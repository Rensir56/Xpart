#include "print.h"
#include "sbi.h"
#include "types.h"

extern void test();

int start_kernel() 
{
    // char *arg0; unsigned arg1;
    // char *argu;
    // __asm__ volatile( "mv %[arg0], a0\n"  "addiw a1, a1, 444\n" "mv %[arg1], a1\n":[arg0]"=r"(arg0),[arg1]"=r"(arg1)::"memory");
    // printk("%d", 2022);
    printk(" ZJU Computer System II\n");
    // puts(arg0);
    // puti(arg1);
    test(); // DO NOT DELETE !!!

	return 0;
}
