/*
 * @Author: SPeak Shen 
 * @Date: 2020-04-09 17:21:05 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-09 17:51:42
 */

#ifndef _ASSERT_H
#define _ASSERT_H

#include <defs.h>
#include <x86.h>
#include <ostream.h>

// assert(x) will generate a run-time error if 'x' is false.
#define assert(x)                                       \
    if (!(x)) {                                         \
        OStream out("\nassert: failed ", "red");        \
        out.write(#x);                                  \
        out.flush();                                    \
        cli();                                          \
        hlt();                                          \
    }                                                   \

// static_assert(x) will generate a compile-time error if 'x' is false.
#define static_assert(x)                                \
    switch (x) {                                        \
        case 0:  case (x): ;                            \
    }

#endif

