#ifndef _VMM_H
#define _VMM_H

#include <defs.h>
#include <memlayout.h>
#include <mmu.h>
#include <phymm.h>
#include <linker.hpp>
#include <list.hpp>
#include <queue.hpp>

#define VM_READ                 0x00000001
#define VM_WRITE                0x00000002
#define VM_EXEC                 0x00000004
#define VM_STACK                0x0000000

class VMM {

    public:
               //manager
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
            MMU::PTEntry *pdt;                      // the PDT of these vma
            Queue<MMU::Page> smPriv;                // the private data for swap manager
            uint32_t mm_count;                      // the number ofprocess which shared the mm
            bool mm_lock;                           // mutex for using dup_mmap fun to duplicat the mm
        } __attribute__((packed));


        List<MM>::DLNode *checkMM { nullptr };                    // mark page fault info

        uint32_t pageFaultNum { 0 };

        /*  -----------Function---------------- */

        void init();

        List<VMA>::DLNode * findVma(List<MM>::DLNode *mm, uptr32_t addr);

        List<VMA>::DLNode * vmaCreate(uptr32_t vmStart, uptr32_t vmEnd, uint32_t vmFlags);
        
        // insert_vma_struct -insert vma in mm's list link
        void insertVma(List<MM>::DLNode *mm, List<VMA>::DLNode *vma);

        // mm_create -  alloc a List<MM>::DLNode-struct & initialize it.
        List<MM>::DLNode * mmCreate();

        void mmDestroy(List<MM>::DLNode *mm);

        void checkVmm();        // check_vmm - check correctness of vmm

        void checkVma();

        // check if vma1 overlaps vma2 ?
        void checkVamOverlap(List<VMA>::DLNode *prev, List<VMA>::DLNode *next);

        void checkPageFault();

        int doPageFault(List<MM>::DLNode *mm, uint32_t errorCode, uptr32_t addr);

        // ****************** manager space in law for user process 

        // map space to mm struct [vma]
        int mmMap(Linker<MM>::DLNode *mm, uptr32_t addr, uint32_t len, uint32_t vm_flags, Linker<VMA>::DLNode **vma_store);

        // cancel space of user in law
        int dupMmMap(Linker<MM>::DLNode *to, Linker<MM>::DLNode *from);

        // cancel PDT & PT map of physical space of mm corresponding  
        void exitMmMap(Linker<MM>::DLNode *mm);

        // ******************* kernel and user space copy

        bool userMemCheck(Linker<MM>::DLNode *mm, uptr32_t start, uint32_t len, bool write = false);

        bool copyToKernel(Linker<MM>::DLNode *mm, const void *src, void *dst, uint32_t len, bool writable = false);

        bool copyToUser(Linker<MM>::DLNode *mm, const void *src, void *dst, uint32_t len);

    private:

        List<MM> mmList;

        

};

#endif