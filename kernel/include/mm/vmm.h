#ifndef _VMM_H
#define _VMM_H

#include <defs.h>
#include <memlayout.h>
#include <mmu.h>
#include <list.hpp>

#define VM_READ                 0x00000001
#define VM_WRITE                0x00000002
#define VM_EXEC                 0x00000004

class VMM {
    public:
        struct VMA;

        // the control struct for a set of vma using the same PDT
        struct MM {
            List<VMA>::DLNode *mmap_cache;          // current accessed vma, used for speed purpose
            MMU::PTEntry *pgdir;                    // the PDT of these vma
            uint32_t map_count;                     // the count of these vma
            void *sm_priv;                          // the private data for swap manager
        };

        // the virtual continuous memory area(vma)
        struct VMA {
            List<MM>::DLNode *vm_mm;                // the set of vma using the same PDT 
            uptr32_t vm_start;                      // start addr of vma    
            uptr32_t vm_end;                        // end addr of vma
            uint32_t vm_flags;                      // flags of vma
        };

        void vmmInit();

        List<VMA>::DLNode * findVma(List<MM>::DLNode *mm, uptr32_t addr);

        List<VMA>::DLNode * vmaCreate(uptr32_t vmStart, uptr32_t vmEnd, uint32_t vmFlags);
        
        void insertVma(List<MM>::DLNode *mm, List<VMA>::DLNode *vma);

        // mm_create -  alloc a List<MM>::DLNode-struct & initialize it.
        List<MM>::DLNode * mmCreate();

        void mmDestroy(List<MM>::DLNode *mm);

        uint32_t doPageFault(List<MM>::DLNode *mm, uint32_t errorCode, uptr32_t addr);
};

#endif