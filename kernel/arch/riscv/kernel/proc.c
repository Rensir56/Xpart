//arch/riscv/kernel/proc.c
#include"proc.h"
#include"defs.h"
#include"math.h"


extern void __dummy();

struct task_struct* idle;           // idle process
struct task_struct* current;        // 指向当前运行线程的 `task_struct`
struct task_struct* task[NR_TASKS]; // 线程数组，所有的线程都保存在此

void dummy(){
uint64 MOD = 1000000007;
uint64 auto_inc_local_var = 0;
int last_counter = -1; // 记录上一个counter
int last_last_counter = -1; // 记录上上个counter
while(1) {
    if (last_counter == -1 || current->counter != last_counter) {
        last_last_counter = last_counter;
        last_counter = current->counter;
        auto_inc_local_var = int_mod((auto_inc_local_var + 1) , MOD);
        printk("[PID = %d] is running. auto_inc_local_var = %d\n", current->pid, auto_inc_local_var); 
    } else if((last_last_counter == 0 || last_last_counter == -1) && last_counter == 1) { // counter恒为1的情况
        // 这里比较 tricky，不要求理解。
        last_counter = 0; 
        current->counter = 0;
    }
}
}


void task_init() {
    // 1. 调用 kalloc() 为 idle 分配一个物理页
    // 2. 设置 state 为 TASK_RUNNING;
    // 3. 由于 idle 不参与调度 可以将其 counter / priority 设置为 0
    // 4. 设置 idle 的 pid 为 0
    // 5. 将 current 和 task[0] 指向 idle
    idle = (struct task_struct*) kalloc();
    idle->state = TASK_RUNNING;
    idle->counter = 0;
    idle->priority = 0;
    idle->pid = 0;

    current = idle;
    task[0] = idle;


    /* YOUR CODE HERE */

    // 1. 参考 idle 的设置, 为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    // 2. 其中每个线程的 state 为 TASK_RUNNING, counter 为 0, priority 使用 rand() 来设置, pid 为该线程在线程数组中的下标。
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 `thread_struct` 中的 `ra` 和 `sp`, 
    // 4. 其中 `ra` 设置为 __dummy （见 4.3.2）的地址， `sp` 设置为 该线程申请的物理页的高地址
    int i = 0;
    int a[10];
    
    for(i = 1;i < NR_TASKS; i++){
        struct task_struct * temp = (struct task_struct *)kalloc();
        temp->state = TASK_RUNNING;
        temp->counter = 0;
        temp->priority = (uint64)int_mod(i+2,(PRIORITY_MAX-PRIORITY_MIN+1))+PRIORITY_MIN;
        temp->pid = i;
        (temp->thread).ra = (uint64)__dummy;
        (temp->thread).sp = (uint64)temp+PGSIZE;
        task[i] = temp;
    }
    
    
    /* YOUR CODE HERE */

    printk("...proc_init done!\n");
}

extern void __switch_to(struct task_struct* prev, struct task_struct* next);

void switch_to(struct task_struct* next) {
    if (next->pid != current->pid) {
        printk("\nswitch to [PID = %d PRIORITY = %d COUNTER = %d]\n", next->pid, next->priority, next->counter);
        struct task_struct* prev = current;
        current = next; // 切换
        __switch_to(prev, next);
    }
}

void do_timer(){
    if(current == idle || current -> counter == 0) schedule();
    else{
        current->counter--;
        if(current->counter == 0) schedule();
    }
}

void schedule(){
    int i , next, c;
    struct task_struct ** p;
    while(1){
        c = -1;
        next = 0;
        i = NR_TASKS;
        p = &task[NR_TASKS];
        while(--i){
            if(!*--p) continue;
            if((*p)->state == TASK_RUNNING && (signed)(*p)->counter > c){
                c = (*p)->counter;
                next = i;
            }
        }
        if(c) break;
        for (int j = 1; j < NR_TASKS; ++j) {
            task[j]->counter = task[j]->priority;
            if (j == 1) printk("\n");
            printk("SET [PID = %d PRIORITY = %d COUNTER = %d]\n", task[j]->pid, task[j]->priority, task[j]->counter);
        }
        
    }
    switch_to(task[next]);
}

