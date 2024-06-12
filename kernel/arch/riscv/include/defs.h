#ifndef _DEFS_H
#define _DEFS_H

#define PHY_START 0x0000000080000000
#define PHY_SIZE  4 * 1024 * 1024//128 * 1024 * 1024 // 128MB， QEMU 默认内存大小 
#define PHY_END   (PHY_START + PHY_SIZE)

#define PGSIZE 0x1000 // 4KB
#define PGROUNDUP(addr) ((addr + PGSIZE - 1) & (~(PGSIZE - 1)))
#define PGROUNDDOWN(addr) (addr & (~(PGSIZE - 1)))

#define OPENSBI_SIZE (0x200000)

#define VM_START (0xffffffe000000000)
#define VM_END   (0xffffffff00000000)
#define VM_SIZE  (VM_END - VM_START)

#define PA2VA_OFFSET (VM_START - PHY_START)

// 取出虚拟地址中的三个虚拟页号
#define VPN0(va) (((uint64)(va) >> 12) & 0x1ff)
#define VPN1(va) (((uint64)(va) >> 21) & 0x1ff)
#define VPN2(va) (((uint64)(va) >> 30) & 0x1ff)
// 页表项中末尾的权限位
#define PTE_V 0x001
#define PTE_R 0x002
#define PTE_W 0x004
#define PTE_X 0x008
#define PTE_U 0x010
#define PTE_G 0x020
#define PTE_A 0x040
#define PTE_D 0x080

#include "types.h"

#define csr_read(csr)                       \
({                                          \
    register uint64 __v;                    \
    asm volatile ("csrr %0, " #csr          \
                    : "=r" (__v) :          \
                    : "memory");            \
    __v;                                    \
})

#define csr_write(csr, val)                         \
({                                                  \
    uint64 __v = (uint64)(val);                     \
    asm volatile ("csrw " #csr ", %0"               \
                    : : "r" (__v)                   \
                    : "memory");                    \
})

#endif
