/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-20 22:16:02 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-21 15:34:34
 */

#ifndef _HARD_DISK_H
#define _HARD_DISK_H

#include <defs.h>
#include <storagedev.h>
#include <x86.h>

class HardDisk : public StorageDev {
    private:

        uint8_t read() override {

        }

        void write(uint8_t data) override {
            
        }
        
        uint16_t read(uint32_t addr, uint32_t count) {
            uint16_t *data;
            inlToVAddr(0x1F0, (uptr32_t)data);
            return (*data);
        }

        void write(uint32_t addr, uint32_t data) {
            
        }
        
    public:

        bool readOk() {
                
        }

        void readFile() {

        }
};

#endif