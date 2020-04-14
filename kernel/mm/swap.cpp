#include <swap.h>
#include <swapfs.hpp>
#include <global.h>
#include <mmu.h>
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
    return 0;
}

uint32_t Swap::swapIn(VMM::MM *mm, uptr32_t ad, Linker<MMU::Page>::DLNode **ptrResult) {
    auto result = kernel::pmm.allocPages();
    assert(result != nullptr);

    auto pte = kernel::pmm.getPTE(mm->pdt, MMU::LinearAD::LAD(ad), false);
    
    int r;
    if ((r = SwapFs::swapfsRead(pte, result)) != 0) {
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

