/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-25 15:03:13 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-10 17:26:15
 */

#include <ostream.h>

OStream::OStream(String str, String col) {
    cons.setColor(col);
    buffPointer = 0;
    for (; buffPointer < str.getLength(); buffPointer++) {
        buffer[buffPointer] = str[buffPointer];
    }
}

OStream::~OStream() {
    flush();
}

void OStream::flush() {
    cons.wirte(buffer, buffPointer);
    buffPointer = 0;
}

void OStream::write(const char &c) {
    if (buffPointer + 1 > BUFFER_MAX) {
        flush();
    }
    buffer[buffPointer++] = c;
}

void OStream::write(const char *arr, const uint32_t &len) {
    for (uint32_t i = 0; i < len; i++) {
        write(arr[i]);
    }
}

void OStream::write(const String &str) {
    write(str.cStr(), str.getLength());
}

void OStream::writeValue(const uint32_t &val) {
    if (val < 10) {
        write(val + '0');
    } else {
        uint8_t s[35];
        uint32_t temp = val, pos = 0;
        while (temp) {
            s[pos++] = temp % 10;
            temp /= 10;
        }
        while (pos) {
            write(s[--pos] + '0');
        }
    }
}