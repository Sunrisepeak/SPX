#include <slib>
#include <syscall>

namespace slib {

    void exit(int error_code) {
        SystemCall::exit(error_code);
        while (1);
    }

    int fork() {
        return SystemCall::fork();
    }

    int wait() {
        return SystemCall::wait(0, nullptr);
    }

    int waitpid(int pid, int *store) {
        return SystemCall::wait(pid, store);
    }

    void yield() {
        SystemCall::yield();
    }

    int kill(int pid) {
        return SystemCall::kill(pid);
    }

    int getPid() {
        return SystemCall::getPid();
    }

    void putChar(int c) {
        SystemCall::putChar(c);
    }

};


