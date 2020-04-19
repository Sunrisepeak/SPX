#ifndef _THREAD_H
#define _THREAD_H

#include <defs.h>
#include <memlayout.h>
#include <trap.h>
#include <string.h>

class Thread {
    public:
        // thread control block
        struct TCB {
            uint32_t tid;       // thread id

        };

        void init();
        

        

};

#endif