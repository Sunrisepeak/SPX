/*
 * @Author: SPeak Shen 
 * @Date: 2020-04-28 00:19:51 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-28 22:08:34
 */

#ifndef _SYSCALL_H
#define _SYSCALL_H

#include <defs.h>

class SysCall {

    public:

        SysCall();

        void syscall();

        int exit(uint32_t arg[]);
        
        int fork(uint32_t arg[]);
        
        int wait(uint32_t arg[]);
        
        int exec(uint32_t arg[]);
        
        int yield(uint32_t arg[]);
        
        int kill(uint32_t arg[]);

        int getPid(uint32_t arg[]);

        //*****************

        int putChar(uint32_t arg[]);

        int PDT(uint32_t arg[]);

    private:

        int (SysCall::* sysCalls[32])(uint32_t arg[]);

        uint32_t NUM_SYSCALLS;

};

#endif /* !_SYSCALL_H__ */
