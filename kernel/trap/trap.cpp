#include <trap.h>
#include <global.h>
#include <kdebug.h>
#include <error.h>
#include <assert.h>
#include <ostream.h>

void Trap::trap(TrapFrame *tf) {
    if (kernel::pm.current == nullptr) {
        trapDispatch(tf);
    } else {
        // keep a trapframe chain in stack
        auto savetTf = kernel::pm.current->data.value.tf;
        kernel::pm.current->data.value.tf = tf;
    
        bool in_kernel = trapInKernel(tf);      // judge user trap Or kernel trap [in]

        trapDispatch(tf);
    
        kernel::pm.current->data.value.tf = savetTf;

        if (!in_kernel) {
            if (kernel::pm.current->data.value.flags & PF_EXITING) {
                kernel::pm.doExit(-E_KILLED);
            }
            if (kernel::pm.current->data.value.needResched) {
                kernel::algorithms::sched.schedule();
            }
        }

        printTrapFrame(tf);
/*
        if (kernel::DEBUG_FLAGS) {
            while(1);
        }
*/
    }
}

void Trap::trapDispatch(TrapFrame *tf) {
    int ret;

    switch (tf->tf_trapno) {
        case T_PGFLT:  //page fault
            if ((ret = pageFaultHandler(tf)) != 0) {
                if (kernel::pm.current == nullptr) {
                    BREAKPOINT("handle pgfault failed.");
                } else {
                    if (trapInKernel(tf)) {
                        BREAKPOINT("handle pgfault failed in kernel mode.");
                    }
                    DEBUGPRINT("killed by kernel.\n");
                    BREAKPOINT("handle user mode pgfault failed"); 
                    kernel::pm.doExit(-E_KILLED);
                }
            }
            break;

        case T_SYSCALL:
            kernel::scall.syscall();
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
        default: ;
            // in kernel, it must be a mistake
            //BREAKPOINT("interrupt error");
            //kernel::algorithms::sched.schedule();
    }

}

int Trap::pageFaultHandler(TrapFrame *tf) {
    auto mm = kernel::vmm.checkMM;

    if (mm != nullptr) {    // idelProc page fault
        assert(kernel::pm.current == kernel::pm.idleProc);
    } else {                // other thread page fault

        DEBUGPRINT("other thread page fault");
        if (kernel::pm.current == nullptr) {
            BREAKPOINT("unhandled page fault.\n");
        }
        mm = kernel::pm.current->data.value.mm;
    }

    return kernel::vmm.doPageFault(kernel::vmm.checkMM, tf->tf_err, getCR2());
}

/* trap_in_kernel - test if trap happened in kernel */
bool Trap::trapInKernel(TrapFrame *tf) {
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
}

void Trap::printTrapFrame(TrapFrame *tf) {

    kernel::stdio::out.write("\nTrapFrame: <----- start");

    kernel::stdio::out.write("\n tf_cs = ");
    kernel::stdio::out.writeValue(tf->tf_cs);

    kernel::stdio::out.write("\n tf_ds = ");
    kernel::stdio::out.writeValue(tf->tf_ds);

    kernel::stdio::out.write("\n tf_eip = ");
    kernel::stdio::out.writeValue(tf->tf_eip);

    kernel::stdio::out.write("\n tf_esp = ");
    kernel::stdio::out.writeValue(tf->tf_esp);

    kernel::stdio::out.write("\n tf_eflags = ");
    kernel::stdio::out.writeValue(tf->tf_eflags);

    kernel::stdio::out.write("\nTrapFrame: <----- end \n");

    kernel::stdio::out.flush();
}