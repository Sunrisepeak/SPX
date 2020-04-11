/*
 * @Author: SPeak Shen 
 * @Date: 2020-04-10 17:04:10 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-10 19:27:08
 */

#ifndef _KDEBUG_H
#define _KDEBUG_H

#include <defs.h>
#include <ostream.h>

#define BREAKPOINT(x) {                             \
    OStream out("\nBreakPoint: ", "red");           \
    out.write(x);                                   \
    out.flush();                                    \
    cli();                                          \
    hlt();                                          \
};

#define DEBUGPRINT(x) {                             \
    OStream out("\n[DEBUG]:", "red");               \
    out.write(x);                                   \
    out.flush();                                    \
};

#endif