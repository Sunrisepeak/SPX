/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-22 11:20:35 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-09 17:35:19
 */

#include <defs.h>
#include <assert.h>
#include <string.h>
#include <console.h>
#include <ostream.h>
#include <interrupt.h>
#include <phymm.h>
#include <list.hpp>
#include <gstatic.h>

/*     virtual funciton exception dealing       */
extern "C" void __cxa_pure_virtual() { 
    OStream os("\nvirutal funtion error.. \n", "red");
    os.flush();
    while (1); 
}

/*  kernel entry point  */
extern "C" void initKernel() {

    static_assert(true);
    bool test = false;
    assert(test == true);

    Console cons;
    cons.init();
    cons.setBackground("white");
    OStream os("Welcome SPX OS.....\n\n", "blue");
    os.flush();

    PhyMM pm;
    pm.init();

    Interrupt inter;
    inter.init();
    inter.enable();
    
    while(1);
}






