/*
 * @Author: SPeak Shen 
 * @Date: 2020-04-28 00:19:41 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-28 19:04:43
 */

#include <syscall.h>
#include <global.h>
#include <unistd.h>
#include <kdebug.h>

SysCall::SysCall() {
    
    sysCalls[SYS_exit] = &SysCall::exit;
    sysCalls[SYS_fork] = &SysCall::fork;
    sysCalls[SYS_wait] = &SysCall::wait;
    sysCalls[SYS_exec] = &SysCall::exec;
    sysCalls[SYS_yield] = &SysCall::yield;
    sysCalls[SYS_kill] = &SysCall::kill;

    sysCalls[SYS_getPid] = &SysCall::getPid;
    sysCalls[SYS_putChar] = &SysCall::putChar;
    sysCalls[SYS_PDT] =  &SysCall::PDT;

    NUM_SYSCALLS = 32;
}

void SysCall::syscall() {
    DEBUGPRINT("SysCall::syscall()");
    auto tf = kernel::pm.current->data.value.tf;

    uint32_t arg[5];
    uint32_t num = tf->tf_regs.reg_eax;
    if (num >= 0 && num < NUM_SYSCALLS) {
        if (sysCalls[num] != nullptr) {
            arg[0] = tf->tf_regs.reg_edx;
            arg[1] = tf->tf_regs.reg_ecx;
            arg[2] = tf->tf_regs.reg_ebx;
            arg[3] = tf->tf_regs.reg_edi;
            arg[4] = tf->tf_regs.reg_esi;
            // call func by point-function (this->*funcName)(args)
            tf->tf_regs.reg_eax = (this->*(sysCalls[num]))(arg);
        }
    } else {
        DEBUGPRINT("undefined syscall ");
        kernel::stdio::out.writeValue(num);
        kernel::stdio::out.write(" pid ");
        kernel::stdio::out.writeValue(kernel::pm.current->data.value.pid);
        kernel::stdio::out.write(" name ");
        kernel::stdio::out.write(kernel::pm.current->data.value.name);
        kernel::stdio::out.flush();
    }
}

int SysCall::exit(uint32_t arg[]) {
    int error_code = (int)(arg[0]);
    return kernel::pm.doExit(error_code);
}

int SysCall::fork(uint32_t arg[]) {
    auto tf = kernel::pm.current->data.value.tf;
    uptr32_t stack = tf->tf_esp;
    return kernel::pm.doFork(0, stack, tf);
}

int SysCall::wait(uint32_t arg[]) {
    int pid = (int)(arg[0]);
    int *store = (int *)arg[1];
    return kernel::pm.doWait(pid, store);
}

int SysCall::exec(uint32_t arg[]) {
    DEBUGPRINT("SysCall::exec");
    
    String name = (const char *)arg[0];
    uint32_t len = (uint32_t)arg[1];
    uchar8_t *binary = (uchar8_t *)arg[2];
    uint32_t size = (uint32_t)arg[3];

    return kernel::pm.doExecve(name, len, binary, size);
}

int SysCall::yield(uint32_t arg[]) {
    return kernel::pm.doYield();
}

int SysCall::kill(uint32_t arg[]) {
    uint32_t pid = arg[0];
    return kernel::pm.doKill(pid);
}

int SysCall::getPid(uint32_t arg[]) {
    return kernel::pm.current->data.value.pid;
}

int SysCall::putChar(uint32_t arg[]) {
    char c = (int)arg[0];
    kernel::stdio::out.write(c);
    return 0;
}

int SysCall::PDT(uint32_t arg[]) {
    BREAKPOINT("syscall->PDT no implement");
    return 0;
}