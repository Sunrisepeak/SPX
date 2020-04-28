#include <defs.h>
#include <global.h>
#include <assert.h>
#include <kdebug.h>
#include <string.h>
#include <unistd.h>

// kernel_execve - do SYS_exec syscall to exec a user program called by userMain kernel_thread
static int
kernel_execve(const char *name, uchar8_t *binary, uint32_t size) {
    String temp = name;
    int ret, len = temp.getLength();
    
    kernel::stdio::out.write(" size = ");
    kernel::stdio::out.writeValue(size);
    kernel::stdio::out.flush();

    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL), "0" (SYS_exec), "d" (name), "c" (len), "b" (binary), "D" (size)
        : "memory"
    );
    return ret;
}

#define __KERNEL_EXECVE(name, binary, size) ({                          \
            DEBUGPRINT("kernel_execve")                                 \
            kernel_execve(name, binary, (uint32_t)(size));              \
        })

// ld general stab __binary_obj_filename_size ... in asm file (by objdump)
#define KERNEL_EXECVE(x) ({                                             \
            extern uchar8_t _binary_obj_##x##_start[],       \
                _binary_obj_##x##_size[];                    \
            __KERNEL_EXECVE(#x, _binary_obj_##x##_start,     \
                            _binary_obj_##x##_size);         \
        })

#define __KERNEL_EXECVE2(x, xstart, xsize) ({                           \
            extern uchar8_t xstart[], xsize[];                          \
            __KERNEL_EXECVE(#x, xstart, (uint32_t)xsize);               \
        })

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)

// userMain - kernel thread used to exec a user program
static int userMain(void *arg) {
    DEBUGPRINT("userMain");
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(HelloWorld_user);
#endif
    BREAKPOINT("userMain execve failed.\n");
    return 0;
}


// init_main - the second kernel thread used to create userMain kernel threads
static int initMain(void *arg) {
    DEBUGPRINT("initMain");

    int pid = kernel::pm.kernelThread(userMain, nullptr, 0);

    if (pid <= 0) {
        BREAKPOINT("create userMain failed.\n");
    }

    while (kernel::pm.doWait(0, nullptr) == 0) {
        kernel::algorithms::sched.schedule();
    }

    BREAKPOINT("all user-mode processes have quit.\n");
    assert(
        kernel::pm.getInitProc().cptr == nullptr &&
        kernel::pm.getInitProc().yptr == nullptr &&
        kernel::pm.getInitProc().optr == nullptr
    );
    assert(kernel::pm.getProcNum() == 2);
    DEBUGPRINT("init check memory pass.\n");
    return 0;
}