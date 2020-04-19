/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-21 17:52:51 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-25 19:22:09
 */

#ifndef _STRING_H
#define _STRING_H

#include <defs.h>

#define STR_BASE_SIZE 250

class String {

    public:

        String(ccstring cstr = "");

        ~String();
        
        String & operator=(ccstring cstr);

        uint8_t getLength() const;

        ccstring cStr() const;

        bool operator==(const String &_str);

        // index accessor
        char & operator[](const uint32_t index);

    private:

        cstring str;                    // str == save [AD]
        char save[STR_BASE_SIZE];      // base-store space
        
        cstring indexTable[10];         // to use when length great than 250 and size is PageSize for per index
        uint8_t index { 0 };

        uint8_t length;

        uint32_t cStrLen(ccstring cstr);
};

#endif