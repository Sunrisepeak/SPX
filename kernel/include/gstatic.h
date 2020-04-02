/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-29 12:56:58 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-02 17:05:01
 */

#ifndef _GLOBLE_H
#define _GLOBLE_H

#include <defs.h>
#include <pic.h>
#include <interrupt.h>

/*
 *  init for global static variable
 *
 */

// PIC   8259A
uint16_t PIC::irqMask  = 0xFFFF;
bool PIC::didInit  = false;


// MMU
MMU::GateDesc Interrupt::idt[256] = {{0}};
pseudodesc Interrupt::pdIdt = {
    sizeof(Interrupt::idt) - 1, (uptr32_t)(Interrupt::idt)
};

#endif