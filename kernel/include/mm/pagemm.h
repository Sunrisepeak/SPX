/*
 * @Author: SPeak Shen 
 * @Date: 2020-04-02 17:12:41 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-04 08:24:56
 */

#ifndef _PAGEMM_H
#define _PAGEMM_H

#include <defs.h>
#include <x86.h>
#include <memlayout.h>
#include <mmu.h>

/* page directory and page table constants */
#define NPDEENTRY       1024                    // page directory entries per page directory
#define NPTEENTRY       1024                    // page table entries per page table

#define PGSIZE          4096                    // bytes mapped by a page
#define PGSHIFT         12                      // log2(PGSIZE)
#define PTSIZE          (PGSIZE * NPTEENTRY)    // bytes mapped by a page directory entry
#define PTSHIFT         22                      // log2(PTSIZE)

#define PTXSHIFT        12                      // offset of PTX in a linear address
#define PDXSHIFT        22                      // offset of PDX in a linear address


class PageMM {

    public:

        struct LinearAD {
            uint32_t OFF : 12;
            uint32_t PTI : 10;
            uint32_t PDI : 10;
        };
        
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
        };

        static uint32_t bootCR3;

        uint32_t getPDI();                      // Page directory index
        
        uint32_t getPTI();                      // Page table index

        uint32_t getPNN();                      // Page number field of address

        uint32_t getPOFF();                     // Page number field of address

        void setLAD(uint32_t pdi, uint32_t pti, uint32_t poff);

    private:
    
        LinearAD LAD;

        PTEntry pte { 0 };

        //static PTEntry pDirTable[NPDEENTRY];

        //static PTEntry pTable[NPTEENTRY];

};


#endif
