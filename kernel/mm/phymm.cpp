#include <phymm.h>
#include <assert.h>
#include <error.h>
#include <global.h>
#include <kdebug.h>
#include <sync.h>
#include <swap.h>
#include <ostream.h>
#include <utils.hpp>

PhyMM::PhyMM() {
    extern PTEntry __boot_pgdir;
    bootPDT = &__boot_pgdir;

    bootCR3 = kAdToPhyAD((uptr32_t)bootPDT);

    extern uptr32_t bootstack, bootstacktop;
    stack = bootstack;
    stackTop = bootstacktop;
    
}

void PhyMM::init() {


    initPmmManager();
    initPage();

    // map to page-dir-table by Virtual Page Table
    bootPDT[LinearAD::LAD(VPT).PDI].p_ppn = (kAdToPhyAD((uptr32_t)bootPDT) >> PGSHIFT) && 0xFFFFF;
    bootPDT[LinearAD::LAD(VPT).PDI].p_p = 1;
    bootPDT[LinearAD::LAD(VPT).PDI].p_rw = 1;

    /*      wait 2020.4.5       */
    // map kernel segment pAD[0 ~ KERNEL_MEM_SIZE] to vAD[KERNEL_BASE ~ (KERNEL_BASE + KERNEL_MEM_SIZE)]
    mapSegment(KERNEL_BASE, 0, KERNEL_MEM_SIZE, PTE_W);

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    initGDTAndTSS();

}

void PhyMM::initPage() {
    E820Map *memMap = (E820Map *)(E820_BUFF + KERNEL_BASE);                      
    uint64_t maxpa = 0;                                                             // size of all mem-block

    OStream out("\nMemmory Map [E820Map] begin...\n", "blue");
    for (uint32_t i = 0; i < memMap->numARDS; i++) {                               // scan all of free memory block
        // get AD of begin and end of current Mem-Block 
        uint64_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
        
        out.write(" >> size = ");
        out.writeValue(memMap->ARDS[i].size);
        out.write(" range: ");
        out.writeValue(begin);
        out.write(" ~ ");
        out.writeValue(end - 1);
        out.write(" type = ");
        out.writeValue(memMap->ARDS[i].type);
        
        if (memMap->ARDS[i].type == E820_ARM) {                                    // is ARM Area
            if (maxpa < end && begin < KERNEL_MEM_SIZE) {
                maxpa = end;
            }
        }
        
        out.write("\n");
    }


    if (maxpa > KERNEL_MEM_SIZE) {
        maxpa = KERNEL_MEM_SIZE;
    }


    extern uint8_t end[];
    numPage = maxpa / PGSIZE;          // get number of page
    
    out.write("\n numPage = ");
    out.writeValue(numPage);
    
    pNodeArr = (List<Page>::DLNode *)Utils::roundUp((uint32_t)end, PGSIZE);

    out.write("\n pNodeArr = ");
    out.writeValue((uint32_t)pNodeArr);

    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
        setPageReserved(pNodeArr[i].data);
    }

    // get top-address of pNodeArr[] element in the end, it is free area when great than the AD
    uptr32_t freeMem = kAdToPhyAD((uptr32_t)(pNodeArr + numPage));
    
    out.write("\n freeMem = ");
    out.writeValue((uint32_t)freeMem);
    out.flush();

    //BREAKPOINT("test Memory");

    for (uint32_t i = 0; i < memMap->numARDS; i++) {
        // get AD of begin and end of current Mem-Block 
        uptr32_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
        
        if (memMap->ARDS[i].type == E820_ARM) {                                    // is ARM Area
            if (begin < freeMem) {
                begin = freeMem;
            }
            if (end > KERNEL_MEM_SIZE) {
                end = KERNEL_MEM_SIZE;
            }
            if (begin < end) {
                begin = Utils::roundUp(begin, PGSIZE);
                end = Utils::roundDown(end, PGSIZE);
                if (begin < end) {
                    manager->initMemMap(phyAdToPgNode(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}

void PhyMM::initGDTAndTSS() {
    // set kernel stack of boot-time[default]
    tss.ts_esp0 = (uptr32_t)stackTop;
    tss.ts_ss0 = KERNEL_DS;

    /* *
    * Global Descriptor Table:
    *
    * The kernel and user segments are identical (except for the DPL). To load
    * the %ss register, the CPL must equal the DPL. Thus, we must duplicate the
    * segments for the user and the kernel. Defined as follows:
    *
    *   index[per-8byte]
    *   - 0:    unused (always faults -- for trapping NULL far pointers)
    *   - 1:    kernel code segment
    *   - 2:    kernel data segment
    *   - 3:    user code segment
    *   - 4:    user data segment
    *   - 5:    defined for tss, initialized in gdt_init
    * */
    GDT[0] = SEG_NULL;
    GDT[SEG_KTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_KERNEL);
    GDT[SEG_KDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_KERNEL);
    GDT[SEG_UTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_USER);
    GDT[SEG_UDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_USER);
    GDT[SEG_TSS] = setTssDesc(STS_T32A, (uptr32_t)(&tss), sizeof(tss), DPL_KERNEL);
    
    // reload globle descript table register
    lgdt(&gdtPD);
    // reset segment register
    setSegR(KERNEL_CS, KERNEL_DS, KERNEL_DS, KERNEL_DS, USER_DS, USER_DS);
    // load Tss to task register
    ltr(GD_TSS);
}

void PhyMM::initPmmManager() {
    manager = &(kernel::algorithms::ffma);
}

void PhyMM::mapSegment(uptr32_t lad, uptr32_t pad, uint32_t size, uint32_t perm) {
    OStream out("\nmapSegment:\n lad: ", "blue");
    out.writeValue(lad);
    out.write(" to pad: ");
    out.writeValue(pad);
    out.write("   size = ");
    out.writeValue(size);
    out.flush();
    out.write("\n");

    lad = Utils::roundDown(lad, PGSIZE);
    pad = Utils::roundDown(pad, PGSIZE);

    out.writeValue(lad);
    out.write(" to pad: ");
    out.writeValue(pad);
    out.flush();

    // map by page-size
    uint32_t n = Utils::roundUp(size + LinearAD::LAD(lad).OFF, PGSIZE) / PGSIZE;

    out.write("\nn = ");
    out.writeValue(n);
    out.flush();

    for (uint32_t i = 0; i < n; i++) {
        PTEntry *pte = getPTE(bootPDT, LinearAD::LAD(lad));

        pte->setPermission(PTE_P | perm);
        pte->p_ppn = (pad >> PGSHIFT);         // set physical address (20-bits)
        
        lad += PGSIZE;
        pad += PGSIZE;
    }
}

int PhyMM::mapPage(PTEntry *pdt, List<Page>::DLNode *pnode, LinearAD lad, uint32_t perm) {
    DEBUGPRINT("PhyMM::mapPage");
    auto pte = getPTE(pdt, lad);
    if (pte == nullptr) {
        return -E_NO_MEM;
    }

    if (pte->p_p) {         // is present?
        auto oldPnode = pteToPgNode(*pte);
        if (oldPnode == pnode) {
            pnode->data.ref--;
        } else {
            removePTE(pdt, lad, pte);
        }
    }

    // [IMPLICATION BUG] here, have a Bug about order...
    // set pte content : please take less to great order[1 -> 2]
    pte->setPermission(perm);           // previous 1

    pte->p_ppn = pnode - pNodeArr;      // back     2
    pte->p_p = 1;

    pnode->data.ref++;

    tlbInvalidData(pdt, lad);

    return 0;
}


uptr32_t PhyMM::kAdToPhyAD(uptr32_t kvAd) {
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
        return kvAd - KERNEL_BASE;
    }
    return 0;
}

uptr32_t PhyMM::pToVirAD(uptr32_t pAd) {
    if (pAd <= KERNEL_MEM_SIZE) {
        return pAd + KERNEL_BASE;
    }
    return 0;
}

List<MMU::Page>::DLNode * PhyMM::phyAdToPgNode(uptr32_t pAd) {
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
    return &(pNodeArr[pIndex]);
}

List<MMU::Page>::DLNode * PhyMM::kvAdToPgNode(uptr32_t vAd) {
    uint32_t pIndex = kAdToPhyAD(vAd) >> PGSHIFT;       // get pages-No
    return &(pNodeArr[pIndex]);
}

uptr32_t PhyMM::pnodeToKernelLAD(List<Page>::DLNode *node) {
    uint32_t pageNo = node - pNodeArr;       // physical memory page NO
    return pToVirAD(pageNo << PGSHIFT);
}

MMU::PTEntry * PhyMM::pdeToPTable(const PTEntry &pte) {
    uptr32_t ptAD= pToVirAD(pte.p_ppn << PGSHIFT);
    return (PTEntry *)ptAD;
}

List<MMU::Page>::DLNode * PhyMM::pteToPgNode(const PTEntry &pte) {
    return &(pNodeArr[pte.p_ppn]);
}

List<MMU::Page>::DLNode * PhyMM::pdeToPgNode(const PTEntry &pde) {
    return &(pNodeArr[pde.p_ppn]);
}

MMU::PTEntry * PhyMM::getPTE(PTEntry *pdt, const LinearAD &lad, bool create) {
    PTEntry &pde = pdt[lad.PDI];                         // spend one day to debug. AI
    if (!(pde.p_p) && create) {                          // check present bit and is create?
        /*      wait 2020.4.6      */
        List<Page>::DLNode *pnode;
        if ((pnode = manager->allocPages()) == nullptr) {
            return nullptr;
        }
        pnode->data.ref = 1;
        // clear page content
        Utils::memset((void *)(pnodeToKernelLAD(pnode)), 0, PGSIZE);
        // set permssion
        pde.p_ppn = pnode - pNodeArr;
        pde.p_us = 1;
        pde.p_rw = 1;
        pde.p_p = 1;
    }
    return &(pdeToPTable(pde)[lad.PTI]);
}

void PhyMM::removePTE(PTEntry *pdt, const LinearAD &lad, PTEntry *pte) {
    DEBUGPRINT("PhyMM::removePTE");
     if (pte->p_p) {
        auto pnode = pteToPgNode(*pte);
        if (--(pnode->data.ref) == 0) {
            freePages(pnode);
        }
        // set zero
        Utils::memset(pte, 0, sizeof(PTEntry));
        tlbInvalidData(pdt, lad);
    }
}


MMU::PTEntry * PhyMM::getPDT() {
    return bootPDT;
}

uptr32_t PhyMM::getCR3() {
    return bootCR3;
}

uptr32_t PhyMM::getStack() {
    return stack;
}

void PhyMM::removePage(PTEntry *pdt, LinearAD lad) {
    auto pte = getPTE(pdt, lad, false);
    if (pte != nullptr) {
        removePTE(pdt, lad, pte);
    }
}

List<MMU::Page>::DLNode * PhyMM::allocPages(uint32_t n) {
    
    List<Page>::DLNode *pnode = nullptr;
    bool intr_flag;
    
    while (true) {

        local_intr_save(intr_flag);
        {
            pnode = manager->allocPages(n);
        }
        local_intr_restore(intr_flag);

        if (pnode != nullptr || n > 1 || kernel::swap.initOk() == false) break;
        
        kernel::swap.swapOut(&(kernel::vmm.checkMM->data), n, 0);
    }
    return pnode;
}

List<MMU::Page>::DLNode * PhyMM::allocPageAndMap(PTEntry *pdt, LinearAD lad, uint32_t perm) {

    DEBUGPRINT("PhyMM::allocPageAndMap");

    auto pnode = allocPages();
    if (pnode != nullptr) {
        if (mapPage(pdt, pnode, lad, perm) != 0) {
            freePages(pnode);
            return nullptr;
        }

        if (kernel::swap.initOk()) {

            if(kernel::vmm.checkMM != nullptr) {
     
                kernel::swap.swapMapSwappable(&(kernel::vmm.checkMM->data), lad, pnode, 0);
                pnode->data.praLAD = lad;
                assert(pnode->data.ref == 1);
                
                OStream out("","blue");
                out.write("\n[Get Page]:\n   praLAD = ");
                out.writeValue(lad.Integer());
                out.write(", [praLink.prev, praLink.next] = ");
                out.writeValue((uint32_t) (pnode->pre));
                out.write(", ");
                out.writeValue((uint32_t) (pnode->next));
                out.flush();
            } 

        }
    }

    return pnode;
}

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void PhyMM::freePages(List<Page>::DLNode *base, uint32_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        manager->freePages(base, n);
    }
    local_intr_restore(intr_flag);
}


void * PhyMM::kmalloc(uint32_t size) {
    DEBUGPRINT("PhyMM::kmalloc ");
   
    void * ptr = nullptr;
    List<Page>::DLNode *base = nullptr;
    assert(size > 0 && size < 1024*0124);
    uint32_t num_pages = (size + PGSIZE - 1 ) / PGSIZE;

    kernel::stdio::out.writeValue(num_pages);
    kernel::stdio::out.flush();

    base = allocPages(num_pages);

    assert(base != nullptr);
    ptr = (void *)pnodeToKernelLAD(base);
    return ptr;
}

void PhyMM::kfree(void *ptr, uint32_t size) {
    assert(size > 0 && size < 1024*0124);
    assert(ptr != nullptr);
    List<Page>::DLNode *base = nullptr;
    uint32_t num_pages = (size + PGSIZE - 1) / PGSIZE;
    base = phyAdToPgNode(kAdToPhyAD((uptr32_t)ptr));
    freePages(base, num_pages);
}

uint32_t PhyMM::numFreePages() {
    uint32_t ret;
    bool intr_flag;
    local_intr_save(intr_flag); 
    {
        ret = manager->numFreePages();
    }
    local_intr_restore(intr_flag);
    return ret;
}

void PhyMM::tlbInvalidData(PTEntry *pdt, LinearAD lad) {
    if (getCR3() == kAdToPhyAD((uptr32_t)pdt)) {
        invlpg((void *)(lad.Integer()));
    }
}

/* *
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void PhyMM::loadEsp0(uptr32_t esp0) {
    tss.ts_esp0 = esp0;
}


void PhyMM::unmapRange(PTEntry *pdt, uptr32_t start, uptr32_t end) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));

    do {
        auto pte = getPTE(pdt, start, false);
        if (pte == nullptr) {
            start = Utils::roundDown(start + PTSIZE, PTSIZE);
            continue ;
        }
        if (!(pte->isEmpty())) {
            removePTE(pdt, start, pte);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
}

void PhyMM::exitRange(PTEntry *pdt, uptr32_t start, uptr32_t end) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));

    start = Utils::roundDown(start, PTSIZE);
    do {
        uint32_t pdi = LinearAD::LAD(start).PDI;
        if (pdt[pdi].p_p) {
            freePages(pdeToPgNode(pdt[pdi]));
            pdt[pdi] = 0;
        }
        start += PTSIZE;
    } while (start != 0 && start < end);
}

int PhyMM::copyRange(PTEntry *from, PTEntry *to, uptr32_t start, uptr32_t end, bool share) {
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
    assert(USER_ACCESS(start, end));
    // copy content by page unit.
    do {
        //call getPTE to find process A's pte according to the addr start
        auto pte = getPTE(from, start, false);
        decltype(pte) npte;
        
        if (pte == nullptr) {
            start = Utils::roundDown(start + PTSIZE, PTSIZE);
            continue ;
        }
        //call getPTE to find process B's pte according to the addr start. If pte is NULL, just alloc a PT
        if (pte->p_p) {
            if ((npte = getPTE(to, start)) == nullptr) {
                return -E_NO_MEM;
            }
            uint32_t perm = pte->p_us;
            //get page node from pte
            auto pnode = pteToPgNode(*pte);
            // alloc a page for process B
            auto npnode = allocPages();
            assert(pnode != nullptr);
            assert(npnode != nullptr);
            int ret = 0;
            
            auto kva_src = pnodeToKernelLAD(pnode);
            auto kva_dst = pnodeToKernelLAD(npnode);
        
            Utils::memcpy((void *)kva_src, (void *)kva_dst, PGSIZE);

            ret = mapPage(to, npnode, start, perm);
            assert(ret == 0);
        }
        start += PGSIZE;
    } while (start != 0 && start < end);
    return 0;
}