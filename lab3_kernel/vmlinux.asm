
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
ffffffe000200024:	6b5000ef          	jal	ra,ffffffe000200ed8 <setup_vm_final>
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
ffffffe000200050:	0500106f          	j	ffffffe0002010a0 <start_kernel>

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
ffffffe0002003d8:	45c010ef          	jal	ra,ffffffe000201834 <printk>
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
ffffffe0002004bc:	44d000ef          	jal	ra,ffffffe000201108 <int_mod>
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
ffffffe000200548:	2ec010ef          	jal	ra,ffffffe000201834 <printk>
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
ffffffe0002005f4:	315000ef          	jal	ra,ffffffe000201108 <int_mod>
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
ffffffe000200634:	200010ef          	jal	ra,ffffffe000201834 <printk>
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
ffffffe0002006d0:	164010ef          	jal	ra,ffffffe000201834 <printk>
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
ffffffe000200904:	731000ef          	jal	ra,ffffffe000201834 <printk>
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
ffffffe000200968:	6cd000ef          	jal	ra,ffffffe000201834 <printk>
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
ffffffe000200bc0:	7f5000ef          	jal	ra,ffffffe000201bb4 <memset>

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
    uint64 va_end = va + sz;
ffffffe000200d0c:	fb043703          	ld	a4,-80(s0)
ffffffe000200d10:	fa043783          	ld	a5,-96(s0)
ffffffe000200d14:	00f707b3          	add	a5,a4,a5
ffffffe000200d18:	fef43023          	sd	a5,-32(s0)
    uint64 *cur_tbl, cur_vpn, cur_pte;
    while (va < va_end) {
ffffffe000200d1c:	1980006f          	j	ffffffe000200eb4 <create_mapping+0x1cc>
        // 第一级
        cur_tbl = pgtbl;
ffffffe000200d20:	fb843783          	ld	a5,-72(s0)
ffffffe000200d24:	fcf43c23          	sd	a5,-40(s0)
        cur_vpn = VPN2(va);
ffffffe000200d28:	fb043783          	ld	a5,-80(s0)
ffffffe000200d2c:	01e7d793          	srli	a5,a5,0x1e
ffffffe000200d30:	1ff7f793          	andi	a5,a5,511
ffffffe000200d34:	fcf43823          	sd	a5,-48(s0)
        cur_pte = *(cur_tbl + cur_vpn);
ffffffe000200d38:	fd043783          	ld	a5,-48(s0)
ffffffe000200d3c:	00379793          	slli	a5,a5,0x3
ffffffe000200d40:	fd843703          	ld	a4,-40(s0)
ffffffe000200d44:	00f707b3          	add	a5,a4,a5
ffffffe000200d48:	0007b783          	ld	a5,0(a5)
ffffffe000200d4c:	fef43423          	sd	a5,-24(s0)
        if ((cur_pte & PTE_V) == 0) {
ffffffe000200d50:	fe843783          	ld	a5,-24(s0)
ffffffe000200d54:	0017f793          	andi	a5,a5,1
ffffffe000200d58:	04079463          	bnez	a5,ffffffe000200da0 <create_mapping+0xb8>
            uint64 new_page_phy = (uint64)kalloc() - PA2VA_OFFSET;
ffffffe000200d5c:	d30ff0ef          	jal	ra,ffffffe00020028c <kalloc>
ffffffe000200d60:	00050713          	mv	a4,a0
ffffffe000200d64:	04100793          	li	a5,65
ffffffe000200d68:	01f79793          	slli	a5,a5,0x1f
ffffffe000200d6c:	00f707b3          	add	a5,a4,a5
ffffffe000200d70:	fcf43423          	sd	a5,-56(s0)
            cur_pte = ((uint64)new_page_phy >> 12) << 10 | PTE_V;
ffffffe000200d74:	fc843783          	ld	a5,-56(s0)
ffffffe000200d78:	00c7d793          	srli	a5,a5,0xc
ffffffe000200d7c:	00a79793          	slli	a5,a5,0xa
ffffffe000200d80:	0017e793          	ori	a5,a5,1
ffffffe000200d84:	fef43423          	sd	a5,-24(s0)
            *(cur_tbl + cur_vpn) = cur_pte;
ffffffe000200d88:	fd043783          	ld	a5,-48(s0)
ffffffe000200d8c:	00379793          	slli	a5,a5,0x3
ffffffe000200d90:	fd843703          	ld	a4,-40(s0)
ffffffe000200d94:	00f707b3          	add	a5,a4,a5
ffffffe000200d98:	fe843703          	ld	a4,-24(s0)
ffffffe000200d9c:	00e7b023          	sd	a4,0(a5)
        }
        // 第二级
        cur_tbl = (uint64*)(((cur_pte >> 10) << 12) + PA2VA_OFFSET);
ffffffe000200da0:	fe843783          	ld	a5,-24(s0)
ffffffe000200da4:	00a7d793          	srli	a5,a5,0xa
ffffffe000200da8:	00c79713          	slli	a4,a5,0xc
ffffffe000200dac:	fbf00793          	li	a5,-65
ffffffe000200db0:	01f79793          	slli	a5,a5,0x1f
ffffffe000200db4:	00f707b3          	add	a5,a4,a5
ffffffe000200db8:	fcf43c23          	sd	a5,-40(s0)
        cur_vpn = VPN1(va);
ffffffe000200dbc:	fb043783          	ld	a5,-80(s0)
ffffffe000200dc0:	0157d793          	srli	a5,a5,0x15
ffffffe000200dc4:	1ff7f793          	andi	a5,a5,511
ffffffe000200dc8:	fcf43823          	sd	a5,-48(s0)
        cur_pte = *(cur_tbl + cur_vpn);
ffffffe000200dcc:	fd043783          	ld	a5,-48(s0)
ffffffe000200dd0:	00379793          	slli	a5,a5,0x3
ffffffe000200dd4:	fd843703          	ld	a4,-40(s0)
ffffffe000200dd8:	00f707b3          	add	a5,a4,a5
ffffffe000200ddc:	0007b783          	ld	a5,0(a5)
ffffffe000200de0:	fef43423          	sd	a5,-24(s0)
        if ((cur_pte & PTE_V) == 0) {
ffffffe000200de4:	fe843783          	ld	a5,-24(s0)
ffffffe000200de8:	0017f793          	andi	a5,a5,1
ffffffe000200dec:	04079463          	bnez	a5,ffffffe000200e34 <create_mapping+0x14c>
            uint64 new_page_phy = (uint64)kalloc() - PA2VA_OFFSET;
ffffffe000200df0:	c9cff0ef          	jal	ra,ffffffe00020028c <kalloc>
ffffffe000200df4:	00050713          	mv	a4,a0
ffffffe000200df8:	04100793          	li	a5,65
ffffffe000200dfc:	01f79793          	slli	a5,a5,0x1f
ffffffe000200e00:	00f707b3          	add	a5,a4,a5
ffffffe000200e04:	fcf43023          	sd	a5,-64(s0)
            cur_pte = ((uint64)new_page_phy >> 12) << 10 | PTE_V;
ffffffe000200e08:	fc043783          	ld	a5,-64(s0)
ffffffe000200e0c:	00c7d793          	srli	a5,a5,0xc
ffffffe000200e10:	00a79793          	slli	a5,a5,0xa
ffffffe000200e14:	0017e793          	ori	a5,a5,1
ffffffe000200e18:	fef43423          	sd	a5,-24(s0)
            *(cur_tbl + cur_vpn) = cur_pte;
ffffffe000200e1c:	fd043783          	ld	a5,-48(s0)
ffffffe000200e20:	00379793          	slli	a5,a5,0x3
ffffffe000200e24:	fd843703          	ld	a4,-40(s0)
ffffffe000200e28:	00f707b3          	add	a5,a4,a5
ffffffe000200e2c:	fe843703          	ld	a4,-24(s0)
ffffffe000200e30:	00e7b023          	sd	a4,0(a5)
        }
        // 第三级
        cur_tbl = (uint64*)(((cur_pte >> 10) << 12) + PA2VA_OFFSET);
ffffffe000200e34:	fe843783          	ld	a5,-24(s0)
ffffffe000200e38:	00a7d793          	srli	a5,a5,0xa
ffffffe000200e3c:	00c79713          	slli	a4,a5,0xc
ffffffe000200e40:	fbf00793          	li	a5,-65
ffffffe000200e44:	01f79793          	slli	a5,a5,0x1f
ffffffe000200e48:	00f707b3          	add	a5,a4,a5
ffffffe000200e4c:	fcf43c23          	sd	a5,-40(s0)
        cur_vpn = VPN0(va);
ffffffe000200e50:	fb043783          	ld	a5,-80(s0)
ffffffe000200e54:	00c7d793          	srli	a5,a5,0xc
ffffffe000200e58:	1ff7f793          	andi	a5,a5,511
ffffffe000200e5c:	fcf43823          	sd	a5,-48(s0)
        cur_pte = ((pa >> 12) << 10) | perm | PTE_V;
ffffffe000200e60:	fa843783          	ld	a5,-88(s0)
ffffffe000200e64:	00c7d793          	srli	a5,a5,0xc
ffffffe000200e68:	00a79713          	slli	a4,a5,0xa
ffffffe000200e6c:	f9843783          	ld	a5,-104(s0)
ffffffe000200e70:	00f767b3          	or	a5,a4,a5
ffffffe000200e74:	0017e793          	ori	a5,a5,1
ffffffe000200e78:	fef43423          	sd	a5,-24(s0)
        *(cur_tbl + cur_vpn) = cur_pte;
ffffffe000200e7c:	fd043783          	ld	a5,-48(s0)
ffffffe000200e80:	00379793          	slli	a5,a5,0x3
ffffffe000200e84:	fd843703          	ld	a4,-40(s0)
ffffffe000200e88:	00f707b3          	add	a5,a4,a5
ffffffe000200e8c:	fe843703          	ld	a4,-24(s0)
ffffffe000200e90:	00e7b023          	sd	a4,0(a5)

        va += PGSIZE;
ffffffe000200e94:	fb043703          	ld	a4,-80(s0)
ffffffe000200e98:	000017b7          	lui	a5,0x1
ffffffe000200e9c:	00f707b3          	add	a5,a4,a5
ffffffe000200ea0:	faf43823          	sd	a5,-80(s0)
        pa += PGSIZE;
ffffffe000200ea4:	fa843703          	ld	a4,-88(s0)
ffffffe000200ea8:	000017b7          	lui	a5,0x1
ffffffe000200eac:	00f707b3          	add	a5,a4,a5
ffffffe000200eb0:	faf43423          	sd	a5,-88(s0)
    while (va < va_end) {
ffffffe000200eb4:	fb043703          	ld	a4,-80(s0)
ffffffe000200eb8:	fe043783          	ld	a5,-32(s0)
ffffffe000200ebc:	e6f762e3          	bltu	a4,a5,ffffffe000200d20 <create_mapping+0x38>
    }
}
ffffffe000200ec0:	00000013          	nop
ffffffe000200ec4:	00000013          	nop
ffffffe000200ec8:	06813083          	ld	ra,104(sp)
ffffffe000200ecc:	06013403          	ld	s0,96(sp)
ffffffe000200ed0:	07010113          	addi	sp,sp,112
ffffffe000200ed4:	00008067          	ret

ffffffe000200ed8 <setup_vm_final>:

void setup_vm_final(void) {
ffffffe000200ed8:	fd010113          	addi	sp,sp,-48
ffffffe000200edc:	02113423          	sd	ra,40(sp)
ffffffe000200ee0:	02813023          	sd	s0,32(sp)
ffffffe000200ee4:	03010413          	addi	s0,sp,48
    memset(swapper_pg_dir, 0x0, PGSIZE);
ffffffe000200ee8:	00001637          	lui	a2,0x1
ffffffe000200eec:	00000593          	li	a1,0
ffffffe000200ef0:	00005517          	auipc	a0,0x5
ffffffe000200ef4:	11050513          	addi	a0,a0,272 # ffffffe000206000 <swapper_pg_dir>
ffffffe000200ef8:	4bd000ef          	jal	ra,ffffffe000201bb4 <memset>

    // No OpenSBI mapping required

    // mapping kernel text X|-|R|V
    uint64 va = VM_START + OPENSBI_SIZE;
ffffffe000200efc:	f00017b7          	lui	a5,0xf0001
ffffffe000200f00:	00979793          	slli	a5,a5,0x9
ffffffe000200f04:	fef43423          	sd	a5,-24(s0)
    uint64 pa = PHY_START + OPENSBI_SIZE;
ffffffe000200f08:	40100793          	li	a5,1025
ffffffe000200f0c:	01579793          	slli	a5,a5,0x15
ffffffe000200f10:	fef43023          	sd	a5,-32(s0)
    create_mapping(swapper_pg_dir, va, pa, _srodata - _stext, PTE_X | PTE_R | PTE_V | PTE_A | PTE_D);
ffffffe000200f14:	00001717          	auipc	a4,0x1
ffffffe000200f18:	0ec70713          	addi	a4,a4,236 # ffffffe000202000 <_srodata>
ffffffe000200f1c:	fffff797          	auipc	a5,0xfffff
ffffffe000200f20:	0e478793          	addi	a5,a5,228 # ffffffe000200000 <_skernel>
ffffffe000200f24:	40f707b3          	sub	a5,a4,a5
ffffffe000200f28:	0cb00713          	li	a4,203
ffffffe000200f2c:	00078693          	mv	a3,a5
ffffffe000200f30:	fe043603          	ld	a2,-32(s0)
ffffffe000200f34:	fe843583          	ld	a1,-24(s0)
ffffffe000200f38:	00005517          	auipc	a0,0x5
ffffffe000200f3c:	0c850513          	addi	a0,a0,200 # ffffffe000206000 <swapper_pg_dir>
ffffffe000200f40:	da9ff0ef          	jal	ra,ffffffe000200ce8 <create_mapping>

    // mapping kernel rodata -|-|R|V
    va += _srodata - _stext;
ffffffe000200f44:	00001717          	auipc	a4,0x1
ffffffe000200f48:	0bc70713          	addi	a4,a4,188 # ffffffe000202000 <_srodata>
ffffffe000200f4c:	fffff797          	auipc	a5,0xfffff
ffffffe000200f50:	0b478793          	addi	a5,a5,180 # ffffffe000200000 <_skernel>
ffffffe000200f54:	40f707b3          	sub	a5,a4,a5
ffffffe000200f58:	00078713          	mv	a4,a5
ffffffe000200f5c:	fe843783          	ld	a5,-24(s0)
ffffffe000200f60:	00e787b3          	add	a5,a5,a4
ffffffe000200f64:	fef43423          	sd	a5,-24(s0)
    pa += _srodata - _stext;
ffffffe000200f68:	00001717          	auipc	a4,0x1
ffffffe000200f6c:	09870713          	addi	a4,a4,152 # ffffffe000202000 <_srodata>
ffffffe000200f70:	fffff797          	auipc	a5,0xfffff
ffffffe000200f74:	09078793          	addi	a5,a5,144 # ffffffe000200000 <_skernel>
ffffffe000200f78:	40f707b3          	sub	a5,a4,a5
ffffffe000200f7c:	00078713          	mv	a4,a5
ffffffe000200f80:	fe043783          	ld	a5,-32(s0)
ffffffe000200f84:	00e787b3          	add	a5,a5,a4
ffffffe000200f88:	fef43023          	sd	a5,-32(s0)
    create_mapping(swapper_pg_dir, va, pa, _sdata - _srodata, PTE_R | PTE_V | PTE_A | PTE_D);
ffffffe000200f8c:	00002717          	auipc	a4,0x2
ffffffe000200f90:	07470713          	addi	a4,a4,116 # ffffffe000203000 <TIMECLOCK>
ffffffe000200f94:	00001797          	auipc	a5,0x1
ffffffe000200f98:	06c78793          	addi	a5,a5,108 # ffffffe000202000 <_srodata>
ffffffe000200f9c:	40f707b3          	sub	a5,a4,a5
ffffffe000200fa0:	0c300713          	li	a4,195
ffffffe000200fa4:	00078693          	mv	a3,a5
ffffffe000200fa8:	fe043603          	ld	a2,-32(s0)
ffffffe000200fac:	fe843583          	ld	a1,-24(s0)
ffffffe000200fb0:	00005517          	auipc	a0,0x5
ffffffe000200fb4:	05050513          	addi	a0,a0,80 # ffffffe000206000 <swapper_pg_dir>
ffffffe000200fb8:	d31ff0ef          	jal	ra,ffffffe000200ce8 <create_mapping>

    // mapping other memory -|W|R|V
    va += _sdata - _srodata;
ffffffe000200fbc:	00002717          	auipc	a4,0x2
ffffffe000200fc0:	04470713          	addi	a4,a4,68 # ffffffe000203000 <TIMECLOCK>
ffffffe000200fc4:	00001797          	auipc	a5,0x1
ffffffe000200fc8:	03c78793          	addi	a5,a5,60 # ffffffe000202000 <_srodata>
ffffffe000200fcc:	40f707b3          	sub	a5,a4,a5
ffffffe000200fd0:	00078713          	mv	a4,a5
ffffffe000200fd4:	fe843783          	ld	a5,-24(s0)
ffffffe000200fd8:	00e787b3          	add	a5,a5,a4
ffffffe000200fdc:	fef43423          	sd	a5,-24(s0)
    pa += _sdata - _srodata;
ffffffe000200fe0:	00002717          	auipc	a4,0x2
ffffffe000200fe4:	02070713          	addi	a4,a4,32 # ffffffe000203000 <TIMECLOCK>
ffffffe000200fe8:	00001797          	auipc	a5,0x1
ffffffe000200fec:	01878793          	addi	a5,a5,24 # ffffffe000202000 <_srodata>
ffffffe000200ff0:	40f707b3          	sub	a5,a4,a5
ffffffe000200ff4:	00078713          	mv	a4,a5
ffffffe000200ff8:	fe043783          	ld	a5,-32(s0)
ffffffe000200ffc:	00e787b3          	add	a5,a5,a4
ffffffe000201000:	fef43023          	sd	a5,-32(s0)
    create_mapping(swapper_pg_dir, va, pa, PHY_SIZE - (_sdata - _stext), PTE_W | PTE_R | PTE_V | PTE_A | PTE_D);
ffffffe000201004:	00002717          	auipc	a4,0x2
ffffffe000201008:	ffc70713          	addi	a4,a4,-4 # ffffffe000203000 <TIMECLOCK>
ffffffe00020100c:	fffff797          	auipc	a5,0xfffff
ffffffe000201010:	ff478793          	addi	a5,a5,-12 # ffffffe000200000 <_skernel>
ffffffe000201014:	40f707b3          	sub	a5,a4,a5
ffffffe000201018:	00400737          	lui	a4,0x400
ffffffe00020101c:	40f707b3          	sub	a5,a4,a5
ffffffe000201020:	0c700713          	li	a4,199
ffffffe000201024:	00078693          	mv	a3,a5
ffffffe000201028:	fe043603          	ld	a2,-32(s0)
ffffffe00020102c:	fe843583          	ld	a1,-24(s0)
ffffffe000201030:	00005517          	auipc	a0,0x5
ffffffe000201034:	fd050513          	addi	a0,a0,-48 # ffffffe000206000 <swapper_pg_dir>
ffffffe000201038:	cb1ff0ef          	jal	ra,ffffffe000200ce8 <create_mapping>
  
    // set satp with swapper_pg_dir
    uint64 _satp = (((uint64)(swapper_pg_dir) - PA2VA_OFFSET) >> 12) | (8L << 60);
ffffffe00020103c:	00005717          	auipc	a4,0x5
ffffffe000201040:	fc470713          	addi	a4,a4,-60 # ffffffe000206000 <swapper_pg_dir>
ffffffe000201044:	04100793          	li	a5,65
ffffffe000201048:	01f79793          	slli	a5,a5,0x1f
ffffffe00020104c:	00f707b3          	add	a5,a4,a5
ffffffe000201050:	00c7d713          	srli	a4,a5,0xc
ffffffe000201054:	fff00793          	li	a5,-1
ffffffe000201058:	03f79793          	slli	a5,a5,0x3f
ffffffe00020105c:	00f767b3          	or	a5,a4,a5
ffffffe000201060:	fcf43c23          	sd	a5,-40(s0)
    csr_write(satp, _satp);
ffffffe000201064:	fd843783          	ld	a5,-40(s0)
ffffffe000201068:	fcf43823          	sd	a5,-48(s0)
ffffffe00020106c:	fd043783          	ld	a5,-48(s0)
ffffffe000201070:	18079073          	csrw	satp,a5
    printk("set satp to %lx\n", _satp);
ffffffe000201074:	fd843583          	ld	a1,-40(s0)
ffffffe000201078:	00001517          	auipc	a0,0x1
ffffffe00020107c:	05850513          	addi	a0,a0,88 # ffffffe0002020d0 <_srodata+0xd0>
ffffffe000201080:	7b4000ef          	jal	ra,ffffffe000201834 <printk>

    // flush TLB
    asm volatile("sfence.vma zero, zero");
ffffffe000201084:	12000073          	sfence.vma

    // flush icache
    asm volatile("fence.i");
ffffffe000201088:	0000100f          	fence.i
    return;
ffffffe00020108c:	00000013          	nop
}
ffffffe000201090:	02813083          	ld	ra,40(sp)
ffffffe000201094:	02013403          	ld	s0,32(sp)
ffffffe000201098:	03010113          	addi	sp,sp,48
ffffffe00020109c:	00008067          	ret

ffffffe0002010a0 <start_kernel>:
#include "printk.h"

extern void test();

int start_kernel(int x) {
ffffffe0002010a0:	fe010113          	addi	sp,sp,-32
ffffffe0002010a4:	00113c23          	sd	ra,24(sp)
ffffffe0002010a8:	00813823          	sd	s0,16(sp)
ffffffe0002010ac:	02010413          	addi	s0,sp,32
ffffffe0002010b0:	00050793          	mv	a5,a0
ffffffe0002010b4:	fef42623          	sw	a5,-20(s0)
    printk("%d", x);
ffffffe0002010b8:	fec42783          	lw	a5,-20(s0)
ffffffe0002010bc:	00078593          	mv	a1,a5
ffffffe0002010c0:	00001517          	auipc	a0,0x1
ffffffe0002010c4:	02850513          	addi	a0,a0,40 # ffffffe0002020e8 <_srodata+0xe8>
ffffffe0002010c8:	76c000ef          	jal	ra,ffffffe000201834 <printk>
    printk(" ZJU Computer System III\n");
ffffffe0002010cc:	00001517          	auipc	a0,0x1
ffffffe0002010d0:	02450513          	addi	a0,a0,36 # ffffffe0002020f0 <_srodata+0xf0>
ffffffe0002010d4:	760000ef          	jal	ra,ffffffe000201834 <printk>
    test(); // DO NOT DELETE !!!
ffffffe0002010d8:	01c000ef          	jal	ra,ffffffe0002010f4 <test>
    return 0;
ffffffe0002010dc:	00000793          	li	a5,0
}
ffffffe0002010e0:	00078513          	mv	a0,a5
ffffffe0002010e4:	01813083          	ld	ra,24(sp)
ffffffe0002010e8:	01013403          	ld	s0,16(sp)
ffffffe0002010ec:	02010113          	addi	sp,sp,32
ffffffe0002010f0:	00008067          	ret

ffffffe0002010f4 <test>:
#include "printk.h"
#include "defs.h"

// Please do not modify

void test() {
ffffffe0002010f4:	fe010113          	addi	sp,sp,-32
ffffffe0002010f8:	00813c23          	sd	s0,24(sp)
ffffffe0002010fc:	02010413          	addi	s0,sp,32
    unsigned long record_time = 0; 
ffffffe000201100:	fe043423          	sd	zero,-24(s0)
    while (1) {
ffffffe000201104:	0000006f          	j	ffffffe000201104 <test+0x10>

ffffffe000201108 <int_mod>:
#include"math.h"
int int_mod(unsigned int v1,unsigned int v2){
ffffffe000201108:	fd010113          	addi	sp,sp,-48
ffffffe00020110c:	02813423          	sd	s0,40(sp)
ffffffe000201110:	03010413          	addi	s0,sp,48
ffffffe000201114:	00050793          	mv	a5,a0
ffffffe000201118:	00058713          	mv	a4,a1
ffffffe00020111c:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201120:	00070793          	mv	a5,a4
ffffffe000201124:	fcf42c23          	sw	a5,-40(s0)
    unsigned long long m1=v1;
ffffffe000201128:	fdc46783          	lwu	a5,-36(s0)
ffffffe00020112c:	fef43423          	sd	a5,-24(s0)
    unsigned long long m2=v2;
ffffffe000201130:	fd846783          	lwu	a5,-40(s0)
ffffffe000201134:	fef43023          	sd	a5,-32(s0)
    m2<<=31;
ffffffe000201138:	fe043783          	ld	a5,-32(s0)
ffffffe00020113c:	01f79793          	slli	a5,a5,0x1f
ffffffe000201140:	fef43023          	sd	a5,-32(s0)
    while(m1>=v2){
ffffffe000201144:	02c0006f          	j	ffffffe000201170 <int_mod+0x68>
        if(m2<m1){
ffffffe000201148:	fe043703          	ld	a4,-32(s0)
ffffffe00020114c:	fe843783          	ld	a5,-24(s0)
ffffffe000201150:	00f77a63          	bgeu	a4,a5,ffffffe000201164 <int_mod+0x5c>
            m1-=m2;
ffffffe000201154:	fe843703          	ld	a4,-24(s0)
ffffffe000201158:	fe043783          	ld	a5,-32(s0)
ffffffe00020115c:	40f707b3          	sub	a5,a4,a5
ffffffe000201160:	fef43423          	sd	a5,-24(s0)
        }
        m2>>=1;
ffffffe000201164:	fe043783          	ld	a5,-32(s0)
ffffffe000201168:	0017d793          	srli	a5,a5,0x1
ffffffe00020116c:	fef43023          	sd	a5,-32(s0)
    while(m1>=v2){
ffffffe000201170:	fd846783          	lwu	a5,-40(s0)
ffffffe000201174:	fe843703          	ld	a4,-24(s0)
ffffffe000201178:	fcf778e3          	bgeu	a4,a5,ffffffe000201148 <int_mod+0x40>
    }
    return m1;
ffffffe00020117c:	fe843783          	ld	a5,-24(s0)
ffffffe000201180:	0007879b          	sext.w	a5,a5
}
ffffffe000201184:	00078513          	mv	a0,a5
ffffffe000201188:	02813403          	ld	s0,40(sp)
ffffffe00020118c:	03010113          	addi	sp,sp,48
ffffffe000201190:	00008067          	ret

ffffffe000201194 <int_mul>:

int int_mul(unsigned int v1,unsigned int v2){
ffffffe000201194:	fd010113          	addi	sp,sp,-48
ffffffe000201198:	02813423          	sd	s0,40(sp)
ffffffe00020119c:	03010413          	addi	s0,sp,48
ffffffe0002011a0:	00050793          	mv	a5,a0
ffffffe0002011a4:	00058713          	mv	a4,a1
ffffffe0002011a8:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002011ac:	00070793          	mv	a5,a4
ffffffe0002011b0:	fcf42c23          	sw	a5,-40(s0)
    unsigned long long res=0;
ffffffe0002011b4:	fe043423          	sd	zero,-24(s0)
    while(v2&&v1){
ffffffe0002011b8:	03c0006f          	j	ffffffe0002011f4 <int_mul+0x60>
        if(v2&1){
ffffffe0002011bc:	fd842783          	lw	a5,-40(s0)
ffffffe0002011c0:	0017f793          	andi	a5,a5,1
ffffffe0002011c4:	0007879b          	sext.w	a5,a5
ffffffe0002011c8:	00078a63          	beqz	a5,ffffffe0002011dc <int_mul+0x48>
            res+=v1;
ffffffe0002011cc:	fdc46783          	lwu	a5,-36(s0)
ffffffe0002011d0:	fe843703          	ld	a4,-24(s0)
ffffffe0002011d4:	00f707b3          	add	a5,a4,a5
ffffffe0002011d8:	fef43423          	sd	a5,-24(s0)
        }
        v2>>=1;
ffffffe0002011dc:	fd842783          	lw	a5,-40(s0)
ffffffe0002011e0:	0017d79b          	srliw	a5,a5,0x1
ffffffe0002011e4:	fcf42c23          	sw	a5,-40(s0)
        v1<<=1;
ffffffe0002011e8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002011ec:	0017979b          	slliw	a5,a5,0x1
ffffffe0002011f0:	fcf42e23          	sw	a5,-36(s0)
    while(v2&&v1){
ffffffe0002011f4:	fd842783          	lw	a5,-40(s0)
ffffffe0002011f8:	0007879b          	sext.w	a5,a5
ffffffe0002011fc:	00078863          	beqz	a5,ffffffe00020120c <int_mul+0x78>
ffffffe000201200:	fdc42783          	lw	a5,-36(s0)
ffffffe000201204:	0007879b          	sext.w	a5,a5
ffffffe000201208:	fa079ae3          	bnez	a5,ffffffe0002011bc <int_mul+0x28>
    }
    return res;
ffffffe00020120c:	fe843783          	ld	a5,-24(s0)
ffffffe000201210:	0007879b          	sext.w	a5,a5
}
ffffffe000201214:	00078513          	mv	a0,a5
ffffffe000201218:	02813403          	ld	s0,40(sp)
ffffffe00020121c:	03010113          	addi	sp,sp,48
ffffffe000201220:	00008067          	ret

ffffffe000201224 <int_div>:

int int_div(unsigned int v1,unsigned int v2){
ffffffe000201224:	fc010113          	addi	sp,sp,-64
ffffffe000201228:	02813c23          	sd	s0,56(sp)
ffffffe00020122c:	04010413          	addi	s0,sp,64
ffffffe000201230:	00050793          	mv	a5,a0
ffffffe000201234:	00058713          	mv	a4,a1
ffffffe000201238:	fcf42623          	sw	a5,-52(s0)
ffffffe00020123c:	00070793          	mv	a5,a4
ffffffe000201240:	fcf42423          	sw	a5,-56(s0)
    unsigned long long m1=v1;
ffffffe000201244:	fcc46783          	lwu	a5,-52(s0)
ffffffe000201248:	fef43423          	sd	a5,-24(s0)
    unsigned long long m2=v2;
ffffffe00020124c:	fc846783          	lwu	a5,-56(s0)
ffffffe000201250:	fef43023          	sd	a5,-32(s0)
    unsigned long long mask=(unsigned int)1<<31;
ffffffe000201254:	00100793          	li	a5,1
ffffffe000201258:	01f79793          	slli	a5,a5,0x1f
ffffffe00020125c:	fcf43c23          	sd	a5,-40(s0)
    m2<<=31;
ffffffe000201260:	fe043783          	ld	a5,-32(s0)
ffffffe000201264:	01f79793          	slli	a5,a5,0x1f
ffffffe000201268:	fef43023          	sd	a5,-32(s0)
    unsigned long long res=0;
ffffffe00020126c:	fc043823          	sd	zero,-48(s0)
    while(m1>=v2){
ffffffe000201270:	0480006f          	j	ffffffe0002012b8 <int_div+0x94>
        if(m2<m1){
ffffffe000201274:	fe043703          	ld	a4,-32(s0)
ffffffe000201278:	fe843783          	ld	a5,-24(s0)
ffffffe00020127c:	02f77263          	bgeu	a4,a5,ffffffe0002012a0 <int_div+0x7c>
            m1-=m2;
ffffffe000201280:	fe843703          	ld	a4,-24(s0)
ffffffe000201284:	fe043783          	ld	a5,-32(s0)
ffffffe000201288:	40f707b3          	sub	a5,a4,a5
ffffffe00020128c:	fef43423          	sd	a5,-24(s0)
            res|=mask;
ffffffe000201290:	fd043703          	ld	a4,-48(s0)
ffffffe000201294:	fd843783          	ld	a5,-40(s0)
ffffffe000201298:	00f767b3          	or	a5,a4,a5
ffffffe00020129c:	fcf43823          	sd	a5,-48(s0)
        }
        m2>>=1;
ffffffe0002012a0:	fe043783          	ld	a5,-32(s0)
ffffffe0002012a4:	0017d793          	srli	a5,a5,0x1
ffffffe0002012a8:	fef43023          	sd	a5,-32(s0)
        mask>>=1;
ffffffe0002012ac:	fd843783          	ld	a5,-40(s0)
ffffffe0002012b0:	0017d793          	srli	a5,a5,0x1
ffffffe0002012b4:	fcf43c23          	sd	a5,-40(s0)
    while(m1>=v2){
ffffffe0002012b8:	fc846783          	lwu	a5,-56(s0)
ffffffe0002012bc:	fe843703          	ld	a4,-24(s0)
ffffffe0002012c0:	faf77ae3          	bgeu	a4,a5,ffffffe000201274 <int_div+0x50>
    }
    return res;
ffffffe0002012c4:	fd043783          	ld	a5,-48(s0)
ffffffe0002012c8:	0007879b          	sext.w	a5,a5
ffffffe0002012cc:	00078513          	mv	a0,a5
ffffffe0002012d0:	03813403          	ld	s0,56(sp)
ffffffe0002012d4:	04010113          	addi	sp,sp,64
ffffffe0002012d8:	00008067          	ret

ffffffe0002012dc <putc>:
#include "printk.h"
#include "sbi.h"

void putc(char c) {
ffffffe0002012dc:	fe010113          	addi	sp,sp,-32
ffffffe0002012e0:	00113c23          	sd	ra,24(sp)
ffffffe0002012e4:	00813823          	sd	s0,16(sp)
ffffffe0002012e8:	02010413          	addi	s0,sp,32
ffffffe0002012ec:	00050793          	mv	a5,a0
ffffffe0002012f0:	fef407a3          	sb	a5,-17(s0)
  sbi_ecall(SBI_PUTCHAR, 0, c, 0, 0, 0, 0, 0);
ffffffe0002012f4:	fef44603          	lbu	a2,-17(s0)
ffffffe0002012f8:	00000893          	li	a7,0
ffffffe0002012fc:	00000813          	li	a6,0
ffffffe000201300:	00000793          	li	a5,0
ffffffe000201304:	00000713          	li	a4,0
ffffffe000201308:	00000693          	li	a3,0
ffffffe00020130c:	00000593          	li	a1,0
ffffffe000201310:	00100513          	li	a0,1
ffffffe000201314:	e98ff0ef          	jal	ra,ffffffe0002009ac <sbi_ecall>
}
ffffffe000201318:	00000013          	nop
ffffffe00020131c:	01813083          	ld	ra,24(sp)
ffffffe000201320:	01013403          	ld	s0,16(sp)
ffffffe000201324:	02010113          	addi	sp,sp,32
ffffffe000201328:	00008067          	ret

ffffffe00020132c <vprintfmt>:

static int vprintfmt(void(*putch)(char), const char *fmt, va_list vl) {
ffffffe00020132c:	f2010113          	addi	sp,sp,-224
ffffffe000201330:	0c113c23          	sd	ra,216(sp)
ffffffe000201334:	0c813823          	sd	s0,208(sp)
ffffffe000201338:	0e010413          	addi	s0,sp,224
ffffffe00020133c:	f2a43c23          	sd	a0,-200(s0)
ffffffe000201340:	f2b43823          	sd	a1,-208(s0)
ffffffe000201344:	f2c43423          	sd	a2,-216(s0)
    int in_format = 0, longarg = 0;
ffffffe000201348:	fe042623          	sw	zero,-20(s0)
ffffffe00020134c:	fe042423          	sw	zero,-24(s0)
    size_t pos = 0;
ffffffe000201350:	fe043023          	sd	zero,-32(s0)
    for( ; *fmt; fmt++) {
ffffffe000201354:	4b80006f          	j	ffffffe00020180c <vprintfmt+0x4e0>
        if (in_format) {
ffffffe000201358:	fec42783          	lw	a5,-20(s0)
ffffffe00020135c:	0007879b          	sext.w	a5,a5
ffffffe000201360:	44078c63          	beqz	a5,ffffffe0002017b8 <vprintfmt+0x48c>
            switch(*fmt) {
ffffffe000201364:	f3043783          	ld	a5,-208(s0)
ffffffe000201368:	0007c783          	lbu	a5,0(a5)
ffffffe00020136c:	0007879b          	sext.w	a5,a5
ffffffe000201370:	f9d7869b          	addiw	a3,a5,-99
ffffffe000201374:	0006871b          	sext.w	a4,a3
ffffffe000201378:	01500793          	li	a5,21
ffffffe00020137c:	48e7e063          	bltu	a5,a4,ffffffe0002017fc <vprintfmt+0x4d0>
ffffffe000201380:	02069793          	slli	a5,a3,0x20
ffffffe000201384:	0207d793          	srli	a5,a5,0x20
ffffffe000201388:	00279713          	slli	a4,a5,0x2
ffffffe00020138c:	00001797          	auipc	a5,0x1
ffffffe000201390:	d8078793          	addi	a5,a5,-640 # ffffffe00020210c <_srodata+0x10c>
ffffffe000201394:	00f707b3          	add	a5,a4,a5
ffffffe000201398:	0007a783          	lw	a5,0(a5)
ffffffe00020139c:	0007871b          	sext.w	a4,a5
ffffffe0002013a0:	00001797          	auipc	a5,0x1
ffffffe0002013a4:	d6c78793          	addi	a5,a5,-660 # ffffffe00020210c <_srodata+0x10c>
ffffffe0002013a8:	00f707b3          	add	a5,a4,a5
ffffffe0002013ac:	00078067          	jr	a5
                case 'l': { 
                    longarg = 1; 
ffffffe0002013b0:	00100793          	li	a5,1
ffffffe0002013b4:	fef42423          	sw	a5,-24(s0)
                    break; 
ffffffe0002013b8:	4480006f          	j	ffffffe000201800 <vprintfmt+0x4d4>
                }
                
                case 'x': {
                    long num = longarg ? va_arg(vl, long) : va_arg(vl, int);
ffffffe0002013bc:	fe842783          	lw	a5,-24(s0)
ffffffe0002013c0:	0007879b          	sext.w	a5,a5
ffffffe0002013c4:	00078c63          	beqz	a5,ffffffe0002013dc <vprintfmt+0xb0>
ffffffe0002013c8:	f2843783          	ld	a5,-216(s0)
ffffffe0002013cc:	00878713          	addi	a4,a5,8
ffffffe0002013d0:	f2e43423          	sd	a4,-216(s0)
ffffffe0002013d4:	0007b783          	ld	a5,0(a5)
ffffffe0002013d8:	0140006f          	j	ffffffe0002013ec <vprintfmt+0xc0>
ffffffe0002013dc:	f2843783          	ld	a5,-216(s0)
ffffffe0002013e0:	00878713          	addi	a4,a5,8
ffffffe0002013e4:	f2e43423          	sd	a4,-216(s0)
ffffffe0002013e8:	0007a783          	lw	a5,0(a5)
ffffffe0002013ec:	f8f43c23          	sd	a5,-104(s0)

                    int hexdigits = int_mul(2 , (longarg ? sizeof(long) : sizeof(int)) - 1);
ffffffe0002013f0:	fe842783          	lw	a5,-24(s0)
ffffffe0002013f4:	0007879b          	sext.w	a5,a5
ffffffe0002013f8:	00078663          	beqz	a5,ffffffe000201404 <vprintfmt+0xd8>
ffffffe0002013fc:	00700793          	li	a5,7
ffffffe000201400:	0080006f          	j	ffffffe000201408 <vprintfmt+0xdc>
ffffffe000201404:	00300793          	li	a5,3
ffffffe000201408:	00078593          	mv	a1,a5
ffffffe00020140c:	00200513          	li	a0,2
ffffffe000201410:	d85ff0ef          	jal	ra,ffffffe000201194 <int_mul>
ffffffe000201414:	00050793          	mv	a5,a0
ffffffe000201418:	f8f42a23          	sw	a5,-108(s0)
                    for(int halfbyte = hexdigits; halfbyte >= 0; halfbyte--) {
ffffffe00020141c:	f9442783          	lw	a5,-108(s0)
ffffffe000201420:	fcf42e23          	sw	a5,-36(s0)
ffffffe000201424:	0900006f          	j	ffffffe0002014b4 <vprintfmt+0x188>
                        int hex = (num >> (int_mul(4,halfbyte))) & 0xF;
ffffffe000201428:	fdc42783          	lw	a5,-36(s0)
ffffffe00020142c:	00078593          	mv	a1,a5
ffffffe000201430:	00400513          	li	a0,4
ffffffe000201434:	d61ff0ef          	jal	ra,ffffffe000201194 <int_mul>
ffffffe000201438:	00050793          	mv	a5,a0
ffffffe00020143c:	00078713          	mv	a4,a5
ffffffe000201440:	f9843783          	ld	a5,-104(s0)
ffffffe000201444:	40e7d7b3          	sra	a5,a5,a4
ffffffe000201448:	0007879b          	sext.w	a5,a5
ffffffe00020144c:	00f7f793          	andi	a5,a5,15
ffffffe000201450:	f8f42823          	sw	a5,-112(s0)
                        char hexchar = (hex < 10 ? '0' + hex : 'a' + hex - 10);
ffffffe000201454:	f9042783          	lw	a5,-112(s0)
ffffffe000201458:	0007871b          	sext.w	a4,a5
ffffffe00020145c:	00900793          	li	a5,9
ffffffe000201460:	00e7cc63          	blt	a5,a4,ffffffe000201478 <vprintfmt+0x14c>
ffffffe000201464:	f9042783          	lw	a5,-112(s0)
ffffffe000201468:	0ff7f793          	zext.b	a5,a5
ffffffe00020146c:	0307879b          	addiw	a5,a5,48
ffffffe000201470:	0ff7f793          	zext.b	a5,a5
ffffffe000201474:	0140006f          	j	ffffffe000201488 <vprintfmt+0x15c>
ffffffe000201478:	f9042783          	lw	a5,-112(s0)
ffffffe00020147c:	0ff7f793          	zext.b	a5,a5
ffffffe000201480:	0577879b          	addiw	a5,a5,87
ffffffe000201484:	0ff7f793          	zext.b	a5,a5
ffffffe000201488:	f8f407a3          	sb	a5,-113(s0)
                        putch(hexchar);
ffffffe00020148c:	f8f44703          	lbu	a4,-113(s0)
ffffffe000201490:	f3843783          	ld	a5,-200(s0)
ffffffe000201494:	00070513          	mv	a0,a4
ffffffe000201498:	000780e7          	jalr	a5
                        pos++;
ffffffe00020149c:	fe043783          	ld	a5,-32(s0)
ffffffe0002014a0:	00178793          	addi	a5,a5,1
ffffffe0002014a4:	fef43023          	sd	a5,-32(s0)
                    for(int halfbyte = hexdigits; halfbyte >= 0; halfbyte--) {
ffffffe0002014a8:	fdc42783          	lw	a5,-36(s0)
ffffffe0002014ac:	fff7879b          	addiw	a5,a5,-1
ffffffe0002014b0:	fcf42e23          	sw	a5,-36(s0)
ffffffe0002014b4:	fdc42783          	lw	a5,-36(s0)
ffffffe0002014b8:	0007879b          	sext.w	a5,a5
ffffffe0002014bc:	f607d6e3          	bgez	a5,ffffffe000201428 <vprintfmt+0xfc>
                    }
                    longarg = 0; in_format = 0; 
ffffffe0002014c0:	fe042423          	sw	zero,-24(s0)
ffffffe0002014c4:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe0002014c8:	3380006f          	j	ffffffe000201800 <vprintfmt+0x4d4>
                }
            
                case 'd': {
                    long num = longarg ? va_arg(vl, long) : va_arg(vl, int);
ffffffe0002014cc:	fe842783          	lw	a5,-24(s0)
ffffffe0002014d0:	0007879b          	sext.w	a5,a5
ffffffe0002014d4:	00078c63          	beqz	a5,ffffffe0002014ec <vprintfmt+0x1c0>
ffffffe0002014d8:	f2843783          	ld	a5,-216(s0)
ffffffe0002014dc:	00878713          	addi	a4,a5,8
ffffffe0002014e0:	f2e43423          	sd	a4,-216(s0)
ffffffe0002014e4:	0007b783          	ld	a5,0(a5)
ffffffe0002014e8:	0140006f          	j	ffffffe0002014fc <vprintfmt+0x1d0>
ffffffe0002014ec:	f2843783          	ld	a5,-216(s0)
ffffffe0002014f0:	00878713          	addi	a4,a5,8
ffffffe0002014f4:	f2e43423          	sd	a4,-216(s0)
ffffffe0002014f8:	0007a783          	lw	a5,0(a5)
ffffffe0002014fc:	fcf43823          	sd	a5,-48(s0)
                    if (num < 0) {
ffffffe000201500:	fd043783          	ld	a5,-48(s0)
ffffffe000201504:	0207d463          	bgez	a5,ffffffe00020152c <vprintfmt+0x200>
                        num = -num; putch('-');
ffffffe000201508:	fd043783          	ld	a5,-48(s0)
ffffffe00020150c:	40f007b3          	neg	a5,a5
ffffffe000201510:	fcf43823          	sd	a5,-48(s0)
ffffffe000201514:	f3843783          	ld	a5,-200(s0)
ffffffe000201518:	02d00513          	li	a0,45
ffffffe00020151c:	000780e7          	jalr	a5
                        pos++;
ffffffe000201520:	fe043783          	ld	a5,-32(s0)
ffffffe000201524:	00178793          	addi	a5,a5,1
ffffffe000201528:	fef43023          	sd	a5,-32(s0)
                    }
                    int bits = 0;
ffffffe00020152c:	fc042623          	sw	zero,-52(s0)
                    char decchar[25] = {'0', 0};
ffffffe000201530:	03000793          	li	a5,48
ffffffe000201534:	f6f43023          	sd	a5,-160(s0)
ffffffe000201538:	f6043423          	sd	zero,-152(s0)
ffffffe00020153c:	f6043823          	sd	zero,-144(s0)
ffffffe000201540:	f6040c23          	sb	zero,-136(s0)
                    for (long tmp = num; tmp; bits++) {
ffffffe000201544:	fd043783          	ld	a5,-48(s0)
ffffffe000201548:	fcf43023          	sd	a5,-64(s0)
ffffffe00020154c:	0500006f          	j	ffffffe00020159c <vprintfmt+0x270>
                        decchar[bits] = (int_mod(tmp , 10)) + '0';
ffffffe000201550:	00a00593          	li	a1,10
ffffffe000201554:	fc043503          	ld	a0,-64(s0)
ffffffe000201558:	bb1ff0ef          	jal	ra,ffffffe000201108 <int_mod>
ffffffe00020155c:	00050793          	mv	a5,a0
ffffffe000201560:	0ff7f793          	zext.b	a5,a5
ffffffe000201564:	0307879b          	addiw	a5,a5,48
ffffffe000201568:	0ff7f713          	zext.b	a4,a5
ffffffe00020156c:	fcc42783          	lw	a5,-52(s0)
ffffffe000201570:	ff078793          	addi	a5,a5,-16
ffffffe000201574:	008787b3          	add	a5,a5,s0
ffffffe000201578:	f6e78823          	sb	a4,-144(a5)
                        tmp = int_div(tmp,10);
ffffffe00020157c:	00a00593          	li	a1,10
ffffffe000201580:	fc043503          	ld	a0,-64(s0)
ffffffe000201584:	ca1ff0ef          	jal	ra,ffffffe000201224 <int_div>
ffffffe000201588:	00050793          	mv	a5,a0
ffffffe00020158c:	fcf43023          	sd	a5,-64(s0)
                    for (long tmp = num; tmp; bits++) {
ffffffe000201590:	fcc42783          	lw	a5,-52(s0)
ffffffe000201594:	0017879b          	addiw	a5,a5,1
ffffffe000201598:	fcf42623          	sw	a5,-52(s0)
ffffffe00020159c:	fc043783          	ld	a5,-64(s0)
ffffffe0002015a0:	fa0798e3          	bnez	a5,ffffffe000201550 <vprintfmt+0x224>
                    }

                    for (int i = bits; i >= 0; i--) {
ffffffe0002015a4:	fcc42783          	lw	a5,-52(s0)
ffffffe0002015a8:	faf42e23          	sw	a5,-68(s0)
ffffffe0002015ac:	02c0006f          	j	ffffffe0002015d8 <vprintfmt+0x2ac>
                        putch(decchar[i]);
ffffffe0002015b0:	fbc42783          	lw	a5,-68(s0)
ffffffe0002015b4:	ff078793          	addi	a5,a5,-16
ffffffe0002015b8:	008787b3          	add	a5,a5,s0
ffffffe0002015bc:	f707c703          	lbu	a4,-144(a5)
ffffffe0002015c0:	f3843783          	ld	a5,-200(s0)
ffffffe0002015c4:	00070513          	mv	a0,a4
ffffffe0002015c8:	000780e7          	jalr	a5
                    for (int i = bits; i >= 0; i--) {
ffffffe0002015cc:	fbc42783          	lw	a5,-68(s0)
ffffffe0002015d0:	fff7879b          	addiw	a5,a5,-1
ffffffe0002015d4:	faf42e23          	sw	a5,-68(s0)
ffffffe0002015d8:	fbc42783          	lw	a5,-68(s0)
ffffffe0002015dc:	0007879b          	sext.w	a5,a5
ffffffe0002015e0:	fc07d8e3          	bgez	a5,ffffffe0002015b0 <vprintfmt+0x284>
                    }
                    pos += bits + 1;
ffffffe0002015e4:	fcc42783          	lw	a5,-52(s0)
ffffffe0002015e8:	0017879b          	addiw	a5,a5,1
ffffffe0002015ec:	0007879b          	sext.w	a5,a5
ffffffe0002015f0:	00078713          	mv	a4,a5
ffffffe0002015f4:	fe043783          	ld	a5,-32(s0)
ffffffe0002015f8:	00e787b3          	add	a5,a5,a4
ffffffe0002015fc:	fef43023          	sd	a5,-32(s0)
                    longarg = 0; in_format = 0; 
ffffffe000201600:	fe042423          	sw	zero,-24(s0)
ffffffe000201604:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe000201608:	1f80006f          	j	ffffffe000201800 <vprintfmt+0x4d4>
                }

                case 'u': {
                    unsigned long num = longarg ? va_arg(vl, long) : va_arg(vl, int);
ffffffe00020160c:	fe842783          	lw	a5,-24(s0)
ffffffe000201610:	0007879b          	sext.w	a5,a5
ffffffe000201614:	00078c63          	beqz	a5,ffffffe00020162c <vprintfmt+0x300>
ffffffe000201618:	f2843783          	ld	a5,-216(s0)
ffffffe00020161c:	00878713          	addi	a4,a5,8
ffffffe000201620:	f2e43423          	sd	a4,-216(s0)
ffffffe000201624:	0007b783          	ld	a5,0(a5)
ffffffe000201628:	0140006f          	j	ffffffe00020163c <vprintfmt+0x310>
ffffffe00020162c:	f2843783          	ld	a5,-216(s0)
ffffffe000201630:	00878713          	addi	a4,a5,8
ffffffe000201634:	f2e43423          	sd	a4,-216(s0)
ffffffe000201638:	0007a783          	lw	a5,0(a5)
ffffffe00020163c:	f8f43023          	sd	a5,-128(s0)
                    int bits = 0;
ffffffe000201640:	fa042c23          	sw	zero,-72(s0)
                    char decchar[25] = {'0', 0};
ffffffe000201644:	03000793          	li	a5,48
ffffffe000201648:	f4f43023          	sd	a5,-192(s0)
ffffffe00020164c:	f4043423          	sd	zero,-184(s0)
ffffffe000201650:	f4043823          	sd	zero,-176(s0)
ffffffe000201654:	f4040c23          	sb	zero,-168(s0)
                    for (long tmp = num; tmp; bits++) {
ffffffe000201658:	f8043783          	ld	a5,-128(s0)
ffffffe00020165c:	faf43823          	sd	a5,-80(s0)
ffffffe000201660:	0500006f          	j	ffffffe0002016b0 <vprintfmt+0x384>
                        decchar[bits] = (int_mod(tmp , 10)) + '0';
ffffffe000201664:	00a00593          	li	a1,10
ffffffe000201668:	fb043503          	ld	a0,-80(s0)
ffffffe00020166c:	a9dff0ef          	jal	ra,ffffffe000201108 <int_mod>
ffffffe000201670:	00050793          	mv	a5,a0
ffffffe000201674:	0ff7f793          	zext.b	a5,a5
ffffffe000201678:	0307879b          	addiw	a5,a5,48
ffffffe00020167c:	0ff7f713          	zext.b	a4,a5
ffffffe000201680:	fb842783          	lw	a5,-72(s0)
ffffffe000201684:	ff078793          	addi	a5,a5,-16
ffffffe000201688:	008787b3          	add	a5,a5,s0
ffffffe00020168c:	f4e78823          	sb	a4,-176(a5)
                        tmp = int_div(tmp,10);
ffffffe000201690:	00a00593          	li	a1,10
ffffffe000201694:	fb043503          	ld	a0,-80(s0)
ffffffe000201698:	b8dff0ef          	jal	ra,ffffffe000201224 <int_div>
ffffffe00020169c:	00050793          	mv	a5,a0
ffffffe0002016a0:	faf43823          	sd	a5,-80(s0)
                    for (long tmp = num; tmp; bits++) {
ffffffe0002016a4:	fb842783          	lw	a5,-72(s0)
ffffffe0002016a8:	0017879b          	addiw	a5,a5,1
ffffffe0002016ac:	faf42c23          	sw	a5,-72(s0)
ffffffe0002016b0:	fb043783          	ld	a5,-80(s0)
ffffffe0002016b4:	fa0798e3          	bnez	a5,ffffffe000201664 <vprintfmt+0x338>
                    }

                    for (int i = bits; i >= 0; i--) {
ffffffe0002016b8:	fb842783          	lw	a5,-72(s0)
ffffffe0002016bc:	faf42623          	sw	a5,-84(s0)
ffffffe0002016c0:	02c0006f          	j	ffffffe0002016ec <vprintfmt+0x3c0>
                        putch(decchar[i]);
ffffffe0002016c4:	fac42783          	lw	a5,-84(s0)
ffffffe0002016c8:	ff078793          	addi	a5,a5,-16
ffffffe0002016cc:	008787b3          	add	a5,a5,s0
ffffffe0002016d0:	f507c703          	lbu	a4,-176(a5)
ffffffe0002016d4:	f3843783          	ld	a5,-200(s0)
ffffffe0002016d8:	00070513          	mv	a0,a4
ffffffe0002016dc:	000780e7          	jalr	a5
                    for (int i = bits; i >= 0; i--) {
ffffffe0002016e0:	fac42783          	lw	a5,-84(s0)
ffffffe0002016e4:	fff7879b          	addiw	a5,a5,-1
ffffffe0002016e8:	faf42623          	sw	a5,-84(s0)
ffffffe0002016ec:	fac42783          	lw	a5,-84(s0)
ffffffe0002016f0:	0007879b          	sext.w	a5,a5
ffffffe0002016f4:	fc07d8e3          	bgez	a5,ffffffe0002016c4 <vprintfmt+0x398>
                    }
                    pos += bits + 1;
ffffffe0002016f8:	fb842783          	lw	a5,-72(s0)
ffffffe0002016fc:	0017879b          	addiw	a5,a5,1
ffffffe000201700:	0007879b          	sext.w	a5,a5
ffffffe000201704:	00078713          	mv	a4,a5
ffffffe000201708:	fe043783          	ld	a5,-32(s0)
ffffffe00020170c:	00e787b3          	add	a5,a5,a4
ffffffe000201710:	fef43023          	sd	a5,-32(s0)
                    longarg = 0; in_format = 0; 
ffffffe000201714:	fe042423          	sw	zero,-24(s0)
ffffffe000201718:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe00020171c:	0e40006f          	j	ffffffe000201800 <vprintfmt+0x4d4>
                }

                case 's': {
                    const char* str = va_arg(vl, const char*);
ffffffe000201720:	f2843783          	ld	a5,-216(s0)
ffffffe000201724:	00878713          	addi	a4,a5,8
ffffffe000201728:	f2e43423          	sd	a4,-216(s0)
ffffffe00020172c:	0007b783          	ld	a5,0(a5)
ffffffe000201730:	faf43023          	sd	a5,-96(s0)
                    while (*str) {
ffffffe000201734:	0300006f          	j	ffffffe000201764 <vprintfmt+0x438>
                        putch(*str);
ffffffe000201738:	fa043783          	ld	a5,-96(s0)
ffffffe00020173c:	0007c703          	lbu	a4,0(a5)
ffffffe000201740:	f3843783          	ld	a5,-200(s0)
ffffffe000201744:	00070513          	mv	a0,a4
ffffffe000201748:	000780e7          	jalr	a5
                        pos++; 
ffffffe00020174c:	fe043783          	ld	a5,-32(s0)
ffffffe000201750:	00178793          	addi	a5,a5,1
ffffffe000201754:	fef43023          	sd	a5,-32(s0)
                        str++;
ffffffe000201758:	fa043783          	ld	a5,-96(s0)
ffffffe00020175c:	00178793          	addi	a5,a5,1
ffffffe000201760:	faf43023          	sd	a5,-96(s0)
                    while (*str) {
ffffffe000201764:	fa043783          	ld	a5,-96(s0)
ffffffe000201768:	0007c783          	lbu	a5,0(a5)
ffffffe00020176c:	fc0796e3          	bnez	a5,ffffffe000201738 <vprintfmt+0x40c>
                    }
                    longarg = 0; in_format = 0; 
ffffffe000201770:	fe042423          	sw	zero,-24(s0)
ffffffe000201774:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe000201778:	0880006f          	j	ffffffe000201800 <vprintfmt+0x4d4>
                }

                case 'c': {
                    char ch = (char)va_arg(vl,int);
ffffffe00020177c:	f2843783          	ld	a5,-216(s0)
ffffffe000201780:	00878713          	addi	a4,a5,8
ffffffe000201784:	f2e43423          	sd	a4,-216(s0)
ffffffe000201788:	0007a783          	lw	a5,0(a5)
ffffffe00020178c:	f6f40fa3          	sb	a5,-129(s0)
                    putch(ch);
ffffffe000201790:	f7f44703          	lbu	a4,-129(s0)
ffffffe000201794:	f3843783          	ld	a5,-200(s0)
ffffffe000201798:	00070513          	mv	a0,a4
ffffffe00020179c:	000780e7          	jalr	a5
                    pos++;
ffffffe0002017a0:	fe043783          	ld	a5,-32(s0)
ffffffe0002017a4:	00178793          	addi	a5,a5,1
ffffffe0002017a8:	fef43023          	sd	a5,-32(s0)
                    longarg = 0; in_format = 0; 
ffffffe0002017ac:	fe042423          	sw	zero,-24(s0)
ffffffe0002017b0:	fe042623          	sw	zero,-20(s0)
                    break;
ffffffe0002017b4:	04c0006f          	j	ffffffe000201800 <vprintfmt+0x4d4>
                }
                default:
                    break;
            }
        }
        else if(*fmt == '%') {
ffffffe0002017b8:	f3043783          	ld	a5,-208(s0)
ffffffe0002017bc:	0007c783          	lbu	a5,0(a5)
ffffffe0002017c0:	00078713          	mv	a4,a5
ffffffe0002017c4:	02500793          	li	a5,37
ffffffe0002017c8:	00f71863          	bne	a4,a5,ffffffe0002017d8 <vprintfmt+0x4ac>
          in_format = 1;
ffffffe0002017cc:	00100793          	li	a5,1
ffffffe0002017d0:	fef42623          	sw	a5,-20(s0)
ffffffe0002017d4:	02c0006f          	j	ffffffe000201800 <vprintfmt+0x4d4>
        }
        else {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
            putch(*fmt);
ffffffe0002017d8:	f3043783          	ld	a5,-208(s0)
ffffffe0002017dc:	0007c703          	lbu	a4,0(a5)
ffffffe0002017e0:	f3843783          	ld	a5,-200(s0)
ffffffe0002017e4:	00070513          	mv	a0,a4
ffffffe0002017e8:	000780e7          	jalr	a5
            pos++;
ffffffe0002017ec:	fe043783          	ld	a5,-32(s0)
ffffffe0002017f0:	00178793          	addi	a5,a5,1
ffffffe0002017f4:	fef43023          	sd	a5,-32(s0)
ffffffe0002017f8:	0080006f          	j	ffffffe000201800 <vprintfmt+0x4d4>
                    break;
ffffffe0002017fc:	00000013          	nop
    for( ; *fmt; fmt++) {
ffffffe000201800:	f3043783          	ld	a5,-208(s0)
ffffffe000201804:	00178793          	addi	a5,a5,1
ffffffe000201808:	f2f43823          	sd	a5,-208(s0)
ffffffe00020180c:	f3043783          	ld	a5,-208(s0)
ffffffe000201810:	0007c783          	lbu	a5,0(a5)
ffffffe000201814:	b40792e3          	bnez	a5,ffffffe000201358 <vprintfmt+0x2c>
        }
    }
    return pos;
ffffffe000201818:	fe043783          	ld	a5,-32(s0)
ffffffe00020181c:	0007879b          	sext.w	a5,a5
}
ffffffe000201820:	00078513          	mv	a0,a5
ffffffe000201824:	0d813083          	ld	ra,216(sp)
ffffffe000201828:	0d013403          	ld	s0,208(sp)
ffffffe00020182c:	0e010113          	addi	sp,sp,224
ffffffe000201830:	00008067          	ret

ffffffe000201834 <printk>:



int printk(const char* s, ...) {
ffffffe000201834:	f9010113          	addi	sp,sp,-112
ffffffe000201838:	02113423          	sd	ra,40(sp)
ffffffe00020183c:	02813023          	sd	s0,32(sp)
ffffffe000201840:	03010413          	addi	s0,sp,48
ffffffe000201844:	fca43c23          	sd	a0,-40(s0)
ffffffe000201848:	00b43423          	sd	a1,8(s0)
ffffffe00020184c:	00c43823          	sd	a2,16(s0)
ffffffe000201850:	00d43c23          	sd	a3,24(s0)
ffffffe000201854:	02e43023          	sd	a4,32(s0)
ffffffe000201858:	02f43423          	sd	a5,40(s0)
ffffffe00020185c:	03043823          	sd	a6,48(s0)
ffffffe000201860:	03143c23          	sd	a7,56(s0)
    int res = 0;
ffffffe000201864:	fe042623          	sw	zero,-20(s0)
    va_list vl;
    va_start(vl, s);
ffffffe000201868:	04040793          	addi	a5,s0,64
ffffffe00020186c:	fcf43823          	sd	a5,-48(s0)
ffffffe000201870:	fd043783          	ld	a5,-48(s0)
ffffffe000201874:	fc878793          	addi	a5,a5,-56
ffffffe000201878:	fef43023          	sd	a5,-32(s0)
    res = vprintfmt(putc, s, vl);
ffffffe00020187c:	fe043783          	ld	a5,-32(s0)
ffffffe000201880:	00078613          	mv	a2,a5
ffffffe000201884:	fd843583          	ld	a1,-40(s0)
ffffffe000201888:	00000517          	auipc	a0,0x0
ffffffe00020188c:	a5450513          	addi	a0,a0,-1452 # ffffffe0002012dc <putc>
ffffffe000201890:	a9dff0ef          	jal	ra,ffffffe00020132c <vprintfmt>
ffffffe000201894:	00050793          	mv	a5,a0
ffffffe000201898:	fef42623          	sw	a5,-20(s0)
    va_end(vl);
    return res;
ffffffe00020189c:	fec42783          	lw	a5,-20(s0)
}
ffffffe0002018a0:	00078513          	mv	a0,a5
ffffffe0002018a4:	02813083          	ld	ra,40(sp)
ffffffe0002018a8:	02013403          	ld	s0,32(sp)
ffffffe0002018ac:	07010113          	addi	sp,sp,112
ffffffe0002018b0:	00008067          	ret

ffffffe0002018b4 <rand>:

int initialize = 0;
int r[1000];
int t = 0;

uint64 rand() {
ffffffe0002018b4:	fe010113          	addi	sp,sp,-32
ffffffe0002018b8:	00813c23          	sd	s0,24(sp)
ffffffe0002018bc:	02010413          	addi	s0,sp,32
    int i;

    if (initialize == 0) {
ffffffe0002018c0:	00002797          	auipc	a5,0x2
ffffffe0002018c4:	75878793          	addi	a5,a5,1880 # ffffffe000204018 <initialize>
ffffffe0002018c8:	0007a783          	lw	a5,0(a5)
ffffffe0002018cc:	1e079463          	bnez	a5,ffffffe000201ab4 <rand+0x200>
        r[0] = SEED;
ffffffe0002018d0:	00005797          	auipc	a5,0x5
ffffffe0002018d4:	73078793          	addi	a5,a5,1840 # ffffffe000207000 <r>
ffffffe0002018d8:	00d00713          	li	a4,13
ffffffe0002018dc:	00e7a023          	sw	a4,0(a5)
        for (i = 1; i < 31; i++) {
ffffffe0002018e0:	00100793          	li	a5,1
ffffffe0002018e4:	fef42623          	sw	a5,-20(s0)
ffffffe0002018e8:	0c40006f          	j	ffffffe0002019ac <rand+0xf8>
            r[i] = (16807LL * r[i - 1]) % 2147483647;
ffffffe0002018ec:	fec42783          	lw	a5,-20(s0)
ffffffe0002018f0:	fff7879b          	addiw	a5,a5,-1
ffffffe0002018f4:	0007879b          	sext.w	a5,a5
ffffffe0002018f8:	00005717          	auipc	a4,0x5
ffffffe0002018fc:	70870713          	addi	a4,a4,1800 # ffffffe000207000 <r>
ffffffe000201900:	00279793          	slli	a5,a5,0x2
ffffffe000201904:	00f707b3          	add	a5,a4,a5
ffffffe000201908:	0007a783          	lw	a5,0(a5)
ffffffe00020190c:	00078713          	mv	a4,a5
ffffffe000201910:	000047b7          	lui	a5,0x4
ffffffe000201914:	1a778793          	addi	a5,a5,423 # 41a7 <_skernel-0xffffffe0001fbe59>
ffffffe000201918:	02f70733          	mul	a4,a4,a5
ffffffe00020191c:	800007b7          	lui	a5,0x80000
ffffffe000201920:	fff7c793          	not	a5,a5
ffffffe000201924:	02f767b3          	rem	a5,a4,a5
ffffffe000201928:	0007871b          	sext.w	a4,a5
ffffffe00020192c:	00005697          	auipc	a3,0x5
ffffffe000201930:	6d468693          	addi	a3,a3,1748 # ffffffe000207000 <r>
ffffffe000201934:	fec42783          	lw	a5,-20(s0)
ffffffe000201938:	00279793          	slli	a5,a5,0x2
ffffffe00020193c:	00f687b3          	add	a5,a3,a5
ffffffe000201940:	00e7a023          	sw	a4,0(a5) # ffffffff80000000 <_estack+0x1f7fdf7000>
            if (r[i] < 0) {
ffffffe000201944:	00005717          	auipc	a4,0x5
ffffffe000201948:	6bc70713          	addi	a4,a4,1724 # ffffffe000207000 <r>
ffffffe00020194c:	fec42783          	lw	a5,-20(s0)
ffffffe000201950:	00279793          	slli	a5,a5,0x2
ffffffe000201954:	00f707b3          	add	a5,a4,a5
ffffffe000201958:	0007a783          	lw	a5,0(a5)
ffffffe00020195c:	0407d263          	bgez	a5,ffffffe0002019a0 <rand+0xec>
                r[i] += 2147483647;
ffffffe000201960:	00005717          	auipc	a4,0x5
ffffffe000201964:	6a070713          	addi	a4,a4,1696 # ffffffe000207000 <r>
ffffffe000201968:	fec42783          	lw	a5,-20(s0)
ffffffe00020196c:	00279793          	slli	a5,a5,0x2
ffffffe000201970:	00f707b3          	add	a5,a4,a5
ffffffe000201974:	0007a703          	lw	a4,0(a5)
ffffffe000201978:	800007b7          	lui	a5,0x80000
ffffffe00020197c:	fff7c793          	not	a5,a5
ffffffe000201980:	00f707bb          	addw	a5,a4,a5
ffffffe000201984:	0007871b          	sext.w	a4,a5
ffffffe000201988:	00005697          	auipc	a3,0x5
ffffffe00020198c:	67868693          	addi	a3,a3,1656 # ffffffe000207000 <r>
ffffffe000201990:	fec42783          	lw	a5,-20(s0)
ffffffe000201994:	00279793          	slli	a5,a5,0x2
ffffffe000201998:	00f687b3          	add	a5,a3,a5
ffffffe00020199c:	00e7a023          	sw	a4,0(a5) # ffffffff80000000 <_estack+0x1f7fdf7000>
        for (i = 1; i < 31; i++) {
ffffffe0002019a0:	fec42783          	lw	a5,-20(s0)
ffffffe0002019a4:	0017879b          	addiw	a5,a5,1
ffffffe0002019a8:	fef42623          	sw	a5,-20(s0)
ffffffe0002019ac:	fec42783          	lw	a5,-20(s0)
ffffffe0002019b0:	0007871b          	sext.w	a4,a5
ffffffe0002019b4:	01e00793          	li	a5,30
ffffffe0002019b8:	f2e7dae3          	bge	a5,a4,ffffffe0002018ec <rand+0x38>
            }
        }
        for (i = 31; i < 34; i++) {
ffffffe0002019bc:	01f00793          	li	a5,31
ffffffe0002019c0:	fef42623          	sw	a5,-20(s0)
ffffffe0002019c4:	0480006f          	j	ffffffe000201a0c <rand+0x158>
            r[i] = r[i - 31];
ffffffe0002019c8:	fec42783          	lw	a5,-20(s0)
ffffffe0002019cc:	fe17879b          	addiw	a5,a5,-31
ffffffe0002019d0:	0007879b          	sext.w	a5,a5
ffffffe0002019d4:	00005717          	auipc	a4,0x5
ffffffe0002019d8:	62c70713          	addi	a4,a4,1580 # ffffffe000207000 <r>
ffffffe0002019dc:	00279793          	slli	a5,a5,0x2
ffffffe0002019e0:	00f707b3          	add	a5,a4,a5
ffffffe0002019e4:	0007a703          	lw	a4,0(a5)
ffffffe0002019e8:	00005697          	auipc	a3,0x5
ffffffe0002019ec:	61868693          	addi	a3,a3,1560 # ffffffe000207000 <r>
ffffffe0002019f0:	fec42783          	lw	a5,-20(s0)
ffffffe0002019f4:	00279793          	slli	a5,a5,0x2
ffffffe0002019f8:	00f687b3          	add	a5,a3,a5
ffffffe0002019fc:	00e7a023          	sw	a4,0(a5)
        for (i = 31; i < 34; i++) {
ffffffe000201a00:	fec42783          	lw	a5,-20(s0)
ffffffe000201a04:	0017879b          	addiw	a5,a5,1
ffffffe000201a08:	fef42623          	sw	a5,-20(s0)
ffffffe000201a0c:	fec42783          	lw	a5,-20(s0)
ffffffe000201a10:	0007871b          	sext.w	a4,a5
ffffffe000201a14:	02100793          	li	a5,33
ffffffe000201a18:	fae7d8e3          	bge	a5,a4,ffffffe0002019c8 <rand+0x114>
        }
        for (i = 34; i < 344; i++) {
ffffffe000201a1c:	02200793          	li	a5,34
ffffffe000201a20:	fef42623          	sw	a5,-20(s0)
ffffffe000201a24:	0700006f          	j	ffffffe000201a94 <rand+0x1e0>
            r[i] = r[i - 31] + r[i - 3];
ffffffe000201a28:	fec42783          	lw	a5,-20(s0)
ffffffe000201a2c:	fe17879b          	addiw	a5,a5,-31
ffffffe000201a30:	0007879b          	sext.w	a5,a5
ffffffe000201a34:	00005717          	auipc	a4,0x5
ffffffe000201a38:	5cc70713          	addi	a4,a4,1484 # ffffffe000207000 <r>
ffffffe000201a3c:	00279793          	slli	a5,a5,0x2
ffffffe000201a40:	00f707b3          	add	a5,a4,a5
ffffffe000201a44:	0007a703          	lw	a4,0(a5)
ffffffe000201a48:	fec42783          	lw	a5,-20(s0)
ffffffe000201a4c:	ffd7879b          	addiw	a5,a5,-3
ffffffe000201a50:	0007879b          	sext.w	a5,a5
ffffffe000201a54:	00005697          	auipc	a3,0x5
ffffffe000201a58:	5ac68693          	addi	a3,a3,1452 # ffffffe000207000 <r>
ffffffe000201a5c:	00279793          	slli	a5,a5,0x2
ffffffe000201a60:	00f687b3          	add	a5,a3,a5
ffffffe000201a64:	0007a783          	lw	a5,0(a5)
ffffffe000201a68:	00f707bb          	addw	a5,a4,a5
ffffffe000201a6c:	0007871b          	sext.w	a4,a5
ffffffe000201a70:	00005697          	auipc	a3,0x5
ffffffe000201a74:	59068693          	addi	a3,a3,1424 # ffffffe000207000 <r>
ffffffe000201a78:	fec42783          	lw	a5,-20(s0)
ffffffe000201a7c:	00279793          	slli	a5,a5,0x2
ffffffe000201a80:	00f687b3          	add	a5,a3,a5
ffffffe000201a84:	00e7a023          	sw	a4,0(a5)
        for (i = 34; i < 344; i++) {
ffffffe000201a88:	fec42783          	lw	a5,-20(s0)
ffffffe000201a8c:	0017879b          	addiw	a5,a5,1
ffffffe000201a90:	fef42623          	sw	a5,-20(s0)
ffffffe000201a94:	fec42783          	lw	a5,-20(s0)
ffffffe000201a98:	0007871b          	sext.w	a4,a5
ffffffe000201a9c:	15700793          	li	a5,343
ffffffe000201aa0:	f8e7d4e3          	bge	a5,a4,ffffffe000201a28 <rand+0x174>
        }

		initialize = 1;
ffffffe000201aa4:	00002797          	auipc	a5,0x2
ffffffe000201aa8:	57478793          	addi	a5,a5,1396 # ffffffe000204018 <initialize>
ffffffe000201aac:	00100713          	li	a4,1
ffffffe000201ab0:	00e7a023          	sw	a4,0(a5)
    }

	t = t % 656;
ffffffe000201ab4:	00002797          	auipc	a5,0x2
ffffffe000201ab8:	56878793          	addi	a5,a5,1384 # ffffffe00020401c <t>
ffffffe000201abc:	0007a783          	lw	a5,0(a5)
ffffffe000201ac0:	00078713          	mv	a4,a5
ffffffe000201ac4:	29000793          	li	a5,656
ffffffe000201ac8:	02f767bb          	remw	a5,a4,a5
ffffffe000201acc:	0007871b          	sext.w	a4,a5
ffffffe000201ad0:	00002797          	auipc	a5,0x2
ffffffe000201ad4:	54c78793          	addi	a5,a5,1356 # ffffffe00020401c <t>
ffffffe000201ad8:	00e7a023          	sw	a4,0(a5)

    r[t + 344] = r[t + 344 - 31] + r[t + 344 - 3];
ffffffe000201adc:	00002797          	auipc	a5,0x2
ffffffe000201ae0:	54078793          	addi	a5,a5,1344 # ffffffe00020401c <t>
ffffffe000201ae4:	0007a783          	lw	a5,0(a5)
ffffffe000201ae8:	1397879b          	addiw	a5,a5,313
ffffffe000201aec:	0007879b          	sext.w	a5,a5
ffffffe000201af0:	00005717          	auipc	a4,0x5
ffffffe000201af4:	51070713          	addi	a4,a4,1296 # ffffffe000207000 <r>
ffffffe000201af8:	00279793          	slli	a5,a5,0x2
ffffffe000201afc:	00f707b3          	add	a5,a4,a5
ffffffe000201b00:	0007a683          	lw	a3,0(a5)
ffffffe000201b04:	00002797          	auipc	a5,0x2
ffffffe000201b08:	51878793          	addi	a5,a5,1304 # ffffffe00020401c <t>
ffffffe000201b0c:	0007a783          	lw	a5,0(a5)
ffffffe000201b10:	1557879b          	addiw	a5,a5,341
ffffffe000201b14:	0007879b          	sext.w	a5,a5
ffffffe000201b18:	00005717          	auipc	a4,0x5
ffffffe000201b1c:	4e870713          	addi	a4,a4,1256 # ffffffe000207000 <r>
ffffffe000201b20:	00279793          	slli	a5,a5,0x2
ffffffe000201b24:	00f707b3          	add	a5,a4,a5
ffffffe000201b28:	0007a703          	lw	a4,0(a5)
ffffffe000201b2c:	00002797          	auipc	a5,0x2
ffffffe000201b30:	4f078793          	addi	a5,a5,1264 # ffffffe00020401c <t>
ffffffe000201b34:	0007a783          	lw	a5,0(a5)
ffffffe000201b38:	1587879b          	addiw	a5,a5,344
ffffffe000201b3c:	0007879b          	sext.w	a5,a5
ffffffe000201b40:	00e6873b          	addw	a4,a3,a4
ffffffe000201b44:	0007071b          	sext.w	a4,a4
ffffffe000201b48:	00005697          	auipc	a3,0x5
ffffffe000201b4c:	4b868693          	addi	a3,a3,1208 # ffffffe000207000 <r>
ffffffe000201b50:	00279793          	slli	a5,a5,0x2
ffffffe000201b54:	00f687b3          	add	a5,a3,a5
ffffffe000201b58:	00e7a023          	sw	a4,0(a5)
    
	t++;
ffffffe000201b5c:	00002797          	auipc	a5,0x2
ffffffe000201b60:	4c078793          	addi	a5,a5,1216 # ffffffe00020401c <t>
ffffffe000201b64:	0007a783          	lw	a5,0(a5)
ffffffe000201b68:	0017879b          	addiw	a5,a5,1
ffffffe000201b6c:	0007871b          	sext.w	a4,a5
ffffffe000201b70:	00002797          	auipc	a5,0x2
ffffffe000201b74:	4ac78793          	addi	a5,a5,1196 # ffffffe00020401c <t>
ffffffe000201b78:	00e7a023          	sw	a4,0(a5)

    return (uint64)r[t - 1 + 344];
ffffffe000201b7c:	00002797          	auipc	a5,0x2
ffffffe000201b80:	4a078793          	addi	a5,a5,1184 # ffffffe00020401c <t>
ffffffe000201b84:	0007a783          	lw	a5,0(a5)
ffffffe000201b88:	1577879b          	addiw	a5,a5,343
ffffffe000201b8c:	0007879b          	sext.w	a5,a5
ffffffe000201b90:	00005717          	auipc	a4,0x5
ffffffe000201b94:	47070713          	addi	a4,a4,1136 # ffffffe000207000 <r>
ffffffe000201b98:	00279793          	slli	a5,a5,0x2
ffffffe000201b9c:	00f707b3          	add	a5,a4,a5
ffffffe000201ba0:	0007a783          	lw	a5,0(a5)
}
ffffffe000201ba4:	00078513          	mv	a0,a5
ffffffe000201ba8:	01813403          	ld	s0,24(sp)
ffffffe000201bac:	02010113          	addi	sp,sp,32
ffffffe000201bb0:	00008067          	ret

ffffffe000201bb4 <memset>:
#include "string.h"
#include "types.h"

void *memset(void *dst, int c, uint64 n) {
ffffffe000201bb4:	fc010113          	addi	sp,sp,-64
ffffffe000201bb8:	02813c23          	sd	s0,56(sp)
ffffffe000201bbc:	04010413          	addi	s0,sp,64
ffffffe000201bc0:	fca43c23          	sd	a0,-40(s0)
ffffffe000201bc4:	00058793          	mv	a5,a1
ffffffe000201bc8:	fcc43423          	sd	a2,-56(s0)
ffffffe000201bcc:	fcf42a23          	sw	a5,-44(s0)
    char *cdst = (char *)dst;
ffffffe000201bd0:	fd843783          	ld	a5,-40(s0)
ffffffe000201bd4:	fef43023          	sd	a5,-32(s0)
    for (uint64 i = 0; i < n; ++i)
ffffffe000201bd8:	fe043423          	sd	zero,-24(s0)
ffffffe000201bdc:	0280006f          	j	ffffffe000201c04 <memset+0x50>
        cdst[i] = c;
ffffffe000201be0:	fe043703          	ld	a4,-32(s0)
ffffffe000201be4:	fe843783          	ld	a5,-24(s0)
ffffffe000201be8:	00f707b3          	add	a5,a4,a5
ffffffe000201bec:	fd442703          	lw	a4,-44(s0)
ffffffe000201bf0:	0ff77713          	zext.b	a4,a4
ffffffe000201bf4:	00e78023          	sb	a4,0(a5)
    for (uint64 i = 0; i < n; ++i)
ffffffe000201bf8:	fe843783          	ld	a5,-24(s0)
ffffffe000201bfc:	00178793          	addi	a5,a5,1
ffffffe000201c00:	fef43423          	sd	a5,-24(s0)
ffffffe000201c04:	fe843703          	ld	a4,-24(s0)
ffffffe000201c08:	fc843783          	ld	a5,-56(s0)
ffffffe000201c0c:	fcf76ae3          	bltu	a4,a5,ffffffe000201be0 <memset+0x2c>

    return dst;
ffffffe000201c10:	fd843783          	ld	a5,-40(s0)
}
ffffffe000201c14:	00078513          	mv	a0,a5
ffffffe000201c18:	03813403          	ld	s0,56(sp)
ffffffe000201c1c:	04010113          	addi	sp,sp,64
ffffffe000201c20:	00008067          	ret
