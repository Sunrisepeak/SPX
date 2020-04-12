#ifndef _MMU_H
#define _MMU_H

#include <flags.h>

#ifndef __ASSEMBLER__   /*      isn't ASM       */

/*  MMU   */
#include <defs.h>
#include <memlayout.h>
#include <ostream.h>

#define SEG_NULL        {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

class MMU {

    public:

        /* Pseudo-descriptors used for LGDT, LLDT(not used) and LIDT instructions. */
        struct PseudoDesc {
            uint16_t pd_lim;        // Limit
            uint32_t pd_base;       // Base address
        }__attribute__ ((packed));  // rule size

        /* segment descriptors */
        struct SegDesc {
            uint16_t sd_lim_15_0 : 16;        // low bits of segment limit
            uint16_t sd_base_15_0 : 16;       // low bits of segment base address
            uint16_t sd_base_23_16 : 8;       // middle bits of segment base address
            uint16_t sd_type : 4;             // segment type (see Sts_ constants)
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
        struct TSS {
            uint32_t ts_link;        // old ts selector
            uptr32_t ts_esp0;        // stack pointers and segment selectors
            uint16_t ts_ss0;         // after an increase in privilege level
            uint16_t ts_padding1;
            uptr32_t ts_esp1;
            uint16_t ts_ss1;
            uint16_t ts_padding2;
            uptr32_t ts_esp2;
            uint16_t ts_ss2;
            uint16_t ts_padding3;
            uptr32_t ts_cr3;         // page directory base
            uptr32_t ts_eip;         // saved state from last task switch
            uint32_t ts_eflags;
            uint32_t ts_eax;         // more saved state (registers)
            uint32_t ts_ecx;
            uint32_t ts_edx;
            uint32_t ts_ebx;
            uptr32_t ts_esp;
            uptr32_t ts_ebp;
            uint32_t ts_esi;
            uint32_t ts_edi;
            uint16_t ts_es;           // even more saved state (segment selectors)
            uint16_t ts_padding4;
            uint16_t ts_cs;
            uint16_t ts_padding5;
            uint16_t ts_ss;
            uint16_t ts_padding6;
            uint16_t ts_ds;
            uint16_t ts_padding7;
            uint16_t ts_fs;
            uint16_t ts_padding8;
            uint16_t ts_gs;
            uint16_t ts_padding9;
            uint16_t ts_ldt;
            uint16_t ts_padding10;
            uint16_t ts_t;            // trap on task switch
            uint16_t ts_iomb;         // i/o map base address
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
            uint32_t p_ppn : 20;                    // physical page[frame] No

            bool isEmpty() {
                return (*(uint32_t *)(this)) == 0;
            }

            void setPermission(uint32_t perm) {
                auto &temp = (*(uint32_t *)(this));
                temp |= perm;
            }

        }__attribute__((packed));

        struct LinearAD {
            uint32_t OFF : 12;
            uint32_t PTI : 10;
            uint32_t PDI : 10;

            uptr32_t Integer() {
                return *(uptr32_t *)(this);
            }

            // covert to liner ad struct
            static LinearAD LAD(uptr32_t vAd) {
                LinearAD lad;
                lad.OFF = vAd & 0xFFF;
                lad.PTI = (vAd >> PGSHIFT) & 0x3FF;
                lad.PDI = (vAd >> PTSHIFT) & 0x3FF;
                return lad;
            }

        }__attribute__((packed));

        MMU();

        static SegDesc setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl);

        static SegDesc setTssDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl);

        static void setGateDesc(GateDesc &gate, uint32_t istrap, uint32_t sel, uint32_t off, uint32_t dpl);

        static void setCallGate(GateDesc &gate, uint32_t ss, uint32_t off, uint32_t dpl);

        static void setTCB();

        static void setPageReserved(Page &p);   

        static void setPageProperty(Page &p);

        static void clearPageProperty(Page &p);

        // covert to liner ad struct
        static LinearAD LAD(uptr32_t vAd);     

        SegDesc getSegDesc();

        GateDesc getGateDesc();

        //TCB getTCB();

    protected:
        static uint32_t bootCR3;

    private:
        SegDesc segdesc;
        GateDesc gatedesc;
    
};

#endif /* !__ASSEMBLER__ */

#endif /* !_MMU_H */