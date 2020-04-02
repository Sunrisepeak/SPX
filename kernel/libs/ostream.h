/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-25 15:02:59 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-28 15:09:12
 */

#ifndef __LIBS_OSTREAM_H
#define __LIBS_OSTREAM_H

#include <defs.h>
#include <string.h>
#include <console.h>

class OStream {
    
    public:
        OStream(String str, String col);

        ~OStream();

        void write(const char &c);

        void write(const char *arr, const uint32_t &len);
        
        void write(const String &str);

        void writeValue(const uint32_t &val);
       
        void flush();
    
    private:
        Console cons;
        char buffer[512];
        uint32_t buffPointer;               // buffer[] of end_pointer
        const uint32_t BUFFER_MAX = 512;    // buffer max value    
};

#endif