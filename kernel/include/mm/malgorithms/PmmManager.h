#ifndef _PMMMANAGER_H
#define _PMMMANAGER_H

#include <defs.h>
#include <string.h>

class PmmManager {

    protected:
        String name = "SPX-MemManager";

        virtual void init() = 0;                      // initialize internal description&management data structure                   

        virtual void initMemMap() = 0;                // (free block list, number of free block) of XXX_pmm_manager 
                                                      // setup description&management data structcure according to
                                                      // the initial free physical memory space 
        virtual void allocPages(uint32_t n) = 0;      // allocate >=n pages, depend on the allocation algorithm 

        virtual void freePages(uint32_t n) = 0;       // free >=n pages with "base" addr of Page descriptor structures(memlayout.h)

        virtual uint32_t numFreePases() = 0;          // return the number of free pages    
};

#endif