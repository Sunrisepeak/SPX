/*
 * @Author: SPeak Shen 
 * @Date: 2020-04-02 16:22:37 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-14 23:07:21
 */

#ifndef _PHYMM_H
#define _PHYMM_H

#include <memlayout.h>
#include <mmu.h>
#include <PmmManager.h>
#include <FFMA.h>
#include <list.hpp>
#include <flags.h>

/* fork flags used in do_fork*/
#define CLONE_VM            0x00000100  // set if VM shared between processes
#define CLONE_THREAD        0x00000200  // thread group

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

        int mapPage(PTEntry *pdt, List<Page>::DLNode *pnode, LinearAD lad, uint32_t perm);

        uptr32_t vToPhyAD(uptr32_t vAd);

        uptr32_t pToVirAD(uptr32_t pAd);

        List<Page>::DLNode * phyAdToPgNode(uptr32_t pAd);

        List<Page>::DLNode * vAdToPgNode(uptr32_t vAd);

        uptr32_t pnodeToKernelLAD(List<Page>::DLNode *node);

        PTEntry * pdeToPTable(const PTEntry &pte);

        List<Page>::DLNode * pteToPgNode(const PTEntry &pte);

        List<Page>::DLNode * pdeToPgNode(const PTEntry &pde);

        PTEntry * getPTE(PTEntry *pdt, const LinearAD &lad, bool create = true);

        void removePTE(PTEntry *pdt, const LinearAD &lad, PTEntry *pte);

        PTEntry * getPDT();

        uptr32_t getCR3();

        uptr32_t getStack();

        void removePage(PTEntry *pte, LinearAD la);                     // remove page which is la point

        List<Page>::DLNode * allocPages(uint32_t n = 1);

        List<Page>::DLNode * allocPageAndMap(PTEntry *pdt, LinearAD lad, uint32_t perm);

        void freePages(List<Page>::DLNode *base, uint32_t n = 1);

        void * kmalloc(uint32_t size);

        void kfree(void *ptr, uint32_t size);

        uint32_t numFreePages();

        void tlbInvalidData(PTEntry *pdt, LinearAD lad);

        void loadEsp0(uptr32_t esp0);

        /*  recycle resource for process    */

        // cancel table map for a range of AD
        void unmapRange(PTEntry *pdt, uptr32_t start, uptr32_t end);

        // cancel page dir table map
        void exitRange(PTEntry *pdt, uptr32_t start, uptr32_t end);

        // copy "old"P/T-memory to a new process/thread [create son Process/Thread]
        int copyRange(PTEntry *to, PTEntry *from, uptr32_t start, uptr32_t end, bool share = false);
    
    private:

        static SegDesc GDT[];
        static PseudoDesc gdtPD;

        static TSS tss;

        // stack data
        uptr32_t stack;
        uptr32_t stackTop;

        // virtual address of boot-time page directory
        PTEntry *bootPDT;

        uint32_t numPage;

        PmmManager *manager;

        List<Page>::DLNode *pNodeArr;      // contain page-attribute[data] in Node

};

#endif

