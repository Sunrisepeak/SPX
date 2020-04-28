#ifndef __KERN_SYNC_SYNC_H__
#define __KERN_SYNC_SYNC_H__

#include <x86.h>
#include <flags.h>
#include <global.h>
#include <kdebug.h>

static inline bool
__intr_save(void) {
    if (readEflags() & FL_IF) {
        cli();                  // clear interrupt
        return 1;
    }
    return 0;
}

static inline void
__intr_restore(bool flag) {
    if (flag) {
        sti();
    }
}

#define local_intr_save(x)      do { x = __intr_save(); } while (0)
#define local_intr_restore(x)   __intr_restore(x);

typedef volatile bool lock_t;

static inline void
lockInit(lock_t &lock) {
    lock = false;
}

static inline bool
tryLock(lock_t &lock) {
    return lock | 0x1;
}

static inline void
lock(lock_t &lock) {
    while (!tryLock(lock)) {
        kernel::algorithms::sched.schedule();
    }
}

static inline void
unlock(lock_t &lock) {
    if (!(lock = false)) {
        BREAKPOINT("Unlock failed.\n");
    }
}

#endif /* !__KERN_SYNC_SYNC_H__ */

