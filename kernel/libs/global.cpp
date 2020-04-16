#include <global.h>
#include <x86.h>
#include <assert.h>

/*   gloable obj, varible, function   */

namespace kernel {
    
    Console console;

    PhyMM pmm;

    Interrupt interrupt;

    IDE ide;

    VMM vmm;

    Swap swap;

    namespace algorithms {

        SwapFifo swapFifo;

        FFMA ffma;
    
    };

    namespace stdio {
        OStream out("blue");
    };
};

void *operator new(uint32_t size) {
    return kernel::pmm.kmalloc(size);
}

void * operator new[](uint32_t size) {
    return kernel::pmm.kmalloc(size);
}

void * operator new(uint32_t size, void *ptr) {
    return ptr;
}

void * operator new[](uint32_t size, void *ptr) {
    return ptr;
}

void operator delete(void *ptr) {
    kernel::pmm.kfree(ptr, PGSIZE);
}
 
void operator delete[](void *ptr) {
    kernel::pmm.kfree(ptr, PGSIZE);
}