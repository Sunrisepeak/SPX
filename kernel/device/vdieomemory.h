/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-21 10:48:50 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-21 17:43:09
 */

#ifndef _VIDEO_MEMORY_H
#define _VIDEO_MEMORY_H

#include <defs.h>
#include <x86.h>
#include <vag.h>        //Video Card


class VideoMemory {
    protected:
        uint8_t *vmBuffer { (uint8_t *)VAG_BUFF_ADDR };
        uint16_t size { VAG_BUFF_SIZE };
    public:
        

        VideoMemory() {
            initVmBuff();
            setCursorPos(0);
        }

        void initVmBuff() {
            for (uint32_t i = 0; i < VAG_BUFF_SIZE; i++) {
                vmBuffer[i] = 0;
            }
        }

        uint16_t getCursorPos() {
            outb(VAG_CURSOR_PORT_D, VAG_INDEX_PORT);
            uint8_t low = inb(VAG_DATA_PORT);
            outb(VAG_CURSOR_PORT_H, VAG_INDEX_PORT);
            uint16_t pos = inb(VAG_DATA_PORT);
            return (pos << 8) + low;
        }

        void setCursorPos(uint16_t pos) {
            outb(VAG_CURSOR_PORT_D, VAG_INDEX_PORT);
            outb((pos & 0xFF), VAG_DATA_PORT);
            outb(VAG_CURSOR_PORT_H, VAG_INDEX_PORT);
            outb(((pos >> 8) & 0xFF), VAG_DATA_PORT);
        }

};

#endif