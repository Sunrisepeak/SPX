#include <vdieomemory.h>

VideoMemory::VideoMemory() {

}

void VideoMemory::initVmBuff() {
    for (uint32_t i = 0; i < VGA_BUFF_SIZE; i++) {
        vmBuffer[i] = 0;
    }
}

uint16_t VideoMemory::getCursorPos() {
    outb(VGA_CURSOR_PORT_D, VGA_INDEX_PORT);
    uint8_t low = inb(VGA_DATA_PORT);
    outb(VGA_CURSOR_PORT_H, VGA_INDEX_PORT);
    uint16_t pos = inb(VGA_DATA_PORT);
    return (pos << 8) + low;
}

void VideoMemory::setCursorPos(uint16_t pos) {
    outb(VGA_CURSOR_PORT_D, VGA_INDEX_PORT);
    outb((pos & 0xFF), VGA_DATA_PORT);
    outb(VGA_CURSOR_PORT_H, VGA_INDEX_PORT);
    outb(((pos >> 8) & 0xFF), VGA_DATA_PORT);
}
