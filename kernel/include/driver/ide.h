/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-20 22:16:02 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-14 23:19:44
 */

#ifndef _IDE_H
#define _IDE_H

#include <defs.h>
#include <x86.h>
#include <flags.h>

#define IO_BASE(ideno)          (channels[(ideno) >> 1].base)
#define IO_CTRL(ideno)          (channels[(ideno) >> 1].ctrl)

class IDE {

    public:
        struct Channels {
            unsigned short base;        // I/O Base
            unsigned short ctrl;        // Control Base
        } __attribute__((packed));

        struct IdeDevice {
            uint8_t valid;              // 0 or 1 (If Device Really Exists)
            uint32_t sets;              // Commend Sets Supported
            uint32_t size;              // Size in Sectors
            uchar8_t model[41];          // Model in String
        } __attribute__((packed));

        static void init();

        static bool isValid(uint32_t ideno);

        static uint32_t waitReady(uint16_t iobase, bool check = false);

        static uint32_t readSecs(uint16_t ideno, uint32_t secno, uptr32_t dst, uint32_t nsecs);

        static uint32_t writeSecs(uint16_t ideno, uint32_t secno, uptr32_t src, uint32_t nsecs);

        static uint32_t devSize(uint16_t ideno);

    private:
    
        static const Channels channels[];

        static IdeDevice ideDevs[];
        
};

#endif