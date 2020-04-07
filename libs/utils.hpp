#ifndef _UTILS_HPP
#define _UTILS_HPP

#include <defs.h>

class Utils {

    public:

        static uint32_t roundUp(uint32_t a, uint32_t n);   // round up  n for a; Example (7, 4) = 8

        static uint32_t roundDown(uint32_t a, uint32_t n);   // round up  n for a; Example (7, 4) = 8

        static void memset(uptr32_t ad, uint8_t byte, uint32_t size);


};

uint32_t Utils::roundUp(uint32_t a, uint32_t n) {
    a = (a % n == 0) ? a : (a / n + 1) * n;
    return a;
}

uint32_t Utils::roundDown(uint32_t a, uint32_t n) {
    return (a / n) * n;
}

void Utils::memset(uptr32_t ad, uint8_t byte, uint32_t size) {
    uint8_t *p = (uint8_t *)ad;
    for (uint32_t i = 0; i < size; i++) {
        p[i] = byte;
    }
}

#endif