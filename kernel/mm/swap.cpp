#include <swap.h>
#include <swapfs.hpp>
#include <global.h>
#include <kdebug.h>

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
        //checkSwap();
    }

    return r;
}
        
uint32_t Swap::swapInitMm(VMM::MM *mm) {

}

uint32_t Swap::swapTickEvent(VMM::MM *mm) {

}

uint32_t Swap::swapMapSwappable(VMM::MM *mm, uptr32_t ad, MMU::Page *page, uint32_t swapIn) {

}

uint32_t Swap::swapSetUnswappable(VMM::MM *mm, uptr32_t ad) {

}

uint32_t Swap::swapOut(VMM::MM *mm, uint32_t n, uint32_t inTick) {

}

uint32_t Swap::swapIn(VMM::MM *mm, uptr32_t ad, MMU::Page **ptrResult) {

}

bool Swap::initOk() {

}

void Swap::setMaxSwapOffset(uint32_t size) {

}

