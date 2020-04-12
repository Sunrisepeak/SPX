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

extern "C" void globCtor() {
    // Loop and call all the constructors
   for(uint32_t *ctor = &ctorStart; ctor < &ctorEnd; ctor++){
      ((void (*) (void)) (*ctor))();
   }
}

/*  kernel entry point  */
extern "C" void initKernel() {

    kernel::console.init();
    kernel::console.setBackground("white");
    
    OStream os("Welcome SPX OS.....\n\n", "blue");
    os.flush();

    kernel::pmm.init();

    kernel::interrupt.init();

    kernel::vmm.init();

    //kernel::interrupt.enable();

    while (true) {
        hlt();
    };
}






