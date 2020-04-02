#include <rtc.h>

void RTC::initClock() {
    outb(0x80 | RTC_REG_B, RTC_INDEX_PORT1);        // choice reg B
    outb(0x42, RTC_DATA_PORT1);                     // set PIE

    outb(RTC_REG_A, RTC_INDEX_PORT1);               // choice reg A
    uint8_t regA = inb(RTC_DATA_PORT1);             // get A 
    regA = (regA & 0xF0) | 0x2;                     // 7.8125ms
    outb(regA, RTC_DATA_PORT1);                     // write A

    clInteStatus();                                 // clear Interrupt status
}

void RTC::clInteStatus() {
    outb(RTC_REG_C, RTC_INDEX_PORT1);               // choice reg C
    inb(RTC_DATA_PORT1);                            // read regC to clear interrupt status
}