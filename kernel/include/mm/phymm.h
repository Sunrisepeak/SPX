/*
 * @Author: SPeak Shen 
 * @Date: 2020-04-02 16:22:37 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-09 23:46:32
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

        void initGDTAndTSS();

        void initPmmManager();

        void mapSegment(uptr32_t lad, uptr32_t pad, uint32_t size, uint32_t perm);

        uptr32_t vToPhyAD(uptr32_t vAd);

        uptr32_t pToVirAD(uptr32_t pAd);

        List<Page>::DLNode * phyADtoPage(uptr32_t pAd);

        uptr32_t pnodeToLAD(List<Page>::DLNode *node);

        PTEntry * pdeToPTable(const PTEntry &pte);

        template <typename T>
        void setPermission(T &t, uint32_t perm);                        // by | :    1110 | 1 = 1111

        PTEntry * getPTE(const LinearAD &lad, bool create = true);

        void * kmalloc(uint32_t size);

        void kfree(void *ptr, uint32_t size);
    
    private:

        static SegDesc GDT[];
        static PseudoDesc gdtPD;

        static TSS tss;

        // stack data
        uint8_t *stack;
        uint8_t *stackTop;

        // virtual address of boot-time page directory
        PTEntry *bootPDT;

        uint32_t numPage;

        FFMA ff;
        
        PmmManager *manager;

        List<Page>::DLNode *pNodeArr;      // contain page-attribute[data] in Node

};

#endif

