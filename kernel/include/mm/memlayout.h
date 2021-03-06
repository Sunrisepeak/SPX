#ifndef _MEMLAYOUT_H__
#define _MEMLAYOUT_H__

/* This file contains the definitions for memory management in our OS. */

/* global segment number */
#define SEG_KTEXT    1
#define SEG_KDATA    2
#define SEG_UTEXT    3
#define SEG_UDATA    4
#define SEG_TSS      5

/* global descriptor numbers */
#define GD_KTEXT    ((SEG_KTEXT) << 3)        // kernel text
#define GD_KDATA    ((SEG_KDATA) << 3)        // kernel data
#define GD_UTEXT    ((SEG_UTEXT) << 3)        // user text
#define GD_UDATA    ((SEG_UDATA) << 3)        // user data
#define GD_TSS        ((SEG_TSS) << 3)        // task segment selector

#define DPL_KERNEL    (0)
#define DPL_USER      (3)

#define KERNEL_CS    ((GD_KTEXT) | DPL_KERNEL)
#define KERNEL_DS    ((GD_KDATA) | DPL_KERNEL)
#define USER_CS      ((GD_UTEXT) | DPL_USER)
#define USER_DS      ((GD_UDATA) | DPL_USER)

/* All physical memory mapped at this address */
#define KERNEL_BASE                 0xC0000000
#define KERNEL_MEM_SIZE             0x38000000                  // the maximum amount of physical memory
#define KERNEL_TOP                  (KERNEL_BASE + KERNEL_MEM_SIZE)

/* *
 * Virtual page table. Entry PDX[VPT] in the PD (Page Directory) contains
 * a pointer to the page directory itself, thereby turning the PD into a page
 * table, which maps all the PTEs (Page Table Entry) containing the page mappings
 * for the entire virtual address space into that 4 Meg region starting at VPT.
 * */
#define VPT                 0xFAC00000

#define KSTACKPAGE          2                           // # of pages in kernel stack
#define KSTACKSIZE          (KSTACKPAGE * PGSIZE)       // sizeof kernel stack

#define USER_TOP             0xB0000000
#define USTACKTOP           USER_TOP
#define USTACKPAGE          256                         // # of pages in user stack
#define USTACKSIZE          (USTACKPAGE * PGSIZE)       // sizeof user stack

#define USER_BASE           0x00200000
#define UTEXT               0x00800000                  // where user programs generally begin
#define USTAB               USER_BASE                    // the location of the user STABS data structure

#define USER_ACCESS(start, end)                     \
(USER_BASE <= (start) && (start) < (end) && (end) <= USER_TOP)

#define KERN_ACCESS(start, end)                     \
(KERNEL_BASE <= (start) && (start) < (end) && (end) <= KERNEL_TOP)

#endif /* !_MEMLAYOUT_H__ */
