#include <trap.h>
#include <global.h>
#include <kdebug.h>
#include <ostream.h>

void Trap::trap(TrapFrame *tf) {
    trapDispatch(tf);
}

void Trap::trapDispatch(TrapFrame *tf) {
    int ret;

    switch (tf->tf_trapno) {
    case T_PGFLT:  //page fault
        if ((ret = pageFaultHandler(tf)) != 0) {
            BREAKPOINT("handle pgfault failed.\n");
        }
        break;
    case IRQ_OFFSET + IRQ_TIMER:

        break;
    case IRQ_OFFSET + IRQ_COM1:
        
        break;
    case IRQ_OFFSET + IRQ_KBD:
       
        break;
    
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        //BREAKPOINT("interrupt error");
        kernel::algorithms::sched.schedule();
    }
}

int Trap::pageFaultHandler(TrapFrame *tf) {
    if (kernel::vmm.checkMM != nullptr) {
        return kernel::vmm.doPageFault(kernel::vmm.checkMM, tf->tf_err, getCR2());
    } else {
        BREAKPOINT("Trap::pageFaultHandler: Failure");
        return -1;
    }
}