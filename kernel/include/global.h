/*
 * @Author: SPeak Shen 
 * @Date: 2020-04-10 09:36:28 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-10 21:09:17
 */

#ifndef _GLOBAL_HPP
#define _GLOBAL_HPP

#include <defs.h>
#include <flags.h>
#include <vdieomemory.h>
#include <console.h>
#include <pic.h>
#include <phymm.h>
#include <interrupt.h>
#include <mmu.h>
#include <ide.h>
#include <vmm.h>
#include <ostream.h>

namespace kernel {
    
    extern Console console;

    extern PhyMM pmm;

    extern Interrupt interrupt;

    extern IDE ide;

    extern VMM vmm;
};

void * operator new(uint32_t size);
void * operator new[](uint32_t size);

// placement new
void * operator new(uint32_t size, void *ptr);
void * operator new[](uint32_t size, void *ptr);

void operator delete(void *ptr);
void operator delete[](void *ptr);

#endif