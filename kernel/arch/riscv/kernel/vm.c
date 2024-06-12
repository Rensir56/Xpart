// arch/riscv/kernel/vm.c
#include "defs.h"
#include "string.h"
#include "mm.h"
#include "printk.h"

/* early_pgtbl: 用于 setup_vm 进行 1GB 的 映射。 */
unsigned long early_pgtbl[512] __attribute__((__aligned__(0x1000)));
/* swapper_pg_dir: kernel pagetable 根目录， 在 setup_vm_final 进行映射。 */
unsigned long  swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm(void)
{
    // 初始化early_pgtbl
    memset(early_pgtbl, 0x0, PGSIZE);

    // 定义pa与va
    uint64 pa = PHY_START, va = VM_START;

    // 等值映射 (PA == VA) 此处pa = va，所以将pa视为va，用pa计算index
    // 1. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
    // high bit 可以忽略
    // 中间9 bit 作为 early_pgtbl 的 index
    int index = VPN2(pa);
    // 低 30 bit 作为 页内偏移 这里注意到 30 = 9 + 9 + 12， 即我们只使用根页表， 根页表的每个 entry 都对应 1GB 的区域。
    early_pgtbl[index] = (((pa >> 30) & 0x3ffffff) << 28);
    // 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    early_pgtbl[index] = early_pgtbl[index] | PTE_V | PTE_R | PTE_W | PTE_X | PTE_A | PTE_D;

    // 映射至高地址 (PA + PV2VA_OFFSET == VA)
    // 1. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
    // high bit 可以忽略
    // 中间9 bit 作为 early_pgtbl 的 index
    index = VPN2(va);
    // 低 30 bit 作为 页内偏移 这里注意到 30 = 9 + 9 + 12， 即我们只使用根页表， 根页表的每个 entry 都对应 1GB 的区域。
    early_pgtbl[index] = (((pa >> 30) & 0x3ffffff) << 28);
    // 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    early_pgtbl[index] = early_pgtbl[index] | PTE_V | PTE_R | PTE_W | PTE_X | PTE_A | PTE_D;
}

extern char _stext[];
extern char _srodata[];
extern char _sdata[];

/* 创建多级页表映射关系 */
void create_mapping(uint64 *pgtbl, uint64 va, uint64 pa, uint64 sz, uint64 perm) {
    /*
    pgtbl 为根页表的基地址
    va, pa 为需要映射的虚拟地址、物理地址
    sz 为映射的大小
    perm 为映射的读写权限

    将给定的一段虚拟内存映射到物理内存上
    物理内存需要分页
    创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
    可以使用 V bit 来判断页表项是否存在
    */
    uint64 va_end = va + sz;
    uint64 *cur_tbl, cur_vpn, cur_pte;
    while (va < va_end) {
        // 第一级
        cur_tbl = pgtbl;
        cur_vpn = VPN2(va);
        cur_pte = *(cur_tbl + cur_vpn);
        if ((cur_pte & PTE_V) == 0) {
            uint64 new_page_phy = (uint64)kalloc() - PA2VA_OFFSET;
            cur_pte = ((uint64)new_page_phy >> 12) << 10 | PTE_V;
            *(cur_tbl + cur_vpn) = cur_pte;
        }
        // 第二级
        cur_tbl = (uint64*)(((cur_pte >> 10) << 12) + PA2VA_OFFSET);
        cur_vpn = VPN1(va);
        cur_pte = *(cur_tbl + cur_vpn);
        if ((cur_pte & PTE_V) == 0) {
            uint64 new_page_phy = (uint64)kalloc() - PA2VA_OFFSET;
            cur_pte = ((uint64)new_page_phy >> 12) << 10 | PTE_V;
            *(cur_tbl + cur_vpn) = cur_pte;
        }
        // 第三级
        cur_tbl = (uint64*)(((cur_pte >> 10) << 12) + PA2VA_OFFSET);
        cur_vpn = VPN0(va);
        cur_pte = ((pa >> 12) << 10) | perm | PTE_V;
        *(cur_tbl + cur_vpn) = cur_pte;

        va += PGSIZE;
        pa += PGSIZE;
    }
}

void setup_vm_final(void) {
    memset(swapper_pg_dir, 0x0, PGSIZE);

    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    uint64 va = VM_START + OPENSBI_SIZE;
    uint64 pa = PHY_START + OPENSBI_SIZE;
    create_mapping(swapper_pg_dir, va, pa, _srodata - _stext, PTE_X | PTE_R | PTE_V | PTE_A | PTE_D);

    // mapping kernel rodata -|-|R|V
    va += _srodata - _stext;
    pa += _srodata - _stext;
    create_mapping(swapper_pg_dir, va, pa, _sdata - _srodata, PTE_R | PTE_V | PTE_A | PTE_D);

    // mapping other memory -|W|R|V
    va += _sdata - _srodata;
    pa += _sdata - _srodata;
    create_mapping(swapper_pg_dir, va, pa, PHY_SIZE - (_sdata - _stext), PTE_W | PTE_R | PTE_V | PTE_A | PTE_D);
  
    // set satp with swapper_pg_dir
    uint64 _satp = (((uint64)(swapper_pg_dir) - PA2VA_OFFSET) >> 12) | (8L << 60);
    csr_write(satp, _satp);
    printk("set satp to %lx\n", _satp);

    // flush TLB
    asm volatile("sfence.vma zero, zero");

    // flush icache
    asm volatile("fence.i");
    return;
}
