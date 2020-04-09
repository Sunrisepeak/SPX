#ifndef _FLAGS_H
#define _FLAGS_H


/*  -------------------type of segment descriptor--------------------   */

// data segment
#define STA_R           0x0
#define STA_RW          0x2
#define STA_R_DOWN      0x4
#define STA_RW_DOWN     0x6

// code segment
#define STA_E           0x8
#define STA_E_R         0xA
#define STA_E_FOLLOW    0xC
#define STA_ER_FOLLOW   0xE

/* System segment type bits */
#define STS_T16A        0x1            // Available 16-bit TSS
#define STS_LDT         0x2            // Local Descriptor Table
#define STS_T16B        0x3            // Busy 16-bit TSS
#define STS_CG16        0x4            // 16-bit Call Gate
#define STS_TG          0x5            // Task Gate / Coum Transmitions
#define STS_IG16        0x6            // 16-bit Interrupt Gate
#define STS_TG16        0x7            // 16-bit Trap Gate
#define STS_T32A        0x9            // Available 32-bit TSS
#define STS_T32B        0xB            // Busy 32-bit TSS
#define STS_CG32        0xC            // 32-bit Call Gate
#define STS_IG32        0xE            // 32-bit Interrupt Gate
#define STS_TG32        0xF            // 32-bit Trap Gate


/* --------------page directory and page table constants------------------------ */


#define NPDEENTRY       1024                    // page directory entries per page directory
#define NPTEENTRY       1024                    // page table entries per page table

#define PGSIZE          4096                    // bytes mapped by a page
#define PGSHIFT         12                      // log2(PGSIZE)
#define PTSIZE          (PGSIZE * NPTEENTRY)    // bytes mapped by a page directory entry
#define PTSHIFT         22                      // log2(PTSIZE)

#define PTXSHIFT        12                      // offset of PTX in a linear address
#define PDXSHIFT        22                      // offset of PDX in a linear address

/* page table/directory entry flags */
#define PTE_P           0x001                   // Present
#define PTE_W           0x002                   // Writeable
#define PTE_U           0x004                   // User
#define PTE_PWT         0x008                   // Write-Through
#define PTE_PCD         0x010                   // Cache-Disable
#define PTE_A           0x020                   // Accessed
#define PTE_D           0x040                   // Dirty
#define PTE_PS          0x080                   // Page Size
#define PTE_MBZ         0x180                   // Bits must be zero
#define PTE_AVAIL       0xE00                   // Available for software use
                                                // The PTE_AVAIL bits aren't used by the kernel or interpreted by the
                                                // hardware, so user processes are allowed to set them arbitrarily.

#define PTE_USER        (PTE_U | PTE_W | PTE_P)



/*   ----------------some constants for bios interrupt 15h AX = 0xE820---------------   */

#define E820_BUFF           0x8000
#define E820MAX             20      // number of entries in E820MAP
#define E820_ARM            1       // address range memory
#define E820_ARR            2       // address range reserved


/*   --------------------------IDE[hardDisk] flags--------------------------   */

#define ISA_DATA                0x00
#define ISA_ERROR               0x01
#define ISA_PRECOMP             0x01
#define ISA_CTRL                0x02
#define ISA_SECCNT              0x02
#define ISA_SECTOR              0x03
#define ISA_CYL_LO              0x04
#define ISA_CYL_HI              0x05
#define ISA_SDH                 0x06
#define ISA_COMMAND             0x07
#define ISA_STATUS              0x07

#define IDE_BSY                 0x80
#define IDE_DRDY                0x40
#define IDE_DF                  0x20
#define IDE_DRQ                 0x08
#define IDE_ERR                 0x01

#define IDE_CMD_READ            0x20
#define IDE_CMD_WRITE           0x30
#define IDE_CMD_IDENTIFY        0xEC

#define IDE_IDENT_SECTORS       20
#define IDE_IDENT_MODEL         54
#define IDE_IDENT_CAPABILITIES  98
#define IDE_IDENT_CMDSETS       164
#define IDE_IDENT_MAX_LBA       120
#define IDE_IDENT_MAX_LBA_EXT   200

#define IO_BASE0                0x1F0
#define IO_BASE1                0x170
#define IO_CTRL0                0x3F4
#define IO_CTRL1                0x374

#define MAX_IDE                 4
#define MAX_NSECS               128
#define MAX_DISK_NSECS          0x10000000U



/*  -------------------Register Flags------------------------   */


/* Eflags register */
#define FL_CF            0x00000001    // Carry Flag
#define FL_PF            0x00000004    // Parity Flag
#define FL_AF            0x00000010    // Auxiliary carry Flag
#define FL_ZF            0x00000040    // Zero Flag
#define FL_SF            0x00000080    // Sign Flag
#define FL_TF            0x00000100    // Trap Flag
#define FL_IF            0x00000200    // Interrupt Flag
#define FL_DF            0x00000400    // Direction Flag
#define FL_OF            0x00000800    // Overflow Flag
#define FL_IOPL_MASK     0x00003000    // I/O Privilege Level bitmask
#define FL_IOPL_0        0x00000000    // IOPL == 0
#define FL_IOPL_1        0x00001000    // IOPL == 1
#define FL_IOPL_2        0x00002000    // IOPL == 2
#define FL_IOPL_3        0x00003000    // IOPL == 3
#define FL_NT            0x00004000    // Nested Task
#define FL_RF            0x00010000    // Resume Flag
#define FL_VM            0x00020000    // Virtual 8086 mode
#define FL_AC            0x00040000    // Alignment Check
#define FL_VIF           0x00080000    // Virtual Interrupt Flag
#define FL_VIP           0x00100000    // Virtual Interrupt Pending
#define FL_ID            0x00200000    // ID flag

/* Control Register flags */
#define CR0_PE          0x00000001              // Protection Enable
#define CR0_MP          0x00000002              // Monitor coProcessor
#define CR0_EM          0x00000004              // Emulation
#define CR0_TS          0x00000008              // Task Switched
#define CR0_ET          0x00000010              // Extension Type
#define CR0_NE          0x00000020              // Numeric Errror
#define CR0_WP          0x00010000              // Write Protect
#define CR0_AM          0x00040000              // Alignment Mask
#define CR0_NW          0x20000000              // Not Writethrough
#define CR0_CD          0x40000000              // Cache Disable
#define CR0_PG          0x80000000              // Paging



#endif