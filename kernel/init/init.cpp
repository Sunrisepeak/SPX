/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-22 11:20:35 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-10 21:19:58
 */

#include <defs.h>
#include <assert.h>
#include <kdebug.h>
#include <string.h>
#include <ostream.h>
#include <list.hpp>
#include <icxxabi.h>
#include <global.h>
#include <vmm.h>

extern uint32_t ctorStart, ctorEnd; // Start and end of constructors

/*  kernel entry point  */
extern "C" void initKernel() {

    kernel::console.init();                         // step 1
    kernel::console.setBackground("white");
    
    OStream os("Welcome SPX OS.....\n\n", "blue");  // step 2
    os.flush();

    kernel::pmm.init();                             // step 3

    kernel::interrupt.init();                       // step 4

    kernel::vmm.init();                             // step 5 page fault need interrupt

    kernel::pm.init();                              // step 8 init process table

    IDE::init();                                    // step 6

    kernel::swap.swapInit();                        // step 7

    kernel::interrupt.enable();                     // step 9

    kernel::pm.cpuIdle();                           // step 10

    while (true) {
        hlt();
    };
}

extern "C" void globCtor() {
    // Loop and call all the constructors
   for(uint32_t *ctor = &ctorStart; ctor < &ctorEnd; ctor++){
      ((void (*) (void)) (*ctor))();
   }
}







