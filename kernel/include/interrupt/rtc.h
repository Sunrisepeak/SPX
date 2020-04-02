#ifndef _RTC_H
#define _RTC_H

#include <defs.h>
#include <x86.h>

/*      Real Time Clock        */

// port
#define RTC_INDEX_PORT1            0x70
#define RTC_DATA_PORT1             0x71


// CMOS RAM
#define RTC_SECOND                 0x01        // second
#define RTC_CLOCK_SECOND           0x02
#define RTC_MINUTE                 0x03
#define RTC_CLOCK_MINUTE           0x04
#define RTC_HOUR                   0x05
#define RTC_CLOCK_HOUR             0x06
#define RTC_WEEKEND                0x07
#define RTC_DAY                    0x08
#define RTC_YEAR                   0x09
#define RTC_REG_A                  0x0A
#define RTC_REG_B                  0x0B
#define RTC_REG_C                  0x0C
#define RTC_REG_D                  0x0D

class RTC {

    public:
        void initClock();

        static void clInteStatus();

};


#endif