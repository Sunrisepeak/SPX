#ifndef __LIBS_ELF_H
#define __LIBS_ELF_H

#include <defs.h>

#define EI_NIDENT 12
#define ELF_MAGIC    0x464C457FU        // 7FELF

/* file header */
typedef struct{
    uint32_t e_magic;                   // elf sign = ELF_MAGIC
    uint8_t e_ident[EI_NIDENT];
    uint16_t e_type;                    // 
    uint16_t e_machine;
    uint32_t e_version;
    uint32_t e_entry;                   // entry point of program
    uint32_t e_phoff;                   // offset program head table in file
    uint32_t e_shoff;
    uint32_t e_flags;
    uint16_t e_ehsize;
    uint16_t e_phentsize;
    uint16_t e_phnum;                   // number of itmes in program head table
    uint16_t e_shentsize;
    uint16_t e_shnum;
    uint16_t e_shstrndx;
} Elf_Ehdr;

/* program section header */
typedef struct {
    uint32_t p_type;
    uint32_t p_offset;                  // offset of segment in file
    uint32_t p_vaddr;                   // virtual address of segment in Memory
    uint32_t p_paddr;
    uint32_t p_filesz;
    uint32_t p_memsz;                   // length of segment
    uint32_t p_flags;
    uint32_t p_align;
} Elf_Phdr;

#endif

