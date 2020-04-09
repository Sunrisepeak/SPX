/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-26 13:00:01 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-09 19:32:22
 */

#ifndef _PIC_H
#define _PIC_H

#include <defs.h>
#include <x86.h>

/*  programmable interrupt controller   8259A */

// I/O Addresses of the two programmable interrupt controllers
#define IO1_8259PIC1             0x20    // Master (IRQs 0-7) | ICW1
#define IO2_8259PIC1             0x21    // ICW2 ~ ICW4

#define IO1_8259PIC2             0xA0    // Slave  (IRQs 8-15) | ICW1
#define IO2_8259PIC2             0xA1    // ICW2 ~ ICW4


// initialize command words
#define LEVEL_TRIGGERED         0x14    // level triggered
#define NO_CASCADE              0x12    // single chip
#define ICW1_ICW4               0x11    // need ICW4

#define EOI_CMD                 0x20    // interrupt end cmd

class PIC {
    public:
    
        void initPIC();

        static void enableIRQ(uint32_t irq);

        static void sendEOI();

    private:

        static uint16_t irqMask;

        static bool didInit; 
};

#endif