/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-20 09:20:07 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-03 13:52:56
 */

#ifndef __LIBS_X86_H
#define __LIBS_X86_H

#include <defs.h>

static inline uint8_t
inb(uint16_t port) {
     uint8_t data;
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
     return data; 
}

static inline void
inbToVAddr(uint16_t port, uptr32_t vaddr) {
    asm volatile (
        "pushl %%eax;"
        "inb %1, %%al"
        "movb %%al, (%0)"
        "popl %%eax;"
        : 
        : "d"(port),"r"(vaddr)
    );
}

static inline void
inlToVAddr(uint16_t port, uptr32_t vaddr) {
    asm volatile (
        "pushl %%eax;"
        "inl %0, %%eax;"
        "movl %%eax, (%1);"
        "popl %%eax;"
        : 
        : "d"(port),"r"(vaddr)
    );
}

static inline void
outb(uint8_t data, uint16_t port) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
}

static inline void
sti() {
    asm volatile ("sti");
}

static inline void
cli() {
    asm volatile ("cli");
}

/* Pseudo-descriptors used for LGDT, LLDT(not used) and LIDT instructions. */
struct pseudodesc {
    uint16_t pd_lim;        // Limit
    uint32_t pd_base;       // Base address
}__attribute__ ((packed));  // rule size

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline uint32_t
getCR0() {
    uint32_t cr0;
    asm volatile ("movl %%cr0, %0" : "=r" (cr0));
    return cr0;
}

static inline void
setCR0(uint32_t v) {
    asm volatile ("movl %0, %%cr0" :: "a" (v));
}

static inline void
setCR3(uptr32_t ad) {
    asm volatile ("movl %0, %%cr3" :: "a" (ad));
}


static inline void
jmpFlush() {
    asm volatile (
        "   leal next, %eax;"
        "   jmp *%eax;"
        "next:  "
    );
}

#endif

