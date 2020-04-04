/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-29 12:56:58 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-04 08:21:52
 */

#ifndef _GLOBLE_H
#define _GLOBLE_H

#include <defs.h>
#include <console.h>
#include <pic.h>
#include <interrupt.h>
#include <mmu.h>

/*
 *  init for global static variable
 *
 */
// Console
Console::Char Console::charEctype = { 0 };

// PIC   8259A
uint16_t PIC::irqMask  = 0xFFFF;
bool PIC::didInit  = false;

// MMU
MMU::GateDesc Interrupt::idt[256] = {{0}};
uint32_t MMU::bootCR3 = 0;

pseudodesc Interrupt::pdIdt = {
    sizeof(Interrupt::idt) - 1, (uptr32_t)(Interrupt::idt)
};

#endif