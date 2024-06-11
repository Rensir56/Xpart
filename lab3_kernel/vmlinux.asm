
../../vmlinux:     file format elf64-littleriscv


Disassembly of section .text:

ffffffe000200000 <_skernel>:
.extern start_kernel
	.section .text.init
	.globl _start
_start:
    # la sp, stack_top
    li sp, 0x80209000
ffffffe000200000:	00080137          	lui	sp,0x80
ffffffe000200004:	2091011b          	addiw	sp,sp,521 # 80209 <_skernel-0xffffffe00017fdf7>
ffffffe000200008:	00c11113          	slli	sp,sp,0xc
    call setup_vm
ffffffe00020000c:	395000ef          	jal	ra,ffffffe000200ba0 <setup_vm>
    call relocate
ffffffe000200010:	044000ef          	jal	ra,ffffffe000200054 <relocate>

# set stvec first
    la a0, _traps
ffffffe000200014:	00000517          	auipc	a0,0x0
ffffffe000200018:	07850513          	addi	a0,a0,120 # ffffffe00020008c <_traps>
    csrw stvec, a0
ffffffe00020001c:	10551073          	csrw	stvec,a0

    call mm_init
ffffffe000200020:	38c000ef          	jal	ra,ffffffe0002003ac <mm_init>
    call setup_vm_final
ffffffe000200024:	6e9000ef          	jal	ra,ffffffe000200f0c <setup_vm_final>
    call task_init
ffffffe000200028:	3c8000ef          	jal	ra,ffffffe0002003f0 <task_init>
  # ------------------
    # set stvec = _traps 

  # ------------------
    # set sie[STIE] = 1
    li a0, 1 << 5       #STIE在sie的右数第5位
ffffffe00020002c:	02000513          	li	a0,32
    csrs sie, a0
ffffffe000200030:	10452073          	csrs	sie,a0
  # ------------------
    # set first time interrupt
    rdtime a0
ffffffe000200034:	c0102573          	rdtime	a0
    li t0, 10000000
ffffffe000200038:	009892b7          	lui	t0,0x989
ffffffe00020003c:	6802829b          	addiw	t0,t0,1664 # 989680 <_skernel-0xffffffdfff876980>
    add a0, a0, t0
ffffffe000200040:	00550533          	add	a0,a0,t0
    call sbi_set_timer
ffffffe000200044:	245000ef          	jal	ra,ffffffe000200a88 <sbi_set_timer>
  # ------------------
    # set sstatus[SIE] = 1
    csrs sstatus, 1 << 1 #SIE在sstatus的右1位
ffffffe000200048:	10016073          	csrsi	sstatus,2
  # ------------------
    li a0, 2024
ffffffe00020004c:	7e800513          	li	a0,2024
    j start_kernel
ffffffe000200050:	0840106f          	j	ffffffe0002010d4 <start_kernel>

ffffffe000200054 <relocate>:
    # set ra = ra + PA2VA_OFFSET
    # set sp = sp + PA2VA_OFFSET (If you have set the sp before)

    ###################### 
    #   YOUR CODE HERE   #
    li t0, 0xffffffdf80000000 # PA2VA_OFFSET
ffffffe000200054:	fbf0029b          	addiw	t0,zero,-65
ffffffe000200058:	01f29293          	slli	t0,t0,0x1f
    add ra, ra, t0
ffffffe00020005c:	005080b3          	add	ra,ra,t0
    add sp, sp, t0
ffffffe000200060:	00510133          	add	sp,sp,t0

    # set satp with early_pgtbl

    ###################### 
    #   YOUR CODE HERE   #
    li t1, 8
ffffffe000200064:	00800313          	li	t1,8
    slli t1, t1, 60     # mode 部分设置为 8
ffffffe000200068:	03c31313          	slli	t1,t1,0x3c
    la t0, early_pgtbl
ffffffe00020006c:	00005297          	auipc	t0,0x5
ffffffe000200070:	f9428293          	addi	t0,t0,-108 # ffffffe000205000 <early_pgtbl>
    srli t0, t0, 12     # PPN 部分设置为页表物理地址右移 12 位
ffffffe000200074:	00c2d293          	srli	t0,t0,0xc
    or t0, t0, t1
ffffffe000200078:	0062e2b3          	or	t0,t0,t1
    csrw satp, t0
ffffffe00020007c:	18029073          	csrw	satp,t0
    ######################

    # flush tlb
    sfence.vma zero, zero
ffffffe000200080:	12000073          	sfence.vma

    # flush icache
    fence.i
ffffffe000200084:	0000100f          	fence.i

    ret
ffffffe000200088:	00008067          	ret

ffffffe00020008c <_traps>:
    .align 2
    .globl _traps 
_traps:
    # -----------
    # 1. save 32 registers and sepc to stack
    sd sp, -8(sp)
ffffffe00020008c:	fe213c23          	sd	sp,-8(sp)
    sd ra, -16(sp)
ffffffe000200090:	fe113823          	sd	ra,-16(sp)
    sd gp, -24(sp)
ffffffe000200094:	fe313423          	sd	gp,-24(sp)
    sd tp, -32(sp)
ffffffe000200098:	fe413023          	sd	tp,-32(sp)
    sd t0, -40(sp)
ffffffe00020009c:	fc513c23          	sd	t0,-40(sp)
    sd t1, -48(sp)
ffffffe0002000a0:	fc613823          	sd	t1,-48(sp)
    sd t2, -56(sp)
ffffffe0002000a4:	fc713423          	sd	t2,-56(sp)
    sd s0, -64(sp)
ffffffe0002000a8:	fc813023          	sd	s0,-64(sp)
    sd s1, -72(sp)
ffffffe0002000ac:	fa913c23          	sd	s1,-72(sp)
    sd a0, -80(sp)
ffffffe0002000b0:	faa13823          	sd	a0,-80(sp)
    sd a1, -88(sp)
ffffffe0002000b4:	fab13423          	sd	a1,-88(sp)
    sd a2, -96(sp)
ffffffe0002000b8:	fac13023          	sd	a2,-96(sp)
    sd a3, -104(sp)
ffffffe0002000bc:	f8d13c23          	sd	a3,-104(sp)
    sd a4, -112(sp)
ffffffe0002000c0:	f8e13823          	sd	a4,-112(sp)
    sd s5, -120(sp)
ffffffe0002000c4:	f9513423          	sd	s5,-120(sp)
    sd a6, -128(sp)
ffffffe0002000c8:	f9013023          	sd	a6,-128(sp)
    sd a7, -136(sp)
ffffffe0002000cc:	f7113c23          	sd	a7,-136(sp)
    sd s2, -144(sp)
ffffffe0002000d0:	f7213823          	sd	s2,-144(sp)
    sd s3, -152(sp)
ffffffe0002000d4:	f7313423          	sd	s3,-152(sp)
    sd s4, -160(sp)
ffffffe0002000d8:	f7413023          	sd	s4,-160(sp)
    sd s5, -168(sp)
ffffffe0002000dc:	f5513c23          	sd	s5,-168(sp)
    sd s6, -176(sp)
ffffffe0002000e0:	f5613823          	sd	s6,-176(sp)
    sd s7, -184(sp)
ffffffe0002000e4:	f5713423          	sd	s7,-184(sp)
    sd s8, -192(sp)
ffffffe0002000e8:	f5813023          	sd	s8,-192(sp)
    sd s9, -200(sp)
ffffffe0002000ec:	f3913c23          	sd	s9,-200(sp)
    sd s10, -208(sp)
ffffffe0002000f0:	f3a13823          	sd	s10,-208(sp)
    sd s11, -216(sp)
ffffffe0002000f4:	f3b13423          	sd	s11,-216(sp)
    sd t3, -224(sp)
ffffffe0002000f8:	f3c13023          	sd	t3,-224(sp)
    sd t4, -232(sp)
ffffffe0002000fc:	f1d13c23          	sd	t4,-232(sp)
    sd t5, -240(sp)
ffffffe000200100:	f1e13823          	sd	t5,-240(sp)
    sd t6, -248(sp)
ffffffe000200104:	f1f13423          	sd	t6,-248(sp)
    addi sp, sp, -248
ffffffe000200108:	f0810113          	addi	sp,sp,-248
    # -----------
    # 2. call trap_handler
    
    csrr a0, scause
ffffffe00020010c:	14202573          	csrr	a0,scause
    csrr a1, sepc
ffffffe000200110:	141025f3          	csrr	a1,sepc
    call trap_handler
ffffffe000200114:	221000ef          	jal	ra,ffffffe000200b34 <trap_handler>
#     beq a0, t1, _csrwrite
#     addi a1, a1, 4
# _csrwrite:
#     csrw sepc, a1

    ld t6, 0(sp)
ffffffe000200118:	00013f83          	ld	t6,0(sp)
    ld t5, 8(sp)
ffffffe00020011c:	00813f03          	ld	t5,8(sp)
    ld t4, 16(sp)
ffffffe000200120:	01013e83          	ld	t4,16(sp)
    ld t3, 24(sp)
ffffffe000200124:	01813e03          	ld	t3,24(sp)
    ld s11, 32(sp)
ffffffe000200128:	02013d83          	ld	s11,32(sp)
    ld s10, 40(sp)
ffffffe00020012c:	02813d03          	ld	s10,40(sp)
    ld s9, 48(sp)
ffffffe000200130:	03013c83          	ld	s9,48(sp)
    ld s8, 56(sp)
ffffffe000200134:	03813c03          	ld	s8,56(sp)
    ld s7, 64(sp)
ffffffe000200138:	04013b83          	ld	s7,64(sp)
    ld s6, 72(sp)
ffffffe00020013c:	04813b03          	ld	s6,72(sp)
    ld s5, 80(sp)
ffffffe000200140:	05013a83          	ld	s5,80(sp)
    ld s4, 88(sp)
ffffffe000200144:	05813a03          	ld	s4,88(sp)
    ld s3, 96(sp)
ffffffe000200148:	06013983          	ld	s3,96(sp)
    ld s2, 104(sp)
ffffffe00020014c:	06813903          	ld	s2,104(sp)
    ld a7, 112(sp)
ffffffe000200150:	07013883          	ld	a7,112(sp)
    ld a6, 120(sp)
ffffffe000200154:	07813803          	ld	a6,120(sp)
    ld a5, 128(sp)
ffffffe000200158:	08013783          	ld	a5,128(sp)
    ld a4, 136(sp)
ffffffe00020015c:	08813703          	ld	a4,136(sp)
    ld a3, 144(sp)
ffffffe000200160:	09013683          	ld	a3,144(sp)
    ld a2, 152(sp)
ffffffe000200164:	09813603          	ld	a2,152(sp)
    ld a1, 160(sp)
ffffffe000200168:	0a013583          	ld	a1,160(sp)
    ld a0, 168(sp)
ffffffe00020016c:	0a813503          	ld	a0,168(sp)
    ld s1, 176(sp)
ffffffe000200170:	0b013483          	ld	s1,176(sp)
    ld s0, 184(sp)
ffffffe000200174:	0b813403          	ld	s0,184(sp)
    ld t2, 192(sp)
ffffffe000200178:	0c013383          	ld	t2,192(sp)
    ld t1, 200(sp)
ffffffe00020017c:	0c813303          	ld	t1,200(sp)
    ld t0, 208(sp)
ffffffe000200180:	0d013283          	ld	t0,208(sp)
    ld tp, 216(sp)
ffffffe000200184:	0d813203          	ld	tp,216(sp)
    ld gp, 224(sp)
ffffffe000200188:	0e013183          	ld	gp,224(sp)
    ld ra, 232(sp)
ffffffe00020018c:	0e813083          	ld	ra,232(sp)
    ld sp, 240(sp)
ffffffe000200190:	0f013103          	ld	sp,240(sp)
    # -----------
    # 4. return from trap
    sret
ffffffe000200194:	10200073          	sret

ffffffe000200198 <__dummy>:
    # -----------
    .extern dummy
    .globl __dummy
__dummy:
    la t0, dummy
ffffffe000200198:	00000297          	auipc	t0,0x0
ffffffe00020019c:	3c828293          	addi	t0,t0,968 # ffffffe000200560 <dummy>
    csrw sepc, t0
ffffffe0002001a0:	14129073          	csrw	sepc,t0
    sret
ffffffe0002001a4:	10200073          	sret

ffffffe0002001a8 <__switch_to>:

    .globl __switch_to
__switch_to:
    sd ra, 40(a0)
ffffffe0002001a8:	02153423          	sd	ra,40(a0)
    sd sp, 48(a0)
ffffffe0002001ac:	02253823          	sd	sp,48(a0)
    sd s0, 56(a0)
ffffffe0002001b0:	02853c23          	sd	s0,56(a0)
    sd s1, 64(a0)
ffffffe0002001b4:	04953023          	sd	s1,64(a0)
    sd s2, 72(a0)
ffffffe0002001b8:	05253423          	sd	s2,72(a0)
    sd s3, 80(a0)
ffffffe0002001bc:	05353823          	sd	s3,80(a0)
    sd s4, 88(a0)
ffffffe0002001c0:	05453c23          	sd	s4,88(a0)
    sd s5, 96(a0)
ffffffe0002001c4:	07553023          	sd	s5,96(a0)
    sd s6, 104(a0)
ffffffe0002001c8:	07653423          	sd	s6,104(a0)
    sd s7, 112(a0)
ffffffe0002001cc:	07753823          	sd	s7,112(a0)
    sd s8, 120(a0)
ffffffe0002001d0:	07853c23          	sd	s8,120(a0)
    sd s9, 128(a0)
ffffffe0002001d4:	09953023          	sd	s9,128(a0)
    sd s10, 136(a0)
ffffffe0002001d8:	09a53423          	sd	s10,136(a0)
    sd s11, 144(a0)
ffffffe0002001dc:	09b53823          	sd	s11,144(a0)

    ld ra, 40(a1)
ffffffe0002001e0:	0285b083          	ld	ra,40(a1)
    ld sp, 48(a1)
ffffffe0002001e4:	0305b103          	ld	sp,48(a1)
    ld s0, 56(a1)
ffffffe0002001e8:	0385b403          	ld	s0,56(a1)
    ld s1, 64(a1)
ffffffe0002001ec:	0405b483          	ld	s1,64(a1)
    ld s2, 72(a1)
ffffffe0002001f0:	0485b903          	ld	s2,72(a1)
    ld s3, 80(a1)
ffffffe0002001f4:	0505b983          	ld	s3,80(a1)
    ld s4, 88(a1)
ffffffe0002001f8:	0585ba03          	ld	s4,88(a1)
    ld s5, 96(a1)
ffffffe0002001fc:	0605ba83          	ld	s5,96(a1)
    ld s6, 104(a1)
ffffffe000200200:	0685bb03          	ld	s6,104(a1)
    ld s7, 112(a1)
ffffffe000200204:	0705bb83          	ld	s7,112(a1)
    ld s8, 120(a1)
ffffffe000200208:	0785bc03          	ld	s8,120(a1)
    ld s9, 128(a1)
ffffffe00020020c:	0805bc83          	ld	s9,128(a1)
    ld s10, 136(a1)
ffffffe000200210:	0885bd03          	ld	s10,136(a1)
    ld s11, 144(a1)
ffffffe000200214:	0905bd83          	ld	s11,144(a1)

ffffffe000200218 <get_cycles>:
#include "sbi.h"
unsigned long TIMECLOCK = 10000000;

unsigned long get_cycles() {
ffffffe000200218:	fe010113          	addi	sp,sp,-32
ffffffe00020021c:	00813c23          	sd	s0,24(sp)
ffffffe000200220:	02010413          	addi	s0,sp,32
    unsigned long mtime;
    asm volatile (
ffffffe000200224:	c0102573          	rdtime	a0
ffffffe000200228:	00050793          	mv	a5,a0
ffffffe00020022c:	fef43423          	sd	a5,-24(s0)
      "mv %[mtime], a0"
      : [mtime] "=r" (mtime)
      : 
      : "a0", "memory"
  );
  return mtime;
ffffffe000200230:	fe843783          	ld	a5,-24(s0)
}
ffffffe000200234:	00078513          	mv	a0,a5
ffffffe000200238:	01813403          	ld	s0,24(sp)
ffffffe00020023c:	02010113          	addi	sp,sp,32
ffffffe000200240:	00008067          	ret

ffffffe000200244 <clock_set_next_event>:

void clock_set_next_event() {
ffffffe000200244:	fe010113          	addi	sp,sp,-32
ffffffe000200248:	00113c23          	sd	ra,24(sp)
ffffffe00020024c:	00813823          	sd	s0,16(sp)
ffffffe000200250:	02010413          	addi	s0,sp,32
    unsigned long next_time = get_cycles() + TIMECLOCK;
ffffffe000200254:	fc5ff0ef          	jal	ra,ffffffe000200218 <get_cycles>
ffffffe000200258:	00050713          	mv	a4,a0
ffffffe00020025c:	00003797          	auipc	a5,0x3
ffffffe000200260:	da478793          	addi	a5,a5,-604 # ffffffe000203000 <TIMECLOCK>
ffffffe000200264:	0007b783          	ld	a5,0(a5)
ffffffe000200268:	00f707b3          	add	a5,a4,a5
ffffffe00020026c:	fef43423          	sd	a5,-24(s0)
    sbi_set_timer(next_time);
ffffffe000200270:	fe843503          	ld	a0,-24(s0)
ffffffe000200274:	015000ef          	jal	ra,ffffffe000200a88 <sbi_set_timer>
ffffffe000200278:	00000013          	nop
ffffffe00020027c:	01813083          	ld	ra,24(sp)
ffffffe000200280:	01013403          	ld	s0,16(sp)
ffffffe000200284:	02010113          	addi	sp,sp,32
ffffffe000200288:	00008067          	ret

ffffffe00020028c <kalloc>:

struct {
    struct run *freelist;
} kmem;

uint64 kalloc() {
ffffffe00020028c:	fe010113          	addi	sp,sp,-32
ffffffe000200290:	00813c23          	sd	s0,24(sp)
ffffffe000200294:	02010413          	addi	s0,sp,32
    struct run *r;

    r = kmem.freelist;
ffffffe000200298:	00004797          	auipc	a5,0x4
ffffffe00020029c:	d6878793          	addi	a5,a5,-664 # ffffffe000204000 <kmem>
ffffffe0002002a0:	0007b783          	ld	a5,0(a5)
ffffffe0002002a4:	fef43423          	sd	a5,-24(s0)
    kmem.freelist = r->next;
ffffffe0002002a8:	fe843783          	ld	a5,-24(s0)
ffffffe0002002ac:	0007b703          	ld	a4,0(a5)
ffffffe0002002b0:	00004797          	auipc	a5,0x4
ffffffe0002002b4:	d5078793          	addi	a5,a5,-688 # ffffffe000204000 <kmem>
ffffffe0002002b8:	00e7b023          	sd	a4,0(a5)
    
    // memset((void *)r, 0x0, PGSIZE);
    return (uint64) r;
ffffffe0002002bc:	fe843783          	ld	a5,-24(s0)
}
ffffffe0002002c0:	00078513          	mv	a0,a5
ffffffe0002002c4:	01813403          	ld	s0,24(sp)
ffffffe0002002c8:	02010113          	addi	sp,sp,32
ffffffe0002002cc:	00008067          	ret

ffffffe0002002d0 <kfree>:

void kfree(uint64 addr) {
ffffffe0002002d0:	fd010113          	addi	sp,sp,-48
ffffffe0002002d4:	02813423          	sd	s0,40(sp)
ffffffe0002002d8:	03010413          	addi	s0,sp,48
ffffffe0002002dc:	fca43c23          	sd	a0,-40(s0)
    struct run *r;

    // PGSIZE align 
    addr = addr & ~(PGSIZE - 1);
ffffffe0002002e0:	fd843703          	ld	a4,-40(s0)
ffffffe0002002e4:	fffff7b7          	lui	a5,0xfffff
ffffffe0002002e8:	00f777b3          	and	a5,a4,a5
ffffffe0002002ec:	fcf43c23          	sd	a5,-40(s0)

    // memset((void *)addr, 0x0, (uint64)PGSIZE);

    r = (struct run *)addr;
ffffffe0002002f0:	fd843783          	ld	a5,-40(s0)
ffffffe0002002f4:	fef43423          	sd	a5,-24(s0)
    r->next = kmem.freelist;
ffffffe0002002f8:	00004797          	auipc	a5,0x4
ffffffe0002002fc:	d0878793          	addi	a5,a5,-760 # ffffffe000204000 <kmem>
ffffffe000200300:	0007b703          	ld	a4,0(a5)
ffffffe000200304:	fe843783          	ld	a5,-24(s0)
ffffffe000200308:	00e7b023          	sd	a4,0(a5)
    kmem.freelist = r;
ffffffe00020030c:	00004797          	auipc	a5,0x4
ffffffe000200310:	cf478793          	addi	a5,a5,-780 # ffffffe000204000 <kmem>
ffffffe000200314:	fe843703          	ld	a4,-24(s0)
ffffffe000200318:	00e7b023          	sd	a4,0(a5)

    return ;
ffffffe00020031c:	00000013          	nop
}
ffffffe000200320:	02813403          	ld	s0,40(sp)
ffffffe000200324:	03010113          	addi	sp,sp,48
ffffffe000200328:	00008067          	ret

ffffffe00020032c <kfreerange>:

void kfreerange(char *start, char *end) {
ffffffe00020032c:	fd010113          	addi	sp,sp,-48
ffffffe000200330:	02113423          	sd	ra,40(sp)
ffffffe000200334:	02813023          	sd	s0,32(sp)
ffffffe000200338:	03010413          	addi	s0,sp,48
ffffffe00020033c:	fca43c23          	sd	a0,-40(s0)
ffffffe000200340:	fcb43823          	sd	a1,-48(s0)
    char *addr = (char *)PGROUNDUP((uint64)start);
ffffffe000200344:	fd843703          	ld	a4,-40(s0)
ffffffe000200348:	000017b7          	lui	a5,0x1
ffffffe00020034c:	fff78793          	addi	a5,a5,-1 # fff <_skernel-0xffffffe0001ff001>
ffffffe000200350:	00f70733          	add	a4,a4,a5
ffffffe000200354:	fffff7b7          	lui	a5,0xfffff
ffffffe000200358:	00f777b3          	and	a5,a4,a5
ffffffe00020035c:	fef43423          	sd	a5,-24(s0)
    for (; (uint64)(addr) + PGSIZE <= (uint64)end; addr += PGSIZE) {
ffffffe000200360:	0200006f          	j	ffffffe000200380 <kfreerange+0x54>
        kfree((uint64)addr);
ffffffe000200364:	fe843783          	ld	a5,-24(s0)
ffffffe000200368:	00078513          	mv	a0,a5
ffffffe00020036c:	f65ff0ef          	jal	ra,ffffffe0002002d0 <kfree>
    for (; (uint64)(addr) + PGSIZE <= (uint64)end; addr += PGSIZE) {
ffffffe000200370:	fe843703          	ld	a4,-24(s0)
ffffffe000200374:	000017b7          	lui	a5,0x1
ffffffe000200378:	00f707b3          	add	a5,a4,a5
ffffffe00020037c:	fef43423          	sd	a5,-24(s0)
ffffffe000200380:	fe843703          	ld	a4,-24(s0)
ffffffe000200384:	000017b7          	lui	a5,0x1
ffffffe000200388:	00f70733          	add	a4,a4,a5
ffffffe00020038c:	fd043783          	ld	a5,-48(s0)
ffffffe000200390:	fce7fae3          	bgeu	a5,a4,ffffffe000200364 <kfreerange+0x38>
    }
}
ffffffe000200394:	00000013          	nop
ffffffe000200398:	00000013          	nop
ffffffe00020039c:	02813083          	ld	ra,40(sp)
ffffffe0002003a0:	02013403          	ld	s0,32(sp)
ffffffe0002003a4:	03010113          	addi	sp,sp,48
ffffffe0002003a8:	00008067          	ret

ffffffe0002003ac <mm_init>:

void mm_init(void) {
ffffffe0002003ac:	ff010113          	addi	sp,sp,-16
ffffffe0002003b0:	00113423          	sd	ra,8(sp)
ffffffe0002003b4:	00813023          	sd	s0,0(sp)
ffffffe0002003b8:	01010413          	addi	s0,sp,16
    kfreerange(_ekernel, (char *)(PHY_END+PA2VA_OFFSET));
ffffffe0002003bc:	f80017b7          	lui	a5,0xf8001
ffffffe0002003c0:	00a79593          	slli	a1,a5,0xa
ffffffe0002003c4:	00008517          	auipc	a0,0x8
ffffffe0002003c8:	c3c50513          	addi	a0,a0,-964 # ffffffe000208000 <_ekernel>
ffffffe0002003cc:	f61ff0ef          	jal	ra,ffffffe00020032c <kfreerange>
    //printk("...mm_init done!\n");
    printk("m\n");
ffffffe0002003d0:	00002517          	auipc	a0,0x2
ffffffe0002003d4:	c3050513          	addi	a0,a0,-976 # ffffffe000202000 <_srodata>
ffffffe0002003d8:	4d4010ef          	jal	ra,ffffffe0002018ac <printk>
}
ffffffe0002003dc:	00000013          	nop
ffffffe0002003e0:	00813083          	ld	ra,8(sp)
ffffffe0002003e4:	00013403          	ld	s0,0(sp)
ffffffe0002003e8:	01010113          	addi	sp,sp,16
ffffffe0002003ec:	00008067          	ret

ffffffe0002003f0 <task_init>:

struct task_struct* idle;           // idle process
struct task_struct* current;        // 指向当前运行线程的 `task_struct`
struct task_struct* task[NR_TASKS]; // 线程数组，所有的线程都保存在此

void task_init() {
ffffffe0002003f0:	fe010113          	addi	sp,sp,-32
ffffffe0002003f4:	00113c23          	sd	ra,24(sp)
ffffffe0002003f8:	00813823          	sd	s0,16(sp)
ffffffe0002003fc:	02010413          	addi	s0,sp,32
    // 1. 调用 kalloc() 为 idle 分配一个物理页
    idle = (struct task_struct*)kalloc();
ffffffe000200400:	e8dff0ef          	jal	ra,ffffffe00020028c <kalloc>
ffffffe000200404:	00050793          	mv	a5,a0
ffffffe000200408:	00078713          	mv	a4,a5
ffffffe00020040c:	00004797          	auipc	a5,0x4
ffffffe000200410:	bfc78793          	addi	a5,a5,-1028 # ffffffe000204008 <idle>
ffffffe000200414:	00e7b023          	sd	a4,0(a5)
    // 2. 设置 state 为 TASK_RUNNING;
    idle->state = TASK_RUNNING;
ffffffe000200418:	00004797          	auipc	a5,0x4
ffffffe00020041c:	bf078793          	addi	a5,a5,-1040 # ffffffe000204008 <idle>
ffffffe000200420:	0007b783          	ld	a5,0(a5)
ffffffe000200424:	0007b423          	sd	zero,8(a5)
    // 3. 由于 idle 不参与调度 可以将其 counter / priority 设置为 0
    idle->counter = 0;
ffffffe000200428:	00004797          	auipc	a5,0x4
ffffffe00020042c:	be078793          	addi	a5,a5,-1056 # ffffffe000204008 <idle>
ffffffe000200430:	0007b783          	ld	a5,0(a5)
ffffffe000200434:	0007b823          	sd	zero,16(a5)
    idle->priority = 0;
ffffffe000200438:	00004797          	auipc	a5,0x4
ffffffe00020043c:	bd078793          	addi	a5,a5,-1072 # ffffffe000204008 <idle>
ffffffe000200440:	0007b783          	ld	a5,0(a5)
ffffffe000200444:	0007bc23          	sd	zero,24(a5)
    // 4. 设置 idle 的 pid 为 0
    idle->pid = 0;
ffffffe000200448:	00004797          	auipc	a5,0x4
ffffffe00020044c:	bc078793          	addi	a5,a5,-1088 # ffffffe000204008 <idle>
ffffffe000200450:	0007b783          	ld	a5,0(a5)
ffffffe000200454:	0207b023          	sd	zero,32(a5)
    // 5. 将 current 和 task[0] 指向 idle
    current = idle;
ffffffe000200458:	00004797          	auipc	a5,0x4
ffffffe00020045c:	bb078793          	addi	a5,a5,-1104 # ffffffe000204008 <idle>
ffffffe000200460:	0007b703          	ld	a4,0(a5)
ffffffe000200464:	00004797          	auipc	a5,0x4
ffffffe000200468:	bac78793          	addi	a5,a5,-1108 # ffffffe000204010 <current>
ffffffe00020046c:	00e7b023          	sd	a4,0(a5)
    task[0] = idle;
ffffffe000200470:	00004797          	auipc	a5,0x4
ffffffe000200474:	b9878793          	addi	a5,a5,-1128 # ffffffe000204008 <idle>
ffffffe000200478:	0007b703          	ld	a4,0(a5)
ffffffe00020047c:	00004797          	auipc	a5,0x4
ffffffe000200480:	ba478793          	addi	a5,a5,-1116 # ffffffe000204020 <task>
ffffffe000200484:	00e7b023          	sd	a4,0(a5)

    // 1. 参考 idle 的设置, 为 task[1] ~ task[NR_TASKS - 1] 进行初始化
    // 2. 其中每个线程的 state 为 TASK_RUNNING, counter 为 0, priority 使用 rand() 来设置, pid 为该线程在线程数组中的下标。
    // 3. 为 task[1] ~ task[NR_TASKS - 1] 设置 `thread_struct` 中的 `ra` 和 `sp`, 
    // 4. 其中 `ra` 设置为 __dummy （见 4.3.2）的地址， `sp` 设置为 该线程申请的物理页的高地址
    for (int i = 1; i < NR_TASKS; i++) {
ffffffe000200488:	00100793          	li	a5,1
ffffffe00020048c:	fef42623          	sw	a5,-20(s0)
ffffffe000200490:	0a00006f          	j	ffffffe000200530 <task_init+0x140>
        struct task_struct* _task = (struct task_struct*)kalloc();
ffffffe000200494:	df9ff0ef          	jal	ra,ffffffe00020028c <kalloc>
ffffffe000200498:	00050793          	mv	a5,a0
ffffffe00020049c:	fef43023          	sd	a5,-32(s0)
        _task->state = TASK_RUNNING;
ffffffe0002004a0:	fe043783          	ld	a5,-32(s0)
ffffffe0002004a4:	0007b423          	sd	zero,8(a5)
        _task->counter = 0;
ffffffe0002004a8:	fe043783          	ld	a5,-32(s0)
ffffffe0002004ac:	0007b823          	sd	zero,16(a5)
        _task->priority = int_mod((uint64)i,(PRIORITY_MAX - PRIORITY_MIN + 1)) + PRIORITY_MIN;
ffffffe0002004b0:	fec42783          	lw	a5,-20(s0)
ffffffe0002004b4:	00500593          	li	a1,5
ffffffe0002004b8:	00078513          	mv	a0,a5
ffffffe0002004bc:	4c5000ef          	jal	ra,ffffffe000201180 <int_mod>
ffffffe0002004c0:	00050793          	mv	a5,a0
ffffffe0002004c4:	0017879b          	addiw	a5,a5,1
ffffffe0002004c8:	0007879b          	sext.w	a5,a5
ffffffe0002004cc:	00078713          	mv	a4,a5
ffffffe0002004d0:	fe043783          	ld	a5,-32(s0)
ffffffe0002004d4:	00e7bc23          	sd	a4,24(a5)
        _task->pid = i;
ffffffe0002004d8:	fec42703          	lw	a4,-20(s0)
ffffffe0002004dc:	fe043783          	ld	a5,-32(s0)
ffffffe0002004e0:	02e7b023          	sd	a4,32(a5)
        _task->thread.ra = (uint64)__dummy;
ffffffe0002004e4:	00000717          	auipc	a4,0x0
ffffffe0002004e8:	cb470713          	addi	a4,a4,-844 # ffffffe000200198 <__dummy>
ffffffe0002004ec:	fe043783          	ld	a5,-32(s0)
ffffffe0002004f0:	02e7b423          	sd	a4,40(a5)
        _task->thread.sp = (uint64)_task + PGSIZE;
ffffffe0002004f4:	fe043703          	ld	a4,-32(s0)
ffffffe0002004f8:	000017b7          	lui	a5,0x1
ffffffe0002004fc:	00f70733          	add	a4,a4,a5
ffffffe000200500:	fe043783          	ld	a5,-32(s0)
ffffffe000200504:	02e7b823          	sd	a4,48(a5) # 1030 <_skernel-0xffffffe0001fefd0>
        task[i] = _task;
ffffffe000200508:	00004717          	auipc	a4,0x4
ffffffe00020050c:	b1870713          	addi	a4,a4,-1256 # ffffffe000204020 <task>
ffffffe000200510:	fec42783          	lw	a5,-20(s0)
ffffffe000200514:	00379793          	slli	a5,a5,0x3
ffffffe000200518:	00f707b3          	add	a5,a4,a5
ffffffe00020051c:	fe043703          	ld	a4,-32(s0)
ffffffe000200520:	00e7b023          	sd	a4,0(a5)
    for (int i = 1; i < NR_TASKS; i++) {
ffffffe000200524:	fec42783          	lw	a5,-20(s0)
ffffffe000200528:	0017879b          	addiw	a5,a5,1
ffffffe00020052c:	fef42623          	sw	a5,-20(s0)
ffffffe000200530:	fec42783          	lw	a5,-20(s0)
ffffffe000200534:	0007871b          	sext.w	a4,a5
ffffffe000200538:	00300793          	li	a5,3
ffffffe00020053c:	f4e7dce3          	bge	a5,a4,ffffffe000200494 <task_init+0xa4>
    }
    /* YOUR CODE HERE */

    //printk("...proc_init done!\n");
    printk("p\n");
ffffffe000200540:	00002517          	auipc	a0,0x2
ffffffe000200544:	ac850513          	addi	a0,a0,-1336 # ffffffe000202008 <_srodata+0x8>
ffffffe000200548:	364010ef          	jal	ra,ffffffe0002018ac <printk>
}
ffffffe00020054c:	00000013          	nop
ffffffe000200550:	01813083          	ld	ra,24(sp)
ffffffe000200554:	01013403          	ld	s0,16(sp)
ffffffe000200558:	02010113          	addi	sp,sp,32
ffffffe00020055c:	00008067          	ret

ffffffe000200560 <dummy>:

void dummy() {
ffffffe000200560:	fd010113          	addi	sp,sp,-48
ffffffe000200564:	02113423          	sd	ra,40(sp)
ffffffe000200568:	02813023          	sd	s0,32(sp)
ffffffe00020056c:	03010413          	addi	s0,sp,48
    uint64 MOD = 1000000007;
ffffffe000200570:	3b9ad7b7          	lui	a5,0x3b9ad
ffffffe000200574:	a0778793          	addi	a5,a5,-1529 # 3b9aca07 <_skernel-0xffffffdfc48535f9>
ffffffe000200578:	fcf43c23          	sd	a5,-40(s0)
    uint64 auto_inc_local_var = 0;
ffffffe00020057c:	fe043423          	sd	zero,-24(s0)
    int last_counter = -1; // 记录上一个counter
ffffffe000200580:	fff00793          	li	a5,-1
ffffffe000200584:	fef42223          	sw	a5,-28(s0)
    int last_last_counter = -1; // 记录上上个counter
ffffffe000200588:	fff00793          	li	a5,-1
ffffffe00020058c:	fef42023          	sw	a5,-32(s0)
    while(1) {
        if (last_counter == -1 || current->counter != last_counter) {
ffffffe000200590:	fe442783          	lw	a5,-28(s0)
ffffffe000200594:	0007871b          	sext.w	a4,a5
ffffffe000200598:	fff00793          	li	a5,-1
ffffffe00020059c:	00f70e63          	beq	a4,a5,ffffffe0002005b8 <dummy+0x58>
ffffffe0002005a0:	00004797          	auipc	a5,0x4
ffffffe0002005a4:	a7078793          	addi	a5,a5,-1424 # ffffffe000204010 <current>
ffffffe0002005a8:	0007b783          	ld	a5,0(a5)
ffffffe0002005ac:	0107b703          	ld	a4,16(a5)
ffffffe0002005b0:	fe442783          	lw	a5,-28(s0)
ffffffe0002005b4:	08f70463          	beq	a4,a5,ffffffe00020063c <dummy+0xdc>
            last_last_counter = last_counter;
ffffffe0002005b8:	fe442783          	lw	a5,-28(s0)
ffffffe0002005bc:	fef42023          	sw	a5,-32(s0)
            last_counter = current->counter;
ffffffe0002005c0:	00004797          	auipc	a5,0x4
ffffffe0002005c4:	a5078793          	addi	a5,a5,-1456 # ffffffe000204010 <current>
ffffffe0002005c8:	0007b783          	ld	a5,0(a5)
ffffffe0002005cc:	0107b783          	ld	a5,16(a5)
ffffffe0002005d0:	fef42223          	sw	a5,-28(s0)
            auto_inc_local_var = int_mod((auto_inc_local_var + 1),MOD);
ffffffe0002005d4:	fe843783          	ld	a5,-24(s0)
ffffffe0002005d8:	0007879b          	sext.w	a5,a5
ffffffe0002005dc:	0017879b          	addiw	a5,a5,1
ffffffe0002005e0:	0007879b          	sext.w	a5,a5
ffffffe0002005e4:	fd843703          	ld	a4,-40(s0)
ffffffe0002005e8:	0007071b          	sext.w	a4,a4
ffffffe0002005ec:	00070593          	mv	a1,a4
ffffffe0002005f0:	00078513          	mv	a0,a5
ffffffe0002005f4:	38d000ef          	jal	ra,ffffffe000201180 <int_mod>
ffffffe0002005f8:	00050793          	mv	a5,a0
ffffffe0002005fc:	fef43423          	sd	a5,-24(s0)
            printk("[PID = %d] is running. auto_inc_local_var = %d. Thread space begin at %lx\n", current->pid, auto_inc_local_var, current->thread.sp); 
ffffffe000200600:	00004797          	auipc	a5,0x4
ffffffe000200604:	a1078793          	addi	a5,a5,-1520 # ffffffe000204010 <current>
ffffffe000200608:	0007b783          	ld	a5,0(a5)
ffffffe00020060c:	0207b703          	ld	a4,32(a5)
ffffffe000200610:	00004797          	auipc	a5,0x4
ffffffe000200614:	a0078793          	addi	a5,a5,-1536 # ffffffe000204010 <current>
ffffffe000200618:	0007b783          	ld	a5,0(a5)
ffffffe00020061c:	0307b783          	ld	a5,48(a5)
ffffffe000200620:	00078693          	mv	a3,a5
ffffffe000200624:	fe843603          	ld	a2,-24(s0)
ffffffe000200628:	00070593          	mv	a1,a4
ffffffe00020062c:	00002517          	auipc	a0,0x2
ffffffe000200630:	9e450513          	addi	a0,a0,-1564 # ffffffe000202010 <_srodata+0x10>
ffffffe000200634:	278010ef          	jal	ra,ffffffe0002018ac <printk>
ffffffe000200638:	0440006f          	j	ffffffe00020067c <dummy+0x11c>
        } else if((last_last_counter == 0 || last_last_counter == -1) && last_counter == 1) { // counter恒为1的情况
ffffffe00020063c:	fe042783          	lw	a5,-32(s0)
ffffffe000200640:	0007879b          	sext.w	a5,a5
ffffffe000200644:	00078a63          	beqz	a5,ffffffe000200658 <dummy+0xf8>
ffffffe000200648:	fe042783          	lw	a5,-32(s0)
ffffffe00020064c:	0007871b          	sext.w	a4,a5
ffffffe000200650:	fff00793          	li	a5,-1
ffffffe000200654:	f2f71ee3          	bne	a4,a5,ffffffe000200590 <dummy+0x30>
ffffffe000200658:	fe442783          	lw	a5,-28(s0)
ffffffe00020065c:	0007871b          	sext.w	a4,a5
ffffffe000200660:	00100793          	li	a5,1
ffffffe000200664:	f2f716e3          	bne	a4,a5,ffffffe000200590 <dummy+0x30>
            // 这里比较 tricky，不要求理解。
            last_counter = 0; 
ffffffe000200668:	fe042223          	sw	zero,-28(s0)
            current->counter = 0;
ffffffe00020066c:	00004797          	auipc	a5,0x4
ffffffe000200670:	9a478793          	addi	a5,a5,-1628 # ffffffe000204010 <current>
ffffffe000200674:	0007b783          	ld	a5,0(a5)
ffffffe000200678:	0007b823          	sd	zero,16(a5)
        if (last_counter == -1 || current->counter != last_counter) {
ffffffe00020067c:	f15ff06f          	j	ffffffe000200590 <dummy+0x30>

ffffffe000200680 <switch_to>:
    }
}

extern void __switch_to(struct task_struct* prev, struct task_struct* next);

void switch_to(struct task_struct* next) {
ffffffe000200680:	fd010113          	addi	sp,sp,-48
ffffffe000200684:	02113423          	sd	ra,40(sp)
ffffffe000200688:	02813023          	sd	s0,32(sp)
ffffffe00020068c:	03010413          	addi	s0,sp,48
ffffffe000200690:	fca43c23          	sd	a0,-40(s0)
    if (next != current){
ffffffe000200694:	00004797          	auipc	a5,0x4
ffffffe000200698:	97c78793          	addi	a5,a5,-1668 # ffffffe000204010 <current>
ffffffe00020069c:	0007b783          	ld	a5,0(a5)
ffffffe0002006a0:	fd843703          	ld	a4,-40(s0)
ffffffe0002006a4:	04f70e63          	beq	a4,a5,ffffffe000200700 <switch_to+0x80>
        printk("\nswitch to [PID = %d PRIORITY = %d COUNTER = %d]\n", next->pid, next->priority, next->counter);
ffffffe0002006a8:	fd843783          	ld	a5,-40(s0)
ffffffe0002006ac:	0207b703          	ld	a4,32(a5)
ffffffe0002006b0:	fd843783          	ld	a5,-40(s0)
ffffffe0002006b4:	0187b603          	ld	a2,24(a5)
ffffffe0002006b8:	fd843783          	ld	a5,-40(s0)
ffffffe0002006bc:	0107b783          	ld	a5,16(a5)
ffffffe0002006c0:	00078693          	mv	a3,a5
ffffffe0002006c4:	00070593          	mv	a1,a4
ffffffe0002006c8:	00002517          	auipc	a0,0x2
ffffffe0002006cc:	99850513          	addi	a0,a0,-1640 # ffffffe000202060 <_srodata+0x60>
ffffffe0002006d0:	1dc010ef          	jal	ra,ffffffe0002018ac <printk>
        struct task_struct* prev = current;
ffffffe0002006d4:	00004797          	auipc	a5,0x4
ffffffe0002006d8:	93c78793          	addi	a5,a5,-1732 # ffffffe000204010 <current>
ffffffe0002006dc:	0007b783          	ld	a5,0(a5)
ffffffe0002006e0:	fef43423          	sd	a5,-24(s0)
        current = next;
ffffffe0002006e4:	00004797          	auipc	a5,0x4
ffffffe0002006e8:	92c78793          	addi	a5,a5,-1748 # ffffffe000204010 <current>
ffffffe0002006ec:	fd843703          	ld	a4,-40(s0)
ffffffe0002006f0:	00e7b023          	sd	a4,0(a5)
        __switch_to(prev, next);
ffffffe0002006f4:	fd843583          	ld	a1,-40(s0)
ffffffe0002006f8:	fe843503          	ld	a0,-24(s0)
ffffffe0002006fc:	aadff0ef          	jal	ra,ffffffe0002001a8 <__switch_to>
    }
}
ffffffe000200700:	00000013          	nop
ffffffe000200704:	02813083          	ld	ra,40(sp)
ffffffe000200708:	02013403          	ld	s0,32(sp)
ffffffe00020070c:	03010113          	addi	sp,sp,48
ffffffe000200710:	00008067          	ret

ffffffe000200714 <do_timer>:

void do_timer(void) {
ffffffe000200714:	ff010113          	addi	sp,sp,-16
ffffffe000200718:	00113423          	sd	ra,8(sp)
ffffffe00020071c:	00813023          	sd	s0,0(sp)
ffffffe000200720:	01010413          	addi	s0,sp,16
    /* 1. 将当前进程的counter--，如果结果大于零则直接返回*/
    /* 2. 否则进行进程调度 */
    if (current == idle || current->counter == 0) {
ffffffe000200724:	00004797          	auipc	a5,0x4
ffffffe000200728:	8ec78793          	addi	a5,a5,-1812 # ffffffe000204010 <current>
ffffffe00020072c:	0007b703          	ld	a4,0(a5)
ffffffe000200730:	00004797          	auipc	a5,0x4
ffffffe000200734:	8d878793          	addi	a5,a5,-1832 # ffffffe000204008 <idle>
ffffffe000200738:	0007b783          	ld	a5,0(a5)
ffffffe00020073c:	00f70c63          	beq	a4,a5,ffffffe000200754 <do_timer+0x40>
ffffffe000200740:	00004797          	auipc	a5,0x4
ffffffe000200744:	8d078793          	addi	a5,a5,-1840 # ffffffe000204010 <current>
ffffffe000200748:	0007b783          	ld	a5,0(a5)
ffffffe00020074c:	0107b783          	ld	a5,16(a5)
ffffffe000200750:	00079663          	bnez	a5,ffffffe00020075c <do_timer+0x48>
        schedule();
ffffffe000200754:	04c000ef          	jal	ra,ffffffe0002007a0 <schedule>
ffffffe000200758:	0380006f          	j	ffffffe000200790 <do_timer+0x7c>
    }else{
        current->counter --;
ffffffe00020075c:	00004797          	auipc	a5,0x4
ffffffe000200760:	8b478793          	addi	a5,a5,-1868 # ffffffe000204010 <current>
ffffffe000200764:	0007b783          	ld	a5,0(a5)
ffffffe000200768:	0107b703          	ld	a4,16(a5)
ffffffe00020076c:	fff70713          	addi	a4,a4,-1
ffffffe000200770:	00e7b823          	sd	a4,16(a5)
        if (current->counter == 0)
ffffffe000200774:	00004797          	auipc	a5,0x4
ffffffe000200778:	89c78793          	addi	a5,a5,-1892 # ffffffe000204010 <current>
ffffffe00020077c:	0007b783          	ld	a5,0(a5)
ffffffe000200780:	0107b783          	ld	a5,16(a5)
ffffffe000200784:	00079463          	bnez	a5,ffffffe00020078c <do_timer+0x78>
            schedule();
ffffffe000200788:	018000ef          	jal	ra,ffffffe0002007a0 <schedule>
        return ;
ffffffe00020078c:	00000013          	nop
    }
    /* YOUR CODE HERE */
}
ffffffe000200790:	00813083          	ld	ra,8(sp)
ffffffe000200794:	00013403          	ld	s0,0(sp)
ffffffe000200798:	01010113          	addi	sp,sp,16
ffffffe00020079c:	00008067          	ret

ffffffe0002007a0 <schedule>:

void schedule(void) {
ffffffe0002007a0:	fd010113          	addi	sp,sp,-48
ffffffe0002007a4:	02113423          	sd	ra,40(sp)
ffffffe0002007a8:	02813023          	sd	s0,32(sp)
ffffffe0002007ac:	03010413          	addi	s0,sp,48
    /* YOUR CODE HERE */
    uint64 minCounter = 0xffffffff;
ffffffe0002007b0:	fff00793          	li	a5,-1
ffffffe0002007b4:	0207d793          	srli	a5,a5,0x20
ffffffe0002007b8:	fef43423          	sd	a5,-24(s0)
    struct task_struct* next = idle;
ffffffe0002007bc:	00004797          	auipc	a5,0x4
ffffffe0002007c0:	84c78793          	addi	a5,a5,-1972 # ffffffe000204008 <idle>
ffffffe0002007c4:	0007b783          	ld	a5,0(a5)
ffffffe0002007c8:	fef43023          	sd	a5,-32(s0)
    while (1) {
        for (int i = 1; i < NR_TASKS; ++i) {
ffffffe0002007cc:	00100793          	li	a5,1
ffffffe0002007d0:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002007d4:	0b00006f          	j	ffffffe000200884 <schedule+0xe4>
            if (task[i]->state == TASK_RUNNING && task[i]->counter != 0 && task[i]->counter < minCounter) {
ffffffe0002007d8:	00004717          	auipc	a4,0x4
ffffffe0002007dc:	84870713          	addi	a4,a4,-1976 # ffffffe000204020 <task>
ffffffe0002007e0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002007e4:	00379793          	slli	a5,a5,0x3
ffffffe0002007e8:	00f707b3          	add	a5,a4,a5
ffffffe0002007ec:	0007b783          	ld	a5,0(a5)
ffffffe0002007f0:	0087b783          	ld	a5,8(a5)
ffffffe0002007f4:	08079263          	bnez	a5,ffffffe000200878 <schedule+0xd8>
ffffffe0002007f8:	00004717          	auipc	a4,0x4
ffffffe0002007fc:	82870713          	addi	a4,a4,-2008 # ffffffe000204020 <task>
ffffffe000200800:	fdc42783          	lw	a5,-36(s0)
ffffffe000200804:	00379793          	slli	a5,a5,0x3
ffffffe000200808:	00f707b3          	add	a5,a4,a5
ffffffe00020080c:	0007b783          	ld	a5,0(a5)
ffffffe000200810:	0107b783          	ld	a5,16(a5)
ffffffe000200814:	06078263          	beqz	a5,ffffffe000200878 <schedule+0xd8>
ffffffe000200818:	00004717          	auipc	a4,0x4
ffffffe00020081c:	80870713          	addi	a4,a4,-2040 # ffffffe000204020 <task>
ffffffe000200820:	fdc42783          	lw	a5,-36(s0)
ffffffe000200824:	00379793          	slli	a5,a5,0x3
ffffffe000200828:	00f707b3          	add	a5,a4,a5
ffffffe00020082c:	0007b783          	ld	a5,0(a5)
ffffffe000200830:	0107b783          	ld	a5,16(a5)
ffffffe000200834:	fe843703          	ld	a4,-24(s0)
ffffffe000200838:	04e7f063          	bgeu	a5,a4,ffffffe000200878 <schedule+0xd8>
                minCounter = task[i]->counter;
ffffffe00020083c:	00003717          	auipc	a4,0x3
ffffffe000200840:	7e470713          	addi	a4,a4,2020 # ffffffe000204020 <task>
ffffffe000200844:	fdc42783          	lw	a5,-36(s0)
ffffffe000200848:	00379793          	slli	a5,a5,0x3
ffffffe00020084c:	00f707b3          	add	a5,a4,a5
ffffffe000200850:	0007b783          	ld	a5,0(a5)
ffffffe000200854:	0107b783          	ld	a5,16(a5)
ffffffe000200858:	fef43423          	sd	a5,-24(s0)
                next = task[i];
ffffffe00020085c:	00003717          	auipc	a4,0x3
ffffffe000200860:	7c470713          	addi	a4,a4,1988 # ffffffe000204020 <task>
ffffffe000200864:	fdc42783          	lw	a5,-36(s0)
ffffffe000200868:	00379793          	slli	a5,a5,0x3
ffffffe00020086c:	00f707b3          	add	a5,a4,a5
ffffffe000200870:	0007b783          	ld	a5,0(a5)
ffffffe000200874:	fef43023          	sd	a5,-32(s0)
        for (int i = 1; i < NR_TASKS; ++i) {
ffffffe000200878:	fdc42783          	lw	a5,-36(s0)
ffffffe00020087c:	0017879b          	addiw	a5,a5,1
ffffffe000200880:	fcf42e23          	sw	a5,-36(s0)
ffffffe000200884:	fdc42783          	lw	a5,-36(s0)
ffffffe000200888:	0007871b          	sext.w	a4,a5
ffffffe00020088c:	00300793          	li	a5,3
ffffffe000200890:	f4e7d4e3          	bge	a5,a4,ffffffe0002007d8 <schedule+0x38>
            }
        }
        if (next != idle) break;
ffffffe000200894:	00003797          	auipc	a5,0x3
ffffffe000200898:	77478793          	addi	a5,a5,1908 # ffffffe000204008 <idle>
ffffffe00020089c:	0007b783          	ld	a5,0(a5)
ffffffe0002008a0:	fe043703          	ld	a4,-32(s0)
ffffffe0002008a4:	0ef71463          	bne	a4,a5,ffffffe00020098c <schedule+0x1ec>
        for (int i = 1; i < NR_TASKS; ++i) {
ffffffe0002008a8:	00100793          	li	a5,1
ffffffe0002008ac:	fcf42c23          	sw	a5,-40(s0)
ffffffe0002008b0:	0c80006f          	j	ffffffe000200978 <schedule+0x1d8>
            task[i]->counter = task[i]->priority;
ffffffe0002008b4:	00003717          	auipc	a4,0x3
ffffffe0002008b8:	76c70713          	addi	a4,a4,1900 # ffffffe000204020 <task>
ffffffe0002008bc:	fd842783          	lw	a5,-40(s0)
ffffffe0002008c0:	00379793          	slli	a5,a5,0x3
ffffffe0002008c4:	00f707b3          	add	a5,a4,a5
ffffffe0002008c8:	0007b703          	ld	a4,0(a5)
ffffffe0002008cc:	00003697          	auipc	a3,0x3
ffffffe0002008d0:	75468693          	addi	a3,a3,1876 # ffffffe000204020 <task>
ffffffe0002008d4:	fd842783          	lw	a5,-40(s0)
ffffffe0002008d8:	00379793          	slli	a5,a5,0x3
ffffffe0002008dc:	00f687b3          	add	a5,a3,a5
ffffffe0002008e0:	0007b783          	ld	a5,0(a5)
ffffffe0002008e4:	01873703          	ld	a4,24(a4)
ffffffe0002008e8:	00e7b823          	sd	a4,16(a5)
            if (i == 1) printk("\n");
ffffffe0002008ec:	fd842783          	lw	a5,-40(s0)
ffffffe0002008f0:	0007871b          	sext.w	a4,a5
ffffffe0002008f4:	00100793          	li	a5,1
ffffffe0002008f8:	00f71863          	bne	a4,a5,ffffffe000200908 <schedule+0x168>
ffffffe0002008fc:	00001517          	auipc	a0,0x1
ffffffe000200900:	79c50513          	addi	a0,a0,1948 # ffffffe000202098 <_srodata+0x98>
ffffffe000200904:	7a9000ef          	jal	ra,ffffffe0002018ac <printk>
            printk("SET [PID = %d PRIORITY = %d COUNTER = %d]\n", task[i]->pid, task[i]->priority, task[i]->counter);
ffffffe000200908:	00003717          	auipc	a4,0x3
ffffffe00020090c:	71870713          	addi	a4,a4,1816 # ffffffe000204020 <task>
ffffffe000200910:	fd842783          	lw	a5,-40(s0)
ffffffe000200914:	00379793          	slli	a5,a5,0x3
ffffffe000200918:	00f707b3          	add	a5,a4,a5
ffffffe00020091c:	0007b783          	ld	a5,0(a5)
ffffffe000200920:	0207b583          	ld	a1,32(a5)
ffffffe000200924:	00003717          	auipc	a4,0x3
ffffffe000200928:	6fc70713          	addi	a4,a4,1788 # ffffffe000204020 <task>
ffffffe00020092c:	fd842783          	lw	a5,-40(s0)
ffffffe000200930:	00379793          	slli	a5,a5,0x3
ffffffe000200934:	00f707b3          	add	a5,a4,a5
ffffffe000200938:	0007b783          	ld	a5,0(a5)
ffffffe00020093c:	0187b603          	ld	a2,24(a5)
ffffffe000200940:	00003717          	auipc	a4,0x3
ffffffe000200944:	6e070713          	addi	a4,a4,1760 # ffffffe000204020 <task>
ffffffe000200948:	fd842783          	lw	a5,-40(s0)
ffffffe00020094c:	00379793          	slli	a5,a5,0x3
ffffffe000200950:	00f707b3          	add	a5,a4,a5
ffffffe000200954:	0007b783          	ld	a5,0(a5)
ffffffe000200958:	0107b783          	ld	a5,16(a5)
ffffffe00020095c:	00078693          	mv	a3,a5
ffffffe000200960:	00001517          	auipc	a0,0x1
ffffffe000200964:	74050513          	addi	a0,a0,1856 # ffffffe0002020a0 <_srodata+0xa0>
ffffffe000200968:	745000ef          	jal	ra,ffffffe0002018ac <printk>
        for (int i = 1; i < NR_TASKS; ++i) {
ffffffe00020096c:	fd842783          	lw	a5,-40(s0)
ffffffe000200970:	0017879b          	addiw	a5,a5,1
ffffffe000200974:	fcf42c23          	sw	a5,-40(s0)
ffffffe000200978:	fd842783          	lw	a5,-40(s0)
ffffffe00020097c:	0007871b          	sext.w	a4,a5
ffffffe000200980:	00300793          	li	a5,3
ffffffe000200984:	f2e7d8e3          	bge	a5,a4,ffffffe0002008b4 <schedule+0x114>
        for (int i = 1; i < NR_TASKS; ++i) {
ffffffe000200988:	e45ff06f          	j	ffffffe0002007cc <schedule+0x2c>
        if (next != idle) break;
ffffffe00020098c:	00000013          	nop
        }
    }
    switch_to(next);
ffffffe000200990:	fe043503          	ld	a0,-32(s0)
ffffffe000200994:	cedff0ef          	jal	ra,ffffffe000200680 <switch_to>
}
ffffffe000200998:	00000013          	nop
ffffffe00020099c:	02813083          	ld	ra,40(sp)
ffffffe0002009a0:	02013403          	ld	s0,32(sp)
ffffffe0002009a4:	03010113          	addi	sp,sp,48
ffffffe0002009a8:	00008067          	ret

ffffffe0002009ac <sbi_ecall>:

struct sbiret sbi_ecall(int ext, int fid, uint64 arg0,
                        uint64 arg1, uint64 arg2,
                        uint64 arg3, uint64 arg4,
                        uint64 arg5)
{
ffffffe0002009ac:	f8010113          	addi	sp,sp,-128
ffffffe0002009b0:	06813c23          	sd	s0,120(sp)
ffffffe0002009b4:	08010413          	addi	s0,sp,128
ffffffe0002009b8:	fac43823          	sd	a2,-80(s0)
ffffffe0002009bc:	fad43423          	sd	a3,-88(s0)
ffffffe0002009c0:	fae43023          	sd	a4,-96(s0)
ffffffe0002009c4:	f8f43c23          	sd	a5,-104(s0)
ffffffe0002009c8:	f9043823          	sd	a6,-112(s0)
ffffffe0002009cc:	f9143423          	sd	a7,-120(s0)
ffffffe0002009d0:	00050793          	mv	a5,a0
ffffffe0002009d4:	faf42e23          	sw	a5,-68(s0)
ffffffe0002009d8:	00058793          	mv	a5,a1
ffffffe0002009dc:	faf42c23          	sw	a5,-72(s0)
  struct sbiret ret;
  uint64 error, value;
  asm volatile (
ffffffe0002009e0:	fb043783          	ld	a5,-80(s0)
ffffffe0002009e4:	fa843703          	ld	a4,-88(s0)
ffffffe0002009e8:	fa043683          	ld	a3,-96(s0)
ffffffe0002009ec:	f9843603          	ld	a2,-104(s0)
ffffffe0002009f0:	f9043803          	ld	a6,-112(s0)
ffffffe0002009f4:	f8843883          	ld	a7,-120(s0)
ffffffe0002009f8:	fb842583          	lw	a1,-72(s0)
ffffffe0002009fc:	00058e13          	mv	t3,a1
ffffffe000200a00:	fbc42583          	lw	a1,-68(s0)
ffffffe000200a04:	00058e93          	mv	t4,a1
ffffffe000200a08:	00078513          	mv	a0,a5
ffffffe000200a0c:	00070593          	mv	a1,a4
ffffffe000200a10:	00068613          	mv	a2,a3
ffffffe000200a14:	00060693          	mv	a3,a2
ffffffe000200a18:	00080713          	mv	a4,a6
ffffffe000200a1c:	00088793          	mv	a5,a7
ffffffe000200a20:	000e0813          	mv	a6,t3
ffffffe000200a24:	000e8893          	mv	a7,t4
ffffffe000200a28:	00000073          	ecall
ffffffe000200a2c:	00050713          	mv	a4,a0
ffffffe000200a30:	00058793          	mv	a5,a1
ffffffe000200a34:	fee43423          	sd	a4,-24(s0)
ffffffe000200a38:	fef43023          	sd	a5,-32(s0)
      "mv %[value], a1"
      : [error] "=r" (error), [value] "=r" (value)
      : [arg0] "r" (arg0), [arg1] "r" (arg1), [arg2] "r" (arg2), [arg3] "r" (arg3), [arg4] "r" (arg4), [arg5] "r" (arg5), [fid] "r" (fid), [ext] "r" (ext)
      : "a0", "a1", "memory"
  );
  ret.error = error;
ffffffe000200a3c:	fe843783          	ld	a5,-24(s0)
ffffffe000200a40:	fcf43023          	sd	a5,-64(s0)
  ret.value = value;
ffffffe000200a44:	fe043783          	ld	a5,-32(s0)
ffffffe000200a48:	fcf43423          	sd	a5,-56(s0)
  return ret;
ffffffe000200a4c:	fc043783          	ld	a5,-64(s0)
ffffffe000200a50:	fcf43823          	sd	a5,-48(s0)
ffffffe000200a54:	fc843783          	ld	a5,-56(s0)
ffffffe000200a58:	fcf43c23          	sd	a5,-40(s0)
ffffffe000200a5c:	fd043703          	ld	a4,-48(s0)
ffffffe000200a60:	fd843783          	ld	a5,-40(s0)
ffffffe000200a64:	00070313          	mv	t1,a4
ffffffe000200a68:	00078393          	mv	t2,a5
ffffffe000200a6c:	00030713          	mv	a4,t1
ffffffe000200a70:	00038793          	mv	a5,t2
}
ffffffe000200a74:	00070513          	mv	a0,a4
ffffffe000200a78:	00078593          	mv	a1,a5
ffffffe000200a7c:	07813403          	ld	s0,120(sp)
ffffffe000200a80:	08010113          	addi	sp,sp,128
ffffffe000200a84:	00008067          	ret

ffffffe000200a88 <sbi_set_timer>:

void sbi_set_timer(uint64 stime_value) {
ffffffe000200a88:	fe010113          	addi	sp,sp,-32
ffffffe000200a8c:	00113c23          	sd	ra,24(sp)
ffffffe000200a90:	00813823          	sd	s0,16(sp)
ffffffe000200a94:	02010413          	addi	s0,sp,32
ffffffe000200a98:	fea43423          	sd	a0,-24(s0)
    sbi_ecall(0x00, 0, stime_value, 0, 0, 0, 0, 0);
ffffffe000200a9c:	00000893          	li	a7,0
ffffffe000200aa0:	00000813          	li	a6,0
ffffffe000200aa4:	00000793          	li	a5,0
ffffffe000200aa8:	00000713          	li	a4,0
ffffffe000200aac:	00000693          	li	a3,0
ffffffe000200ab0:	fe843603          	ld	a2,-24(s0)
ffffffe000200ab4:	00000593          	li	a1,0
ffffffe000200ab8:	00000513          	li	a0,0
ffffffe000200abc:	ef1ff0ef          	jal	ra,ffffffe0002009ac <sbi_ecall>
    return;
ffffffe000200ac0:	00000013          	nop
}
ffffffe000200ac4:	01813083          	ld	ra,24(sp)
ffffffe000200ac8:	01013403          	ld	s0,16(sp)
ffffffe000200acc:	02010113          	addi	sp,sp,32
ffffffe000200ad0:	00008067          	ret

ffffffe000200ad4 <sbi_console_getchar>:

int sbi_console_getchar() {
ffffffe000200ad4:	fe010113          	addi	sp,sp,-32
ffffffe000200ad8:	00113c23          	sd	ra,24(sp)
ffffffe000200adc:	00813823          	sd	s0,16(sp)
ffffffe000200ae0:	02010413          	addi	s0,sp,32
    struct sbiret ret;
    ret = sbi_ecall(0x02, 0, 0, 0, 0, 0, 0, 0);
ffffffe000200ae4:	00000893          	li	a7,0
ffffffe000200ae8:	00000813          	li	a6,0
ffffffe000200aec:	00000793          	li	a5,0
ffffffe000200af0:	00000713          	li	a4,0
ffffffe000200af4:	00000693          	li	a3,0
ffffffe000200af8:	00000613          	li	a2,0
ffffffe000200afc:	00000593          	li	a1,0
ffffffe000200b00:	00200513          	li	a0,2
ffffffe000200b04:	ea9ff0ef          	jal	ra,ffffffe0002009ac <sbi_ecall>
ffffffe000200b08:	00050713          	mv	a4,a0
ffffffe000200b0c:	00058793          	mv	a5,a1
ffffffe000200b10:	fee43023          	sd	a4,-32(s0)
ffffffe000200b14:	fef43423          	sd	a5,-24(s0)
    return ret.error;
ffffffe000200b18:	fe043783          	ld	a5,-32(s0)
ffffffe000200b1c:	0007879b          	sext.w	a5,a5
}
ffffffe000200b20:	00078513          	mv	a0,a5
ffffffe000200b24:	01813083          	ld	ra,24(sp)
ffffffe000200b28:	01013403          	ld	s0,16(sp)
ffffffe000200b2c:	02010113          	addi	sp,sp,32
ffffffe000200b30:	00008067          	ret

ffffffe000200b34 <trap_handler>:
#include "printk.h" 
#include "clock.h"
#include "proc.h"

void trap_handler(unsigned long scause, unsigned long sepc) {
ffffffe000200b34:	fd010113          	addi	sp,sp,-48
ffffffe000200b38:	02113423          	sd	ra,40(sp)
ffffffe000200b3c:	02813023          	sd	s0,32(sp)
ffffffe000200b40:	03010413          	addi	s0,sp,48
ffffffe000200b44:	fca43c23          	sd	a0,-40(s0)
ffffffe000200b48:	fcb43823          	sd	a1,-48(s0)
    unsigned long interrupt = scause >> 63;
ffffffe000200b4c:	fd843783          	ld	a5,-40(s0)
ffffffe000200b50:	03f7d793          	srli	a5,a5,0x3f
ffffffe000200b54:	fef43423          	sd	a5,-24(s0)
    unsigned long exception = scause & 0x7FFFFFFFFFFFFFFF;
ffffffe000200b58:	fd843703          	ld	a4,-40(s0)
ffffffe000200b5c:	fff00793          	li	a5,-1
ffffffe000200b60:	0017d793          	srli	a5,a5,0x1
ffffffe000200b64:	00f777b3          	and	a5,a4,a5
ffffffe000200b68:	fef43023          	sd	a5,-32(s0)
    if (interrupt == 1 && exception == 5){
ffffffe000200b6c:	fe843703          	ld	a4,-24(s0)
ffffffe000200b70:	00100793          	li	a5,1
ffffffe000200b74:	00f71e63          	bne	a4,a5,ffffffe000200b90 <trap_handler+0x5c>
ffffffe000200b78:	fe043703          	ld	a4,-32(s0)
ffffffe000200b7c:	00500793          	li	a5,5
ffffffe000200b80:	00f71863          	bne	a4,a5,ffffffe000200b90 <trap_handler+0x5c>
        // printk("[S] Supervisor Mode Timer Interrupt\n");
        clock_set_next_event();
ffffffe000200b84:	ec0ff0ef          	jal	ra,ffffffe000200244 <clock_set_next_event>
        do_timer();
ffffffe000200b88:	b8dff0ef          	jal	ra,ffffffe000200714 <do_timer>
        return;
ffffffe000200b8c:	00000013          	nop
    }
    // printk("scause = %lx, sepc = %llx\n", scause, sepc);
ffffffe000200b90:	02813083          	ld	ra,40(sp)
ffffffe000200b94:	02013403          	ld	s0,32(sp)
ffffffe000200b98:	03010113          	addi	sp,sp,48
ffffffe000200b9c:	00008067          	ret

ffffffe000200ba0 <setup_vm>:
unsigned long early_pgtbl[512] __attribute__((__aligned__(0x1000)));
/* swapper_pg_dir: kernel pagetable 根目录， 在 setup_vm_final 进行映射。 */
unsigned long  swapper_pg_dir[512] __attribute__((__aligned__(0x1000)));

void setup_vm(void)
{
ffffffe000200ba0:	fd010113          	addi	sp,sp,-48
ffffffe000200ba4:	02113423          	sd	ra,40(sp)
ffffffe000200ba8:	02813023          	sd	s0,32(sp)
ffffffe000200bac:	03010413          	addi	s0,sp,48
    // 初始化early_pgtbl
    memset(early_pgtbl, 0x0, PGSIZE);
ffffffe000200bb0:	00001637          	lui	a2,0x1
ffffffe000200bb4:	00000593          	li	a1,0
ffffffe000200bb8:	00004517          	auipc	a0,0x4
ffffffe000200bbc:	44850513          	addi	a0,a0,1096 # ffffffe000205000 <early_pgtbl>
ffffffe000200bc0:	06c010ef          	jal	ra,ffffffe000201c2c <memset>

    // 定义pa与va
    uint64 pa = PHY_START, va = VM_START;
ffffffe000200bc4:	00100793          	li	a5,1
ffffffe000200bc8:	01f79793          	slli	a5,a5,0x1f
ffffffe000200bcc:	fef43423          	sd	a5,-24(s0)
ffffffe000200bd0:	fff00793          	li	a5,-1
ffffffe000200bd4:	02579793          	slli	a5,a5,0x25
ffffffe000200bd8:	fef43023          	sd	a5,-32(s0)

    // 等值映射 (PA == VA) 此处pa = va，所以将pa视为va，用pa计算index
    // 1. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
    // high bit 可以忽略
    // 中间9 bit 作为 early_pgtbl 的 index
    int index = VPN2(pa);
ffffffe000200bdc:	fe843783          	ld	a5,-24(s0)
ffffffe000200be0:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200be4:	0007879b          	sext.w	a5,a5
ffffffe000200be8:	1ff7f793          	andi	a5,a5,511
ffffffe000200bec:	fcf42e23          	sw	a5,-36(s0)
    // 低 30 bit 作为 页内偏移 这里注意到 30 = 9 + 9 + 12， 即我们只使用根页表， 根页表的每个 entry 都对应 1GB 的区域。
    early_pgtbl[index] = (((pa >> 30) & 0x3ffffff) << 28);
ffffffe000200bf0:	fe843783          	ld	a5,-24(s0)
ffffffe000200bf4:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200bf8:	01c79713          	slli	a4,a5,0x1c
ffffffe000200bfc:	040007b7          	lui	a5,0x4000
ffffffe000200c00:	fff78793          	addi	a5,a5,-1 # 3ffffff <_skernel-0xffffffdffc200001>
ffffffe000200c04:	01c79793          	slli	a5,a5,0x1c
ffffffe000200c08:	00f77733          	and	a4,a4,a5
ffffffe000200c0c:	00004697          	auipc	a3,0x4
ffffffe000200c10:	3f468693          	addi	a3,a3,1012 # ffffffe000205000 <early_pgtbl>
ffffffe000200c14:	fdc42783          	lw	a5,-36(s0)
ffffffe000200c18:	00379793          	slli	a5,a5,0x3
ffffffe000200c1c:	00f687b3          	add	a5,a3,a5
ffffffe000200c20:	00e7b023          	sd	a4,0(a5)
    // 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    early_pgtbl[index] = early_pgtbl[index] | PTE_V | PTE_R | PTE_W | PTE_X | PTE_A | PTE_D;
ffffffe000200c24:	00004717          	auipc	a4,0x4
ffffffe000200c28:	3dc70713          	addi	a4,a4,988 # ffffffe000205000 <early_pgtbl>
ffffffe000200c2c:	fdc42783          	lw	a5,-36(s0)
ffffffe000200c30:	00379793          	slli	a5,a5,0x3
ffffffe000200c34:	00f707b3          	add	a5,a4,a5
ffffffe000200c38:	0007b783          	ld	a5,0(a5)
ffffffe000200c3c:	0cf7e713          	ori	a4,a5,207
ffffffe000200c40:	00004697          	auipc	a3,0x4
ffffffe000200c44:	3c068693          	addi	a3,a3,960 # ffffffe000205000 <early_pgtbl>
ffffffe000200c48:	fdc42783          	lw	a5,-36(s0)
ffffffe000200c4c:	00379793          	slli	a5,a5,0x3
ffffffe000200c50:	00f687b3          	add	a5,a3,a5
ffffffe000200c54:	00e7b023          	sd	a4,0(a5)

    // 映射至高地址 (PA + PV2VA_OFFSET == VA)
    // 1. 将 va 的 64bit 作为如下划分： | high bit | 9 bit | 30 bit |
    // high bit 可以忽略
    // 中间9 bit 作为 early_pgtbl 的 index
    index = VPN2(va);
ffffffe000200c58:	fe043783          	ld	a5,-32(s0)
ffffffe000200c5c:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200c60:	0007879b          	sext.w	a5,a5
ffffffe000200c64:	1ff7f793          	andi	a5,a5,511
ffffffe000200c68:	fcf42e23          	sw	a5,-36(s0)
    // 低 30 bit 作为 页内偏移 这里注意到 30 = 9 + 9 + 12， 即我们只使用根页表， 根页表的每个 entry 都对应 1GB 的区域。
    early_pgtbl[index] = (((pa >> 30) & 0x3ffffff) << 28);
ffffffe000200c6c:	fe843783          	ld	a5,-24(s0)
ffffffe000200c70:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200c74:	01c79713          	slli	a4,a5,0x1c
ffffffe000200c78:	040007b7          	lui	a5,0x4000
ffffffe000200c7c:	fff78793          	addi	a5,a5,-1 # 3ffffff <_skernel-0xffffffdffc200001>
ffffffe000200c80:	01c79793          	slli	a5,a5,0x1c
ffffffe000200c84:	00f77733          	and	a4,a4,a5
ffffffe000200c88:	00004697          	auipc	a3,0x4
ffffffe000200c8c:	37868693          	addi	a3,a3,888 # ffffffe000205000 <early_pgtbl>
ffffffe000200c90:	fdc42783          	lw	a5,-36(s0)
ffffffe000200c94:	00379793          	slli	a5,a5,0x3
ffffffe000200c98:	00f687b3          	add	a5,a3,a5
ffffffe000200c9c:	00e7b023          	sd	a4,0(a5)
    // 3. Page Table Entry 的权限 V | R | W | X 位设置为 1
    early_pgtbl[index] = early_pgtbl[index] | PTE_V | PTE_R | PTE_W | PTE_X | PTE_A | PTE_D;
ffffffe000200ca0:	00004717          	auipc	a4,0x4
ffffffe000200ca4:	36070713          	addi	a4,a4,864 # ffffffe000205000 <early_pgtbl>
ffffffe000200ca8:	fdc42783          	lw	a5,-36(s0)
ffffffe000200cac:	00379793          	slli	a5,a5,0x3
ffffffe000200cb0:	00f707b3          	add	a5,a4,a5
ffffffe000200cb4:	0007b783          	ld	a5,0(a5)
ffffffe000200cb8:	0cf7e713          	ori	a4,a5,207
ffffffe000200cbc:	00004697          	auipc	a3,0x4
ffffffe000200cc0:	34468693          	addi	a3,a3,836 # ffffffe000205000 <early_pgtbl>
ffffffe000200cc4:	fdc42783          	lw	a5,-36(s0)
ffffffe000200cc8:	00379793          	slli	a5,a5,0x3
ffffffe000200ccc:	00f687b3          	add	a5,a3,a5
ffffffe000200cd0:	00e7b023          	sd	a4,0(a5)
}
ffffffe000200cd4:	00000013          	nop
ffffffe000200cd8:	02813083          	ld	ra,40(sp)
ffffffe000200cdc:	02013403          	ld	s0,32(sp)
ffffffe000200ce0:	03010113          	addi	sp,sp,48
ffffffe000200ce4:	00008067          	ret

ffffffe000200ce8 <create_mapping>:
extern char _stext[];
extern char _srodata[];
extern char _sdata[];

/* 创建多级页表映射关系 */
void create_mapping(uint64 *pgtbl, uint64 va, uint64 pa, uint64 sz, uint64 perm) {
ffffffe000200ce8:	f9010113          	addi	sp,sp,-112
ffffffe000200cec:	06113423          	sd	ra,104(sp)
ffffffe000200cf0:	06813023          	sd	s0,96(sp)
ffffffe000200cf4:	07010413          	addi	s0,sp,112
ffffffe000200cf8:	faa43c23          	sd	a0,-72(s0)
ffffffe000200cfc:	fab43823          	sd	a1,-80(s0)
ffffffe000200d00:	fac43423          	sd	a2,-88(s0)
ffffffe000200d04:	fad43023          	sd	a3,-96(s0)
ffffffe000200d08:	f8e43c23          	sd	a4,-104(s0)
    将给定的一段虚拟内存映射到物理内存上
    物理内存需要分页
    创建多级页表的时候可以使用 kalloc() 来获取一页作为页表目录
    可以使用 V bit 来判断页表项是否存在
    */
    printk("root: %lx, [%lx, %lx) -> [%lx, %lx), perm: %x\n", pgtbl, pa, pa+sz, va, va+sz, perm);
ffffffe000200d0c:	fa843703          	ld	a4,-88(s0)
ffffffe000200d10:	fa043783          	ld	a5,-96(s0)
ffffffe000200d14:	00f706b3          	add	a3,a4,a5
ffffffe000200d18:	fb043703          	ld	a4,-80(s0)
ffffffe000200d1c:	fa043783          	ld	a5,-96(s0)
ffffffe000200d20:	00f707b3          	add	a5,a4,a5
ffffffe000200d24:	f9843803          	ld	a6,-104(s0)
ffffffe000200d28:	fb043703          	ld	a4,-80(s0)
ffffffe000200d2c:	fa843603          	ld	a2,-88(s0)
ffffffe000200d30:	fb843583          	ld	a1,-72(s0)
ffffffe000200d34:	00001517          	auipc	a0,0x1
ffffffe000200d38:	39c50513          	addi	a0,a0,924 # ffffffe0002020d0 <_srodata+0xd0>
ffffffe000200d3c:	371000ef          	jal	ra,ffffffe0002018ac <printk>
    uint64 va_end = va + sz;
ffffffe000200d40:	fb043703          	ld	a4,-80(s0)
ffffffe000200d44:	fa043783          	ld	a5,-96(s0)
ffffffe000200d48:	00f707b3          	add	a5,a4,a5
ffffffe000200d4c:	fef43023          	sd	a5,-32(s0)
    uint64 *cur_tbl, cur_vpn, cur_pte;
    while (va < va_end) {
ffffffe000200d50:	1980006f          	j	ffffffe000200ee8 <create_mapping+0x200>
        // 第一级
        cur_tbl = pgtbl;
ffffffe000200d54:	fb843783          	ld	a5,-72(s0)
ffffffe000200d58:	fcf43c23          	sd	a5,-40(s0)
        cur_vpn = VPN2(va);
ffffffe000200d5c:	fb043783          	ld	a5,-80(s0)
ffffffe000200d60:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200d64:	1ff7f793          	andi	a5,a5,511
ffffffe000200d68:	fcf43823          	sd	a5,-48(s0)
        cur_pte = *(cur_tbl + cur_vpn);
ffffffe000200d6c:	fd043783          	ld	a5,-48(s0)
ffffffe000200d70:	00379793          	slli	a5,a5,0x3
ffffffe000200d74:	fd843703          	ld	a4,-40(s0)
ffffffe000200d78:	00f707b3          	add	a5,a4,a5
ffffffe000200d7c:	0007b783          	ld	a5,0(a5)
ffffffe000200d80:	fef43423          	sd	a5,-24(s0)
        if ((cur_pte & PTE_V) == 0) {
ffffffe000200d84:	fe843783          	ld	a5,-24(s0)
ffffffe000200d88:	0017f793          	andi	a5,a5,1
ffffffe000200d8c:	04079463          	bnez	a5,ffffffe000200dd4 <create_mapping+0xec>
            uint64 new_page_phy = (uint64)kalloc() - PA2VA_OFFSET;
ffffffe000200d90:	cfcff0ef          	jal	ra,ffffffe00020028c <kalloc>
ffffffe000200d94:	00050713          	mv	a4,a0
ffffffe000200d98:	04100793          	li	a5,65
ffffffe000200d9c:	01f79793          	slli	a5,a5,0x1f
ffffffe000200da0:	00f707b3          	add	a5,a4,a5
ffffffe000200da4:	fcf43423          	sd	a5,-56(s0)
            cur_pte = ((uint64)new_page_phy >> 12) << 10 | PTE_V;
ffffffe000200da8:	fc843783          	ld	a5,-56(s0)
ffffffe000200dac:	00c7d793          	srli	a5,a5,0xc
ffffffe000200db0:	00a79793          	slli	a5,a5,0xa
ffffffe000200db4:	0017e793          	ori	a5,a5,1
ffffffe000200db8:	fef43423          	sd	a5,-24(s0)
            *(cur_tbl + cur_vpn) = cur_pte;
ffffffe000200dbc:	fd043783          	ld	a5,-48(s0)
ffffffe000200dc0:	00379793          	slli	a5,a5,0x3
ffffffe000200dc4:	fd843703          	ld	a4,-40(s0)
ffffffe000200dc8:	00f707b3          	add	a5,a4,a5
ffffffe000200dcc:	fe843703          	ld	a4,-24(s0)
ffffffe000200dd0:	00e7b023          	sd	a4,0(a5)
        }
        // 第二级
        cur_tbl = (uint64*)(((cur_pte >> 10) << 12) + PA2VA_OFFSET);
ffffffe000200dd4:	fe843783          	ld	a5,-24(s0)
ffffffe000200dd8:	00a7d793          	srli	a5,a5,0xa
ffffffe000200ddc:	00c79713          	slli	a4,a5,0xc
ffffffe000200de0:	fbf00793          	li	a5,-65
ffffffe000200de4:	01f79793          	slli	a5,a5,0x1f
ffffffe000200de8:	00f707b3          	add	a5,a4,a5
ffffffe000200dec:	fcf43c23          	sd	a5,-40(s0)
        cur_vpn = VPN1(va);
ffffffe000200df0:	fb043783          	ld	a5,-80(s0)
ffffffe000200df4:	0157d793          	srli	a5,a5,0x15
ffffffe000200df8:	1ff7f793          	andi	a5,a5,511
ffffffe000200dfc:	fcf43823          	sd	a5,-48(s0)
        cur_pte = *(cur_tbl + cur_vpn);
ffffffe000200e00:	fd043783          	ld	a5,-48(s0)
ffffffe000200e04:	00379793          	slli	a5,a5,0x3
ffffffe000200e08:	fd843703          	ld	a4,-40(s0)
ffffffe000200e0c:	00f707b3          	add	a5,a4,a5
ffffffe000200e10:	0007b783          	ld	a5,0(a5)
ffffffe000200e14:	fef43423          	sd	a5,-24(s0)
        if ((cur_pte & PTE_V) == 0) {
ffffffe000200e18:	fe843783          	ld	a5,-24(s0)
ffffffe000200e1c:	0017f793          	andi	a5,a5,1
ffffffe000200e20:	04079463          	bnez	a5,ffffffe000200e68 <create_mapping+0x180>
            uint64 new_page_phy = (uint64)kalloc() - PA2VA_OFFSET;
ffffffe000200e24:	c68ff0ef          	jal	ra,ffffffe00020028c <kalloc>
ffffffe000200e28:	00050713          	mv	a4,a0
ffffffe000200e2c:	04100793          	li	a5,65
ffffffe000200e30:	01f79793          	slli	a5,a5,0x1f
ffffffe000200e34:	00f707b3          	add	a5,a4,a5
ffffffe000200e38:	fcf43023          	sd	a5,-64(s0)
            cur_pte = ((uint64)new_page_phy >> 12) << 10 | PTE_V;
ffffffe000200e3c:	fc043783          	ld	a5,-64(s0)
ffffffe000200e40:	00c7d793          	srli	a5,a5,0xc
ffffffe000200e44:	00a79793          	slli	a5,a5,0xa
ffffffe000200e48:	0017e793          	ori	a5,a5,1
ffffffe000200e4c:	fef43423          	sd	a5,-24(s0)
            *(cur_tbl + cur_vpn) = cur_pte;
ffffffe000200e50:	fd043783          	ld	a5,-48(s0)
ffffffe000200e54:	00379793          	slli	a5,a5,0x3
ffffffe000200e58:	fd843703          	ld	a4,-40(s0)
ffffffe000200e5c:	00f707b3          	add	a5,a4,a5
ffffffe000200e60:	fe843703          	ld	a4,-24(s0)
ffffffe000200e64:	00e7b023          	sd	a4,0(a5)
        }
        // 第三级
        cur_tbl = (uint64*)(((cur_pte >> 10) << 12) + PA2VA_OFFSET);
ffffffe000200e68:	fe843783          	ld	a5,-24(s0)
ffffffe000200e6c:	00a7d793          	srli	a5,a5,0xa
ffffffe000200e70:	00c79713          	slli	a4,a5,0xc
ffffffe000200e74:	fbf00793          	li	a5,-65
ffffffe000200e78:	01f79793          	slli	a5,a5,0x1f
ffffffe000200e7c:	00f707b3          	add	a5,a4,a5
ffffffe000200e80:	fcf43c23          	sd	a5,-40(s0)
        cur_vpn = VPN0(va);
ffffffe000200e84:	fb043783          	ld	a5,-80(s0)
ffffffe000200e88:	00c7d793          	srli	a5,a5,0xc
ffffffe000200e8c:	1ff7f793          	andi	a5,a5,511
ffffffe000200e90:	fcf43823          	sd	a5,-48(s0)
        cur_pte = ((pa >> 12) << 10) | perm | PTE_V;
ffffffe000200e94:	fa843783          	ld	a5,-88(s0)
ffffffe000200e98:	00c7d793          	srli	a5,a5,0xc
ffffffe000200e9c:	00a79713          	slli	a4,a5,0xa
ffffffe000200ea0:	f9843783          	ld	a5,-104(s0)
ffffffe000200ea4:	00f767b3          	or	a5,a4,a5
ffffffe000200ea8:	0017e793          	ori	a5,a5,1
ffffffe000200eac:	fef43423          	sd	a5,-24(s0)
        *(cur_tbl + cur_vpn) = cur_pte;
ffffffe000200eb0:	fd043783          	ld	a5,-48(s0)
ffffffe000200eb4:	00379793          	slli	a5,a5,0x3
ffffffe000200eb8:	fd843703          	ld	a4,-40(s0)
ffffffe000200ebc:	00f707b3          	add	a5,a4,a5
ffffffe000200ec0:	fe843703          	ld	a4,-24(s0)
ffffffe000200ec4:	00e7b023          	sd	a4,0(a5)

        va += PGSIZE;
ffffffe000200ec8:	fb043703          	ld	a4,-80(s0)
ffffffe000200ecc:	000017b7          	lui	a5,0x1
ffffffe000200ed0:	00f707b3          	add	a5,a4,a5
ffffffe000200ed4:	faf43823          	sd	a5,-80(s0)
        pa += PGSIZE;
ffffffe000200ed8:	fa843703          	ld	a4,-88(s0)
ffffffe000200edc:	000017b7          	lui	a5,0x1
ffffffe000200ee0:	00f707b3          	add	a5,a4,a5
ffffffe000200ee4:	faf43423          	sd	a5,-88(s0)
    while (va < va_end) {
ffffffe000200ee8:	fb043703          	ld	a4,-80(s0)
ffffffe000200eec:	fe043783          	ld	a5,-32(s0)
ffffffe000200ef0:	e6f762e3          	bltu	a4,a5,ffffffe000200d54 <create_mapping+0x6c>
    }
}
ffffffe000200ef4:	00000013          	nop
ffffffe000200ef8:	00000013          	nop
ffffffe000200efc:	06813083          	ld	ra,104(sp)
ffffffe000200f00:	06013403          	ld	s0,96(sp)
ffffffe000200f04:	07010113          	addi	sp,sp,112
ffffffe000200f08:	00008067          	ret

ffffffe000200f0c <setup_vm_final>:

void setup_vm_final(void) {
ffffffe000200f0c:	fd010113          	addi	sp,sp,-48
ffffffe000200f10:	02113423          	sd	ra,40(sp)
ffffffe000200f14:	02813023          	sd	s0,32(sp)
ffffffe000200f18:	03010413          	addi	s0,sp,48
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe000200f1c:	00001637          	lui	a2,0x1
ffffffe000200f20:	00000593          	li	a1,0
ffffffe000200f24:	00005517          	auipc	a0,0x5
ffffffe000200f28:	0dc50513          	addi	a0,a0,220 # ffffffe000206000 <swapper_pg_dir>
ffffffe000200f2c:	501000ef          	jal	ra,ffffffe000201c2c <memset>

    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    uint64 va = VM_START + OPENSBI_SIZE;
ffffffe000200f30:	f00017b7          	lui	a5,0xf0001
ffffffe000200f34:	00979793          	slli	a5,a5,0x9
ffffffe000200f38:	fef43423          	sd	a5,-24(s0)
    uint64 pa = PHY_START + OPENSBI_SIZE;
ffffffe000200f3c:	40100793          	li	a5,1025
ffffffe000200f40:	01579793          	slli	a5,a5,0x15
ffffffe000200f44:	fef43023          	sd	a5,-32(s0)
    create_mapping(swapper_pg_dir, va, pa, _srodata - _stext, PTE_X | PTE_R | PTE_V | PTE_A | PTE_D);
ffffffe000200f48:	00001717          	auipc	a4,0x1
ffffffe000200f4c:	0b870713          	addi	a4,a4,184 # ffffffe000202000 <_srodata>
ffffffe000200f50:	fffff797          	auipc	a5,0xfffff
ffffffe000200f54:	0b078793          	addi	a5,a5,176 # ffffffe000200000 <_skernel>
ffffffe000200f58:	40f707b3          	sub	a5,a4,a5
ffffffe000200f5c:	0cb00713          	li	a4,203
ffffffe000200f60:	00078693          	mv	a3,a5
ffffffe000200f64:	fe043603          	ld	a2,-32(s0)
ffffffe000200f68:	fe843583          	ld	a1,-24(s0)
ffffffe000200f6c:	00005517          	auipc	a0,0x5
ffffffe000200f70:	09450513          	addi	a0,a0,148 # ffffffe000206000 <swapper_pg_dir>
ffffffe000200f74:	d75ff0ef          	jal	ra,ffffffe000200ce8 <create_mapping>

    // mapping kernel rodata -|-|R|V
    va += _srodata - _stext;
ffffffe000200f78:	00001717          	auipc	a4,0x1
ffffffe000200f7c:	08870713          	addi	a4,a4,136 # ffffffe000202000 <_srodata>
ffffffe000200f80:	fffff797          	auipc	a5,0xfffff
ffffffe000200f84:	08078793          	addi	a5,a5,128 # ffffffe000200000 <_skernel>
ffffffe000200f88:	40f707b3          	sub	a5,a4,a5
ffffffe000200f8c:	00078713          	mv	a4,a5
ffffffe000200f90:	fe843783          	ld	a5,-24(s0)
ffffffe000200f94:	00e787b3          	add	a5,a5,a4
ffffffe000200f98:	fef43423          	sd	a5,-24(s0)
    pa += _srodata - _stext;
ffffffe000200f9c:	00001717          	auipc	a4,0x1
ffffffe000200fa0:	06470713          	addi	a4,a4,100 # ffffffe000202000 <_srodata>
ffffffe000200fa4:	fffff797          	auipc	a5,0xfffff
ffffffe000200fa8:	05c78793          	addi	a5,a5,92 # ffffffe000200000 <_skernel>
ffffffe000200fac:	40f707b3          	sub	a5,a4,a5
ffffffe000200fb0:	00078713          	mv	a4,a5
ffffffe000200fb4:	fe043783          	ld	a5,-32(s0)
ffffffe000200fb8:	00e787b3          	add	a5,a5,a4
ffffffe000200fbc:	fef43023          	sd	a5,-32(s0)
    create_mapping(swapper_pg_dir, va, pa, _sdata - _srodata, PTE_R | PTE_V | PTE_A | PTE_D);
ffffffe000200fc0:	00002717          	auipc	a4,0x2
ffffffe000200fc4:	04070713          	addi	a4,a4,64 # ffffffe000203000 <TIMECLOCK>
ffffffe000200fc8:	00001797          	auipc	a5,0x1
ffffffe000200fcc:	03878793          	addi	a5,a5,56 # ffffffe000202000 <_srodata>
ffffffe000200fd0:	40f707b3          	sub	a5,a4,a5
ffffffe000200fd4:	0c300713          	li	a4,195
ffffffe000200fd8:	00078693          	mv	a3,a5
ffffffe000200fdc:	fe043603          	ld	a2,-32(s0)
ffffffe000200fe0:	fe843583          	ld	a1,-24(s0)
ffffffe000200fe4:	00005517          	auipc	a0,0x5
ffffffe000200fe8:	01c50513          	addi	a0,a0,28 # ffffffe000206000 <swapper_pg_dir>
ffffffe000200fec:	cfdff0ef          	jal	ra,ffffffe000200ce8 <create_mapping>

    // mapping other memory -|W|R|V
    va += _sdata - _srodata;
ffffffe000200ff0:	00002717          	auipc	a4,0x2
ffffffe000200ff4:	01070713          	addi	a4,a4,16 # ffffffe000203000 <TIMECLOCK>
ffffffe000200ff8:	00001797          	auipc	a5,0x1
ffffffe000200ffc:	00878793          	addi	a5,a5,8 # ffffffe000202000 <_srodata>
ffffffe000201000:	40f707b3          	sub	a5,a4,a5
ffffffe000201004:	00078713          	mv	a4,a5
ffffffe000201008:	fe843783          	ld	a5,-24(s0)
ffffffe00020100c:	00e787b3          	add	a5,a5,a4
ffffffe000201010:	fef43423          	sd	a5,-24(s0)
    pa += _sdata - _srodata;
ffffffe000201014:	00002717          	auipc	a4,0x2
ffffffe000201018:	fec70713          	addi	a4,a4,-20 # ffffffe000203000 <TIMECLOCK>
ffffffe00020101c:	00001797          	auipc	a5,0x1
ffffffe000201020:	fe478793          	addi	a5,a5,-28 # ffffffe000202000 <_srodata>
ffffffe000201024:	40f707b3          	sub	a5,a4,a5
ffffffe000201028:	00078713          	mv	a4,a5
ffffffe00020102c:	fe043783          	ld	a5,-32(s0)
ffffffe000201030:	00e787b3          	add	a5,a5,a4
ffffffe000201034:	fef43023          	sd	a5,-32(s0)
    create_mapping(swapper_pg_dir, va, pa, PHY_SIZE - (_sdata - _stext), PTE_W | PTE_R | PTE_V | PTE_A | PTE_D);
ffffffe000201038:	00002717          	auipc	a4,0x2
ffffffe00020103c:	fc870713          	addi	a4,a4,-56 # ffffffe000203000 <TIMECLOCK>
ffffffe000201040:	fffff797          	auipc	a5,0xfffff
ffffffe000201044:	fc078793          	addi	a5,a5,-64 # ffffffe000200000 <_skernel>
ffffffe000201048:	40f707b3          	sub	a5,a4,a5
ffffffe00020104c:	00400737          	lui	a4,0x400
ffffffe000201050:	40f707b3          	sub	a5,a4,a5
ffffffe000201054:	0c700713          	li	a4,199
ffffffe000201058:	00078693          	mv	a3,a5
ffffffe00020105c:	fe043603          	ld	a2,-32(s0)
ffffffe000201060:	fe843583          	ld	a1,-24(s0)
ffffffe000201064:	00005517          	auipc	a0,0x5
ffffffe000201068:	f9c50513          	addi	a0,a0,-100 # ffffffe000206000 <swapper_pg_dir>
ffffffe00020106c:	c7dff0ef          	jal	ra,ffffffe000200ce8 <create_mapping>
  
    // set satp with swapper_pg_dir
    uint64 _satp = (((uint64)(swapper_pg_dir) - PA2VA_OFFSET) >> 12) | (8L << 60);
ffffffe000201070:	00005717          	auipc	a4,0x5
ffffffe000201074:	f9070713          	addi	a4,a4,-112 # ffffffe000206000 <swapper_pg_dir>
ffffffe000201078:	04100793          	li	a5,65
ffffffe00020107c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201080:	00f707b3          	add	a5,a4,a5
ffffffe000201084:	00c7d713          	srli	a4,a5,0xc
ffffffe000201088:	fff00793          	li	a5,-1
ffffffe00020108c:	03f79793          	slli	a5,a5,0x3f
ffffffe000201090:	00f767b3          	or	a5,a4,a5
ffffffe000201094:	fcf43c23          	sd	a5,-40(s0)
    csr_write(satp, _satp);
ffffffe000201098:	fd843783          	ld	a5,-40(s0)
ffffffe00020109c:	fcf43823          	sd	a5,-48(s0)
ffffffe0002010a0:	fd043783          	ld	a5,-48(s0)
ffffffe0002010a4:	18079073          	csrw	satp,a5
    printk("set satp to %lx\n", _satp);
ffffffe0002010a8:	fd843583          	ld	a1,-40(s0)
ffffffe0002010ac:	00001517          	auipc	a0,0x1
ffffffe0002010b0:	05450513          	addi	a0,a0,84 # ffffffe000202100 <_srodata+0x100>
ffffffe0002010b4:	7f8000ef          	jal	ra,ffffffe0002018ac <printk>

    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe0002010b8:	12000073          	sfence.vma

    // flush icache
    asm volatile("fence.i");
ffffffe0002010bc:	0000100f          	fence.i
    return;
ffffffe0002010c0:	00000013          	nop
}
ffffffe0002010c4:	02813083          	ld	ra,40(sp)
ffffffe0002010c8:	02013403          	ld	s0,32(sp)
ffffffe0002010cc:	03010113          	addi	sp,sp,48
ffffffe0002010d0:	00008067          	ret

ffffffe0002010d4 <start_kernel>:
#include "printk.h"

extern void test();

int start_kernel(int x) {
ffffffe0002010d4:	fe010113          	addi	sp,sp,-32
ffffffe0002010d8:	00113c23          	sd	ra,24(sp)
ffffffe0002010dc:	00813823          	sd	s0,16(sp)
ffffffe0002010e0:	02010413          	addi	s0,sp,32
ffffffe0002010e4:	00050793          	mv	a5,a0
ffffffe0002010e8:	fef42623          	sw	a5,-20(s0)
    printk("%d", x);
ffffffe0002010ec:	fec42783          	lw	a5,-20(s0)
ffffffe0002010f0:	00078593          	mv	a1,a5
ffffffe0002010f4:	00001517          	auipc	a0,0x1
ffffffe0002010f8:	02450513          	addi	a0,a0,36 # ffffffe000202118 <_srodata+0x118>
ffffffe0002010fc:	7b0000ef          	jal	ra,ffffffe0002018ac <printk>
    printk(" ZJU Computer System III\n");
ffffffe000201100:	00001517          	auipc	a0,0x1
ffffffe000201104:	02050513          	addi	a0,a0,32 # ffffffe000202120 <_srodata+0x120>
ffffffe000201108:	7a4000ef          	jal	ra,ffffffe0002018ac <printk>
    test(); // DO NOT DELETE !!!
ffffffe00020110c:	01c000ef          	jal	ra,ffffffe000201128 <test>
    return 0;
ffffffe000201110:	00000793          	li	a5,0
}
ffffffe000201114:	00078513          	mv	a0,a5
ffffffe000201118:	01813083          	ld	ra,24(sp)
ffffffe00020111c:	01013403          	ld	s0,16(sp)
ffffffe000201120:	02010113          	addi	sp,sp,32
ffffffe000201124:	00008067          	ret

ffffffe000201128 <test>:
#include "printk.h"
#include "defs.h"

// Please do not modify

void test() {
ffffffe000201128:	fe010113          	addi	sp,sp,-32
ffffffe00020112c:	00113c23          	sd	ra,24(sp)
ffffffe000201130:	00813823          	sd	s0,16(sp)
ffffffe000201134:	02010413          	addi	s0,sp,32
    unsigned long record_time = 0; 
ffffffe000201138:	fe043423          	sd	zero,-24(s0)
    while (1) {
        unsigned long present_time;
        __asm__ volatile("rdtime %[t]" : [t] "=r" (present_time) : : "memory");
ffffffe00020113c:	c01027f3          	rdtime	a5
ffffffe000201140:	fef43023          	sd	a5,-32(s0)
        present_time /= 10000000;
ffffffe000201144:	fe043703          	ld	a4,-32(s0)
ffffffe000201148:	009897b7          	lui	a5,0x989
ffffffe00020114c:	68078793          	addi	a5,a5,1664 # 989680 <_skernel-0xffffffdfff876980>
ffffffe000201150:	02f757b3          	divu	a5,a4,a5
ffffffe000201154:	fef43023          	sd	a5,-32(s0)
        if (record_time < present_time) {
ffffffe000201158:	fe843703          	ld	a4,-24(s0)
ffffffe00020115c:	fe043783          	ld	a5,-32(s0)
ffffffe000201160:	fcf77ee3          	bgeu	a4,a5,ffffffe00020113c <test+0x14>
            printk("kernel is running! Time: %lus\n", present_time);
ffffffe000201164:	fe043583          	ld	a1,-32(s0)
ffffffe000201168:	00001517          	auipc	a0,0x1
ffffffe00020116c:	fd850513          	addi	a0,a0,-40 # ffffffe000202140 <_srodata+0x140>
ffffffe000201170:	73c000ef          	jal	ra,ffffffe0002018ac <printk>
            record_time = present_time; 
ffffffe000201174:	fe043783          	ld	a5,-32(s0)
ffffffe000201178:	fef43423          	sd	a5,-24(s0)
    while (1) {
ffffffe00020117c:	fc1ff06f          	j	ffffffe00020113c <test+0x14>

ffffffe000201180 <int_mod>:
#include"math.h"
int int_mod(unsigned int v1,unsigned int v2){
ffffffe000201180:	fd010113          	addi	sp,sp,-48
ffffffe000201184:	02813423          	sd	s0,40(sp)
ffffffe000201188:	03010413          	addi	s0,sp,48
ffffffe00020118c:	00050793          	mv	a5,a0
ffffffe000201190:	00058713          	mv	a4,a1
ffffffe000201194:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201198:	00070793          	mv	a5,a4
ffffffe00020119c:	fcf42c23          	sw	a5,-40(s0)
    unsigned long long m1=v1;
ffffffe0002011a0:	fdc46783          	lwu	a5,-36(s0)
ffffffe0002011a4:	fef43423          	sd	a5,-24(s0)
    unsigned long long m2=v2;
ffffffe0002011a8:	fd846783          	lwu	a5,-40(s0)
ffffffe0002011ac:	fef43023          	sd	a5,-32(s0)
    m2<<=31;
ffffffe0002011b0:	fe043783          	ld	a5,-32(s0)
ffffffe0002011b4:	01f79793          	slli	a5,a5,0x1f
ffffffe0002011b8:	fef43023          	sd	a5,-32(s0)
    while(m1>=v2){
ffffffe0002011bc:	02c0006f          	j	ffffffe0002011e8 <int_mod+0x68>
        if(m2<m1){
ffffffe0002011c0:	fe043703          	ld	a4,-32(s0)
ffffffe0002011c4:	fe843783          	ld	a5,-24(s0)
ffffffe0002011c8:	00f77a63          	bgeu	a4,a5,ffffffe0002011dc <int_mod+0x5c>
            m1-=m2;
ffffffe0002011cc:	fe843703          	ld	a4,-24(s0)
ffffffe0002011d0:	fe043783          	ld	a5,-32(s0)
ffffffe0002011d4:	40f707b3          	sub	a5,a4,a5
ffffffe0002011d8:	fef43423          	sd	a5,-24(s0)
        }
        m2>>=1;
ffffffe0002011dc:	fe043783          	ld	a5,-32(s0)
ffffffe0002011e0:	0017d793          	srli	a5,a5,0x1
ffffffe0002011e4:	fef43023          	sd	a5,-32(s0)
    while(m1>=v2){
ffffffe0002011e8:	fd846783          	lwu	a5,-40(s0)
ffffffe0002011ec:	fe843703          	ld	a4,-24(s0)
ffffffe0002011f0:	fcf778e3          	bgeu	a4,a5,ffffffe0002011c0 <int_mod+0x40>
    }
    return m1;
ffffffe0002011f4:	fe843783          	ld	a5,-24(s0)
ffffffe0002011f8:	0007879b          	sext.w	a5,a5
}
ffffffe0002011fc:	00078513          	mv	a0,a5
ffffffe000201200:	02813403          	ld	s0,40(sp)
ffffffe000201204:	03010113          	addi	sp,sp,48
ffffffe000201208:	00008067          	ret

ffffffe00020120c <int_mul>:

int int_mul(unsigned int v1,unsigned int v2){
ffffffe00020120c:	fd010113          	addi	sp,sp,-48
ffffffe000201210:	02813423          	sd	s0,40(sp)
ffffffe000201214:	03010413          	addi	s0,sp,48
ffffffe000201218:	00050793          	mv	a5,a0
ffffffe00020121c:	00058713          	mv	a4,a1
ffffffe000201220:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201224:	00070793          	mv	a5,a4
ffffffe000201228:	fcf42c23          	sw	a5,-40(s0)
    unsigned long long res=0;
ffffffe00020122c:	fe043423          	sd	zero,-24(s0)
    while(v2&&v1){
ffffffe000201230:	03c0006f          	j	ffffffe00020126c <int_mul+0x60>
        if(v2&1){
ffffffe000201234:	fd842783          	lw	a5,-40(s0)
ffffffe000201238:	0017f793          	andi	a5,a5,1
ffffffe00020123c:	0007879b          	sext.w	a5,a5
ffffffe000201240:	00078a63          	beqz	a5,ffffffe000201254 <int_mul+0x48>
            res+=v1;
ffffffe000201244:	fdc46783          	lwu	a5,-36(s0)
ffffffe000201248:	fe843703          	ld	a4,-24(s0)
ffffffe00020124c:	00f707b3          	add	a5,a4,a5
ffffffe000201250:	fef43423          	sd	a5,-24(s0)
        }
        v2>>=1;
ffffffe000201254:	fd842783          	lw	a5,-40(s0)
ffffffe000201258:	0017d79b          	srliw	a5,a5,0x1
ffffffe00020125c:	fcf42c23          	sw	a5,-40(s0)
        v1<<=1;
ffffffe000201260:	fdc42783          	lw	a5,-36(s0)
ffffffe000201264:	0017979b          	slliw	a5,a5,0x1
ffffffe000201268:	fcf42e23          	sw	a5,-36(s0)
    while(v2&&v1){
ffffffe00020126c:	fd842783          	lw	a5,-40(s0)
ffffffe000201270:	0007879b          	sext.w	a5,a5
ffffffe000201274:	00078863          	beqz	a5,ffffffe000201284 <int_mul+0x78>
ffffffe000201278:	fdc42783          	lw	a5,-36(s0)
ffffffe00020127c:	0007879b          	sext.w	a5,a5
ffffffe000201280:	fa079ae3          	bnez	a5,ffffffe000201234 <int_mul+0x28>
    }
    return res;
ffffffe000201284:	fe843783          	ld	a5,-24(s0)
ffffffe000201288:	0007879b          	sext.w	a5,a5
}
ffffffe00020128c:	00078513          	mv	a0,a5
ffffffe000201290:	02813403          	ld	s0,40(sp)
ffffffe000201294:	03010113          	addi	sp,sp,48
ffffffe000201298:	00008067          	ret

ffffffe00020129c <int_div>:

int int_div(unsigned int v1,unsigned int v2){
ffffffe00020129c:	fc010113          	addi	sp,sp,-64
ffffffe0002012a0:	02813c23          	sd	s0,56(sp)
ffffffe0002012a4:	04010413          	addi	s0,sp,64
ffffffe0002012a8:	00050793          	mv	a5,a0
ffffffe0002012ac:	00058713          	mv	a4,a1
ffffffe0002012b0:	fcf42623          	sw	a5,-52(s0)
ffffffe0002012b4:	00070793          	mv	a5,a4
ffffffe0002012b8:	fcf42423          	sw	a5,-56(s0)
    unsigned long long m1=v1;
ffffffe0002012bc:	fcc46783          	lwu	a5,-52(s0)
ffffffe0002012c0:	fef43423          	sd	a5,-24(s0)
    unsigned long long m2=v2;
ffffffe0002012c4:	fc846783          	lwu	a5,-56(s0)
ffffffe0002012c8:	fef43023          	sd	a5,-32(s0)
    unsigned long long mask=(unsigned int)1<<31;
ffffffe0002012cc:	00100793          	li	a5,1
ffffffe0002012d0:	01f79793          	slli	a5,a5,0x1f
ffffffe0002012d4:	fcf43c23          	sd	a5,-40(s0)
    m2<<=31;
ffffffe0002012d8:	fe043783          	ld	a5,-32(s0)
ffffffe0002012dc:	01f79793          	slli	a5,a5,0x1f
ffffffe0002012e0:	fef43023          	sd	a5,-32(s0)
    unsigned long long res=0;
ffffffe0002012e4:	fc043823          	sd	zero,-48(s0)
    while(m1>=v2){
ffffffe0002012e8:	0480006f          	j	ffffffe000201330 <int_div+0x94>
        if(m2<m1){
ffffffe0002012ec:	fe043703          	ld	a4,-32(s0)
ffffffe0002012f0:	fe843783          	ld	a5,-24(s0)
ffffffe0002012f4:	02f77263          	bgeu	a4,a5,ffffffe000201318 <int_div+0x7c>
            m1-=m2;
ffffffe0002012f8:	fe843703          	ld	a4,-24(s0)
ffffffe0002012fc:	fe043783          	ld	a5,-32(s0)
ffffffe000201300:	40f707b3          	sub	a5,a4,a5
ffffffe000201304:	fef43423          	sd	a5,-24(s0)
            res|=mask;
ffffffe000201308:	fd043703          	ld	a4,-48(s0)
ffffffe00020130c:	fd843783          	ld	a5,-40(s0)
ffffffe000201310:	00f767b3          	or	a5,a4,a5
ffffffe000201314:	fcf43823          	sd	a5,-48(s0)
        }
        m2>>=1;
ffffffe000201318:	fe043783          	ld	a5,-32(s0)
ffffffe00020131c:	0017d793          	srli	a5,a5,0x1
ffffffe000201320:	fef43023          	sd	a5,-32(s0)
        mask>>=1;
ffffffe000201324:	fd843783          	ld	a5,-40(s0)
ffffffe000201328:	0017d793          	srli	a5,a5,0x1
ffffffe00020132c:	fcf43c23          	sd	a5,-40(s0)
    while(m1>=v2){
ffffffe000201330:	fc846783          	lwu	a5,-56(s0)
ffffffe000201334:	fe843703          	ld	a4,-24(s0)
ffffffe000201338:	faf77ae3          	bgeu	a4,a5,ffffffe0002012ec <int_div+0x50>
    }
    return res;
ffffffe00020133c:	fd043783          	ld	a5,-48(s0)
ffffffe000201340:	0007879b          	sext.w	a5,a5
ffffffe000201344:	00078513          	mv	a0,a5
ffffffe000201348:	03813403          	ld	s0,56(sp)
ffffffe00020134c:	04010113          	addi	sp,sp,64
ffffffe000201350:	00008067          	ret

ffffffe000201354 <putc>:
#include "printk.h"
#include "sbi.h"

void putc(char c) {
ffffffe000201354:	fe010113          	addi	sp,sp,-32
ffffffe000201358:	00113c23          	sd	ra,24(sp)
ffffffe00020135c:	00813823          	sd	s0,16(sp)
ffffffe000201360:	02010413          	addi	s0,sp,32
ffffffe000201364:	00050793          	mv	a5,a0
ffffffe000201368:	fef407a3          	sb	a5,-17(s0)
  sbi_ecall(SBI_PUTCHAR, 0, c, 0, 0, 0, 0, 0);
ffffffe00020136c:	fef44603          	lbu	a2,-17(s0)
ffffffe000201370:	00000893          	li	a7,0
ffffffe000201374:	00000813          	li	a6,0
ffffffe000201378:	00000793          	li	a5,0
ffffffe00020137c:	00000713          	li	a4,0
ffffffe000201380:	00000693          	li	a3,0
ffffffe000201384:	00000593          	li	a1,0
ffffffe000201388:	00100513          	li	a0,1
ffffffe00020138c:	e20ff0ef          	jal	ra,ffffffe0002009ac <sbi_ecall>
}
ffffffe000201390:	00000013          	nop
ffffffe000201394:	01813083          	ld	ra,24(sp)
ffffffe000201398:	01013403          	ld	s0,16(sp)
ffffffe00020139c:	02010113          	addi	sp,sp,32
ffffffe0002013a0:	00008067          	ret

ffffffe0002013a4 <vprintfmt>:

static int vprintfmt(void(*putch)(char), const char *fmt, va_list vl) {
ffffffe0002013a4:	f2010113          	addi	sp,sp,-224
ffffffe0002013a8:	0c113c23          	sd	ra,216(sp)
ffffffe0002013ac:	0c813823          	sd	s0,208(sp)
ffffffe0002013b0:	0e010413          	addi	s0,sp,224
ffffffe0002013b4:	f2a43c23          	sd	a0,-200(s0)
ffffffe0002013b8:	f2b43823          	sd	a1,-208(s0)
ffffffe0002013bc:	f2c43423          	sd	a2,-216(s0)
    int in_format = 0, longarg = 0;
ffffffe0002013c0:	fe042623          	sw	zero,-20(s0)
ffffffe0002013c4:	fe042423          	sw	zero,-24(s0)
    size_t pos = 0;
ffffffe0002013c8:	fe043023          	sd	zero,-32(s0)
    for( ; *fmt; fmt++) {
ffffffe0002013cc:	4b80006f          	j	ffffffe000201884 <vprintfmt+0x4e0>
        if (in_format) {
ffffffe0002013d0:	fec42783          	lw	a5,-20(s0)
ffffffe0002013d4:	0007879b          	sext.w	a5,a5
ffffffe0002013d8:	44078c63          	beqz	a5,ffffffe000201830 <vprintfmt+0x48c>
            switch(*fmt) {
ffffffe0002013dc:	f3043783          	ld	a5,-208(s0)
ffffffe0002013e0:	0007c783          	lbu	a5,0(a5)
ffffffe0002013e4:	0007879b          	sext.w	a5,a5
ffffffe0002013e8:	f9d7869b          	addiw	a3,a5,-99
ffffffe0002013ec:	0006871b          	sext.w	a4,a3
ffffffe0002013f0:	01500793          	li	a5,21
ffffffe0002013f4:	48e7e063          	bltu	a5,a4,ffffffe000201874 <vprintfmt+0x4d0>
ffffffe0002013f8:	02069793          	slli	a5,a3,0x20
ffffffe0002013fc:	0207d793          	srli	a5,a5,0x20
ffffffe000201400:	00279713          	slli	a4,a5,0x2
ffffffe000201404:	00001797          	auipc	a5,0x1
ffffffe000201408:	d5c78793          	addi	a5,a5,-676 # ffffffe000202160 <_srodata+0x160>
ffffffe00020140c:	00f707b3          	add	a5,a4,a5
ffffffe000201410:	0007a783          	lw	a5,0(a5)
ffffffe000201414:	0007871b          	sext.w	a4,a5
ffffffe000201418:	00001797          	auipc	a5,0x1
ffffffe00020141c:	d4878793          	addi	a5,a5,-696 # ffffffe000202160 <_srodata+0x160>
ffffffe000201420:	00f707b3          	add	a5,a4,a5
ffffffe000201424:	00078067          	jr	a5
                case 'l': { 
                    longarg = 1; 
ffffffe000201428:	00100793          	li	a5,1
ffffffe00020142c:	fef42423          	sw	a5,-24(s0)
                    break; 
ffffffe000201430:	4480006f          	j	ffffffe000201878 <vprintfmt+0x4d4>
                }
                
                case 'x': {
                    long num = longarg ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000201434:	fe842783          	lw	a5,-24(s0)
ffffffe000201438:	0007879b          	sext.w	a5,a5
ffffffe00020143c:	00078c63          	beqz	a5,ffffffe000201454 <vprintfmt+0xb0>
ffffffe000201440:	f2843783          	ld	a5,-216(s0)
ffffffe000201444:	00878713          	addi	a4,a5,8
ffffffe000201448:	f2e43423          	sd	a4,-216(s0)
ffffffe00020144c:	0007b783          	ld	a5,0(a5)
ffffffe000201450:	0140006f          	j	ffffffe000201464 <vprintfmt+0xc0>
ffffffe000201454:	f2843783          	ld	a5,-216(s0)
ffffffe000201458:	00878713          	addi	a4,a5,8
ffffffe00020145c:	f2e43423          	sd	a4,-216(s0)
ffffffe000201460:	0007a783          	lw	a5,0(a5)
ffffffe000201464:	f8f43c23          	sd	a5,-104(s0)

                    int hexdigits = int_mul(2 , (longarg ? sizeof(long) : sizeof(int)) - 1);
ffffffe000201468:	fe842783          	lw	a5,-24(s0)
ffffffe00020146c:	0007879b          	sext.w	a5,a5
ffffffe000201470:	00078663          	beqz	a5,ffffffe00020147c <vprintfmt+0xd8>
ffffffe000201474:	00700793          	li	a5,7
ffffffe000201478:	0080006f          	j	ffffffe000201480 <vprintfmt+0xdc>
ffffffe00020147c:	00300793          	li	a5,3
ffffffe000201480:	00078593          	mv	a1,a5
ffffffe000201484:	00200513          	li	a0,2
ffffffe000201488:	d85ff0ef          	jal	ra,ffffffe00020120c <int_mul>
ffffffe00020148c:	00050793          	mv	a5,a0
ffffffe000201490:	f8f42a23          	sw	a5,-108(s0)
                    for(int halfbyte = hexdigits; halfbyte >= 0; halfbyte--) {
ffffffe000201494:	f9442783          	lw	a5,-108(s0)
ffffffe000201498:	fcf42e23          	sw	a5,-36(s0)
ffffffe00020149c:	0900006f          	j	ffffffe00020152c <vprintfmt+0x188>
                        int hex = (num >> (int_mul(4,halfbyte))) & 0xF;
ffffffe0002014a0:	fdc42783          	lw	a5,-36(s0)
ffffffe0002014a4:	00078593          	mv	a1,a5
ffffffe0002014a8:	00400513          	li	a0,4
ffffffe0002014ac:	d61ff0ef          	jal	ra,ffffffe00020120c <int_mul>
ffffffe0002014b0:	00050793          	mv	a5,a0
ffffffe0002014b4:	00078713          	mv	a4,a5
ffffffe0002014b8:	f9843783          	ld	a5,-104(s0)
ffffffe0002014bc:	40e7d7b3          	sra	a5,a5,a4
ffffffe0002014c0:	0007879b          	sext.w	a5,a5
ffffffe0002014c4:	00f7f793          	andi	a5,a5,15
ffffffe0002014c8:	f8f42823          	sw	a5,-112(s0)
                        char hexchar = (hex < 10 ? '0' + hex : 'a' + hex - 10);
ffffffe0002014cc:	f9042783          	lw	a5,-112(s0)
ffffffe0002014d0:	0007871b          	sext.w	a4,a5
ffffffe0002014d4:	00900793          	li	a5,9
ffffffe0002014d8:	00e7cc63          	blt	a5,a4,ffffffe0002014f0 <vprintfmt+0x14c>
ffffffe0002014dc:	f9042783          	lw	a5,-112(s0)
ffffffe0002014e0:	0ff7f793          	zext.b	a5,a5
ffffffe0002014e4:	0307879b          	addiw	a5,a5,48
ffffffe0002014e8:	0ff7f793          	zext.b	a5,a5
ffffffe0002014ec:	0140006f          	j	ffffffe000201500 <vprintfmt+0x15c>
ffffffe0002014f0:	f9042783          	lw	a5,-112(s0)
ffffffe0002014f4:	0ff7f793          	zext.b	a5,a5
ffffffe0002014f8:	0577879b          	addiw	a5,a5,87
ffffffe0002014fc:	0ff7f793          	zext.b	a5,a5
ffffffe000201500:	f8f407a3          	sb	a5,-113(s0)
                        putch(hexchar);
ffffffe000201504:	f8f44703          	lbu	a4,-113(s0)
ffffffe000201508:	f3843783          	ld	a5,-200(s0)
ffffffe00020150c:	00070513          	mv	a0,a4
ffffffe000201510:	000780e7          	jalr	a5
                        pos++;
ffffffe000201514:	fe043783          	ld	a5,-32(s0)
ffffffe000201518:	00178793          	addi	a5,a5,1
ffffffe00020151c:	fef43023          	sd	a5,-32(s0)
                    for(int halfbyte = hexdigits; halfbyte >= 0; halfbyte--) {
ffffffe000201520:	fdc42783          	lw	a5,-36(s0)
ffffffe000201524:	fff7879b          	addiw	a5,a5,-1
ffffffe000201528:	fcf42e23          	sw	a5,-36(s0)
ffffffe00020152c:	fdc42783          	lw	a5,-36(s0)
ffffffe000201530:	0007879b          	sext.w	a5,a5
ffffffe000201534:	f607d6e3          	bgez	a5,ffffffe0002014a0 <vprintfmt+0xfc>
                    }
                    longarg = 0; in_format = 0; 
ffffffe000201538:	fe042423          	sw	zero,-24(s0)
ffffffe00020153c:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe000201540:	3380006f          	j	ffffffe000201878 <vprintfmt+0x4d4>
                }
            
                case 'd': {
                    long num = longarg ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000201544:	fe842783          	lw	a5,-24(s0)
ffffffe000201548:	0007879b          	sext.w	a5,a5
ffffffe00020154c:	00078c63          	beqz	a5,ffffffe000201564 <vprintfmt+0x1c0>
ffffffe000201550:	f2843783          	ld	a5,-216(s0)
ffffffe000201554:	00878713          	addi	a4,a5,8
ffffffe000201558:	f2e43423          	sd	a4,-216(s0)
ffffffe00020155c:	0007b783          	ld	a5,0(a5)
ffffffe000201560:	0140006f          	j	ffffffe000201574 <vprintfmt+0x1d0>
ffffffe000201564:	f2843783          	ld	a5,-216(s0)
ffffffe000201568:	00878713          	addi	a4,a5,8
ffffffe00020156c:	f2e43423          	sd	a4,-216(s0)
ffffffe000201570:	0007a783          	lw	a5,0(a5)
ffffffe000201574:	fcf43823          	sd	a5,-48(s0)
                    if (num < 0) {
ffffffe000201578:	fd043783          	ld	a5,-48(s0)
ffffffe00020157c:	0207d463          	bgez	a5,ffffffe0002015a4 <vprintfmt+0x200>
                        num = -num; putch('-');
ffffffe000201580:	fd043783          	ld	a5,-48(s0)
ffffffe000201584:	40f007b3          	neg	a5,a5
ffffffe000201588:	fcf43823          	sd	a5,-48(s0)
ffffffe00020158c:	f3843783          	ld	a5,-200(s0)
ffffffe000201590:	02d00513          	li	a0,45
ffffffe000201594:	000780e7          	jalr	a5
                        pos++;
ffffffe000201598:	fe043783          	ld	a5,-32(s0)
ffffffe00020159c:	00178793          	addi	a5,a5,1
ffffffe0002015a0:	fef43023          	sd	a5,-32(s0)
                    }
                    int bits = 0;
ffffffe0002015a4:	fc042623          	sw	zero,-52(s0)
                    char decchar[25] = {'0', 0};
ffffffe0002015a8:	03000793          	li	a5,48
ffffffe0002015ac:	f6f43023          	sd	a5,-160(s0)
ffffffe0002015b0:	f6043423          	sd	zero,-152(s0)
ffffffe0002015b4:	f6043823          	sd	zero,-144(s0)
ffffffe0002015b8:	f6040c23          	sb	zero,-136(s0)
                    for (long tmp = num; tmp; bits++) {
ffffffe0002015bc:	fd043783          	ld	a5,-48(s0)
ffffffe0002015c0:	fcf43023          	sd	a5,-64(s0)
ffffffe0002015c4:	0500006f          	j	ffffffe000201614 <vprintfmt+0x270>
                        decchar[bits] = (int_mod(tmp , 10)) + '0';
ffffffe0002015c8:	00a00593          	li	a1,10
ffffffe0002015cc:	fc043503          	ld	a0,-64(s0)
ffffffe0002015d0:	bb1ff0ef          	jal	ra,ffffffe000201180 <int_mod>
ffffffe0002015d4:	00050793          	mv	a5,a0
ffffffe0002015d8:	0ff7f793          	zext.b	a5,a5
ffffffe0002015dc:	0307879b          	addiw	a5,a5,48
ffffffe0002015e0:	0ff7f713          	zext.b	a4,a5
ffffffe0002015e4:	fcc42783          	lw	a5,-52(s0)
ffffffe0002015e8:	ff078793          	addi	a5,a5,-16
ffffffe0002015ec:	008787b3          	add	a5,a5,s0
ffffffe0002015f0:	f6e78823          	sb	a4,-144(a5)
                        tmp = int_div(tmp,10);
ffffffe0002015f4:	00a00593          	li	a1,10
ffffffe0002015f8:	fc043503          	ld	a0,-64(s0)
ffffffe0002015fc:	ca1ff0ef          	jal	ra,ffffffe00020129c <int_div>
ffffffe000201600:	00050793          	mv	a5,a0
ffffffe000201604:	fcf43023          	sd	a5,-64(s0)
                    for (long tmp = num; tmp; bits++) {
ffffffe000201608:	fcc42783          	lw	a5,-52(s0)
ffffffe00020160c:	0017879b          	addiw	a5,a5,1
ffffffe000201610:	fcf42623          	sw	a5,-52(s0)
ffffffe000201614:	fc043783          	ld	a5,-64(s0)
ffffffe000201618:	fa0798e3          	bnez	a5,ffffffe0002015c8 <vprintfmt+0x224>
                    }

                    for (int i = bits; i >= 0; i--) {
ffffffe00020161c:	fcc42783          	lw	a5,-52(s0)
ffffffe000201620:	faf42e23          	sw	a5,-68(s0)
ffffffe000201624:	02c0006f          	j	ffffffe000201650 <vprintfmt+0x2ac>
                        putch(decchar[i]);
ffffffe000201628:	fbc42783          	lw	a5,-68(s0)
ffffffe00020162c:	ff078793          	addi	a5,a5,-16
ffffffe000201630:	008787b3          	add	a5,a5,s0
ffffffe000201634:	f707c703          	lbu	a4,-144(a5)
ffffffe000201638:	f3843783          	ld	a5,-200(s0)
ffffffe00020163c:	00070513          	mv	a0,a4
ffffffe000201640:	000780e7          	jalr	a5
                    for (int i = bits; i >= 0; i--) {
ffffffe000201644:	fbc42783          	lw	a5,-68(s0)
ffffffe000201648:	fff7879b          	addiw	a5,a5,-1
ffffffe00020164c:	faf42e23          	sw	a5,-68(s0)
ffffffe000201650:	fbc42783          	lw	a5,-68(s0)
ffffffe000201654:	0007879b          	sext.w	a5,a5
ffffffe000201658:	fc07d8e3          	bgez	a5,ffffffe000201628 <vprintfmt+0x284>
                    }
                    pos += bits + 1;
ffffffe00020165c:	fcc42783          	lw	a5,-52(s0)
ffffffe000201660:	0017879b          	addiw	a5,a5,1
ffffffe000201664:	0007879b          	sext.w	a5,a5
ffffffe000201668:	00078713          	mv	a4,a5
ffffffe00020166c:	fe043783          	ld	a5,-32(s0)
ffffffe000201670:	00e787b3          	add	a5,a5,a4
ffffffe000201674:	fef43023          	sd	a5,-32(s0)
                    longarg = 0; in_format = 0; 
ffffffe000201678:	fe042423          	sw	zero,-24(s0)
ffffffe00020167c:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe000201680:	1f80006f          	j	ffffffe000201878 <vprintfmt+0x4d4>
                }

                case 'u': {
                    unsigned long num = longarg ? va_arg(vl, long) : va_arg(vl, int);
ffffffe000201684:	fe842783          	lw	a5,-24(s0)
ffffffe000201688:	0007879b          	sext.w	a5,a5
ffffffe00020168c:	00078c63          	beqz	a5,ffffffe0002016a4 <vprintfmt+0x300>
ffffffe000201690:	f2843783          	ld	a5,-216(s0)
ffffffe000201694:	00878713          	addi	a4,a5,8
ffffffe000201698:	f2e43423          	sd	a4,-216(s0)
ffffffe00020169c:	0007b783          	ld	a5,0(a5)
ffffffe0002016a0:	0140006f          	j	ffffffe0002016b4 <vprintfmt+0x310>
ffffffe0002016a4:	f2843783          	ld	a5,-216(s0)
ffffffe0002016a8:	00878713          	addi	a4,a5,8
ffffffe0002016ac:	f2e43423          	sd	a4,-216(s0)
ffffffe0002016b0:	0007a783          	lw	a5,0(a5)
ffffffe0002016b4:	f8f43023          	sd	a5,-128(s0)
                    int bits = 0;
ffffffe0002016b8:	fa042c23          	sw	zero,-72(s0)
                    char decchar[25] = {'0', 0};
ffffffe0002016bc:	03000793          	li	a5,48
ffffffe0002016c0:	f4f43023          	sd	a5,-192(s0)
ffffffe0002016c4:	f4043423          	sd	zero,-184(s0)
ffffffe0002016c8:	f4043823          	sd	zero,-176(s0)
ffffffe0002016cc:	f4040c23          	sb	zero,-168(s0)
                    for (long tmp = num; tmp; bits++) {
ffffffe0002016d0:	f8043783          	ld	a5,-128(s0)
ffffffe0002016d4:	faf43823          	sd	a5,-80(s0)
ffffffe0002016d8:	0500006f          	j	ffffffe000201728 <vprintfmt+0x384>
                        decchar[bits] = (int_mod(tmp , 10)) + '0';
ffffffe0002016dc:	00a00593          	li	a1,10
ffffffe0002016e0:	fb043503          	ld	a0,-80(s0)
ffffffe0002016e4:	a9dff0ef          	jal	ra,ffffffe000201180 <int_mod>
ffffffe0002016e8:	00050793          	mv	a5,a0
ffffffe0002016ec:	0ff7f793          	zext.b	a5,a5
ffffffe0002016f0:	0307879b          	addiw	a5,a5,48
ffffffe0002016f4:	0ff7f713          	zext.b	a4,a5
ffffffe0002016f8:	fb842783          	lw	a5,-72(s0)
ffffffe0002016fc:	ff078793          	addi	a5,a5,-16
ffffffe000201700:	008787b3          	add	a5,a5,s0
ffffffe000201704:	f4e78823          	sb	a4,-176(a5)
                        tmp = int_div(tmp,10);
ffffffe000201708:	00a00593          	li	a1,10
ffffffe00020170c:	fb043503          	ld	a0,-80(s0)
ffffffe000201710:	b8dff0ef          	jal	ra,ffffffe00020129c <int_div>
ffffffe000201714:	00050793          	mv	a5,a0
ffffffe000201718:	faf43823          	sd	a5,-80(s0)
                    for (long tmp = num; tmp; bits++) {
ffffffe00020171c:	fb842783          	lw	a5,-72(s0)
ffffffe000201720:	0017879b          	addiw	a5,a5,1
ffffffe000201724:	faf42c23          	sw	a5,-72(s0)
ffffffe000201728:	fb043783          	ld	a5,-80(s0)
ffffffe00020172c:	fa0798e3          	bnez	a5,ffffffe0002016dc <vprintfmt+0x338>
                    }

                    for (int i = bits; i >= 0; i--) {
ffffffe000201730:	fb842783          	lw	a5,-72(s0)
ffffffe000201734:	faf42623          	sw	a5,-84(s0)
ffffffe000201738:	02c0006f          	j	ffffffe000201764 <vprintfmt+0x3c0>
                        putch(decchar[i]);
ffffffe00020173c:	fac42783          	lw	a5,-84(s0)
ffffffe000201740:	ff078793          	addi	a5,a5,-16
ffffffe000201744:	008787b3          	add	a5,a5,s0
ffffffe000201748:	f507c703          	lbu	a4,-176(a5)
ffffffe00020174c:	f3843783          	ld	a5,-200(s0)
ffffffe000201750:	00070513          	mv	a0,a4
ffffffe000201754:	000780e7          	jalr	a5
                    for (int i = bits; i >= 0; i--) {
ffffffe000201758:	fac42783          	lw	a5,-84(s0)
ffffffe00020175c:	fff7879b          	addiw	a5,a5,-1
ffffffe000201760:	faf42623          	sw	a5,-84(s0)
ffffffe000201764:	fac42783          	lw	a5,-84(s0)
ffffffe000201768:	0007879b          	sext.w	a5,a5
ffffffe00020176c:	fc07d8e3          	bgez	a5,ffffffe00020173c <vprintfmt+0x398>
                    }
                    pos += bits + 1;
ffffffe000201770:	fb842783          	lw	a5,-72(s0)
ffffffe000201774:	0017879b          	addiw	a5,a5,1
ffffffe000201778:	0007879b          	sext.w	a5,a5
ffffffe00020177c:	00078713          	mv	a4,a5
ffffffe000201780:	fe043783          	ld	a5,-32(s0)
ffffffe000201784:	00e787b3          	add	a5,a5,a4
ffffffe000201788:	fef43023          	sd	a5,-32(s0)
                    longarg = 0; in_format = 0; 
ffffffe00020178c:	fe042423          	sw	zero,-24(s0)
ffffffe000201790:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe000201794:	0e40006f          	j	ffffffe000201878 <vprintfmt+0x4d4>
                }

                case 's': {
                    const char* str = va_arg(vl, const char*);
ffffffe000201798:	f2843783          	ld	a5,-216(s0)
ffffffe00020179c:	00878713          	addi	a4,a5,8
ffffffe0002017a0:	f2e43423          	sd	a4,-216(s0)
ffffffe0002017a4:	0007b783          	ld	a5,0(a5)
ffffffe0002017a8:	faf43023          	sd	a5,-96(s0)
                    while (*str) {
ffffffe0002017ac:	0300006f          	j	ffffffe0002017dc <vprintfmt+0x438>
                        putch(*str);
ffffffe0002017b0:	fa043783          	ld	a5,-96(s0)
ffffffe0002017b4:	0007c703          	lbu	a4,0(a5)
ffffffe0002017b8:	f3843783          	ld	a5,-200(s0)
ffffffe0002017bc:	00070513          	mv	a0,a4
ffffffe0002017c0:	000780e7          	jalr	a5
                        pos++; 
ffffffe0002017c4:	fe043783          	ld	a5,-32(s0)
ffffffe0002017c8:	00178793          	addi	a5,a5,1
ffffffe0002017cc:	fef43023          	sd	a5,-32(s0)
                        str++;
ffffffe0002017d0:	fa043783          	ld	a5,-96(s0)
ffffffe0002017d4:	00178793          	addi	a5,a5,1
ffffffe0002017d8:	faf43023          	sd	a5,-96(s0)
                    while (*str) {
ffffffe0002017dc:	fa043783          	ld	a5,-96(s0)
ffffffe0002017e0:	0007c783          	lbu	a5,0(a5)
ffffffe0002017e4:	fc0796e3          	bnez	a5,ffffffe0002017b0 <vprintfmt+0x40c>
                    }
                    longarg = 0; in_format = 0; 
ffffffe0002017e8:	fe042423          	sw	zero,-24(s0)
ffffffe0002017ec:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe0002017f0:	0880006f          	j	ffffffe000201878 <vprintfmt+0x4d4>
                }

                case 'c': {
                    char ch = (char)va_arg(vl,int);
ffffffe0002017f4:	f2843783          	ld	a5,-216(s0)
ffffffe0002017f8:	00878713          	addi	a4,a5,8
ffffffe0002017fc:	f2e43423          	sd	a4,-216(s0)
ffffffe000201800:	0007a783          	lw	a5,0(a5)
ffffffe000201804:	f6f40fa3          	sb	a5,-129(s0)
                    putch(ch);
ffffffe000201808:	f7f44703          	lbu	a4,-129(s0)
ffffffe00020180c:	f3843783          	ld	a5,-200(s0)
ffffffe000201810:	00070513          	mv	a0,a4
ffffffe000201814:	000780e7          	jalr	a5
                    pos++;
ffffffe000201818:	fe043783          	ld	a5,-32(s0)
ffffffe00020181c:	00178793          	addi	a5,a5,1
ffffffe000201820:	fef43023          	sd	a5,-32(s0)
                    longarg = 0; in_format = 0; 
ffffffe000201824:	fe042423          	sw	zero,-24(s0)
ffffffe000201828:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe00020182c:	04c0006f          	j	ffffffe000201878 <vprintfmt+0x4d4>
                }
                default:
                    break;
            }
        }
        else if(*fmt == '%') {
ffffffe000201830:	f3043783          	ld	a5,-208(s0)
ffffffe000201834:	0007c783          	lbu	a5,0(a5)
ffffffe000201838:	00078713          	mv	a4,a5
ffffffe00020183c:	02500793          	li	a5,37
ffffffe000201840:	00f71863          	bne	a4,a5,ffffffe000201850 <vprintfmt+0x4ac>
          in_format = 1;
ffffffe000201844:	00100793          	li	a5,1
ffffffe000201848:	fef42623          	sw	a5,-20(s0)
ffffffe00020184c:	02c0006f          	j	ffffffe000201878 <vprintfmt+0x4d4>
        }
        else {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
            putch(*fmt);
ffffffe000201850:	f3043783          	ld	a5,-208(s0)
ffffffe000201854:	0007c703          	lbu	a4,0(a5)
ffffffe000201858:	f3843783          	ld	a5,-200(s0)
ffffffe00020185c:	00070513          	mv	a0,a4
ffffffe000201860:	000780e7          	jalr	a5
            pos++;
ffffffe000201864:	fe043783          	ld	a5,-32(s0)
ffffffe000201868:	00178793          	addi	a5,a5,1
ffffffe00020186c:	fef43023          	sd	a5,-32(s0)
ffffffe000201870:	0080006f          	j	ffffffe000201878 <vprintfmt+0x4d4>
                    break;
ffffffe000201874:	00000013          	nop
    for( ; *fmt; fmt++) {
ffffffe000201878:	f3043783          	ld	a5,-208(s0)
ffffffe00020187c:	00178793          	addi	a5,a5,1
ffffffe000201880:	f2f43823          	sd	a5,-208(s0)
ffffffe000201884:	f3043783          	ld	a5,-208(s0)
ffffffe000201888:	0007c783          	lbu	a5,0(a5)
ffffffe00020188c:	b40792e3          	bnez	a5,ffffffe0002013d0 <vprintfmt+0x2c>
        }
    }
    return pos;
ffffffe000201890:	fe043783          	ld	a5,-32(s0)
ffffffe000201894:	0007879b          	sext.w	a5,a5
}
ffffffe000201898:	00078513          	mv	a0,a5
ffffffe00020189c:	0d813083          	ld	ra,216(sp)
ffffffe0002018a0:	0d013403          	ld	s0,208(sp)
ffffffe0002018a4:	0e010113          	addi	sp,sp,224
ffffffe0002018a8:	00008067          	ret

ffffffe0002018ac <printk>:



int printk(const char* s, ...) {
ffffffe0002018ac:	f9010113          	addi	sp,sp,-112
ffffffe0002018b0:	02113423          	sd	ra,40(sp)
ffffffe0002018b4:	02813023          	sd	s0,32(sp)
ffffffe0002018b8:	03010413          	addi	s0,sp,48
ffffffe0002018bc:	fca43c23          	sd	a0,-40(s0)
ffffffe0002018c0:	00b43423          	sd	a1,8(s0)
ffffffe0002018c4:	00c43823          	sd	a2,16(s0)
ffffffe0002018c8:	00d43c23          	sd	a3,24(s0)
ffffffe0002018cc:	02e43023          	sd	a4,32(s0)
ffffffe0002018d0:	02f43423          	sd	a5,40(s0)
ffffffe0002018d4:	03043823          	sd	a6,48(s0)
ffffffe0002018d8:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe0002018dc:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe0002018e0:	04040793          	addi	a5,s0,64
ffffffe0002018e4:	fcf43823          	sd	a5,-48(s0)
ffffffe0002018e8:	fd043783          	ld	a5,-48(s0)
ffffffe0002018ec:	fc878793          	addi	a5,a5,-56
ffffffe0002018f0:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe0002018f4:	fe043783          	ld	a5,-32(s0)
ffffffe0002018f8:	00078613          	mv	a2,a5
ffffffe0002018fc:	fd843583          	ld	a1,-40(s0)
ffffffe000201900:	00000517          	auipc	a0,0x0
ffffffe000201904:	a5450513          	addi	a0,a0,-1452 # ffffffe000201354 <putc>
ffffffe000201908:	a9dff0ef          	jal	ra,ffffffe0002013a4 <vprintfmt>
ffffffe00020190c:	00050793          	mv	a5,a0
ffffffe000201910:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe000201914:	fec42783          	lw	a5,-20(s0)
}
ffffffe000201918:	00078513          	mv	a0,a5
ffffffe00020191c:	02813083          	ld	ra,40(sp)
ffffffe000201920:	02013403          	ld	s0,32(sp)
ffffffe000201924:	07010113          	addi	sp,sp,112
ffffffe000201928:	00008067          	ret

ffffffe00020192c <rand>:

int initialize = 0;
int r[1000];
int t = 0;

uint64 rand() {
ffffffe00020192c:	fe010113          	addi	sp,sp,-32
ffffffe000201930:	00813c23          	sd	s0,24(sp)
ffffffe000201934:	02010413          	addi	s0,sp,32
    int i;

    if (initialize == 0) {
ffffffe000201938:	00002797          	auipc	a5,0x2
ffffffe00020193c:	6e078793          	addi	a5,a5,1760 # ffffffe000204018 <initialize>
ffffffe000201940:	0007a783          	lw	a5,0(a5)
ffffffe000201944:	1e079463          	bnez	a5,ffffffe000201b2c <rand+0x200>
        r[0] = SEED;
ffffffe000201948:	00005797          	auipc	a5,0x5
ffffffe00020194c:	6b878793          	addi	a5,a5,1720 # ffffffe000207000 <r>
ffffffe000201950:	00d00713          	li	a4,13
ffffffe000201954:	00e7a023          	sw	a4,0(a5)
        for (i = 1; i < 31; i++) {
ffffffe000201958:	00100793          	li	a5,1
ffffffe00020195c:	fef42623          	sw	a5,-20(s0)
ffffffe000201960:	0c40006f          	j	ffffffe000201a24 <rand+0xf8>
            r[i] = (16807LL * r[i - 1]) % 2147483647;
ffffffe000201964:	fec42783          	lw	a5,-20(s0)
ffffffe000201968:	fff7879b          	addiw	a5,a5,-1
ffffffe00020196c:	0007879b          	sext.w	a5,a5
ffffffe000201970:	00005717          	auipc	a4,0x5
ffffffe000201974:	69070713          	addi	a4,a4,1680 # ffffffe000207000 <r>
ffffffe000201978:	00279793          	slli	a5,a5,0x2
ffffffe00020197c:	00f707b3          	add	a5,a4,a5
ffffffe000201980:	0007a783          	lw	a5,0(a5)
ffffffe000201984:	00078713          	mv	a4,a5
ffffffe000201988:	000047b7          	lui	a5,0x4
ffffffe00020198c:	1a778793          	addi	a5,a5,423 # 41a7 <_skernel-0xffffffe0001fbe59>
ffffffe000201990:	02f70733          	mul	a4,a4,a5
ffffffe000201994:	800007b7          	lui	a5,0x80000
ffffffe000201998:	fff7c793          	not	a5,a5
ffffffe00020199c:	02f767b3          	rem	a5,a4,a5
ffffffe0002019a0:	0007871b          	sext.w	a4,a5
ffffffe0002019a4:	00005697          	auipc	a3,0x5
ffffffe0002019a8:	65c68693          	addi	a3,a3,1628 # ffffffe000207000 <r>
ffffffe0002019ac:	fec42783          	lw	a5,-20(s0)
ffffffe0002019b0:	00279793          	slli	a5,a5,0x2
ffffffe0002019b4:	00f687b3          	add	a5,a3,a5
ffffffe0002019b8:	00e7a023          	sw	a4,0(a5) # ffffffff80000000 <_estack+0x1f7fdf7000>
            if (r[i] < 0) {
ffffffe0002019bc:	00005717          	auipc	a4,0x5
ffffffe0002019c0:	64470713          	addi	a4,a4,1604 # ffffffe000207000 <r>
ffffffe0002019c4:	fec42783          	lw	a5,-20(s0)
ffffffe0002019c8:	00279793          	slli	a5,a5,0x2
ffffffe0002019cc:	00f707b3          	add	a5,a4,a5
ffffffe0002019d0:	0007a783          	lw	a5,0(a5)
ffffffe0002019d4:	0407d263          	bgez	a5,ffffffe000201a18 <rand+0xec>
                r[i] += 2147483647;
ffffffe0002019d8:	00005717          	auipc	a4,0x5
ffffffe0002019dc:	62870713          	addi	a4,a4,1576 # ffffffe000207000 <r>
ffffffe0002019e0:	fec42783          	lw	a5,-20(s0)
ffffffe0002019e4:	00279793          	slli	a5,a5,0x2
ffffffe0002019e8:	00f707b3          	add	a5,a4,a5
ffffffe0002019ec:	0007a703          	lw	a4,0(a5)
ffffffe0002019f0:	800007b7          	lui	a5,0x80000
ffffffe0002019f4:	fff7c793          	not	a5,a5
ffffffe0002019f8:	00f707bb          	addw	a5,a4,a5
ffffffe0002019fc:	0007871b          	sext.w	a4,a5
ffffffe000201a00:	00005697          	auipc	a3,0x5
ffffffe000201a04:	60068693          	addi	a3,a3,1536 # ffffffe000207000 <r>
ffffffe000201a08:	fec42783          	lw	a5,-20(s0)
ffffffe000201a0c:	00279793          	slli	a5,a5,0x2
ffffffe000201a10:	00f687b3          	add	a5,a3,a5
ffffffe000201a14:	00e7a023          	sw	a4,0(a5) # ffffffff80000000 <_estack+0x1f7fdf7000>
        for (i = 1; i < 31; i++) {
ffffffe000201a18:	fec42783          	lw	a5,-20(s0)
ffffffe000201a1c:	0017879b          	addiw	a5,a5,1
ffffffe000201a20:	fef42623          	sw	a5,-20(s0)
ffffffe000201a24:	fec42783          	lw	a5,-20(s0)
ffffffe000201a28:	0007871b          	sext.w	a4,a5
ffffffe000201a2c:	01e00793          	li	a5,30
ffffffe000201a30:	f2e7dae3          	bge	a5,a4,ffffffe000201964 <rand+0x38>
            }
        }
        for (i = 31; i < 34; i++) {
ffffffe000201a34:	01f00793          	li	a5,31
ffffffe000201a38:	fef42623          	sw	a5,-20(s0)
ffffffe000201a3c:	0480006f          	j	ffffffe000201a84 <rand+0x158>
            r[i] = r[i - 31];
ffffffe000201a40:	fec42783          	lw	a5,-20(s0)
ffffffe000201a44:	fe17879b          	addiw	a5,a5,-31
ffffffe000201a48:	0007879b          	sext.w	a5,a5
ffffffe000201a4c:	00005717          	auipc	a4,0x5
ffffffe000201a50:	5b470713          	addi	a4,a4,1460 # ffffffe000207000 <r>
ffffffe000201a54:	00279793          	slli	a5,a5,0x2
ffffffe000201a58:	00f707b3          	add	a5,a4,a5
ffffffe000201a5c:	0007a703          	lw	a4,0(a5)
ffffffe000201a60:	00005697          	auipc	a3,0x5
ffffffe000201a64:	5a068693          	addi	a3,a3,1440 # ffffffe000207000 <r>
ffffffe000201a68:	fec42783          	lw	a5,-20(s0)
ffffffe000201a6c:	00279793          	slli	a5,a5,0x2
ffffffe000201a70:	00f687b3          	add	a5,a3,a5
ffffffe000201a74:	00e7a023          	sw	a4,0(a5)
        for (i = 31; i < 34; i++) {
ffffffe000201a78:	fec42783          	lw	a5,-20(s0)
ffffffe000201a7c:	0017879b          	addiw	a5,a5,1
ffffffe000201a80:	fef42623          	sw	a5,-20(s0)
ffffffe000201a84:	fec42783          	lw	a5,-20(s0)
ffffffe000201a88:	0007871b          	sext.w	a4,a5
ffffffe000201a8c:	02100793          	li	a5,33
ffffffe000201a90:	fae7d8e3          	bge	a5,a4,ffffffe000201a40 <rand+0x114>
        }
        for (i = 34; i < 344; i++) {
ffffffe000201a94:	02200793          	li	a5,34
ffffffe000201a98:	fef42623          	sw	a5,-20(s0)
ffffffe000201a9c:	0700006f          	j	ffffffe000201b0c <rand+0x1e0>
            r[i] = r[i - 31] + r[i - 3];
ffffffe000201aa0:	fec42783          	lw	a5,-20(s0)
ffffffe000201aa4:	fe17879b          	addiw	a5,a5,-31
ffffffe000201aa8:	0007879b          	sext.w	a5,a5
ffffffe000201aac:	00005717          	auipc	a4,0x5
ffffffe000201ab0:	55470713          	addi	a4,a4,1364 # ffffffe000207000 <r>
ffffffe000201ab4:	00279793          	slli	a5,a5,0x2
ffffffe000201ab8:	00f707b3          	add	a5,a4,a5
ffffffe000201abc:	0007a703          	lw	a4,0(a5)
ffffffe000201ac0:	fec42783          	lw	a5,-20(s0)
ffffffe000201ac4:	ffd7879b          	addiw	a5,a5,-3
ffffffe000201ac8:	0007879b          	sext.w	a5,a5
ffffffe000201acc:	00005697          	auipc	a3,0x5
ffffffe000201ad0:	53468693          	addi	a3,a3,1332 # ffffffe000207000 <r>
ffffffe000201ad4:	00279793          	slli	a5,a5,0x2
ffffffe000201ad8:	00f687b3          	add	a5,a3,a5
ffffffe000201adc:	0007a783          	lw	a5,0(a5)
ffffffe000201ae0:	00f707bb          	addw	a5,a4,a5
ffffffe000201ae4:	0007871b          	sext.w	a4,a5
ffffffe000201ae8:	00005697          	auipc	a3,0x5
ffffffe000201aec:	51868693          	addi	a3,a3,1304 # ffffffe000207000 <r>
ffffffe000201af0:	fec42783          	lw	a5,-20(s0)
ffffffe000201af4:	00279793          	slli	a5,a5,0x2
ffffffe000201af8:	00f687b3          	add	a5,a3,a5
ffffffe000201afc:	00e7a023          	sw	a4,0(a5)
        for (i = 34; i < 344; i++) {
ffffffe000201b00:	fec42783          	lw	a5,-20(s0)
ffffffe000201b04:	0017879b          	addiw	a5,a5,1
ffffffe000201b08:	fef42623          	sw	a5,-20(s0)
ffffffe000201b0c:	fec42783          	lw	a5,-20(s0)
ffffffe000201b10:	0007871b          	sext.w	a4,a5
ffffffe000201b14:	15700793          	li	a5,343
ffffffe000201b18:	f8e7d4e3          	bge	a5,a4,ffffffe000201aa0 <rand+0x174>
        }

		initialize = 1;
ffffffe000201b1c:	00002797          	auipc	a5,0x2
ffffffe000201b20:	4fc78793          	addi	a5,a5,1276 # ffffffe000204018 <initialize>
ffffffe000201b24:	00100713          	li	a4,1
ffffffe000201b28:	00e7a023          	sw	a4,0(a5)
    }

	t = t % 656;
ffffffe000201b2c:	00002797          	auipc	a5,0x2
ffffffe000201b30:	4f078793          	addi	a5,a5,1264 # ffffffe00020401c <t>
ffffffe000201b34:	0007a783          	lw	a5,0(a5)
ffffffe000201b38:	00078713          	mv	a4,a5
ffffffe000201b3c:	29000793          	li	a5,656
ffffffe000201b40:	02f767bb          	remw	a5,a4,a5
ffffffe000201b44:	0007871b          	sext.w	a4,a5
ffffffe000201b48:	00002797          	auipc	a5,0x2
ffffffe000201b4c:	4d478793          	addi	a5,a5,1236 # ffffffe00020401c <t>
ffffffe000201b50:	00e7a023          	sw	a4,0(a5)

    r[t + 344] = r[t + 344 - 31] + r[t + 344 - 3];
ffffffe000201b54:	00002797          	auipc	a5,0x2
ffffffe000201b58:	4c878793          	addi	a5,a5,1224 # ffffffe00020401c <t>
ffffffe000201b5c:	0007a783          	lw	a5,0(a5)
ffffffe000201b60:	1397879b          	addiw	a5,a5,313
ffffffe000201b64:	0007879b          	sext.w	a5,a5
ffffffe000201b68:	00005717          	auipc	a4,0x5
ffffffe000201b6c:	49870713          	addi	a4,a4,1176 # ffffffe000207000 <r>
ffffffe000201b70:	00279793          	slli	a5,a5,0x2
ffffffe000201b74:	00f707b3          	add	a5,a4,a5
ffffffe000201b78:	0007a683          	lw	a3,0(a5)
ffffffe000201b7c:	00002797          	auipc	a5,0x2
ffffffe000201b80:	4a078793          	addi	a5,a5,1184 # ffffffe00020401c <t>
ffffffe000201b84:	0007a783          	lw	a5,0(a5)
ffffffe000201b88:	1557879b          	addiw	a5,a5,341
ffffffe000201b8c:	0007879b          	sext.w	a5,a5
ffffffe000201b90:	00005717          	auipc	a4,0x5
ffffffe000201b94:	47070713          	addi	a4,a4,1136 # ffffffe000207000 <r>
ffffffe000201b98:	00279793          	slli	a5,a5,0x2
ffffffe000201b9c:	00f707b3          	add	a5,a4,a5
ffffffe000201ba0:	0007a703          	lw	a4,0(a5)
ffffffe000201ba4:	00002797          	auipc	a5,0x2
ffffffe000201ba8:	47878793          	addi	a5,a5,1144 # ffffffe00020401c <t>
ffffffe000201bac:	0007a783          	lw	a5,0(a5)
ffffffe000201bb0:	1587879b          	addiw	a5,a5,344
ffffffe000201bb4:	0007879b          	sext.w	a5,a5
ffffffe000201bb8:	00e6873b          	addw	a4,a3,a4
ffffffe000201bbc:	0007071b          	sext.w	a4,a4
ffffffe000201bc0:	00005697          	auipc	a3,0x5
ffffffe000201bc4:	44068693          	addi	a3,a3,1088 # ffffffe000207000 <r>
ffffffe000201bc8:	00279793          	slli	a5,a5,0x2
ffffffe000201bcc:	00f687b3          	add	a5,a3,a5
ffffffe000201bd0:	00e7a023          	sw	a4,0(a5)
    
	t++;
ffffffe000201bd4:	00002797          	auipc	a5,0x2
ffffffe000201bd8:	44878793          	addi	a5,a5,1096 # ffffffe00020401c <t>
ffffffe000201bdc:	0007a783          	lw	a5,0(a5)
ffffffe000201be0:	0017879b          	addiw	a5,a5,1
ffffffe000201be4:	0007871b          	sext.w	a4,a5
ffffffe000201be8:	00002797          	auipc	a5,0x2
ffffffe000201bec:	43478793          	addi	a5,a5,1076 # ffffffe00020401c <t>
ffffffe000201bf0:	00e7a023          	sw	a4,0(a5)

    return (uint64)r[t - 1 + 344];
ffffffe000201bf4:	00002797          	auipc	a5,0x2
ffffffe000201bf8:	42878793          	addi	a5,a5,1064 # ffffffe00020401c <t>
ffffffe000201bfc:	0007a783          	lw	a5,0(a5)
ffffffe000201c00:	1577879b          	addiw	a5,a5,343
ffffffe000201c04:	0007879b          	sext.w	a5,a5
ffffffe000201c08:	00005717          	auipc	a4,0x5
ffffffe000201c0c:	3f870713          	addi	a4,a4,1016 # ffffffe000207000 <r>
ffffffe000201c10:	00279793          	slli	a5,a5,0x2
ffffffe000201c14:	00f707b3          	add	a5,a4,a5
ffffffe000201c18:	0007a783          	lw	a5,0(a5)
}
ffffffe000201c1c:	00078513          	mv	a0,a5
ffffffe000201c20:	01813403          	ld	s0,24(sp)
ffffffe000201c24:	02010113          	addi	sp,sp,32
ffffffe000201c28:	00008067          	ret

ffffffe000201c2c <memset>:
#include "string.h"
#include "types.h"

void *memset(void *dst, int c, uint64 n) {
ffffffe000201c2c:	fc010113          	addi	sp,sp,-64
ffffffe000201c30:	02813c23          	sd	s0,56(sp)
ffffffe000201c34:	04010413          	addi	s0,sp,64
ffffffe000201c38:	fca43c23          	sd	a0,-40(s0)
ffffffe000201c3c:	00058793          	mv	a5,a1
ffffffe000201c40:	fcc43423          	sd	a2,-56(s0)
ffffffe000201c44:	fcf42a23          	sw	a5,-44(s0)
    char *cdst = (char *)dst;
ffffffe000201c48:	fd843783          	ld	a5,-40(s0)
ffffffe000201c4c:	fef43023          	sd	a5,-32(s0)
    for (uint64 i = 0; i < n; ++i)
ffffffe000201c50:	fe043423          	sd	zero,-24(s0)
ffffffe000201c54:	0280006f          	j	ffffffe000201c7c <memset+0x50>
        cdst[i] = c;
ffffffe000201c58:	fe043703          	ld	a4,-32(s0)
ffffffe000201c5c:	fe843783          	ld	a5,-24(s0)
ffffffe000201c60:	00f707b3          	add	a5,a4,a5
ffffffe000201c64:	fd442703          	lw	a4,-44(s0)
ffffffe000201c68:	0ff77713          	zext.b	a4,a4
ffffffe000201c6c:	00e78023          	sb	a4,0(a5)
    for (uint64 i = 0; i < n; ++i)
ffffffe000201c70:	fe843783          	ld	a5,-24(s0)
ffffffe000201c74:	00178793          	addi	a5,a5,1
ffffffe000201c78:	fef43423          	sd	a5,-24(s0)
ffffffe000201c7c:	fe843703          	ld	a4,-24(s0)
ffffffe000201c80:	fc843783          	ld	a5,-56(s0)
ffffffe000201c84:	fcf76ae3          	bltu	a4,a5,ffffffe000201c58 <memset+0x2c>

    return dst;
ffffffe000201c88:	fd843783          	ld	a5,-40(s0)
}
ffffffe000201c8c:	00078513          	mv	a0,a5
ffffffe000201c90:	03813403          	ld	s0,56(sp)
ffffffe000201c94:	04010113          	addi	sp,sp,64
ffffffe000201c98:	00008067          	ret
