#ifndef _SCHEDULE_H_
#define _SCHEDULE_H_

#include <defs.h>
#include <pm.h>

class Schedule {

    public:

        void wakeupProc(PM::PCB &pcb);

        void schedule();

};

#endif 
