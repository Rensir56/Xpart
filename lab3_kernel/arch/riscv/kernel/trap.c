#include "printk.h" 
#include "clock.h"
#include "proc.h"

void trap_handler(unsigned long scause, unsigned long sepc) {
    unsigned long interrupt = scause >> 63;
    unsigned long exception = scause & 0x7FFFFFFFFFFFFFFF;
    if (interrupt == 1 && exception == 5){
        // printk("[S] Supervisor Mode Timer Interrupt\n");
        clock_set_next_event();
        do_timer();
        return;
    }
    // printk("scause = %lx, sepc = %llx\n", scause, sepc);
}