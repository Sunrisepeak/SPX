#ifndef _SWAP_FIFO_H
#define _SWAP_FIFO_H

#include <defs.h>
#include <SwapManager.h>

class SwapFifo : public SwapManager {

    public:

        int init();

        int initMM(VMM::MM *mm);

        int tickEvent(VMM::MM *mm);

        int mapSwappable(VMM::MM *mm, uptr32_t addr, MMU::Page *page, uint32_t swapIn);

        int setUnswappable(VMM::MM *mm, uptr32_t addr);
        
        int swapOutVictim(VMM::MM *mm, MMU::Page **ptrPage, uint32_t inTick);
        
};

#endif