#ifndef _FFMA_H
#define _FFMA_H

#include <mmu.h>
#include <PmmManager.h>
#include <list.hpp>

// First-Fit Memory Allocation (FFMA) Algorithm

class FFMA : public PmmManager{
    public:
        void init();                      // initialize internal description&management data structure                   

        void initMemMap(List<MMU::Page>::DLNode *pArr, uint32_t num);                // (free block list, number of free block) of XXX_pmm_manager 
                                                                        // setup description&management data structcure according to
                                                                        // the initial free physical memory space 
        List<MMU::Page>::DLNode * allocPages(uint32_t n = 1);      // allocate >=n pages, depend on the allocation algorithm 

        void freePages(void *base, uint32_t n);       // free >=n pages with "base" addr of Page descriptor structures(memlayout.h)

        uint32_t numFreePages();          // return the number of free pages   
    
    private:
    
        List<MMU::Page> freeArea;                // list of all of Page

        uint32_t nfp { 0 };                      // number of free-page

        //List<MMU::Page>::DLNode pageNode;
};

#endif