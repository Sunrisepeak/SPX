/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-20 21:57:37 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-21 13:18:37
 */
#ifndef _STORAGE_DEV_H
#define _STORAGE_DEV_H

#include <defs.h>
#include <device.h>

class StorageDev : public Device{
    public:
        virtual uint8_t read() = 0;

        virtual void write(uint8_t data) = 0;
};

#endif