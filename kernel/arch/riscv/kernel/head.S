.extern start_kernel

.section .text.init
.globl _start
.globl _end
_start:
  la sp, boot_stack_top
  addi sp, sp, 0x400
  addi sp, sp, 0x400
  addi sp, sp, 0x400
  addi sp, sp, 0x400
  la t0, _traps
  csrw stvec, t0
  csrr t0, sie
  ori t0, t0, 0x20
  csrw sie, t0
  li a0, 0x100000

  xor a7, a7, a7
  xor a6, a6, a6
  xor a5, a5, a5
  xor a4, a4, a4
  xor a3, a3, a3
  xor a2, a2, a2
  xor a1, a1, a1
  ecall

  csrr t0, sstatus
  ori t0, t0, 1<<1
  csrw sstatus, t0

  call mm_init
  call task_init

  li a0, 2022
  j start_kernel

.section .bss
  .space 0x1000

boot_stack_top:
.align 4
_end:
