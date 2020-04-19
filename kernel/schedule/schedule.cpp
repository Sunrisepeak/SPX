#include <schedule.h>
#include <assert.h>
#include <sync.h>
#include <global.h>

void Schedule::wakeupProc(PM::PCB &pcb) {
    assert(
        pcb.state != PM::ProcState::PROC_ZOMBIE &&
        pcb.state != PM::ProcState::PROC_RUNNABLE
    );
    pcb.state = PM::ProcState::PROC_RUNNABLE;
}

void Schedule::schedule() {
    
    DEBUGPRINT("Schedule::schedule()");

    auto it = kernel::pm.procList.getHashListIterator();
    PM::Process *proc;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        while ((proc = it.nextHashNode()) != nullptr) {
            if (proc->data.value.state == PM::ProcState::PROC_RUNNABLE) {
                break;
            }
        }

        assert(proc != nullptr);
        
        if (proc == nullptr || proc->data.value.state != PM::ProcState::PROC_RUNNABLE) {
            proc = kernel::pm.idleProc;
        }

        proc->data.value.runs++;

        if (proc != kernel::pm.current) {
            kernel::pm.procRun(proc);
        }
    }
    local_intr_restore(intr_flag);
}