#ifndef _MMU_H
#define _MMU_H

#include <flags.h>

#ifndef __ASSEMBLER__   /*      isn't ASM       */

/*  MMU   */
#include <defs.h>
#include <memlayout.h>

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
        }__attribute__((packed));

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
        }__attribute__((packed));

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
        }__attribute__((packed));

        struct Page {
            uint32_t ref;                           // page's reference counter
            uint8_t status;                         // 0
            uint32_t property;                      //
        }__attribute__((packed));
        
        // page table entry        
        struct PTEntry {
            uint32_t p_p : 1;                       // present bits
            uint32_t p_rw : 1;                      // R/W bits
            uint32_t p_us : 1;                      // user
            uint32_t p_pwt : 1;
            uint32_t p_pcd : 1;
            uint32_t p_a : 1;
            uint32_t p_d : 1; 
            uint32_t p_pat : 1;
            uint32_t p_g : 1;
            uint32_t p_avl : 3;
            uint32_t p_base : 20;                  // base address
        }__attribute__((packed));

        struct LinearAD {
            uint32_t OFF : 12;
            uint32_t PTI : 10;
            uint32_t PDI : 10;
        }__attribute__((packed));

        MMU();

        void setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl);

        static void setGateDesc(GateDesc &gate, uint32_t istrap, uint32_t sel, uint32_t off, uint32_t dpl);

        static void setCallGate(GateDesc &gate, uint32_t ss, uint32_t off, uint32_t dpl);

        void setTCB();

        static void setPageReserved(Page &p);   

        static void setPageProperty(Page &p);

        // covert to liner ad struct
        LinearAD LAD(uptr32_t vAd);     

        SegDesc getSegDesc();

        GateDesc getGateDesc();

        TCB getTCB();

    protected:

        static uint32_t bootCR3;

    private:

        SegDesc segdesc;
        GateDesc gatedesc;
        TCB tcb;
    
};

#endif /* !__ASSEMBLER__ */

#endif /* !_MMU_H */