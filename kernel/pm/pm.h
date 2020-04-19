#ifndef _PROCESS_H
#define _PROCESS_H

#include <defs.h>
#include <trap.h>
#include <vmm.h>
#include <thread.h>
#include <string.h>
#include <linker.hpp>
#include <hashlist.hpp>

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
            uint32_t pid;                               // Process ID
            String name;                                // Process name
            int runs;                                   // the running times of Proces
            uptr32_t kStack;                            // Process kernel stack
            bool needResched;                           // bool value: need to be rescheduled to release CPU?
            Process *parent;                            // the parent process
            VMM::MM *mm;                                // Process's memory management field
            Context context;                            // Switch here to run process
            Trap::TrapFrame *tf;                        // Trap frame for current interrupt
            uptr32_t cr3;                               // CR3 register: the base addr of Page Directroy Table(PDT)
            uint32_t flags;                             // Process flag
        };

        Process *current;
        Process *idleProc;

        HashList<PCB> procList;

        static int initMain(void *arg);

        void init();

        // allocPCB - alloc a PCB init all fields of PCB
        Process * allocProc();

        int kernelThread(int (*fn)(void *), const void *arg, uint32_t clone_flags);

        int doFork(uint32_t clone_flags, uptr32_t stack, Trap::TrapFrame *tf);

        int allocKernelStack(PCB &pcb);

        void freeKernelStack(PCB &pcb);

        int copyMm(uint32_t clone_flags, PCB &pcb);

        uint32_t generatePid();

        void copyThread(PCB &tcb, uptr32_t esp, Trap::TrapFrame *tf);

        void doExit(int error_code);

        void cpuIdle();

        void procRun(Process *proc);

    private:
        
        PCB pcb;
        
        Process *initProc;
        

};

#endif