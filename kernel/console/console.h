/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-21 10:48:50 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-21 20:04:05
 */

#ifndef _CONSOLE_H
#define _CONSOLE_H

#include <defs.h>
#include <vdieomemory.h>
#include <string.h>

#define COLOR_NUM       4

class Console : public VideoMemory {
    public:
        // public for to use of outside
        struct Char {           
            uint8_t c;          // char
            uint8_t attri;      // attribute 
        };
    
    private:
    
        String color[COLOR_NUM] = {
            "red", "black", "white", "blue"
        };

        uint8_t colorTable[COLOR_NUM] = {
            0x4, 0x0, 0x7, 0x1
        };

        struct CursorPos {
            uint32_t x;
            uint32_t y;
        };
        
        Char *screen;

        uint32_t length, wide;

        CursorPos cPos;

        Char charEctype;                     //char, background and char of attribute

    public:

        Console() {
            size = VideoMemory::size / sizeof(Char);
            screen = (Char *)(VideoMemory::vmBuffer);
            length = 80;
            wide = 25;
        }

        void setBackGround(String str) {
            uint32_t index = 2;
            for (uint32_t i = 0; i < COLOR_NUM; i++) {
                if (str == color[i]) {
                    index = i;
                    break;
                }
            }
            charEctype.attri = (charEctype.attri & 0x0F) | ((colorTable[index]) << 4);
            for (uint32_t i = 0; i < size; i++) {
                screen[i].attri = charEctype.attri;
            }
        }
};

#endif