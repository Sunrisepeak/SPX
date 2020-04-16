#include <SwapFifo.h>
#include <swapfs.hpp>
#include <linker.hpp>
#include <assert.h>
#include <kdebug.h>


int SwapFifo::init() {
    return 0;
}

int SwapFifo::tickEvent(VMM::MM *mm) {
    return 0;
}

int SwapFifo::mapSwappable(VMM::MM *mm, MMU::LinearAD lad, Linker<MMU::Page>::DLNode *pnode, uint32_t swapIn) {
    assert(pnode != nullptr);
    mm->smPriv.enqueue(pnode);
    return 0;
}

int SwapFifo::setUnswappable(VMM::MM *mm, MMU::LinearAD lad) {
    return 0;
}

int SwapFifo::swapOutVictim(VMM::MM *mm, Linker<MMU::Page>::DLNode **ptrPage, uint32_t inTick) {
    *ptrPage = mm->smPriv.dequeue();
    assert(*ptrPage != nullptr);
    return 0;
}