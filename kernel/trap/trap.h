#ifndef _TRAP_H
#define _TRAP_H

/* *
 * These are arbitrarily chosen, but with care not to overlap
 * processor defined exceptions or interrupt vectors.
 * */
#define T_SWITCH_TOU                120    // user/kernel switch
#define T_SWITCH_TOK                121    // user/kernel switch

/* Hardware IRQ numbers. We receive these as (IRQ_OFFSET + IRQ_xx) */
#define IRQ_OFFSET                32    // IRQ 0 corresponds to int IRQ_OFFSET

#define IRQ_TIMER                0
#define IRQ_KBD                    1
#define IRQ_COM1                4
#define IRQ_IDE1                14
#define IRQ_IDE2                15
#define IRQ_ERROR                19
#define IRQ_SPURIOUS                31


class Trap {
    public:
        static void trap();
};

#endif