#include <pm.h>
#include <global.h>
#include <error.h>
#include <assert.h>
#include <elf.h>
#include <kdebug.h>
#include <phymm.h>
#include <sync.h>
#include <string.h>
#include <utils.hpp>
#include <userEntry.h>

// assemlly function
extern "C" void forkrets(Trap::TrapFrame *tf);
extern "C" void kernelThreadEntry(Trap::TrapFrame *tf);
extern "C" void switchTo(PM::Context *from, PM::Context *to);

static void
forkret() {
    forkrets(kernel::pm.current->data.value.tf);
}


/*----------------------------------------------------------*/


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

        pcb->wait_state = 0;
        pcb->cptr = pcb->optr = pcb->yptr = nullptr;
    }

    return proc;
}

// kernel_thread - create a kernel thread using "fn" function
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int PM::kernelThread(int (*fn)(void *), const void *arg, uint32_t clone_flags) {
    DEBUGPRINT("PM::kernelThread");
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

int PM::allocKernelStack(PCB &pcb) {
    auto pnode = kernel::pmm.allocPages(KSTACKPAGE);
    if (pnode != nullptr) {
        pcb.kStack = kernel::pmm.pnodeToKernelLAD(pnode);
        return 0;
    }
    return -E_NO_MEM;
}

// put_kstack - free the memory space of process kernel stack
void PM::freeKernelStack(PCB &pcb) {
    kernel::pmm.freePages(kernel::pmm.kvAdToPgNode(pcb.kStack), KSTACKPAGE);
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
            // thread switch
            switchTo(&(prev->data.value.context), &(next->data.value.context));
        }
        local_intr_restore(intr_flag);
    }
}

// alloc one page as PDT
int PM::setupPDT(VMM::MM &mm) {
    auto pnode = kernel::pmm.allocPages();
    if (pnode == nullptr) {
        return -E_NO_MEM;
    }
    auto pdt = (MMU::PTEntry *) kernel::pmm.pnodeToKernelLAD(pnode);

    // copy kernel pdt to new pdt
    Utils::memcpy(kernel::pmm.getPDT(), pdt, PGSIZE);

    // set kernel page dir to the page dir
    pdt[MMU::LinearAD::LAD(VPT).PDI] = kernel::pmm.kAdToPhyAD((uptr32_t)pdt) | PTE_P | PTE_W;
    mm.pdt = pdt;

    return 0;
}

// free the memory space of PDT
void PM::releasePDT(VMM::MM &mm) {
    kernel::pmm.freePages(kernel::pmm.kvAdToPgNode((uptr32_t)(mm.pdt)));
}

// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
int PM::copyMm(uint32_t clone_flags, Process *proc) {
    Linker<VMM::MM>::DLNode *mm, *oldmm = current->data.value.mm;
    int ret = 0;

    /* current is a kernel thread */
    if (oldmm == nullptr) {
        return ret;
    }

    if (clone_flags & CLONE_VM) {   // 1.share ?
        mm = oldmm;
        goto good_mm;
    }

    ret = -E_NO_MEM;
    if ((mm = kernel::vmm.mmCreate()) == nullptr) {
        goto bad_mm;
    }

    if (setupPDT(mm->data) != 0) {
        goto bad_data_mm;
    }

    kernel::vmm.lockMm(oldmm->data);
    {
        ret = kernel::vmm.dupMmMap(oldmm, mm);  // 2. duplicate
    }
    kernel::vmm.unlockMm(oldmm->data);

    if (ret != 0) {
        goto bad_dup_cleanup_mmap;
    }

good_mm:                        // "share"
    mm->data.mm_share++;
    proc->data.value.mm = mm;
    proc->data.value.cr3 = kernel::pmm.kAdToPhyAD((uptr32_t)(mm->data.pdt));
    return 0;

bad_dup_cleanup_mmap:           // "duplicate"
    kernel::vmm.exitMmMap(mm);
    releasePDT(mm->data);

bad_data_mm:
    kernel::vmm.mmDestroy(mm);

bad_mm:
    return ret;
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
        setRelation(proc);
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

int PM::doExit(int error_code) {
    DEBUGPRINT("process exit!!.");
    //BREAKPOINT("****");
    return 0;
}

//ask the scheduler to reschedule
int PM::doYield() {
    current->data.value.needResched = true;
    return 0;
}

int PM::doExecve(String &name, uint32_t len, uchar8_t *binary, uint32_t size) {
    auto mm = current->data.value.mm;

    kernel::stdio::out.writeValue(size);
    kernel::stdio::out.flush();

    if (!kernel::vmm.userMemCheck(mm, (uptr32_t)&name, len, false)) {
        return -E_INVAL;
    }

    if (len > PROC_NAME_LEN) {
        len = PROC_NAME_LEN;
    }

    if (mm != nullptr) {
        BREAKPOINT("doExecve Debug");
        setCR3(kernel::pmm.getCR3());
        if ((--(mm->data.mm_share)) == 0) {
            kernel::vmm.exitMmMap(mm);
            releasePDT(mm->data);
            kernel::vmm.mmDestroy(mm);
        }
        current->data.value.mm = nullptr;
    }

    int ret;
    if ((ret = loadCodeELF(binary, size)) != 0) {
        goto execve_exit;
    }
    current->data.value.name = name;
    return 0;

execve_exit:

    doExit(ret);
    DEBUGPRINT("already exit: ");
    kernel::stdio::out.writeValue(ret);
    return 0;
}

// do_wait - wait one OR any children with ProcState::PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int PM::doWait(uint32_t pid, int *code_store) {
    DEBUGPRINT("PM::doWait");
    auto *mm = current->data.value.mm;
    if (code_store != nullptr) {        // code is Exist [mem]?
        if (!kernel::vmm.userMemCheck(mm, (uptr32_t)code_store, sizeof(uint32_t), true)) {
            return -E_INVAL;
        }
    }

    Process *proc;
    bool intr_flag, hasKid;

repeat:
    hasKid = false;
    if (pid != 0) {     // is pid = 0 kernelThread
        proc = procList.find(pid);
        if (proc != nullptr && proc->data.value.parent == current) {
            hasKid = 1;
            if (proc->data.value.state == ProcState::PROC_ZOMBIE) {
                goto found;
            }
        }
    } else {
        proc = current->data.value.cptr;
        for (; proc != nullptr; proc = proc->data.value.optr) {
            hasKid = true;

            DEBUGPRINT("find child thread");
            kernel::stdio::out.writeValue(proc->data.value.pid);
            kernel::stdio::out.flush();
            
            if (proc->data.value.state == ProcState::PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    if (hasKid) {   // has child thread
        current->data.value.state = ProcState::PROC_SLEEPING;
        current->data.value.wait_state = WT_CHILD;

        kernel::algorithms::sched.schedule();
        
        if (current->data.value.flags & PF_EXITING) {
            doExit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;

found:
    if (proc == idleProc || proc == initProc) {
        BREAKPOINT("wait idleproc or initProc.\n");
    }
    
    if (code_store != nullptr) {
        *code_store = proc->data.value.exit_code;
    }
    
    local_intr_save(intr_flag);
    {
        cleanRelation(proc);
    }
    local_intr_restore(intr_flag);
    
    freeKernelStack(proc->data.value);
    kernel::pmm.kfree(proc, sizeof(Process));
    return 0;
}

// do_kill - kill process with pid by set this process's flags with PF_EXITING
int PM::doKill(uint32_t pid) {
    Process *proc;
    if ((proc = procList.find(pid)) != nullptr) {
        if (!(proc->data.value.flags & PF_EXITING)) {
            proc->data.value.flags |= PF_EXITING;
            if (proc->data.value.wait_state & WT_INTERRUPTED) {
                kernel::algorithms::sched.wakeupProc(proc->data.value);
            }
            return 0;
        }
        return -E_KILLED;
    }
    return -E_INVAL;
}

/* load_icode - load the content of binary program(ELF format) as the new content of current process
 * @binary:  the memory addr of the content of binary program
 * @size:  the size of the content of binary program
 */
int PM::loadCodeELF(uchar8_t *binary, uint32_t size) {

    kernel::DEBUG_FLAGS = true;

    DEBUGPRINT("PM::loadCodeELF ");
    kernel::stdio::out.writeValue(size);
    kernel::stdio::out.flush();
    
    if (current->data.value.mm != nullptr) {
        BREAKPOINT("load_icode: current..mm must be empty.\n");
    }

    // variable init OR defined in front of goto-keywrod
    int ret = -E_NO_MEM;
    Linker<VMM::MM>::DLNode *mm;
    Linker<MMU::Page>::DLNode *pnode { nullptr };
    Trap::TrapFrame *tf;

    Elf_Ehdr *elf;
    Elf_Phdr *ph, *ph_end;

    // step1: create a new mm for current process
    if ((mm = kernel::vmm.mmCreate()) == nullptr) {
        goto bad_mm;
    }
    
    // step2: create a new PDT, and mm->data.pdt= kernel virtual addr of PDT
    if (setupPDT(mm->data) != 0) {
        goto bad_cleanup_mm;
    }

    // step3: copy TEXT/DATA section, build BSS parts in binary to memory space of process
    // step3.1: get the file header of the bianry program (ELF format)
    elf = (Elf_Ehdr *)binary;

    // step3.2: get the entry of the program section headers of the bianry program (ELF format)
    ph = (Elf_Phdr *)(binary + elf->e_phoff);
    
    // step3.3: This program is valid?
    if (elf->e_magic != ELF_MAGIC) {
        ret = -E_INVAL_ELF;
        goto bad_elf_cleanup_data;
    }
    
    uint32_t vm_flags, perm;
    ph_end = ph + elf->e_phnum;
    
    for (; ph < ph_end; ph++) {

        // step3.4: find every program section headers
        if (ph->p_type != ELF_PT_LOAD) {
            continue ;
        }
        if (ph->p_filesz > ph->p_memsz) {
            ret = -E_INVAL_ELF;
            goto bad_cleanup_mmap;
        }
        if (ph->p_filesz == 0) {
            continue ;
        }

        //step3.5: call mm_map fun to setup the new vma ( ph->p_vaddr, ph->p_memsz)
        vm_flags = 0, perm = PTE_U;
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
        if (vm_flags & VM_WRITE) perm |= PTE_W;

        if ((ret = kernel::vmm.mmMap(mm, ph->p_vaddr, ph->p_memsz, vm_flags, nullptr)) != 0) {
            goto bad_cleanup_mmap;
        }
        uchar8_t *from = binary + ph->p_offset;
        uint32_t off, size;
        uptr32_t start = ph->p_vaddr, end, la = Utils::roundDown(start, PGSIZE);

        ret = -E_NO_MEM;

        // step3.6: alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
        end = ph->p_vaddr + ph->p_filesz;

        // step3.6.1 copy TEXT/DATA section of bianry program
        while (start < end) {
            if ((pnode = kernel::pmm.allocPageAndMap(mm->data.pdt, la, perm)) == nullptr) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            
            Utils::memcpy(from, (void *)(kernel::pmm.pnodeToKernelLAD(pnode) + off), size);
            start += size, from += size;
            
        }

        // step3.6.2: build BSS section of binary program
        end = ph->p_vaddr + ph->p_memsz;
        if (start < la) {
            /* ph->p_memsz == ph->p_filesz */
            if (start == end) {
                continue ;
            }
            off = start + PGSIZE - la, size = PGSIZE - off;
            if (end < la) {
                size -= la - end;
            }
            Utils::memset((void *)(kernel::pmm.pnodeToKernelLAD(pnode) + off), 0, size);
            start += size;
            assert((end < la && start == end) || (end >= la && start == la));
        }

        while (start < end) {
            if ((pnode = kernel::pmm.allocPageAndMap(mm->data.pdt, la, perm)) == nullptr) {
                goto bad_cleanup_mmap;
            }
            off = start - la, size = PGSIZE - off, la += PGSIZE;
            if (end < la) {
                size -= la - end;
            }
            Utils::memset((void *)(kernel::pmm.pnodeToKernelLAD(pnode) + off), 0, size);
            start += size;
        }
    }

    // step4: build user stack memory
    vm_flags = VM_READ | VM_WRITE | VM_STACK;
    if ((ret = kernel::vmm.mmMap(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, nullptr)) != 0) {
        goto bad_cleanup_mmap;
    }

    assert(kernel::pmm.allocPageAndMap(mm->data.pdt, USTACKTOP - PGSIZE , PTE_USER) != nullptr);
    assert(kernel::pmm.allocPageAndMap(mm->data.pdt, USTACKTOP - 2 * PGSIZE , PTE_USER) != nullptr);
    assert(kernel::pmm.allocPageAndMap(mm->data.pdt, USTACKTOP - 3 * PGSIZE , PTE_USER) != nullptr);
    assert(kernel::pmm.allocPageAndMap(mm->data.pdt, USTACKTOP - 4 * PGSIZE , PTE_USER) != nullptr);
    
    // step5: set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
    mm->data.mm_share++;
    current->data.value.mm = mm;
    current->data.value.cr3 = kernel::pmm.kAdToPhyAD((uptr32_t)(mm->data.pdt));
    setCR3(current->data.value.cr3);

    // step6: setup trapframe for user environment
    tf = current->data.value.tf;

    kernel::stdio::out.write("\n user program pdt = ");
    kernel::stdio::out.writeValue((uint32_t)mm->data.pdt);
    kernel::stdio::out.flush();

    // this exception due to DEBUGPRINT() general 
    Utils::memset(tf, 0, sizeof(Trap::TrapFrame));

    /* step7: init trapframe 
     * should set tf_cs,tf_ds,tf_es,tf_ss,tf_esp,tf_eip,tf_eflags
     * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
     *          tf_cs should be USER_CS segment (see memlayout.h)
     *          tf_ds=tf_es=tf_ss should be USER_DS segment
     *          tf_esp should be the top addr of user stack (USTACKTOP)
     *          tf_eip should be the entry point of this binary program (elf->e_entry)
     *          tf_eflags should be set to enable computer to produce Interrupt
     */
    tf->tf_cs = USER_CS;
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
    tf->tf_esp = USTACKTOP;
    tf->tf_eip = elf->e_entry;
    tf->tf_eflags = FL_IF;

    ret = 0;

out:
    return ret;

bad_cleanup_mmap:
    kernel::vmm.exitMmMap(mm);

bad_elf_cleanup_data:
    releasePDT(mm->data);

bad_cleanup_mm:
    kernel::vmm.mmDestroy(mm);

bad_mm:
    goto out;
}

// set_links - set the relation links of process
void PM::setRelation(Process *proc) {
    proc->data.value.yptr = nullptr;
    if ((proc->data.value.optr = (proc->data.value.parent)->data.value.cptr) != nullptr) {
        BREAKPOINT("66666666");
        (proc->data.value.optr)->data.value.yptr = proc;
    }
    (proc->data.value.parent)->data.value.cptr = proc;
}

// clean relation & remove hashList
void PM::cleanRelation(Process *proc) {
    procList.remove(proc->data.value.pid, proc);
    if (proc->data.value.optr != nullptr) {
        proc->data.value.optr->data.value.yptr = proc->data.value.yptr;
    }
    if (proc->data.value.yptr != nullptr) {
        proc->data.value.yptr->data.value.optr = proc->data.value.optr;
    }
    else {
       proc->data.value.parent->data.value.cptr = proc->data.value.optr;
    }
}

const PM::PCB & PM::getInitProc() {
    return initProc->data.value;
}

uint32_t PM::getProcNum() {
    return procList.size();
}      