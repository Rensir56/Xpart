#include "printk.h"

extern void test();

int start_kernel(int x) {
    printk("%d", x);
    printk(" ZJU Computer System III\n");
    test(); // DO NOT DELETE !!!
    return 0;
}
