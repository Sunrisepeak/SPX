#include <pm.h>
#include <global.h>
#include <error.h>
#include <assert.h>
#include <kdebug.h>
#include <phymm.h>
#include <sync.h>
#include <string.h>
#include <utils.hpp>

// assemlly function
extern "C" void forkrets(Trap::TrapFrame *tf);
extern "C" void kernelThreadEntry(Trap::TrapFrame *tf);
extern "C" void switchTo(PM::Context *from, PM::Context *to);

static void
forkret() {
    forkrets(kernel::pm.current->data.value.tf);
}


/*----------------------------------------------------------*/



// init_main - the second kernel thread used to create user_main kernel threads
int PM::initMain(void *arg) {
    DEBUGPRINT("initMain");
    return 0;
}


void PM::init() {

    if ((idleProc = allocProc()) != nullptr) {

        assert(idleProc->data.value.name == "initProc");

        idleProc->data.value.pid = 0;
        idleProc->data.value.state = ProcState::PROC_RUNNABLE;
        idleProc->data.value.kStack = kernel::pmm.getStack();
        idleProc->data.value.needResched = true;
        idleProc->data.value.name = "idle";

        current = idleProc;

        int pid = kernelThread(initMain, "Hello world!!", 0);
        if (pid <= 0) {
            DEBUGPRINT("create init_main failed.\n");
        }

        initProc = procList.find(pid);
        initProc->data.value.name = "init";

        assert(idleProc != nullptr && idleProc->data.value.pid == 0);
        assert(initProc != nullptr && initProc->data.value.pid == 1);
    }
    
}

PM::Process * PM::allocProc() {
    auto proc = (Process *)kernel::pmm.kmalloc(sizeof(Process));

    auto pcb = &(proc->data.value);

    if (pcb != nullptr) {
        pcb->state = ProcState::PROC_UNINIT;
        pcb->pid = -1;
        pcb->runs = 0;
        pcb->kStack = 0;
        pcb->needResched = 0;
        pcb->parent = nullptr;
        pcb->mm = nullptr;
        Utils::memset(&(pcb->context), 0, sizeof(Context));
        pcb->tf = nullptr;
        pcb->cr3 = kernel::pmm.getCR3();
        pcb->flags = 0;
        new (&(pcb->name)) String("initProc");              // call ctr init
    }

    return proc;
}

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int PM::kernelThread(int (*fn)(void *), const void *arg, uint32_t clone_flags) {
    // temp tf
    Trap::TrapFrame tf;
    
    Utils::memset(&tf, 0, sizeof(Trap::TrapFrame));
    
    tf.tf_cs = KERNEL_CS;
    tf.tf_ds = tf.tf_es = tf.tf_ss = KERNEL_DS;
    tf.tf_regs.reg_ebx = (uint32_t)fn;
    tf.tf_regs.reg_edx = (uint32_t)arg;
    tf.tf_eip = (uint32_t)kernelThreadEntry;

    return doFork(clone_flags | CLONE_VM, 0, &tf);
}

/* do_fork -     parent PM for a new child PM
 * @clone_flags: used to guide how to clone the child PM
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child PM's proc->tf
 */
int PM::doFork(uint32_t clone_flags, uptr32_t stack, Trap::TrapFrame *tf) {
    int ret = -E_NO_FREE_PROC;
    Process *proc;
    if (procList.size() >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;

    if ((proc = allocProc()) == nullptr) {
        goto fork_out;
    }

    proc->data.value.parent = current;
    // wait 2020.4.18
    if (allocKernelStack(proc->data.value) != 0) {
        goto bad_fork_cleanup_proc;
    }

    if (copyMm(clone_flags, proc->data.value) != 0) {
        goto bad_fork_cleanup_kstack;
    }

    copyThread(proc->data.value, stack, tf);

    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->data.value.pid = generatePid();
        procList.add(proc->data.value.pid, proc);
    }
    local_intr_restore(intr_flag);

    // wait...............
    kernel::algorithms::sched.wakeupProc(proc->data.value);

    ret = proc->data.value.pid;

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    freeKernelStack(proc->data.value);

bad_fork_cleanup_proc:
    kernel::pmm.kfree(proc, sizeof(proc));
    goto fork_out;
}

int PM::allocKernelStack(PCB &pcb) {
    auto pnode = kernel::pmm.allocPages(KSTACKPAGE);
    if (pnode != nullptr) {
        pcb.kStack = kernel::pmm.pnodeToPageLAD(pnode);
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - free the memory space of process kernel stack
void PM::freeKernelStack(PCB &pcb) {
    kernel::pmm.freePages(kernel::pmm.vAdToPgNode(pcb.kStack), KSTACKPAGE);
}

// copy_mm - PM "proc" duplicate OR share PM "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
int PM::copyMm(uint32_t clone_flags, PCB &pcb) {
    assert(current->data.value.mm == nullptr);
    /* do nothing in this project */
    return 0;
}

uint32_t PM::generatePid() {
    uint32_t pid = 1;
    while (true) {
        if (!procList.isExist(pid)) {
            break;
        }
        pid = pid % MAX_PID + 1;
    }
    return pid;
}

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
void PM::copyThread(PCB &pcb, uptr32_t esp, Trap::TrapFrame *tf) {
    pcb.tf = (Trap::TrapFrame *)(pcb.kStack + KSTACKSIZE) - 1;
    *(pcb.tf) = *tf;
    pcb.tf->tf_regs.reg_eax = 0;
    pcb.tf->tf_esp = esp;
    pcb.tf->tf_eflags |= FL_IF;

    pcb.context.eip = (uptr32_t)(forkret);
    pcb.context.esp = (uptr32_t)(pcb.tf);
}

void PM::doExit(int error_code) {
    DEBUGPRINT("process exit!!.");
    BREAKPOINT("****");
}

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void PM::cpuIdle() {

    DEBUGPRINT("PM::cpuIdle");
    
    while (1) {
        if (current->data.value.needResched) {
            kernel::algorithms::sched.schedule();
        }
    }
}

// proc_run - make process "proc" running on cpu
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void PM::procRun(Process *proc) {

    DEBUGPRINT("PM::procRun");
    
    if (proc != current) {
        bool intr_flag;
        auto prev = current, next = proc;
        local_intr_save(intr_flag);
        {
            current = proc;
            kernel::pmm.loadEsp0(next->data.value.kStack + KSTACKSIZE);
            setCR3(next->data.value.cr3);
            switchTo(&(prev->data.value.context), &(next->data.value.context));
        }
        local_intr_restore(intr_flag);
    }
}



