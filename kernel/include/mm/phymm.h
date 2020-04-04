/*
 * @Author: SPeak Shen 
 * @Date: 2020-04-02 16:22:37 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-04 11:23:15
 */

#ifndef _PHYMM_H
#define _PHYMM_H

#include <memlayout.h>
#include <PmmManager.h>
#include <mmu.h>
#include <flags.h>

/*      physical Memory management      */

class PhyMM : public MMU {

    public:
        struct E820Map {
            uint32_t numARDS;                           // number of memory block[ARDS]
            struct {                                    // Address Range Descriptor structure
                uint64_t addr;                          // first address of current block
                uint64_t size;                          // size of current block
                uint32_t type;                          // type ....
            } __attribute__((packed)) ARDS[E820MAX];
        };

        void init();

        void initPage();                            // pmm_init - initialize the physical memory management

        uptr32_t vToPhyAD(uptr32_t vAd);

        uptr32_t pToVirAD(uptr32_t pAd);

        uint32_t roundUp(uint32_t a, uint32_t n);   // round up  n for a; Example (7, 4) = 8

        void initPmmManager();
    
    private:
        uint32_t numPage;
        
        PmmManager *manager;

        Page *pages;
};

#endif

