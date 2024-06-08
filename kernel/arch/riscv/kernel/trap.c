#include<printk.h>
#include"clock.h"
// trap.c 

void trap_handler(unsigned long scause, unsigned long sepc) {
    if ((scause & 0x8000000000000000) && (scause & 0x7FFFFFFFFFFFFFFF) == 5) {
        printk("[S] Supervisor Mode Timer Interrupt\n");
        clock_set_next_event();
        do_timer();
    }
    return;
}