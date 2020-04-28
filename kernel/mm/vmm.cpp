#include <vmm.h>
#include <global.h>
#include <assert.h>
#include <error.h>
#include <sync.h>
#include <kdebug.h>
#include <list.hpp>
#include <queue.hpp>
#include <utils.hpp>

void VMM::init() {
    checkVmm();
}

List<VMM::VMA>::DLNode * VMM::findVma(List<MM>::DLNode *mm, uptr32_t addr) {

    #ifdef VMM_DEBUG
        DEBUGPRINT("VMM::findVma");
    #endif
    
    List<VMA>::DLNode *vma = nullptr;

    if (mm != nullptr) {
        vma = mm->data.mmap_cache;
        if (!(vma != nullptr && vma->data.vm_start <= addr && vma->data.vm_end > addr)) {
                bool found = 0;
                auto it = mm->data.vmaList.getNodeIterator();
                while ((vma = it.nextLNode()) != nullptr) {

                    #ifdef VMM_DEBUG
                        out.write("\ntarget = ");
                        out.writeValue(addr);
                        out.write(" now = ");
                        out.writeValue(vma->data.vm_start);
                        out.flush();
                    #endif
                    
                    if (vma->data.vm_start <= addr && addr < vma->data.vm_end) {
                        
                        #ifdef VMM_DEBUG
                            DEBUGPRINT("VMM::findVma::vma->data.vm_start <= addr && addr < vma->data.vm_end");
                        #endif
                        
                        found = 1;
                        break;
                    }
                }
                if (!found) {
                    vma = nullptr;
                }
        }
        if (vma != nullptr) {
            mm->data.mmap_cache = vma;
        }
    }

    return vma;

}

List<VMM::VMA>::DLNode * VMM::vmaCreate(uptr32_t vmStart, uptr32_t vmEnd, uint32_t vmFlags) {
    DEBUGPRINT("VMM::vmaCreate");
    if (kernel::DEBUG_FLAGS) {
        kernel::stdio::out.writeValue((uint32_t)kernel::pm.current->data.value.tf);
        kernel::stdio::out.flush();
        if ((uint32_t)kernel::pm.current->data.value.tf < 0xC0000000) BREAKPOINT("4");
        DEBUGPRINT("4");
    }

    auto vma = (List<VMA>::DLNode *)(kernel::pmm.kmalloc(sizeof(List<VMA>::DLNode)));
    
    if (kernel::DEBUG_FLAGS) {
        kernel::stdio::out.writeValue((uint32_t)vma);
        kernel::stdio::out.writeValue((uint32_t)kernel::pm.current->data.value.tf);
        kernel::stdio::out.flush();
        if ((uint32_t)kernel::pm.current->data.value.tf < 0xC0000000) BREAKPOINT("5");
        DEBUGPRINT("5");
    }

    if (vma != nullptr) {
        OStream out("", "blue");
        out.writeValue((uint32_t)vma);
        out.flush();

        vma->data.vm_start = vmStart;
        vma->data.vm_end = vmEnd;
        vma->data.vm_flags = vmFlags;
    }
    
    return vma;
}

void VMM::insertVma(List<MM>::DLNode *mm, List<VMA>::DLNode *vma) {
    OStream out("\n[new] vma: vm_start = ", "blue");
    out.writeValue(vma->data.vm_start);
    
    assert(vma->data.vm_start < vma->data.vm_end);
    
    auto it = mm->data.vmaList.getNodeIterator();

    decltype(vma) vmaNode, preVma = nullptr;
    while ((vmaNode = it.nextLNode()) != nullptr) {
        //out.write("\nold = ");
        //out.writeValue(vmaNode->data.vm_start);
        if (vmaNode->data.vm_start > vma->data.vm_start) {
            break;
        }
        //DEBUGPRINT("VMM::insertVma --> while ");
        preVma = vmaNode;
    }

    /* check overlap */
    if (preVma != nullptr) {    // pre-note
        checkVamOverlap(preVma, vma);
    }

    if (vmaNode != nullptr) {   // back-note
        checkVamOverlap(vma, vmaNode);
    }

    vma->data.vm_mm = mm;       // pointer father-MM

    if (preVma == nullptr) {
        mm->data.vmaList.headInsertLNode(vma);
    } else {
        DEBUGPRINT("Inert-->mid");
        mm->data.vmaList.insertLNode(preVma, vma);
    }
    out.write("\nnodeNum: ");
    out.writeValue((mm->data.vmaList.length()));
    out.flush();
}

List<VMM::MM>::DLNode * VMM::mmCreate() {
    DEBUGPRINT(" VMM::mmCreate()");
    auto mm = (List<MM>::DLNode *)(kernel::pmm.kmalloc(sizeof(List<MM>::DLNode)));

    if (kernel::DEBUG_FLAGS) {
        kernel::stdio::out.writeValue((uint32_t)kernel::pm.current->data.value.tf);
        kernel::stdio::out.flush();
        if ((uint32_t)kernel::pm.current->data.value.tf < 0xC0000000) BREAKPOINT("2.2");
    }

    if (mm != nullptr) {

        mm->next = mm->pre = nullptr;
        mm->data.mmap_cache = nullptr;
        mm->data.pdt = nullptr;

        new (&(mm->data.vmaList)) List<VMA>();
        new (&(mm->data.smPriv)) Queue<VMA>();

        if (kernel::swap.initOk()) {
            kernel::swap.swapInitMm(&(mm->data));
        }

        mm->data.mm_share = 0;
        mm->data.mm_lock = false;
        
    }
    return mm;
}

void VMM::mmDestroy(List<MM>::DLNode *mm) {
    assert(mm->data.mm_share == 0);
    auto it = mm->data.vmaList.getNodeIterator();
    List<VMA>::DLNode *vma;
    while ((vma = it.nextLNode()) != nullptr) {

        #ifdef VMM_DEBUG
            out.write("\ndestructor: vma = ");
            out.writeValue((uint32_t)vma);
            out.flush();
        #endif

        mm->data.vmaList.deleteLNode(vma);
        kernel::pmm.kfree(vma, sizeof(List<VMA>::DLNode));  //kfree vma        
    }
    kernel::pmm.kfree(mm, sizeof(List<MM>::DLNode));        //kfree mm
    mm = nullptr;
}

void VMM::checkVmm() {
    DEBUGPRINT("VMM::checkVmm");
    uint32_t nr_free_pages_store = kernel::pmm.numFreePages();

    OStream out("\ncheckVMM : ", "blue");
    out.writeValue(nr_free_pages_store);
    out.flush();
    
    checkVma();
    checkPageFault();
    
    assert(nr_free_pages_store == kernel::pmm.numFreePages());

    //DEBUGPRINT("check_vmm() succeeded.\n");
}

void VMM::checkVma() {
    DEBUGPRINT("VMM::checkVma");

    uint32_t nr_free_pages_store = kernel::pmm.numFreePages();

    auto mm = mmCreate();
    assert(mm != nullptr);

    uint32_t step1 = 10, step2 = step1 * 10;

    // test 10 times for less than for vma-being
    for (uint32_t i = step1; i >= 1; i--) {
        auto *vma = vmaCreate(i * 5, i * 5 + 2, 0);
        assert(vma != nullptr);
        insertVma(mm, vma);
    }
    // test 90 times for great than for vma-being
    for (uint32_t i = step1 + 1; i <= step2; i++) {
        auto *vma = vmaCreate(i * 5, i * 5 + 2, 0);
        assert(vma != nullptr);
        insertVma(mm, vma);
    }

    auto it = mm->data.vmaList.getNodeIterator();
    auto vmaNode = it.nextLNode();

    for (uint32_t i = 1; i <= step2; i++) {

        assert(vmaNode != nullptr);
        assert(vmaNode->data.vm_start == i * 5 && vmaNode->data.vm_end == i * 5 + 2);

        vmaNode = it.nextLNode();
    }

    // check vma by address and test size if normal.
    for (uint32_t i = 5; i <= 5 * step2; i += 5) {      // 5 ~ 500
        // test exist
        auto vma1 = findVma(mm, i);
        assert(vma1 != nullptr);
        auto vma2 = findVma(mm, i + 1);
        assert(vma2 != nullptr);
        
        // test not exist
        auto vma3 = findVma(mm, i + 2);
        assert(vma3 == nullptr);
        auto vma4 = findVma(mm, i + 3);
        assert(vma4 == nullptr);
        auto vma5 = findVma(mm, i + 4);
        assert(vma5 == nullptr);

        // test size
        assert(vma1->data.vm_start == i  && vma1->data.vm_end == i  + 2);
        assert(vma2->data.vm_start == i  && vma2->data.vm_end == i  + 2);
    }

    // tset less than 5
    for (int i = 4; i >= 0; i--) {
        auto *vma_below_5= findVma(mm,i);
        assert(vma_below_5 == nullptr);
    }

    mmDestroy(mm);

    assert(nr_free_pages_store == kernel::pmm.numFreePages());

    DEBUGPRINT("CheckVma succeeded!");

}

// check if vma1 overlaps vma2 ?
void VMM::checkVamOverlap(List<VMA>::DLNode *prev, List<VMA>::DLNode *next) {
    assert(prev->data.vm_start < prev->data.vm_end);
    assert(prev->data.vm_end <= next->data.vm_start);
    assert(next->data.vm_start < next->data.vm_end);
}

void VMM::checkPageFault() {
    DEBUGPRINT("VMM::checkPageFault");
    uint32_t nr_free_pages_store = kernel::pmm.numFreePages();

    checkMM = mmCreate();
    assert(checkMM != nullptr);

    auto mm = checkMM;
    auto pdt = mm->data.pdt = kernel::pmm.getPDT();
    assert(pdt[0].isEmpty());

    auto vma = vmaCreate(0, PTSIZE, VM_WRITE);
    assert(vma != nullptr);

    insertVma(mm, vma);

    uptr32_t addr = 0x100;
    assert(findVma(mm, addr) == vma);

    // default page exception test
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);

    kernel::pmm.removePage(pdt, MMU::LinearAD::LAD(Utils::roundDown(addr, PGSIZE)));
    kernel::pmm.freePages(kernel::pmm.pdeToPgNode(pdt[0]));    
    pdt[0] = 0;

    mm->data.pdt = nullptr;
    mmDestroy(mm);

    checkMM = nullptr;

    assert(nr_free_pages_store == kernel::pmm.numFreePages());

    DEBUGPRINT("check Page fault succeeded!");
}


// do_pgfault - interrupt handler to process the page fault execption
int VMM::doPageFault(List<MM>::DLNode *mm, uint32_t errorCode, uptr32_t addr) {

    OStream out("\n[PageFault Exception] errorCode= ", "blue");
    out.writeValue(errorCode);
    out.flush();

    int ret = -E_INVAL;
    uint32_t perm;
    MMU::PTEntry *pte = nullptr;

    //try to find a vma which include addr
    auto vma = findVma(mm, addr);

    pageFaultNum++;
    //If the addr is in the range of a mm's vma?
    if (vma == nullptr || vma->data.vm_start > addr) {
        DEBUGPRINT("invalid address, not exist in mm");
    } 
    //check the errorCode
    switch (errorCode & 0b11) {
        case 0: /* error code flag : (W/R=0, P=0): read, not present */
            if (!(vma->data.vm_flags & (VM_READ | VM_EXEC))) {
                DEBUGPRINT("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec");
                BREAKPOINT("Read not present");
                goto failed;
            }
            break;

        case 1:     /* error code flag : (W/R=0, P=1): read, present */
            DEBUGPRINT("do_pgfault failed: error code flag = read AND present");
            goto failed;

        case 2:     /* error code flag : (W/R=1, P=0): write, not present */
            if (!(vma->data.vm_flags & VM_WRITE)) {
                DEBUGPRINT("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write");
                goto failed;
            }

            break;

        default: 
            break;   /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    }
   

    perm = PTE_U;
    if (vma->data.vm_flags & VM_WRITE) {
        perm |= PTE_W;
    }

    addr = Utils::roundDown(addr, PGSIZE);

    ret = -E_NO_MEM;

    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((pte = kernel::pmm.getPTE(mm->data.pdt, MMU::LinearAD::LAD(addr))) == nullptr) {
        DEBUGPRINT("get_pte in do_pgfault failed");
        goto failed;
    }
    
    if (pte->isEmpty()) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
        if (kernel::pmm.allocPageAndMap(mm->data.pdt, MMU::LinearAD::LAD(addr), perm) == nullptr) {
            DEBUGPRINT("pgdir_alloc_page in do_pgfault failed");
            goto failed;
        }
    } else { 
        
        // if this pte is a swap entry, then load data from disk to a page with phy addr
        // and call mapPage to map the phy addr with logical addr
        List<MMU::Page>::DLNode *pnode = nullptr;
        if (pte->p_p) {
            BREAKPOINT("not implement only-read");
        } else {
            if(kernel::swap.initOk()) {
                if ((ret = kernel::swap.swapIn(&(mm->data), MMU::LinearAD::LAD(addr), &pnode)) != 0) {
                    DEBUGPRINT("swap_in in do_pgfault failed\n");
                    goto failed;
                }    
            } else {
                DEBUGPRINT("no swap_init_ok but ptep is failed\n");
                goto failed;
            }
        }
    
        kernel::pmm.mapPage(mm->data.pdt, pnode, MMU::LinearAD::LAD(addr), perm);
        kernel::swap.swapMapSwappable(&(mm->data), MMU::LinearAD::LAD(addr), pnode, 1);
        pnode->data.praLAD = addr;
   }

   ret = 0;

failed:

    return ret;
}

/*
 *  setting user space in law [mm Map]
 * 
 **/

int VMM::mmMap(
    Linker<MM>::DLNode *mm,
    uptr32_t addr,
    uint32_t len,
    uint32_t vm_flags,
    Linker<VMA>::DLNode **vma_store
) {

    DEBUGPRINT("VMM::mmMap");

    uptr32_t start = Utils::roundDown(addr, PGSIZE), end = Utils::roundUp(addr + len, PGSIZE);
    if (!USER_ACCESS(start, end)) {
        return -E_INVAL;
    }

    assert(mm != nullptr);

    int ret = -E_INVAL;

    Linker<VMA>::DLNode *vma;
    if ((vma = findVma(mm, start)) != nullptr && end > vma->data.vm_start) {
        goto out;
    }
    
    ret = -E_NO_MEM;
    if ((vma = vmaCreate(start, end, vm_flags)) == nullptr) {
        goto out;
    }

    kernel::stdio::out.writeValue((uint32_t)kernel::pm.current->data.value.tf);
    kernel::stdio::out.flush();
    if ((uint32_t)kernel::pm.current->data.value.tf < 0xC0000000) BREAKPOINT("3");

    insertVma(mm, vma);
    
    if (vma_store != nullptr) {
        *vma_store = vma;
    }

       

    ret = 0;

out:
    return ret;
}

int VMM::dupMmMap(Linker<MM>::DLNode *from, Linker<MM>::DLNode *to) {

    assert(to != nullptr && from != nullptr);
    auto it = from->data.vmaList.getNodeIterator();
    Linker<VMA>::DLNode *vma;
    while ((vma = it.nextLNode()) != nullptr) {
        Linker<VMA>::DLNode *newVma;
        newVma = vmaCreate(vma->data.vm_start, vma->data.vm_end, vma->data.vm_flags);
        if (newVma == nullptr) {
            return -E_NO_MEM;
        }

        insertVma(to, newVma);

        if (kernel::pmm.copyRange(from->data.pdt, to->data.pdt, vma->data.vm_start, vma->data.vm_end) != 0) {
            return -E_NO_MEM;
        }
    }
    return 0;
}

void VMM::exitMmMap(Linker<MM>::DLNode *mm) {
    assert(mm != nullptr && mm->data.vmaList.length() == 0);
    auto pdt = mm->data.pdt;
    auto it = mm->data.vmaList.getNodeIterator();
    Linker<VMA>::DLNode *vma;
    while ((vma = it.nextLNode()) != nullptr) {
        kernel::pmm.unmapRange(pdt, vma->data.vm_start, vma->data.vm_end);
    }
    while ((vma = it.nextLNode()) != nullptr) {
        kernel::pmm.exitRange(pdt, vma->data.vm_start, vma->data.vm_end);
    }
}

bool VMM::userMemCheck(Linker<MM>::DLNode *mm, uptr32_t start, uint32_t len, bool write) {
    if (mm != nullptr) {
        if (!USER_ACCESS(start, start + len)) {
            return false;
        }
        Linker<VMA>::DLNode *vma;
        uptr32_t addr = start, end = start + len;
        while (addr < end) {
            if ((vma = findVma(mm, addr)) == nullptr || addr < vma->data.vm_start) {
                return false;
            }
            if (!(vma->data.vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return false;
            }
            if (write && (vma->data.vm_flags & VM_STACK)) {
                if (addr < vma->data.vm_start + PGSIZE) { //check stack start & size
                    return false;
                }
            }
            addr = vma->data.vm_end;
        }
        return true;
    }
    return KERN_ACCESS(start, start + len);
}


bool VMM::copyToKernel(
    Linker<MM>::DLNode *mm,
    const void *src, 
    void *dst, 
    uint32_t len, 
    bool writable
) {
    if (!userMemCheck(mm, (uptr32_t)src, len, writable)) {
        return false;
    }
    Utils::memcpy(src, dst, len);
    return true;
}

bool VMM::copyToUser(Linker<MM>::DLNode *mm, const void *src, void *dst, uint32_t len) {
    if (!userMemCheck(mm, (uptr32_t)dst, len, true)) {
        return false;
    }
    Utils::memcpy(src, dst, len);
    return true;
}

void VMM::lockMm(MM &mm) {
    lock(mm.mm_lock);
}

void VMM::unlockMm(MM &mm) {
    unlock(mm.mm_lock);
}