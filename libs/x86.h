/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-20 09:20:07 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-10 10:30:17
 */

#ifndef __LIBS_X86_H
#define __LIBS_X86_H

#include <defs.h>

/* -----------------> I/O <------------------- */

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
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
        "cld;"
        "repne; insl;"
        : "=D" (addr), "=c" (cnt)
        : "d" (port), "0" (addr), "1" (cnt)
        : "memory", "cc");
}

static inline void
outb(uint8_t data, uint16_t port) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
        "cld;"
        "repne; outsl;"
        : "=S" (addr), "=c" (cnt)
        : "d" (port), "0" (addr), "1" (cnt)
        : "memory", "cc");
}

/* -----------------> Interrupt <------------------- */

static inline void
sti() {
    asm volatile ("sti");
}

static inline void
cli() {
    asm volatile ("cli");
}

/* -----------------> Set Register <------------------- */

static inline void
lidt(void *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
}

/* *
 * lgdt - load the global descriptor table register
 * */
static inline void
lgdt(void *pd) {
    asm volatile ("lgdt (%0)" :: "r" (pd));
}

// load TSS to task register
static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
}

// set segment register and flush cs
static inline void
setSegR(uint32_t cs, uint32_t ds, uint32_t ss, uint32_t es, uint32_t fs, uint32_t gs) {
    asm volatile ("movw %%ax, %%ds" :: "a" (ds));
    asm volatile ("movw %%ax, %%ss" :: "a" (ss));
    asm volatile ("movw %%ax, %%es" :: "a" (es));
    asm volatile ("movw %%ax, %%fs" :: "a" (fs));
    asm volatile ("movw %%ax, %%gs" :: "a" (gs));
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (cs));
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

static inline uint32_t
readEflags() {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
    return eflags;
}


static inline void
jmpFlush() {
    asm volatile (
        "   leal next, %eax;"
        "   jmp *%eax;"
        "next:  "
    );
}

static inline void
hlt() {
    asm volatile ("hlt");
}

#endif

