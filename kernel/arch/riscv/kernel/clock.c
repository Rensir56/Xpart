// clock.c
#include"clock.h"
#include"sbi.h"


unsigned long TIMECLOCK = 0x1000000;

unsigned long get_cycles() {
    unsigned long timer;
    __asm__ volatile(
        "rdtime %[timer]\n"
        :[timer]"=r"(timer)
        :
        :"memory"
    );
    return timer;
}

void clock_set_next_event() {
    sbi_set_timer(TIMECLOCK);
} 


