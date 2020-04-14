#include <global.h>

/*
 *  init for global Console::variable
 *
 */

/* ------------->Console<-----------------*/

Console::Char * Console::screen { nullptr };                                   // screen by char
uint32_t Console::length { 80 };                          // screen size
uint32_t Console::wide { 50 };                          // screen size
Console::CursorPos Console::cPos {0, 0};                                 // coursor postion
Console::Char Console::charEctype = {       // char, background and char of attribute
    ' ', 0x0
};
Console::Char Console::cursorStatus = { 
    'S', 0b10101010                         // light green and flash
};

// PIC   8259A
uint16_t PIC::irqMask  = 0xFFFF;
bool PIC::didInit  = false;

// MMU
uint32_t MMU::bootCR3 = 0;



// init task state segment struct
MMU::TSS PhyMM::tss = { 0 };

// Interrupt
MMU::GateDesc Interrupt::IDT[256] = {{0}};
MMU::PseudoDesc Interrupt::idtPD = {
    sizeof(Interrupt::IDT) - 1, (uptr32_t)(Interrupt::IDT)
};

/* -----------------------------------------> FFMA <--------------------------------------------*/

//List<MMU::Page> FFMA::freeArea;                // list of all of Page

//uint32_t FFMA::nfp { 0 };                      // number of free-page

// PhyMM

MMU::SegDesc PhyMM::GDT[] = {
    SEG_NULL,
    SEG_NULL,
    SEG_NULL,
    SEG_NULL,
    SEG_NULL,
    SEG_NULL
};

MMU::PseudoDesc PhyMM::gdtPD = {
    sizeof(GDT) - 1, (uptr32_t)GDT
};


/* ------------------------->IDE<------------------------------- */

const IDE::Channels IDE::channels[2] = {
    {IO_BASE0, IO_CTRL0},
    {IO_BASE1, IO_CTRL1},
};

IDE::IdeDevice IDE::ideDevs[MAX_IDE] = { {0} };

/* ------------------------->Swap<------------------------------- */

uint32_t Swap::maxSwapOffset { 0 };
