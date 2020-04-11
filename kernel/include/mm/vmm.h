#ifndef _VMM_H
#define _VMM_H

#include <defs.h>
#include <memlayout.h>
#include <mmu.h>
#include <phymm.h>
#include <list.hpp>

#define VM_READ                 0x00000001
#define VM_WRITE                0x00000002
#define VM_EXEC                 0x00000004

class VMM : public PhyMM {

    public:       //manager
        /*      MM --------> VMA        */
        struct MM;
        
        // the virtual continuous memory area(vma)
        struct VMA {
            List<MM>::DLNode *vm_mm;                // the set of vma using the same PDT 
            uptr32_t vm_start;                      // start addr of vma    
            uptr32_t vm_end;                        // end addr of vma
            uint32_t vm_flags;                      // flags of vma
        } __attribute__((packed));

        // the control struct for a set of vma using the same PDT
        struct MM {
            List<VMA> vmaList;                      // MM manager of vam-list
            List<VMA>::DLNode *mmap_cache;          // current accessed vma, used for speed purpose
            MMU::PTEntry *pgdir;                    // the PDT of these vma
            void *sm_priv;                          // the private data for swap manager
        } __attribute__((packed));

        void vmmInit();

        List<VMA>::DLNode * findVma(List<MM>::DLNode *mm, uptr32_t addr);

        List<VMA>::DLNode * vmaCreate(uptr32_t vmStart, uptr32_t vmEnd, uint32_t vmFlags);
        
        // insert_vma_struct -insert vma in mm's list link
        void insertVma(List<MM>::DLNode *mm, List<VMA>::DLNode *vma);

        // mm_create -  alloc a List<MM>::DLNode-struct & initialize it.
        List<MM>::DLNode * mmCreate();

        void mmDestroy(List<MM>::DLNode *mm);

        uint32_t doPageFault(List<MM>::DLNode *mm, uint32_t errorCode, uptr32_t addr);

        void checkVmm();        // check_vmm - check correctness of vmm

        void checkVma();

        // check if vma1 overlaps vma2 ?
        void checkVamOverlap(List<VMA>::DLNode *prev, List<VMA>::DLNode *next);

    private:

        List<MM> mmList;

};

#endif