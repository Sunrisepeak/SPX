#ifndef _UTILS_HPP
#define _UTILS_HPP

#include <defs.h>
#include <kdebug.h>

class Utils {

    public:

        static uint32_t roundUp(uint32_t a, uint32_t n) {
            a = (a % n == 0) ? a : (a / n + 1) * n;
            return a;
        }

        static uint32_t roundDown(uint32_t a, uint32_t n) {         // round up  n for a; Example (7, 4) = 8
            return (a / n) * n;
        }

        static void memset(void *ad, uint8_t byte, uint32_t size) {
            uint8_t *p = (uint8_t *)ad;
            for (uint32_t i = 0; i < size; i++) {
                p[i] = byte;
            }
        }

        static void memcpy(const void *from, const void *to, uint32_t size) {
            uint8_t *src = (uint8_t *)from;
            uint8_t *dst = (uint8_t *)to;
            for (uint32_t i = 0; i < size; i++) {
                dst[i] = src[i];
            }
        }


        static bool memEmpty(void *ad, uint32_t size) {
            uint8_t *p = (uint8_t *)ad;
            for (uint32_t i = 0; i < size; i++) {
                if (*p != 0) {
                    return false;
                }
            }
            return true;
        }

        // swap content of memory
        template <typename T>
        static void swap(T &a, T &b) {
            if (sizeof(a) != sizeof(b)) {
                BREAKPOINT("Utils::swap fail.")
            }
            uint32_t n = sizeof(a);
            uint8_t temp;
            uint8_t *p1 = (uint8_t *)(&a);
            uint8_t *p2 = (uint8_t *)(&b);

            for (uint32_t i = 0; i < n; i++) {
                temp = p1[i];
                p1[i] = p2[i];
                p2[i] = temp;
            }
        }

};

#endif