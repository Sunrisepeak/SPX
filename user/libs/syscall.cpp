#include <syscall>
#include <stdarg.h>
#include <unistd.h>

#define MAX_ARGS            5

namespace SystemCall {

    static inline int sysCall(int num, ...) {
        va_list ap;
        va_start(ap, num);
        uint32_t a[MAX_ARGS];
        int i, ret;
        for (i = 0; i < MAX_ARGS; i ++) {
            a[i] = va_arg(ap, uint32_t);
        }
        va_end(ap);

        asm volatile (
            "int %1;"
            : "=a" (ret)
            : "i" (T_SYSCALL),
            "a" (num),
            "d" (a[0]),
            "c" (a[1]),
            "b" (a[2]),
            "D" (a[3]),
            "S" (a[4])
            : "cc", "memory");
        return ret;
    }

    int exit(int error_code) {
        return sysCall(SYS_exit, error_code);
    }

    int fork(void) {
        return sysCall(SYS_fork);
    }

    int wait(int pid, int *store) {
        return sysCall(SYS_wait, pid, store);
    }

    int yield(void) {
        return sysCall(SYS_yield);
    }

    int kill(int pid) {
        return sysCall(SYS_kill, pid);
    }

    int getPid() {
        return sysCall(SYS_getPid);
    }

    int putChar(int c) {
        return sysCall(SYS_putChar, c);
    }

};

