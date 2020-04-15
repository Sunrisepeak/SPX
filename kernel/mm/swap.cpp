#include <swap.h>
#include <assert.h>
#include <swapfs.hpp>
#include <global.h>
#include <mmu.h>
#include <kdebug.h>
#include <ostream.h>
#include <list.hpp>
#include <utils.hpp>

uint32_t Swap::swapInit() {
    SwapFs::swapfsInit();

    if (!(1024 <= maxSwapOffset && maxSwapOffset < MAX_SWAP_OFFSET_LIMIT)) {
        BREAKPOINT("bad maxSwapOffset");
    }
    
    sm = &(kernel::algorithms::swapFifo);

    int r = sm->init();

    if (r == 0) {
        initok = true;
        DEBUGPRINT("Swap Manager: ");
        checkSwap();
    }

    return r;
}
        
uint32_t Swap::swapInitMm(VMM::MM *mm) {
    return 0;
}

uint32_t Swap::swapTickEvent(VMM::MM *mm) {
    return 0;
}

uint32_t Swap::swapMapSwappable(VMM::MM *mm, uptr32_t ad, MMU::Page *page, uint32_t swapIn) {
    return 0;
}

uint32_t Swap::swapSetUnswappable(VMM::MM *mm, uptr32_t ad) {
    return 0;
}

uint32_t Swap::swapOut(VMM::MM *mm, uint32_t n, uint32_t inTick) {
    uint32_t i = 0;
    SwapEntry swapEntry;

    for (; i != n; i++) {
        uptr32_t v;
        //Linker<MMU::Page>::DLNode **ptr_page = NULL;
        Linker<MMU::Page>::DLNode *pnode = nullptr;
        // cprintf("i %d, SWAP: call swap_out_victim\n",i);
        int r = sm->swapOutVictim(mm, &pnode, inTick);
        if (r != 0) {
            DEBUGPRINT("i %d, swap_out: call swap_out_victim failed");
            break;
        }          

        v = pnode->data.pra_vaddr; 
        auto pte = kernel::pmm.getPTE(mm->pdt, MMU::LinearAD::LAD(v), false);
        assert(pte->p_p != 0);

        swapEntry.setSecno(pnode->data.pra_vaddr / PGSIZE + 1);
        if (SwapFs::swapfsWrite(swapEntry, pnode) != 0) {
            DEBUGPRINT("SWAP: failed to save");
            sm->mapSwappable(mm, v, pnode, 0);
            continue;
        } else {
            DEBUGPRINT("swap_out: i %d, store page in vaddr 0x%x to disk swap entry");
            pte->setSecno((pnode->data.pra_vaddr / PGSIZE) + 1);
            kernel::pmm.freePages(pnode);
        }
        
        kernel::pmm.tlbInvalidData(mm->pdt, MMU::LinearAD::LAD(v));
    }
    return i;
}

uint32_t Swap::swapIn(VMM::MM *mm, uptr32_t ad, Linker<MMU::Page>::DLNode **ptrResult) {
    auto result = kernel::pmm.allocPages();
    assert(result != nullptr);

    auto pte = kernel::pmm.getPTE(mm->pdt, MMU::LinearAD::LAD(ad), false);
    
    int r;
    if ((r = SwapFs::swapfsRead(*pte, result)) != 0) {
        assert(r != 0);
    }

    DEBUGPRINT("swap_in: load disk swap entry %d with swap_page");
    *ptrResult = result;

    return 0;
}

bool Swap::initOk() {
    return initok;
}

void Swap::setMaxSwapOffset(uint32_t size) {
    maxSwapOffset = size;
}

void Swap::checkSwap() {

    OStream out("", "blue");

    //backup mem env
    int ret, count = 0, total = 0;
    auto it = kernel::algorithms::ffma.getFreeArea().getNodeIterator();
    Linker<MMU::Page>::DLNode *pnode;
    while ((pnode = it.nextLNode()) != nullptr) {
        assert(pnode->data.status & 2);
        count++, total += pnode->data.property;
    }
    assert(total = (kernel::pmm.numFreePages()));
    
    DEBUGPRINT("BEGIN check_swap: [count, total] = \n");
    out.writeValue(count);
    out.write(", ");
    out.writeValue(total);
    out.flush();
     
    //now we set the phy pages env     
    auto mm = kernel::vmm.mmCreate();
    assert(mm != nullptr);

    assert(kernel::vmm.checkMM == nullptr);

    kernel::vmm.checkMM = mm;

    auto pdt = mm->data.pdt = kernel::pmm.getPDT();
    assert(pdt[0].isEmpty());

    auto vma = kernel::vmm.vmaCreate(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
    assert(vma != nullptr);

    kernel::vmm.insertVma(mm, vma);

    //setup the temp Page Table vaddr 0~4MB
    DEBUGPRINT("setup Page Table for vaddr 0X1000, so alloc a page");
    auto tempPte = kernel::pmm.getPTE(mm->data.pdt, MMU::LinearAD::LAD(BEING_CHECK_VALID_VADDR));
    assert(tempPte != nullptr);
    DEBUGPRINT("setup Page Table vaddr 0~4MB OVER!");
    
    for (uint32_t i = 0; i < CHECK_VALID_PHY_PAGE_NUM ; i++) {
        check_rp[i] = kernel::pmm.allocPages();
        assert(check_rp[i] != nullptr );
        assert(!(check_rp[i]->data.status & 0x2));
    }

    // set environment of haven't freePage
    List<MMU::Page> save;
    Utils::swap(save, kernel::algorithms::ffma.getFreeArea());

    uint32_t nr_free_store = kernel::pmm.numFreePages();
    kernel::algorithms::ffma.setNFP(0);

    for (uint32_t i = 0 ;i < CHECK_VALID_PHY_PAGE_NUM; i++) {
        kernel::pmm.freePages(check_rp[i]);
    }

    assert(kernel::pmm.numFreePages() == CHECK_VALID_PHY_PAGE_NUM);
    
    DEBUGPRINT("set up init env for checkSwap begin!");
    //setup initial vir_page<->phy_page environment for page relpacement algorithm 

    
    kernel::vmm.pageFaultNum = 0;
    
    checkContentSet();
    assert(kernel::pmm.numFreePages() == 0);         
    for(uint32_t i = 0; i < MAX_SEQ_NO ; i++) 
        swap_out_seq_no[i] = swap_in_seq_no[i] = -1;
    
    for (uint32_t i = 0; i < CHECK_VALID_PHY_PAGE_NUM;i++) {
        check_ptep[i]=0;
        check_ptep[i] = kernel::pmm.getPTE(pdt, MMU::LinearAD::LAD((i + 1) * 0x1000), false);
        //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
        assert(check_ptep[i] != nullptr);
        assert(kernel::pmm.pteToPgNode(*check_ptep[i]) == check_rp[i]);
        assert(check_ptep[i]->p_p == 1);          
    }
    DEBUGPRINT("set up init env for checkSwap over!");
    // now access the virt pages to test  page relpacement algorithm 
    ret = checkContentAccess();
    assert(ret == 0);
    
    //restore kernel mem env
    for (uint32_t i = 0; i < CHECK_VALID_PHY_PAGE_NUM; i++) {
        kernel::pmm.freePages(check_rp[i]);
    } 

    kernel::vmm.mmDestroy(mm);

    // restore  info of free page
    Utils::swap(save, kernel::algorithms::ffma.getFreeArea());
    kernel::algorithms::ffma.setNFP(nr_free_store);

    
    it = kernel::algorithms::ffma.getFreeArea().getNodeIterator();
    while ((pnode = it.nextLNode()) != nullptr) {
        assert(pnode->data.status & 2);
        count--, total -= pnode->data.property;
    }

    DEBUGPRINT("(count, total)");
    out.writeValue(count);
    out.write(", ");
    out.writeValue(total);
    out.flush();
    
    assert(count == 0);
    
    DEBUGPRINT("checkSwap() succeeded!\n");
}

void Swap::checkContentSet() {

    *(uchar8_t *)0x1000 = 0x0a;
     assert(kernel::vmm.pageFaultNum == 1);
     *(uchar8_t *)0x1010 = 0x0a;
     assert(kernel::vmm.pageFaultNum == 1);
     *(uchar8_t *)0x2000 = 0x0b;
     assert(kernel::vmm.pageFaultNum == 2);
     *(uchar8_t *)0x2010 = 0x0b;
     assert(kernel::vmm.pageFaultNum == 2);
     *(uchar8_t *)0x3000 = 0x0c;
     assert(kernel::vmm.pageFaultNum == 3);
     *(uchar8_t *)0x3010 = 0x0c;
     assert(kernel::vmm.pageFaultNum == 3);
     *(uchar8_t *)0x4000 = 0x0d;
     assert(kernel::vmm.pageFaultNum == 4);
     *(uchar8_t *)0x4010 = 0x0d;
     assert(kernel::vmm.pageFaultNum == 4);

}

int Swap::checkContentAccess() {

    DEBUGPRINT("write Virt Page c in fifo_check_swap");
    *(uchar8_t *)0x3000 = 0x0c;
    assert(kernel::vmm.pageFaultNum == 4);
    DEBUGPRINT("write Virt Page a in fifo_check_swap");
    *(uchar8_t *)0x1000 = 0x0a;
    assert(kernel::vmm.pageFaultNum == 4);
    DEBUGPRINT("write Virt Page d in fifo_check_swap");
    *(uchar8_t *)0x4000 = 0x0d;
    assert(kernel::vmm.pageFaultNum == 4);
    DEBUGPRINT("write Virt Page b in fifo_check_swap");
    *(uchar8_t *)0x2000 = 0x0b;
    assert(kernel::vmm.pageFaultNum == 4);
    DEBUGPRINT("write Virt Page e in fifo_check_swap");
    *(uchar8_t *)0x5000 = 0x0e;
    assert(kernel::vmm.pageFaultNum == 5);
    DEBUGPRINT("write Virt Page b in fifo_check_swap");
    *(uchar8_t *)0x2000 = 0x0b;
    assert(kernel::vmm.pageFaultNum == 5);
    DEBUGPRINT("write Virt Page a in fifo_check_swap");
    *(uchar8_t *)0x1000 = 0x0a;
    assert(kernel::vmm.pageFaultNum == 6);
    DEBUGPRINT("write Virt Page b in fifo_check_swap");
    *(uchar8_t *)0x2000 = 0x0b;
    assert(kernel::vmm.pageFaultNum == 7);
    DEBUGPRINT("write Virt Page c in fifo_check_swap");
    *(uchar8_t *)0x3000 = 0x0c;
    assert(kernel::vmm.pageFaultNum == 8);
    DEBUGPRINT("write Virt Page d in fifo_check_swap");
    *(uchar8_t *)0x4000 = 0x0d;
    assert(kernel::vmm.pageFaultNum == 9);
    DEBUGPRINT("write Virt Page e in fifo_check_swap");
    *(uchar8_t *)0x5000 = 0x0e;
    assert(kernel::vmm.pageFaultNum == 10);
    DEBUGPRINT("write Virt Page a in fifo_check_swap");
    assert(*(uchar8_t *)0x1000 == 0x0a);
    *(uchar8_t *)0x1000 = 0x0a;
    assert(kernel::vmm.pageFaultNum == 11);
    return 0;

}

