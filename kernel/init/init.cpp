/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-22 11:20:35 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-03-28 21:34:43
 */

#include <defs.h>
#include <string.h>
#include <console.h>
#include <ostream.h>
#include <interrupt.h>
#include <gstatic.h>   

/*  kernel entry point  */
extern "C" void initKernel() {
    Console cons;
    cons.clear();
    cons.setBackground("white");

    Interrupt inter;
    inter.init();
    inter.enable();
    while(1);
}