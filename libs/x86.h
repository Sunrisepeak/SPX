/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-20 09:20:07 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-21 14:37:39
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
        "inb %1, %%al"
        "movb %%al, %0"
        : "=m" (vaddr)
        : "d" (port)
    );
}

static inline uint32_t
inlToVAddr(uint16_t port, uptr32_t vaddr) {
    asm volatile (
        "inl %1, %%eax;"
        "movl %%eax, %0;"
        : "=m" (vaddr)
        : "d" (port)
    );
    return *((uint32_t *)vaddr);
}

static inline void
outb(uint8_t data, uint16_t port) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
}

#endif

