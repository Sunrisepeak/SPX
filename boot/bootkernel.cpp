/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-19 21:21:26 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-03 10:48:09
 */

#include <defs.h>
#include <x86.h>
#include <elf.h>

#define SECTSIZE        512
#define ELFHDR          ((Elf_Ehdr *)0x10000)
#define VMEMORY         ((uint16_t *)0xB8000)

static void
readSector(uptr32_t vaddr, uint32_t sec) {
    sec = (sec & 0x0FFFFFFF) | 0xE0000000;      // set LBA28 Mode 0xE(28 ~ 31)
    outb(1, 0x1F2);                             // count = 1
    
    for (uint32_t i = 0; i < 4; i++) {          // LAB28 Mode and LAB to prot
        outb(((sec >> (i * 8)) & 0xFF), 0x1F3 + i);
    }

    outb(0x20, 0x1F7);                          // cmd 0x20 - read sectors
    
    // check SBY and DRQ bit
    while ((inb(0x1F7) & 0x88) != 0x08);        // wait disk data and not busy
    
    for (uint32_t i = 0; i < SECTSIZE / 4; i++) {    // read a sector
        inlToVAddr(0x1F0, vaddr);               //read 4byte from 0x1F0-Port to [vaddr]
        vaddr += 4;
    }
}

static void
readSeg(uptr32_t vaddr, uint32_t count, uint32_t offset) {
    uptr32_t end_va = vaddr + count;
    vaddr -= offset % SECTSIZE;
    uint32_t sec = (offset / SECTSIZE) + 1;
    for (; vaddr < end_va; vaddr += SECTSIZE, sec++) {
        readSector(vaddr, sec);
    }
}

extern "C" void     // extern "C" compiler by c-style, function name is not change.
bootKernel() {
    // read the 1st page off disk
    readSeg((uptr32_t)ELFHDR, SECTSIZE * 8, 0);

    // is this a valid ELF?
    if (ELFHDR->e_magic == ELF_MAGIC) {
        
        Elf_Phdr *ph = nullptr;
        ph = (Elf_Phdr *)((uptr32_t)ELFHDR + ELFHDR->e_phoff);  // get program head table first address
        
        for (uint32_t i = 0; i < ELFHDR->e_phnum; i++, ph++) {  // laod segment of program
            readSeg(ph->p_vaddr & 0xFFFFFF, ph->p_memsz, ph->p_offset);
        }
        // jmp kernel
        ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();
    }

    // Error Info: E of red
    // byte: KRGB IRGB front : back 
    *VMEMORY = ((uint16_t)0b00000100 << 8) + 'E';
    while(1);
}

