/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-21 17:52:51 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-21 20:59:41
 */

#ifndef _STRING_H
#define _STRING_H

#include <defs.h>

class String {

    private:
        cstring str;
        uint8_t length;

        uint32_t cStrLen(ccstring cstr) {
            uint32_t len = 0;
            auto it = cstr;
            while(*it++ != '\0') {
                len++;
            }
            return len;
        }

    public:

        String(ccstring cstr) {
            length = cStrLen(cstr);
            str = new char[length];
            for (uint32_t i = 0; i < length; i++) {
                str[i] = cstr[i];
            }
        }

        ~String() {                                     //destructor
            delete [] str;
        }

        String & operator=(ccstring cstr) {             // copy assigment
            length = cStrLen(cstr);
            delete [] str;
            str = new char[length];
            for (uint32_t i = 0; i < length; i++) {
                str[i] = cstr[i];
            }
            return *this;
        }

        ccstring cStr() {
            return str;
        }

        uint8_t getLength() {
            return length;
        }

        bool operator==(const String &_str) {
            bool isEquals = false;
            if (_str.length == length) {
                for (uint32_t i = 0; i < length; i++) {
                    if (str[i] != (_str.str)[i]) {
                        return false;
                    }
                }
                isEquals = true;
            }
            return isEquals;
        }

        // index accessor
        char & operator[](const uint32_t index) {
            return str[index];
        }
};

#endif