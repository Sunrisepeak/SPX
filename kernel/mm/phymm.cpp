#include <phymm.h>
#include <ostream.h>
#include <utils.hpp>

PhyMM::PhyMM() {
    extern PTEntry __boot_pgdir;
    bootPDT = &__boot_pgdir;
}

void PhyMM::init() {
    extern uptr32_t __boot_pgdir;                   // virtual AD of page directory Table
    bootCR3 = vToPhyAD(__boot_pgdir);
    bootCR3 = 1;
    initPmmManager();
    initPage();

//    bootPDT[LAD(VPT)->PDI].p_base = (vToPhyAD((uptr32_t)bootPDT) >> PGSHIFT) && 0xFFFFF;
//    bootPDT[LAD(VPT)->PDI].p_p = 1;
//    bootPDT[LAD(VPT)->PDI].p_rw = 1;

    OStream out("\nInit: ", "blue");
    
    out.writeValue(VPT);
    out.write("  VPT <---> PDI: ");
    out.writeValue(LAD(VPT).PDI);

    out.write("\n");

    out.writeValue(sizeof(LinearAD));
    out.write("  LAD <---> PTE: ");
    out.writeValue(sizeof(PTEntry));

    /*      wait 2020.4.5       */

}

void PhyMM::initPage() {
    E820Map *memMap = (E820Map *)(E820_BUFF + KERNEL_BASE);                      
    uint64_t maxpa = 0;                                                             // size of all mem-block

    OStream out("Memmory Map [E820Map] begin...\n", "blue");
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
    
    nodeArray = (List<Page>::DLNode *)Utils::roundUp((uint32_t)end, PGSIZE);

    out.write("\n nodeArray = ");
    out.writeValue((uint32_t)nodeArray);

    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
        setPageReserved(nodeArray[i].data);
    }

    // get top-address of nodeArray[] element in the end, it is free area when great than the AD
    uptr32_t freeMem = vToPhyAD((uptr32_t)(nodeArray + numPage));
    
    out.write("\n freeMem = ");
    out.writeValue((uint32_t)freeMem);
    out.flush();

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
                    manager->initMemMap(phyADtoPage(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}

void PhyMM::initPmmManager() {
    manager = &ff;
}

uptr32_t PhyMM::vToPhyAD(uptr32_t kvAd) {
    return kvAd - KERNEL_BASE;
}

uptr32_t PhyMM::pToVirAD(uptr32_t pAd) {
    return pAd + KERNEL_BASE;
}

List<MMU::Page>::DLNode * PhyMM::phyADtoPage(uptr32_t pAd) {
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
    return &(nodeArray[pIndex]);
}

