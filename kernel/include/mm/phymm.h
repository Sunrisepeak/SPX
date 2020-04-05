/*
 * @Author: SPeak Shen 
 * @Date: 2020-04-02 16:22:37 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-04 11:23:15
 */

#ifndef _PHYMM_H
#define _PHYMM_H

#include <memlayout.h>
#include <mmu.h>
#include <PmmManager.h>
#include <FFMA.h>
#include <list.hpp>
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

        PhyMM();

        void init();

        void initPage();                            // pmm_init - initialize the physical memory management

        uptr32_t vToPhyAD(uptr32_t vAd);

        uptr32_t pToVirAD(uptr32_t pAd);

        List<Page>::DLNode * phyADtoPage(uptr32_t pAd);

        void initPmmManager();
    
    private:
        // virtual address of boot-time page directory
        PTEntry *bootPDT;

        uint32_t numPage;

        FFMA ff;
        
        PmmManager *manager;

        List<Page>::DLNode *nodeArray;      // contain page-attribute[data] in Node

};

#endif

