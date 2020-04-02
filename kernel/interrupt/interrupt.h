/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-26 14:26:09 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-02 17:04:55
 */

#ifndef _INTERRUPT_H
#define _INTERRUPT_H

#include <defs.h>
#include <x86.h>
#include <rtc.h>
#include <pic.h>
#include <memlayout.h>
#include <mmu.h>
#include <trap.h>

class Interrupt : public PIC, public RTC{
    
    public:
    
        Interrupt();

        void init();

        void initIDT();

        void enable();

        void disable();

    private:
        static MMU::GateDesc idt[256];
        static pseudodesc pdIdt;
};

#endif