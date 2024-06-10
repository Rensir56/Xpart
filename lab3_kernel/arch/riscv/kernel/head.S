.extern start_kernel
	.section .text.init
	.globl _start
_start:
   # la sp, stack_top
   li sp, 0x80209000
    call setup_vm
    call relocate

    call mm_init
    call setup_vm_final
    call task_init
  # ------------------
    # set stvec = _traps 
    la a0, _traps
    csrw stvec, a0
  # ------------------
    # set sie[STIE] = 1
    li a0, 1 << 5       #STIE在sie的右数第5位
    csrs sie, a0
  # ------------------
    # set first time interrupt
    rdtime a0
    li t0, 10000000
    add a0, a0, t0
    call sbi_set_timer
  # ------------------
    # set sstatus[SIE] = 1
    csrs sstatus, 1 << 1 #SIE在sstatus的右1位
  # ------------------
    li a0, 2024
    j start_kernel

relocate:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)

    ###################### 
    #   YOUR CODE HERE   #
    li t0, 0xffffffdf80000000 # PA2VA_OFFSET
    add ra, ra, t0
    add sp, sp, t0
    ######################

    # set satp with early_pgtbl

    ###################### 
    #   YOUR CODE HERE   #
    li t1, 8
    slli t1, t1, 60     # mode 部分设置为 8
    la t0, early_pgtbl
    srli t0, t0, 12     # PPN 部分设置为页表物理地址右移 12 位
    or t0, t0, t1
    csrw satp, t0
    ######################

    # flush tlb
    sfence.vma zero, zero

    # flush icache
    fence.i

    ret

.section .bss.stack
.globl boot_stack
boot_stack:

.section .stack.entry
.globl stack_bottom
stack_bottom:
  .space 4096
.globl stack_top 
stack_top:
    # ------------------

