#ifndef _FFMA_H
#define _FFMA_H

#include <mmu.h>
#include <PmmManager.h>
#include <list.hpp>

// First-Fit Memory Allocation (FFMA) Algorithm

class FFMA : public PmmManager {
    public:
        void init();
    
    private:
        List<MMU::Page> freeArea;
};

#endif