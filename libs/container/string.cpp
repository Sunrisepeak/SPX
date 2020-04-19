/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-25 19:21:46 
 * @Last Modified by:   SPeak Shen 
 * @Last Modified time: 2020-03-25 19:21:46 
 */

#include <string.h>
#include <utils.hpp>

uint32_t String::cStrLen(ccstring cstr) {
    uint32_t len = 0;
    auto it = cstr;
    while(*it++ != '\0') {
        len++;
    }
    return len;
}


String::String(ccstring cstr) {
    str = (cstring)save;
    length = cStrLen(cstr);
    Utils::memcpy(cstr, str, length);
}


String::~String() {                                     //destructor

}


String & String::operator=(ccstring cstr) {             // copy assigment    
    length = cStrLen(cstr);
    for (uint32_t i = 0; i < length && i < STR_BASE_SIZE; i++) {
        save[i] = cstr[i];
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
            if (save[i] != (_str.str)[i]) {
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
