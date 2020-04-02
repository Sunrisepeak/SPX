#ifndef _MEMMANAGE_H
#define _MEMMANAGE_H

#include <defs.h>
#include <memlayout.h>

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

/*  type of segment descriptor   */

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

/*  MMU   */

class MMU {

    public:
        /* segment descriptors */
        struct SegDesc {
            uint16_t sd_lim_15_0 : 16;        // low bits of segment limit
            uint16_t sd_base_15_0 : 16;       // low bits of segment base address
            uint16_t sd_base_23_16 : 8;       // middle bits of segment base address
            uint16_t sd_type : 4;             // segment type (see STcb_ constants)
            uint16_t sd_s : 1;                // 0 = system, 1 = application
            uint16_t sd_dpl : 2;              // descriptor Privilege Level
            uint16_t sd_p : 1;                // present
            uint16_t sd_lim_19_16 : 4;        // high bits of segment limit
            uint16_t sd_avl : 1;              // unused (available for software use)
            uint16_t sd_l : 1;                // 64-bit code segment
            uint16_t sd_db : 1;               // 0 = 16-bit segment, 1 = 32-bit segment
            uint16_t sd_g : 1;                // granularity: limit scaled by 4K when set
            uint16_t sd_base_31_24 : 8;       // high bits of segment base address
        };

        /* Gate descriptors for interrupts and traps */
        struct GateDesc {
            uint16_t gd_off_15_0 : 16;        // low 16 bits of offset in segment
            uint16_t gd_ss : 16;              // segment selector
            uint16_t gd_args : 5;             // # args, 0 for interrupt/trap gates
            uint16_t gd_rsv1 : 3;             // reserved(should be zero I guess)
            uint16_t gd_type : 4;             // type(STS_{TG,IG32,TG32})
            uint16_t gd_s : 1;                // must be 0 (system)
            uint16_t gd_dpl : 2;              // descriptor(meaning new) privilege level
            uint16_t gd_p : 1;                // Present
            uint16_t gd_off_31_16 : 16;       // high bits of offset in segment
        };



        /* task state segment format (as described by the Pentium architecture book) */
        struct TCB {
            uint32_t tcb_link;        // old ts selector
            uptr32_t tcb_esp0;        // stack pointers and segment selectors
            uint16_t tcb_ss0;         // after an increase in privilege level
            uint16_t tcb_padding1;
            uptr32_t tcb_esp1;
            uint16_t tcb_ss1;
            uint16_t tcb_padding2;
            uptr32_t tcb_esp2;
            uint16_t tcb_ss2;
            uint16_t tcb_padding3;
            uptr32_t tcb_cr3;         // page directory base
            uptr32_t tcb_eip;         // saved state from last task switch
            uint32_t tcb_eflags;
            uint32_t tcb_eax;         // more saved state (registers)
            uint32_t tcb_ecx;
            uint32_t tcb_edx;
            uint32_t tcb_ebx;
            uptr32_t tcb_esp;
            uptr32_t tcb_ebp;
            uint32_t tcb_esi;
            uint32_t tcb_edi;
            uint16_t tcb_es;           // even more saved state (segment selectors)
            uint16_t tcb_padding4;
            uint16_t tcb_cs;
            uint16_t tcb_padding5;
            uint16_t tcb_ss;
            uint16_t tcb_padding6;
            uint16_t tcb_ds;
            uint16_t tcb_padding7;
            uint16_t tcb_fs;
            uint16_t tcb_padding8;
            uint16_t tcb_gs;
            uint16_t tcb_padding9;
            uint16_t tcb_ldt;
            uint16_t tcb_padding10;
            uint16_t tcb_t;            // trap on task switch
            uint16_t tcb_iomb;         // i/o map base address
        };

        MMU();

        void setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl);

        static void setGateDesc(GateDesc &gate, uint32_t istrap, uint32_t sel, uint32_t off, uint32_t dpl);

        static void setCallGate(GateDesc &gate, uint32_t ss, uint32_t off, uint32_t dpl);

        void setTCB();

        SegDesc getSegDesc();

        GateDesc getGateDesc();

        TCB getTCB();

    private:
        SegDesc segdesc;
        GateDesc gatedesc;
        TCB tcb;
    
};

#endif