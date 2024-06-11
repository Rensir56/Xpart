#include "sbi.h"
unsigned long TIMECLOCK = 10000000;

unsigned long get_cycles() {
    unsigned long mtime;
    asm volatile (
      "rdtime a0\n"
      "mv %[mtime], a0"
      : [mtime] "=r" (mtime)
      : 
      : "a0", "memory"
  );
  return mtime;
}

void clock_set_next_event() {
    unsigned long next_time = get_cycles() + TIMECLOCK;
    sbi_set_timer(next_time);
} 