/*
 * @Author: SPeak Shen 
 * @Date: 2020-04-10 09:36:28 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-28 18:23:30
 */

#ifndef _GLOBAL_H
#define _GLOBAL_H

#include <defs.h>
#include <flags.h>
#include <vdieomemory.h>
#include <console.h>
#include <pic.h>
#include <phymm.h>
#include <interrupt.h>
#include <mmu.h>
#include <FFMA.h>
#include <ide.h>
#include <vmm.h>
#include <swap.h>
#include <SwapFifo.h>
#include <pm.h>
#include <schedule.h>
#include <syscall.h>
#include <ostream.h>

namespace kernel {
    
    extern Console console;

    extern PhyMM pmm;

    extern Interrupt interrupt;

    extern IDE ide;

    extern VMM vmm;

    extern Swap swap;

    extern PM pm;

    extern SysCall scall;

    extern bool DEBUG_FLAGS;

    namespace algorithms {

        extern SwapFifo swapFifo;

        extern FFMA ffma;

        extern Schedule sched;
    
    };

    namespace stdio {
        extern OStream out;
    };
};

// reuse struct
using SwapEntry = MMU::PTEntry;

void * operator new(uint32_t size);
void * operator new[](uint32_t size);

// placement new
void * operator new(uint32_t size, void *ptr);
void * operator new[](uint32_t size, void *ptr);

void operator delete(void *ptr);
void operator delete[](void *ptr);

#endif