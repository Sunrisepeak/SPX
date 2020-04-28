#include <interrupt.h>

Interrupt::Interrupt() {
    
}

void Interrupt::init() {

    initIDT();

    initPIC();

    initClock();

    enableIRQ(2);                                   // set master IR2, because of slave connection to IR2
    
    enableIRQ(8);                                   // set slave IR1, clock interrupt of RTC
}

void Interrupt::initIDT() {
    extern uptr32_t __vectors[];
    for (uint32_t i = 0; i < sizeof(IDT) / sizeof(MMU::GateDesc); i++) {
        MMU::setGateDesc(IDT[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }

	// set for switch from user to kernel
    MMU::setGateDesc(IDT[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);

    // set system call desc of interrupt
    MMU::setGateDesc(IDT[T_SYSCALL], 1, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
	
    // load the IDT
    lidt(&idtPD);
}

void Interrupt::enable() {
    sti();
}

void Interrupt::disable() {
    cli();
}


