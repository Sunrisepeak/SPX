/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-25 19:21:46 
 * @Last Modified by:   SPeak Shen 
 * @Last Modified time: 2020-03-25 19:21:46 
 */

#include <string.h>

uint32_t String::cStrLen(ccstring cstr) {
    uint32_t len = 0;
    auto it = cstr;
    while(*it++ != '\0') {
        len++;
    }
    return len;
}


String::String(ccstring cstr) {
    str = (cstring)cstr;
    length = cStrLen(cstr);
}


String::~String() {                                     //destructor

}


String & String::operator=(ccstring cstr) {             // copy assigment
    length = cStrLen(cstr);
    //delete [] str;
    //str = new char[length];
    for (uint32_t i = 0; i < length; i++) {
        str[i] = cstr[i];
    }
    return *this;
}

ccstring String::cStr() const {
    return str;
}

uint8_t String::getLength() const {
    return length;
}

bool String::operator==(const String &_str) {
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
char & String::operator[](const uint32_t index) {
    return str[index];
}
