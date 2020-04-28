#ifndef _PROCESS_H
#define _PROCESS_H

#include <defs.h>
#include <trap.h>
#include <vmm.h>
#include <thread.h>
#include <string.h>
#include <linker.hpp>
#include <hashlist.hpp>

#define PF_EXITING                  0x00000001      // getting shutdown

#define WT_CHILD                    (0x00000001 | WT_INTERRUPTED)
#define WT_INTERRUPTED               0x80000000                    // the wait state could be interrupted

#define PROC_NAME_LEN               15
#define MAX_PROCESS                 4096
#define MAX_PID                     (MAX_PROCESS * 2)

/*  Process Management   */

class PM {

    public:

        struct PCB;

        using Process = HashList<PCB>::HashNode;

        enum class ProcState {
            PROC_UNINIT = 0,  // uninitialized
            PROC_SLEEPING,    // sleeping
            PROC_RUNNABLE,    // runnable(maybe running)
            PROC_ZOMBIE,      // almost dead, and wait parent proc to reclaim his resource
        };

        // register status [context]
        struct Context {
            uint32_t eip;
            uint32_t esp;
            uint32_t ebx;
            uint32_t ecx;
            uint32_t edx;
            uint32_t esi;
            uint32_t edi;
            uint32_t ebp;
        };

        // Process control block
        struct PCB {
            ProcState state;                            // Process state
            int pid;                                    // Process ID
            int runs;                                   // the running times of Proces
            uptr32_t kStack;                            // Process kernel stack
            bool needResched;                           // bool value: need to be rescheduled to release CPU?
            Process *parent;                            // the parent process
            Linker<VMM::MM>::DLNode *mm;                // Process's memory management field
            Context context;                            // Switch here to run process
            Trap::TrapFrame *tf;                        // Trap frame for current interrupt
            uptr32_t cr3;                               // CR3 register: the base addr of Page Directroy Table(PDT)
            uint32_t flags;                             // Process flag
            String name;                                // Process name
            int exit_code;                              // exit code (be sent to parent proc)
            uint32_t wait_state;                        // waiting state
            
            Process *cptr;                              // relations between processes
            Process *yptr;
            Process *optr;                
        };

        Process *current { nullptr };
        Process *idleProc { nullptr };

        HashList<PCB> procList;

        void init();

        // allocPCB - alloc a PCB init all fields of PCB
        Process * allocProc();

        int kernelThread(int (*fn)(void *), const void *arg, uint32_t clone_flags);

        int allocKernelStack(PCB &pcb);

        void freeKernelStack(PCB &pcb);

        int copyMm(uint32_t clone_flags, PCB &pcb);

        uint32_t generatePid();

        void copyThread(PCB &tcb, uptr32_t esp, Trap::TrapFrame *tf);

        void cpuIdle();

        void procRun(Process *proc);

        // alloc one page as PDT
        int setupPDT(VMM::MM &mm);

        // free the memory space of PDT
        void releasePDT(VMM::MM &mm);

        int copyMm(uint32_t clone_flags, Process *proc);

        // **************************** process op

        int doFork(uint32_t clone_flags, uptr32_t stack, Trap::TrapFrame *tf);

        int doExit(int error_code);

        int doYield();

        int doExecve(String &name, uint32_t len, uchar8_t *binary, uint32_t size);
        
        int doWait(uint32_t pid, int *code_store);
        
        int doKill(uint32_t pid);

        int loadCodeELF(uchar8_t *binary, uint32_t size);

        void setRelation(Process *proc);

        void cleanRelation(Process *proc);

        // 
        const PCB & getInitProc();

        uint32_t getProcNum();

    private:
        
        PCB pcb;
        
        Process *initProc;

};

#endif