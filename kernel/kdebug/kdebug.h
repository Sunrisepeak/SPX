/*
 * @Author: SPeak Shen 
 * @Date: 2020-04-10 17:04:10 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-28 19:01:40
 */

#ifndef _KDEBUG_H
#define _KDEBUG_H

#include <defs.h>
#include <string.h>
#include <ostream.h>

#define BREAKPOINT(x) {                                \
    OStream kdebug("\nBreakPoint: ", "red");           \
    kdebug.write(x);                                   \
    kdebug.flush();                                    \
    cli();                                             \
    hlt();                                             \
};

#define DEBUGPRINT(x) {                                \
    OStream kdebug("\n[DEBUG]:", "red");               \
    kdebug.write(x);                                   \
    kdebug.flush();                                    \
};

#endif