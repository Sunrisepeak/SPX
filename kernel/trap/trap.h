#ifndef _TRAP_H
#define _TRAP_H

/* *
 * These are arbitrarily chosen, but with care not to overlap
 * processor defined exceptions or interrupt vectors.
 * */
#define T_SWITCH_TOU                120    // user/kernel switch
#define T_SWITCH_TOK                121    // user/kernel switch


class Trap {
    public:
        static void trap();
};

#endif