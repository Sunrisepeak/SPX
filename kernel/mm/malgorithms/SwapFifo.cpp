#include <SwapFifo.h>
#include <swapfs.hpp>


int SwapFifo::init() {

}

int SwapFifo::initMM(VMM::MM *mm) {

}

int SwapFifo::tickEvent(VMM::MM *mm) {

}

int SwapFifo::mapSwappable(VMM::MM *mm, uptr32_t addr, MMU::Page *page, uint32_t swapIn) {

}

int SwapFifo::setUnswappable(VMM::MM *mm, uptr32_t addr) {

}

int SwapFifo::swapOutVictim(VMM::MM *mm, MMU::Page **ptrPage, uint32_t inTick) {

}