/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-25 15:03:34 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-28 18:44:43
 */

#include <console.h>

Console::Console() {
    // set l and w
    length = 80;
    wide = 25;
    
    // get Video Memory buffer
    screen = (Char *)(VideoMemory::vmBuffer);

    // get cursor position
    cPos.x = VideoMemory::getCursorPos() / length;
    cPos.y = VideoMemory::getCursorPos() % length;

    // init char = S and color: front = white, back = black
    charEctype.c = 'S';
    charEctype.attri = screen[0].attri;     // get current background of console

    // set cursor status
    cursorStatus.c = 'S';
    cursorStatus.attri = 0b10101010;        // light green and flash
}

void Console::clear() {
    VideoMemory::initVmBuff();
}

void Console::setColor(String str) {
    uint32_t index;
    for (index = 0; index < COLOR_NUM; index++) {
        if (str == color[index]) {
            break;
        }
    }
    if (index < COLOR_NUM) {
        charEctype.attri = (charEctype.attri & 0xF0) | colorTable[index];
    }
}

void Console::setBackground(String str) {
    uint32_t index = 1;                             // default black
    for (uint32_t i = 0; i < COLOR_NUM; i++) {
        if (str == color[i]) {
            index = i;
            break;
        }
    }
    charEctype.attri = (charEctype.attri & 0x0F) | ((colorTable[index]) << 4);
    for (uint32_t row = 0; row < wide; row++) {
        for (uint32_t col = 0; col < length; col++) {
            screen[row * length + col].attri = charEctype.attri;
        }
    }
}

void Console::setCursorPos(uint8_t x = 0, uint8_t y = 0) {
    cPos.x = x;
    cPos.y = y;
    // set cursor status
    screen[cPos.x * length + cPos.y] = cursorStatus;
    VideoMemory::setCursorPos(cPos.x * length + cPos.y);
}

const Console::CursorPos & Console::getCursorPos() {
    cPos.x = VideoMemory::getCursorPos() / length;
    cPos.y = VideoMemory::getCursorPos() % length;
    return cPos;
}

void Console::wirte(const char &c) {
    if (c == '\n') {
        charEctype.c = ' ';
        screen[cPos.x * length + cPos.y] = charEctype;
        lineFeed();
    } else {
        charEctype.c = c;
        screen[cPos.x * length + cPos.y] = charEctype;
        next();
    }
}

void Console::wirte(char *cArry, const uint16_t &len) {
    for (uint32_t i = 0; i < len; i++) {
        wirte(cArry[i]);
    }
}

char Console::read() {
    return screen[0].c;
}

void Console::read(char *cArry, const uint16_t &len) {
   
}

/*-----------------------------Private Member-------------------------------*/

void Console::next() {
    cPos.y = (cPos.y + 1) % length;
    if (cPos.y == 0) {
        cPos.x = (cPos.x + 1) % wide;
    }
    
    if (cPos.y == 0 && cPos.x == 0) {   // jugde scroll screen
        scrollScreen();
    } else {
        setCursorPos(cPos.x, cPos.y);
    }    
}

void Console::lineFeed() {
    if ((uint32_t)(cPos.x + 1) >= wide) {
        scrollScreen();
    } else {
        setCursorPos(cPos.x + 1, 0);
    }
}

void Console::scrollScreen() {
    charEctype.c = ' ';
    for (uint32_t i = 0; i < length * wide; i++) {
        if (i < length * (wide - 1)) {
            screen[i] = screen[length + i];
        } else {
            screen[i] = charEctype;
        }
    }
    setCursorPos(wide - 1, 0);
}

/*
void Console::wirte(const Char &c, const CursorPos pos) {
    screen[pos.x * length + pos.y] = c;
    next();
}
*/

