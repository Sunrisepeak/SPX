#include <pic.h>

void PIC::initPIC() {
    // mask all interrupts
    outb(0xFF, IO2_8259PIC1);
    outb(0xFF, IO2_8259PIC2);

    // master
    outb(ICW1_ICW4, IO1_8259PIC1);                  // ICW1: edge-tri / cascade
    outb(0x20, IO2_8259PIC1);                       // ICW2: set first vectors of interrupt
    outb(0x04, IO2_8259PIC1);                       // ICW3: second chip is link to IR2 of first chip
    outb(0x01, IO2_8259PIC1);                       // ICW4; normal EOI

    // slave
    outb(ICW1_ICW4, IO1_8259PIC2);                  // ICW1: edge-tri / cascade
    outb(0x70, IO2_8259PIC2);                       // ICW2: set first vectors of interrupt
    outb(0x04, IO2_8259PIC2);                       // ICW3: second chip is link to IR2 of first chip
    outb(0x01, IO2_8259PIC2);                       // ICW4; normal EOI

    didInit = true;                                 // 
}

void PIC::enableIRQ(uint32_t irq) {                 // enable irq
    irqMask &= ~(1 << irq);
    if (didInit) {
        outb(irqMask & 0xFF, IO2_8259PIC1);         // master chip
        outb((irqMask >> 8) & 0xFF, IO2_8259PIC2);  // slave chip
    }
}

void PIC::sendEOI() {
    outb(EOI_CMD, IO1_8259PIC2);                    // send EOI cmd for slave
    outb(EOI_CMD, IO1_8259PIC1);                    // send EOI cmd for master
}