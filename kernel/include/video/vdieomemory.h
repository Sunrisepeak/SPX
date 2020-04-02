/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-21 10:48:50 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-26 13:21:21
 */

#ifndef _VIDEO_MEMORY_H
#define _VIDEO_MEMORY_H

#include <defs.h>
#include <x86.h>
#include <vga.h>        //Video Card


class VideoMemory {
    
    public:
        
        VideoMemory();

        void initVmBuff();

        uint16_t getCursorPos();

        void setCursorPos(uint16_t pos);

    protected:

        uint8_t *vmBuffer { (uint8_t *)VGA_BUFF_ADDR };
        
        uint16_t size { VGA_BUFF_SIZE };

};

#endif