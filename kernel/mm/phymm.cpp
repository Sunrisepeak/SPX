#include <phymm.h>
#include <ostream.h>

void PhyMM::init() {
    extern uptr32_t __boot_pgdir;                   // virtual AD of page directory Table
    bootCR3 = vToPhyAD(__boot_pgdir);
    bootCR3 = 1;

    initPage();
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
        
        out.write("\n", true);
    }

    if (maxpa > KERNEL_MEM_SIZE) {
        maxpa = KERNEL_MEM_SIZE;
    }


    extern uint8_t end[];
    numPage = maxpa / PGSIZE;          // get number of page
    
    out.write("\n numPage = ");
    out.writeValue(numPage);
    
    pages = (Page *)roundUp((uint32_t)end, PGSIZE);

    out.write("\n pages = ");
    out.writeValue((uint32_t)pages);

    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
        SetPageReserved(pages + i);
    }
    // get top-address of pages[] element in the end
    uptr32_t freeMem = vToPhyAD((uptr32_t)(pages + numPage));
    
    out.write("\n freeMem = ");
    out.writeValue((uint32_t)freeMem);


    /*     wait --- 2020.4.4      */

}

void PhyMM::initPmmManager() {
   
}

uptr32_t PhyMM::vToPhyAD(uptr32_t kvAd) {
    return kvAd - KERNEL_BASE;
}

uptr32_t PhyMM::pToVirAD(uptr32_t pAd) {
    return pAd + KERNEL_BASE;
}

uint32_t PhyMM::roundUp(uint32_t a, uint32_t n) {
    a = (a % n == 0) ? a : (a / n + 1) * n;
    return a;
}

