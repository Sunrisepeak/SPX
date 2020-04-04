/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-21 10:48:50 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-03 20:15:44
 * 
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
            uint8_t c;              // char       
            uint8_t attri;          // attribute KRGB_IRGB |  front:back
        }__attribute__ ((packed));  //      K: flash; 
                                         
                                    //(0,0)
        struct CursorPos {          //  *--------------> y
            uint8_t x;              //  |
            uint8_t y;              //  |
        };                          //  V x

        Console();

        void init();

        void clear();                                   // clear console

        void setColor(String str);                      // set Char color of console

        void setBackground(String str);                 // set background of console 

        void setCursorPos(uint8_t x, uint8_t y);        // set postion of coursor, left-top is (0, 0)

        const CursorPos & getCursorPos();               // get postion of coursor

        void wirte(const char &c);                      // write a Char

        void wirte(char *cArry, const uint16_t &len);   // write Char[] : 0 ~ length - 1

        char read();                                    // read a Char

        void read(char *cArry, const uint16_t &len);    // read Char[] : 0 ~ length - 1

    private:
        
        String color[COLOR_NUM] = {                     // color table
            "red", "black", "white", "blue"
        };
        
        uint8_t colorTable[COLOR_NUM] = {               // color map table
            0x4, 0x0, 0x7, 0x1
        };
        
        Char *screen;                                   // screen by char

        uint32_t length, wide;                          // screen size

        CursorPos cPos;                                 // coursor postion

        static Char charEctype;                         // char, background and char of attribute

        Char cursorStatus;

        /*      Function        */

        void next();                                    // move to next postion for coursor

        void lineFeed();                                // move to next postion for coursor

        void scrollScreen();                            // scroll a line of screen 

        //void wirte(const Char &c, const CursorPos pos); // write Char on decision postion
};

#endif