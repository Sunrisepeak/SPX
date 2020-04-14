#ifndef __KERN_MM_SWAP_H__
#define __KERN_MM_SWAP_H__

#include <defs.h>
#include <memlayout.h>
#include <phymm.h>
#include <vmm.h>
#include <SwapManager.h>

/* *
 * swap_entryT
 *E-------------------------------------------
 * |         offset        |   reserved   | 0 |
 * --------------------------------------------
 *           24 bits            7 bits    1 bit
 * */

#define MAX_SWAP_OFFSET_LIMIT                   (1 << 24)

class Swap {

    public:

        uint32_t swapInit(void);
        
        uint32_t swapInitMm(VMM::MM *mm);
        
        uint32_t swapTickEvent(VMM::MM *mm);
        
        uint32_t swapMapSwappable(VMM::MM *mm, uptr32_t ad, MMU::Page *page, uint32_t swapIn);
        
        uint32_t swapSetUnswappable(VMM::MM *mm, uptr32_t ad);
        
        uint32_t swapOut(VMM::MM *mm, uint32_t n, uint32_t inTick);
        
        uint32_t swapIn(VMM::MM *mm, uptr32_t ad, Linker<MMU::Page>::DLNode **ptrResult);

        bool initOk();

        static void setMaxSwapOffset(uint32_t size);

    private:

        SwapManager *sm;

        static uint32_t maxSwapOffset;

        bool initok { 0 };

};

#endif
