
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <entryKernel>:

.text
.globl entryKernel
entryKernel:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 30 12 00       	mov    $0x123000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNEL_BASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 30 12 c0       	mov    %eax,0xc0123000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 20 12 c0       	mov    $0xc0122000,%esp
    # now kernel stack is ready , call the C++ function [init.cpp]

    # call all of ctor for global variable(obj)
    call globCtor
c010002f:	e8 99 0a 00 00       	call   c0100acd <globCtor>

    # init kernel env
    call initKernel
c0100034:	e8 be 0a 00 00       	call   c0100af7 <initKernel>

c0100039 <spin>:

# should never get here
spin:
    jmp spin
c0100039:	eb fe                	jmp    c0100039 <spin>

c010003b <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c010003b:	1e                   	push   %ds
    pushl %es
c010003c:	06                   	push   %es
    pushl %fs
c010003d:	0f a0                	push   %fs
    pushl %gs
c010003f:	0f a8                	push   %gs
    pushal
c0100041:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0100042:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0100047:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0100049:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c010004b:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call _ZN4Trap4trapEPNS_9TrapFrameE
c010004c:	e8 b3 5b 00 00       	call   c0105c04 <_ZN4Trap4trapEPNS_9TrapFrameE>

    # pop the pushed stack pointer
    popl %esp
c0100051:	5c                   	pop    %esp

c0100052 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0100052:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0100053:	0f a9                	pop    %gs
    popl %fs
c0100055:	0f a1                	pop    %fs
    popl %es
c0100057:	07                   	pop    %es
    popl %ds
c0100058:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0100059:	83 c4 08             	add    $0x8,%esp
    iret
c010005c:	cf                   	iret   

c010005d <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c010005d:	6a 00                	push   $0x0
  pushl $0
c010005f:	6a 00                	push   $0x0
  jmp __alltraps
c0100061:	e9 d5 ff ff ff       	jmp    c010003b <__alltraps>

c0100066 <vector1>:
.globl vector1
vector1:
  pushl $0
c0100066:	6a 00                	push   $0x0
  pushl $1
c0100068:	6a 01                	push   $0x1
  jmp __alltraps
c010006a:	e9 cc ff ff ff       	jmp    c010003b <__alltraps>

c010006f <vector2>:
.globl vector2
vector2:
  pushl $0
c010006f:	6a 00                	push   $0x0
  pushl $2
c0100071:	6a 02                	push   $0x2
  jmp __alltraps
c0100073:	e9 c3 ff ff ff       	jmp    c010003b <__alltraps>

c0100078 <vector3>:
.globl vector3
vector3:
  pushl $0
c0100078:	6a 00                	push   $0x0
  pushl $3
c010007a:	6a 03                	push   $0x3
  jmp __alltraps
c010007c:	e9 ba ff ff ff       	jmp    c010003b <__alltraps>

c0100081 <vector4>:
.globl vector4
vector4:
  pushl $0
c0100081:	6a 00                	push   $0x0
  pushl $4
c0100083:	6a 04                	push   $0x4
  jmp __alltraps
c0100085:	e9 b1 ff ff ff       	jmp    c010003b <__alltraps>

c010008a <vector5>:
.globl vector5
vector5:
  pushl $0
c010008a:	6a 00                	push   $0x0
  pushl $5
c010008c:	6a 05                	push   $0x5
  jmp __alltraps
c010008e:	e9 a8 ff ff ff       	jmp    c010003b <__alltraps>

c0100093 <vector6>:
.globl vector6
vector6:
  pushl $0
c0100093:	6a 00                	push   $0x0
  pushl $6
c0100095:	6a 06                	push   $0x6
  jmp __alltraps
c0100097:	e9 9f ff ff ff       	jmp    c010003b <__alltraps>

c010009c <vector7>:
.globl vector7
vector7:
  pushl $0
c010009c:	6a 00                	push   $0x0
  pushl $7
c010009e:	6a 07                	push   $0x7
  jmp __alltraps
c01000a0:	e9 96 ff ff ff       	jmp    c010003b <__alltraps>

c01000a5 <vector8>:
.globl vector8
vector8:
  pushl $8
c01000a5:	6a 08                	push   $0x8
  jmp __alltraps
c01000a7:	e9 8f ff ff ff       	jmp    c010003b <__alltraps>

c01000ac <vector9>:
.globl vector9
vector9:
  pushl $9
c01000ac:	6a 09                	push   $0x9
  jmp __alltraps
c01000ae:	e9 88 ff ff ff       	jmp    c010003b <__alltraps>

c01000b3 <vector10>:
.globl vector10
vector10:
  pushl $10
c01000b3:	6a 0a                	push   $0xa
  jmp __alltraps
c01000b5:	e9 81 ff ff ff       	jmp    c010003b <__alltraps>

c01000ba <vector11>:
.globl vector11
vector11:
  pushl $11
c01000ba:	6a 0b                	push   $0xb
  jmp __alltraps
c01000bc:	e9 7a ff ff ff       	jmp    c010003b <__alltraps>

c01000c1 <vector12>:
.globl vector12
vector12:
  pushl $12
c01000c1:	6a 0c                	push   $0xc
  jmp __alltraps
c01000c3:	e9 73 ff ff ff       	jmp    c010003b <__alltraps>

c01000c8 <vector13>:
.globl vector13
vector13:
  pushl $13
c01000c8:	6a 0d                	push   $0xd
  jmp __alltraps
c01000ca:	e9 6c ff ff ff       	jmp    c010003b <__alltraps>

c01000cf <vector14>:
.globl vector14
vector14:
  pushl $14
c01000cf:	6a 0e                	push   $0xe
  jmp __alltraps
c01000d1:	e9 65 ff ff ff       	jmp    c010003b <__alltraps>

c01000d6 <vector15>:
.globl vector15
vector15:
  pushl $0
c01000d6:	6a 00                	push   $0x0
  pushl $15
c01000d8:	6a 0f                	push   $0xf
  jmp __alltraps
c01000da:	e9 5c ff ff ff       	jmp    c010003b <__alltraps>

c01000df <vector16>:
.globl vector16
vector16:
  pushl $0
c01000df:	6a 00                	push   $0x0
  pushl $16
c01000e1:	6a 10                	push   $0x10
  jmp __alltraps
c01000e3:	e9 53 ff ff ff       	jmp    c010003b <__alltraps>

c01000e8 <vector17>:
.globl vector17
vector17:
  pushl $17
c01000e8:	6a 11                	push   $0x11
  jmp __alltraps
c01000ea:	e9 4c ff ff ff       	jmp    c010003b <__alltraps>

c01000ef <vector18>:
.globl vector18
vector18:
  pushl $0
c01000ef:	6a 00                	push   $0x0
  pushl $18
c01000f1:	6a 12                	push   $0x12
  jmp __alltraps
c01000f3:	e9 43 ff ff ff       	jmp    c010003b <__alltraps>

c01000f8 <vector19>:
.globl vector19
vector19:
  pushl $0
c01000f8:	6a 00                	push   $0x0
  pushl $19
c01000fa:	6a 13                	push   $0x13
  jmp __alltraps
c01000fc:	e9 3a ff ff ff       	jmp    c010003b <__alltraps>

c0100101 <vector20>:
.globl vector20
vector20:
  pushl $0
c0100101:	6a 00                	push   $0x0
  pushl $20
c0100103:	6a 14                	push   $0x14
  jmp __alltraps
c0100105:	e9 31 ff ff ff       	jmp    c010003b <__alltraps>

c010010a <vector21>:
.globl vector21
vector21:
  pushl $0
c010010a:	6a 00                	push   $0x0
  pushl $21
c010010c:	6a 15                	push   $0x15
  jmp __alltraps
c010010e:	e9 28 ff ff ff       	jmp    c010003b <__alltraps>

c0100113 <vector22>:
.globl vector22
vector22:
  pushl $0
c0100113:	6a 00                	push   $0x0
  pushl $22
c0100115:	6a 16                	push   $0x16
  jmp __alltraps
c0100117:	e9 1f ff ff ff       	jmp    c010003b <__alltraps>

c010011c <vector23>:
.globl vector23
vector23:
  pushl $0
c010011c:	6a 00                	push   $0x0
  pushl $23
c010011e:	6a 17                	push   $0x17
  jmp __alltraps
c0100120:	e9 16 ff ff ff       	jmp    c010003b <__alltraps>

c0100125 <vector24>:
.globl vector24
vector24:
  pushl $0
c0100125:	6a 00                	push   $0x0
  pushl $24
c0100127:	6a 18                	push   $0x18
  jmp __alltraps
c0100129:	e9 0d ff ff ff       	jmp    c010003b <__alltraps>

c010012e <vector25>:
.globl vector25
vector25:
  pushl $0
c010012e:	6a 00                	push   $0x0
  pushl $25
c0100130:	6a 19                	push   $0x19
  jmp __alltraps
c0100132:	e9 04 ff ff ff       	jmp    c010003b <__alltraps>

c0100137 <vector26>:
.globl vector26
vector26:
  pushl $0
c0100137:	6a 00                	push   $0x0
  pushl $26
c0100139:	6a 1a                	push   $0x1a
  jmp __alltraps
c010013b:	e9 fb fe ff ff       	jmp    c010003b <__alltraps>

c0100140 <vector27>:
.globl vector27
vector27:
  pushl $0
c0100140:	6a 00                	push   $0x0
  pushl $27
c0100142:	6a 1b                	push   $0x1b
  jmp __alltraps
c0100144:	e9 f2 fe ff ff       	jmp    c010003b <__alltraps>

c0100149 <vector28>:
.globl vector28
vector28:
  pushl $0
c0100149:	6a 00                	push   $0x0
  pushl $28
c010014b:	6a 1c                	push   $0x1c
  jmp __alltraps
c010014d:	e9 e9 fe ff ff       	jmp    c010003b <__alltraps>

c0100152 <vector29>:
.globl vector29
vector29:
  pushl $0
c0100152:	6a 00                	push   $0x0
  pushl $29
c0100154:	6a 1d                	push   $0x1d
  jmp __alltraps
c0100156:	e9 e0 fe ff ff       	jmp    c010003b <__alltraps>

c010015b <vector30>:
.globl vector30
vector30:
  pushl $0
c010015b:	6a 00                	push   $0x0
  pushl $30
c010015d:	6a 1e                	push   $0x1e
  jmp __alltraps
c010015f:	e9 d7 fe ff ff       	jmp    c010003b <__alltraps>

c0100164 <vector31>:
.globl vector31
vector31:
  pushl $0
c0100164:	6a 00                	push   $0x0
  pushl $31
c0100166:	6a 1f                	push   $0x1f
  jmp __alltraps
c0100168:	e9 ce fe ff ff       	jmp    c010003b <__alltraps>

c010016d <vector32>:
.globl vector32
vector32:
  pushl $0
c010016d:	6a 00                	push   $0x0
  pushl $32
c010016f:	6a 20                	push   $0x20
  jmp __alltraps
c0100171:	e9 c5 fe ff ff       	jmp    c010003b <__alltraps>

c0100176 <vector33>:
.globl vector33
vector33:
  pushl $0
c0100176:	6a 00                	push   $0x0
  pushl $33
c0100178:	6a 21                	push   $0x21
  jmp __alltraps
c010017a:	e9 bc fe ff ff       	jmp    c010003b <__alltraps>

c010017f <vector34>:
.globl vector34
vector34:
  pushl $0
c010017f:	6a 00                	push   $0x0
  pushl $34
c0100181:	6a 22                	push   $0x22
  jmp __alltraps
c0100183:	e9 b3 fe ff ff       	jmp    c010003b <__alltraps>

c0100188 <vector35>:
.globl vector35
vector35:
  pushl $0
c0100188:	6a 00                	push   $0x0
  pushl $35
c010018a:	6a 23                	push   $0x23
  jmp __alltraps
c010018c:	e9 aa fe ff ff       	jmp    c010003b <__alltraps>

c0100191 <vector36>:
.globl vector36
vector36:
  pushl $0
c0100191:	6a 00                	push   $0x0
  pushl $36
c0100193:	6a 24                	push   $0x24
  jmp __alltraps
c0100195:	e9 a1 fe ff ff       	jmp    c010003b <__alltraps>

c010019a <vector37>:
.globl vector37
vector37:
  pushl $0
c010019a:	6a 00                	push   $0x0
  pushl $37
c010019c:	6a 25                	push   $0x25
  jmp __alltraps
c010019e:	e9 98 fe ff ff       	jmp    c010003b <__alltraps>

c01001a3 <vector38>:
.globl vector38
vector38:
  pushl $0
c01001a3:	6a 00                	push   $0x0
  pushl $38
c01001a5:	6a 26                	push   $0x26
  jmp __alltraps
c01001a7:	e9 8f fe ff ff       	jmp    c010003b <__alltraps>

c01001ac <vector39>:
.globl vector39
vector39:
  pushl $0
c01001ac:	6a 00                	push   $0x0
  pushl $39
c01001ae:	6a 27                	push   $0x27
  jmp __alltraps
c01001b0:	e9 86 fe ff ff       	jmp    c010003b <__alltraps>

c01001b5 <vector40>:
.globl vector40
vector40:
  pushl $0
c01001b5:	6a 00                	push   $0x0
  pushl $40
c01001b7:	6a 28                	push   $0x28
  jmp __alltraps
c01001b9:	e9 7d fe ff ff       	jmp    c010003b <__alltraps>

c01001be <vector41>:
.globl vector41
vector41:
  pushl $0
c01001be:	6a 00                	push   $0x0
  pushl $41
c01001c0:	6a 29                	push   $0x29
  jmp __alltraps
c01001c2:	e9 74 fe ff ff       	jmp    c010003b <__alltraps>

c01001c7 <vector42>:
.globl vector42
vector42:
  pushl $0
c01001c7:	6a 00                	push   $0x0
  pushl $42
c01001c9:	6a 2a                	push   $0x2a
  jmp __alltraps
c01001cb:	e9 6b fe ff ff       	jmp    c010003b <__alltraps>

c01001d0 <vector43>:
.globl vector43
vector43:
  pushl $0
c01001d0:	6a 00                	push   $0x0
  pushl $43
c01001d2:	6a 2b                	push   $0x2b
  jmp __alltraps
c01001d4:	e9 62 fe ff ff       	jmp    c010003b <__alltraps>

c01001d9 <vector44>:
.globl vector44
vector44:
  pushl $0
c01001d9:	6a 00                	push   $0x0
  pushl $44
c01001db:	6a 2c                	push   $0x2c
  jmp __alltraps
c01001dd:	e9 59 fe ff ff       	jmp    c010003b <__alltraps>

c01001e2 <vector45>:
.globl vector45
vector45:
  pushl $0
c01001e2:	6a 00                	push   $0x0
  pushl $45
c01001e4:	6a 2d                	push   $0x2d
  jmp __alltraps
c01001e6:	e9 50 fe ff ff       	jmp    c010003b <__alltraps>

c01001eb <vector46>:
.globl vector46
vector46:
  pushl $0
c01001eb:	6a 00                	push   $0x0
  pushl $46
c01001ed:	6a 2e                	push   $0x2e
  jmp __alltraps
c01001ef:	e9 47 fe ff ff       	jmp    c010003b <__alltraps>

c01001f4 <vector47>:
.globl vector47
vector47:
  pushl $0
c01001f4:	6a 00                	push   $0x0
  pushl $47
c01001f6:	6a 2f                	push   $0x2f
  jmp __alltraps
c01001f8:	e9 3e fe ff ff       	jmp    c010003b <__alltraps>

c01001fd <vector48>:
.globl vector48
vector48:
  pushl $0
c01001fd:	6a 00                	push   $0x0
  pushl $48
c01001ff:	6a 30                	push   $0x30
  jmp __alltraps
c0100201:	e9 35 fe ff ff       	jmp    c010003b <__alltraps>

c0100206 <vector49>:
.globl vector49
vector49:
  pushl $0
c0100206:	6a 00                	push   $0x0
  pushl $49
c0100208:	6a 31                	push   $0x31
  jmp __alltraps
c010020a:	e9 2c fe ff ff       	jmp    c010003b <__alltraps>

c010020f <vector50>:
.globl vector50
vector50:
  pushl $0
c010020f:	6a 00                	push   $0x0
  pushl $50
c0100211:	6a 32                	push   $0x32
  jmp __alltraps
c0100213:	e9 23 fe ff ff       	jmp    c010003b <__alltraps>

c0100218 <vector51>:
.globl vector51
vector51:
  pushl $0
c0100218:	6a 00                	push   $0x0
  pushl $51
c010021a:	6a 33                	push   $0x33
  jmp __alltraps
c010021c:	e9 1a fe ff ff       	jmp    c010003b <__alltraps>

c0100221 <vector52>:
.globl vector52
vector52:
  pushl $0
c0100221:	6a 00                	push   $0x0
  pushl $52
c0100223:	6a 34                	push   $0x34
  jmp __alltraps
c0100225:	e9 11 fe ff ff       	jmp    c010003b <__alltraps>

c010022a <vector53>:
.globl vector53
vector53:
  pushl $0
c010022a:	6a 00                	push   $0x0
  pushl $53
c010022c:	6a 35                	push   $0x35
  jmp __alltraps
c010022e:	e9 08 fe ff ff       	jmp    c010003b <__alltraps>

c0100233 <vector54>:
.globl vector54
vector54:
  pushl $0
c0100233:	6a 00                	push   $0x0
  pushl $54
c0100235:	6a 36                	push   $0x36
  jmp __alltraps
c0100237:	e9 ff fd ff ff       	jmp    c010003b <__alltraps>

c010023c <vector55>:
.globl vector55
vector55:
  pushl $0
c010023c:	6a 00                	push   $0x0
  pushl $55
c010023e:	6a 37                	push   $0x37
  jmp __alltraps
c0100240:	e9 f6 fd ff ff       	jmp    c010003b <__alltraps>

c0100245 <vector56>:
.globl vector56
vector56:
  pushl $0
c0100245:	6a 00                	push   $0x0
  pushl $56
c0100247:	6a 38                	push   $0x38
  jmp __alltraps
c0100249:	e9 ed fd ff ff       	jmp    c010003b <__alltraps>

c010024e <vector57>:
.globl vector57
vector57:
  pushl $0
c010024e:	6a 00                	push   $0x0
  pushl $57
c0100250:	6a 39                	push   $0x39
  jmp __alltraps
c0100252:	e9 e4 fd ff ff       	jmp    c010003b <__alltraps>

c0100257 <vector58>:
.globl vector58
vector58:
  pushl $0
c0100257:	6a 00                	push   $0x0
  pushl $58
c0100259:	6a 3a                	push   $0x3a
  jmp __alltraps
c010025b:	e9 db fd ff ff       	jmp    c010003b <__alltraps>

c0100260 <vector59>:
.globl vector59
vector59:
  pushl $0
c0100260:	6a 00                	push   $0x0
  pushl $59
c0100262:	6a 3b                	push   $0x3b
  jmp __alltraps
c0100264:	e9 d2 fd ff ff       	jmp    c010003b <__alltraps>

c0100269 <vector60>:
.globl vector60
vector60:
  pushl $0
c0100269:	6a 00                	push   $0x0
  pushl $60
c010026b:	6a 3c                	push   $0x3c
  jmp __alltraps
c010026d:	e9 c9 fd ff ff       	jmp    c010003b <__alltraps>

c0100272 <vector61>:
.globl vector61
vector61:
  pushl $0
c0100272:	6a 00                	push   $0x0
  pushl $61
c0100274:	6a 3d                	push   $0x3d
  jmp __alltraps
c0100276:	e9 c0 fd ff ff       	jmp    c010003b <__alltraps>

c010027b <vector62>:
.globl vector62
vector62:
  pushl $0
c010027b:	6a 00                	push   $0x0
  pushl $62
c010027d:	6a 3e                	push   $0x3e
  jmp __alltraps
c010027f:	e9 b7 fd ff ff       	jmp    c010003b <__alltraps>

c0100284 <vector63>:
.globl vector63
vector63:
  pushl $0
c0100284:	6a 00                	push   $0x0
  pushl $63
c0100286:	6a 3f                	push   $0x3f
  jmp __alltraps
c0100288:	e9 ae fd ff ff       	jmp    c010003b <__alltraps>

c010028d <vector64>:
.globl vector64
vector64:
  pushl $0
c010028d:	6a 00                	push   $0x0
  pushl $64
c010028f:	6a 40                	push   $0x40
  jmp __alltraps
c0100291:	e9 a5 fd ff ff       	jmp    c010003b <__alltraps>

c0100296 <vector65>:
.globl vector65
vector65:
  pushl $0
c0100296:	6a 00                	push   $0x0
  pushl $65
c0100298:	6a 41                	push   $0x41
  jmp __alltraps
c010029a:	e9 9c fd ff ff       	jmp    c010003b <__alltraps>

c010029f <vector66>:
.globl vector66
vector66:
  pushl $0
c010029f:	6a 00                	push   $0x0
  pushl $66
c01002a1:	6a 42                	push   $0x42
  jmp __alltraps
c01002a3:	e9 93 fd ff ff       	jmp    c010003b <__alltraps>

c01002a8 <vector67>:
.globl vector67
vector67:
  pushl $0
c01002a8:	6a 00                	push   $0x0
  pushl $67
c01002aa:	6a 43                	push   $0x43
  jmp __alltraps
c01002ac:	e9 8a fd ff ff       	jmp    c010003b <__alltraps>

c01002b1 <vector68>:
.globl vector68
vector68:
  pushl $0
c01002b1:	6a 00                	push   $0x0
  pushl $68
c01002b3:	6a 44                	push   $0x44
  jmp __alltraps
c01002b5:	e9 81 fd ff ff       	jmp    c010003b <__alltraps>

c01002ba <vector69>:
.globl vector69
vector69:
  pushl $0
c01002ba:	6a 00                	push   $0x0
  pushl $69
c01002bc:	6a 45                	push   $0x45
  jmp __alltraps
c01002be:	e9 78 fd ff ff       	jmp    c010003b <__alltraps>

c01002c3 <vector70>:
.globl vector70
vector70:
  pushl $0
c01002c3:	6a 00                	push   $0x0
  pushl $70
c01002c5:	6a 46                	push   $0x46
  jmp __alltraps
c01002c7:	e9 6f fd ff ff       	jmp    c010003b <__alltraps>

c01002cc <vector71>:
.globl vector71
vector71:
  pushl $0
c01002cc:	6a 00                	push   $0x0
  pushl $71
c01002ce:	6a 47                	push   $0x47
  jmp __alltraps
c01002d0:	e9 66 fd ff ff       	jmp    c010003b <__alltraps>

c01002d5 <vector72>:
.globl vector72
vector72:
  pushl $0
c01002d5:	6a 00                	push   $0x0
  pushl $72
c01002d7:	6a 48                	push   $0x48
  jmp __alltraps
c01002d9:	e9 5d fd ff ff       	jmp    c010003b <__alltraps>

c01002de <vector73>:
.globl vector73
vector73:
  pushl $0
c01002de:	6a 00                	push   $0x0
  pushl $73
c01002e0:	6a 49                	push   $0x49
  jmp __alltraps
c01002e2:	e9 54 fd ff ff       	jmp    c010003b <__alltraps>

c01002e7 <vector74>:
.globl vector74
vector74:
  pushl $0
c01002e7:	6a 00                	push   $0x0
  pushl $74
c01002e9:	6a 4a                	push   $0x4a
  jmp __alltraps
c01002eb:	e9 4b fd ff ff       	jmp    c010003b <__alltraps>

c01002f0 <vector75>:
.globl vector75
vector75:
  pushl $0
c01002f0:	6a 00                	push   $0x0
  pushl $75
c01002f2:	6a 4b                	push   $0x4b
  jmp __alltraps
c01002f4:	e9 42 fd ff ff       	jmp    c010003b <__alltraps>

c01002f9 <vector76>:
.globl vector76
vector76:
  pushl $0
c01002f9:	6a 00                	push   $0x0
  pushl $76
c01002fb:	6a 4c                	push   $0x4c
  jmp __alltraps
c01002fd:	e9 39 fd ff ff       	jmp    c010003b <__alltraps>

c0100302 <vector77>:
.globl vector77
vector77:
  pushl $0
c0100302:	6a 00                	push   $0x0
  pushl $77
c0100304:	6a 4d                	push   $0x4d
  jmp __alltraps
c0100306:	e9 30 fd ff ff       	jmp    c010003b <__alltraps>

c010030b <vector78>:
.globl vector78
vector78:
  pushl $0
c010030b:	6a 00                	push   $0x0
  pushl $78
c010030d:	6a 4e                	push   $0x4e
  jmp __alltraps
c010030f:	e9 27 fd ff ff       	jmp    c010003b <__alltraps>

c0100314 <vector79>:
.globl vector79
vector79:
  pushl $0
c0100314:	6a 00                	push   $0x0
  pushl $79
c0100316:	6a 4f                	push   $0x4f
  jmp __alltraps
c0100318:	e9 1e fd ff ff       	jmp    c010003b <__alltraps>

c010031d <vector80>:
.globl vector80
vector80:
  pushl $0
c010031d:	6a 00                	push   $0x0
  pushl $80
c010031f:	6a 50                	push   $0x50
  jmp __alltraps
c0100321:	e9 15 fd ff ff       	jmp    c010003b <__alltraps>

c0100326 <vector81>:
.globl vector81
vector81:
  pushl $0
c0100326:	6a 00                	push   $0x0
  pushl $81
c0100328:	6a 51                	push   $0x51
  jmp __alltraps
c010032a:	e9 0c fd ff ff       	jmp    c010003b <__alltraps>

c010032f <vector82>:
.globl vector82
vector82:
  pushl $0
c010032f:	6a 00                	push   $0x0
  pushl $82
c0100331:	6a 52                	push   $0x52
  jmp __alltraps
c0100333:	e9 03 fd ff ff       	jmp    c010003b <__alltraps>

c0100338 <vector83>:
.globl vector83
vector83:
  pushl $0
c0100338:	6a 00                	push   $0x0
  pushl $83
c010033a:	6a 53                	push   $0x53
  jmp __alltraps
c010033c:	e9 fa fc ff ff       	jmp    c010003b <__alltraps>

c0100341 <vector84>:
.globl vector84
vector84:
  pushl $0
c0100341:	6a 00                	push   $0x0
  pushl $84
c0100343:	6a 54                	push   $0x54
  jmp __alltraps
c0100345:	e9 f1 fc ff ff       	jmp    c010003b <__alltraps>

c010034a <vector85>:
.globl vector85
vector85:
  pushl $0
c010034a:	6a 00                	push   $0x0
  pushl $85
c010034c:	6a 55                	push   $0x55
  jmp __alltraps
c010034e:	e9 e8 fc ff ff       	jmp    c010003b <__alltraps>

c0100353 <vector86>:
.globl vector86
vector86:
  pushl $0
c0100353:	6a 00                	push   $0x0
  pushl $86
c0100355:	6a 56                	push   $0x56
  jmp __alltraps
c0100357:	e9 df fc ff ff       	jmp    c010003b <__alltraps>

c010035c <vector87>:
.globl vector87
vector87:
  pushl $0
c010035c:	6a 00                	push   $0x0
  pushl $87
c010035e:	6a 57                	push   $0x57
  jmp __alltraps
c0100360:	e9 d6 fc ff ff       	jmp    c010003b <__alltraps>

c0100365 <vector88>:
.globl vector88
vector88:
  pushl $0
c0100365:	6a 00                	push   $0x0
  pushl $88
c0100367:	6a 58                	push   $0x58
  jmp __alltraps
c0100369:	e9 cd fc ff ff       	jmp    c010003b <__alltraps>

c010036e <vector89>:
.globl vector89
vector89:
  pushl $0
c010036e:	6a 00                	push   $0x0
  pushl $89
c0100370:	6a 59                	push   $0x59
  jmp __alltraps
c0100372:	e9 c4 fc ff ff       	jmp    c010003b <__alltraps>

c0100377 <vector90>:
.globl vector90
vector90:
  pushl $0
c0100377:	6a 00                	push   $0x0
  pushl $90
c0100379:	6a 5a                	push   $0x5a
  jmp __alltraps
c010037b:	e9 bb fc ff ff       	jmp    c010003b <__alltraps>

c0100380 <vector91>:
.globl vector91
vector91:
  pushl $0
c0100380:	6a 00                	push   $0x0
  pushl $91
c0100382:	6a 5b                	push   $0x5b
  jmp __alltraps
c0100384:	e9 b2 fc ff ff       	jmp    c010003b <__alltraps>

c0100389 <vector92>:
.globl vector92
vector92:
  pushl $0
c0100389:	6a 00                	push   $0x0
  pushl $92
c010038b:	6a 5c                	push   $0x5c
  jmp __alltraps
c010038d:	e9 a9 fc ff ff       	jmp    c010003b <__alltraps>

c0100392 <vector93>:
.globl vector93
vector93:
  pushl $0
c0100392:	6a 00                	push   $0x0
  pushl $93
c0100394:	6a 5d                	push   $0x5d
  jmp __alltraps
c0100396:	e9 a0 fc ff ff       	jmp    c010003b <__alltraps>

c010039b <vector94>:
.globl vector94
vector94:
  pushl $0
c010039b:	6a 00                	push   $0x0
  pushl $94
c010039d:	6a 5e                	push   $0x5e
  jmp __alltraps
c010039f:	e9 97 fc ff ff       	jmp    c010003b <__alltraps>

c01003a4 <vector95>:
.globl vector95
vector95:
  pushl $0
c01003a4:	6a 00                	push   $0x0
  pushl $95
c01003a6:	6a 5f                	push   $0x5f
  jmp __alltraps
c01003a8:	e9 8e fc ff ff       	jmp    c010003b <__alltraps>

c01003ad <vector96>:
.globl vector96
vector96:
  pushl $0
c01003ad:	6a 00                	push   $0x0
  pushl $96
c01003af:	6a 60                	push   $0x60
  jmp __alltraps
c01003b1:	e9 85 fc ff ff       	jmp    c010003b <__alltraps>

c01003b6 <vector97>:
.globl vector97
vector97:
  pushl $0
c01003b6:	6a 00                	push   $0x0
  pushl $97
c01003b8:	6a 61                	push   $0x61
  jmp __alltraps
c01003ba:	e9 7c fc ff ff       	jmp    c010003b <__alltraps>

c01003bf <vector98>:
.globl vector98
vector98:
  pushl $0
c01003bf:	6a 00                	push   $0x0
  pushl $98
c01003c1:	6a 62                	push   $0x62
  jmp __alltraps
c01003c3:	e9 73 fc ff ff       	jmp    c010003b <__alltraps>

c01003c8 <vector99>:
.globl vector99
vector99:
  pushl $0
c01003c8:	6a 00                	push   $0x0
  pushl $99
c01003ca:	6a 63                	push   $0x63
  jmp __alltraps
c01003cc:	e9 6a fc ff ff       	jmp    c010003b <__alltraps>

c01003d1 <vector100>:
.globl vector100
vector100:
  pushl $0
c01003d1:	6a 00                	push   $0x0
  pushl $100
c01003d3:	6a 64                	push   $0x64
  jmp __alltraps
c01003d5:	e9 61 fc ff ff       	jmp    c010003b <__alltraps>

c01003da <vector101>:
.globl vector101
vector101:
  pushl $0
c01003da:	6a 00                	push   $0x0
  pushl $101
c01003dc:	6a 65                	push   $0x65
  jmp __alltraps
c01003de:	e9 58 fc ff ff       	jmp    c010003b <__alltraps>

c01003e3 <vector102>:
.globl vector102
vector102:
  pushl $0
c01003e3:	6a 00                	push   $0x0
  pushl $102
c01003e5:	6a 66                	push   $0x66
  jmp __alltraps
c01003e7:	e9 4f fc ff ff       	jmp    c010003b <__alltraps>

c01003ec <vector103>:
.globl vector103
vector103:
  pushl $0
c01003ec:	6a 00                	push   $0x0
  pushl $103
c01003ee:	6a 67                	push   $0x67
  jmp __alltraps
c01003f0:	e9 46 fc ff ff       	jmp    c010003b <__alltraps>

c01003f5 <vector104>:
.globl vector104
vector104:
  pushl $0
c01003f5:	6a 00                	push   $0x0
  pushl $104
c01003f7:	6a 68                	push   $0x68
  jmp __alltraps
c01003f9:	e9 3d fc ff ff       	jmp    c010003b <__alltraps>

c01003fe <vector105>:
.globl vector105
vector105:
  pushl $0
c01003fe:	6a 00                	push   $0x0
  pushl $105
c0100400:	6a 69                	push   $0x69
  jmp __alltraps
c0100402:	e9 34 fc ff ff       	jmp    c010003b <__alltraps>

c0100407 <vector106>:
.globl vector106
vector106:
  pushl $0
c0100407:	6a 00                	push   $0x0
  pushl $106
c0100409:	6a 6a                	push   $0x6a
  jmp __alltraps
c010040b:	e9 2b fc ff ff       	jmp    c010003b <__alltraps>

c0100410 <vector107>:
.globl vector107
vector107:
  pushl $0
c0100410:	6a 00                	push   $0x0
  pushl $107
c0100412:	6a 6b                	push   $0x6b
  jmp __alltraps
c0100414:	e9 22 fc ff ff       	jmp    c010003b <__alltraps>

c0100419 <vector108>:
.globl vector108
vector108:
  pushl $0
c0100419:	6a 00                	push   $0x0
  pushl $108
c010041b:	6a 6c                	push   $0x6c
  jmp __alltraps
c010041d:	e9 19 fc ff ff       	jmp    c010003b <__alltraps>

c0100422 <vector109>:
.globl vector109
vector109:
  pushl $0
c0100422:	6a 00                	push   $0x0
  pushl $109
c0100424:	6a 6d                	push   $0x6d
  jmp __alltraps
c0100426:	e9 10 fc ff ff       	jmp    c010003b <__alltraps>

c010042b <vector110>:
.globl vector110
vector110:
  pushl $0
c010042b:	6a 00                	push   $0x0
  pushl $110
c010042d:	6a 6e                	push   $0x6e
  jmp __alltraps
c010042f:	e9 07 fc ff ff       	jmp    c010003b <__alltraps>

c0100434 <vector111>:
.globl vector111
vector111:
  pushl $0
c0100434:	6a 00                	push   $0x0
  pushl $111
c0100436:	6a 6f                	push   $0x6f
  jmp __alltraps
c0100438:	e9 fe fb ff ff       	jmp    c010003b <__alltraps>

c010043d <vector112>:
.globl vector112
vector112:
  pushl $0
c010043d:	6a 00                	push   $0x0
  pushl $112
c010043f:	6a 70                	push   $0x70
  jmp __alltraps
c0100441:	e9 f5 fb ff ff       	jmp    c010003b <__alltraps>

c0100446 <vector113>:
.globl vector113
vector113:
  pushl $0
c0100446:	6a 00                	push   $0x0
  pushl $113
c0100448:	6a 71                	push   $0x71
  jmp __alltraps
c010044a:	e9 ec fb ff ff       	jmp    c010003b <__alltraps>

c010044f <vector114>:
.globl vector114
vector114:
  pushl $0
c010044f:	6a 00                	push   $0x0
  pushl $114
c0100451:	6a 72                	push   $0x72
  jmp __alltraps
c0100453:	e9 e3 fb ff ff       	jmp    c010003b <__alltraps>

c0100458 <vector115>:
.globl vector115
vector115:
  pushl $0
c0100458:	6a 00                	push   $0x0
  pushl $115
c010045a:	6a 73                	push   $0x73
  jmp __alltraps
c010045c:	e9 da fb ff ff       	jmp    c010003b <__alltraps>

c0100461 <vector116>:
.globl vector116
vector116:
  pushl $0
c0100461:	6a 00                	push   $0x0
  pushl $116
c0100463:	6a 74                	push   $0x74
  jmp __alltraps
c0100465:	e9 d1 fb ff ff       	jmp    c010003b <__alltraps>

c010046a <vector117>:
.globl vector117
vector117:
  pushl $0
c010046a:	6a 00                	push   $0x0
  pushl $117
c010046c:	6a 75                	push   $0x75
  jmp __alltraps
c010046e:	e9 c8 fb ff ff       	jmp    c010003b <__alltraps>

c0100473 <vector118>:
.globl vector118
vector118:
  pushl $0
c0100473:	6a 00                	push   $0x0
  pushl $118
c0100475:	6a 76                	push   $0x76
  jmp __alltraps
c0100477:	e9 bf fb ff ff       	jmp    c010003b <__alltraps>

c010047c <vector119>:
.globl vector119
vector119:
  pushl $0
c010047c:	6a 00                	push   $0x0
  pushl $119
c010047e:	6a 77                	push   $0x77
  jmp __alltraps
c0100480:	e9 b6 fb ff ff       	jmp    c010003b <__alltraps>

c0100485 <vector120>:
.globl vector120
vector120:
  pushl $0
c0100485:	6a 00                	push   $0x0
  pushl $120
c0100487:	6a 78                	push   $0x78
  jmp __alltraps
c0100489:	e9 ad fb ff ff       	jmp    c010003b <__alltraps>

c010048e <vector121>:
.globl vector121
vector121:
  pushl $0
c010048e:	6a 00                	push   $0x0
  pushl $121
c0100490:	6a 79                	push   $0x79
  jmp __alltraps
c0100492:	e9 a4 fb ff ff       	jmp    c010003b <__alltraps>

c0100497 <vector122>:
.globl vector122
vector122:
  pushl $0
c0100497:	6a 00                	push   $0x0
  pushl $122
c0100499:	6a 7a                	push   $0x7a
  jmp __alltraps
c010049b:	e9 9b fb ff ff       	jmp    c010003b <__alltraps>

c01004a0 <vector123>:
.globl vector123
vector123:
  pushl $0
c01004a0:	6a 00                	push   $0x0
  pushl $123
c01004a2:	6a 7b                	push   $0x7b
  jmp __alltraps
c01004a4:	e9 92 fb ff ff       	jmp    c010003b <__alltraps>

c01004a9 <vector124>:
.globl vector124
vector124:
  pushl $0
c01004a9:	6a 00                	push   $0x0
  pushl $124
c01004ab:	6a 7c                	push   $0x7c
  jmp __alltraps
c01004ad:	e9 89 fb ff ff       	jmp    c010003b <__alltraps>

c01004b2 <vector125>:
.globl vector125
vector125:
  pushl $0
c01004b2:	6a 00                	push   $0x0
  pushl $125
c01004b4:	6a 7d                	push   $0x7d
  jmp __alltraps
c01004b6:	e9 80 fb ff ff       	jmp    c010003b <__alltraps>

c01004bb <vector126>:
.globl vector126
vector126:
  pushl $0
c01004bb:	6a 00                	push   $0x0
  pushl $126
c01004bd:	6a 7e                	push   $0x7e
  jmp __alltraps
c01004bf:	e9 77 fb ff ff       	jmp    c010003b <__alltraps>

c01004c4 <vector127>:
.globl vector127
vector127:
  pushl $0
c01004c4:	6a 00                	push   $0x0
  pushl $127
c01004c6:	6a 7f                	push   $0x7f
  jmp __alltraps
c01004c8:	e9 6e fb ff ff       	jmp    c010003b <__alltraps>

c01004cd <vector128>:
.globl vector128
vector128:
  pushl $0
c01004cd:	6a 00                	push   $0x0
  pushl $128
c01004cf:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01004d4:	e9 62 fb ff ff       	jmp    c010003b <__alltraps>

c01004d9 <vector129>:
.globl vector129
vector129:
  pushl $0
c01004d9:	6a 00                	push   $0x0
  pushl $129
c01004db:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01004e0:	e9 56 fb ff ff       	jmp    c010003b <__alltraps>

c01004e5 <vector130>:
.globl vector130
vector130:
  pushl $0
c01004e5:	6a 00                	push   $0x0
  pushl $130
c01004e7:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01004ec:	e9 4a fb ff ff       	jmp    c010003b <__alltraps>

c01004f1 <vector131>:
.globl vector131
vector131:
  pushl $0
c01004f1:	6a 00                	push   $0x0
  pushl $131
c01004f3:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01004f8:	e9 3e fb ff ff       	jmp    c010003b <__alltraps>

c01004fd <vector132>:
.globl vector132
vector132:
  pushl $0
c01004fd:	6a 00                	push   $0x0
  pushl $132
c01004ff:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0100504:	e9 32 fb ff ff       	jmp    c010003b <__alltraps>

c0100509 <vector133>:
.globl vector133
vector133:
  pushl $0
c0100509:	6a 00                	push   $0x0
  pushl $133
c010050b:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0100510:	e9 26 fb ff ff       	jmp    c010003b <__alltraps>

c0100515 <vector134>:
.globl vector134
vector134:
  pushl $0
c0100515:	6a 00                	push   $0x0
  pushl $134
c0100517:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c010051c:	e9 1a fb ff ff       	jmp    c010003b <__alltraps>

c0100521 <vector135>:
.globl vector135
vector135:
  pushl $0
c0100521:	6a 00                	push   $0x0
  pushl $135
c0100523:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0100528:	e9 0e fb ff ff       	jmp    c010003b <__alltraps>

c010052d <vector136>:
.globl vector136
vector136:
  pushl $0
c010052d:	6a 00                	push   $0x0
  pushl $136
c010052f:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0100534:	e9 02 fb ff ff       	jmp    c010003b <__alltraps>

c0100539 <vector137>:
.globl vector137
vector137:
  pushl $0
c0100539:	6a 00                	push   $0x0
  pushl $137
c010053b:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0100540:	e9 f6 fa ff ff       	jmp    c010003b <__alltraps>

c0100545 <vector138>:
.globl vector138
vector138:
  pushl $0
c0100545:	6a 00                	push   $0x0
  pushl $138
c0100547:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c010054c:	e9 ea fa ff ff       	jmp    c010003b <__alltraps>

c0100551 <vector139>:
.globl vector139
vector139:
  pushl $0
c0100551:	6a 00                	push   $0x0
  pushl $139
c0100553:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0100558:	e9 de fa ff ff       	jmp    c010003b <__alltraps>

c010055d <vector140>:
.globl vector140
vector140:
  pushl $0
c010055d:	6a 00                	push   $0x0
  pushl $140
c010055f:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0100564:	e9 d2 fa ff ff       	jmp    c010003b <__alltraps>

c0100569 <vector141>:
.globl vector141
vector141:
  pushl $0
c0100569:	6a 00                	push   $0x0
  pushl $141
c010056b:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0100570:	e9 c6 fa ff ff       	jmp    c010003b <__alltraps>

c0100575 <vector142>:
.globl vector142
vector142:
  pushl $0
c0100575:	6a 00                	push   $0x0
  pushl $142
c0100577:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c010057c:	e9 ba fa ff ff       	jmp    c010003b <__alltraps>

c0100581 <vector143>:
.globl vector143
vector143:
  pushl $0
c0100581:	6a 00                	push   $0x0
  pushl $143
c0100583:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0100588:	e9 ae fa ff ff       	jmp    c010003b <__alltraps>

c010058d <vector144>:
.globl vector144
vector144:
  pushl $0
c010058d:	6a 00                	push   $0x0
  pushl $144
c010058f:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0100594:	e9 a2 fa ff ff       	jmp    c010003b <__alltraps>

c0100599 <vector145>:
.globl vector145
vector145:
  pushl $0
c0100599:	6a 00                	push   $0x0
  pushl $145
c010059b:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01005a0:	e9 96 fa ff ff       	jmp    c010003b <__alltraps>

c01005a5 <vector146>:
.globl vector146
vector146:
  pushl $0
c01005a5:	6a 00                	push   $0x0
  pushl $146
c01005a7:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01005ac:	e9 8a fa ff ff       	jmp    c010003b <__alltraps>

c01005b1 <vector147>:
.globl vector147
vector147:
  pushl $0
c01005b1:	6a 00                	push   $0x0
  pushl $147
c01005b3:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01005b8:	e9 7e fa ff ff       	jmp    c010003b <__alltraps>

c01005bd <vector148>:
.globl vector148
vector148:
  pushl $0
c01005bd:	6a 00                	push   $0x0
  pushl $148
c01005bf:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01005c4:	e9 72 fa ff ff       	jmp    c010003b <__alltraps>

c01005c9 <vector149>:
.globl vector149
vector149:
  pushl $0
c01005c9:	6a 00                	push   $0x0
  pushl $149
c01005cb:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01005d0:	e9 66 fa ff ff       	jmp    c010003b <__alltraps>

c01005d5 <vector150>:
.globl vector150
vector150:
  pushl $0
c01005d5:	6a 00                	push   $0x0
  pushl $150
c01005d7:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01005dc:	e9 5a fa ff ff       	jmp    c010003b <__alltraps>

c01005e1 <vector151>:
.globl vector151
vector151:
  pushl $0
c01005e1:	6a 00                	push   $0x0
  pushl $151
c01005e3:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01005e8:	e9 4e fa ff ff       	jmp    c010003b <__alltraps>

c01005ed <vector152>:
.globl vector152
vector152:
  pushl $0
c01005ed:	6a 00                	push   $0x0
  pushl $152
c01005ef:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01005f4:	e9 42 fa ff ff       	jmp    c010003b <__alltraps>

c01005f9 <vector153>:
.globl vector153
vector153:
  pushl $0
c01005f9:	6a 00                	push   $0x0
  pushl $153
c01005fb:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0100600:	e9 36 fa ff ff       	jmp    c010003b <__alltraps>

c0100605 <vector154>:
.globl vector154
vector154:
  pushl $0
c0100605:	6a 00                	push   $0x0
  pushl $154
c0100607:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010060c:	e9 2a fa ff ff       	jmp    c010003b <__alltraps>

c0100611 <vector155>:
.globl vector155
vector155:
  pushl $0
c0100611:	6a 00                	push   $0x0
  pushl $155
c0100613:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0100618:	e9 1e fa ff ff       	jmp    c010003b <__alltraps>

c010061d <vector156>:
.globl vector156
vector156:
  pushl $0
c010061d:	6a 00                	push   $0x0
  pushl $156
c010061f:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0100624:	e9 12 fa ff ff       	jmp    c010003b <__alltraps>

c0100629 <vector157>:
.globl vector157
vector157:
  pushl $0
c0100629:	6a 00                	push   $0x0
  pushl $157
c010062b:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0100630:	e9 06 fa ff ff       	jmp    c010003b <__alltraps>

c0100635 <vector158>:
.globl vector158
vector158:
  pushl $0
c0100635:	6a 00                	push   $0x0
  pushl $158
c0100637:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010063c:	e9 fa f9 ff ff       	jmp    c010003b <__alltraps>

c0100641 <vector159>:
.globl vector159
vector159:
  pushl $0
c0100641:	6a 00                	push   $0x0
  pushl $159
c0100643:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0100648:	e9 ee f9 ff ff       	jmp    c010003b <__alltraps>

c010064d <vector160>:
.globl vector160
vector160:
  pushl $0
c010064d:	6a 00                	push   $0x0
  pushl $160
c010064f:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0100654:	e9 e2 f9 ff ff       	jmp    c010003b <__alltraps>

c0100659 <vector161>:
.globl vector161
vector161:
  pushl $0
c0100659:	6a 00                	push   $0x0
  pushl $161
c010065b:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0100660:	e9 d6 f9 ff ff       	jmp    c010003b <__alltraps>

c0100665 <vector162>:
.globl vector162
vector162:
  pushl $0
c0100665:	6a 00                	push   $0x0
  pushl $162
c0100667:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c010066c:	e9 ca f9 ff ff       	jmp    c010003b <__alltraps>

c0100671 <vector163>:
.globl vector163
vector163:
  pushl $0
c0100671:	6a 00                	push   $0x0
  pushl $163
c0100673:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0100678:	e9 be f9 ff ff       	jmp    c010003b <__alltraps>

c010067d <vector164>:
.globl vector164
vector164:
  pushl $0
c010067d:	6a 00                	push   $0x0
  pushl $164
c010067f:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0100684:	e9 b2 f9 ff ff       	jmp    c010003b <__alltraps>

c0100689 <vector165>:
.globl vector165
vector165:
  pushl $0
c0100689:	6a 00                	push   $0x0
  pushl $165
c010068b:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0100690:	e9 a6 f9 ff ff       	jmp    c010003b <__alltraps>

c0100695 <vector166>:
.globl vector166
vector166:
  pushl $0
c0100695:	6a 00                	push   $0x0
  pushl $166
c0100697:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010069c:	e9 9a f9 ff ff       	jmp    c010003b <__alltraps>

c01006a1 <vector167>:
.globl vector167
vector167:
  pushl $0
c01006a1:	6a 00                	push   $0x0
  pushl $167
c01006a3:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01006a8:	e9 8e f9 ff ff       	jmp    c010003b <__alltraps>

c01006ad <vector168>:
.globl vector168
vector168:
  pushl $0
c01006ad:	6a 00                	push   $0x0
  pushl $168
c01006af:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01006b4:	e9 82 f9 ff ff       	jmp    c010003b <__alltraps>

c01006b9 <vector169>:
.globl vector169
vector169:
  pushl $0
c01006b9:	6a 00                	push   $0x0
  pushl $169
c01006bb:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01006c0:	e9 76 f9 ff ff       	jmp    c010003b <__alltraps>

c01006c5 <vector170>:
.globl vector170
vector170:
  pushl $0
c01006c5:	6a 00                	push   $0x0
  pushl $170
c01006c7:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01006cc:	e9 6a f9 ff ff       	jmp    c010003b <__alltraps>

c01006d1 <vector171>:
.globl vector171
vector171:
  pushl $0
c01006d1:	6a 00                	push   $0x0
  pushl $171
c01006d3:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01006d8:	e9 5e f9 ff ff       	jmp    c010003b <__alltraps>

c01006dd <vector172>:
.globl vector172
vector172:
  pushl $0
c01006dd:	6a 00                	push   $0x0
  pushl $172
c01006df:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01006e4:	e9 52 f9 ff ff       	jmp    c010003b <__alltraps>

c01006e9 <vector173>:
.globl vector173
vector173:
  pushl $0
c01006e9:	6a 00                	push   $0x0
  pushl $173
c01006eb:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01006f0:	e9 46 f9 ff ff       	jmp    c010003b <__alltraps>

c01006f5 <vector174>:
.globl vector174
vector174:
  pushl $0
c01006f5:	6a 00                	push   $0x0
  pushl $174
c01006f7:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01006fc:	e9 3a f9 ff ff       	jmp    c010003b <__alltraps>

c0100701 <vector175>:
.globl vector175
vector175:
  pushl $0
c0100701:	6a 00                	push   $0x0
  pushl $175
c0100703:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0100708:	e9 2e f9 ff ff       	jmp    c010003b <__alltraps>

c010070d <vector176>:
.globl vector176
vector176:
  pushl $0
c010070d:	6a 00                	push   $0x0
  pushl $176
c010070f:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0100714:	e9 22 f9 ff ff       	jmp    c010003b <__alltraps>

c0100719 <vector177>:
.globl vector177
vector177:
  pushl $0
c0100719:	6a 00                	push   $0x0
  pushl $177
c010071b:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0100720:	e9 16 f9 ff ff       	jmp    c010003b <__alltraps>

c0100725 <vector178>:
.globl vector178
vector178:
  pushl $0
c0100725:	6a 00                	push   $0x0
  pushl $178
c0100727:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010072c:	e9 0a f9 ff ff       	jmp    c010003b <__alltraps>

c0100731 <vector179>:
.globl vector179
vector179:
  pushl $0
c0100731:	6a 00                	push   $0x0
  pushl $179
c0100733:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0100738:	e9 fe f8 ff ff       	jmp    c010003b <__alltraps>

c010073d <vector180>:
.globl vector180
vector180:
  pushl $0
c010073d:	6a 00                	push   $0x0
  pushl $180
c010073f:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0100744:	e9 f2 f8 ff ff       	jmp    c010003b <__alltraps>

c0100749 <vector181>:
.globl vector181
vector181:
  pushl $0
c0100749:	6a 00                	push   $0x0
  pushl $181
c010074b:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0100750:	e9 e6 f8 ff ff       	jmp    c010003b <__alltraps>

c0100755 <vector182>:
.globl vector182
vector182:
  pushl $0
c0100755:	6a 00                	push   $0x0
  pushl $182
c0100757:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c010075c:	e9 da f8 ff ff       	jmp    c010003b <__alltraps>

c0100761 <vector183>:
.globl vector183
vector183:
  pushl $0
c0100761:	6a 00                	push   $0x0
  pushl $183
c0100763:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0100768:	e9 ce f8 ff ff       	jmp    c010003b <__alltraps>

c010076d <vector184>:
.globl vector184
vector184:
  pushl $0
c010076d:	6a 00                	push   $0x0
  pushl $184
c010076f:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0100774:	e9 c2 f8 ff ff       	jmp    c010003b <__alltraps>

c0100779 <vector185>:
.globl vector185
vector185:
  pushl $0
c0100779:	6a 00                	push   $0x0
  pushl $185
c010077b:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0100780:	e9 b6 f8 ff ff       	jmp    c010003b <__alltraps>

c0100785 <vector186>:
.globl vector186
vector186:
  pushl $0
c0100785:	6a 00                	push   $0x0
  pushl $186
c0100787:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010078c:	e9 aa f8 ff ff       	jmp    c010003b <__alltraps>

c0100791 <vector187>:
.globl vector187
vector187:
  pushl $0
c0100791:	6a 00                	push   $0x0
  pushl $187
c0100793:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0100798:	e9 9e f8 ff ff       	jmp    c010003b <__alltraps>

c010079d <vector188>:
.globl vector188
vector188:
  pushl $0
c010079d:	6a 00                	push   $0x0
  pushl $188
c010079f:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01007a4:	e9 92 f8 ff ff       	jmp    c010003b <__alltraps>

c01007a9 <vector189>:
.globl vector189
vector189:
  pushl $0
c01007a9:	6a 00                	push   $0x0
  pushl $189
c01007ab:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01007b0:	e9 86 f8 ff ff       	jmp    c010003b <__alltraps>

c01007b5 <vector190>:
.globl vector190
vector190:
  pushl $0
c01007b5:	6a 00                	push   $0x0
  pushl $190
c01007b7:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01007bc:	e9 7a f8 ff ff       	jmp    c010003b <__alltraps>

c01007c1 <vector191>:
.globl vector191
vector191:
  pushl $0
c01007c1:	6a 00                	push   $0x0
  pushl $191
c01007c3:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01007c8:	e9 6e f8 ff ff       	jmp    c010003b <__alltraps>

c01007cd <vector192>:
.globl vector192
vector192:
  pushl $0
c01007cd:	6a 00                	push   $0x0
  pushl $192
c01007cf:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01007d4:	e9 62 f8 ff ff       	jmp    c010003b <__alltraps>

c01007d9 <vector193>:
.globl vector193
vector193:
  pushl $0
c01007d9:	6a 00                	push   $0x0
  pushl $193
c01007db:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01007e0:	e9 56 f8 ff ff       	jmp    c010003b <__alltraps>

c01007e5 <vector194>:
.globl vector194
vector194:
  pushl $0
c01007e5:	6a 00                	push   $0x0
  pushl $194
c01007e7:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01007ec:	e9 4a f8 ff ff       	jmp    c010003b <__alltraps>

c01007f1 <vector195>:
.globl vector195
vector195:
  pushl $0
c01007f1:	6a 00                	push   $0x0
  pushl $195
c01007f3:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01007f8:	e9 3e f8 ff ff       	jmp    c010003b <__alltraps>

c01007fd <vector196>:
.globl vector196
vector196:
  pushl $0
c01007fd:	6a 00                	push   $0x0
  pushl $196
c01007ff:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0100804:	e9 32 f8 ff ff       	jmp    c010003b <__alltraps>

c0100809 <vector197>:
.globl vector197
vector197:
  pushl $0
c0100809:	6a 00                	push   $0x0
  pushl $197
c010080b:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0100810:	e9 26 f8 ff ff       	jmp    c010003b <__alltraps>

c0100815 <vector198>:
.globl vector198
vector198:
  pushl $0
c0100815:	6a 00                	push   $0x0
  pushl $198
c0100817:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010081c:	e9 1a f8 ff ff       	jmp    c010003b <__alltraps>

c0100821 <vector199>:
.globl vector199
vector199:
  pushl $0
c0100821:	6a 00                	push   $0x0
  pushl $199
c0100823:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0100828:	e9 0e f8 ff ff       	jmp    c010003b <__alltraps>

c010082d <vector200>:
.globl vector200
vector200:
  pushl $0
c010082d:	6a 00                	push   $0x0
  pushl $200
c010082f:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0100834:	e9 02 f8 ff ff       	jmp    c010003b <__alltraps>

c0100839 <vector201>:
.globl vector201
vector201:
  pushl $0
c0100839:	6a 00                	push   $0x0
  pushl $201
c010083b:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0100840:	e9 f6 f7 ff ff       	jmp    c010003b <__alltraps>

c0100845 <vector202>:
.globl vector202
vector202:
  pushl $0
c0100845:	6a 00                	push   $0x0
  pushl $202
c0100847:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010084c:	e9 ea f7 ff ff       	jmp    c010003b <__alltraps>

c0100851 <vector203>:
.globl vector203
vector203:
  pushl $0
c0100851:	6a 00                	push   $0x0
  pushl $203
c0100853:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0100858:	e9 de f7 ff ff       	jmp    c010003b <__alltraps>

c010085d <vector204>:
.globl vector204
vector204:
  pushl $0
c010085d:	6a 00                	push   $0x0
  pushl $204
c010085f:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0100864:	e9 d2 f7 ff ff       	jmp    c010003b <__alltraps>

c0100869 <vector205>:
.globl vector205
vector205:
  pushl $0
c0100869:	6a 00                	push   $0x0
  pushl $205
c010086b:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0100870:	e9 c6 f7 ff ff       	jmp    c010003b <__alltraps>

c0100875 <vector206>:
.globl vector206
vector206:
  pushl $0
c0100875:	6a 00                	push   $0x0
  pushl $206
c0100877:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010087c:	e9 ba f7 ff ff       	jmp    c010003b <__alltraps>

c0100881 <vector207>:
.globl vector207
vector207:
  pushl $0
c0100881:	6a 00                	push   $0x0
  pushl $207
c0100883:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0100888:	e9 ae f7 ff ff       	jmp    c010003b <__alltraps>

c010088d <vector208>:
.globl vector208
vector208:
  pushl $0
c010088d:	6a 00                	push   $0x0
  pushl $208
c010088f:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0100894:	e9 a2 f7 ff ff       	jmp    c010003b <__alltraps>

c0100899 <vector209>:
.globl vector209
vector209:
  pushl $0
c0100899:	6a 00                	push   $0x0
  pushl $209
c010089b:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01008a0:	e9 96 f7 ff ff       	jmp    c010003b <__alltraps>

c01008a5 <vector210>:
.globl vector210
vector210:
  pushl $0
c01008a5:	6a 00                	push   $0x0
  pushl $210
c01008a7:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01008ac:	e9 8a f7 ff ff       	jmp    c010003b <__alltraps>

c01008b1 <vector211>:
.globl vector211
vector211:
  pushl $0
c01008b1:	6a 00                	push   $0x0
  pushl $211
c01008b3:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01008b8:	e9 7e f7 ff ff       	jmp    c010003b <__alltraps>

c01008bd <vector212>:
.globl vector212
vector212:
  pushl $0
c01008bd:	6a 00                	push   $0x0
  pushl $212
c01008bf:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01008c4:	e9 72 f7 ff ff       	jmp    c010003b <__alltraps>

c01008c9 <vector213>:
.globl vector213
vector213:
  pushl $0
c01008c9:	6a 00                	push   $0x0
  pushl $213
c01008cb:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01008d0:	e9 66 f7 ff ff       	jmp    c010003b <__alltraps>

c01008d5 <vector214>:
.globl vector214
vector214:
  pushl $0
c01008d5:	6a 00                	push   $0x0
  pushl $214
c01008d7:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01008dc:	e9 5a f7 ff ff       	jmp    c010003b <__alltraps>

c01008e1 <vector215>:
.globl vector215
vector215:
  pushl $0
c01008e1:	6a 00                	push   $0x0
  pushl $215
c01008e3:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01008e8:	e9 4e f7 ff ff       	jmp    c010003b <__alltraps>

c01008ed <vector216>:
.globl vector216
vector216:
  pushl $0
c01008ed:	6a 00                	push   $0x0
  pushl $216
c01008ef:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01008f4:	e9 42 f7 ff ff       	jmp    c010003b <__alltraps>

c01008f9 <vector217>:
.globl vector217
vector217:
  pushl $0
c01008f9:	6a 00                	push   $0x0
  pushl $217
c01008fb:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0100900:	e9 36 f7 ff ff       	jmp    c010003b <__alltraps>

c0100905 <vector218>:
.globl vector218
vector218:
  pushl $0
c0100905:	6a 00                	push   $0x0
  pushl $218
c0100907:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c010090c:	e9 2a f7 ff ff       	jmp    c010003b <__alltraps>

c0100911 <vector219>:
.globl vector219
vector219:
  pushl $0
c0100911:	6a 00                	push   $0x0
  pushl $219
c0100913:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0100918:	e9 1e f7 ff ff       	jmp    c010003b <__alltraps>

c010091d <vector220>:
.globl vector220
vector220:
  pushl $0
c010091d:	6a 00                	push   $0x0
  pushl $220
c010091f:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0100924:	e9 12 f7 ff ff       	jmp    c010003b <__alltraps>

c0100929 <vector221>:
.globl vector221
vector221:
  pushl $0
c0100929:	6a 00                	push   $0x0
  pushl $221
c010092b:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0100930:	e9 06 f7 ff ff       	jmp    c010003b <__alltraps>

c0100935 <vector222>:
.globl vector222
vector222:
  pushl $0
c0100935:	6a 00                	push   $0x0
  pushl $222
c0100937:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c010093c:	e9 fa f6 ff ff       	jmp    c010003b <__alltraps>

c0100941 <vector223>:
.globl vector223
vector223:
  pushl $0
c0100941:	6a 00                	push   $0x0
  pushl $223
c0100943:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0100948:	e9 ee f6 ff ff       	jmp    c010003b <__alltraps>

c010094d <vector224>:
.globl vector224
vector224:
  pushl $0
c010094d:	6a 00                	push   $0x0
  pushl $224
c010094f:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0100954:	e9 e2 f6 ff ff       	jmp    c010003b <__alltraps>

c0100959 <vector225>:
.globl vector225
vector225:
  pushl $0
c0100959:	6a 00                	push   $0x0
  pushl $225
c010095b:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0100960:	e9 d6 f6 ff ff       	jmp    c010003b <__alltraps>

c0100965 <vector226>:
.globl vector226
vector226:
  pushl $0
c0100965:	6a 00                	push   $0x0
  pushl $226
c0100967:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010096c:	e9 ca f6 ff ff       	jmp    c010003b <__alltraps>

c0100971 <vector227>:
.globl vector227
vector227:
  pushl $0
c0100971:	6a 00                	push   $0x0
  pushl $227
c0100973:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0100978:	e9 be f6 ff ff       	jmp    c010003b <__alltraps>

c010097d <vector228>:
.globl vector228
vector228:
  pushl $0
c010097d:	6a 00                	push   $0x0
  pushl $228
c010097f:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0100984:	e9 b2 f6 ff ff       	jmp    c010003b <__alltraps>

c0100989 <vector229>:
.globl vector229
vector229:
  pushl $0
c0100989:	6a 00                	push   $0x0
  pushl $229
c010098b:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0100990:	e9 a6 f6 ff ff       	jmp    c010003b <__alltraps>

c0100995 <vector230>:
.globl vector230
vector230:
  pushl $0
c0100995:	6a 00                	push   $0x0
  pushl $230
c0100997:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010099c:	e9 9a f6 ff ff       	jmp    c010003b <__alltraps>

c01009a1 <vector231>:
.globl vector231
vector231:
  pushl $0
c01009a1:	6a 00                	push   $0x0
  pushl $231
c01009a3:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01009a8:	e9 8e f6 ff ff       	jmp    c010003b <__alltraps>

c01009ad <vector232>:
.globl vector232
vector232:
  pushl $0
c01009ad:	6a 00                	push   $0x0
  pushl $232
c01009af:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01009b4:	e9 82 f6 ff ff       	jmp    c010003b <__alltraps>

c01009b9 <vector233>:
.globl vector233
vector233:
  pushl $0
c01009b9:	6a 00                	push   $0x0
  pushl $233
c01009bb:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01009c0:	e9 76 f6 ff ff       	jmp    c010003b <__alltraps>

c01009c5 <vector234>:
.globl vector234
vector234:
  pushl $0
c01009c5:	6a 00                	push   $0x0
  pushl $234
c01009c7:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01009cc:	e9 6a f6 ff ff       	jmp    c010003b <__alltraps>

c01009d1 <vector235>:
.globl vector235
vector235:
  pushl $0
c01009d1:	6a 00                	push   $0x0
  pushl $235
c01009d3:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01009d8:	e9 5e f6 ff ff       	jmp    c010003b <__alltraps>

c01009dd <vector236>:
.globl vector236
vector236:
  pushl $0
c01009dd:	6a 00                	push   $0x0
  pushl $236
c01009df:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01009e4:	e9 52 f6 ff ff       	jmp    c010003b <__alltraps>

c01009e9 <vector237>:
.globl vector237
vector237:
  pushl $0
c01009e9:	6a 00                	push   $0x0
  pushl $237
c01009eb:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01009f0:	e9 46 f6 ff ff       	jmp    c010003b <__alltraps>

c01009f5 <vector238>:
.globl vector238
vector238:
  pushl $0
c01009f5:	6a 00                	push   $0x0
  pushl $238
c01009f7:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01009fc:	e9 3a f6 ff ff       	jmp    c010003b <__alltraps>

c0100a01 <vector239>:
.globl vector239
vector239:
  pushl $0
c0100a01:	6a 00                	push   $0x0
  pushl $239
c0100a03:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0100a08:	e9 2e f6 ff ff       	jmp    c010003b <__alltraps>

c0100a0d <vector240>:
.globl vector240
vector240:
  pushl $0
c0100a0d:	6a 00                	push   $0x0
  pushl $240
c0100a0f:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0100a14:	e9 22 f6 ff ff       	jmp    c010003b <__alltraps>

c0100a19 <vector241>:
.globl vector241
vector241:
  pushl $0
c0100a19:	6a 00                	push   $0x0
  pushl $241
c0100a1b:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0100a20:	e9 16 f6 ff ff       	jmp    c010003b <__alltraps>

c0100a25 <vector242>:
.globl vector242
vector242:
  pushl $0
c0100a25:	6a 00                	push   $0x0
  pushl $242
c0100a27:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0100a2c:	e9 0a f6 ff ff       	jmp    c010003b <__alltraps>

c0100a31 <vector243>:
.globl vector243
vector243:
  pushl $0
c0100a31:	6a 00                	push   $0x0
  pushl $243
c0100a33:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0100a38:	e9 fe f5 ff ff       	jmp    c010003b <__alltraps>

c0100a3d <vector244>:
.globl vector244
vector244:
  pushl $0
c0100a3d:	6a 00                	push   $0x0
  pushl $244
c0100a3f:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0100a44:	e9 f2 f5 ff ff       	jmp    c010003b <__alltraps>

c0100a49 <vector245>:
.globl vector245
vector245:
  pushl $0
c0100a49:	6a 00                	push   $0x0
  pushl $245
c0100a4b:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0100a50:	e9 e6 f5 ff ff       	jmp    c010003b <__alltraps>

c0100a55 <vector246>:
.globl vector246
vector246:
  pushl $0
c0100a55:	6a 00                	push   $0x0
  pushl $246
c0100a57:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0100a5c:	e9 da f5 ff ff       	jmp    c010003b <__alltraps>

c0100a61 <vector247>:
.globl vector247
vector247:
  pushl $0
c0100a61:	6a 00                	push   $0x0
  pushl $247
c0100a63:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0100a68:	e9 ce f5 ff ff       	jmp    c010003b <__alltraps>

c0100a6d <vector248>:
.globl vector248
vector248:
  pushl $0
c0100a6d:	6a 00                	push   $0x0
  pushl $248
c0100a6f:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0100a74:	e9 c2 f5 ff ff       	jmp    c010003b <__alltraps>

c0100a79 <vector249>:
.globl vector249
vector249:
  pushl $0
c0100a79:	6a 00                	push   $0x0
  pushl $249
c0100a7b:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0100a80:	e9 b6 f5 ff ff       	jmp    c010003b <__alltraps>

c0100a85 <vector250>:
.globl vector250
vector250:
  pushl $0
c0100a85:	6a 00                	push   $0x0
  pushl $250
c0100a87:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0100a8c:	e9 aa f5 ff ff       	jmp    c010003b <__alltraps>

c0100a91 <vector251>:
.globl vector251
vector251:
  pushl $0
c0100a91:	6a 00                	push   $0x0
  pushl $251
c0100a93:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0100a98:	e9 9e f5 ff ff       	jmp    c010003b <__alltraps>

c0100a9d <vector252>:
.globl vector252
vector252:
  pushl $0
c0100a9d:	6a 00                	push   $0x0
  pushl $252
c0100a9f:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0100aa4:	e9 92 f5 ff ff       	jmp    c010003b <__alltraps>

c0100aa9 <vector253>:
.globl vector253
vector253:
  pushl $0
c0100aa9:	6a 00                	push   $0x0
  pushl $253
c0100aab:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0100ab0:	e9 86 f5 ff ff       	jmp    c010003b <__alltraps>

c0100ab5 <vector254>:
.globl vector254
vector254:
  pushl $0
c0100ab5:	6a 00                	push   $0x0
  pushl $254
c0100ab7:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0100abc:	e9 7a f5 ff ff       	jmp    c010003b <__alltraps>

c0100ac1 <vector255>:
.globl vector255
vector255:
  pushl $0
c0100ac1:	6a 00                	push   $0x0
  pushl $255
c0100ac3:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0100ac8:	e9 6e f5 ff ff       	jmp    c010003b <__alltraps>

c0100acd <globCtor>:
#include <global.h>
#include <vmm.h>

extern uint32_t ctorStart, ctorEnd; // Start and end of constructors

extern "C" void globCtor() {
c0100acd:	e8 f7 00 00 00       	call   c0100bc9 <__x86.get_pc_thunk.ax>
c0100ad2:	05 4e 19 02 00       	add    $0x2194e,%eax
c0100ad7:	55                   	push   %ebp
c0100ad8:	89 e5                	mov    %esp,%ebp
c0100ada:	56                   	push   %esi
c0100adb:	53                   	push   %ebx
    // Loop and call all the constructors
   for(uint32_t *ctor = &ctorStart; ctor < &ctorEnd; ctor++){
c0100adc:	c7 c6 04 f0 11 c0    	mov    $0xc011f004,%esi
c0100ae2:	c7 c3 00 f0 11 c0    	mov    $0xc011f000,%ebx
c0100ae8:	39 f3                	cmp    %esi,%ebx
c0100aea:	73 07                	jae    c0100af3 <globCtor+0x26>
      ((void (*) (void)) (*ctor))();
c0100aec:	ff 13                	call   *(%ebx)
   for(uint32_t *ctor = &ctorStart; ctor < &ctorEnd; ctor++){
c0100aee:	83 c3 04             	add    $0x4,%ebx
c0100af1:	eb f5                	jmp    c0100ae8 <globCtor+0x1b>
   }
}
c0100af3:	5b                   	pop    %ebx
c0100af4:	5e                   	pop    %esi
c0100af5:	5d                   	pop    %ebp
c0100af6:	c3                   	ret    

c0100af7 <initKernel>:

/*  kernel entry point  */
extern "C" void initKernel() {
c0100af7:	55                   	push   %ebp
c0100af8:	89 e5                	mov    %esp,%ebp
c0100afa:	57                   	push   %edi
c0100afb:	56                   	push   %esi
c0100afc:	53                   	push   %ebx
c0100afd:	e8 cb 00 00 00       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0100b02:	81 c3 1e 19 02 00    	add    $0x2191e,%ebx
c0100b08:	81 ec 48 02 00 00    	sub    $0x248,%esp

    kernel::console.init();
    kernel::console.setBackground("white");
c0100b0e:	8d b5 e0 fd ff ff    	lea    -0x220(%ebp),%esi
    kernel::console.init();
c0100b14:	c7 c7 68 50 12 c0    	mov    $0xc0125068,%edi
c0100b1a:	57                   	push   %edi
c0100b1b:	e8 30 03 00 00       	call   c0100e50 <_ZN7Console4initEv>
    kernel::console.setBackground("white");
c0100b20:	58                   	pop    %eax
c0100b21:	8d 83 90 39 fe ff    	lea    -0x1c670(%ebx),%eax
c0100b27:	5a                   	pop    %edx
c0100b28:	50                   	push   %eax
c0100b29:	56                   	push   %esi
c0100b2a:	e8 cb 51 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0100b2f:	59                   	pop    %ecx
c0100b30:	58                   	pop    %eax
c0100b31:	56                   	push   %esi
c0100b32:	57                   	push   %edi
c0100b33:	e8 e6 01 00 00       	call   c0100d1e <_ZN7Console13setBackgroundE6String>
    
    OStream os("Welcome SPX OS.....\n\n", "blue");
c0100b38:	8d bd db fd ff ff    	lea    -0x225(%ebp),%edi
    kernel::console.setBackground("white");
c0100b3e:	89 34 24             	mov    %esi,(%esp)
c0100b41:	e8 ce 51 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    OStream os("Welcome SPX OS.....\n\n", "blue");
c0100b46:	58                   	pop    %eax
c0100b47:	8d 83 96 39 fe ff    	lea    -0x1c66a(%ebx),%eax
c0100b4d:	5a                   	pop    %edx
c0100b4e:	50                   	push   %eax
c0100b4f:	57                   	push   %edi
c0100b50:	e8 a5 51 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0100b55:	59                   	pop    %ecx
c0100b56:	58                   	pop    %eax
c0100b57:	8d 83 9b 39 fe ff    	lea    -0x1c665(%ebx),%eax
c0100b5d:	50                   	push   %eax
c0100b5e:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0100b64:	50                   	push   %eax
c0100b65:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0100b6b:	e8 8a 51 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0100b70:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0100b76:	83 c4 0c             	add    $0xc,%esp
c0100b79:	57                   	push   %edi
c0100b7a:	50                   	push   %eax
c0100b7b:	56                   	push   %esi
c0100b7c:	e8 4d 0f 00 00       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0100b81:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0100b87:	89 04 24             	mov    %eax,(%esp)
c0100b8a:	e8 85 51 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0100b8f:	89 3c 24             	mov    %edi,(%esp)
c0100b92:	e8 7d 51 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    os.flush();
c0100b97:	89 34 24             	mov    %esi,(%esp)
c0100b9a:	e8 c9 0f 00 00       	call   c0101b68 <_ZN7OStream5flushEv>

    kernel::pmm.init();
c0100b9f:	58                   	pop    %eax
c0100ba0:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
c0100ba6:	e8 21 1d 00 00       	call   c01028cc <_ZN5PhyMM4initEv>

    kernel::interrupt.init();
c0100bab:	58                   	pop    %eax
c0100bac:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
c0100bb2:	e8 93 05 00 00       	call   c010114a <_ZN9Interrupt4initEv>

    kernel::vmm.init();
c0100bb7:	58                   	pop    %eax
c0100bb8:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
c0100bbe:	e8 8f 4b 00 00       	call   c0105752 <_ZN3VMM4initEv>
c0100bc3:	83 c4 10             	add    $0x10,%esp
    );
}

static inline void
hlt() {
    asm volatile ("hlt");
c0100bc6:	f4                   	hlt    
c0100bc7:	eb fd                	jmp    c0100bc6 <initKernel+0xcf>

c0100bc9 <__x86.get_pc_thunk.ax>:
c0100bc9:	8b 04 24             	mov    (%esp),%eax
c0100bcc:	c3                   	ret    

c0100bcd <__x86.get_pc_thunk.bx>:
c0100bcd:	8b 1c 24             	mov    (%esp),%ebx
c0100bd0:	c3                   	ret    
c0100bd1:	90                   	nop

c0100bd2 <_ZN7ConsoleC1Ev>:
 * @Last Modified time: 2020-04-10 21:25:43
 */

#include <console.h>

Console::Console() {
c0100bd2:	55                   	push   %ebp
c0100bd3:	89 e5                	mov    %esp,%ebp
c0100bd5:	57                   	push   %edi
c0100bd6:	56                   	push   %esi
c0100bd7:	53                   	push   %ebx
c0100bd8:	83 ec 28             	sub    $0x28,%esp
c0100bdb:	e8 ed ff ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0100be0:	81 c3 40 18 02 00    	add    $0x21840,%ebx
c0100be6:	8b 75 08             	mov    0x8(%ebp),%esi
c0100be9:	56                   	push   %esi
c0100bea:	e8 ab 06 00 00       	call   c010129a <_ZN11VideoMemoryC1Ev>
c0100bef:	58                   	pop    %eax
c0100bf0:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0100bf6:	5a                   	pop    %edx
c0100bf7:	50                   	push   %eax
c0100bf8:	8d 46 06             	lea    0x6(%esi),%eax
c0100bfb:	50                   	push   %eax
c0100bfc:	e8 f9 50 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0100c01:	8d 83 b5 39 fe ff    	lea    -0x1c64b(%ebx),%eax
c0100c07:	59                   	pop    %ecx
c0100c08:	5f                   	pop    %edi
c0100c09:	50                   	push   %eax
c0100c0a:	8d 46 0b             	lea    0xb(%esi),%eax
c0100c0d:	50                   	push   %eax
c0100c0e:	e8 e7 50 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0100c13:	58                   	pop    %eax
c0100c14:	8d 83 90 39 fe ff    	lea    -0x1c670(%ebx),%eax
c0100c1a:	5a                   	pop    %edx
c0100c1b:	50                   	push   %eax
c0100c1c:	8d 46 10             	lea    0x10(%esi),%eax
c0100c1f:	50                   	push   %eax
c0100c20:	e8 d5 50 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0100c25:	8d 83 96 39 fe ff    	lea    -0x1c66a(%ebx),%eax
c0100c2b:	59                   	pop    %ecx
c0100c2c:	5f                   	pop    %edi
c0100c2d:	50                   	push   %eax
c0100c2e:	8d 46 15             	lea    0x15(%esi),%eax
c0100c31:	50                   	push   %eax
c0100c32:	e8 c3 50 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
    // set l and w
    length = 80;
c0100c37:	c7 c7 0c 24 12 c0    	mov    $0xc012240c,%edi
    wide = 25;
c0100c3d:	c7 c0 08 24 12 c0    	mov    $0xc0122408,%eax
Console::Console() {
c0100c43:	c7 46 1a 04 00 07 01 	movl   $0x1070004,0x1a(%esi)
    length = 80;
c0100c4a:	c7 07 50 00 00 00    	movl   $0x50,(%edi)
    wide = 25;
c0100c50:	c7 00 19 00 00 00    	movl   $0x19,(%eax)
    
    // get Video Memory buffer
    screen = (Char *)(VideoMemory::vmBuffer);
c0100c56:	c7 c0 30 5a 12 c0    	mov    $0xc0125a30,%eax
c0100c5c:	8b 16                	mov    (%esi),%edx
c0100c5e:	89 10                	mov    %edx,(%eax)

    // get cursor position
    cPos.x = VideoMemory::getCursorPos() / length;
c0100c60:	89 34 24             	mov    %esi,(%esp)
c0100c63:	e8 5e 06 00 00       	call   c01012c6 <_ZN11VideoMemory12getCursorPosEv>
c0100c68:	31 d2                	xor    %edx,%edx
c0100c6a:	c7 c1 2d 5a 12 c0    	mov    $0xc0125a2d,%ecx
c0100c70:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
c0100c73:	0f b7 c0             	movzwl %ax,%eax
c0100c76:	f7 37                	divl   (%edi)
c0100c78:	88 01                	mov    %al,(%ecx)
    cPos.y = VideoMemory::getCursorPos() % length;
c0100c7a:	89 34 24             	mov    %esi,(%esp)
c0100c7d:	e8 44 06 00 00       	call   c01012c6 <_ZN11VideoMemory12getCursorPosEv>
c0100c82:	31 d2                	xor    %edx,%edx
c0100c84:	8b 4d e4             	mov    -0x1c(%ebp),%ecx

    // set cursor status
    cursorStatus.c = 'S';
    cursorStatus.attri = 0b10101010;        // light green and flash
}
c0100c87:	83 c4 10             	add    $0x10,%esp
    cPos.y = VideoMemory::getCursorPos() % length;
c0100c8a:	0f b7 c0             	movzwl %ax,%eax
c0100c8d:	f7 37                	divl   (%edi)
    cursorStatus.c = 'S';
c0100c8f:	c7 c0 02 24 12 c0    	mov    $0xc0122402,%eax
c0100c95:	66 c7 00 53 aa       	movw   $0xaa53,(%eax)
    cPos.y = VideoMemory::getCursorPos() % length;
c0100c9a:	88 51 01             	mov    %dl,0x1(%ecx)
}
c0100c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100ca0:	5b                   	pop    %ebx
c0100ca1:	5e                   	pop    %esi
c0100ca2:	5f                   	pop    %edi
c0100ca3:	5d                   	pop    %ebp
c0100ca4:	c3                   	ret    
c0100ca5:	90                   	nop

c0100ca6 <_ZN7Console5clearEv>:

void Console::clear() {
c0100ca6:	55                   	push   %ebp
c0100ca7:	89 e5                	mov    %esp,%ebp
c0100ca9:	53                   	push   %ebx
c0100caa:	e8 1e ff ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0100caf:	81 c3 71 17 02 00    	add    $0x21771,%ebx
c0100cb5:	83 ec 10             	sub    $0x10,%esp
    VideoMemory::initVmBuff();
c0100cb8:	ff 75 08             	pushl  0x8(%ebp)
c0100cbb:	e8 ee 05 00 00       	call   c01012ae <_ZN11VideoMemory10initVmBuffEv>
}
c0100cc0:	83 c4 10             	add    $0x10,%esp
c0100cc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100cc6:	c9                   	leave  
c0100cc7:	c3                   	ret    

c0100cc8 <_ZN7Console8setColorE6String>:
void Console::init() {
    VideoMemory::initVmBuff();
    setCursorPos(0, 0);
}

void Console::setColor(String str) {
c0100cc8:	55                   	push   %ebp
c0100cc9:	89 e5                	mov    %esp,%ebp
c0100ccb:	57                   	push   %edi
c0100ccc:	56                   	push   %esi
    uint32_t index;
    for (index = 0; index < COLOR_NUM; index++) {
c0100ccd:	31 f6                	xor    %esi,%esi
void Console::setColor(String str) {
c0100ccf:	53                   	push   %ebx
c0100cd0:	83 ec 0c             	sub    $0xc,%esp
c0100cd3:	e8 f5 fe ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0100cd8:	81 c3 48 17 02 00    	add    $0x21748,%ebx
c0100cde:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ce1:	8d 78 06             	lea    0x6(%eax),%edi
        if (str == color[index]) {
c0100ce4:	50                   	push   %eax
c0100ce5:	50                   	push   %eax
c0100ce6:	57                   	push   %edi
c0100ce7:	ff 75 0c             	pushl  0xc(%ebp)
c0100cea:	e8 77 50 00 00       	call   c0105d66 <_ZN6StringeqERKS_>
c0100cef:	83 c4 10             	add    $0x10,%esp
c0100cf2:	84 c0                	test   %al,%al
c0100cf4:	75 0b                	jne    c0100d01 <_ZN7Console8setColorE6String+0x39>
    for (index = 0; index < COLOR_NUM; index++) {
c0100cf6:	46                   	inc    %esi
c0100cf7:	83 c7 05             	add    $0x5,%edi
c0100cfa:	83 fe 04             	cmp    $0x4,%esi
c0100cfd:	75 e5                	jne    c0100ce4 <_ZN7Console8setColorE6String+0x1c>
c0100cff:	eb 15                	jmp    c0100d16 <_ZN7Console8setColorE6String+0x4e>
            break;
        }
    }
    if (index < COLOR_NUM) {
        charEctype.attri = (charEctype.attri & 0xF0) | colorTable[index];
c0100d01:	c7 c2 04 24 12 c0    	mov    $0xc0122404,%edx
c0100d07:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0100d0a:	8a 42 01             	mov    0x1(%edx),%al
c0100d0d:	24 f0                	and    $0xf0,%al
c0100d0f:	0a 44 31 1a          	or     0x1a(%ecx,%esi,1),%al
c0100d13:	88 42 01             	mov    %al,0x1(%edx)
    }
}
c0100d16:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100d19:	5b                   	pop    %ebx
c0100d1a:	5e                   	pop    %esi
c0100d1b:	5f                   	pop    %edi
c0100d1c:	5d                   	pop    %ebp
c0100d1d:	c3                   	ret    

c0100d1e <_ZN7Console13setBackgroundE6String>:

void Console::setBackground(String str) {
c0100d1e:	55                   	push   %ebp
c0100d1f:	89 e5                	mov    %esp,%ebp
c0100d21:	57                   	push   %edi
    uint32_t index = 1;                             // default black
    for (uint32_t i = 0; i < COLOR_NUM; i++) {
c0100d22:	31 ff                	xor    %edi,%edi
void Console::setBackground(String str) {
c0100d24:	56                   	push   %esi
c0100d25:	53                   	push   %ebx
c0100d26:	83 ec 1c             	sub    $0x1c,%esp
c0100d29:	e8 9f fe ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0100d2e:	81 c3 f2 16 02 00    	add    $0x216f2,%ebx
c0100d34:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d37:	8d 70 06             	lea    0x6(%eax),%esi
        if (str == color[i]) {
c0100d3a:	50                   	push   %eax
c0100d3b:	50                   	push   %eax
c0100d3c:	56                   	push   %esi
c0100d3d:	ff 75 0c             	pushl  0xc(%ebp)
c0100d40:	e8 21 50 00 00       	call   c0105d66 <_ZN6StringeqERKS_>
c0100d45:	83 c4 10             	add    $0x10,%esp
c0100d48:	84 c0                	test   %al,%al
c0100d4a:	75 0e                	jne    c0100d5a <_ZN7Console13setBackgroundE6String+0x3c>
    for (uint32_t i = 0; i < COLOR_NUM; i++) {
c0100d4c:	47                   	inc    %edi
c0100d4d:	83 c6 05             	add    $0x5,%esi
c0100d50:	83 ff 04             	cmp    $0x4,%edi
c0100d53:	75 e5                	jne    c0100d3a <_ZN7Console13setBackgroundE6String+0x1c>
    uint32_t index = 1;                             // default black
c0100d55:	bf 01 00 00 00       	mov    $0x1,%edi
            index = i;
            break;
        }
    }
    charEctype.attri = (charEctype.attri & 0x0F) | ((colorTable[index]) << 4);
c0100d5a:	c7 c1 04 24 12 c0    	mov    $0xc0122404,%ecx
c0100d60:	8b 55 08             	mov    0x8(%ebp),%edx
c0100d63:	8a 41 01             	mov    0x1(%ecx),%al
c0100d66:	0f b6 54 3a 1a       	movzbl 0x1a(%edx,%edi,1),%edx
c0100d6b:	24 0f                	and    $0xf,%al
c0100d6d:	c1 e2 04             	shl    $0x4,%edx
c0100d70:	08 d0                	or     %dl,%al
c0100d72:	88 41 01             	mov    %al,0x1(%ecx)
    for (uint32_t row = 0; row < wide; row++) {
c0100d75:	c7 c0 08 24 12 c0    	mov    $0xc0122408,%eax
c0100d7b:	8b 00                	mov    (%eax),%eax
c0100d7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (uint32_t col = 0; col < length; col++) {
c0100d80:	c7 c0 0c 24 12 c0    	mov    $0xc012240c,%eax
c0100d86:	8b 30                	mov    (%eax),%esi
            if (cPos.x != row || cPos.y != col) {
c0100d88:	c7 c0 2d 5a 12 c0    	mov    $0xc0125a2d,%eax
c0100d8e:	0f b6 38             	movzbl (%eax),%edi
c0100d91:	0f b6 40 01          	movzbl 0x1(%eax),%eax
c0100d95:	89 7d e0             	mov    %edi,-0x20(%ebp)
    for (uint32_t row = 0; row < wide; row++) {
c0100d98:	31 ff                	xor    %edi,%edi
            if (cPos.x != row || cPos.y != col) {
c0100d9a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100d9d:	8d 04 36             	lea    (%esi,%esi,1),%eax
c0100da0:	89 45 d8             	mov    %eax,-0x28(%ebp)
                screen[row * length + col].attri = charEctype.attri;
c0100da3:	c7 c0 30 5a 12 c0    	mov    $0xc0125a30,%eax
c0100da9:	8b 18                	mov    (%eax),%ebx
    for (uint32_t row = 0; row < wide; row++) {
c0100dab:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
c0100dae:	74 24                	je     c0100dd4 <_ZN7Console13setBackgroundE6String+0xb6>
        for (uint32_t col = 0; col < length; col++) {
c0100db0:	31 c0                	xor    %eax,%eax
c0100db2:	39 c6                	cmp    %eax,%esi
c0100db4:	74 14                	je     c0100dca <_ZN7Console13setBackgroundE6String+0xac>
            if (cPos.x != row || cPos.y != col) {
c0100db6:	39 7d e0             	cmp    %edi,-0x20(%ebp)
c0100db9:	75 05                	jne    c0100dc0 <_ZN7Console13setBackgroundE6String+0xa2>
c0100dbb:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0100dbe:	74 07                	je     c0100dc7 <_ZN7Console13setBackgroundE6String+0xa9>
                screen[row * length + col].attri = charEctype.attri;
c0100dc0:	8a 51 01             	mov    0x1(%ecx),%dl
c0100dc3:	88 54 43 01          	mov    %dl,0x1(%ebx,%eax,2)
        for (uint32_t col = 0; col < length; col++) {
c0100dc7:	40                   	inc    %eax
c0100dc8:	eb e8                	jmp    c0100db2 <_ZN7Console13setBackgroundE6String+0x94>
    for (uint32_t row = 0; row < wide; row++) {
c0100dca:	89 f8                	mov    %edi,%eax
c0100dcc:	40                   	inc    %eax
c0100dcd:	89 c7                	mov    %eax,%edi
c0100dcf:	03 5d d8             	add    -0x28(%ebp),%ebx
c0100dd2:	eb d7                	jmp    c0100dab <_ZN7Console13setBackgroundE6String+0x8d>
            }
        }
    }
}
c0100dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100dd7:	5b                   	pop    %ebx
c0100dd8:	5e                   	pop    %esi
c0100dd9:	5f                   	pop    %edi
c0100dda:	5d                   	pop    %ebp
c0100ddb:	c3                   	ret    

c0100ddc <_ZN7Console12setCursorPosEhh>:

void Console::setCursorPos(uint8_t x, uint8_t y) {
c0100ddc:	55                   	push   %ebp
c0100ddd:	89 e5                	mov    %esp,%ebp
c0100ddf:	57                   	push   %edi
c0100de0:	56                   	push   %esi
c0100de1:	53                   	push   %ebx
c0100de2:	e8 e6 fd ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0100de7:	81 c3 39 16 02 00    	add    $0x21639,%ebx
c0100ded:	83 ec 24             	sub    $0x24,%esp
c0100df0:	8b 45 10             	mov    0x10(%ebp),%eax
c0100df3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
c0100df7:	88 45 e7             	mov    %al,-0x19(%ebp)
    cPos.x = x;
c0100dfa:	c7 c6 2d 5a 12 c0    	mov    $0xc0125a2d,%esi
    cPos.y = y;
    // set cursor status
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100e00:	0f b6 7d e7          	movzbl -0x19(%ebp),%edi
    cPos.y = y;
c0100e04:	88 46 01             	mov    %al,0x1(%esi)
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100e07:	c7 c0 0c 24 12 c0    	mov    $0xc012240c,%eax
    cPos.x = x;
c0100e0d:	88 0e                	mov    %cl,(%esi)
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100e0f:	0f b6 f1             	movzbl %cl,%esi
c0100e12:	8b 00                	mov    (%eax),%eax
c0100e14:	0f af f0             	imul   %eax,%esi
    VideoMemory::setCursorPos(cPos.x * length + cPos.y);
c0100e17:	0f af c1             	imul   %ecx,%eax
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100e1a:	8d 14 3e             	lea    (%esi,%edi,1),%edx
c0100e1d:	c7 c6 30 5a 12 c0    	mov    $0xc0125a30,%esi
c0100e23:	c7 c7 02 24 12 c0    	mov    $0xc0122402,%edi
c0100e29:	8b 36                	mov    (%esi),%esi
c0100e2b:	66 8b 3f             	mov    (%edi),%di
c0100e2e:	66 89 3c 56          	mov    %di,(%esi,%edx,2)
    VideoMemory::setCursorPos(cPos.x * length + cPos.y);
c0100e32:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
c0100e36:	01 d0                	add    %edx,%eax
c0100e38:	0f b7 c0             	movzwl %ax,%eax
c0100e3b:	50                   	push   %eax
c0100e3c:	ff 75 08             	pushl  0x8(%ebp)
c0100e3f:	e8 b0 04 00 00       	call   c01012f4 <_ZN11VideoMemory12setCursorPosEt>
}
c0100e44:	83 c4 10             	add    $0x10,%esp
c0100e47:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100e4a:	5b                   	pop    %ebx
c0100e4b:	5e                   	pop    %esi
c0100e4c:	5f                   	pop    %edi
c0100e4d:	5d                   	pop    %ebp
c0100e4e:	c3                   	ret    
c0100e4f:	90                   	nop

c0100e50 <_ZN7Console4initEv>:
void Console::init() {
c0100e50:	55                   	push   %ebp
c0100e51:	89 e5                	mov    %esp,%ebp
c0100e53:	56                   	push   %esi
c0100e54:	8b 75 08             	mov    0x8(%ebp),%esi
c0100e57:	53                   	push   %ebx
c0100e58:	e8 70 fd ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0100e5d:	81 c3 c3 15 02 00    	add    $0x215c3,%ebx
    VideoMemory::initVmBuff();
c0100e63:	83 ec 0c             	sub    $0xc,%esp
c0100e66:	56                   	push   %esi
c0100e67:	e8 42 04 00 00       	call   c01012ae <_ZN11VideoMemory10initVmBuffEv>
    setCursorPos(0, 0);
c0100e6c:	83 c4 0c             	add    $0xc,%esp
c0100e6f:	6a 00                	push   $0x0
c0100e71:	6a 00                	push   $0x0
c0100e73:	56                   	push   %esi
c0100e74:	e8 63 ff ff ff       	call   c0100ddc <_ZN7Console12setCursorPosEhh>
}
c0100e79:	83 c4 10             	add    $0x10,%esp
c0100e7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0100e7f:	5b                   	pop    %ebx
c0100e80:	5e                   	pop    %esi
c0100e81:	5d                   	pop    %ebp
c0100e82:	c3                   	ret    
c0100e83:	90                   	nop

c0100e84 <_ZN7Console12getCursorPosEv>:

const Console::CursorPos & Console::getCursorPos() {
c0100e84:	55                   	push   %ebp
c0100e85:	89 e5                	mov    %esp,%ebp
c0100e87:	57                   	push   %edi
c0100e88:	56                   	push   %esi
c0100e89:	53                   	push   %ebx
c0100e8a:	e8 3e fd ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0100e8f:	81 c3 91 15 02 00    	add    $0x21591,%ebx
c0100e95:	83 ec 18             	sub    $0x18,%esp
    cPos.x = VideoMemory::getCursorPos() / length;
c0100e98:	ff 75 08             	pushl  0x8(%ebp)
c0100e9b:	e8 26 04 00 00       	call   c01012c6 <_ZN11VideoMemory12getCursorPosEv>
c0100ea0:	c7 c6 0c 24 12 c0    	mov    $0xc012240c,%esi
c0100ea6:	31 d2                	xor    %edx,%edx
c0100ea8:	c7 c7 2d 5a 12 c0    	mov    $0xc0125a2d,%edi
c0100eae:	0f b7 c0             	movzwl %ax,%eax
c0100eb1:	f7 36                	divl   (%esi)
c0100eb3:	88 07                	mov    %al,(%edi)
    cPos.y = VideoMemory::getCursorPos() % length;
c0100eb5:	58                   	pop    %eax
c0100eb6:	ff 75 08             	pushl  0x8(%ebp)
c0100eb9:	e8 08 04 00 00       	call   c01012c6 <_ZN11VideoMemory12getCursorPosEv>
c0100ebe:	31 d2                	xor    %edx,%edx
c0100ec0:	0f b7 c0             	movzwl %ax,%eax
c0100ec3:	f7 36                	divl   (%esi)
    return cPos;
}
c0100ec5:	89 f8                	mov    %edi,%eax
    cPos.y = VideoMemory::getCursorPos() % length;
c0100ec7:	88 57 01             	mov    %dl,0x1(%edi)
}
c0100eca:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100ecd:	5b                   	pop    %ebx
c0100ece:	5e                   	pop    %esi
c0100ecf:	5f                   	pop    %edi
c0100ed0:	5d                   	pop    %ebp
c0100ed1:	c3                   	ret    

c0100ed2 <_ZN7Console4readEv>:
    for (uint32_t i = 0; i < len; i++) {
        wirte(cArry[i]);
    }
}

char Console::read() {
c0100ed2:	e8 f2 fc ff ff       	call   c0100bc9 <__x86.get_pc_thunk.ax>
c0100ed7:	05 49 15 02 00       	add    $0x21549,%eax
c0100edc:	55                   	push   %ebp
c0100edd:	89 e5                	mov    %esp,%ebp
    return screen[0].c;
}
c0100edf:	5d                   	pop    %ebp
    return screen[0].c;
c0100ee0:	c7 c0 30 5a 12 c0    	mov    $0xc0125a30,%eax
c0100ee6:	8b 00                	mov    (%eax),%eax
c0100ee8:	8a 00                	mov    (%eax),%al
}
c0100eea:	c3                   	ret    
c0100eeb:	90                   	nop

c0100eec <_ZN7Console4readEPcRKt>:

void Console::read(char *cArry, const uint16_t &len) {
c0100eec:	55                   	push   %ebp
c0100eed:	89 e5                	mov    %esp,%ebp
   
}
c0100eef:	5d                   	pop    %ebp
c0100ef0:	c3                   	ret    
c0100ef1:	90                   	nop

c0100ef2 <_ZN7Console12scrollScreenEv>:
    } else {
        setCursorPos(cPos.x + 1, 0);
    }
}

void Console::scrollScreen() {
c0100ef2:	e8 cd 01 00 00       	call   c01010c4 <__x86.get_pc_thunk.cx>
c0100ef7:	81 c1 29 15 02 00    	add    $0x21529,%ecx
    charEctype.c = ' ';
    for (uint32_t i = 0; i < length * wide; i++) {
c0100efd:	31 c0                	xor    %eax,%eax
void Console::scrollScreen() {
c0100eff:	55                   	push   %ebp
c0100f00:	89 e5                	mov    %esp,%ebp
c0100f02:	57                   	push   %edi
c0100f03:	56                   	push   %esi
c0100f04:	53                   	push   %ebx
c0100f05:	83 ec 1c             	sub    $0x1c,%esp
    for (uint32_t i = 0; i < length * wide; i++) {
c0100f08:	c7 c7 0c 24 12 c0    	mov    $0xc012240c,%edi
    charEctype.c = ' ';
c0100f0e:	c7 c6 04 24 12 c0    	mov    $0xc0122404,%esi
    for (uint32_t i = 0; i < length * wide; i++) {
c0100f14:	89 7d e0             	mov    %edi,-0x20(%ebp)
c0100f17:	c7 c7 08 24 12 c0    	mov    $0xc0122408,%edi
    charEctype.c = ' ';
c0100f1d:	c6 06 20             	movb   $0x20,(%esi)
    for (uint32_t i = 0; i < length * wide; i++) {
c0100f20:	89 7d dc             	mov    %edi,-0x24(%ebp)
c0100f23:	8b 7d e0             	mov    -0x20(%ebp),%edi
c0100f26:	8b 3f                	mov    (%edi),%edi
c0100f28:	89 7d e4             	mov    %edi,-0x1c(%ebp)
c0100f2b:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0100f2e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
c0100f31:	8b 17                	mov    (%edi),%edx
c0100f33:	0f af da             	imul   %edx,%ebx
c0100f36:	39 c3                	cmp    %eax,%ebx
c0100f38:	76 28                	jbe    c0100f62 <_ZN7Console12scrollScreenEv+0x70>
c0100f3a:	c7 c2 30 5a 12 c0    	mov    $0xc0125a30,%edx
        if (i < length * (wide - 1)) {
c0100f40:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
c0100f43:	8b 3a                	mov    (%edx),%edi
c0100f45:	8d 14 00             	lea    (%eax,%eax,1),%edx
c0100f48:	01 fa                	add    %edi,%edx
c0100f4a:	39 c3                	cmp    %eax,%ebx
c0100f4c:	76 0b                	jbe    c0100f59 <_ZN7Console12scrollScreenEv+0x67>
            screen[i] = screen[length + i];
c0100f4e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
c0100f51:	01 c3                	add    %eax,%ebx
c0100f53:	66 8b 1c 5f          	mov    (%edi,%ebx,2),%bx
c0100f57:	eb 03                	jmp    c0100f5c <_ZN7Console12scrollScreenEv+0x6a>
        } else {
            screen[i] = charEctype;
c0100f59:	66 8b 1e             	mov    (%esi),%bx
c0100f5c:	66 89 1a             	mov    %bx,(%edx)
    for (uint32_t i = 0; i < length * wide; i++) {
c0100f5f:	40                   	inc    %eax
c0100f60:	eb c1                	jmp    c0100f23 <_ZN7Console12scrollScreenEv+0x31>
        }
    }
    setCursorPos(wide - 1, 0);
c0100f62:	fe ca                	dec    %dl
c0100f64:	50                   	push   %eax
c0100f65:	0f b6 d2             	movzbl %dl,%edx
c0100f68:	6a 00                	push   $0x0
c0100f6a:	52                   	push   %edx
c0100f6b:	ff 75 08             	pushl  0x8(%ebp)
c0100f6e:	e8 69 fe ff ff       	call   c0100ddc <_ZN7Console12setCursorPosEhh>
}
c0100f73:	83 c4 10             	add    $0x10,%esp
c0100f76:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100f79:	5b                   	pop    %ebx
c0100f7a:	5e                   	pop    %esi
c0100f7b:	5f                   	pop    %edi
c0100f7c:	5d                   	pop    %ebp
c0100f7d:	c3                   	ret    

c0100f7e <_ZN7Console4nextEv>:
void Console::next() {
c0100f7e:	55                   	push   %ebp
    cPos.y = (cPos.y + 1) % length;
c0100f7f:	31 d2                	xor    %edx,%edx
void Console::next() {
c0100f81:	89 e5                	mov    %esp,%ebp
c0100f83:	57                   	push   %edi
c0100f84:	e8 3f 01 00 00       	call   c01010c8 <__x86.get_pc_thunk.di>
c0100f89:	81 c7 97 14 02 00    	add    $0x21497,%edi
c0100f8f:	56                   	push   %esi
c0100f90:	53                   	push   %ebx
c0100f91:	83 ec 0c             	sub    $0xc,%esp
c0100f94:	8b 75 08             	mov    0x8(%ebp),%esi
    cPos.y = (cPos.y + 1) % length;
c0100f97:	c7 c3 2d 5a 12 c0    	mov    $0xc0125a2d,%ebx
c0100f9d:	c7 c1 0c 24 12 c0    	mov    $0xc012240c,%ecx
c0100fa3:	0f b6 43 01          	movzbl 0x1(%ebx),%eax
c0100fa7:	40                   	inc    %eax
c0100fa8:	f7 31                	divl   (%ecx)
    if (cPos.y == 0) {
c0100faa:	84 d2                	test   %dl,%dl
    cPos.y = (cPos.y + 1) % length;
c0100fac:	89 d1                	mov    %edx,%ecx
c0100fae:	88 53 01             	mov    %dl,0x1(%ebx)
    if (cPos.y == 0) {
c0100fb1:	75 20                	jne    c0100fd3 <_ZN7Console4nextEv+0x55>
        cPos.x = (cPos.x + 1) % wide;
c0100fb3:	0f b6 03             	movzbl (%ebx),%eax
c0100fb6:	31 d2                	xor    %edx,%edx
c0100fb8:	c7 c7 08 24 12 c0    	mov    $0xc0122408,%edi
c0100fbe:	40                   	inc    %eax
c0100fbf:	f7 37                	divl   (%edi)
    if (cPos.y == 0 && cPos.x == 0) {   // jugde scroll screen
c0100fc1:	84 d2                	test   %dl,%dl
        cPos.x = (cPos.x + 1) % wide;
c0100fc3:	88 13                	mov    %dl,(%ebx)
    if (cPos.y == 0 && cPos.x == 0) {   // jugde scroll screen
c0100fc5:	75 0c                	jne    c0100fd3 <_ZN7Console4nextEv+0x55>
}
c0100fc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100fca:	5b                   	pop    %ebx
c0100fcb:	5e                   	pop    %esi
c0100fcc:	5f                   	pop    %edi
c0100fcd:	5d                   	pop    %ebp
        scrollScreen();
c0100fce:	e9 1f ff ff ff       	jmp    c0100ef2 <_ZN7Console12scrollScreenEv>
        setCursorPos(cPos.x, cPos.y);
c0100fd3:	50                   	push   %eax
c0100fd4:	0f b6 03             	movzbl (%ebx),%eax
c0100fd7:	0f b6 c9             	movzbl %cl,%ecx
c0100fda:	51                   	push   %ecx
c0100fdb:	50                   	push   %eax
c0100fdc:	56                   	push   %esi
c0100fdd:	e8 fa fd ff ff       	call   c0100ddc <_ZN7Console12setCursorPosEhh>
c0100fe2:	83 c4 10             	add    $0x10,%esp
}
c0100fe5:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100fe8:	5b                   	pop    %ebx
c0100fe9:	5e                   	pop    %esi
c0100fea:	5f                   	pop    %edi
c0100feb:	5d                   	pop    %ebp
c0100fec:	c3                   	ret    
c0100fed:	90                   	nop

c0100fee <_ZN7Console8lineFeedEv>:
void Console::lineFeed() {
c0100fee:	e8 cd 00 00 00       	call   c01010c0 <__x86.get_pc_thunk.dx>
c0100ff3:	81 c2 2d 14 02 00    	add    $0x2142d,%edx
c0100ff9:	55                   	push   %ebp
c0100ffa:	89 e5                	mov    %esp,%ebp
c0100ffc:	83 ec 08             	sub    $0x8,%esp
c0100fff:	8b 4d 08             	mov    0x8(%ebp),%ecx
    if ((uint32_t)(cPos.x + 1) >= wide) {
c0101002:	c7 c0 2d 5a 12 c0    	mov    $0xc0125a2d,%eax
c0101008:	c7 c2 08 24 12 c0    	mov    $0xc0122408,%edx
c010100e:	0f b6 00             	movzbl (%eax),%eax
c0101011:	40                   	inc    %eax
c0101012:	3b 02                	cmp    (%edx),%eax
c0101014:	72 06                	jb     c010101c <_ZN7Console8lineFeedEv+0x2e>
}
c0101016:	c9                   	leave  
        scrollScreen();
c0101017:	e9 d6 fe ff ff       	jmp    c0100ef2 <_ZN7Console12scrollScreenEv>
        setCursorPos(cPos.x + 1, 0);
c010101c:	52                   	push   %edx
c010101d:	0f b6 c0             	movzbl %al,%eax
c0101020:	6a 00                	push   $0x0
c0101022:	50                   	push   %eax
c0101023:	51                   	push   %ecx
c0101024:	e8 b3 fd ff ff       	call   c0100ddc <_ZN7Console12setCursorPosEhh>
c0101029:	83 c4 10             	add    $0x10,%esp
}
c010102c:	c9                   	leave  
c010102d:	c3                   	ret    

c010102e <_ZN7Console5wirteERKc>:
void Console::wirte(const char &c) {
c010102e:	e8 91 00 00 00       	call   c01010c4 <__x86.get_pc_thunk.cx>
c0101033:	81 c1 ed 13 02 00    	add    $0x213ed,%ecx
c0101039:	55                   	push   %ebp
c010103a:	89 e5                	mov    %esp,%ebp
c010103c:	57                   	push   %edi
    if (c == '\n') {
c010103d:	8b 45 0c             	mov    0xc(%ebp),%eax
void Console::wirte(const char &c) {
c0101040:	56                   	push   %esi
c0101041:	53                   	push   %ebx
c0101042:	c7 c6 2d 5a 12 c0    	mov    $0xc0125a2d,%esi
c0101048:	c7 c7 0c 24 12 c0    	mov    $0xc012240c,%edi
    if (c == '\n') {
c010104e:	8a 10                	mov    (%eax),%dl
c0101050:	c7 c3 30 5a 12 c0    	mov    $0xc0125a30,%ebx
c0101056:	0f b6 06             	movzbl (%esi),%eax
c0101059:	0f b6 76 01          	movzbl 0x1(%esi),%esi
c010105d:	c7 c1 04 24 12 c0    	mov    $0xc0122404,%ecx
c0101063:	0f af 07             	imul   (%edi),%eax
c0101066:	01 f0                	add    %esi,%eax
c0101068:	01 c0                	add    %eax,%eax
c010106a:	03 03                	add    (%ebx),%eax
c010106c:	80 fa 0a             	cmp    $0xa,%dl
c010106f:	75 12                	jne    c0101083 <_ZN7Console5wirteERKc+0x55>
        charEctype.c = ' ';
c0101071:	c6 01 20             	movb   $0x20,(%ecx)
        screen[cPos.x * length + cPos.y] = charEctype;
c0101074:	66 8b 11             	mov    (%ecx),%dx
c0101077:	66 89 10             	mov    %dx,(%eax)
}
c010107a:	5b                   	pop    %ebx
c010107b:	5e                   	pop    %esi
c010107c:	5f                   	pop    %edi
c010107d:	5d                   	pop    %ebp
        lineFeed();
c010107e:	e9 6b ff ff ff       	jmp    c0100fee <_ZN7Console8lineFeedEv>
        charEctype.c = c;
c0101083:	88 11                	mov    %dl,(%ecx)
        screen[cPos.x * length + cPos.y] = charEctype;
c0101085:	66 8b 11             	mov    (%ecx),%dx
c0101088:	66 89 10             	mov    %dx,(%eax)
}
c010108b:	5b                   	pop    %ebx
c010108c:	5e                   	pop    %esi
c010108d:	5f                   	pop    %edi
c010108e:	5d                   	pop    %ebp
        next();
c010108f:	e9 ea fe ff ff       	jmp    c0100f7e <_ZN7Console4nextEv>

c0101094 <_ZN7Console5wirteEPcRKt>:
void Console::wirte(char *cArry, const uint16_t &len) {
c0101094:	55                   	push   %ebp
c0101095:	89 e5                	mov    %esp,%ebp
c0101097:	53                   	push   %ebx
    for (uint32_t i = 0; i < len; i++) {
c0101098:	31 db                	xor    %ebx,%ebx
void Console::wirte(char *cArry, const uint16_t &len) {
c010109a:	52                   	push   %edx
    for (uint32_t i = 0; i < len; i++) {
c010109b:	8b 45 10             	mov    0x10(%ebp),%eax
c010109e:	0f b7 00             	movzwl (%eax),%eax
c01010a1:	39 d8                	cmp    %ebx,%eax
c01010a3:	76 16                	jbe    c01010bb <_ZN7Console5wirteEPcRKt+0x27>
        wirte(cArry[i]);
c01010a5:	50                   	push   %eax
c01010a6:	50                   	push   %eax
c01010a7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01010aa:	01 d8                	add    %ebx,%eax
    for (uint32_t i = 0; i < len; i++) {
c01010ac:	43                   	inc    %ebx
        wirte(cArry[i]);
c01010ad:	50                   	push   %eax
c01010ae:	ff 75 08             	pushl  0x8(%ebp)
c01010b1:	e8 78 ff ff ff       	call   c010102e <_ZN7Console5wirteERKc>
    for (uint32_t i = 0; i < len; i++) {
c01010b6:	83 c4 10             	add    $0x10,%esp
c01010b9:	eb e0                	jmp    c010109b <_ZN7Console5wirteEPcRKt+0x7>
}
c01010bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01010be:	c9                   	leave  
c01010bf:	c3                   	ret    

c01010c0 <__x86.get_pc_thunk.dx>:
c01010c0:	8b 14 24             	mov    (%esp),%edx
c01010c3:	c3                   	ret    

c01010c4 <__x86.get_pc_thunk.cx>:
c01010c4:	8b 0c 24             	mov    (%esp),%ecx
c01010c7:	c3                   	ret    

c01010c8 <__x86.get_pc_thunk.di>:
c01010c8:	8b 3c 24             	mov    (%esp),%edi
c01010cb:	c3                   	ret    

c01010cc <_ZN9InterruptC1Ev>:
#include <interrupt.h>

Interrupt::Interrupt() {
c01010cc:	55                   	push   %ebp
c01010cd:	89 e5                	mov    %esp,%ebp
    
}
c01010cf:	5d                   	pop    %ebp
c01010d0:	c3                   	ret    
c01010d1:	90                   	nop

c01010d2 <_ZN9Interrupt7initIDTEv>:
    enableIRQ(2);                                   // set master IR2, because of slave connection to IR2
    
    enableIRQ(8);                                   // set slave IR1, clock interrupt of RTC
}

void Interrupt::initIDT() {
c01010d2:	55                   	push   %ebp
c01010d3:	89 e5                	mov    %esp,%ebp
c01010d5:	57                   	push   %edi
c01010d6:	56                   	push   %esi
    extern uptr32_t __vectors[];
    for (uint32_t i = 0; i < sizeof(IDT) / sizeof(MMU::GateDesc); i++) {
c01010d7:	31 f6                	xor    %esi,%esi
void Interrupt::initIDT() {
c01010d9:	53                   	push   %ebx
c01010da:	e8 ee fa ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c01010df:	81 c3 41 13 02 00    	add    $0x21341,%ebx
c01010e5:	83 ec 1c             	sub    $0x1c,%esp
        MMU::setGateDesc(IDT[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01010e8:	c7 c0 00 20 12 c0    	mov    $0xc0122000,%eax
c01010ee:	c7 c7 c0 51 12 c0    	mov    $0xc01251c0,%edi
c01010f4:	83 ec 0c             	sub    $0xc,%esp
c01010f7:	6a 00                	push   $0x0
c01010f9:	ff 34 b0             	pushl  (%eax,%esi,4)
c01010fc:	8d 14 f7             	lea    (%edi,%esi,8),%edx
    for (uint32_t i = 0; i < sizeof(IDT) / sizeof(MMU::GateDesc); i++) {
c01010ff:	46                   	inc    %esi
        MMU::setGateDesc(IDT[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0101100:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0101103:	6a 08                	push   $0x8
c0101105:	6a 00                	push   $0x0
c0101107:	52                   	push   %edx
c0101108:	e8 eb 47 00 00       	call   c01058f8 <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>
    for (uint32_t i = 0; i < sizeof(IDT) / sizeof(MMU::GateDesc); i++) {
c010110d:	83 c4 20             	add    $0x20,%esp
c0101110:	81 fe 00 01 00 00    	cmp    $0x100,%esi
c0101116:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101119:	75 d9                	jne    c01010f4 <_ZN9Interrupt7initIDTEv+0x22>
    }
	// set for switch from user to kernel
    MMU::setGateDesc(IDT[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c010111b:	83 ec 0c             	sub    $0xc,%esp
c010111e:	6a 03                	push   $0x3
c0101120:	ff b0 e4 01 00 00    	pushl  0x1e4(%eax)
c0101126:	8d 87 c8 03 00 00    	lea    0x3c8(%edi),%eax
c010112c:	6a 08                	push   $0x8
c010112e:	6a 00                	push   $0x0
c0101130:	50                   	push   %eax
c0101131:	e8 c2 47 00 00       	call   c01058f8 <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>
    asm volatile ("lidt (%0)" :: "r" (pd));
c0101136:	c7 c0 50 24 12 c0    	mov    $0xc0122450,%eax
c010113c:	0f 01 18             	lidtl  (%eax)
	// load the IDT
    lidt(&idtPD);
}
c010113f:	83 c4 20             	add    $0x20,%esp
c0101142:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101145:	5b                   	pop    %ebx
c0101146:	5e                   	pop    %esi
c0101147:	5f                   	pop    %edi
c0101148:	5d                   	pop    %ebp
c0101149:	c3                   	ret    

c010114a <_ZN9Interrupt4initEv>:
void Interrupt::init() {
c010114a:	55                   	push   %ebp
c010114b:	89 e5                	mov    %esp,%ebp
c010114d:	56                   	push   %esi
c010114e:	8b 75 08             	mov    0x8(%ebp),%esi
c0101151:	53                   	push   %ebx
c0101152:	e8 76 fa ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0101157:	81 c3 c9 12 02 00    	add    $0x212c9,%ebx
    initIDT();
c010115d:	83 ec 0c             	sub    $0xc,%esp
c0101160:	56                   	push   %esi
c0101161:	e8 6c ff ff ff       	call   c01010d2 <_ZN9Interrupt7initIDTEv>
    initPIC();
c0101166:	89 34 24             	mov    %esi,(%esp)
c0101169:	e8 36 00 00 00       	call   c01011a4 <_ZN3PIC7initPICEv>
    initClock();
c010116e:	89 34 24             	mov    %esi,(%esp)
c0101171:	e8 fa 00 00 00       	call   c0101270 <_ZN3RTC9initClockEv>
    enableIRQ(2);                                   // set master IR2, because of slave connection to IR2
c0101176:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010117d:	e8 7c 00 00 00       	call   c01011fe <_ZN3PIC9enableIRQEj>
    enableIRQ(8);                                   // set slave IR1, clock interrupt of RTC
c0101182:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101189:	e8 70 00 00 00       	call   c01011fe <_ZN3PIC9enableIRQEj>
}
c010118e:	83 c4 10             	add    $0x10,%esp
c0101191:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101194:	5b                   	pop    %ebx
c0101195:	5e                   	pop    %esi
c0101196:	5d                   	pop    %ebp
c0101197:	c3                   	ret    

c0101198 <_ZN9Interrupt6enableEv>:

void Interrupt::enable() {
c0101198:	55                   	push   %ebp
c0101199:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c010119b:	fb                   	sti    
    sti();
}
c010119c:	5d                   	pop    %ebp
c010119d:	c3                   	ret    

c010119e <_ZN9Interrupt7disableEv>:

void Interrupt::disable() {
c010119e:	55                   	push   %ebp
c010119f:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli");
c01011a1:	fa                   	cli    
    cli();
}
c01011a2:	5d                   	pop    %ebp
c01011a3:	c3                   	ret    

c01011a4 <_ZN3PIC7initPICEv>:
#include <pic.h>

void PIC::initPIC() {
c01011a4:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c01011a5:	b0 ff                	mov    $0xff,%al
c01011a7:	89 e5                	mov    %esp,%ebp
c01011a9:	57                   	push   %edi
c01011aa:	56                   	push   %esi
c01011ab:	be 21 00 00 00       	mov    $0x21,%esi
c01011b0:	53                   	push   %ebx
c01011b1:	89 f2                	mov    %esi,%edx
c01011b3:	e8 10 ff ff ff       	call   c01010c8 <__x86.get_pc_thunk.di>
c01011b8:	81 c7 68 12 02 00    	add    $0x21268,%edi
c01011be:	ee                   	out    %al,(%dx)
c01011bf:	bb a1 00 00 00       	mov    $0xa1,%ebx
c01011c4:	89 da                	mov    %ebx,%edx
c01011c6:	ee                   	out    %al,(%dx)
c01011c7:	b1 11                	mov    $0x11,%cl
c01011c9:	ba 20 00 00 00       	mov    $0x20,%edx
c01011ce:	88 c8                	mov    %cl,%al
c01011d0:	ee                   	out    %al,(%dx)
c01011d1:	b0 20                	mov    $0x20,%al
c01011d3:	89 f2                	mov    %esi,%edx
c01011d5:	ee                   	out    %al,(%dx)
c01011d6:	b0 04                	mov    $0x4,%al
c01011d8:	ee                   	out    %al,(%dx)
c01011d9:	b0 01                	mov    $0x1,%al
c01011db:	ee                   	out    %al,(%dx)
c01011dc:	ba a0 00 00 00       	mov    $0xa0,%edx
c01011e1:	88 c8                	mov    %cl,%al
c01011e3:	ee                   	out    %al,(%dx)
c01011e4:	b0 70                	mov    $0x70,%al
c01011e6:	89 da                	mov    %ebx,%edx
c01011e8:	ee                   	out    %al,(%dx)
c01011e9:	b0 04                	mov    $0x4,%al
c01011eb:	ee                   	out    %al,(%dx)
c01011ec:	b0 01                	mov    $0x1,%al
c01011ee:	ee                   	out    %al,(%dx)
    outb(ICW1_ICW4, IO1_8259PIC2);                  // ICW1: edge-tri / cascade
    outb(0x70, IO2_8259PIC2);                       // ICW2: set first vectors of interrupt
    outb(0x04, IO2_8259PIC2);                       // ICW3: second chip is link to IR2 of first chip
    outb(0x01, IO2_8259PIC2);                       // ICW4; normal EOI

    didInit = true;                                 // 
c01011ef:	c7 c0 2c 5a 12 c0    	mov    $0xc0125a2c,%eax
c01011f5:	c6 00 01             	movb   $0x1,(%eax)
}
c01011f8:	5b                   	pop    %ebx
c01011f9:	5e                   	pop    %esi
c01011fa:	5f                   	pop    %edi
c01011fb:	5d                   	pop    %ebp
c01011fc:	c3                   	ret    
c01011fd:	90                   	nop

c01011fe <_ZN3PIC9enableIRQEj>:

void PIC::enableIRQ(uint32_t irq) {                 // enable irq
c01011fe:	e8 bd fe ff ff       	call   c01010c0 <__x86.get_pc_thunk.dx>
c0101203:	81 c2 1d 12 02 00    	add    $0x2121d,%edx
    irqMask &= ~(1 << irq);
c0101209:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
void PIC::enableIRQ(uint32_t irq) {                 // enable irq
c010120e:	55                   	push   %ebp
c010120f:	89 e5                	mov    %esp,%ebp
    irqMask &= ~(1 << irq);
c0101211:	8b 4d 08             	mov    0x8(%ebp),%ecx
void PIC::enableIRQ(uint32_t irq) {                 // enable irq
c0101214:	53                   	push   %ebx
    irqMask &= ~(1 << irq);
c0101215:	c7 c3 00 24 12 c0    	mov    $0xc0122400,%ebx
c010121b:	d3 c0                	rol    %cl,%eax
    if (didInit) {
c010121d:	c7 c2 2c 5a 12 c0    	mov    $0xc0125a2c,%edx
    irqMask &= ~(1 << irq);
c0101223:	66 8b 0b             	mov    (%ebx),%cx
c0101226:	21 c8                	and    %ecx,%eax
    if (didInit) {
c0101228:	80 3a 00             	cmpb   $0x0,(%edx)
    irqMask &= ~(1 << irq);
c010122b:	98                   	cwtl   
c010122c:	0f b7 c8             	movzwl %ax,%ecx
c010122f:	66 89 0b             	mov    %cx,(%ebx)
    if (didInit) {
c0101232:	74 11                	je     c0101245 <_ZN3PIC9enableIRQEj+0x47>
c0101234:	ba 21 00 00 00       	mov    $0x21,%edx
c0101239:	ee                   	out    %al,(%dx)
        outb(irqMask & 0xFF, IO2_8259PIC1);         // master chip
        outb((irqMask >> 8) & 0xFF, IO2_8259PIC2);  // slave chip
c010123a:	89 c8                	mov    %ecx,%eax
c010123c:	ba a1 00 00 00       	mov    $0xa1,%edx
c0101241:	c1 e8 08             	shr    $0x8,%eax
c0101244:	ee                   	out    %al,(%dx)
    }
}
c0101245:	5b                   	pop    %ebx
c0101246:	5d                   	pop    %ebp
c0101247:	c3                   	ret    

c0101248 <_ZN3PIC7sendEOIEv>:

void PIC::sendEOI() {
c0101248:	55                   	push   %ebp
c0101249:	b0 20                	mov    $0x20,%al
c010124b:	89 e5                	mov    %esp,%ebp
c010124d:	ba a0 00 00 00       	mov    $0xa0,%edx
c0101252:	ee                   	out    %al,(%dx)
c0101253:	ba 20 00 00 00       	mov    $0x20,%edx
c0101258:	ee                   	out    %al,(%dx)
    outb(EOI_CMD, IO1_8259PIC2);                    // send EOI cmd for slave
    outb(EOI_CMD, IO1_8259PIC1);                    // send EOI cmd for master
c0101259:	5d                   	pop    %ebp
c010125a:	c3                   	ret    
c010125b:	90                   	nop

c010125c <_ZN3RTC12clInteStatusEv>:
    outb(regA, RTC_DATA_PORT1);                     // write A

    clInteStatus();                                 // clear Interrupt status
}

void RTC::clInteStatus() {
c010125c:	55                   	push   %ebp
c010125d:	b0 0c                	mov    $0xc,%al
c010125f:	89 e5                	mov    %esp,%ebp
c0101261:	ba 70 00 00 00       	mov    $0x70,%edx
c0101266:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c0101267:	ba 71 00 00 00       	mov    $0x71,%edx
c010126c:	ec                   	in     (%dx),%al
    outb(RTC_REG_C, RTC_INDEX_PORT1);               // choice reg C
    inb(RTC_DATA_PORT1);                            // read regC to clear interrupt status
c010126d:	5d                   	pop    %ebp
c010126e:	c3                   	ret    
c010126f:	90                   	nop

c0101270 <_ZN3RTC9initClockEv>:
void RTC::initClock() {
c0101270:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c0101271:	b0 8b                	mov    $0x8b,%al
c0101273:	89 e5                	mov    %esp,%ebp
c0101275:	53                   	push   %ebx
c0101276:	bb 70 00 00 00       	mov    $0x70,%ebx
c010127b:	89 da                	mov    %ebx,%edx
c010127d:	ee                   	out    %al,(%dx)
c010127e:	b9 71 00 00 00       	mov    $0x71,%ecx
c0101283:	b0 42                	mov    $0x42,%al
c0101285:	89 ca                	mov    %ecx,%edx
c0101287:	ee                   	out    %al,(%dx)
c0101288:	b0 0a                	mov    $0xa,%al
c010128a:	89 da                	mov    %ebx,%edx
c010128c:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c010128d:	89 ca                	mov    %ecx,%edx
c010128f:	ec                   	in     (%dx),%al
    regA = (regA & 0xF0) | 0x2;                     // 7.8125ms
c0101290:	24 f0                	and    $0xf0,%al
c0101292:	0c 02                	or     $0x2,%al
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c0101294:	ee                   	out    %al,(%dx)
}
c0101295:	5b                   	pop    %ebx
c0101296:	5d                   	pop    %ebp
    clInteStatus();                                 // clear Interrupt status
c0101297:	eb c3                	jmp    c010125c <_ZN3RTC12clInteStatusEv>
c0101299:	90                   	nop

c010129a <_ZN11VideoMemoryC1Ev>:
#include <vdieomemory.h>

VideoMemory::VideoMemory() {
c010129a:	55                   	push   %ebp
c010129b:	89 e5                	mov    %esp,%ebp
c010129d:	8b 45 08             	mov    0x8(%ebp),%eax
c01012a0:	c7 00 00 80 0b c0    	movl   $0xc00b8000,(%eax)
c01012a6:	66 c7 40 04 a0 0f    	movw   $0xfa0,0x4(%eax)

}
c01012ac:	5d                   	pop    %ebp
c01012ad:	c3                   	ret    

c01012ae <_ZN11VideoMemory10initVmBuffEv>:

void VideoMemory::initVmBuff() {
c01012ae:	55                   	push   %ebp
    for (uint32_t i = 0; i < VGA_BUFF_SIZE; i++) {
c01012af:	31 c0                	xor    %eax,%eax
void VideoMemory::initVmBuff() {
c01012b1:	89 e5                	mov    %esp,%ebp
c01012b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
        vmBuffer[i] = 0;
c01012b6:	8b 11                	mov    (%ecx),%edx
c01012b8:	c6 04 02 00          	movb   $0x0,(%edx,%eax,1)
    for (uint32_t i = 0; i < VGA_BUFF_SIZE; i++) {
c01012bc:	40                   	inc    %eax
c01012bd:	3d a0 0f 00 00       	cmp    $0xfa0,%eax
c01012c2:	75 f2                	jne    c01012b6 <_ZN11VideoMemory10initVmBuffEv+0x8>
    }
}
c01012c4:	5d                   	pop    %ebp
c01012c5:	c3                   	ret    

c01012c6 <_ZN11VideoMemory12getCursorPosEv>:

uint16_t VideoMemory::getCursorPos() {
c01012c6:	55                   	push   %ebp
c01012c7:	b0 0f                	mov    $0xf,%al
c01012c9:	89 e5                	mov    %esp,%ebp
c01012cb:	56                   	push   %esi
c01012cc:	be d4 03 00 00       	mov    $0x3d4,%esi
c01012d1:	53                   	push   %ebx
c01012d2:	89 f2                	mov    %esi,%edx
c01012d4:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c01012d5:	bb d5 03 00 00       	mov    $0x3d5,%ebx
c01012da:	89 da                	mov    %ebx,%edx
c01012dc:	ec                   	in     (%dx),%al
c01012dd:	0f b6 c8             	movzbl %al,%ecx
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c01012e0:	89 f2                	mov    %esi,%edx
c01012e2:	b0 0e                	mov    $0xe,%al
c01012e4:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c01012e5:	89 da                	mov    %ebx,%edx
c01012e7:	ec                   	in     (%dx),%al
    outb(VGA_CURSOR_PORT_D, VGA_INDEX_PORT);
    uint8_t low = inb(VGA_DATA_PORT);
    outb(VGA_CURSOR_PORT_H, VGA_INDEX_PORT);
    uint16_t pos = inb(VGA_DATA_PORT);
    return (pos << 8) + low;
}
c01012e8:	5b                   	pop    %ebx
    uint16_t pos = inb(VGA_DATA_PORT);
c01012e9:	0f b6 c0             	movzbl %al,%eax
    return (pos << 8) + low;
c01012ec:	c1 e0 08             	shl    $0x8,%eax
}
c01012ef:	5e                   	pop    %esi
    return (pos << 8) + low;
c01012f0:	01 c8                	add    %ecx,%eax
}
c01012f2:	5d                   	pop    %ebp
c01012f3:	c3                   	ret    

c01012f4 <_ZN11VideoMemory12setCursorPosEt>:

void VideoMemory::setCursorPos(uint16_t pos) {
c01012f4:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c01012f5:	b0 0f                	mov    $0xf,%al
c01012f7:	89 e5                	mov    %esp,%ebp
c01012f9:	56                   	push   %esi
c01012fa:	be d4 03 00 00       	mov    $0x3d4,%esi
c01012ff:	0f b7 4d 0c          	movzwl 0xc(%ebp),%ecx
c0101303:	53                   	push   %ebx
c0101304:	89 f2                	mov    %esi,%edx
c0101306:	ee                   	out    %al,(%dx)
c0101307:	bb d5 03 00 00       	mov    $0x3d5,%ebx
c010130c:	88 c8                	mov    %cl,%al
c010130e:	89 da                	mov    %ebx,%edx
c0101310:	ee                   	out    %al,(%dx)
c0101311:	b0 0e                	mov    $0xe,%al
c0101313:	89 f2                	mov    %esi,%edx
c0101315:	ee                   	out    %al,(%dx)
    outb(VGA_CURSOR_PORT_D, VGA_INDEX_PORT);
    outb((pos & 0xFF), VGA_DATA_PORT);
    outb(VGA_CURSOR_PORT_H, VGA_INDEX_PORT);
    outb(((pos >> 8) & 0xFF), VGA_DATA_PORT);
c0101316:	89 c8                	mov    %ecx,%eax
c0101318:	89 da                	mov    %ebx,%edx
c010131a:	c1 e8 08             	shr    $0x8,%eax
c010131d:	ee                   	out    %al,(%dx)
}
c010131e:	5b                   	pop    %ebx
c010131f:	5e                   	pop    %esi
c0101320:	5d                   	pop    %ebp
c0101321:	c3                   	ret    

c0101322 <_ZN3IDE7isValidEj>:
    // enable ide interrupt
    PIC::enableIRQ(IRQ_IDE1);
    PIC::enableIRQ(IRQ_IDE2);
}

bool IDE::isValid(uint32_t ideno) {
c0101322:	55                   	push   %ebp
c0101323:	31 c0                	xor    %eax,%eax
c0101325:	89 e5                	mov    %esp,%ebp
c0101327:	8b 55 08             	mov    0x8(%ebp),%edx
c010132a:	e8 95 fd ff ff       	call   c01010c4 <__x86.get_pc_thunk.cx>
c010132f:	81 c1 f1 10 02 00    	add    $0x210f1,%ecx
    return ((ideno) >= 0) && ((ideno) < MAX_IDE) && (ideDevs[ideno].valid);
c0101335:	83 fa 03             	cmp    $0x3,%edx
c0101338:	77 0f                	ja     c0101349 <_ZN3IDE7isValidEj+0x27>
c010133a:	6b d2 32             	imul   $0x32,%edx,%edx
c010133d:	81 c2 a0 50 12 c0    	add    $0xc01250a0,%edx
c0101343:	80 3a 00             	cmpb   $0x0,(%edx)
c0101346:	0f 95 c0             	setne  %al
}
c0101349:	5d                   	pop    %ebp
c010134a:	c3                   	ret    
c010134b:	90                   	nop

c010134c <_ZN3IDE9waitReadyEtb>:

uint32_t IDE::waitReady(uint16_t iobase, bool check) {
c010134c:	55                   	push   %ebp
c010134d:	89 e5                	mov    %esp,%ebp
c010134f:	0f b7 55 08          	movzwl 0x8(%ebp),%edx
c0101353:	8a 4d 0c             	mov    0xc(%ebp),%cl
    uint32_t r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0101356:	83 c2 07             	add    $0x7,%edx
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c0101359:	ec                   	in     (%dx),%al
c010135a:	84 c0                	test   %al,%al
c010135c:	78 fb                	js     c0101359 <_ZN3IDE9waitReadyEtb+0xd>
        /* nothing */;
    if (check && (r & (IDE_DF | IDE_ERR)) != 0) {
        return -1;
    }
    return 0;
c010135e:	31 d2                	xor    %edx,%edx
    if (check && (r & (IDE_DF | IDE_ERR)) != 0) {
c0101360:	84 c9                	test   %cl,%cl
c0101362:	74 09                	je     c010136d <_ZN3IDE9waitReadyEtb+0x21>
c0101364:	31 d2                	xor    %edx,%edx
c0101366:	a8 21                	test   $0x21,%al
c0101368:	0f 95 c2             	setne  %dl
c010136b:	f7 da                	neg    %edx
}
c010136d:	89 d0                	mov    %edx,%eax
c010136f:	5d                   	pop    %ebp
c0101370:	c3                   	ret    
c0101371:	90                   	nop

c0101372 <_ZN3IDE4initEv>:
void IDE::init() {
c0101372:	55                   	push   %ebp
c0101373:	89 e5                	mov    %esp,%ebp
c0101375:	57                   	push   %edi
c0101376:	56                   	push   %esi
c0101377:	53                   	push   %ebx
c0101378:	e8 50 f8 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c010137d:	81 c3 a3 10 02 00    	add    $0x210a3,%ebx
c0101383:	81 ec 4c 04 00 00    	sub    $0x44c,%esp
c0101389:	c6 85 bf fb ff ff 00 	movb   $0x0,-0x441(%ebp)
c0101390:	c7 85 c0 fb ff ff 00 	movl   $0x0,-0x440(%ebp)
c0101397:	00 00 00 
c010139a:	c7 c0 a0 50 12 c0    	mov    $0xc01250a0,%eax
c01013a0:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
        iobase = IO_BASE(ideno);
c01013a6:	c7 c0 98 5e 10 c0    	mov    $0xc0105e98,%eax
c01013ac:	89 85 b8 fb ff ff    	mov    %eax,-0x448(%ebp)
        ideDevs[ideno].valid = 0;
c01013b2:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
        iobase = IO_BASE(ideno);
c01013b8:	8b 8d b8 fb ff ff    	mov    -0x448(%ebp),%ecx
        ideDevs[ideno].valid = 0;
c01013be:	c6 00 00             	movb   $0x0,(%eax)
        iobase = IO_BASE(ideno);
c01013c1:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c01013c7:	d1 f8                	sar    %eax
c01013c9:	0f b7 34 81          	movzwl (%ecx,%eax,4),%esi
        waitReady(iobase);
c01013cd:	6a 00                	push   $0x0
c01013cf:	56                   	push   %esi
c01013d0:	e8 77 ff ff ff       	call   c010134c <_ZN3IDE9waitReadyEtb>
        outb(0xE0 | ((ideno & 1) << 4), iobase + ISA_SDH);
c01013d5:	8a 85 bf fb ff ff    	mov    -0x441(%ebp),%al
c01013db:	8d 56 06             	lea    0x6(%esi),%edx
c01013de:	24 10                	and    $0x10,%al
c01013e0:	0c e0                	or     $0xe0,%al
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c01013e2:	ee                   	out    %al,(%dx)
        waitReady(iobase);
c01013e3:	6a 00                	push   $0x0
c01013e5:	56                   	push   %esi
c01013e6:	e8 61 ff ff ff       	call   c010134c <_ZN3IDE9waitReadyEtb>
        outb(IDE_CMD_IDENTIFY, iobase + ISA_COMMAND);
c01013eb:	8d 56 07             	lea    0x7(%esi),%edx
c01013ee:	b0 ec                	mov    $0xec,%al
c01013f0:	0f b7 d2             	movzwl %dx,%edx
c01013f3:	ee                   	out    %al,(%dx)
        waitReady(iobase);
c01013f4:	6a 00                	push   $0x0
c01013f6:	56                   	push   %esi
c01013f7:	89 95 b4 fb ff ff    	mov    %edx,-0x44c(%ebp)
c01013fd:	e8 4a ff ff ff       	call   c010134c <_ZN3IDE9waitReadyEtb>
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c0101402:	8b 95 b4 fb ff ff    	mov    -0x44c(%ebp),%edx
c0101408:	ec                   	in     (%dx),%al
        if (inb(iobase + ISA_STATUS) == 0 || waitReady(iobase, true) != 0) {
c0101409:	83 c4 18             	add    $0x18,%esp
c010140c:	84 c0                	test   %al,%al
c010140e:	0f 84 37 02 00 00    	je     c010164b <_ZN3IDE4initEv+0x2d9>
c0101414:	6a 01                	push   $0x1
c0101416:	56                   	push   %esi
c0101417:	e8 30 ff ff ff       	call   c010134c <_ZN3IDE9waitReadyEtb>
c010141c:	59                   	pop    %ecx
c010141d:	5f                   	pop    %edi
c010141e:	85 c0                	test   %eax,%eax
c0101420:	0f 85 25 02 00 00    	jne    c010164b <_ZN3IDE4initEv+0x2d9>
        ideDevs[ideno].valid = 1;
c0101426:	8b 8d c4 fb ff ff    	mov    -0x43c(%ebp),%ecx
        : "memory", "cc");
c010142c:	8d bd e0 fb ff ff    	lea    -0x420(%ebp),%edi
c0101432:	89 f2                	mov    %esi,%edx
c0101434:	c6 01 01             	movb   $0x1,(%ecx)
c0101437:	b9 80 00 00 00       	mov    $0x80,%ecx
c010143c:	fc                   	cld    
c010143d:	f2 6d                	repnz insl (%dx),%es:(%edi)
        uint32_t cmdsets = *(uint32_t *)(ident + IDE_IDENT_CMDSETS);
c010143f:	8b 8d 84 fc ff ff    	mov    -0x37c(%ebp),%ecx
        if (cmdsets & (1 << 26)) {
c0101445:	0f ba e1 1a          	bt     $0x1a,%ecx
c0101449:	73 08                	jae    c0101453 <_ZN3IDE4initEv+0xe1>
            sectors = *(uint32_t *)(ident + IDE_IDENT_MAX_LBA_EXT);
c010144b:	8b 95 a8 fc ff ff    	mov    -0x358(%ebp),%edx
c0101451:	eb 06                	jmp    c0101459 <_ZN3IDE4initEv+0xe7>
            sectors = *(uint32_t *)(ident + IDE_IDENT_MAX_LBA);
c0101453:	8b 95 58 fc ff ff    	mov    -0x3a8(%ebp),%edx
        ideDevs[ideno].sets = cmdsets;
c0101459:	8b bd c4 fb ff ff    	mov    -0x43c(%ebp),%edi
        assert((*(uint16_t *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c010145f:	f6 85 43 fc ff ff 02 	testb  $0x2,-0x3bd(%ebp)
        ideDevs[ideno].sets = cmdsets;
c0101466:	89 4f 01             	mov    %ecx,0x1(%edi)
        ideDevs[ideno].size = sectors;
c0101469:	89 57 05             	mov    %edx,0x5(%edi)
        assert((*(uint16_t *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c010146c:	0f 85 9e 00 00 00    	jne    c0101510 <_ZN3IDE4initEv+0x19e>
c0101472:	89 85 b0 fb ff ff    	mov    %eax,-0x450(%ebp)
c0101478:	8d 93 b1 39 fe ff    	lea    -0x1c64f(%ebx),%edx
c010147e:	50                   	push   %eax
c010147f:	50                   	push   %eax
c0101480:	52                   	push   %edx
c0101481:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c0101487:	56                   	push   %esi
c0101488:	e8 6d 48 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010148d:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0101493:	58                   	pop    %eax
c0101494:	5a                   	pop    %edx
c0101495:	8d 93 bb 39 fe ff    	lea    -0x1c645(%ebx),%edx
c010149b:	52                   	push   %edx
c010149c:	8d 95 d3 fb ff ff    	lea    -0x42d(%ebp),%edx
c01014a2:	52                   	push   %edx
c01014a3:	89 95 b4 fb ff ff    	mov    %edx,-0x44c(%ebp)
c01014a9:	e8 4c 48 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01014ae:	8b 95 b4 fb ff ff    	mov    -0x44c(%ebp),%edx
c01014b4:	83 c4 0c             	add    $0xc,%esp
c01014b7:	56                   	push   %esi
c01014b8:	52                   	push   %edx
c01014b9:	57                   	push   %edi
c01014ba:	e8 0f 06 00 00       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01014bf:	8b 95 b4 fb ff ff    	mov    -0x44c(%ebp),%edx
c01014c5:	89 14 24             	mov    %edx,(%esp)
c01014c8:	e8 47 48 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01014cd:	89 34 24             	mov    %esi,(%esp)
c01014d0:	e8 3f 48 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01014d5:	8d 93 cc 39 fe ff    	lea    -0x1c634(%ebx),%edx
c01014db:	59                   	pop    %ecx
c01014dc:	58                   	pop    %eax
c01014dd:	52                   	push   %edx
c01014de:	56                   	push   %esi
c01014df:	e8 16 48 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01014e4:	58                   	pop    %eax
c01014e5:	5a                   	pop    %edx
c01014e6:	56                   	push   %esi
c01014e7:	57                   	push   %edi
c01014e8:	e8 2f 07 00 00       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01014ed:	89 34 24             	mov    %esi,(%esp)
c01014f0:	e8 1f 48 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01014f5:	89 3c 24             	mov    %edi,(%esp)
c01014f8:	e8 6b 06 00 00       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01014fd:	fa                   	cli    
    asm volatile ("hlt");
c01014fe:	f4                   	hlt    
c01014ff:	89 3c 24             	mov    %edi,(%esp)
c0101502:	e8 a5 06 00 00       	call   c0101bac <_ZN7OStreamD1Ev>
c0101507:	8b 85 b0 fb ff ff    	mov    -0x450(%ebp),%eax
c010150d:	83 c4 10             	add    $0x10,%esp
c0101510:	8b 8d c4 fb ff ff    	mov    -0x43c(%ebp),%ecx
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101516:	8d b5 17 fc ff ff    	lea    -0x3e9(%ebp),%esi
c010151c:	8d bd 16 fc ff ff    	lea    -0x3ea(%ebp),%edi
c0101522:	8d 51 09             	lea    0x9(%ecx),%edx
c0101525:	8a 0c 06             	mov    (%esi,%eax,1),%cl
c0101528:	88 0c 02             	mov    %cl,(%edx,%eax,1)
c010152b:	8a 0c 07             	mov    (%edi,%eax,1),%cl
c010152e:	88 4c 02 01          	mov    %cl,0x1(%edx,%eax,1)
        for (i = 0; i < length; i += 2) {
c0101532:	83 c0 02             	add    $0x2,%eax
c0101535:	83 f8 28             	cmp    $0x28,%eax
c0101538:	75 eb                	jne    c0101525 <_ZN3IDE4initEv+0x1b3>
c010153a:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0101540:	83 c0 31             	add    $0x31,%eax
        } while (i -- > 0 && model[i] == ' ');
c0101543:	39 d0                	cmp    %edx,%eax
            model[i] = '\0';
c0101545:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c0101548:	74 06                	je     c0101550 <_ZN3IDE4initEv+0x1de>
c010154a:	48                   	dec    %eax
c010154b:	80 38 20             	cmpb   $0x20,(%eax)
c010154e:	74 f3                	je     c0101543 <_ZN3IDE4initEv+0x1d1>
        OStream out("\nide", "blue");
c0101550:	50                   	push   %eax
c0101551:	50                   	push   %eax
c0101552:	8d 83 96 39 fe ff    	lea    -0x1c66a(%ebx),%eax
c0101558:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c010155e:	50                   	push   %eax
c010155f:	56                   	push   %esi
c0101560:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0101566:	89 95 b0 fb ff ff    	mov    %edx,-0x450(%ebp)
c010156c:	e8 89 47 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0101571:	8d 83 09 3a fe ff    	lea    -0x1c5f7(%ebx),%eax
c0101577:	5a                   	pop    %edx
c0101578:	59                   	pop    %ecx
c0101579:	50                   	push   %eax
c010157a:	8d 85 d3 fb ff ff    	lea    -0x42d(%ebp),%eax
c0101580:	50                   	push   %eax
c0101581:	89 85 b4 fb ff ff    	mov    %eax,-0x44c(%ebp)
c0101587:	e8 6e 47 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010158c:	8b 85 b4 fb ff ff    	mov    -0x44c(%ebp),%eax
c0101592:	83 c4 0c             	add    $0xc,%esp
c0101595:	56                   	push   %esi
c0101596:	50                   	push   %eax
c0101597:	57                   	push   %edi
c0101598:	e8 31 05 00 00       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c010159d:	8b 85 b4 fb ff ff    	mov    -0x44c(%ebp),%eax
c01015a3:	89 04 24             	mov    %eax,(%esp)
c01015a6:	e8 69 47 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01015ab:	89 34 24             	mov    %esi,(%esp)
c01015ae:	e8 61 47 00 00       	call   c0105d14 <_ZN6StringD1Ev>
        out.writeValue(ideno);
c01015b3:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c01015b9:	89 85 d8 fb ff ff    	mov    %eax,-0x428(%ebp)
c01015bf:	58                   	pop    %eax
c01015c0:	5a                   	pop    %edx
c01015c1:	56                   	push   %esi
c01015c2:	57                   	push   %edi
c01015c3:	e8 98 06 00 00       	call   c0101c60 <_ZN7OStream10writeValueERKj>
        out.write(": ");
c01015c8:	59                   	pop    %ecx
c01015c9:	58                   	pop    %eax
c01015ca:	8d 83 a8 40 fe ff    	lea    -0x1bf58(%ebx),%eax
c01015d0:	50                   	push   %eax
c01015d1:	56                   	push   %esi
c01015d2:	e8 23 47 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01015d7:	58                   	pop    %eax
c01015d8:	5a                   	pop    %edx
c01015d9:	56                   	push   %esi
c01015da:	57                   	push   %edi
c01015db:	e8 3c 06 00 00       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01015e0:	89 34 24             	mov    %esi,(%esp)
c01015e3:	e8 2c 47 00 00       	call   c0105d14 <_ZN6StringD1Ev>
        out.writeValue(ideDevs[ideno].size);
c01015e8:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c01015ee:	59                   	pop    %ecx
c01015ef:	8b 40 05             	mov    0x5(%eax),%eax
c01015f2:	89 85 d8 fb ff ff    	mov    %eax,-0x428(%ebp)
c01015f8:	58                   	pop    %eax
c01015f9:	56                   	push   %esi
c01015fa:	57                   	push   %edi
c01015fb:	e8 60 06 00 00       	call   c0101c60 <_ZN7OStream10writeValueERKj>
        out.write(", model: ");
c0101600:	58                   	pop    %eax
c0101601:	8d 83 0e 3a fe ff    	lea    -0x1c5f2(%ebx),%eax
c0101607:	5a                   	pop    %edx
c0101608:	50                   	push   %eax
c0101609:	56                   	push   %esi
c010160a:	e8 eb 46 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010160f:	59                   	pop    %ecx
c0101610:	58                   	pop    %eax
c0101611:	56                   	push   %esi
c0101612:	57                   	push   %edi
c0101613:	e8 04 06 00 00       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0101618:	89 34 24             	mov    %esi,(%esp)
c010161b:	e8 f4 46 00 00       	call   c0105d14 <_ZN6StringD1Ev>
        String temp((ccstring)(ideDevs[ideno].model)); 
c0101620:	58                   	pop    %eax
c0101621:	5a                   	pop    %edx
c0101622:	8b 95 b0 fb ff ff    	mov    -0x450(%ebp),%edx
c0101628:	52                   	push   %edx
c0101629:	56                   	push   %esi
c010162a:	e8 cb 46 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
        out.write(temp);
c010162f:	59                   	pop    %ecx
c0101630:	58                   	pop    %eax
c0101631:	56                   	push   %esi
c0101632:	57                   	push   %edi
c0101633:	e8 e4 05 00 00       	call   c0101c1c <_ZN7OStream5writeERK6String>
        String temp((ccstring)(ideDevs[ideno].model)); 
c0101638:	89 34 24             	mov    %esi,(%esp)
c010163b:	e8 d4 46 00 00       	call   c0105d14 <_ZN6StringD1Ev>
        OStream out("\nide", "blue");
c0101640:	89 3c 24             	mov    %edi,(%esp)
c0101643:	e8 64 05 00 00       	call   c0101bac <_ZN7OStreamD1Ev>
c0101648:	83 c4 10             	add    $0x10,%esp
c010164b:	ff 85 c0 fb ff ff    	incl   -0x440(%ebp)
c0101651:	83 85 c4 fb ff ff 32 	addl   $0x32,-0x43c(%ebp)
c0101658:	80 85 bf fb ff ff 10 	addb   $0x10,-0x441(%ebp)
    for (ideno = 0; ideno < MAX_IDE; ideno++) {
c010165f:	83 bd c0 fb ff ff 04 	cmpl   $0x4,-0x440(%ebp)
c0101666:	0f 85 46 fd ff ff    	jne    c01013b2 <_ZN3IDE4initEv+0x40>
    PIC::enableIRQ(IRQ_IDE1);
c010166c:	83 ec 0c             	sub    $0xc,%esp
c010166f:	6a 0e                	push   $0xe
c0101671:	e8 88 fb ff ff       	call   c01011fe <_ZN3PIC9enableIRQEj>
    PIC::enableIRQ(IRQ_IDE2);
c0101676:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c010167d:	e8 7c fb ff ff       	call   c01011fe <_ZN3PIC9enableIRQEj>
}
c0101682:	83 c4 10             	add    $0x10,%esp
c0101685:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101688:	5b                   	pop    %ebx
c0101689:	5e                   	pop    %esi
c010168a:	5f                   	pop    %edi
c010168b:	5d                   	pop    %ebp
c010168c:	c3                   	ret    
c010168d:	90                   	nop

c010168e <_ZN3IDE8readSecsEtjPvj>:

uint32_t IDE::readSecs(uint16_t ideno, uint32_t secno, void *dst, uint32_t nsecs) {
c010168e:	55                   	push   %ebp
c010168f:	89 e5                	mov    %esp,%ebp
c0101691:	57                   	push   %edi
c0101692:	56                   	push   %esi
c0101693:	53                   	push   %ebx
c0101694:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
c010169a:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
c010169e:	e8 2a f5 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c01016a3:	81 c3 7d 0d 02 00    	add    $0x20d7d,%ebx
    assert(nsecs <= MAX_NSECS && isValid(ideno));
c01016a9:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
uint32_t IDE::readSecs(uint16_t ideno, uint32_t secno, void *dst, uint32_t nsecs) {
c01016b0:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
    assert(nsecs <= MAX_NSECS && isValid(ideno));
c01016b6:	77 0f                	ja     c01016c7 <_ZN3IDE8readSecsEtjPvj+0x39>
c01016b8:	50                   	push   %eax
c01016b9:	e8 64 fc ff ff       	call   c0101322 <_ZN3IDE7isValidEj>
c01016be:	59                   	pop    %ecx
c01016bf:	84 c0                	test   %al,%al
c01016c1:	0f 85 92 00 00 00    	jne    c0101759 <_ZN3IDE8readSecsEtjPvj+0xcb>
c01016c7:	50                   	push   %eax
c01016c8:	50                   	push   %eax
c01016c9:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c01016cf:	50                   	push   %eax
c01016d0:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01016d6:	56                   	push   %esi
c01016d7:	e8 1e 46 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01016dc:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01016e2:	58                   	pop    %eax
c01016e3:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c01016e9:	5a                   	pop    %edx
c01016ea:	50                   	push   %eax
c01016eb:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c01016f1:	50                   	push   %eax
c01016f2:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c01016f8:	e8 fd 45 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01016fd:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0101703:	83 c4 0c             	add    $0xc,%esp
c0101706:	56                   	push   %esi
c0101707:	50                   	push   %eax
c0101708:	57                   	push   %edi
c0101709:	e8 c0 03 00 00       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c010170e:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0101714:	89 04 24             	mov    %eax,(%esp)
c0101717:	e8 f8 45 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010171c:	89 34 24             	mov    %esi,(%esp)
c010171f:	e8 f0 45 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0101724:	59                   	pop    %ecx
c0101725:	58                   	pop    %eax
c0101726:	8d 83 18 3a fe ff    	lea    -0x1c5e8(%ebx),%eax
c010172c:	50                   	push   %eax
c010172d:	56                   	push   %esi
c010172e:	e8 c7 45 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0101733:	58                   	pop    %eax
c0101734:	5a                   	pop    %edx
c0101735:	56                   	push   %esi
c0101736:	57                   	push   %edi
c0101737:	e8 e0 04 00 00       	call   c0101c1c <_ZN7OStream5writeERK6String>
c010173c:	89 34 24             	mov    %esi,(%esp)
c010173f:	e8 d0 45 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0101744:	89 3c 24             	mov    %edi,(%esp)
c0101747:	e8 1c 04 00 00       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010174c:	fa                   	cli    
    asm volatile ("hlt");
c010174d:	f4                   	hlt    
c010174e:	89 3c 24             	mov    %edi,(%esp)
c0101751:	e8 56 04 00 00       	call   c0101bac <_ZN7OStreamD1Ev>
c0101756:	83 c4 10             	add    $0x10,%esp
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101759:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101760:	77 11                	ja     c0101773 <_ZN3IDE8readSecsEtjPvj+0xe5>
c0101762:	8b 45 14             	mov    0x14(%ebp),%eax
c0101765:	03 45 0c             	add    0xc(%ebp),%eax
c0101768:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010176d:	0f 86 92 00 00 00    	jbe    c0101805 <_ZN3IDE8readSecsEtjPvj+0x177>
c0101773:	51                   	push   %ecx
c0101774:	51                   	push   %ecx
c0101775:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c010177b:	50                   	push   %eax
c010177c:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0101782:	56                   	push   %esi
c0101783:	e8 72 45 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0101788:	5f                   	pop    %edi
c0101789:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c010178f:	58                   	pop    %eax
c0101790:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0101796:	50                   	push   %eax
c0101797:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c010179d:	50                   	push   %eax
c010179e:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c01017a4:	e8 51 45 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01017a9:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01017af:	83 c4 0c             	add    $0xc,%esp
c01017b2:	56                   	push   %esi
c01017b3:	50                   	push   %eax
c01017b4:	57                   	push   %edi
c01017b5:	e8 14 03 00 00       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01017ba:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01017c0:	89 04 24             	mov    %eax,(%esp)
c01017c3:	e8 4c 45 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01017c8:	89 34 24             	mov    %esi,(%esp)
c01017cb:	e8 44 45 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01017d0:	58                   	pop    %eax
c01017d1:	8d 83 3d 3a fe ff    	lea    -0x1c5c3(%ebx),%eax
c01017d7:	5a                   	pop    %edx
c01017d8:	50                   	push   %eax
c01017d9:	56                   	push   %esi
c01017da:	e8 1b 45 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01017df:	59                   	pop    %ecx
c01017e0:	58                   	pop    %eax
c01017e1:	56                   	push   %esi
c01017e2:	57                   	push   %edi
c01017e3:	e8 34 04 00 00       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01017e8:	89 34 24             	mov    %esi,(%esp)
c01017eb:	e8 24 45 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01017f0:	89 3c 24             	mov    %edi,(%esp)
c01017f3:	e8 70 03 00 00       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01017f8:	fa                   	cli    
    asm volatile ("hlt");
c01017f9:	f4                   	hlt    
c01017fa:	89 3c 24             	mov    %edi,(%esp)
c01017fd:	e8 aa 03 00 00       	call   c0101bac <_ZN7OStreamD1Ev>
c0101802:	83 c4 10             	add    $0x10,%esp
    uint16_t iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101805:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c010180b:	c7 c0 98 5e 10 c0    	mov    $0xc0105e98,%eax
c0101811:	d1 fa                	sar    %edx
c0101813:	0f b7 1c 90          	movzwl (%eax,%edx,4),%ebx
c0101817:	0f b7 74 90 02       	movzwl 0x2(%eax,%edx,4),%esi

    waitReady(iobase, 0);
c010181c:	52                   	push   %edx
c010181d:	52                   	push   %edx
c010181e:	6a 00                	push   $0x0
c0101820:	53                   	push   %ebx
c0101821:	e8 26 fb ff ff       	call   c010134c <_ZN3IDE9waitReadyEtb>

    // generate interrupt
    outb(0, ioctrl + ISA_CTRL);
c0101826:	8d 56 02             	lea    0x2(%esi),%edx
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c0101829:	31 c0                	xor    %eax,%eax
c010182b:	ee                   	out    %al,(%dx)
    outb(nsecs, iobase + ISA_SECCNT);
c010182c:	8d 53 02             	lea    0x2(%ebx),%edx
c010182f:	8a 45 14             	mov    0x14(%ebp),%al
c0101832:	ee                   	out    %al,(%dx)
    outb(secno & 0xFF, iobase + ISA_SECTOR);
c0101833:	8d 53 03             	lea    0x3(%ebx),%edx
c0101836:	8a 45 0c             	mov    0xc(%ebp),%al
c0101839:	ee                   	out    %al,(%dx)
    outb((secno >> 8) & 0xFF, iobase + ISA_CYL_LO);
c010183a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010183d:	8d 53 04             	lea    0x4(%ebx),%edx
c0101840:	c1 e8 08             	shr    $0x8,%eax
c0101843:	ee                   	out    %al,(%dx)
    outb((secno >> 16) & 0xFF, iobase + ISA_CYL_HI);
c0101844:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101847:	8d 53 05             	lea    0x5(%ebx),%edx
c010184a:	c1 e8 10             	shr    $0x10,%eax
c010184d:	ee                   	out    %al,(%dx)
    outb(0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF), iobase + ISA_SDH);
c010184e:	8a 85 c4 fd ff ff    	mov    -0x23c(%ebp),%al
c0101854:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101857:	c0 e0 04             	shl    $0x4,%al
c010185a:	24 10                	and    $0x10,%al
c010185c:	c1 ea 18             	shr    $0x18,%edx
c010185f:	0c e0                	or     $0xe0,%al
c0101861:	80 e2 0f             	and    $0xf,%dl
c0101864:	08 d0                	or     %dl,%al
c0101866:	8d 53 06             	lea    0x6(%ebx),%edx
c0101869:	ee                   	out    %al,(%dx)
c010186a:	b0 20                	mov    $0x20,%al
    outb(IDE_CMD_READ, iobase + ISA_COMMAND);
c010186c:	8d 53 07             	lea    0x7(%ebx),%edx
c010186f:	ee                   	out    %al,(%dx)
c0101870:	83 c4 10             	add    $0x10,%esp

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101873:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101877:	74 2a                	je     c01018a3 <_ZN3IDE8readSecsEtjPvj+0x215>
        if ((ret = waitReady(iobase, true)) != 0) {
c0101879:	50                   	push   %eax
c010187a:	50                   	push   %eax
c010187b:	6a 01                	push   $0x1
c010187d:	53                   	push   %ebx
c010187e:	e8 c9 fa ff ff       	call   c010134c <_ZN3IDE9waitReadyEtb>
c0101883:	83 c4 10             	add    $0x10,%esp
c0101886:	85 c0                	test   %eax,%eax
c0101888:	75 1b                	jne    c01018a5 <_ZN3IDE8readSecsEtjPvj+0x217>
        : "memory", "cc");
c010188a:	8b 7d 10             	mov    0x10(%ebp),%edi
c010188d:	b9 80 00 00 00       	mov    $0x80,%ecx
c0101892:	89 da                	mov    %ebx,%edx
c0101894:	fc                   	cld    
c0101895:	f2 6d                	repnz insl (%dx),%es:(%edi)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101897:	ff 4d 14             	decl   0x14(%ebp)
c010189a:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01018a1:	eb d0                	jmp    c0101873 <_ZN3IDE8readSecsEtjPvj+0x1e5>
c01018a3:	31 c0                	xor    %eax,%eax
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

    return ret;
}
c01018a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01018a8:	5b                   	pop    %ebx
c01018a9:	5e                   	pop    %esi
c01018aa:	5f                   	pop    %edi
c01018ab:	5d                   	pop    %ebp
c01018ac:	c3                   	ret    
c01018ad:	90                   	nop

c01018ae <_ZN3IDE9writeSecsEtjPKvj>:

uint32_t IDE::writeSecs(uint16_t ideno, uint32_t secno, const void *src, uint32_t nsecs) {
c01018ae:	55                   	push   %ebp
c01018af:	89 e5                	mov    %esp,%ebp
c01018b1:	57                   	push   %edi
c01018b2:	56                   	push   %esi
c01018b3:	53                   	push   %ebx
c01018b4:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
c01018ba:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
c01018be:	e8 0a f3 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c01018c3:	81 c3 5d 0b 02 00    	add    $0x20b5d,%ebx
    assert(nsecs <= MAX_NSECS && isValid(ideno));
c01018c9:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
uint32_t IDE::writeSecs(uint16_t ideno, uint32_t secno, const void *src, uint32_t nsecs) {
c01018d0:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
    assert(nsecs <= MAX_NSECS && isValid(ideno));
c01018d6:	77 0f                	ja     c01018e7 <_ZN3IDE9writeSecsEtjPKvj+0x39>
c01018d8:	50                   	push   %eax
c01018d9:	e8 44 fa ff ff       	call   c0101322 <_ZN3IDE7isValidEj>
c01018de:	59                   	pop    %ecx
c01018df:	84 c0                	test   %al,%al
c01018e1:	0f 85 92 00 00 00    	jne    c0101979 <_ZN3IDE9writeSecsEtjPKvj+0xcb>
c01018e7:	50                   	push   %eax
c01018e8:	50                   	push   %eax
c01018e9:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c01018ef:	50                   	push   %eax
c01018f0:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01018f6:	56                   	push   %esi
c01018f7:	e8 fe 43 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01018fc:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0101902:	58                   	pop    %eax
c0101903:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0101909:	5a                   	pop    %edx
c010190a:	50                   	push   %eax
c010190b:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0101911:	50                   	push   %eax
c0101912:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c0101918:	e8 dd 43 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010191d:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0101923:	83 c4 0c             	add    $0xc,%esp
c0101926:	56                   	push   %esi
c0101927:	50                   	push   %eax
c0101928:	57                   	push   %edi
c0101929:	e8 a0 01 00 00       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c010192e:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0101934:	89 04 24             	mov    %eax,(%esp)
c0101937:	e8 d8 43 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010193c:	89 34 24             	mov    %esi,(%esp)
c010193f:	e8 d0 43 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0101944:	59                   	pop    %ecx
c0101945:	58                   	pop    %eax
c0101946:	8d 83 18 3a fe ff    	lea    -0x1c5e8(%ebx),%eax
c010194c:	50                   	push   %eax
c010194d:	56                   	push   %esi
c010194e:	e8 a7 43 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0101953:	58                   	pop    %eax
c0101954:	5a                   	pop    %edx
c0101955:	56                   	push   %esi
c0101956:	57                   	push   %edi
c0101957:	e8 c0 02 00 00       	call   c0101c1c <_ZN7OStream5writeERK6String>
c010195c:	89 34 24             	mov    %esi,(%esp)
c010195f:	e8 b0 43 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0101964:	89 3c 24             	mov    %edi,(%esp)
c0101967:	e8 fc 01 00 00       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010196c:	fa                   	cli    
    asm volatile ("hlt");
c010196d:	f4                   	hlt    
c010196e:	89 3c 24             	mov    %edi,(%esp)
c0101971:	e8 36 02 00 00       	call   c0101bac <_ZN7OStreamD1Ev>
c0101976:	83 c4 10             	add    $0x10,%esp
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101979:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101980:	77 11                	ja     c0101993 <_ZN3IDE9writeSecsEtjPKvj+0xe5>
c0101982:	8b 45 14             	mov    0x14(%ebp),%eax
c0101985:	03 45 0c             	add    0xc(%ebp),%eax
c0101988:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010198d:	0f 86 92 00 00 00    	jbe    c0101a25 <_ZN3IDE9writeSecsEtjPKvj+0x177>
c0101993:	51                   	push   %ecx
c0101994:	51                   	push   %ecx
c0101995:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c010199b:	50                   	push   %eax
c010199c:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01019a2:	56                   	push   %esi
c01019a3:	e8 52 43 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01019a8:	5f                   	pop    %edi
c01019a9:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01019af:	58                   	pop    %eax
c01019b0:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c01019b6:	50                   	push   %eax
c01019b7:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c01019bd:	50                   	push   %eax
c01019be:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c01019c4:	e8 31 43 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01019c9:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01019cf:	83 c4 0c             	add    $0xc,%esp
c01019d2:	56                   	push   %esi
c01019d3:	50                   	push   %eax
c01019d4:	57                   	push   %edi
c01019d5:	e8 f4 00 00 00       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01019da:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01019e0:	89 04 24             	mov    %eax,(%esp)
c01019e3:	e8 2c 43 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01019e8:	89 34 24             	mov    %esi,(%esp)
c01019eb:	e8 24 43 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01019f0:	58                   	pop    %eax
c01019f1:	8d 83 3d 3a fe ff    	lea    -0x1c5c3(%ebx),%eax
c01019f7:	5a                   	pop    %edx
c01019f8:	50                   	push   %eax
c01019f9:	56                   	push   %esi
c01019fa:	e8 fb 42 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01019ff:	59                   	pop    %ecx
c0101a00:	58                   	pop    %eax
c0101a01:	56                   	push   %esi
c0101a02:	57                   	push   %edi
c0101a03:	e8 14 02 00 00       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0101a08:	89 34 24             	mov    %esi,(%esp)
c0101a0b:	e8 04 43 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0101a10:	89 3c 24             	mov    %edi,(%esp)
c0101a13:	e8 50 01 00 00       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0101a18:	fa                   	cli    
    asm volatile ("hlt");
c0101a19:	f4                   	hlt    
c0101a1a:	89 3c 24             	mov    %edi,(%esp)
c0101a1d:	e8 8a 01 00 00       	call   c0101bac <_ZN7OStreamD1Ev>
c0101a22:	83 c4 10             	add    $0x10,%esp
    uint16_t iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101a25:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c0101a2b:	c7 c0 98 5e 10 c0    	mov    $0xc0105e98,%eax
c0101a31:	d1 fa                	sar    %edx
c0101a33:	0f b7 1c 90          	movzwl (%eax,%edx,4),%ebx
c0101a37:	0f b7 74 90 02       	movzwl 0x2(%eax,%edx,4),%esi

    waitReady(iobase);
c0101a3c:	52                   	push   %edx
c0101a3d:	52                   	push   %edx
c0101a3e:	6a 00                	push   $0x0
c0101a40:	53                   	push   %ebx
c0101a41:	e8 06 f9 ff ff       	call   c010134c <_ZN3IDE9waitReadyEtb>

    // generate interrupt
    outb(0, ioctrl + ISA_CTRL);
c0101a46:	8d 56 02             	lea    0x2(%esi),%edx
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c0101a49:	31 c0                	xor    %eax,%eax
c0101a4b:	ee                   	out    %al,(%dx)
    outb(nsecs, iobase + ISA_SECCNT);
c0101a4c:	8d 53 02             	lea    0x2(%ebx),%edx
c0101a4f:	8a 45 14             	mov    0x14(%ebp),%al
c0101a52:	ee                   	out    %al,(%dx)
    outb(secno & 0xFF, iobase + ISA_SECTOR);
c0101a53:	8d 53 03             	lea    0x3(%ebx),%edx
c0101a56:	8a 45 0c             	mov    0xc(%ebp),%al
c0101a59:	ee                   	out    %al,(%dx)
    outb((secno >> 8) & 0xFF, iobase + ISA_CYL_LO);
c0101a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a5d:	8d 53 04             	lea    0x4(%ebx),%edx
c0101a60:	c1 e8 08             	shr    $0x8,%eax
c0101a63:	ee                   	out    %al,(%dx)
    outb((secno >> 16) & 0xFF, iobase + ISA_CYL_HI);
c0101a64:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a67:	8d 53 05             	lea    0x5(%ebx),%edx
c0101a6a:	c1 e8 10             	shr    $0x10,%eax
c0101a6d:	ee                   	out    %al,(%dx)
    outb(0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF), iobase + ISA_SDH);
c0101a6e:	8a 85 c4 fd ff ff    	mov    -0x23c(%ebp),%al
c0101a74:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101a77:	c0 e0 04             	shl    $0x4,%al
c0101a7a:	24 10                	and    $0x10,%al
c0101a7c:	c1 ea 18             	shr    $0x18,%edx
c0101a7f:	0c e0                	or     $0xe0,%al
c0101a81:	80 e2 0f             	and    $0xf,%dl
c0101a84:	08 d0                	or     %dl,%al
c0101a86:	8d 53 06             	lea    0x6(%ebx),%edx
c0101a89:	ee                   	out    %al,(%dx)
c0101a8a:	b0 20                	mov    $0x20,%al
    outb(IDE_CMD_READ, iobase + ISA_COMMAND);
c0101a8c:	8d 53 07             	lea    0x7(%ebx),%edx
c0101a8f:	ee                   	out    %al,(%dx)
c0101a90:	83 c4 10             	add    $0x10,%esp

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101a93:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101a97:	74 2a                	je     c0101ac3 <_ZN3IDE9writeSecsEtjPKvj+0x215>
        if ((ret = waitReady(iobase, true)) != 0) {
c0101a99:	50                   	push   %eax
c0101a9a:	50                   	push   %eax
c0101a9b:	6a 01                	push   $0x1
c0101a9d:	53                   	push   %ebx
c0101a9e:	e8 a9 f8 ff ff       	call   c010134c <_ZN3IDE9waitReadyEtb>
c0101aa3:	83 c4 10             	add    $0x10,%esp
c0101aa6:	85 c0                	test   %eax,%eax
c0101aa8:	75 1b                	jne    c0101ac5 <_ZN3IDE9writeSecsEtjPKvj+0x217>
        : "memory", "cc");
c0101aaa:	8b 75 10             	mov    0x10(%ebp),%esi
c0101aad:	b9 80 00 00 00       	mov    $0x80,%ecx
c0101ab2:	89 da                	mov    %ebx,%edx
c0101ab4:	fc                   	cld    
c0101ab5:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101ab7:	ff 4d 14             	decl   0x14(%ebp)
c0101aba:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101ac1:	eb d0                	jmp    c0101a93 <_ZN3IDE9writeSecsEtjPKvj+0x1e5>
c0101ac3:	31 c0                	xor    %eax,%eax
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

    return ret;
}
c0101ac5:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101ac8:	5b                   	pop    %ebx
c0101ac9:	5e                   	pop    %esi
c0101aca:	5f                   	pop    %edi
c0101acb:	5d                   	pop    %ebp
c0101acc:	c3                   	ret    
c0101acd:	90                   	nop

c0101ace <_ZN7OStreamC1E6StringS0_>:
 */

#include <ostream.h>
#include <global.h>

OStream::OStream(String str, String col) {
c0101ace:	55                   	push   %ebp
c0101acf:	89 e5                	mov    %esp,%ebp
c0101ad1:	57                   	push   %edi
c0101ad2:	56                   	push   %esi
c0101ad3:	53                   	push   %ebx
c0101ad4:	83 ec 24             	sub    $0x24,%esp
c0101ad7:	e8 f1 f0 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0101adc:	81 c3 44 09 02 00    	add    $0x20944,%ebx
c0101ae2:	8b 75 08             	mov    0x8(%ebp),%esi
    kernel::console.setColor(col);
c0101ae5:	8d 7d e3             	lea    -0x1d(%ebp),%edi
OStream::OStream(String str, String col) {
c0101ae8:	8b 45 10             	mov    0x10(%ebp),%eax
c0101aeb:	c7 86 04 02 00 00 00 	movl   $0x200,0x204(%esi)
c0101af2:	02 00 00 
    kernel::console.setColor(col);
c0101af5:	8b 08                	mov    (%eax),%ecx
c0101af7:	8a 40 04             	mov    0x4(%eax),%al
c0101afa:	57                   	push   %edi
c0101afb:	ff b3 f0 ff ff ff    	pushl  -0x10(%ebx)
c0101b01:	89 4d e3             	mov    %ecx,-0x1d(%ebp)
c0101b04:	88 45 e7             	mov    %al,-0x19(%ebp)
c0101b07:	e8 bc f1 ff ff       	call   c0100cc8 <_ZN7Console8setColorE6String>
c0101b0c:	89 3c 24             	mov    %edi,(%esp)
c0101b0f:	e8 00 42 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    buffPointer = 0;
c0101b14:	c7 86 00 02 00 00 00 	movl   $0x0,0x200(%esi)
c0101b1b:	00 00 00 
c0101b1e:	83 c4 10             	add    $0x10,%esp
    for (; buffPointer < str.getLength(); buffPointer++) {
c0101b21:	8b be 00 02 00 00    	mov    0x200(%esi),%edi
c0101b27:	83 ec 0c             	sub    $0xc,%esp
c0101b2a:	ff 75 0c             	pushl  0xc(%ebp)
c0101b2d:	e8 28 42 00 00       	call   c0105d5a <_ZNK6String9getLengthEv>
c0101b32:	83 c4 10             	add    $0x10,%esp
c0101b35:	0f b6 c0             	movzbl %al,%eax
c0101b38:	39 c7                	cmp    %eax,%edi
c0101b3a:	73 24                	jae    c0101b60 <_ZN7OStreamC1E6StringS0_+0x92>
        buffer[buffPointer] = str[buffPointer];
c0101b3c:	50                   	push   %eax
c0101b3d:	50                   	push   %eax
c0101b3e:	ff b6 00 02 00 00    	pushl  0x200(%esi)
c0101b44:	ff 75 0c             	pushl  0xc(%ebp)
c0101b47:	e8 54 42 00 00       	call   c0105da0 <_ZN6StringixEj>
c0101b4c:	8b 8e 00 02 00 00    	mov    0x200(%esi),%ecx
c0101b52:	8a 00                	mov    (%eax),%al
c0101b54:	88 04 0e             	mov    %al,(%esi,%ecx,1)
    for (; buffPointer < str.getLength(); buffPointer++) {
c0101b57:	41                   	inc    %ecx
c0101b58:	89 8e 00 02 00 00    	mov    %ecx,0x200(%esi)
c0101b5e:	eb be                	jmp    c0101b1e <_ZN7OStreamC1E6StringS0_+0x50>
    }
}
c0101b60:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101b63:	5b                   	pop    %ebx
c0101b64:	5e                   	pop    %esi
c0101b65:	5f                   	pop    %edi
c0101b66:	5d                   	pop    %ebp
c0101b67:	c3                   	ret    

c0101b68 <_ZN7OStream5flushEv>:

OStream::~OStream() {
    flush();
}

void OStream::flush() {
c0101b68:	55                   	push   %ebp
c0101b69:	89 e5                	mov    %esp,%ebp
c0101b6b:	56                   	push   %esi
c0101b6c:	53                   	push   %ebx
c0101b6d:	83 ec 14             	sub    $0x14,%esp
c0101b70:	8b 75 08             	mov    0x8(%ebp),%esi
c0101b73:	e8 55 f0 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0101b78:	81 c3 a8 08 02 00    	add    $0x208a8,%ebx
    kernel::console.wirte(buffer, buffPointer);
c0101b7e:	8b 86 00 02 00 00    	mov    0x200(%esi),%eax
c0101b84:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101b88:	8d 45 f6             	lea    -0xa(%ebp),%eax
c0101b8b:	50                   	push   %eax
c0101b8c:	56                   	push   %esi
c0101b8d:	ff b3 f0 ff ff ff    	pushl  -0x10(%ebx)
c0101b93:	e8 fc f4 ff ff       	call   c0101094 <_ZN7Console5wirteEPcRKt>
    buffPointer = 0;
}
c0101b98:	83 c4 10             	add    $0x10,%esp
    buffPointer = 0;
c0101b9b:	c7 86 00 02 00 00 00 	movl   $0x0,0x200(%esi)
c0101ba2:	00 00 00 
}
c0101ba5:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101ba8:	5b                   	pop    %ebx
c0101ba9:	5e                   	pop    %esi
c0101baa:	5d                   	pop    %ebp
c0101bab:	c3                   	ret    

c0101bac <_ZN7OStreamD1Ev>:
OStream::~OStream() {
c0101bac:	55                   	push   %ebp
c0101bad:	89 e5                	mov    %esp,%ebp
}
c0101baf:	5d                   	pop    %ebp
    flush();
c0101bb0:	eb b6                	jmp    c0101b68 <_ZN7OStream5flushEv>

c0101bb2 <_ZN7OStream5writeERKc>:

void OStream::write(const char &c) {
c0101bb2:	55                   	push   %ebp
c0101bb3:	89 e5                	mov    %esp,%ebp
c0101bb5:	53                   	push   %ebx
c0101bb6:	50                   	push   %eax
c0101bb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (buffPointer + 1 > BUFFER_MAX) {
c0101bba:	8b 83 00 02 00 00    	mov    0x200(%ebx),%eax
c0101bc0:	40                   	inc    %eax
c0101bc1:	3b 83 04 02 00 00    	cmp    0x204(%ebx),%eax
c0101bc7:	76 0c                	jbe    c0101bd5 <_ZN7OStream5writeERKc+0x23>
        flush();
c0101bc9:	83 ec 0c             	sub    $0xc,%esp
c0101bcc:	53                   	push   %ebx
c0101bcd:	e8 96 ff ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c0101bd2:	83 c4 10             	add    $0x10,%esp
    }
    buffer[buffPointer++] = c;
c0101bd5:	8b 83 00 02 00 00    	mov    0x200(%ebx),%eax
c0101bdb:	8d 50 01             	lea    0x1(%eax),%edx
c0101bde:	89 93 00 02 00 00    	mov    %edx,0x200(%ebx)
c0101be4:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101be7:	8a 12                	mov    (%edx),%dl
c0101be9:	88 14 03             	mov    %dl,(%ebx,%eax,1)
}
c0101bec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101bef:	c9                   	leave  
c0101bf0:	c3                   	ret    
c0101bf1:	90                   	nop

c0101bf2 <_ZN7OStream5writeEPKcRKj>:

void OStream::write(const char *arr, const uint32_t &len) {
c0101bf2:	55                   	push   %ebp
c0101bf3:	89 e5                	mov    %esp,%ebp
c0101bf5:	53                   	push   %ebx
    for (uint32_t i = 0; i < len; i++) {
c0101bf6:	31 db                	xor    %ebx,%ebx
void OStream::write(const char *arr, const uint32_t &len) {
c0101bf8:	52                   	push   %edx
    for (uint32_t i = 0; i < len; i++) {
c0101bf9:	8b 45 10             	mov    0x10(%ebp),%eax
c0101bfc:	39 18                	cmp    %ebx,(%eax)
c0101bfe:	76 16                	jbe    c0101c16 <_ZN7OStream5writeEPKcRKj+0x24>
        write(arr[i]);
c0101c00:	50                   	push   %eax
c0101c01:	50                   	push   %eax
c0101c02:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101c05:	01 d8                	add    %ebx,%eax
    for (uint32_t i = 0; i < len; i++) {
c0101c07:	43                   	inc    %ebx
        write(arr[i]);
c0101c08:	50                   	push   %eax
c0101c09:	ff 75 08             	pushl  0x8(%ebp)
c0101c0c:	e8 a1 ff ff ff       	call   c0101bb2 <_ZN7OStream5writeERKc>
    for (uint32_t i = 0; i < len; i++) {
c0101c11:	83 c4 10             	add    $0x10,%esp
c0101c14:	eb e3                	jmp    c0101bf9 <_ZN7OStream5writeEPKcRKj+0x7>
    }
}
c0101c16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101c19:	c9                   	leave  
c0101c1a:	c3                   	ret    
c0101c1b:	90                   	nop

c0101c1c <_ZN7OStream5writeERK6String>:

void OStream::write(const String &str) {
c0101c1c:	55                   	push   %ebp
c0101c1d:	89 e5                	mov    %esp,%ebp
c0101c1f:	56                   	push   %esi
c0101c20:	53                   	push   %ebx
c0101c21:	83 ec 1c             	sub    $0x1c,%esp
c0101c24:	e8 a4 ef ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0101c29:	81 c3 f7 07 02 00    	add    $0x207f7,%ebx
c0101c2f:	8b 75 0c             	mov    0xc(%ebp),%esi
    write(str.cStr(), str.getLength());
c0101c32:	56                   	push   %esi
c0101c33:	e8 22 41 00 00       	call   c0105d5a <_ZNK6String9getLengthEv>
c0101c38:	89 34 24             	mov    %esi,(%esp)
c0101c3b:	0f b6 c0             	movzbl %al,%eax
c0101c3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101c41:	e8 0a 41 00 00       	call   c0105d50 <_ZNK6String4cStrEv>
c0101c46:	83 c4 0c             	add    $0xc,%esp
c0101c49:	8d 55 f4             	lea    -0xc(%ebp),%edx
c0101c4c:	52                   	push   %edx
c0101c4d:	50                   	push   %eax
c0101c4e:	ff 75 08             	pushl  0x8(%ebp)
c0101c51:	e8 9c ff ff ff       	call   c0101bf2 <_ZN7OStream5writeEPKcRKj>
}
c0101c56:	83 c4 10             	add    $0x10,%esp
c0101c59:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101c5c:	5b                   	pop    %ebx
c0101c5d:	5e                   	pop    %esi
c0101c5e:	5d                   	pop    %ebp
c0101c5f:	c3                   	ret    

c0101c60 <_ZN7OStream10writeValueERKj>:

void OStream::writeValue(const uint32_t &val) {
c0101c60:	55                   	push   %ebp
c0101c61:	89 e5                	mov    %esp,%ebp
c0101c63:	57                   	push   %edi
c0101c64:	56                   	push   %esi
c0101c65:	53                   	push   %ebx
c0101c66:	83 ec 3c             	sub    $0x3c,%esp
    if (val < 10) {
c0101c69:	8b 45 0c             	mov    0xc(%ebp),%eax
void OStream::writeValue(const uint32_t &val) {
c0101c6c:	8b 75 08             	mov    0x8(%ebp),%esi
    if (val < 10) {
c0101c6f:	8b 00                	mov    (%eax),%eax
c0101c71:	83 f8 09             	cmp    $0x9,%eax
c0101c74:	77 16                	ja     c0101c8c <_ZN7OStream10writeValueERKj+0x2c>
        write(val + '0');
c0101c76:	04 30                	add    $0x30,%al
c0101c78:	52                   	push   %edx
c0101c79:	52                   	push   %edx
c0101c7a:	88 45 c5             	mov    %al,-0x3b(%ebp)
c0101c7d:	8d 45 c5             	lea    -0x3b(%ebp),%eax
c0101c80:	50                   	push   %eax
c0101c81:	56                   	push   %esi
c0101c82:	e8 2b ff ff ff       	call   c0101bb2 <_ZN7OStream5writeERKc>
c0101c87:	83 c4 10             	add    $0x10,%esp
c0101c8a:	eb 30                	jmp    c0101cbc <_ZN7OStream10writeValueERKj+0x5c>
c0101c8c:	31 db                	xor    %ebx,%ebx
c0101c8e:	8d 7d c4             	lea    -0x3c(%ebp),%edi
    } else {
        uint8_t s[35];
        uint32_t temp = val, pos = 0;
        while (temp) {
            s[pos++] = temp % 10;
c0101c91:	31 d2                	xor    %edx,%edx
c0101c93:	b9 0a 00 00 00       	mov    $0xa,%ecx
c0101c98:	f7 f1                	div    %ecx
c0101c9a:	43                   	inc    %ebx
        while (temp) {
c0101c9b:	85 c0                	test   %eax,%eax
            s[pos++] = temp % 10;
c0101c9d:	88 14 1f             	mov    %dl,(%edi,%ebx,1)
        while (temp) {
c0101ca0:	75 ef                	jne    c0101c91 <_ZN7OStream10writeValueERKj+0x31>
            temp /= 10;
        }
        while (pos) {
            write(s[--pos] + '0');
c0101ca2:	4b                   	dec    %ebx
c0101ca3:	8a 44 1d c5          	mov    -0x3b(%ebp,%ebx,1),%al
c0101ca7:	04 30                	add    $0x30,%al
c0101ca9:	88 45 c4             	mov    %al,-0x3c(%ebp)
c0101cac:	50                   	push   %eax
c0101cad:	50                   	push   %eax
c0101cae:	57                   	push   %edi
c0101caf:	56                   	push   %esi
c0101cb0:	e8 fd fe ff ff       	call   c0101bb2 <_ZN7OStream5writeERKc>
        while (pos) {
c0101cb5:	83 c4 10             	add    $0x10,%esp
c0101cb8:	85 db                	test   %ebx,%ebx
c0101cba:	75 e6                	jne    c0101ca2 <_ZN7OStream10writeValueERKj+0x42>
        }
    }
c0101cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101cbf:	5b                   	pop    %ebx
c0101cc0:	5e                   	pop    %esi
c0101cc1:	5f                   	pop    %edi
c0101cc2:	5d                   	pop    %ebp
c0101cc3:	c3                   	ret    

c0101cc4 <_Znwj>:
    IDE ide;

    VMM vmm;
};

void *operator new(uint32_t size) {
c0101cc4:	55                   	push   %ebp
c0101cc5:	89 e5                	mov    %esp,%ebp
c0101cc7:	53                   	push   %ebx
c0101cc8:	e8 00 ef ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0101ccd:	81 c3 53 07 02 00    	add    $0x20753,%ebx
c0101cd3:	83 ec 0c             	sub    $0xc,%esp
    return kernel::pmm.kmalloc(size);
c0101cd6:	ff 75 08             	pushl  0x8(%ebp)
c0101cd9:	8d 83 00 2c 00 00    	lea    0x2c00(%ebx),%eax
c0101cdf:	50                   	push   %eax
c0101ce0:	e8 fb 0c 00 00       	call   c01029e0 <_ZN5PhyMM7kmallocEj>
}
c0101ce5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101ce8:	c9                   	leave  
c0101ce9:	c3                   	ret    

c0101cea <_Znaj>:
c0101cea:	55                   	push   %ebp
c0101ceb:	89 e5                	mov    %esp,%ebp
c0101ced:	5d                   	pop    %ebp
c0101cee:	eb d4                	jmp    c0101cc4 <_Znwj>

c0101cf0 <_ZnwjPv>:

void * operator new[](uint32_t size) {
    return kernel::pmm.kmalloc(size);
}

void * operator new(uint32_t size, void *ptr) {
c0101cf0:	55                   	push   %ebp
c0101cf1:	89 e5                	mov    %esp,%ebp
    return ptr;
}
c0101cf3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cf6:	5d                   	pop    %ebp
c0101cf7:	c3                   	ret    

c0101cf8 <_ZnajPv>:
c0101cf8:	55                   	push   %ebp
c0101cf9:	89 e5                	mov    %esp,%ebp
c0101cfb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cfe:	5d                   	pop    %ebp
c0101cff:	c3                   	ret    

c0101d00 <_ZdlPv>:
c0101d00:	55                   	push   %ebp
c0101d01:	89 e5                	mov    %esp,%ebp
c0101d03:	53                   	push   %ebx
c0101d04:	e8 c4 ee ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0101d09:	81 c3 17 07 02 00    	add    $0x20717,%ebx
c0101d0f:	83 ec 08             	sub    $0x8,%esp
c0101d12:	68 00 10 00 00       	push   $0x1000
c0101d17:	ff 75 08             	pushl  0x8(%ebp)
c0101d1a:	8d 83 00 2c 00 00    	lea    0x2c00(%ebx),%eax
c0101d20:	50                   	push   %eax
c0101d21:	e8 c2 0e 00 00       	call   c0102be8 <_ZN5PhyMM5kfreeEPvj>
c0101d26:	83 c4 10             	add    $0x10,%esp
c0101d29:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101d2c:	c9                   	leave  
c0101d2d:	c3                   	ret    

c0101d2e <_ZdaPv>:
c0101d2e:	55                   	push   %ebp
c0101d2f:	89 e5                	mov    %esp,%ebp
c0101d31:	5d                   	pop    %ebp
c0101d32:	eb cc                	jmp    c0101d00 <_ZdlPv>

c0101d34 <_ZN7ConsoleD1Ev>:
#include <vdieomemory.h>
#include <string.h>

#define COLOR_NUM       4

class Console : public VideoMemory {
c0101d34:	55                   	push   %ebp
c0101d35:	89 e5                	mov    %esp,%ebp
c0101d37:	57                   	push   %edi
c0101d38:	56                   	push   %esi
c0101d39:	53                   	push   %ebx
c0101d3a:	83 ec 0c             	sub    $0xc,%esp
c0101d3d:	e8 8b ee ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0101d42:	81 c3 de 06 02 00    	add    $0x206de,%ebx
c0101d48:	8b 75 08             	mov    0x8(%ebp),%esi
c0101d4b:	8d 7e 06             	lea    0x6(%esi),%edi
c0101d4e:	83 c6 1a             	add    $0x1a,%esi
c0101d51:	39 f7                	cmp    %esi,%edi
c0101d53:	74 11                	je     c0101d66 <_ZN7ConsoleD1Ev+0x32>
c0101d55:	83 ec 0c             	sub    $0xc,%esp
c0101d58:	83 ee 05             	sub    $0x5,%esi
c0101d5b:	56                   	push   %esi
c0101d5c:	e8 b3 3f 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0101d61:	83 c4 10             	add    $0x10,%esp
c0101d64:	eb eb                	jmp    c0101d51 <_ZN7ConsoleD1Ev+0x1d>
c0101d66:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101d69:	5b                   	pop    %ebx
c0101d6a:	5e                   	pop    %esi
c0101d6b:	5f                   	pop    %edi
c0101d6c:	5d                   	pop    %ebp
c0101d6d:	c3                   	ret    

c0101d6e <_ZN5PhyMMD1Ev>:
#include <list.hpp>
#include <flags.h>

/*      physical Memory management      */

class PhyMM : public MMU {
c0101d6e:	55                   	push   %ebp
c0101d6f:	89 e5                	mov    %esp,%ebp
c0101d71:	53                   	push   %ebx
c0101d72:	e8 56 ee ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0101d77:	81 c3 a9 06 02 00    	add    $0x206a9,%ebx
c0101d7d:	83 ec 10             	sub    $0x10,%esp
c0101d80:	8b 45 08             	mov    0x8(%ebp),%eax
#include <defs.h>
#include <mmu.h>
#include <list.hpp>
#include <string.h>

class PmmManager {
c0101d83:	83 c0 24             	add    $0x24,%eax
c0101d86:	8d 93 14 00 00 00    	lea    0x14(%ebx),%edx
c0101d8c:	89 50 fc             	mov    %edx,-0x4(%eax)
c0101d8f:	50                   	push   %eax
c0101d90:	e8 7f 3f 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0101d95:	83 c4 10             	add    $0x10,%esp
c0101d98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101d9b:	c9                   	leave  
c0101d9c:	c3                   	ret    

c0101d9d <_GLOBAL__sub_I__ZN6kernel7consoleE>:
    kernel::pmm.kfree(ptr, PGSIZE);
}
 
void operator delete[](void *ptr) {
    kernel::pmm.kfree(ptr, PGSIZE);
c0101d9d:	55                   	push   %ebp
c0101d9e:	89 e5                	mov    %esp,%ebp
c0101da0:	57                   	push   %edi
c0101da1:	56                   	push   %esi
c0101da2:	53                   	push   %ebx
c0101da3:	e8 25 ee ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0101da8:	81 c3 78 06 02 00    	add    $0x20678,%ebx
c0101dae:	83 ec 18             	sub    $0x18,%esp
    Console console;
c0101db1:	8d b3 48 2c 00 00    	lea    0x2c48(%ebx),%esi
c0101db7:	56                   	push   %esi
c0101db8:	e8 15 ee ff ff       	call   c0100bd2 <_ZN7ConsoleC1Ev>
c0101dbd:	8d bb 20 36 00 00    	lea    0x3620(%ebx),%edi
c0101dc3:	83 c4 0c             	add    $0xc,%esp
c0101dc6:	57                   	push   %edi
c0101dc7:	56                   	push   %esi
c0101dc8:	8d 83 14 f9 fd ff    	lea    -0x206ec(%ebx),%eax
c0101dce:	50                   	push   %eax
    PhyMM pmm;
c0101dcf:	8d b3 00 2c 00 00    	lea    0x2c00(%ebx),%esi
    Console console;
c0101dd5:	e8 38 3e 00 00       	call   c0105c12 <__cxa_atexit>
    PhyMM pmm;
c0101dda:	89 34 24             	mov    %esi,(%esp)
c0101ddd:	e8 6e 00 00 00       	call   c0101e50 <_ZN5PhyMMC1Ev>
c0101de2:	83 c4 0c             	add    $0xc,%esp
c0101de5:	57                   	push   %edi
c0101de6:	56                   	push   %esi
c0101de7:	8d 83 4e f9 fd ff    	lea    -0x206b2(%ebx),%eax
c0101ded:	50                   	push   %eax
c0101dee:	e8 1f 3e 00 00       	call   c0105c12 <__cxa_atexit>
    Interrupt interrupt;
c0101df3:	8d 83 f5 2b 00 00    	lea    0x2bf5(%ebx),%eax
c0101df9:	89 04 24             	mov    %eax,(%esp)
c0101dfc:	e8 cb f2 ff ff       	call   c01010cc <_ZN9InterruptC1Ev>
c0101e01:	83 c4 10             	add    $0x10,%esp

#define VM_READ                 0x00000001
#define VM_WRITE                0x00000002
#define VM_EXEC                 0x00000004

class VMM {
c0101e04:	c7 83 e0 2b 00 00 00 	movl   $0x0,0x2be0(%ebx)
c0101e0b:	00 00 00 
        struct LHeadNode {
            DLNode *first, *last;
            uint32_t eNum;
        }__attribute__((packed));

        class NodeIterator {
c0101e0e:	c7 83 e4 2b 00 00 00 	movl   $0x0,0x2be4(%ebx)
c0101e15:	00 00 00 
        LHeadNode headNode;
};

template <typename Object>
List<Object>::List() {
    headNode.first = nullptr;
c0101e18:	c7 83 e8 2b 00 00 00 	movl   $0x0,0x2be8(%ebx)
c0101e1f:	00 00 00 
    headNode.last = nullptr;
c0101e22:	c7 83 ec 2b 00 00 00 	movl   $0x0,0x2bec(%ebx)
c0101e29:	00 00 00 
    headNode.eNum = 0;
c0101e2c:	c7 83 f0 2b 00 00 00 	movl   $0x0,0x2bf0(%ebx)
c0101e33:	00 00 00 
c0101e36:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101e39:	5b                   	pop    %ebx
c0101e3a:	5e                   	pop    %esi
c0101e3b:	5f                   	pop    %edi
c0101e3c:	5d                   	pop    %ebp
c0101e3d:	c3                   	ret    

c0101e3e <_ZL11__intr_savev>:

#include <x86.h>
#include <flags.h>

static inline bool
__intr_save(void) {
c0101e3e:	55                   	push   %ebp
c0101e3f:	89 e5                	mov    %esp,%ebp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0101e41:	9c                   	pushf  
c0101e42:	5a                   	pop    %edx
c0101e43:	31 c0                	xor    %eax,%eax
    if (readEflags() & FL_IF) {
c0101e45:	0f ba e2 09          	bt     $0x9,%edx
c0101e49:	73 03                	jae    c0101e4e <_ZL11__intr_savev+0x10>
    asm volatile ("cli");
c0101e4b:	fa                   	cli    
        cli();                  // clear interrupt
        return 1;
c0101e4c:	b0 01                	mov    $0x1,%al
    }
    return 0;
}
c0101e4e:	5d                   	pop    %ebp
c0101e4f:	c3                   	ret    

c0101e50 <_ZN5PhyMMC1Ev>:
#include <sync.h>
#include <swap.h>
#include <ostream.h>
#include <utils.hpp>

PhyMM::PhyMM() {
c0101e50:	55                   	push   %ebp
c0101e51:	89 e5                	mov    %esp,%ebp
c0101e53:	56                   	push   %esi
c0101e54:	8b 75 08             	mov    0x8(%ebp),%esi
c0101e57:	53                   	push   %ebx
c0101e58:	e8 70 ed ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0101e5d:	81 c3 c3 05 02 00    	add    $0x205c3,%ebx
c0101e63:	83 ec 0c             	sub    $0xc,%esp
c0101e66:	56                   	push   %esi
c0101e67:	e8 36 39 00 00       	call   c01057a2 <_ZN3MMUC1Ev>
c0101e6c:	8d 83 14 00 00 00    	lea    0x14(%ebx),%eax
c0101e72:	89 46 20             	mov    %eax,0x20(%esi)
c0101e75:	58                   	pop    %eax
c0101e76:	8d 83 80 3a fe ff    	lea    -0x1c580(%ebx),%eax
c0101e7c:	5a                   	pop    %edx
c0101e7d:	50                   	push   %eax
c0101e7e:	8d 46 24             	lea    0x24(%esi),%eax
c0101e81:	50                   	push   %eax
c0101e82:	e8 73 3e 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
#include <PmmManager.h>
#include <list.hpp>

// First-Fit Memory Allocation (FFMA) Algorithm

class FFMA : public PmmManager{
c0101e87:	c7 c0 58 24 12 c0    	mov    $0xc0122458,%eax
    return 0;
}


uptr32_t PhyMM::vToPhyAD(uptr32_t kvAd) {
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c0101e8d:	83 c4 10             	add    $0x10,%esp
        class NodeIterator {
c0101e90:	c7 46 29 00 00 00 00 	movl   $0x0,0x29(%esi)
    headNode.first = nullptr;
c0101e97:	c7 46 2d 00 00 00 00 	movl   $0x0,0x2d(%esi)
    headNode.last = nullptr;
c0101e9e:	c7 46 31 00 00 00 00 	movl   $0x0,0x31(%esi)
c0101ea5:	83 c0 08             	add    $0x8,%eax
c0101ea8:	89 46 20             	mov    %eax,0x20(%esi)
    bootPDT = &__boot_pgdir;
c0101eab:	c7 c0 00 30 12 c0    	mov    $0xc0123000,%eax
    headNode.eNum = 0;
c0101eb1:	c7 46 35 00 00 00 00 	movl   $0x0,0x35(%esi)
c0101eb8:	c7 46 39 00 00 00 00 	movl   $0x0,0x39(%esi)
c0101ebf:	89 46 18             	mov    %eax,0x18(%esi)
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c0101ec2:	05 00 00 00 40       	add    $0x40000000,%eax
c0101ec7:	3d 00 00 00 38       	cmp    $0x38000000,%eax
c0101ecc:	76 02                	jbe    c0101ed0 <_ZN5PhyMMC1Ev+0x80>
        return kvAd - KERNEL_BASE;
    }
    return 0;
c0101ece:	31 c0                	xor    %eax,%eax
    bootCR3 = vToPhyAD((uptr32_t)bootPDT);
c0101ed0:	c7 c2 28 5a 12 c0    	mov    $0xc0125a28,%edx
c0101ed6:	89 02                	mov    %eax,(%edx)
    stack = bootstack;
c0101ed8:	c7 c0 00 00 12 c0    	mov    $0xc0120000,%eax
c0101ede:	89 46 10             	mov    %eax,0x10(%esi)
    stackTop = bootstacktop;
c0101ee1:	c7 c0 00 20 12 c0    	mov    $0xc0122000,%eax
c0101ee7:	89 46 14             	mov    %eax,0x14(%esi)
}
c0101eea:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101eed:	5b                   	pop    %ebx
c0101eee:	5e                   	pop    %esi
c0101eef:	5d                   	pop    %ebp
c0101ef0:	c3                   	ret    
c0101ef1:	90                   	nop

c0101ef2 <_ZN5PhyMM8initPageEv>:
void PhyMM::initPage() {
c0101ef2:	55                   	push   %ebp
c0101ef3:	89 e5                	mov    %esp,%ebp
c0101ef5:	57                   	push   %edi
c0101ef6:	56                   	push   %esi
c0101ef7:	53                   	push   %ebx
c0101ef8:	e8 d0 ec ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0101efd:	81 c3 23 05 02 00    	add    $0x20523,%ebx
c0101f03:	81 ec 64 02 00 00    	sub    $0x264,%esp
    OStream out("\nMemmory Map [E820Map] begin...\n", "blue");
c0101f09:	8d b5 d8 fd ff ff    	lea    -0x228(%ebp),%esi
c0101f0f:	8d 83 96 39 fe ff    	lea    -0x1c66a(%ebx),%eax
c0101f15:	50                   	push   %eax
c0101f16:	56                   	push   %esi
c0101f17:	e8 de 3d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0101f1c:	8d 83 8f 3a fe ff    	lea    -0x1c571(%ebx),%eax
c0101f22:	59                   	pop    %ecx
c0101f23:	5f                   	pop    %edi
c0101f24:	8d bd d3 fd ff ff    	lea    -0x22d(%ebp),%edi
c0101f2a:	50                   	push   %eax
c0101f2b:	57                   	push   %edi
c0101f2c:	e8 c9 3d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0101f31:	83 c4 0c             	add    $0xc,%esp
c0101f34:	56                   	push   %esi
c0101f35:	57                   	push   %edi
c0101f36:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c0101f3c:	50                   	push   %eax
c0101f3d:	e8 8c fb ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0101f42:	89 3c 24             	mov    %edi,(%esp)
c0101f45:	e8 ca 3d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0101f4a:	89 34 24             	mov    %esi,(%esp)
c0101f4d:	e8 c2 3d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0101f52:	83 c4 10             	add    $0x10,%esp
    uint64_t maxpa = 0;                                                             // size of all mem-block
c0101f55:	31 c9                	xor    %ecx,%ecx
    for (uint32_t i = 0; i < memMap->numARDS; i++) {                               // scan all of free memory block
c0101f57:	c7 85 b0 fd ff ff 00 	movl   $0x0,-0x250(%ebp)
c0101f5e:	00 00 00 
    uint64_t maxpa = 0;                                                             // size of all mem-block
c0101f61:	c7 85 b4 fd ff ff 00 	movl   $0x0,-0x24c(%ebp)
c0101f68:	00 00 00 
    for (uint32_t i = 0; i < memMap->numARDS; i++) {                               // scan all of free memory block
c0101f6b:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c0101f71:	39 05 00 80 00 c0    	cmp    %eax,0xc0008000
c0101f77:	0f 86 e0 01 00 00    	jbe    c010215d <_ZN5PhyMM8initPageEv+0x26b>
c0101f7d:	6b c0 14             	imul   $0x14,%eax,%eax
c0101f80:	89 8d a4 fd ff ff    	mov    %ecx,-0x25c(%ebp)
        uint64_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c0101f86:	8b b0 04 80 00 c0    	mov    -0x3fff7ffc(%eax),%esi
c0101f8c:	8d 90 00 80 00 c0    	lea    -0x3fff8000(%eax),%edx
c0101f92:	8b b8 08 80 00 c0    	mov    -0x3fff7ff8(%eax),%edi
c0101f98:	89 85 a8 fd ff ff    	mov    %eax,-0x258(%ebp)
c0101f9e:	89 95 ac fd ff ff    	mov    %edx,-0x254(%ebp)
c0101fa4:	89 b5 c0 fd ff ff    	mov    %esi,-0x240(%ebp)
c0101faa:	03 b0 0c 80 00 c0    	add    -0x3fff7ff4(%eax),%esi
c0101fb0:	89 bd c4 fd ff ff    	mov    %edi,-0x23c(%ebp)
c0101fb6:	13 b8 10 80 00 c0    	adc    -0x3fff7ff0(%eax),%edi
        out.write(" >> size = ");
c0101fbc:	50                   	push   %eax
c0101fbd:	50                   	push   %eax
        uint64_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c0101fbe:	89 b5 b8 fd ff ff    	mov    %esi,-0x248(%ebp)
        out.write(" >> size = ");
c0101fc4:	8d b3 b0 3a fe ff    	lea    -0x1c550(%ebx),%esi
c0101fca:	56                   	push   %esi
c0101fcb:	8d b5 d8 fd ff ff    	lea    -0x228(%ebp),%esi
c0101fd1:	56                   	push   %esi
        uint64_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c0101fd2:	89 bd bc fd ff ff    	mov    %edi,-0x244(%ebp)
        out.write(" >> size = ");
c0101fd8:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0101fde:	e8 17 3d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0101fe3:	58                   	pop    %eax
c0101fe4:	5a                   	pop    %edx
c0101fe5:	56                   	push   %esi
c0101fe6:	57                   	push   %edi
c0101fe7:	e8 30 fc ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0101fec:	89 34 24             	mov    %esi,(%esp)
c0101fef:	e8 20 3d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
        out.writeValue(memMap->ARDS[i].size);
c0101ff4:	8b 95 ac fd ff ff    	mov    -0x254(%ebp),%edx
c0101ffa:	59                   	pop    %ecx
c0101ffb:	58                   	pop    %eax
c0101ffc:	8b 52 0c             	mov    0xc(%edx),%edx
c0101fff:	56                   	push   %esi
c0102000:	57                   	push   %edi
c0102001:	89 95 d8 fd ff ff    	mov    %edx,-0x228(%ebp)
c0102007:	e8 54 fc ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
        out.write(" range: ");
c010200c:	58                   	pop    %eax
c010200d:	5a                   	pop    %edx
c010200e:	8d 93 bc 3a fe ff    	lea    -0x1c544(%ebx),%edx
c0102014:	52                   	push   %edx
c0102015:	56                   	push   %esi
c0102016:	e8 df 3c 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010201b:	59                   	pop    %ecx
c010201c:	58                   	pop    %eax
c010201d:	56                   	push   %esi
c010201e:	57                   	push   %edi
c010201f:	e8 f8 fb ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102024:	89 34 24             	mov    %esi,(%esp)
c0102027:	e8 e8 3c 00 00       	call   c0105d14 <_ZN6StringD1Ev>
        out.writeValue(begin);
c010202c:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0102032:	89 85 d8 fd ff ff    	mov    %eax,-0x228(%ebp)
c0102038:	58                   	pop    %eax
c0102039:	5a                   	pop    %edx
c010203a:	56                   	push   %esi
c010203b:	57                   	push   %edi
c010203c:	e8 1f fc ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
        out.write(" ~ ");
c0102041:	8d 93 c5 3a fe ff    	lea    -0x1c53b(%ebx),%edx
c0102047:	59                   	pop    %ecx
c0102048:	58                   	pop    %eax
c0102049:	52                   	push   %edx
c010204a:	56                   	push   %esi
c010204b:	e8 aa 3c 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102050:	58                   	pop    %eax
c0102051:	5a                   	pop    %edx
c0102052:	56                   	push   %esi
c0102053:	57                   	push   %edi
c0102054:	e8 c3 fb ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102059:	89 34 24             	mov    %esi,(%esp)
c010205c:	e8 b3 3c 00 00       	call   c0105d14 <_ZN6StringD1Ev>
        out.writeValue(end - 1);
c0102061:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
c0102067:	59                   	pop    %ecx
c0102068:	8d 50 ff             	lea    -0x1(%eax),%edx
c010206b:	58                   	pop    %eax
c010206c:	89 95 d8 fd ff ff    	mov    %edx,-0x228(%ebp)
c0102072:	56                   	push   %esi
c0102073:	57                   	push   %edi
c0102074:	e8 e7 fb ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
        out.write(" type = ");
c0102079:	58                   	pop    %eax
c010207a:	5a                   	pop    %edx
c010207b:	8d 93 c9 3a fe ff    	lea    -0x1c537(%ebx),%edx
c0102081:	52                   	push   %edx
c0102082:	56                   	push   %esi
c0102083:	e8 72 3c 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102088:	59                   	pop    %ecx
c0102089:	58                   	pop    %eax
c010208a:	56                   	push   %esi
c010208b:	57                   	push   %edi
c010208c:	e8 8b fb ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102091:	89 34 24             	mov    %esi,(%esp)
c0102094:	e8 7b 3c 00 00       	call   c0105d14 <_ZN6StringD1Ev>
        out.writeValue(memMap->ARDS[i].type);
c0102099:	8b 85 a8 fd ff ff    	mov    -0x258(%ebp),%eax
c010209f:	8b 90 14 80 00 c0    	mov    -0x3fff7fec(%eax),%edx
c01020a5:	89 85 ac fd ff ff    	mov    %eax,-0x254(%ebp)
c01020ab:	58                   	pop    %eax
c01020ac:	89 95 d8 fd ff ff    	mov    %edx,-0x228(%ebp)
c01020b2:	5a                   	pop    %edx
c01020b3:	56                   	push   %esi
c01020b4:	57                   	push   %edi
c01020b5:	e8 a6 fb ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
        if (memMap->ARDS[i].type == E820_ARM) {                                    // is ARM Area
c01020ba:	8b 85 ac fd ff ff    	mov    -0x254(%ebp),%eax
c01020c0:	83 c4 10             	add    $0x10,%esp
c01020c3:	8b 8d a4 fd ff ff    	mov    -0x25c(%ebp),%ecx
c01020c9:	83 b8 14 80 00 c0 01 	cmpl   $0x1,-0x3fff7fec(%eax)
c01020d0:	75 45                	jne    c0102117 <_ZN5PhyMM8initPageEv+0x225>
            if (maxpa < end && begin < KERNEL_MEM_SIZE) {
c01020d2:	8b 95 bc fd ff ff    	mov    -0x244(%ebp),%edx
c01020d8:	39 95 b4 fd ff ff    	cmp    %edx,-0x24c(%ebp)
c01020de:	72 0a                	jb     c01020ea <_ZN5PhyMM8initPageEv+0x1f8>
c01020e0:	77 35                	ja     c0102117 <_ZN5PhyMM8initPageEv+0x225>
c01020e2:	3b 8d b8 fd ff ff    	cmp    -0x248(%ebp),%ecx
c01020e8:	73 2d                	jae    c0102117 <_ZN5PhyMM8initPageEv+0x225>
c01020ea:	83 bd c4 fd ff ff 00 	cmpl   $0x0,-0x23c(%ebp)
c01020f1:	77 24                	ja     c0102117 <_ZN5PhyMM8initPageEv+0x225>
c01020f3:	81 bd c0 fd ff ff ff 	cmpl   $0x37ffffff,-0x240(%ebp)
c01020fa:	ff ff 37 
c01020fd:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
c0102103:	0f 47 85 b4 fd ff ff 	cmova  -0x24c(%ebp),%eax
c010210a:	0f 46 8d b8 fd ff ff 	cmovbe -0x248(%ebp),%ecx
c0102111:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c0102117:	89 8d c0 fd ff ff    	mov    %ecx,-0x240(%ebp)
        out.write("\n");
c010211d:	8d 83 af 39 fe ff    	lea    -0x1c651(%ebx),%eax
c0102123:	51                   	push   %ecx
c0102124:	51                   	push   %ecx
c0102125:	50                   	push   %eax
c0102126:	8d b5 d8 fd ff ff    	lea    -0x228(%ebp),%esi
c010212c:	56                   	push   %esi
c010212d:	e8 c8 3b 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102132:	5f                   	pop    %edi
c0102133:	58                   	pop    %eax
c0102134:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c010213a:	56                   	push   %esi
c010213b:	50                   	push   %eax
c010213c:	e8 db fa ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102141:	89 34 24             	mov    %esi,(%esp)
c0102144:	e8 cb 3b 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    for (uint32_t i = 0; i < memMap->numARDS; i++) {                               // scan all of free memory block
c0102149:	83 c4 10             	add    $0x10,%esp
c010214c:	8b 8d c0 fd ff ff    	mov    -0x240(%ebp),%ecx
c0102152:	ff 85 b0 fd ff ff    	incl   -0x250(%ebp)
c0102158:	e9 0e fe ff ff       	jmp    c0101f6b <_ZN5PhyMM8initPageEv+0x79>
    numPage = maxpa / PGSIZE;          // get number of page
c010215d:	8b bd b4 fd ff ff    	mov    -0x24c(%ebp),%edi
c0102163:	89 ce                	mov    %ecx,%esi
c0102165:	83 ff 00             	cmp    $0x0,%edi
c0102168:	77 08                	ja     c0102172 <_ZN5PhyMM8initPageEv+0x280>
c010216a:	81 f9 00 00 00 38    	cmp    $0x38000000,%ecx
c0102170:	76 07                	jbe    c0102179 <_ZN5PhyMM8initPageEv+0x287>
c0102172:	be 00 00 00 38       	mov    $0x38000000,%esi
c0102177:	31 ff                	xor    %edi,%edi
c0102179:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010217c:	89 f0                	mov    %esi,%eax
c010217e:	0f ac f8 0c          	shrd   $0xc,%edi,%eax
c0102182:	89 41 1c             	mov    %eax,0x1c(%ecx)
    out.write("\n numPage = ");
c0102185:	8d 83 d2 3a fe ff    	lea    -0x1c52e(%ebx),%eax
c010218b:	56                   	push   %esi
c010218c:	56                   	push   %esi
c010218d:	50                   	push   %eax
c010218e:	8d b5 d8 fd ff ff    	lea    -0x228(%ebp),%esi
c0102194:	56                   	push   %esi
c0102195:	e8 60 3b 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010219a:	5f                   	pop    %edi
c010219b:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01021a1:	58                   	pop    %eax
c01021a2:	56                   	push   %esi
c01021a3:	57                   	push   %edi
c01021a4:	e8 73 fa ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01021a9:	89 34 24             	mov    %esi,(%esp)
c01021ac:	e8 63 3b 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue(numPage);
c01021b1:	8b 45 08             	mov    0x8(%ebp),%eax
c01021b4:	8b 40 1c             	mov    0x1c(%eax),%eax
c01021b7:	89 85 d8 fd ff ff    	mov    %eax,-0x228(%ebp)
c01021bd:	58                   	pop    %eax
c01021be:	5a                   	pop    %edx
c01021bf:	56                   	push   %esi
c01021c0:	57                   	push   %edi
c01021c1:	e8 9a fa ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    pNodeArr = (List<Page>::DLNode *)Utils::roundUp((uint32_t)end, PGSIZE);
c01021c6:	c7 c0 60 60 12 c0    	mov    $0xc0126060,%eax
class Utils {

    public:

        static uint32_t roundUp(uint32_t a, uint32_t n) {
            a = (a % n == 0) ? a : (a / n + 1) * n;
c01021cc:	83 c4 10             	add    $0x10,%esp
c01021cf:	a9 ff 0f 00 00       	test   $0xfff,%eax
c01021d4:	74 0a                	je     c01021e0 <_ZN5PhyMM8initPageEv+0x2ee>
c01021d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01021db:	05 00 10 00 00       	add    $0x1000,%eax
c01021e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
c01021e3:	89 41 41             	mov    %eax,0x41(%ecx)
    out.write("\n pNodeArr = ");
c01021e6:	8d 83 df 3a fe ff    	lea    -0x1c521(%ebx),%eax
c01021ec:	51                   	push   %ecx
c01021ed:	51                   	push   %ecx
c01021ee:	50                   	push   %eax
c01021ef:	56                   	push   %esi
c01021f0:	e8 05 3b 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01021f5:	5f                   	pop    %edi
c01021f6:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01021fc:	58                   	pop    %eax
c01021fd:	56                   	push   %esi
c01021fe:	57                   	push   %edi
c01021ff:	e8 18 fa ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102204:	89 34 24             	mov    %esi,(%esp)
c0102207:	e8 08 3b 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue((uint32_t)pNodeArr);
c010220c:	8b 45 08             	mov    0x8(%ebp),%eax
c010220f:	8b 40 41             	mov    0x41(%eax),%eax
c0102212:	89 85 d8 fd ff ff    	mov    %eax,-0x228(%ebp)
c0102218:	58                   	pop    %eax
c0102219:	5a                   	pop    %edx
c010221a:	56                   	push   %esi
c010221b:	57                   	push   %edi
    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c010221c:	31 ff                	xor    %edi,%edi
    out.writeValue((uint32_t)pNodeArr);
c010221e:	e8 3d fa ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
c0102223:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c0102226:	8b 45 08             	mov    0x8(%ebp),%eax
c0102229:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010222c:	8b 40 1c             	mov    0x1c(%eax),%eax
c010222f:	8b 51 41             	mov    0x41(%ecx),%edx
c0102232:	39 f8                	cmp    %edi,%eax
c0102234:	76 14                	jbe    c010224a <_ZN5PhyMM8initPageEv+0x358>
        setPageReserved(pNodeArr[i].data);
c0102236:	6b c7 11             	imul   $0x11,%edi,%eax
c0102239:	83 ec 0c             	sub    $0xc,%esp
    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c010223c:	47                   	inc    %edi
        setPageReserved(pNodeArr[i].data);
c010223d:	01 c2                	add    %eax,%edx
c010223f:	52                   	push   %edx
c0102240:	e8 3d 37 00 00       	call   c0105982 <_ZN3MMU15setPageReservedERNS_4PageE>
    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c0102245:	83 c4 10             	add    $0x10,%esp
c0102248:	eb dc                	jmp    c0102226 <_ZN5PhyMM8initPageEv+0x334>
    uptr32_t freeMem = vToPhyAD((uptr32_t)(pNodeArr + numPage));
c010224a:	6b c0 11             	imul   $0x11,%eax,%eax
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c010224d:	8d bc 02 00 00 00 40 	lea    0x40000000(%edx,%eax,1),%edi
c0102254:	81 ff 00 00 00 38    	cmp    $0x38000000,%edi
c010225a:	76 02                	jbe    c010225e <_ZN5PhyMM8initPageEv+0x36c>
    return 0;
c010225c:	31 ff                	xor    %edi,%edi
    out.write("\n freeMem = ");
c010225e:	50                   	push   %eax
c010225f:	50                   	push   %eax
c0102260:	8d 83 ed 3a fe ff    	lea    -0x1c513(%ebx),%eax
c0102266:	50                   	push   %eax
c0102267:	56                   	push   %esi
c0102268:	e8 8d 3a 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010226d:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c0102273:	5a                   	pop    %edx
c0102274:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c010227a:	59                   	pop    %ecx
c010227b:	56                   	push   %esi
c010227c:	50                   	push   %eax
c010227d:	e8 9a f9 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102282:	89 34 24             	mov    %esi,(%esp)
c0102285:	e8 8a 3a 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue((uint32_t)freeMem);
c010228a:	58                   	pop    %eax
c010228b:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0102291:	5a                   	pop    %edx
c0102292:	89 bd d8 fd ff ff    	mov    %edi,-0x228(%ebp)
c0102298:	56                   	push   %esi
    for (uint32_t i = 0; i < memMap->numARDS; i++) {
c0102299:	31 f6                	xor    %esi,%esi
    out.writeValue((uint32_t)freeMem);
c010229b:	50                   	push   %eax
c010229c:	e8 bf f9 ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    out.flush();
c01022a1:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01022a7:	89 04 24             	mov    %eax,(%esp)
c01022aa:	e8 b9 f8 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c01022af:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 0; i < memMap->numARDS; i++) {
c01022b2:	39 35 00 80 00 c0    	cmp    %esi,0xc0008000
c01022b8:	0f 86 85 00 00 00    	jbe    c0102343 <_ZN5PhyMM8initPageEv+0x451>
        if (memMap->ARDS[i].type == E820_ARM) {                                    // is ARM Area
c01022be:	6b c6 14             	imul   $0x14,%esi,%eax
c01022c1:	83 b8 14 80 00 c0 01 	cmpl   $0x1,-0x3fff7fec(%eax)
c01022c8:	8d 88 00 80 00 c0    	lea    -0x3fff8000(%eax),%ecx
c01022ce:	75 6d                	jne    c010233d <_ZN5PhyMM8initPageEv+0x44b>
        uptr32_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c01022d0:	8b 90 04 80 00 c0    	mov    -0x3fff7ffc(%eax),%edx
c01022d6:	89 f8                	mov    %edi,%eax
c01022d8:	39 fa                	cmp    %edi,%edx
c01022da:	0f 43 c2             	cmovae %edx,%eax
c01022dd:	03 51 0c             	add    0xc(%ecx),%edx
c01022e0:	b9 00 00 00 38       	mov    $0x38000000,%ecx
c01022e5:	81 fa 00 00 00 38    	cmp    $0x38000000,%edx
c01022eb:	0f 47 d1             	cmova  %ecx,%edx
            if (begin < end) {
c01022ee:	39 d0                	cmp    %edx,%eax
c01022f0:	73 4b                	jae    c010233d <_ZN5PhyMM8initPageEv+0x44b>
c01022f2:	a9 ff 0f 00 00       	test   $0xfff,%eax
c01022f7:	74 0a                	je     c0102303 <_ZN5PhyMM8initPageEv+0x411>
c01022f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01022fe:	05 00 10 00 00       	add    $0x1000,%eax
            return a;
        }

        static uint32_t roundDown(uint32_t a, uint32_t n) {         // round up  n for a; Example (7, 4) = 8
            return (a / n) * n;
c0102303:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
                if (begin < end) {
c0102309:	39 c2                	cmp    %eax,%edx
c010230b:	76 30                	jbe    c010233d <_ZN5PhyMM8initPageEv+0x44b>
                    manager->initMemMap(phyAdToPgNode(begin), (end - begin) / PGSIZE);
c010230d:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0102310:	29 c2                	sub    %eax,%edx
c0102312:	83 ec 04             	sub    $0x4,%esp
c0102315:	c1 ea 0c             	shr    $0xc,%edx
    }
    return 0;
}

List<MMU::Page>::DLNode * PhyMM::phyAdToPgNode(uptr32_t pAd) {
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
c0102318:	c1 e8 0c             	shr    $0xc,%eax
    return &(pNodeArr[pIndex]);
c010231b:	6b c0 11             	imul   $0x11,%eax,%eax
                    manager->initMemMap(phyAdToPgNode(begin), (end - begin) / PGSIZE);
c010231e:	8b 49 3d             	mov    0x3d(%ecx),%ecx
c0102321:	89 8d c0 fd ff ff    	mov    %ecx,-0x240(%ebp)
c0102327:	8b 09                	mov    (%ecx),%ecx
c0102329:	52                   	push   %edx
    return &(pNodeArr[pIndex]);
c010232a:	8b 55 08             	mov    0x8(%ebp),%edx
c010232d:	03 42 41             	add    0x41(%edx),%eax
                    manager->initMemMap(phyAdToPgNode(begin), (end - begin) / PGSIZE);
c0102330:	50                   	push   %eax
c0102331:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c0102337:	ff 51 04             	call   *0x4(%ecx)
c010233a:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 0; i < memMap->numARDS; i++) {
c010233d:	46                   	inc    %esi
c010233e:	e9 6f ff ff ff       	jmp    c01022b2 <_ZN5PhyMM8initPageEv+0x3c0>
    OStream out("\nMemmory Map [E820Map] begin...\n", "blue");
c0102343:	83 ec 0c             	sub    $0xc,%esp
c0102346:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c010234c:	50                   	push   %eax
c010234d:	e8 5a f8 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
}
c0102352:	83 c4 10             	add    $0x10,%esp
c0102355:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102358:	5b                   	pop    %ebx
c0102359:	5e                   	pop    %esi
c010235a:	5f                   	pop    %edi
c010235b:	5d                   	pop    %ebp
c010235c:	c3                   	ret    
c010235d:	90                   	nop

c010235e <_ZN5PhyMM13initGDTAndTSSEv>:
void PhyMM::initGDTAndTSS() {
c010235e:	55                   	push   %ebp
c010235f:	89 e5                	mov    %esp,%ebp
c0102361:	57                   	push   %edi
c0102362:	56                   	push   %esi
c0102363:	53                   	push   %ebx
c0102364:	e8 64 e8 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0102369:	81 c3 b7 00 02 00    	add    $0x200b7,%ebx
c010236f:	83 ec 28             	sub    $0x28,%esp
    tss.ts_esp0 = (uptr32_t)stackTop;
c0102372:	8b 45 08             	mov    0x8(%ebp),%eax
    GDT[SEG_KTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_KERNEL);
c0102375:	8d 7d e0             	lea    -0x20(%ebp),%edi
    tss.ts_esp0 = (uptr32_t)stackTop;
c0102378:	8b 40 14             	mov    0x14(%eax),%eax
c010237b:	c7 c1 c0 59 12 c0    	mov    $0xc01259c0,%ecx
    GDT[0] = SEG_NULL;
c0102381:	c7 c6 80 51 12 c0    	mov    $0xc0125180,%esi
    tss.ts_esp0 = (uptr32_t)stackTop;
c0102387:	89 41 04             	mov    %eax,0x4(%ecx)
    tss.ts_ss0 = KERNEL_DS;
c010238a:	66 c7 41 08 10 00    	movw   $0x10,0x8(%ecx)
    GDT[SEG_KTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_KERNEL);
c0102390:	6a 00                	push   $0x0
c0102392:	6a ff                	push   $0xffffffff
c0102394:	6a 00                	push   $0x0
c0102396:	6a 0a                	push   $0xa
c0102398:	57                   	push   %edi
    tss.ts_ss0 = KERNEL_DS;
c0102399:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    GDT[0] = SEG_NULL;
c010239c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
c01023a2:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
    GDT[SEG_KTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_KERNEL);
c01023a9:	e8 fa 33 00 00       	call   c01057a8 <_ZN3MMU10setSegDescEjjjj>
c01023ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01023b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01023b4:	89 46 08             	mov    %eax,0x8(%esi)
c01023b7:	89 56 0c             	mov    %edx,0xc(%esi)
    GDT[SEG_KDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_KERNEL);
c01023ba:	6a 00                	push   $0x0
c01023bc:	6a ff                	push   $0xffffffff
c01023be:	6a 00                	push   $0x0
c01023c0:	6a 02                	push   $0x2
c01023c2:	57                   	push   %edi
c01023c3:	e8 e0 33 00 00       	call   c01057a8 <_ZN3MMU10setSegDescEjjjj>
c01023c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01023cb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01023ce:	89 46 10             	mov    %eax,0x10(%esi)
c01023d1:	89 56 14             	mov    %edx,0x14(%esi)
    GDT[SEG_UTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_USER);
c01023d4:	83 c4 20             	add    $0x20,%esp
c01023d7:	6a 03                	push   $0x3
c01023d9:	6a ff                	push   $0xffffffff
c01023db:	6a 00                	push   $0x0
c01023dd:	6a 0a                	push   $0xa
c01023df:	57                   	push   %edi
c01023e0:	e8 c3 33 00 00       	call   c01057a8 <_ZN3MMU10setSegDescEjjjj>
c01023e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01023e8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01023eb:	89 46 18             	mov    %eax,0x18(%esi)
c01023ee:	89 56 1c             	mov    %edx,0x1c(%esi)
    GDT[SEG_UDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_USER);
c01023f1:	6a 03                	push   $0x3
c01023f3:	6a ff                	push   $0xffffffff
c01023f5:	6a 00                	push   $0x0
c01023f7:	6a 02                	push   $0x2
c01023f9:	57                   	push   %edi
c01023fa:	e8 a9 33 00 00       	call   c01057a8 <_ZN3MMU10setSegDescEjjjj>
    GDT[SEG_TSS] = setTssDesc(STS_T32A, (uptr32_t)(&tss), sizeof(tss), DPL_KERNEL);
c01023ff:	8b 4d dc             	mov    -0x24(%ebp),%ecx
    GDT[SEG_UDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_USER);
c0102402:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102405:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102408:	89 46 20             	mov    %eax,0x20(%esi)
    GDT[SEG_TSS] = setTssDesc(STS_T32A, (uptr32_t)(&tss), sizeof(tss), DPL_KERNEL);
c010240b:	83 c4 20             	add    $0x20,%esp
c010240e:	6a 00                	push   $0x0
c0102410:	6a 68                	push   $0x68
c0102412:	51                   	push   %ecx
c0102413:	6a 09                	push   $0x9
c0102415:	57                   	push   %edi
    GDT[SEG_UDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_USER);
c0102416:	89 56 24             	mov    %edx,0x24(%esi)
    GDT[SEG_TSS] = setTssDesc(STS_T32A, (uptr32_t)(&tss), sizeof(tss), DPL_KERNEL);
c0102419:	e8 82 34 00 00       	call   c01058a0 <_ZN3MMU10setTssDescEjjjj>
c010241e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102421:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102424:	89 46 28             	mov    %eax,0x28(%esi)
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102427:	c7 c0 48 24 12 c0    	mov    $0xc0122448,%eax
c010242d:	89 56 2c             	mov    %edx,0x2c(%esi)
c0102430:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%ds" :: "a" (ds));
c0102433:	b8 10 00 00 00       	mov    $0x10,%eax
c0102438:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (ss));
c010243a:	8e d0                	mov    %eax,%ss
    asm volatile ("movw %%ax, %%es" :: "a" (es));
c010243c:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%fs" :: "a" (fs));
c010243e:	b8 23 00 00 00       	mov    $0x23,%eax
c0102443:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%gs" :: "a" (gs));
c0102445:	8e e8                	mov    %eax,%gs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (cs));
c0102447:	ea 4e 24 10 c0 08 00 	ljmp   $0x8,$0xc010244e
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c010244e:	b8 28 00 00 00       	mov    $0x28,%eax
c0102453:	0f 00 d8             	ltr    %ax
}
c0102456:	83 c4 1c             	add    $0x1c,%esp
c0102459:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010245c:	5b                   	pop    %ebx
c010245d:	5e                   	pop    %esi
c010245e:	5f                   	pop    %edi
c010245f:	5d                   	pop    %ebp
c0102460:	c3                   	ret    
c0102461:	90                   	nop

c0102462 <_ZN5PhyMM14initPmmManagerEv>:
void PhyMM::initPmmManager() {
c0102462:	55                   	push   %ebp
c0102463:	89 e5                	mov    %esp,%ebp
c0102465:	8b 45 08             	mov    0x8(%ebp),%eax
    manager = &ff;
c0102468:	8d 50 20             	lea    0x20(%eax),%edx
c010246b:	89 50 3d             	mov    %edx,0x3d(%eax)
}
c010246e:	5d                   	pop    %ebp
c010246f:	c3                   	ret    

c0102470 <_ZN5PhyMM8vToPhyADEj>:
uptr32_t PhyMM::vToPhyAD(uptr32_t kvAd) {
c0102470:	55                   	push   %ebp
c0102471:	89 e5                	mov    %esp,%ebp
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c0102473:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102476:	05 00 00 00 40       	add    $0x40000000,%eax
c010247b:	3d 00 00 00 38       	cmp    $0x38000000,%eax
c0102480:	76 02                	jbe    c0102484 <_ZN5PhyMM8vToPhyADEj+0x14>
    return 0;
c0102482:	31 c0                	xor    %eax,%eax
}
c0102484:	5d                   	pop    %ebp
c0102485:	c3                   	ret    

c0102486 <_ZN5PhyMM8pToVirADEj>:
uptr32_t PhyMM::pToVirAD(uptr32_t pAd) {
c0102486:	55                   	push   %ebp
c0102487:	89 e5                	mov    %esp,%ebp
c0102489:	8b 55 0c             	mov    0xc(%ebp),%edx
    if (pAd <= KERNEL_MEM_SIZE) {
c010248c:	81 fa 00 00 00 38    	cmp    $0x38000000,%edx
        return pAd + KERNEL_BASE;
c0102492:	8d 82 00 00 00 c0    	lea    -0x40000000(%edx),%eax
    if (pAd <= KERNEL_MEM_SIZE) {
c0102498:	76 02                	jbe    c010249c <_ZN5PhyMM8pToVirADEj+0x16>
c010249a:	31 c0                	xor    %eax,%eax
}
c010249c:	5d                   	pop    %ebp
c010249d:	c3                   	ret    

c010249e <_ZN5PhyMM13phyAdToPgNodeEj>:
List<MMU::Page>::DLNode * PhyMM::phyAdToPgNode(uptr32_t pAd) {
c010249e:	55                   	push   %ebp
c010249f:	89 e5                	mov    %esp,%ebp
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
c01024a1:	8b 45 0c             	mov    0xc(%ebp),%eax
    return &(pNodeArr[pIndex]);
c01024a4:	8b 55 08             	mov    0x8(%ebp),%edx
}
c01024a7:	5d                   	pop    %ebp
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
c01024a8:	c1 e8 0c             	shr    $0xc,%eax
    return &(pNodeArr[pIndex]);
c01024ab:	6b c0 11             	imul   $0x11,%eax,%eax
c01024ae:	03 42 41             	add    0x41(%edx),%eax
}
c01024b1:	c3                   	ret    

c01024b2 <_ZN5PhyMM14pnodeToPageLADEPN4ListIN3MMU4PageEE6DLNodeE>:

uptr32_t PhyMM::pnodeToPageLAD(List<Page>::DLNode *node) {
c01024b2:	55                   	push   %ebp
c01024b3:	89 e5                	mov    %esp,%ebp
    uint32_t pageNo = node - pNodeArr;       // physical memory page NO
c01024b5:	8b 45 08             	mov    0x8(%ebp),%eax
c01024b8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01024bb:	2b 50 41             	sub    0x41(%eax),%edx
c01024be:	69 d2 f1 f0 f0 f0    	imul   $0xf0f0f0f1,%edx,%edx
    return pToVirAD(pageNo << PGSHIFT);
c01024c4:	c1 e2 0c             	shl    $0xc,%edx
    if (pAd <= KERNEL_MEM_SIZE) {
c01024c7:	81 fa 00 00 00 38    	cmp    $0x38000000,%edx
        return pAd + KERNEL_BASE;
c01024cd:	8d 82 00 00 00 c0    	lea    -0x40000000(%edx),%eax
    if (pAd <= KERNEL_MEM_SIZE) {
c01024d3:	76 02                	jbe    c01024d7 <_ZN5PhyMM14pnodeToPageLADEPN4ListIN3MMU4PageEE6DLNodeE+0x25>
c01024d5:	31 c0                	xor    %eax,%eax
}
c01024d7:	5d                   	pop    %ebp
c01024d8:	c3                   	ret    
c01024d9:	90                   	nop

c01024da <_ZN5PhyMM11pdeToPTableERKN3MMU7PTEntryE>:

MMU::PTEntry * PhyMM::pdeToPTable(const PTEntry &pte) {
c01024da:	55                   	push   %ebp
c01024db:	89 e5                	mov    %esp,%ebp
c01024dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    uptr32_t ptAD= pToVirAD(pte.p_ppn << PGSHIFT);
c01024e0:	8a 51 01             	mov    0x1(%ecx),%dl
c01024e3:	c0 ea 04             	shr    $0x4,%dl
c01024e6:	0f b6 c2             	movzbl %dl,%eax
c01024e9:	0f b6 51 02          	movzbl 0x2(%ecx),%edx
c01024ed:	c1 e2 04             	shl    $0x4,%edx
c01024f0:	09 d0                	or     %edx,%eax
c01024f2:	0f b6 51 03          	movzbl 0x3(%ecx),%edx
c01024f6:	c1 e2 0c             	shl    $0xc,%edx
c01024f9:	09 c2                	or     %eax,%edx
c01024fb:	c1 e2 0c             	shl    $0xc,%edx
    if (pAd <= KERNEL_MEM_SIZE) {
c01024fe:	81 fa 00 00 00 38    	cmp    $0x38000000,%edx
        return pAd + KERNEL_BASE;
c0102504:	8d 82 00 00 00 c0    	lea    -0x40000000(%edx),%eax
    if (pAd <= KERNEL_MEM_SIZE) {
c010250a:	76 02                	jbe    c010250e <_ZN5PhyMM11pdeToPTableERKN3MMU7PTEntryE+0x34>
c010250c:	31 c0                	xor    %eax,%eax
    return (PTEntry *)ptAD;
}
c010250e:	5d                   	pop    %ebp
c010250f:	c3                   	ret    

c0102510 <_ZN5PhyMM11pteToPgNodeERKN3MMU7PTEntryE>:

List<MMU::Page>::DLNode * PhyMM::pteToPgNode(const PTEntry &pte) {
c0102510:	55                   	push   %ebp
c0102511:	89 e5                	mov    %esp,%ebp
c0102513:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    return &(pNodeArr[pte.p_ppn]);
c0102516:	8a 41 01             	mov    0x1(%ecx),%al
c0102519:	c0 e8 04             	shr    $0x4,%al
c010251c:	0f b6 d0             	movzbl %al,%edx
c010251f:	0f b6 41 02          	movzbl 0x2(%ecx),%eax
c0102523:	c1 e0 04             	shl    $0x4,%eax
c0102526:	09 c2                	or     %eax,%edx
c0102528:	0f b6 41 03          	movzbl 0x3(%ecx),%eax
c010252c:	c1 e0 0c             	shl    $0xc,%eax
c010252f:	09 d0                	or     %edx,%eax
c0102531:	8b 55 08             	mov    0x8(%ebp),%edx
c0102534:	6b c0 11             	imul   $0x11,%eax,%eax
}
c0102537:	5d                   	pop    %ebp
    return &(pNodeArr[pte.p_ppn]);
c0102538:	03 42 41             	add    0x41(%edx),%eax
}
c010253b:	c3                   	ret    

c010253c <_ZN5PhyMM11pdeToPgNodeERKN3MMU7PTEntryE>:
c010253c:	55                   	push   %ebp
c010253d:	89 e5                	mov    %esp,%ebp
c010253f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0102542:	8a 41 01             	mov    0x1(%ecx),%al
c0102545:	c0 e8 04             	shr    $0x4,%al
c0102548:	0f b6 d0             	movzbl %al,%edx
c010254b:	0f b6 41 02          	movzbl 0x2(%ecx),%eax
c010254f:	c1 e0 04             	shl    $0x4,%eax
c0102552:	09 c2                	or     %eax,%edx
c0102554:	0f b6 41 03          	movzbl 0x3(%ecx),%eax
c0102558:	c1 e0 0c             	shl    $0xc,%eax
c010255b:	09 d0                	or     %edx,%eax
c010255d:	8b 55 08             	mov    0x8(%ebp),%edx
c0102560:	6b c0 11             	imul   $0x11,%eax,%eax
c0102563:	5d                   	pop    %ebp
c0102564:	03 42 41             	add    0x41(%edx),%eax
c0102567:	c3                   	ret    

c0102568 <_ZN5PhyMM6getPTEEPN3MMU7PTEntryERKNS0_8LinearADEb>:

List<MMU::Page>::DLNode * PhyMM::pdeToPgNode(const PTEntry &pde) {
    return &(pNodeArr[pde.p_ppn]);
}

MMU::PTEntry * PhyMM::getPTE(PTEntry *pdt, const LinearAD &lad, bool create) {
c0102568:	55                   	push   %ebp
c0102569:	89 e5                	mov    %esp,%ebp
c010256b:	57                   	push   %edi
c010256c:	56                   	push   %esi
c010256d:	53                   	push   %ebx
c010256e:	83 ec 0c             	sub    $0xc,%esp
c0102571:	8b 75 10             	mov    0x10(%ebp),%esi
c0102574:	8b 7d 08             	mov    0x8(%ebp),%edi
c0102577:	8a 45 14             	mov    0x14(%ebp),%al
    PTEntry &pde = bootPDT[lad.PDI];
c010257a:	8a 56 02             	mov    0x2(%esi),%dl
c010257d:	c0 ea 06             	shr    $0x6,%dl
c0102580:	0f b6 ca             	movzbl %dl,%ecx
c0102583:	0f b6 56 03          	movzbl 0x3(%esi),%edx
c0102587:	c1 e2 02             	shl    $0x2,%edx
c010258a:	09 ca                	or     %ecx,%edx
c010258c:	8b 4f 18             	mov    0x18(%edi),%ecx
c010258f:	8d 1c 91             	lea    (%ecx,%edx,4),%ebx
    if (!(pde.p_p) && create) {                          // check present bit and is create?
c0102592:	8a 13                	mov    (%ebx),%dl
c0102594:	f6 d2                	not    %dl
c0102596:	80 e2 01             	and    $0x1,%dl
c0102599:	84 d2                	test   %dl,%dl
c010259b:	74 67                	je     c0102604 <_ZN5PhyMM6getPTEEPN3MMU7PTEntryERKNS0_8LinearADEb+0x9c>
c010259d:	84 c0                	test   %al,%al
c010259f:	74 63                	je     c0102604 <_ZN5PhyMM6getPTEEPN3MMU7PTEntryERKNS0_8LinearADEb+0x9c>
        /*      wait 2020.4.6      */
        List<Page>::DLNode *pnode;
        if ((pnode = manager->allocPages()) == nullptr) {
c01025a1:	8b 47 3d             	mov    0x3d(%edi),%eax
c01025a4:	51                   	push   %ecx
c01025a5:	51                   	push   %ecx
c01025a6:	8b 10                	mov    (%eax),%edx
c01025a8:	6a 01                	push   $0x1
c01025aa:	50                   	push   %eax
c01025ab:	ff 52 08             	call   *0x8(%edx)
c01025ae:	83 c4 10             	add    $0x10,%esp
c01025b1:	89 c1                	mov    %eax,%ecx
            return nullptr;
c01025b3:	31 c0                	xor    %eax,%eax
        if ((pnode = manager->allocPages()) == nullptr) {
c01025b5:	85 c9                	test   %ecx,%ecx
c01025b7:	74 6f                	je     c0102628 <_ZN5PhyMM6getPTEEPN3MMU7PTEntryERKNS0_8LinearADEb+0xc0>
        }
        pnode->data.ref = 1;
c01025b9:	c7 01 01 00 00 00    	movl   $0x1,(%ecx)
        // clear page content
        Utils::memset((void *)(pnodeToPageLAD(pnode)), 0, PGSIZE);
c01025bf:	52                   	push   %edx
c01025c0:	52                   	push   %edx
c01025c1:	51                   	push   %ecx
c01025c2:	57                   	push   %edi
c01025c3:	e8 ea fe ff ff       	call   c01024b2 <_ZN5PhyMM14pnodeToPageLADEPN4ListIN3MMU4PageEE6DLNodeE>
c01025c8:	83 c4 10             	add    $0x10,%esp
        }

        static void memset(void *ad, uint8_t byte, uint32_t size) {
            uint8_t *p = (uint8_t *)ad;
            for (uint32_t i = 0; i < size; i++) {
c01025cb:	31 d2                	xor    %edx,%edx
                p[i] = byte;
c01025cd:	c6 04 10 00          	movb   $0x0,(%eax,%edx,1)
            for (uint32_t i = 0; i < size; i++) {
c01025d1:	42                   	inc    %edx
c01025d2:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
c01025d8:	75 f3                	jne    c01025cd <_ZN5PhyMM6getPTEEPN3MMU7PTEntryERKNS0_8LinearADEb+0x65>
        // set permssion
        pde.p_ppn = pnode - pNodeArr;
c01025da:	2b 4f 41             	sub    0x41(%edi),%ecx
c01025dd:	8a 53 01             	mov    0x1(%ebx),%dl
        pde.p_us = 1;
        pde.p_rw = 1;
        pde.p_p = 1;
c01025e0:	80 0b 07             	orb    $0x7,(%ebx)
        pde.p_ppn = pnode - pNodeArr;
c01025e3:	69 c1 f1 f0 f0 f0    	imul   $0xf0f0f0f1,%ecx,%eax
c01025e9:	80 e2 0f             	and    $0xf,%dl
c01025ec:	88 c1                	mov    %al,%cl
c01025ee:	c0 e1 04             	shl    $0x4,%cl
c01025f1:	08 ca                	or     %cl,%dl
c01025f3:	88 53 01             	mov    %dl,0x1(%ebx)
c01025f6:	89 c2                	mov    %eax,%edx
c01025f8:	c1 ea 04             	shr    $0x4,%edx
c01025fb:	c1 e8 0c             	shr    $0xc,%eax
c01025fe:	88 53 02             	mov    %dl,0x2(%ebx)
c0102601:	88 43 03             	mov    %al,0x3(%ebx)
    }
    return &(pdeToPTable(pde)[lad.PTI]);
c0102604:	50                   	push   %eax
c0102605:	50                   	push   %eax
c0102606:	53                   	push   %ebx
c0102607:	57                   	push   %edi
c0102608:	e8 cd fe ff ff       	call   c01024da <_ZN5PhyMM11pdeToPTableERKN3MMU7PTEntryE>
c010260d:	8a 56 01             	mov    0x1(%esi),%dl
c0102610:	83 c4 10             	add    $0x10,%esp
c0102613:	c0 ea 04             	shr    $0x4,%dl
c0102616:	0f b6 ca             	movzbl %dl,%ecx
c0102619:	0f b6 56 02          	movzbl 0x2(%esi),%edx
c010261d:	83 e2 3f             	and    $0x3f,%edx
c0102620:	c1 e2 04             	shl    $0x4,%edx
c0102623:	09 ca                	or     %ecx,%edx
c0102625:	8d 04 90             	lea    (%eax,%edx,4),%eax
}
c0102628:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010262b:	5b                   	pop    %ebx
c010262c:	5e                   	pop    %esi
c010262d:	5f                   	pop    %edi
c010262e:	5d                   	pop    %ebp
c010262f:	c3                   	ret    

c0102630 <_ZN5PhyMM10mapSegmentEjjjj>:
void PhyMM::mapSegment(uptr32_t lad, uptr32_t pad, uint32_t size, uint32_t perm) {
c0102630:	55                   	push   %ebp
c0102631:	89 e5                	mov    %esp,%ebp
c0102633:	57                   	push   %edi
c0102634:	56                   	push   %esi
c0102635:	53                   	push   %ebx
c0102636:	e8 92 e5 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c010263b:	81 c3 e5 fd 01 00    	add    $0x1fde5,%ebx
c0102641:	81 ec 44 02 00 00    	sub    $0x244,%esp
    OStream out("\nmapSegment:\n lad: ", "blue");
c0102647:	8d bd db fd ff ff    	lea    -0x225(%ebp),%edi
c010264d:	8d b5 e0 fd ff ff    	lea    -0x220(%ebp),%esi
c0102653:	8d 83 96 39 fe ff    	lea    -0x1c66a(%ebx),%eax
c0102659:	50                   	push   %eax
c010265a:	57                   	push   %edi
c010265b:	e8 9a 36 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102660:	58                   	pop    %eax
c0102661:	8d 83 fa 3a fe ff    	lea    -0x1c506(%ebx),%eax
c0102667:	5a                   	pop    %edx
c0102668:	50                   	push   %eax
c0102669:	8d 85 d4 fd ff ff    	lea    -0x22c(%ebp),%eax
c010266f:	50                   	push   %eax
c0102670:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0102676:	e8 7f 36 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010267b:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102681:	83 c4 0c             	add    $0xc,%esp
c0102684:	57                   	push   %edi
c0102685:	50                   	push   %eax
c0102686:	56                   	push   %esi
c0102687:	e8 42 f4 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c010268c:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102692:	89 04 24             	mov    %eax,(%esp)
c0102695:	e8 7a 36 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010269a:	89 3c 24             	mov    %edi,(%esp)
c010269d:	e8 72 36 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue(lad);
c01026a2:	8d 55 0c             	lea    0xc(%ebp),%edx
c01026a5:	59                   	pop    %ecx
c01026a6:	89 95 bc fd ff ff    	mov    %edx,-0x244(%ebp)
c01026ac:	58                   	pop    %eax
c01026ad:	52                   	push   %edx
c01026ae:	56                   	push   %esi
c01026af:	e8 ac f5 ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    out.write(" to pad: ");
c01026b4:	58                   	pop    %eax
c01026b5:	8d 83 0e 3b fe ff    	lea    -0x1c4f2(%ebx),%eax
c01026bb:	5a                   	pop    %edx
c01026bc:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c01026c2:	50                   	push   %eax
c01026c3:	57                   	push   %edi
c01026c4:	e8 31 36 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01026c9:	59                   	pop    %ecx
c01026ca:	58                   	pop    %eax
c01026cb:	57                   	push   %edi
c01026cc:	56                   	push   %esi
c01026cd:	e8 4a f5 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01026d2:	89 3c 24             	mov    %edi,(%esp)
c01026d5:	e8 3a 36 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue(pad);
c01026da:	58                   	pop    %eax
c01026db:	8d 45 10             	lea    0x10(%ebp),%eax
c01026de:	5a                   	pop    %edx
c01026df:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c01026e5:	50                   	push   %eax
c01026e6:	56                   	push   %esi
c01026e7:	e8 74 f5 ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    out.write("   size = ");
c01026ec:	59                   	pop    %ecx
c01026ed:	8d 8b 18 3b fe ff    	lea    -0x1c4e8(%ebx),%ecx
c01026f3:	58                   	pop    %eax
c01026f4:	51                   	push   %ecx
c01026f5:	57                   	push   %edi
c01026f6:	e8 ff 35 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01026fb:	58                   	pop    %eax
c01026fc:	5a                   	pop    %edx
c01026fd:	57                   	push   %edi
c01026fe:	56                   	push   %esi
c01026ff:	e8 18 f5 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102704:	89 3c 24             	mov    %edi,(%esp)
c0102707:	e8 08 36 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue(size);
c010270c:	59                   	pop    %ecx
c010270d:	8d 4d 14             	lea    0x14(%ebp),%ecx
c0102710:	58                   	pop    %eax
c0102711:	51                   	push   %ecx
c0102712:	56                   	push   %esi
c0102713:	e8 48 f5 ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    out.flush();
c0102718:	89 34 24             	mov    %esi,(%esp)
c010271b:	e8 48 f4 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    out.write("\n");
c0102720:	8d 8b af 39 fe ff    	lea    -0x1c651(%ebx),%ecx
c0102726:	58                   	pop    %eax
c0102727:	5a                   	pop    %edx
c0102728:	51                   	push   %ecx
c0102729:	57                   	push   %edi
c010272a:	e8 cb 35 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010272f:	59                   	pop    %ecx
c0102730:	58                   	pop    %eax
c0102731:	57                   	push   %edi
c0102732:	56                   	push   %esi
c0102733:	e8 e4 f4 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102738:	89 3c 24             	mov    %edi,(%esp)
c010273b:	e8 d4 35 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue(lad);
c0102740:	58                   	pop    %eax
            return (a / n) * n;
c0102741:	81 65 0c 00 f0 ff ff 	andl   $0xfffff000,0xc(%ebp)
c0102748:	5a                   	pop    %edx
c0102749:	8b 95 bc fd ff ff    	mov    -0x244(%ebp),%edx
c010274f:	81 65 10 00 f0 ff ff 	andl   $0xfffff000,0x10(%ebp)
c0102756:	52                   	push   %edx
c0102757:	56                   	push   %esi
c0102758:	e8 03 f5 ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    out.write(" to pad: ");
c010275d:	59                   	pop    %ecx
c010275e:	58                   	pop    %eax
c010275f:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0102765:	57                   	push   %edi
c0102766:	e8 8f 35 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010276b:	58                   	pop    %eax
c010276c:	5a                   	pop    %edx
c010276d:	57                   	push   %edi
c010276e:	56                   	push   %esi
c010276f:	e8 a8 f4 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102774:	89 3c 24             	mov    %edi,(%esp)
c0102777:	e8 98 35 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue(pad);
c010277c:	59                   	pop    %ecx
c010277d:	58                   	pop    %eax
c010277e:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0102784:	50                   	push   %eax
c0102785:	56                   	push   %esi
c0102786:	e8 d5 f4 ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    out.flush();
c010278b:	89 34 24             	mov    %esi,(%esp)
c010278e:	e8 d5 f3 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    uint32_t n = Utils::roundUp(size + LinearAD::LAD(lad).OFF, PGSIZE) / PGSIZE;
c0102793:	8b 45 0c             	mov    0xc(%ebp),%eax
            a = (a % n == 0) ? a : (a / n + 1) * n;
c0102796:	83 c4 10             	add    $0x10,%esp
c0102799:	25 ff 0f 00 00       	and    $0xfff,%eax
c010279e:	03 45 14             	add    0x14(%ebp),%eax
c01027a1:	a9 ff 0f 00 00       	test   $0xfff,%eax
c01027a6:	74 0a                	je     c01027b2 <_ZN5PhyMM10mapSegmentEjjjj+0x182>
c01027a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01027ad:	05 00 10 00 00       	add    $0x1000,%eax
c01027b2:	c1 e8 0c             	shr    $0xc,%eax
c01027b5:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
    out.write("\nn = ");
c01027bb:	8d b5 e0 fd ff ff    	lea    -0x220(%ebp),%esi
c01027c1:	50                   	push   %eax
c01027c2:	50                   	push   %eax
c01027c3:	8d 83 23 3b fe ff    	lea    -0x1c4dd(%ebx),%eax
c01027c9:	50                   	push   %eax
c01027ca:	57                   	push   %edi
c01027cb:	e8 2a 35 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01027d0:	5a                   	pop    %edx
c01027d1:	59                   	pop    %ecx
c01027d2:	57                   	push   %edi
c01027d3:	56                   	push   %esi
c01027d4:	e8 43 f4 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01027d9:	89 3c 24             	mov    %edi,(%esp)
c01027dc:	e8 33 35 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue(n);
c01027e1:	8d 95 d4 fd ff ff    	lea    -0x22c(%ebp),%edx
c01027e7:	5f                   	pop    %edi
c01027e8:	58                   	pop    %eax
c01027e9:	52                   	push   %edx
c01027ea:	56                   	push   %esi
c01027eb:	e8 70 f4 ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    out.flush();
c01027f0:	89 34 24             	mov    %esi,(%esp)
    for (uint32_t i = 0; i < n; i++) {
c01027f3:	31 f6                	xor    %esi,%esi
    out.flush();
c01027f5:	e8 6e f3 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c01027fa:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 0; i < n; i++) {
c01027fd:	39 b5 d4 fd ff ff    	cmp    %esi,-0x22c(%ebp)
c0102803:	0f 86 a8 00 00 00    	jbe    c01028b1 <_ZN5PhyMM10mapSegmentEjjjj+0x281>
        PTEntry *pte = getPTE(bootPDT, LinearAD::LAD(lad));
c0102809:	8b 45 0c             	mov    0xc(%ebp),%eax
    for (uint32_t i = 0; i < n; i++) {
c010280c:	46                   	inc    %esi
        PTEntry *pte = getPTE(bootPDT, LinearAD::LAD(lad));
c010280d:	6a 01                	push   $0x1
            }

            // covert to liner ad struct
            static LinearAD LAD(uptr32_t vAd) {
                LinearAD lad;
                lad.OFF = vAd & 0xFFF;
c010280f:	89 c2                	mov    %eax,%edx
                lad.PTI = (vAd >> PGSHIFT) & 0x3FF;
c0102811:	89 c1                	mov    %eax,%ecx
                lad.OFF = vAd & 0xFFF;
c0102813:	c1 ea 08             	shr    $0x8,%edx
                lad.PTI = (vAd >> PGSHIFT) & 0x3FF;
c0102816:	c1 e9 0c             	shr    $0xc,%ecx
c0102819:	80 e2 0f             	and    $0xf,%dl
c010281c:	c0 e1 04             	shl    $0x4,%cl
c010281f:	08 ca                	or     %cl,%dl
                lad.PDI = (vAd >> PTSHIFT) & 0x3FF;
c0102821:	89 c1                	mov    %eax,%ecx
                lad.PTI = (vAd >> PGSHIFT) & 0x3FF;
c0102823:	88 95 dc fd ff ff    	mov    %dl,-0x224(%ebp)
c0102829:	89 c2                	mov    %eax,%edx
                lad.OFF = vAd & 0xFFF;
c010282b:	88 85 db fd ff ff    	mov    %al,-0x225(%ebp)
                lad.PDI = (vAd >> PTSHIFT) & 0x3FF;
c0102831:	c1 e8 18             	shr    $0x18,%eax
c0102834:	88 85 de fd ff ff    	mov    %al,-0x222(%ebp)
c010283a:	8d 85 db fd ff ff    	lea    -0x225(%ebp),%eax
c0102840:	50                   	push   %eax
c0102841:	8b 45 08             	mov    0x8(%ebp),%eax
                lad.PTI = (vAd >> PGSHIFT) & 0x3FF;
c0102844:	c1 ea 10             	shr    $0x10,%edx
                lad.PDI = (vAd >> PTSHIFT) & 0x3FF;
c0102847:	c1 e9 16             	shr    $0x16,%ecx
c010284a:	80 e2 3f             	and    $0x3f,%dl
c010284d:	c0 e1 06             	shl    $0x6,%cl
c0102850:	ff 70 18             	pushl  0x18(%eax)
c0102853:	08 ca                	or     %cl,%dl
c0102855:	88 95 dd fd ff ff    	mov    %dl,-0x223(%ebp)
c010285b:	50                   	push   %eax
c010285c:	e8 07 fd ff ff       	call   c0102568 <_ZN5PhyMM6getPTEEPN3MMU7PTEntryERKNS0_8LinearADEb>
        pte->setPermission(PTE_P | perm);
c0102861:	8b 55 18             	mov    0x18(%ebp),%edx
    for (uint32_t i = 0; i < n; i++) {
c0102864:	83 c4 10             	add    $0x10,%esp
        pte->setPermission(PTE_P | perm);
c0102867:	83 ca 01             	or     $0x1,%edx
                temp |= perm;
c010286a:	09 10                	or     %edx,(%eax)
        pte->p_ppn = (pad >> PGSHIFT);         // set physical address (20-bits)
c010286c:	8b 55 10             	mov    0x10(%ebp),%edx
c010286f:	89 d1                	mov    %edx,%ecx
c0102871:	c1 e9 0c             	shr    $0xc,%ecx
c0102874:	c0 e1 04             	shl    $0x4,%cl
c0102877:	88 8d c4 fd ff ff    	mov    %cl,-0x23c(%ebp)
c010287d:	8a 48 01             	mov    0x1(%eax),%cl
c0102880:	80 e1 0f             	and    $0xf,%cl
c0102883:	0a 8d c4 fd ff ff    	or     -0x23c(%ebp),%cl
c0102889:	88 48 01             	mov    %cl,0x1(%eax)
c010288c:	89 d1                	mov    %edx,%ecx
c010288e:	c1 e9 10             	shr    $0x10,%ecx
c0102891:	88 48 02             	mov    %cl,0x2(%eax)
c0102894:	89 d1                	mov    %edx,%ecx
        pad += PGSIZE;
c0102896:	81 c2 00 10 00 00    	add    $0x1000,%edx
        pte->p_ppn = (pad >> PGSHIFT);         // set physical address (20-bits)
c010289c:	c1 e9 18             	shr    $0x18,%ecx
c010289f:	88 48 03             	mov    %cl,0x3(%eax)
        lad += PGSIZE;
c01028a2:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
        pad += PGSIZE;
c01028a9:	89 55 10             	mov    %edx,0x10(%ebp)
    for (uint32_t i = 0; i < n; i++) {
c01028ac:	e9 4c ff ff ff       	jmp    c01027fd <_ZN5PhyMM10mapSegmentEjjjj+0x1cd>
    OStream out("\nmapSegment:\n lad: ", "blue");
c01028b1:	83 ec 0c             	sub    $0xc,%esp
c01028b4:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c01028ba:	50                   	push   %eax
c01028bb:	e8 ec f2 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
}
c01028c0:	83 c4 10             	add    $0x10,%esp
c01028c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01028c6:	5b                   	pop    %ebx
c01028c7:	5e                   	pop    %esi
c01028c8:	5f                   	pop    %edi
c01028c9:	5d                   	pop    %ebp
c01028ca:	c3                   	ret    
c01028cb:	90                   	nop

c01028cc <_ZN5PhyMM4initEv>:
void PhyMM::init() {
c01028cc:	55                   	push   %ebp
c01028cd:	89 e5                	mov    %esp,%ebp
c01028cf:	53                   	push   %ebx
c01028d0:	83 ec 10             	sub    $0x10,%esp
c01028d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
    manager = &ff;
c01028d6:	8d 43 20             	lea    0x20(%ebx),%eax
c01028d9:	89 43 3d             	mov    %eax,0x3d(%ebx)
    initPage();
c01028dc:	53                   	push   %ebx
c01028dd:	e8 10 f6 ff ff       	call   c0101ef2 <_ZN5PhyMM8initPageEv>
    bootPDT[LinearAD::LAD(VPT).PDI].p_ppn = (vToPhyAD((uptr32_t)bootPDT) >> PGSHIFT) && 0xFFFFF;
c01028e2:	8b 43 18             	mov    0x18(%ebx),%eax
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c01028e5:	83 c4 10             	add    $0x10,%esp
c01028e8:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c01028ee:	81 fa 00 00 00 38    	cmp    $0x38000000,%edx
c01028f4:	76 02                	jbe    c01028f8 <_ZN5PhyMM4initEv+0x2c>
    return 0;
c01028f6:	31 d2                	xor    %edx,%edx
    bootPDT[LinearAD::LAD(VPT).PDI].p_ppn = (vToPhyAD((uptr32_t)bootPDT) >> PGSHIFT) && 0xFFFFF;
c01028f8:	c1 ea 0c             	shr    $0xc,%edx
c01028fb:	0f 95 c2             	setne  %dl
    mapSegment(KERNEL_BASE, 0, KERNEL_MEM_SIZE, PTE_W);
c01028fe:	83 ec 0c             	sub    $0xc,%esp
    bootPDT[LinearAD::LAD(VPT).PDI].p_ppn = (vToPhyAD((uptr32_t)bootPDT) >> PGSHIFT) && 0xFFFFF;
c0102901:	0f b6 d2             	movzbl %dl,%edx
c0102904:	88 d1                	mov    %dl,%cl
c0102906:	8a 90 ad 0f 00 00    	mov    0xfad(%eax),%dl
c010290c:	c0 e1 04             	shl    $0x4,%cl
c010290f:	c6 80 ae 0f 00 00 00 	movb   $0x0,0xfae(%eax)
c0102916:	c6 80 af 0f 00 00 00 	movb   $0x0,0xfaf(%eax)
c010291d:	80 e2 0f             	and    $0xf,%dl
c0102920:	08 ca                	or     %cl,%dl
c0102922:	88 90 ad 0f 00 00    	mov    %dl,0xfad(%eax)
    bootPDT[LinearAD::LAD(VPT).PDI].p_rw = 1;
c0102928:	80 88 ac 0f 00 00 03 	orb    $0x3,0xfac(%eax)
    mapSegment(KERNEL_BASE, 0, KERNEL_MEM_SIZE, PTE_W);
c010292f:	6a 02                	push   $0x2
c0102931:	68 00 00 00 38       	push   $0x38000000
c0102936:	6a 00                	push   $0x0
c0102938:	68 00 00 00 c0       	push   $0xc0000000
c010293d:	53                   	push   %ebx
c010293e:	e8 ed fc ff ff       	call   c0102630 <_ZN5PhyMM10mapSegmentEjjjj>
    initGDTAndTSS();
c0102943:	83 c4 20             	add    $0x20,%esp
c0102946:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
c0102949:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010294c:	c9                   	leave  
    initGDTAndTSS();
c010294d:	e9 0c fa ff ff       	jmp    c010235e <_ZN5PhyMM13initGDTAndTSSEv>

c0102952 <_ZN5PhyMM6getPDTEv>:
        tlbInvalidData(pdt, lad);
    }
}


MMU::PTEntry * PhyMM::getPDT() {
c0102952:	55                   	push   %ebp
c0102953:	89 e5                	mov    %esp,%ebp
    return bootPDT;
c0102955:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0102958:	5d                   	pop    %ebp
    return bootPDT;
c0102959:	8b 40 18             	mov    0x18(%eax),%eax
}
c010295c:	c3                   	ret    
c010295d:	90                   	nop

c010295e <_ZN5PhyMM10allocPagesEj>:
    if (pte != nullptr) {
        removePTE(pdt, lad, pte);
    }
}

List<MMU::Page>::DLNode * PhyMM::allocPages(uint32_t n) {
c010295e:	e8 66 e2 ff ff       	call   c0100bc9 <__x86.get_pc_thunk.ax>
c0102963:	05 bd fa 01 00       	add    $0x1fabd,%eax
c0102968:	55                   	push   %ebp
c0102969:	89 e5                	mov    %esp,%ebp
c010296b:	57                   	push   %edi
c010296c:	56                   	push   %esi
c010296d:	53                   	push   %ebx
c010296e:	83 ec 1c             	sub    $0x1c,%esp
c0102971:	8b 75 08             	mov    0x8(%ebp),%esi
c0102974:	8b 5d 0c             	mov    0xc(%ebp),%ebx
         }
         local_intr_restore(intr_flag);

         extern int swap_init_ok;

         if (pnode != nullptr || n > 1 || swap_init_ok == 0) break;
c0102977:	c7 c7 34 5a 12 c0    	mov    $0xc0125a34,%edi
         local_intr_save(intr_flag);
c010297d:	e8 bc f4 ff ff       	call   c0101e3e <_ZL11__intr_savev>
c0102982:	88 45 e7             	mov    %al,-0x19(%ebp)
              pnode = manager->allocPages(n);
c0102985:	8b 46 3d             	mov    0x3d(%esi),%eax
c0102988:	52                   	push   %edx
c0102989:	52                   	push   %edx
c010298a:	8b 08                	mov    (%eax),%ecx
c010298c:	53                   	push   %ebx
c010298d:	50                   	push   %eax
c010298e:	ff 51 08             	call   *0x8(%ecx)

static inline void
__intr_restore(bool flag) {
    if (flag) {
c0102991:	8a 55 e7             	mov    -0x19(%ebp),%dl
c0102994:	83 c4 10             	add    $0x10,%esp
c0102997:	84 d2                	test   %dl,%dl
c0102999:	74 01                	je     c010299c <_ZN5PhyMM10allocPagesEj+0x3e>
    asm volatile ("sti");
c010299b:	fb                   	sti    
         if (pnode != nullptr || n > 1 || swap_init_ok == 0) break;
c010299c:	85 c0                	test   %eax,%eax
c010299e:	75 0a                	jne    c01029aa <_ZN5PhyMM10allocPagesEj+0x4c>
c01029a0:	83 fb 01             	cmp    $0x1,%ebx
c01029a3:	77 05                	ja     c01029aa <_ZN5PhyMM10allocPagesEj+0x4c>
c01029a5:	83 3f 00             	cmpl   $0x0,(%edi)
c01029a8:	75 d3                	jne    c010297d <_ZN5PhyMM10allocPagesEj+0x1f>
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         //swap_out(check_mm_struct, n, 0);
    }
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return pnode;
}
c01029aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01029ad:	5b                   	pop    %ebx
c01029ae:	5e                   	pop    %esi
c01029af:	5f                   	pop    %edi
c01029b0:	5d                   	pop    %ebp
c01029b1:	c3                   	ret    

c01029b2 <_ZN5PhyMM9freePagesEPN4ListIN3MMU4PageEE6DLNodeEj>:

    return pnode;
}

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void PhyMM::freePages(List<Page>::DLNode *base, uint32_t n) {
c01029b2:	55                   	push   %ebp
c01029b3:	89 e5                	mov    %esp,%ebp
c01029b5:	83 ec 18             	sub    $0x18,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c01029b8:	e8 81 f4 ff ff       	call   c0101e3e <_ZL11__intr_savev>
    {
        manager->freePages(base, n);
c01029bd:	8b 55 08             	mov    0x8(%ebp),%edx
c01029c0:	8b 52 3d             	mov    0x3d(%edx),%edx
    local_intr_save(intr_flag);
c01029c3:	88 45 f7             	mov    %al,-0x9(%ebp)
        manager->freePages(base, n);
c01029c6:	50                   	push   %eax
c01029c7:	8b 0a                	mov    (%edx),%ecx
c01029c9:	ff 75 10             	pushl  0x10(%ebp)
c01029cc:	ff 75 0c             	pushl  0xc(%ebp)
c01029cf:	52                   	push   %edx
c01029d0:	ff 51 0c             	call   *0xc(%ecx)
c01029d3:	8a 45 f7             	mov    -0x9(%ebp),%al
c01029d6:	83 c4 10             	add    $0x10,%esp
c01029d9:	84 c0                	test   %al,%al
c01029db:	74 01                	je     c01029de <_ZN5PhyMM9freePagesEPN4ListIN3MMU4PageEE6DLNodeEj+0x2c>
c01029dd:	fb                   	sti    
    }
    local_intr_restore(intr_flag);
}
c01029de:	c9                   	leave  
c01029df:	c3                   	ret    

c01029e0 <_ZN5PhyMM7kmallocEj>:


void * PhyMM::kmalloc(uint32_t size) {
c01029e0:	55                   	push   %ebp
c01029e1:	89 e5                	mov    %esp,%ebp
c01029e3:	57                   	push   %edi
c01029e4:	56                   	push   %esi
c01029e5:	53                   	push   %ebx
c01029e6:	e8 e2 e1 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c01029eb:	81 c3 35 fa 01 00    	add    $0x1fa35,%ebx
c01029f1:	81 ec 44 02 00 00    	sub    $0x244,%esp
    DEBUGPRINT("PhyMM::kmalloc");
c01029f7:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01029fd:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0102a03:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0102a09:	50                   	push   %eax
c0102a0a:	56                   	push   %esi
c0102a0b:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c0102a11:	e8 e4 32 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102a16:	58                   	pop    %eax
c0102a17:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0102a1d:	5a                   	pop    %edx
c0102a1e:	8d 93 29 3b fe ff    	lea    -0x1c4d7(%ebx),%edx
c0102a24:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0102a2a:	52                   	push   %edx
c0102a2b:	50                   	push   %eax
c0102a2c:	e8 c9 32 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102a31:	83 c4 0c             	add    $0xc,%esp
c0102a34:	56                   	push   %esi
c0102a35:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0102a3b:	57                   	push   %edi
c0102a3c:	e8 8d f0 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0102a41:	59                   	pop    %ecx
c0102a42:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0102a48:	e8 c7 32 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102a4d:	89 34 24             	mov    %esi,(%esp)
c0102a50:	e8 bf 32 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102a55:	58                   	pop    %eax
c0102a56:	5a                   	pop    %edx
c0102a57:	8d 93 33 3b fe ff    	lea    -0x1c4cd(%ebx),%edx
c0102a5d:	52                   	push   %edx
c0102a5e:	56                   	push   %esi
c0102a5f:	e8 96 32 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102a64:	59                   	pop    %ecx
c0102a65:	58                   	pop    %eax
c0102a66:	56                   	push   %esi
c0102a67:	57                   	push   %edi
c0102a68:	e8 af f1 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102a6d:	89 34 24             	mov    %esi,(%esp)
c0102a70:	e8 9f 32 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102a75:	89 3c 24             	mov    %edi,(%esp)
c0102a78:	e8 eb f0 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c0102a7d:	89 3c 24             	mov    %edi,(%esp)
c0102a80:	e8 27 f1 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
    void * ptr = nullptr;
    List<Page>::DLNode *base = nullptr;
    assert(size > 0 && size < 1024*0124);
c0102a85:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102a88:	83 c4 10             	add    $0x10,%esp
c0102a8b:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102a8e:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0102a94:	81 fa fe 4f 01 00    	cmp    $0x14ffe,%edx
c0102a9a:	76 76                	jbe    c0102b12 <_ZN5PhyMM7kmallocEj+0x132>
c0102a9c:	52                   	push   %edx
c0102a9d:	52                   	push   %edx
c0102a9e:	50                   	push   %eax
c0102a9f:	56                   	push   %esi
c0102aa0:	e8 55 32 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102aa5:	59                   	pop    %ecx
c0102aa6:	58                   	pop    %eax
c0102aa7:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0102aad:	50                   	push   %eax
c0102aae:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0102ab4:	e8 41 32 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102ab9:	83 c4 0c             	add    $0xc,%esp
c0102abc:	56                   	push   %esi
c0102abd:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0102ac3:	57                   	push   %edi
c0102ac4:	e8 05 f0 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0102ac9:	58                   	pop    %eax
c0102aca:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0102ad0:	e8 3f 32 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102ad5:	89 34 24             	mov    %esi,(%esp)
c0102ad8:	e8 37 32 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102add:	58                   	pop    %eax
c0102ade:	8d 83 42 3b fe ff    	lea    -0x1c4be(%ebx),%eax
c0102ae4:	5a                   	pop    %edx
c0102ae5:	50                   	push   %eax
c0102ae6:	56                   	push   %esi
c0102ae7:	e8 0e 32 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102aec:	59                   	pop    %ecx
c0102aed:	58                   	pop    %eax
c0102aee:	56                   	push   %esi
c0102aef:	57                   	push   %edi
c0102af0:	e8 27 f1 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102af5:	89 34 24             	mov    %esi,(%esp)
c0102af8:	e8 17 32 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102afd:	89 3c 24             	mov    %edi,(%esp)
c0102b00:	e8 63 f0 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0102b05:	fa                   	cli    
    asm volatile ("hlt");
c0102b06:	f4                   	hlt    
c0102b07:	89 3c 24             	mov    %edi,(%esp)
c0102b0a:	e8 9d f0 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0102b0f:	83 c4 10             	add    $0x10,%esp
    uint32_t num_pages = (size + PGSIZE - 1 ) / PGSIZE;
    base = allocPages(num_pages);
c0102b12:	50                   	push   %eax
c0102b13:	50                   	push   %eax
    uint32_t num_pages = (size + PGSIZE - 1 ) / PGSIZE;
c0102b14:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102b17:	05 ff 0f 00 00       	add    $0xfff,%eax
c0102b1c:	c1 e8 0c             	shr    $0xc,%eax
    base = allocPages(num_pages);
c0102b1f:	50                   	push   %eax
c0102b20:	ff 75 08             	pushl  0x8(%ebp)
c0102b23:	e8 36 fe ff ff       	call   c010295e <_ZN5PhyMM10allocPagesEj>
    assert(base != nullptr);
c0102b28:	83 c4 10             	add    $0x10,%esp
c0102b2b:	85 c0                	test   %eax,%eax
c0102b2d:	0f 85 9e 00 00 00    	jne    c0102bd1 <_ZN5PhyMM7kmallocEj+0x1f1>
c0102b33:	51                   	push   %ecx
c0102b34:	51                   	push   %ecx
c0102b35:	8d 93 b1 39 fe ff    	lea    -0x1c64f(%ebx),%edx
c0102b3b:	52                   	push   %edx
c0102b3c:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0102b42:	56                   	push   %esi
c0102b43:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c0102b49:	e8 ac 31 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102b4e:	8d 93 bb 39 fe ff    	lea    -0x1c645(%ebx),%edx
c0102b54:	5f                   	pop    %edi
c0102b55:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0102b5b:	58                   	pop    %eax
c0102b5c:	52                   	push   %edx
c0102b5d:	8d 95 d6 fd ff ff    	lea    -0x22a(%ebp),%edx
c0102b63:	52                   	push   %edx
c0102b64:	89 95 c4 fd ff ff    	mov    %edx,-0x23c(%ebp)
c0102b6a:	e8 8b 31 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102b6f:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c0102b75:	83 c4 0c             	add    $0xc,%esp
c0102b78:	56                   	push   %esi
c0102b79:	52                   	push   %edx
c0102b7a:	57                   	push   %edi
c0102b7b:	e8 4e ef ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0102b80:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c0102b86:	89 14 24             	mov    %edx,(%esp)
c0102b89:	e8 86 31 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102b8e:	89 34 24             	mov    %esi,(%esp)
c0102b91:	e8 7e 31 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102b96:	58                   	pop    %eax
c0102b97:	5a                   	pop    %edx
c0102b98:	8d 93 5f 3b fe ff    	lea    -0x1c4a1(%ebx),%edx
c0102b9e:	52                   	push   %edx
c0102b9f:	56                   	push   %esi
c0102ba0:	e8 55 31 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102ba5:	59                   	pop    %ecx
c0102ba6:	58                   	pop    %eax
c0102ba7:	56                   	push   %esi
c0102ba8:	57                   	push   %edi
c0102ba9:	e8 6e f0 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102bae:	89 34 24             	mov    %esi,(%esp)
c0102bb1:	e8 5e 31 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102bb6:	89 3c 24             	mov    %edi,(%esp)
c0102bb9:	e8 aa ef ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0102bbe:	fa                   	cli    
    asm volatile ("hlt");
c0102bbf:	f4                   	hlt    
c0102bc0:	89 3c 24             	mov    %edi,(%esp)
c0102bc3:	e8 e4 ef ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0102bc8:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0102bce:	83 c4 10             	add    $0x10,%esp
    ptr = (void *)pnodeToPageLAD(base);
c0102bd1:	52                   	push   %edx
c0102bd2:	52                   	push   %edx
c0102bd3:	50                   	push   %eax
c0102bd4:	ff 75 08             	pushl  0x8(%ebp)
c0102bd7:	e8 d6 f8 ff ff       	call   c01024b2 <_ZN5PhyMM14pnodeToPageLADEPN4ListIN3MMU4PageEE6DLNodeE>
c0102bdc:	83 c4 10             	add    $0x10,%esp
    return ptr;
}
c0102bdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102be2:	5b                   	pop    %ebx
c0102be3:	5e                   	pop    %esi
c0102be4:	5f                   	pop    %edi
c0102be5:	5d                   	pop    %ebp
c0102be6:	c3                   	ret    
c0102be7:	90                   	nop

c0102be8 <_ZN5PhyMM5kfreeEPvj>:

void PhyMM::kfree(void *ptr, uint32_t size) {
c0102be8:	55                   	push   %ebp
c0102be9:	89 e5                	mov    %esp,%ebp
c0102beb:	57                   	push   %edi
c0102bec:	56                   	push   %esi
c0102bed:	53                   	push   %ebx
c0102bee:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
    assert(size > 0 && size < 1024*0124);
c0102bf4:	8b 45 10             	mov    0x10(%ebp),%eax
c0102bf7:	e8 d1 df ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0102bfc:	81 c3 24 f8 01 00    	add    $0x1f824,%ebx
c0102c02:	48                   	dec    %eax
c0102c03:	3d fe 4f 01 00       	cmp    $0x14ffe,%eax
c0102c08:	0f 86 92 00 00 00    	jbe    c0102ca0 <_ZN5PhyMM5kfreeEPvj+0xb8>
c0102c0e:	50                   	push   %eax
c0102c0f:	50                   	push   %eax
c0102c10:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0102c16:	50                   	push   %eax
c0102c17:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0102c1d:	56                   	push   %esi
c0102c1e:	e8 d7 30 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102c23:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0102c29:	58                   	pop    %eax
c0102c2a:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0102c30:	5a                   	pop    %edx
c0102c31:	50                   	push   %eax
c0102c32:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0102c38:	50                   	push   %eax
c0102c39:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0102c3f:	e8 b6 30 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102c44:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102c4a:	83 c4 0c             	add    $0xc,%esp
c0102c4d:	56                   	push   %esi
c0102c4e:	50                   	push   %eax
c0102c4f:	57                   	push   %edi
c0102c50:	e8 79 ee ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0102c55:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102c5b:	89 04 24             	mov    %eax,(%esp)
c0102c5e:	e8 b1 30 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102c63:	89 34 24             	mov    %esi,(%esp)
c0102c66:	e8 a9 30 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102c6b:	59                   	pop    %ecx
c0102c6c:	58                   	pop    %eax
c0102c6d:	8d 83 42 3b fe ff    	lea    -0x1c4be(%ebx),%eax
c0102c73:	50                   	push   %eax
c0102c74:	56                   	push   %esi
c0102c75:	e8 80 30 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102c7a:	58                   	pop    %eax
c0102c7b:	5a                   	pop    %edx
c0102c7c:	56                   	push   %esi
c0102c7d:	57                   	push   %edi
c0102c7e:	e8 99 ef ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102c83:	89 34 24             	mov    %esi,(%esp)
c0102c86:	e8 89 30 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102c8b:	89 3c 24             	mov    %edi,(%esp)
c0102c8e:	e8 d5 ee ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0102c93:	fa                   	cli    
    asm volatile ("hlt");
c0102c94:	f4                   	hlt    
c0102c95:	89 3c 24             	mov    %edi,(%esp)
c0102c98:	e8 0f ef ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0102c9d:	83 c4 10             	add    $0x10,%esp
    assert(ptr != nullptr);
c0102ca0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102ca4:	0f 85 92 00 00 00    	jne    c0102d3c <_ZN5PhyMM5kfreeEPvj+0x154>
c0102caa:	56                   	push   %esi
c0102cab:	56                   	push   %esi
c0102cac:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0102cb2:	50                   	push   %eax
c0102cb3:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0102cb9:	56                   	push   %esi
c0102cba:	e8 3b 30 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102cbf:	5f                   	pop    %edi
c0102cc0:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0102cc6:	58                   	pop    %eax
c0102cc7:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0102ccd:	50                   	push   %eax
c0102cce:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0102cd4:	50                   	push   %eax
c0102cd5:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0102cdb:	e8 1a 30 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102ce0:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102ce6:	83 c4 0c             	add    $0xc,%esp
c0102ce9:	56                   	push   %esi
c0102cea:	50                   	push   %eax
c0102ceb:	57                   	push   %edi
c0102cec:	e8 dd ed ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0102cf1:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102cf7:	89 04 24             	mov    %eax,(%esp)
c0102cfa:	e8 15 30 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102cff:	89 34 24             	mov    %esi,(%esp)
c0102d02:	e8 0d 30 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102d07:	58                   	pop    %eax
c0102d08:	8d 83 6f 3b fe ff    	lea    -0x1c491(%ebx),%eax
c0102d0e:	5a                   	pop    %edx
c0102d0f:	50                   	push   %eax
c0102d10:	56                   	push   %esi
c0102d11:	e8 e4 2f 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102d16:	59                   	pop    %ecx
c0102d17:	58                   	pop    %eax
c0102d18:	56                   	push   %esi
c0102d19:	57                   	push   %edi
c0102d1a:	e8 fd ee ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102d1f:	89 34 24             	mov    %esi,(%esp)
c0102d22:	e8 ed 2f 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102d27:	89 3c 24             	mov    %edi,(%esp)
c0102d2a:	e8 39 ee ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0102d2f:	fa                   	cli    
    asm volatile ("hlt");
c0102d30:	f4                   	hlt    
c0102d31:	89 3c 24             	mov    %edi,(%esp)
c0102d34:	e8 73 ee ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0102d39:	83 c4 10             	add    $0x10,%esp
    List<Page>::DLNode *base = nullptr;
    uint32_t num_pages = (size + PGSIZE - 1) / PGSIZE;
c0102d3c:	8b 45 10             	mov    0x10(%ebp),%eax
c0102d3f:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c0102d45:	8b 45 0c             	mov    0xc(%ebp),%eax
    uint32_t num_pages = (size + PGSIZE - 1) / PGSIZE;
c0102d48:	c1 ea 0c             	shr    $0xc,%edx
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c0102d4b:	05 00 00 00 40       	add    $0x40000000,%eax
c0102d50:	3d 00 00 00 38       	cmp    $0x38000000,%eax
c0102d55:	76 02                	jbe    c0102d59 <_ZN5PhyMM5kfreeEPvj+0x171>
    return 0;
c0102d57:	31 c0                	xor    %eax,%eax
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
c0102d59:	c1 e8 0c             	shr    $0xc,%eax
    base = phyAdToPgNode(vToPhyAD((uptr32_t)ptr));
    freePages(base, num_pages);
c0102d5c:	51                   	push   %ecx
    return &(pNodeArr[pIndex]);
c0102d5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0102d60:	6b c0 11             	imul   $0x11,%eax,%eax
    freePages(base, num_pages);
c0102d63:	52                   	push   %edx
    return &(pNodeArr[pIndex]);
c0102d64:	03 41 41             	add    0x41(%ecx),%eax
    freePages(base, num_pages);
c0102d67:	50                   	push   %eax
c0102d68:	51                   	push   %ecx
c0102d69:	e8 44 fc ff ff       	call   c01029b2 <_ZN5PhyMM9freePagesEPN4ListIN3MMU4PageEE6DLNodeEj>
}
c0102d6e:	83 c4 10             	add    $0x10,%esp
c0102d71:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102d74:	5b                   	pop    %ebx
c0102d75:	5e                   	pop    %esi
c0102d76:	5f                   	pop    %edi
c0102d77:	5d                   	pop    %ebp
c0102d78:	c3                   	ret    
c0102d79:	90                   	nop

c0102d7a <_ZN5PhyMM12numFreePagesEv>:

uint32_t PhyMM::numFreePages() {
c0102d7a:	55                   	push   %ebp
c0102d7b:	89 e5                	mov    %esp,%ebp
c0102d7d:	83 ec 18             	sub    $0x18,%esp
    uint32_t ret;
    bool intr_flag;
    local_intr_save(intr_flag); 
c0102d80:	e8 b9 f0 ff ff       	call   c0101e3e <_ZL11__intr_savev>
    {
        ret = manager->numFreePages();
c0102d85:	83 ec 0c             	sub    $0xc,%esp
    local_intr_save(intr_flag); 
c0102d88:	88 45 f7             	mov    %al,-0x9(%ebp)
        ret = manager->numFreePages();
c0102d8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d8e:	8b 40 3d             	mov    0x3d(%eax),%eax
c0102d91:	8b 08                	mov    (%eax),%ecx
c0102d93:	50                   	push   %eax
c0102d94:	ff 51 10             	call   *0x10(%ecx)
c0102d97:	8a 55 f7             	mov    -0x9(%ebp),%dl
c0102d9a:	83 c4 10             	add    $0x10,%esp
c0102d9d:	84 d2                	test   %dl,%dl
c0102d9f:	74 01                	je     c0102da2 <_ZN5PhyMM12numFreePagesEv+0x28>
    asm volatile ("sti");
c0102da1:	fb                   	sti    
    }
    local_intr_restore(intr_flag);
    return ret;
}
c0102da2:	c9                   	leave  
c0102da3:	c3                   	ret    

c0102da4 <_ZN5PhyMM14tlbInvalidDataEPN3MMU7PTEntryENS0_8LinearADE>:

void PhyMM::tlbInvalidData(PTEntry *pdt, LinearAD lad) {
c0102da4:	55                   	push   %ebp
c0102da5:	89 e5                	mov    %esp,%ebp
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0102da7:	0f 20 da             	mov    %cr3,%edx
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c0102daa:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102dad:	05 00 00 00 40       	add    $0x40000000,%eax
c0102db2:	3d 00 00 00 38       	cmp    $0x38000000,%eax
c0102db7:	76 02                	jbe    c0102dbb <_ZN5PhyMM14tlbInvalidDataEPN3MMU7PTEntryENS0_8LinearADE+0x17>
    return 0;
c0102db9:	31 c0                	xor    %eax,%eax
    if (getCR3() == vToPhyAD((uptr32_t)pdt)) {
c0102dbb:	39 d0                	cmp    %edx,%eax
c0102dbd:	75 06                	jne    c0102dc5 <_ZN5PhyMM14tlbInvalidDataEPN3MMU7PTEntryENS0_8LinearADE+0x21>
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0102dbf:	8b 45 10             	mov    0x10(%ebp),%eax
c0102dc2:	0f 01 38             	invlpg (%eax)
        invlpg((void *)(lad.Integer()));
    }
c0102dc5:	5d                   	pop    %ebp
c0102dc6:	c3                   	ret    
c0102dc7:	90                   	nop

c0102dc8 <_ZN5PhyMM9removePTEEPN3MMU7PTEntryERKNS0_8LinearADES2_>:
void PhyMM::removePTE(PTEntry *pdt, const LinearAD &lad, PTEntry *pte) {
c0102dc8:	55                   	push   %ebp
c0102dc9:	89 e5                	mov    %esp,%ebp
c0102dcb:	57                   	push   %edi
c0102dcc:	56                   	push   %esi
c0102dcd:	53                   	push   %ebx
c0102dce:	e8 fa dd ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0102dd3:	81 c3 4d f6 01 00    	add    $0x1f64d,%ebx
c0102dd9:	81 ec 44 02 00 00    	sub    $0x244,%esp
c0102ddf:	8b 55 14             	mov    0x14(%ebp),%edx
    DEBUGPRINT("PhyMM::removePTE");
c0102de2:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
void PhyMM::removePTE(PTEntry *pdt, const LinearAD &lad, PTEntry *pte) {
c0102de8:	89 95 c0 fd ff ff    	mov    %edx,-0x240(%ebp)
    DEBUGPRINT("PhyMM::removePTE");
c0102dee:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0102df4:	50                   	push   %eax
c0102df5:	56                   	push   %esi
c0102df6:	e8 ff 2e 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102dfb:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c0102e01:	59                   	pop    %ecx
c0102e02:	5f                   	pop    %edi
c0102e03:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0102e09:	50                   	push   %eax
c0102e0a:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0102e10:	50                   	push   %eax
c0102e11:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0102e17:	e8 de 2e 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102e1c:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102e22:	83 c4 0c             	add    $0xc,%esp
c0102e25:	56                   	push   %esi
c0102e26:	50                   	push   %eax
c0102e27:	57                   	push   %edi
c0102e28:	e8 a1 ec ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0102e2d:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102e33:	89 04 24             	mov    %eax,(%esp)
c0102e36:	e8 d9 2e 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102e3b:	89 34 24             	mov    %esi,(%esp)
c0102e3e:	e8 d1 2e 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102e43:	58                   	pop    %eax
c0102e44:	8d 83 7e 3b fe ff    	lea    -0x1c482(%ebx),%eax
c0102e4a:	5a                   	pop    %edx
c0102e4b:	50                   	push   %eax
c0102e4c:	56                   	push   %esi
c0102e4d:	e8 a8 2e 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102e52:	59                   	pop    %ecx
c0102e53:	58                   	pop    %eax
c0102e54:	56                   	push   %esi
c0102e55:	57                   	push   %edi
c0102e56:	e8 c1 ed ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102e5b:	89 34 24             	mov    %esi,(%esp)
c0102e5e:	e8 b1 2e 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102e63:	89 3c 24             	mov    %edi,(%esp)
c0102e66:	e8 fd ec ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c0102e6b:	89 3c 24             	mov    %edi,(%esp)
c0102e6e:	e8 39 ed ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
     if (pte->p_p) {
c0102e73:	8b 95 c0 fd ff ff    	mov    -0x240(%ebp),%edx
c0102e79:	83 c4 10             	add    $0x10,%esp
c0102e7c:	f6 02 01             	testb  $0x1,(%edx)
c0102e7f:	74 5b                	je     c0102edc <_ZN5PhyMM9removePTEEPN3MMU7PTEntryERKNS0_8LinearADES2_+0x114>
    return &(pNodeArr[pte.p_ppn]);
c0102e81:	8a 42 01             	mov    0x1(%edx),%al
c0102e84:	8b 7d 08             	mov    0x8(%ebp),%edi
c0102e87:	c0 e8 04             	shr    $0x4,%al
c0102e8a:	0f b6 c8             	movzbl %al,%ecx
c0102e8d:	0f b6 42 02          	movzbl 0x2(%edx),%eax
c0102e91:	c1 e0 04             	shl    $0x4,%eax
c0102e94:	09 c1                	or     %eax,%ecx
c0102e96:	0f b6 42 03          	movzbl 0x3(%edx),%eax
c0102e9a:	c1 e0 0c             	shl    $0xc,%eax
c0102e9d:	09 c8                	or     %ecx,%eax
c0102e9f:	6b c0 11             	imul   $0x11,%eax,%eax
c0102ea2:	03 47 41             	add    0x41(%edi),%eax
        if (--(pnode->data.ref) == 0) {
c0102ea5:	ff 08                	decl   (%eax)
c0102ea7:	75 19                	jne    c0102ec2 <_ZN5PhyMM9removePTEEPN3MMU7PTEntryERKNS0_8LinearADES2_+0xfa>
c0102ea9:	89 95 c4 fd ff ff    	mov    %edx,-0x23c(%ebp)
            freePages(pnode);
c0102eaf:	52                   	push   %edx
c0102eb0:	6a 01                	push   $0x1
c0102eb2:	50                   	push   %eax
c0102eb3:	57                   	push   %edi
c0102eb4:	e8 f9 fa ff ff       	call   c01029b2 <_ZN5PhyMM9freePagesEPN4ListIN3MMU4PageEE6DLNodeEj>
c0102eb9:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c0102ebf:	83 c4 10             	add    $0x10,%esp
                p[i] = byte;
c0102ec2:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
        tlbInvalidData(pdt, lad);
c0102ec8:	50                   	push   %eax
c0102ec9:	8b 45 10             	mov    0x10(%ebp),%eax
c0102ecc:	ff 30                	pushl  (%eax)
c0102ece:	ff 75 0c             	pushl  0xc(%ebp)
c0102ed1:	ff 75 08             	pushl  0x8(%ebp)
c0102ed4:	e8 cb fe ff ff       	call   c0102da4 <_ZN5PhyMM14tlbInvalidDataEPN3MMU7PTEntryENS0_8LinearADE>
c0102ed9:	83 c4 10             	add    $0x10,%esp
}
c0102edc:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102edf:	5b                   	pop    %ebx
c0102ee0:	5e                   	pop    %esi
c0102ee1:	5f                   	pop    %edi
c0102ee2:	5d                   	pop    %ebp
c0102ee3:	c3                   	ret    

c0102ee4 <_ZN5PhyMM10removePageEPN3MMU7PTEntryENS0_8LinearADE>:
void PhyMM::removePage(PTEntry *pdt, LinearAD lad) {
c0102ee4:	55                   	push   %ebp
c0102ee5:	89 e5                	mov    %esp,%ebp
c0102ee7:	57                   	push   %edi
c0102ee8:	56                   	push   %esi
c0102ee9:	53                   	push   %ebx
c0102eea:	83 ec 0c             	sub    $0xc,%esp
c0102eed:	8b 75 0c             	mov    0xc(%ebp),%esi
    auto pte = getPTE(pdt, lad, false);
c0102ef0:	8d 7d 10             	lea    0x10(%ebp),%edi
void PhyMM::removePage(PTEntry *pdt, LinearAD lad) {
c0102ef3:	8b 5d 08             	mov    0x8(%ebp),%ebx
    auto pte = getPTE(pdt, lad, false);
c0102ef6:	6a 00                	push   $0x0
c0102ef8:	57                   	push   %edi
c0102ef9:	56                   	push   %esi
c0102efa:	53                   	push   %ebx
c0102efb:	e8 68 f6 ff ff       	call   c0102568 <_ZN5PhyMM6getPTEEPN3MMU7PTEntryERKNS0_8LinearADEb>
    if (pte != nullptr) {
c0102f00:	83 c4 10             	add    $0x10,%esp
c0102f03:	85 c0                	test   %eax,%eax
c0102f05:	74 0c                	je     c0102f13 <_ZN5PhyMM10removePageEPN3MMU7PTEntryENS0_8LinearADE+0x2f>
        removePTE(pdt, lad, pte);
c0102f07:	50                   	push   %eax
c0102f08:	57                   	push   %edi
c0102f09:	56                   	push   %esi
c0102f0a:	53                   	push   %ebx
c0102f0b:	e8 b8 fe ff ff       	call   c0102dc8 <_ZN5PhyMM9removePTEEPN3MMU7PTEntryERKNS0_8LinearADES2_>
c0102f10:	83 c4 10             	add    $0x10,%esp
}
c0102f13:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102f16:	5b                   	pop    %ebx
c0102f17:	5e                   	pop    %esi
c0102f18:	5f                   	pop    %edi
c0102f19:	5d                   	pop    %ebp
c0102f1a:	c3                   	ret    
c0102f1b:	90                   	nop

c0102f1c <_ZN5PhyMM7mapPageEPN3MMU7PTEntryEPN4ListINS0_4PageEE6DLNodeENS0_8LinearADEj>:
int PhyMM::mapPage(PTEntry *pdt, List<Page>::DLNode *pnode, LinearAD lad, uint32_t perm) {
c0102f1c:	55                   	push   %ebp
c0102f1d:	89 e5                	mov    %esp,%ebp
c0102f1f:	57                   	push   %edi
c0102f20:	56                   	push   %esi
c0102f21:	53                   	push   %ebx
c0102f22:	e8 a6 dc ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0102f27:	81 c3 f9 f4 01 00    	add    $0x1f4f9,%ebx
c0102f2d:	81 ec 44 02 00 00    	sub    $0x244,%esp
c0102f33:	8b 4d 10             	mov    0x10(%ebp),%ecx
    DEBUGPRINT("PhyMM::mapPage");
c0102f36:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0102f3c:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
int PhyMM::mapPage(PTEntry *pdt, List<Page>::DLNode *pnode, LinearAD lad, uint32_t perm) {
c0102f42:	89 8d c0 fd ff ff    	mov    %ecx,-0x240(%ebp)
    DEBUGPRINT("PhyMM::mapPage");
c0102f48:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0102f4e:	50                   	push   %eax
c0102f4f:	56                   	push   %esi
c0102f50:	e8 a5 2d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102f55:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c0102f5b:	5a                   	pop    %edx
c0102f5c:	59                   	pop    %ecx
c0102f5d:	50                   	push   %eax
c0102f5e:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0102f64:	50                   	push   %eax
c0102f65:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0102f6b:	e8 8a 2d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102f70:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102f76:	83 c4 0c             	add    $0xc,%esp
c0102f79:	56                   	push   %esi
c0102f7a:	50                   	push   %eax
c0102f7b:	57                   	push   %edi
c0102f7c:	e8 4d eb ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0102f81:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102f87:	89 04 24             	mov    %eax,(%esp)
c0102f8a:	e8 85 2d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102f8f:	89 34 24             	mov    %esi,(%esp)
c0102f92:	e8 7d 2d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102f97:	58                   	pop    %eax
c0102f98:	8d 83 8f 3b fe ff    	lea    -0x1c471(%ebx),%eax
c0102f9e:	5a                   	pop    %edx
c0102f9f:	50                   	push   %eax
c0102fa0:	56                   	push   %esi
c0102fa1:	e8 54 2d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0102fa6:	59                   	pop    %ecx
c0102fa7:	58                   	pop    %eax
c0102fa8:	56                   	push   %esi
c0102fa9:	57                   	push   %edi
c0102faa:	e8 6d ec ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0102faf:	89 34 24             	mov    %esi,(%esp)
c0102fb2:	e8 5d 2d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0102fb7:	89 3c 24             	mov    %edi,(%esp)
c0102fba:	e8 a9 eb ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c0102fbf:	89 3c 24             	mov    %edi,(%esp)
c0102fc2:	e8 e5 eb ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
    auto pte = getPTE(pdt, lad);
c0102fc7:	8d 5d 14             	lea    0x14(%ebp),%ebx
c0102fca:	6a 01                	push   $0x1
c0102fcc:	53                   	push   %ebx
c0102fcd:	ff 75 0c             	pushl  0xc(%ebp)
c0102fd0:	ff 75 08             	pushl  0x8(%ebp)
c0102fd3:	e8 90 f5 ff ff       	call   c0102568 <_ZN5PhyMM6getPTEEPN3MMU7PTEntryERKNS0_8LinearADEb>
    if (pte == nullptr) {
c0102fd8:	83 c4 20             	add    $0x20,%esp
    auto pte = getPTE(pdt, lad);
c0102fdb:	89 c6                	mov    %eax,%esi
c0102fdd:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
    if (pte == nullptr) {
c0102fe2:	85 f6                	test   %esi,%esi
c0102fe4:	0f 84 9d 00 00 00    	je     c0103087 <_ZN5PhyMM7mapPageEPN3MMU7PTEntryEPN4ListINS0_4PageEE6DLNodeENS0_8LinearADEj+0x16b>
    if (pte->p_p) {         // is present?
c0102fea:	f6 06 01             	testb  $0x1,(%esi)
c0102fed:	8b 8d c0 fd ff ff    	mov    -0x240(%ebp),%ecx
c0102ff3:	74 48                	je     c010303d <_ZN5PhyMM7mapPageEPN3MMU7PTEntryEPN4ListINS0_4PageEE6DLNodeENS0_8LinearADEj+0x121>
    return &(pNodeArr[pte.p_ppn]);
c0102ff5:	8a 56 01             	mov    0x1(%esi),%dl
c0102ff8:	0f b6 46 03          	movzbl 0x3(%esi),%eax
c0102ffc:	c0 ea 04             	shr    $0x4,%dl
c0102fff:	0f b6 fa             	movzbl %dl,%edi
c0103002:	0f b6 56 02          	movzbl 0x2(%esi),%edx
c0103006:	c1 e0 0c             	shl    $0xc,%eax
c0103009:	c1 e2 04             	shl    $0x4,%edx
c010300c:	09 fa                	or     %edi,%edx
c010300e:	8b 7d 08             	mov    0x8(%ebp),%edi
c0103011:	09 d0                	or     %edx,%eax
c0103013:	6b c0 11             	imul   $0x11,%eax,%eax
c0103016:	03 47 41             	add    0x41(%edi),%eax
        if (oldPnode == pnode) {
c0103019:	39 c1                	cmp    %eax,%ecx
c010301b:	75 04                	jne    c0103021 <_ZN5PhyMM7mapPageEPN3MMU7PTEntryEPN4ListINS0_4PageEE6DLNodeENS0_8LinearADEj+0x105>
            pnode->data.ref--;
c010301d:	ff 09                	decl   (%ecx)
c010301f:	eb 1c                	jmp    c010303d <_ZN5PhyMM7mapPageEPN3MMU7PTEntryEPN4ListINS0_4PageEE6DLNodeENS0_8LinearADEj+0x121>
            removePTE(pdt, lad, pte);
c0103021:	56                   	push   %esi
c0103022:	53                   	push   %ebx
c0103023:	ff 75 0c             	pushl  0xc(%ebp)
c0103026:	89 8d c4 fd ff ff    	mov    %ecx,-0x23c(%ebp)
c010302c:	ff 75 08             	pushl  0x8(%ebp)
c010302f:	e8 94 fd ff ff       	call   c0102dc8 <_ZN5PhyMM9removePTEEPN3MMU7PTEntryERKNS0_8LinearADES2_>
c0103034:	8b 8d c4 fd ff ff    	mov    -0x23c(%ebp),%ecx
c010303a:	83 c4 10             	add    $0x10,%esp
c010303d:	8b 45 18             	mov    0x18(%ebp),%eax
    pte->p_ppn = pnode - pNodeArr;      // back     2
c0103040:	89 ca                	mov    %ecx,%edx
c0103042:	09 06                	or     %eax,(%esi)
c0103044:	8b 45 08             	mov    0x8(%ebp),%eax
c0103047:	8a 5e 01             	mov    0x1(%esi),%bl
c010304a:	2b 50 41             	sub    0x41(%eax),%edx
    pte->p_p = 1;
c010304d:	80 0e 01             	orb    $0x1,(%esi)
    pte->p_ppn = pnode - pNodeArr;      // back     2
c0103050:	80 e3 0f             	and    $0xf,%bl
c0103053:	69 d2 f1 f0 f0 f0    	imul   $0xf0f0f0f1,%edx,%edx
c0103059:	88 d0                	mov    %dl,%al
c010305b:	c0 e0 04             	shl    $0x4,%al
c010305e:	08 c3                	or     %al,%bl
c0103060:	89 d0                	mov    %edx,%eax
c0103062:	c1 e8 04             	shr    $0x4,%eax
c0103065:	c1 ea 0c             	shr    $0xc,%edx
c0103068:	88 46 02             	mov    %al,0x2(%esi)
c010306b:	88 5e 01             	mov    %bl,0x1(%esi)
c010306e:	88 56 03             	mov    %dl,0x3(%esi)
    pnode->data.ref++;
c0103071:	ff 01                	incl   (%ecx)
    tlbInvalidData(pdt, lad);
c0103073:	50                   	push   %eax
c0103074:	ff 75 14             	pushl  0x14(%ebp)
c0103077:	ff 75 0c             	pushl  0xc(%ebp)
c010307a:	ff 75 08             	pushl  0x8(%ebp)
c010307d:	e8 22 fd ff ff       	call   c0102da4 <_ZN5PhyMM14tlbInvalidDataEPN3MMU7PTEntryENS0_8LinearADE>
    return 0;
c0103082:	83 c4 10             	add    $0x10,%esp
c0103085:	31 c0                	xor    %eax,%eax
}
c0103087:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010308a:	5b                   	pop    %ebx
c010308b:	5e                   	pop    %esi
c010308c:	5f                   	pop    %edi
c010308d:	5d                   	pop    %ebp
c010308e:	c3                   	ret    
c010308f:	90                   	nop

c0103090 <_ZN5PhyMM15allocPageAndMapEPN3MMU7PTEntryENS0_8LinearADEj>:
List<MMU::Page>::DLNode * PhyMM::allocPageAndMap(PTEntry *pdt, LinearAD lad, uint32_t perm) {
c0103090:	55                   	push   %ebp
c0103091:	89 e5                	mov    %esp,%ebp
c0103093:	57                   	push   %edi
c0103094:	56                   	push   %esi
c0103095:	53                   	push   %ebx
c0103096:	e8 32 db ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c010309b:	81 c3 85 f3 01 00    	add    $0x1f385,%ebx
c01030a1:	81 ec 44 02 00 00    	sub    $0x244,%esp
    DEBUGPRINT("PhyMM::allocPageAndMap");
c01030a7:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01030ad:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01030b3:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c01030b9:	50                   	push   %eax
c01030ba:	56                   	push   %esi
c01030bb:	e8 3a 2c 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01030c0:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c01030c6:	5a                   	pop    %edx
c01030c7:	59                   	pop    %ecx
c01030c8:	50                   	push   %eax
c01030c9:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c01030cf:	50                   	push   %eax
c01030d0:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c01030d6:	e8 1f 2c 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01030db:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c01030e1:	83 c4 0c             	add    $0xc,%esp
c01030e4:	56                   	push   %esi
c01030e5:	50                   	push   %eax
c01030e6:	57                   	push   %edi
c01030e7:	e8 e2 e9 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01030ec:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c01030f2:	89 04 24             	mov    %eax,(%esp)
c01030f5:	e8 1a 2c 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01030fa:	89 34 24             	mov    %esi,(%esp)
c01030fd:	e8 12 2c 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103102:	58                   	pop    %eax
c0103103:	8d 83 9e 3b fe ff    	lea    -0x1c462(%ebx),%eax
c0103109:	5a                   	pop    %edx
c010310a:	50                   	push   %eax
c010310b:	56                   	push   %esi
c010310c:	e8 e9 2b 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103111:	59                   	pop    %ecx
c0103112:	58                   	pop    %eax
c0103113:	56                   	push   %esi
c0103114:	57                   	push   %edi
c0103115:	e8 02 eb ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c010311a:	89 34 24             	mov    %esi,(%esp)
c010311d:	e8 f2 2b 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103122:	89 3c 24             	mov    %edi,(%esp)
c0103125:	e8 3e ea ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c010312a:	89 3c 24             	mov    %edi,(%esp)
c010312d:	e8 7a ea ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
    auto pnode = allocPages();
c0103132:	58                   	pop    %eax
c0103133:	5a                   	pop    %edx
c0103134:	6a 01                	push   $0x1
c0103136:	ff 75 08             	pushl  0x8(%ebp)
c0103139:	e8 20 f8 ff ff       	call   c010295e <_ZN5PhyMM10allocPagesEj>
    if (pnode != nullptr) {
c010313e:	83 c4 10             	add    $0x10,%esp
c0103141:	85 c0                	test   %eax,%eax
    auto pnode = allocPages();
c0103143:	89 c3                	mov    %eax,%ebx
    if (pnode != nullptr) {
c0103145:	74 2d                	je     c0103174 <_ZN5PhyMM15allocPageAndMapEPN3MMU7PTEntryENS0_8LinearADEj+0xe4>
        if (mapPage(pdt, pnode, lad, perm) != 0) {
c0103147:	83 ec 0c             	sub    $0xc,%esp
c010314a:	ff 75 14             	pushl  0x14(%ebp)
c010314d:	ff 75 10             	pushl  0x10(%ebp)
c0103150:	50                   	push   %eax
c0103151:	ff 75 0c             	pushl  0xc(%ebp)
c0103154:	ff 75 08             	pushl  0x8(%ebp)
c0103157:	e8 c0 fd ff ff       	call   c0102f1c <_ZN5PhyMM7mapPageEPN3MMU7PTEntryEPN4ListINS0_4PageEE6DLNodeENS0_8LinearADEj>
c010315c:	83 c4 20             	add    $0x20,%esp
c010315f:	85 c0                	test   %eax,%eax
c0103161:	74 11                	je     c0103174 <_ZN5PhyMM15allocPageAndMapEPN3MMU7PTEntryENS0_8LinearADEj+0xe4>
            freePages(pnode);
c0103163:	50                   	push   %eax
c0103164:	6a 01                	push   $0x1
c0103166:	53                   	push   %ebx
            return nullptr;
c0103167:	31 db                	xor    %ebx,%ebx
            freePages(pnode);
c0103169:	ff 75 08             	pushl  0x8(%ebp)
c010316c:	e8 41 f8 ff ff       	call   c01029b2 <_ZN5PhyMM9freePagesEPN4ListIN3MMU4PageEE6DLNodeEj>
            return nullptr;
c0103171:	83 c4 10             	add    $0x10,%esp
}
c0103174:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0103177:	89 d8                	mov    %ebx,%eax
c0103179:	5b                   	pop    %ebx
c010317a:	5e                   	pop    %esi
c010317b:	5f                   	pop    %edi
c010317c:	5d                   	pop    %ebp
c010317d:	c3                   	ret    

c010317e <_ZN4FFMA12numFreePagesEv>:
        freeArea.insertLNode(pnode->pre, pnArr);
    }
    nfp += n;
}

uint32_t FFMA::numFreePages() {
c010317e:	55                   	push   %ebp
c010317f:	89 e5                	mov    %esp,%ebp
    return nfp;
c0103181:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0103184:	5d                   	pop    %ebp
    return nfp;
c0103185:	8b 40 19             	mov    0x19(%eax),%eax
}
c0103188:	c3                   	ret    
c0103189:	90                   	nop

c010318a <_ZN4FFMA4initEv>:
void FFMA::init() {
c010318a:	55                   	push   %ebp
c010318b:	89 e5                	mov    %esp,%ebp
c010318d:	53                   	push   %ebx
c010318e:	e8 3a da ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0103193:	81 c3 8d f2 01 00    	add    $0x1f28d,%ebx
c0103199:	83 ec 0c             	sub    $0xc,%esp
    name = "First-Fit Memory Allocation (FFMA) Algorithm";
c010319c:	8d 83 b5 3b fe ff    	lea    -0x1c44b(%ebx),%eax
c01031a2:	50                   	push   %eax
c01031a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01031a6:	83 c0 04             	add    $0x4,%eax
c01031a9:	50                   	push   %eax
c01031aa:	e8 6b 2b 00 00       	call   c0105d1a <_ZN6StringaSEPKc>
}
c01031af:	83 c4 10             	add    $0x10,%esp
c01031b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01031b5:	c9                   	leave  
c01031b6:	c3                   	ret    
c01031b7:	90                   	nop

c01031b8 <_ZN4FFMA10initMemMapEPN4ListIN3MMU4PageEE6DLNodeEj>:
void FFMA::initMemMap(List<MMU::Page>::DLNode *pArr, uint32_t num) {
c01031b8:	55                   	push   %ebp
c01031b9:	89 e5                	mov    %esp,%ebp
c01031bb:	57                   	push   %edi
c01031bc:	56                   	push   %esi
c01031bd:	53                   	push   %ebx
c01031be:	e8 0a da ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c01031c3:	81 c3 5d f2 01 00    	add    $0x1f25d,%ebx
c01031c9:	81 ec 44 02 00 00    	sub    $0x244,%esp
    OStream out("\n\ninitMemMap:\n\n firstAd = ", "red");
c01031cf:	8d b5 d8 fd ff ff    	lea    -0x228(%ebp),%esi
c01031d5:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c01031db:	50                   	push   %eax
c01031dc:	56                   	push   %esi
c01031dd:	e8 18 2b 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01031e2:	8d 83 e2 3b fe ff    	lea    -0x1c41e(%ebx),%eax
c01031e8:	59                   	pop    %ecx
c01031e9:	5f                   	pop    %edi
c01031ea:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01031f0:	50                   	push   %eax
c01031f1:	8d 85 d3 fd ff ff    	lea    -0x22d(%ebp),%eax
c01031f7:	50                   	push   %eax
c01031f8:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c01031fe:	e8 f7 2a 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103203:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0103209:	83 c4 0c             	add    $0xc,%esp
c010320c:	56                   	push   %esi
c010320d:	50                   	push   %eax
c010320e:	57                   	push   %edi
c010320f:	e8 ba e8 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0103214:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c010321a:	89 04 24             	mov    %eax,(%esp)
c010321d:	e8 f2 2a 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103222:	89 34 24             	mov    %esi,(%esp)
c0103225:	e8 ea 2a 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue((uint32_t)pArr);
c010322a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010322d:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0103233:	89 85 d8 fd ff ff    	mov    %eax,-0x228(%ebp)
c0103239:	58                   	pop    %eax
c010323a:	5a                   	pop    %edx
c010323b:	56                   	push   %esi
c010323c:	57                   	push   %edi
c010323d:	e8 1e ea ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    out.write("\n num = ");
c0103242:	8d 93 fd 3b fe ff    	lea    -0x1c403(%ebx),%edx
c0103248:	59                   	pop    %ecx
c0103249:	58                   	pop    %eax
c010324a:	52                   	push   %edx
c010324b:	56                   	push   %esi
c010324c:	e8 a9 2a 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103251:	58                   	pop    %eax
c0103252:	5a                   	pop    %edx
c0103253:	56                   	push   %esi
c0103254:	57                   	push   %edi
c0103255:	e8 c2 e9 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c010325a:	89 34 24             	mov    %esi,(%esp)
c010325d:	e8 b2 2a 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue(num);
c0103262:	8d 55 10             	lea    0x10(%ebp),%edx
c0103265:	59                   	pop    %ecx
c0103266:	58                   	pop    %eax
c0103267:	52                   	push   %edx
c0103268:	57                   	push   %edi
c0103269:	e8 f2 e9 ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    out.write("\n");
c010326e:	58                   	pop    %eax
c010326f:	5a                   	pop    %edx
c0103270:	8d 93 af 39 fe ff    	lea    -0x1c651(%ebx),%edx
c0103276:	52                   	push   %edx
c0103277:	56                   	push   %esi
c0103278:	e8 7d 2a 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010327d:	59                   	pop    %ecx
c010327e:	58                   	pop    %eax
c010327f:	56                   	push   %esi
c0103280:	57                   	push   %edi
c0103281:	e8 96 e9 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0103286:	89 34 24             	mov    %esi,(%esp)
c0103289:	e8 86 2a 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.flush();
c010328e:	89 3c 24             	mov    %edi,(%esp)
c0103291:	e8 d2 e8 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    for (uint32_t i = 0; i < num; i++) {    // init Page struct for the mem-area
c0103296:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0103299:	83 c4 10             	add    $0x10,%esp
c010329c:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c01032a2:	6b d1 11             	imul   $0x11,%ecx,%edx
c01032a5:	03 55 0c             	add    0xc(%ebp),%edx
c01032a8:	39 d0                	cmp    %edx,%eax
c01032aa:	74 16                	je     c01032c2 <_ZN4FFMA10initMemMapEPN4ListIN3MMU4PageEE6DLNodeEj+0x10a>
        pArr[i].data.ref = 0;
c01032ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c01032b2:	83 c0 11             	add    $0x11,%eax
        pArr[i].data.status = 0;
c01032b5:	c6 40 f3 00          	movb   $0x0,-0xd(%eax)
        pArr[i].data.property = 0;
c01032b9:	c7 40 f4 00 00 00 00 	movl   $0x0,-0xc(%eax)
    for (uint32_t i = 0; i < num; i++) {    // init Page struct for the mem-area
c01032c0:	eb e6                	jmp    c01032a8 <_ZN4FFMA10initMemMapEPN4ListIN3MMU4PageEE6DLNodeEj+0xf0>
    pArr[0].data.property = num;
c01032c2:	8b 45 0c             	mov    0xc(%ebp),%eax
    MMU::setPageProperty(pArr[0].data);
c01032c5:	83 ec 0c             	sub    $0xc,%esp
    pArr[0].data.property = num;
c01032c8:	89 48 05             	mov    %ecx,0x5(%eax)
    MMU::setPageProperty(pArr[0].data);
c01032cb:	50                   	push   %eax
c01032cc:	e8 bd 26 00 00       	call   c010598e <_ZN3MMU15setPagePropertyERNS_4PageE>
    nfp += num;
c01032d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
c01032d4:	8b 45 10             	mov    0x10(%ebp),%eax
c01032d7:	01 41 19             	add    %eax,0x19(%ecx)
    freeArea.addLNode(*pArr);
c01032da:	58                   	pop    %eax
c01032db:	89 c8                	mov    %ecx,%eax
c01032dd:	83 c0 09             	add    $0x9,%eax
c01032e0:	5a                   	pop    %edx
c01032e1:	ff 75 0c             	pushl  0xc(%ebp)
c01032e4:	50                   	push   %eax
c01032e5:	e8 e0 01 00 00       	call   c01034ca <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE>
    OStream out("\n\ninitMemMap:\n\n firstAd = ", "red");
c01032ea:	89 3c 24             	mov    %edi,(%esp)
c01032ed:	e8 ba e8 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
}
c01032f2:	83 c4 10             	add    $0x10,%esp
c01032f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01032f8:	5b                   	pop    %ebx
c01032f9:	5e                   	pop    %esi
c01032fa:	5f                   	pop    %edi
c01032fb:	5d                   	pop    %ebp
c01032fc:	c3                   	ret    
c01032fd:	90                   	nop

c01032fe <_ZN4FFMA10allocPagesEj>:
List<MMU::Page>::DLNode * FFMA::allocPages(uint32_t n) {
c01032fe:	55                   	push   %ebp
c01032ff:	89 e5                	mov    %esp,%ebp
c0103301:	57                   	push   %edi
c0103302:	56                   	push   %esi
c0103303:	53                   	push   %ebx
c0103304:	83 ec 1c             	sub    $0x1c,%esp
c0103307:	8b 7d 08             	mov    0x8(%ebp),%edi
    if (n > nfp) {                                 // if n great than  number of free-page
c010330a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010330d:	e8 bb d8 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0103312:	81 c3 0e f1 01 00    	add    $0x1f10e,%ebx
c0103318:	39 47 19             	cmp    %eax,0x19(%edi)
c010331b:	73 04                	jae    c0103321 <_ZN4FFMA10allocPagesEj+0x23>
        return nullptr;
c010331d:	31 f6                	xor    %esi,%esi
c010331f:	eb 6b                	jmp    c010338c <_ZN4FFMA10allocPagesEj+0x8e>
    return p->data;
}

template <typename Object>
typename List<Object>::NodeIterator List<Object>::getNodeIterator() {
    it.setCurrentNode(headNode.first);
c0103321:	8b 77 0d             	mov    0xd(%edi),%esi
                    currentNode = node;
c0103324:	89 77 09             	mov    %esi,0x9(%edi)
                    if (!hasNext()) {
c0103327:	85 f6                	test   %esi,%esi
c0103329:	74 f2                	je     c010331d <_ZN4FFMA10allocPagesEj+0x1f>
        if (pnode->data.property >= n) {            // current continuous area[page num] is Ok
c010332b:	8b 4e 05             	mov    0x5(%esi),%ecx
c010332e:	3b 4d 0c             	cmp    0xc(%ebp),%ecx
                    currentNode = currentNode->next;
c0103331:	8b 56 0d             	mov    0xd(%esi),%edx
c0103334:	73 04                	jae    c010333a <_ZN4FFMA10allocPagesEj+0x3c>
c0103336:	89 d6                	mov    %edx,%esi
c0103338:	eb ed                	jmp    c0103327 <_ZN4FFMA10allocPagesEj+0x29>
        if (pnode->data.property > n) {             // need resolve continuous area ?
c010333a:	3b 4d 0c             	cmp    0xc(%ebp),%ecx
    auto it = freeArea.getNodeIterator();
c010333d:	8d 47 09             	lea    0x9(%edi),%eax
c0103340:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (pnode->data.property > n) {             // need resolve continuous area ?
c0103343:	76 2b                	jbe    c0103370 <_ZN4FFMA10allocPagesEj+0x72>
            List<MMU::Page>::DLNode *newNode = pnode + n;
c0103345:	6b 55 0c 11          	imul   $0x11,0xc(%ebp),%edx
            MMU::setPageProperty(newNode->data);
c0103349:	83 ec 0c             	sub    $0xc,%esp
            newNode->data.property = pnode->data.property - n;
c010334c:	2b 4d 0c             	sub    0xc(%ebp),%ecx
            List<MMU::Page>::DLNode *newNode = pnode + n;
c010334f:	01 f2                	add    %esi,%edx
            newNode->data.property = pnode->data.property - n;
c0103351:	89 4a 05             	mov    %ecx,0x5(%edx)
            MMU::setPageProperty(newNode->data);
c0103354:	52                   	push   %edx
c0103355:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0103358:	e8 31 26 00 00       	call   c010598e <_ZN3MMU15setPagePropertyERNS_4PageE>
            freeArea.insertLNode(pnode, newNode);   // insert new pageNode
c010335d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103360:	83 c4 0c             	add    $0xc,%esp
c0103363:	52                   	push   %edx
c0103364:	56                   	push   %esi
c0103365:	ff 75 e4             	pushl  -0x1c(%ebp)
c0103368:	e8 a3 01 00 00       	call   c0103510 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_>
c010336d:	83 c4 10             	add    $0x10,%esp
        freeArea.deleteLNode(pnode);
c0103370:	50                   	push   %eax
c0103371:	50                   	push   %eax
c0103372:	56                   	push   %esi
c0103373:	ff 75 e4             	pushl  -0x1c(%ebp)
c0103376:	e8 d1 01 00 00       	call   c010354c <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE>
        nfp -= n;
c010337b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010337e:	29 47 19             	sub    %eax,0x19(%edi)
        MMU::clearPageProperty(pnode->data);
c0103381:	89 34 24             	mov    %esi,(%esp)
c0103384:	e8 11 26 00 00       	call   c010599a <_ZN3MMU17clearPagePropertyERNS_4PageE>
c0103389:	83 c4 10             	add    $0x10,%esp
}
c010338c:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010338f:	89 f0                	mov    %esi,%eax
c0103391:	5b                   	pop    %ebx
c0103392:	5e                   	pop    %esi
c0103393:	5f                   	pop    %edi
c0103394:	5d                   	pop    %ebp
c0103395:	c3                   	ret    

c0103396 <_ZN4FFMA9freePagesEPvj>:
c0103396:	55                   	push   %ebp
c0103397:	89 e5                	mov    %esp,%ebp
c0103399:	57                   	push   %edi
c010339a:	56                   	push   %esi
c010339b:	53                   	push   %ebx
c010339c:	83 ec 1c             	sub    $0x1c,%esp
c010339f:	e8 29 d8 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c01033a4:	81 c3 7c f0 01 00    	add    $0x1f07c,%ebx
c01033aa:	8b 75 0c             	mov    0xc(%ebp),%esi
c01033ad:	6b 4d 10 11          	imul   $0x11,0x10(%ebp),%ecx
c01033b1:	89 f2                	mov    %esi,%edx
c01033b3:	01 f1                	add    %esi,%ecx
c01033b5:	39 ca                	cmp    %ecx,%edx
c01033b7:	74 10                	je     c01033c9 <_ZN4FFMA9freePagesEPvj+0x33>
c01033b9:	c6 42 04 00          	movb   $0x0,0x4(%edx)
c01033bd:	83 c2 11             	add    $0x11,%edx
c01033c0:	c7 42 ef 00 00 00 00 	movl   $0x0,-0x11(%edx)
c01033c7:	eb ec                	jmp    c01033b5 <_ZN4FFMA9freePagesEPvj+0x1f>
c01033c9:	8b 45 10             	mov    0x10(%ebp),%eax
c01033cc:	83 ec 0c             	sub    $0xc,%esp
c01033cf:	89 46 05             	mov    %eax,0x5(%esi)
c01033d2:	56                   	push   %esi
c01033d3:	e8 b6 25 00 00       	call   c010598e <_ZN3MMU15setPagePropertyERNS_4PageE>
c01033d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01033db:	83 c4 10             	add    $0x10,%esp
c01033de:	83 c0 09             	add    $0x9,%eax
c01033e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01033e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01033e7:	8b 78 0d             	mov    0xd(%eax),%edi
c01033ea:	89 78 09             	mov    %edi,0x9(%eax)
c01033ed:	85 ff                	test   %edi,%edi
c01033ef:	74 62                	je     c0103453 <_ZN4FFMA9freePagesEPvj+0xbd>
c01033f1:	8b 47 0d             	mov    0xd(%edi),%eax
c01033f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01033f7:	8b 47 05             	mov    0x5(%edi),%eax
c01033fa:	6b d0 11             	imul   $0x11,%eax,%edx
c01033fd:	01 fa                	add    %edi,%edx
c01033ff:	39 f2                	cmp    %esi,%edx
c0103401:	75 21                	jne    c0103424 <_ZN4FFMA9freePagesEPvj+0x8e>
c0103403:	03 46 05             	add    0x5(%esi),%eax
c0103406:	83 ec 0c             	sub    $0xc,%esp
c0103409:	89 47 05             	mov    %eax,0x5(%edi)
c010340c:	56                   	push   %esi
c010340d:	89 fe                	mov    %edi,%esi
c010340f:	e8 86 25 00 00       	call   c010599a <_ZN3MMU17clearPagePropertyERNS_4PageE>
c0103414:	58                   	pop    %eax
c0103415:	5a                   	pop    %edx
c0103416:	57                   	push   %edi
c0103417:	ff 75 e4             	pushl  -0x1c(%ebp)
c010341a:	e8 2d 01 00 00       	call   c010354c <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE>
c010341f:	83 c4 10             	add    $0x10,%esp
c0103422:	eb 2f                	jmp    c0103453 <_ZN4FFMA9freePagesEPvj+0xbd>
c0103424:	8b 4e 05             	mov    0x5(%esi),%ecx
c0103427:	6b d1 11             	imul   $0x11,%ecx,%edx
c010342a:	01 f2                	add    %esi,%edx
c010342c:	39 fa                	cmp    %edi,%edx
c010342e:	74 05                	je     c0103435 <_ZN4FFMA9freePagesEPvj+0x9f>
c0103430:	8b 7d e0             	mov    -0x20(%ebp),%edi
c0103433:	eb b8                	jmp    c01033ed <_ZN4FFMA9freePagesEPvj+0x57>
c0103435:	83 ec 0c             	sub    $0xc,%esp
c0103438:	01 c1                	add    %eax,%ecx
c010343a:	89 4e 05             	mov    %ecx,0x5(%esi)
c010343d:	57                   	push   %edi
c010343e:	e8 57 25 00 00       	call   c010599a <_ZN3MMU17clearPagePropertyERNS_4PageE>
c0103443:	59                   	pop    %ecx
c0103444:	58                   	pop    %eax
c0103445:	57                   	push   %edi
c0103446:	ff 75 e4             	pushl  -0x1c(%ebp)
c0103449:	e8 fe 00 00 00       	call   c010354c <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE>
c010344e:	83 c4 10             	add    $0x10,%esp
c0103451:	eb dd                	jmp    c0103430 <_ZN4FFMA9freePagesEPvj+0x9a>
c0103453:	8b 45 08             	mov    0x8(%ebp),%eax
c0103456:	8b 48 0d             	mov    0xd(%eax),%ecx
c0103459:	89 48 09             	mov    %ecx,0x9(%eax)
c010345c:	89 ca                	mov    %ecx,%edx
c010345e:	85 d2                	test   %edx,%edx
c0103460:	74 0b                	je     c010346d <_ZN4FFMA9freePagesEPvj+0xd7>
c0103462:	39 f2                	cmp    %esi,%edx
c0103464:	8b 5a 0d             	mov    0xd(%edx),%ebx
c0103467:	73 3a                	jae    c01034a3 <_ZN4FFMA9freePagesEPvj+0x10d>
c0103469:	89 da                	mov    %ebx,%edx
c010346b:	eb f1                	jmp    c010345e <_ZN4FFMA9freePagesEPvj+0xc8>
c010346d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103470:	8b 50 15             	mov    0x15(%eax),%edx
c0103473:	85 d2                	test   %edx,%edx
c0103475:	75 06                	jne    c010347d <_ZN4FFMA9freePagesEPvj+0xe7>
c0103477:	83 78 11 00          	cmpl   $0x0,0x11(%eax)
c010347b:	74 19                	je     c0103496 <_ZN4FFMA9freePagesEPvj+0x100>
c010347d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103480:	42                   	inc    %edx
c0103481:	c7 46 09 00 00 00 00 	movl   $0x0,0x9(%esi)
c0103488:	89 4e 0d             	mov    %ecx,0xd(%esi)
c010348b:	89 71 09             	mov    %esi,0x9(%ecx)
c010348e:	89 70 0d             	mov    %esi,0xd(%eax)
c0103491:	89 50 15             	mov    %edx,0x15(%eax)
c0103494:	eb 22                	jmp    c01034b8 <_ZN4FFMA9freePagesEPvj+0x122>
c0103496:	52                   	push   %edx
c0103497:	52                   	push   %edx
c0103498:	56                   	push   %esi
c0103499:	ff 75 e4             	pushl  -0x1c(%ebp)
c010349c:	e8 29 00 00 00       	call   c01034ca <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE>
c01034a1:	eb 12                	jmp    c01034b5 <_ZN4FFMA9freePagesEPvj+0x11f>
c01034a3:	8b 52 09             	mov    0x9(%edx),%edx
c01034a6:	85 d2                	test   %edx,%edx
c01034a8:	74 c3                	je     c010346d <_ZN4FFMA9freePagesEPvj+0xd7>
c01034aa:	50                   	push   %eax
c01034ab:	56                   	push   %esi
c01034ac:	52                   	push   %edx
c01034ad:	ff 75 e4             	pushl  -0x1c(%ebp)
c01034b0:	e8 5b 00 00 00       	call   c0103510 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_>
c01034b5:	83 c4 10             	add    $0x10,%esp
c01034b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01034bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
c01034be:	01 58 19             	add    %ebx,0x19(%eax)
c01034c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01034c4:	5b                   	pop    %ebx
c01034c5:	5e                   	pop    %esi
c01034c6:	5f                   	pop    %edi
c01034c7:	5d                   	pop    %ebp
c01034c8:	c3                   	ret    
c01034c9:	90                   	nop

c01034ca <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE>:
void List<Object>::addLNode(DLNode &node) {
c01034ca:	55                   	push   %ebp
c01034cb:	89 e5                	mov    %esp,%ebp
c01034cd:	8b 55 08             	mov    0x8(%ebp),%edx
c01034d0:	53                   	push   %ebx
c01034d1:	8b 45 0c             	mov    0xc(%ebp),%eax
    return (headNode.eNum == 0 && headNode.last == nullptr);
c01034d4:	8b 4a 0c             	mov    0xc(%edx),%ecx
c01034d7:	8b 5a 08             	mov    0x8(%edx),%ebx
c01034da:	85 c9                	test   %ecx,%ecx
c01034dc:	75 1a                	jne    c01034f8 <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE+0x2e>
c01034de:	85 db                	test   %ebx,%ebx
c01034e0:	75 16                	jne    c01034f8 <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE+0x2e>
        headNode.last = &node;
c01034e2:	89 42 08             	mov    %eax,0x8(%edx)
        headNode.first = &node;
c01034e5:	89 42 04             	mov    %eax,0x4(%edx)
        node.pre = nullptr;
c01034e8:	c7 40 09 00 00 00 00 	movl   $0x0,0x9(%eax)
        node.next = nullptr;
c01034ef:	c7 40 0d 00 00 00 00 	movl   $0x0,0xd(%eax)
c01034f6:	eb 10                	jmp    c0103508 <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE+0x3e>
        p->next = &node;
c01034f8:	89 43 0d             	mov    %eax,0xd(%ebx)
        node.pre = p;
c01034fb:	89 58 09             	mov    %ebx,0x9(%eax)
        node.next = nullptr;
c01034fe:	c7 40 0d 00 00 00 00 	movl   $0x0,0xd(%eax)
        headNode.last = &node;           // update 
c0103505:	89 42 08             	mov    %eax,0x8(%edx)
    headNode.eNum++;
c0103508:	41                   	inc    %ecx
c0103509:	89 4a 0c             	mov    %ecx,0xc(%edx)
}
c010350c:	5b                   	pop    %ebx
c010350d:	5d                   	pop    %ebp
c010350e:	c3                   	ret    
c010350f:	90                   	nop

c0103510 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_>:
void List<Object>::insertLNode(DLNode *node1, DLNode *node2) {
c0103510:	55                   	push   %ebp
c0103511:	89 e5                	mov    %esp,%ebp
c0103513:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103516:	53                   	push   %ebx
c0103517:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010351a:	8b 55 10             	mov    0x10(%ebp),%edx
    if (node1 == nullptr) {
c010351d:	85 c0                	test   %eax,%eax
c010351f:	74 27                	je     c0103548 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_+0x38>
    if (node1->next == nullptr) {
c0103521:	8b 58 0d             	mov    0xd(%eax),%ebx
c0103524:	85 db                	test   %ebx,%ebx
c0103526:	75 0a                	jne    c0103532 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_+0x22>
}
c0103528:	5b                   	pop    %ebx
        addLNode(*node2);
c0103529:	89 55 0c             	mov    %edx,0xc(%ebp)
}
c010352c:	5d                   	pop    %ebp
        addLNode(*node2);
c010352d:	e9 98 ff ff ff       	jmp    c01034ca <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE>
        node2->next = node1->next;
c0103532:	89 5a 0d             	mov    %ebx,0xd(%edx)
        if (node1->next != nullptr) {
c0103535:	8b 58 0d             	mov    0xd(%eax),%ebx
        node2->pre = node1;
c0103538:	89 42 09             	mov    %eax,0x9(%edx)
        if (node1->next != nullptr) {
c010353b:	85 db                	test   %ebx,%ebx
c010353d:	74 03                	je     c0103542 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_+0x32>
            node1->next->pre = node2;
c010353f:	89 53 09             	mov    %edx,0x9(%ebx)
        node1->next = node2;
c0103542:	89 50 0d             	mov    %edx,0xd(%eax)
        headNode.eNum++;
c0103545:	ff 41 0c             	incl   0xc(%ecx)
}
c0103548:	5b                   	pop    %ebx
c0103549:	5d                   	pop    %ebp
c010354a:	c3                   	ret    
c010354b:	90                   	nop

c010354c <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE>:
void List<Object>::deleteLNode(DLNode *node) {
c010354c:	55                   	push   %ebp
c010354d:	89 e5                	mov    %esp,%ebp
c010354f:	8b 55 08             	mov    0x8(%ebp),%edx
c0103552:	53                   	push   %ebx
c0103553:	8b 45 0c             	mov    0xc(%ebp),%eax
    if (headNode.first == node) {       // is first Node
c0103556:	39 42 04             	cmp    %eax,0x4(%edx)
c0103559:	75 1c                	jne    c0103577 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x2b>
        headNode.first = node->next;
c010355b:	8b 48 0d             	mov    0xd(%eax),%ecx
        if (headNode.first == nullptr) {
c010355e:	85 c9                	test   %ecx,%ecx
        headNode.first = node->next;
c0103560:	89 4a 04             	mov    %ecx,0x4(%edx)
        if (headNode.first == nullptr) {
c0103563:	75 09                	jne    c010356e <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x22>
            headNode.last = nullptr;
c0103565:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
c010356c:	eb 29                	jmp    c0103597 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x4b>
            headNode.first->pre = nullptr;
c010356e:	c7 41 09 00 00 00 00 	movl   $0x0,0x9(%ecx)
c0103575:	eb 20                	jmp    c0103597 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x4b>
    } else if (headNode.last == node) { // is trail Node[can't only a node]
c0103577:	39 42 08             	cmp    %eax,0x8(%edx)
c010357a:	8b 48 09             	mov    0x9(%eax),%ecx
c010357d:	75 0c                	jne    c010358b <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x3f>
        headNode.last = node->pre;
c010357f:	89 4a 08             	mov    %ecx,0x8(%edx)
        headNode.last->next = nullptr;
c0103582:	c7 41 0d 00 00 00 00 	movl   $0x0,0xd(%ecx)
c0103589:	eb 0c                	jmp    c0103597 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x4b>
        node->next->pre = node->pre;
c010358b:	8b 58 0d             	mov    0xd(%eax),%ebx
c010358e:	89 4b 09             	mov    %ecx,0x9(%ebx)
        node->pre->next = node->next;
c0103591:	8b 48 09             	mov    0x9(%eax),%ecx
c0103594:	89 59 0d             	mov    %ebx,0xd(%ecx)
    node->next = node->pre = nullptr;
c0103597:	c7 40 09 00 00 00 00 	movl   $0x0,0x9(%eax)
c010359e:	c7 40 0d 00 00 00 00 	movl   $0x0,0xd(%eax)
    headNode.eNum--;
c01035a5:	ff 4a 0c             	decl   0xc(%edx)
}
c01035a8:	5b                   	pop    %ebx
c01035a9:	5d                   	pop    %ebp
c01035aa:	c3                   	ret    
c01035ab:	90                   	nop

c01035ac <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>:

void VMM::init() {
    checkVmm();
}

List<VMM::VMA>::DLNode * VMM::findVma(List<MM>::DLNode *mm, uptr32_t addr) {
c01035ac:	55                   	push   %ebp
c01035ad:	89 e5                	mov    %esp,%ebp
c01035af:	8b 55 0c             	mov    0xc(%ebp),%edx
c01035b2:	53                   	push   %ebx
c01035b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
        DEBUGPRINT("VMM::findVma");
    #endif
    
    List<VMA>::DLNode *vma = nullptr;

    if (mm != nullptr) {
c01035b6:	85 d2                	test   %edx,%edx
c01035b8:	75 04                	jne    c01035be <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x12>
    List<VMA>::DLNode *vma = nullptr;
c01035ba:	31 c0                	xor    %eax,%eax
c01035bc:	eb 2e                	jmp    c01035ec <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x40>
        vma = mm->data.mmap_cache;
c01035be:	8b 42 10             	mov    0x10(%edx),%eax
        if (!(vma != nullptr && vma->data.vm_start <= addr && vma->data.vm_end > addr)) {
c01035c1:	85 c0                	test   %eax,%eax
c01035c3:	74 0a                	je     c01035cf <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x23>
c01035c5:	39 48 04             	cmp    %ecx,0x4(%eax)
c01035c8:	77 05                	ja     c01035cf <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x23>
c01035ca:	39 48 08             	cmp    %ecx,0x8(%eax)
c01035cd:	77 1a                	ja     c01035e9 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x3d>
    it.setCurrentNode(headNode.first);
c01035cf:	8b 42 04             	mov    0x4(%edx),%eax
                    currentNode = node;
c01035d2:	89 02                	mov    %eax,(%edx)
                    if (!hasNext()) {
c01035d4:	85 c0                	test   %eax,%eax
c01035d6:	74 e2                	je     c01035ba <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0xe>
                        out.write(" now = ");
                        out.writeValue(vma->data.vm_start);
                        out.flush();
                    #endif
                    
                    if (vma->data.vm_start <= addr && addr < vma->data.vm_end) {
c01035d8:	39 48 04             	cmp    %ecx,0x4(%eax)
                    currentNode = currentNode->next;
c01035db:	8b 58 14             	mov    0x14(%eax),%ebx
c01035de:	76 04                	jbe    c01035e4 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x38>
List<VMM::VMA>::DLNode * VMM::findVma(List<MM>::DLNode *mm, uptr32_t addr) {
c01035e0:	89 d8                	mov    %ebx,%eax
c01035e2:	eb f0                	jmp    c01035d4 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x28>
                    if (vma->data.vm_start <= addr && addr < vma->data.vm_end) {
c01035e4:	39 48 08             	cmp    %ecx,0x8(%eax)
c01035e7:	76 f7                	jbe    c01035e0 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x34>
                if (!found) {
                    vma = nullptr;
                }
        }
        if (vma != nullptr) {
            mm->data.mmap_cache = vma;
c01035e9:	89 42 10             	mov    %eax,0x10(%edx)
        }
    }

    return vma;

}
c01035ec:	5b                   	pop    %ebx
c01035ed:	5d                   	pop    %ebp
c01035ee:	c3                   	ret    
c01035ef:	90                   	nop

c01035f0 <_ZN3VMM9vmaCreateEjjj>:

List<VMM::VMA>::DLNode * VMM::vmaCreate(uptr32_t vmStart, uptr32_t vmEnd, uint32_t vmFlags) {
c01035f0:	55                   	push   %ebp
c01035f1:	89 e5                	mov    %esp,%ebp
c01035f3:	57                   	push   %edi
c01035f4:	56                   	push   %esi
c01035f5:	53                   	push   %ebx
c01035f6:	e8 d2 d5 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c01035fb:	81 c3 25 ee 01 00    	add    $0x1ee25,%ebx
c0103601:	81 ec 44 02 00 00    	sub    $0x244,%esp
    DEBUGPRINT("VMM::vmaCreate");
c0103607:	8d b5 d8 fd ff ff    	lea    -0x228(%ebp),%esi
c010360d:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0103613:	50                   	push   %eax
c0103614:	56                   	push   %esi
c0103615:	e8 e0 26 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010361a:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c0103620:	59                   	pop    %ecx
c0103621:	5f                   	pop    %edi
c0103622:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0103628:	50                   	push   %eax
c0103629:	8d 85 d3 fd ff ff    	lea    -0x22d(%ebp),%eax
c010362f:	50                   	push   %eax
c0103630:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0103636:	e8 bf 26 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010363b:	83 c4 0c             	add    $0xc,%esp
c010363e:	56                   	push   %esi
c010363f:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0103645:	57                   	push   %edi
c0103646:	e8 83 e4 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c010364b:	58                   	pop    %eax
c010364c:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0103652:	e8 bd 26 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103657:	89 34 24             	mov    %esi,(%esp)
c010365a:	e8 b5 26 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010365f:	58                   	pop    %eax
c0103660:	8d 83 06 3c fe ff    	lea    -0x1c3fa(%ebx),%eax
c0103666:	5a                   	pop    %edx
c0103667:	50                   	push   %eax
c0103668:	56                   	push   %esi
c0103669:	e8 8c 26 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010366e:	59                   	pop    %ecx
c010366f:	58                   	pop    %eax
c0103670:	56                   	push   %esi
c0103671:	57                   	push   %edi
c0103672:	e8 a5 e5 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0103677:	89 34 24             	mov    %esi,(%esp)
c010367a:	e8 95 26 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010367f:	89 3c 24             	mov    %edi,(%esp)
c0103682:	e8 e1 e4 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c0103687:	89 3c 24             	mov    %edi,(%esp)
c010368a:	e8 1d e5 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
    auto vma = (List<VMA>::DLNode *)(kernel::pmm.kmalloc(sizeof(List<VMA>::DLNode)));
c010368f:	58                   	pop    %eax
c0103690:	5a                   	pop    %edx
c0103691:	6a 18                	push   $0x18
c0103693:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
c0103699:	e8 42 f3 ff ff       	call   c01029e0 <_ZN5PhyMM7kmallocEj>
    
    if (vma != nullptr) {
c010369e:	83 c4 10             	add    $0x10,%esp
c01036a1:	85 c0                	test   %eax,%eax
c01036a3:	0f 84 99 00 00 00    	je     c0103742 <_ZN3VMM9vmaCreateEjjj+0x152>
c01036a9:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
        OStream out("", "blue");
c01036af:	8d 93 96 39 fe ff    	lea    -0x1c66a(%ebx),%edx
c01036b5:	50                   	push   %eax
c01036b6:	50                   	push   %eax
c01036b7:	52                   	push   %edx
c01036b8:	56                   	push   %esi
c01036b9:	e8 3c 26 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01036be:	5a                   	pop    %edx
c01036bf:	8d 93 b0 39 fe ff    	lea    -0x1c650(%ebx),%edx
c01036c5:	59                   	pop    %ecx
c01036c6:	52                   	push   %edx
c01036c7:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c01036cd:	e8 28 26 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01036d2:	83 c4 0c             	add    $0xc,%esp
c01036d5:	56                   	push   %esi
c01036d6:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c01036dc:	57                   	push   %edi
c01036dd:	e8 ec e3 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01036e2:	58                   	pop    %eax
c01036e3:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c01036e9:	e8 26 26 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01036ee:	89 34 24             	mov    %esi,(%esp)
c01036f1:	e8 1e 26 00 00       	call   c0105d14 <_ZN6StringD1Ev>
        out.writeValue((uint32_t)vma);
c01036f6:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01036fc:	89 85 d8 fd ff ff    	mov    %eax,-0x228(%ebp)
c0103702:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0103708:	58                   	pop    %eax
c0103709:	5a                   	pop    %edx
c010370a:	56                   	push   %esi
c010370b:	57                   	push   %edi
c010370c:	e8 4f e5 ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
        out.flush();
c0103711:	89 3c 24             	mov    %edi,(%esp)
c0103714:	e8 4f e4 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>

        vma->data.vm_start = vmStart;
c0103719:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c010371f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103722:	89 50 04             	mov    %edx,0x4(%eax)
        vma->data.vm_end = vmEnd;
c0103725:	8b 55 10             	mov    0x10(%ebp),%edx
c0103728:	89 50 08             	mov    %edx,0x8(%eax)
        vma->data.vm_flags = vmFlags;
c010372b:	8b 55 14             	mov    0x14(%ebp),%edx
c010372e:	89 50 0c             	mov    %edx,0xc(%eax)
        OStream out("", "blue");
c0103731:	89 3c 24             	mov    %edi,(%esp)
c0103734:	e8 73 e4 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0103739:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c010373f:	83 c4 10             	add    $0x10,%esp
    }
    
    return vma;
}
c0103742:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0103745:	5b                   	pop    %ebx
c0103746:	5e                   	pop    %esi
c0103747:	5f                   	pop    %edi
c0103748:	5d                   	pop    %ebp
c0103749:	c3                   	ret    

c010374a <_ZN3VMM8mmCreateEv>:
    out.write("\nnodeNum: ");
    out.writeValue((mm->data.vmaList.length()));
    out.flush();
}

List<VMM::MM>::DLNode * VMM::mmCreate() {
c010374a:	55                   	push   %ebp
c010374b:	89 e5                	mov    %esp,%ebp
c010374d:	57                   	push   %edi
c010374e:	56                   	push   %esi
c010374f:	53                   	push   %ebx
c0103750:	e8 78 d4 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0103755:	81 c3 cb ec 01 00    	add    $0x1eccb,%ebx
c010375b:	81 ec 44 02 00 00    	sub    $0x244,%esp
    DEBUGPRINT(" VMM::mmCreate()");
c0103761:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0103767:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c010376d:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0103773:	50                   	push   %eax
c0103774:	56                   	push   %esi
c0103775:	e8 80 25 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010377a:	58                   	pop    %eax
c010377b:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c0103781:	5a                   	pop    %edx
c0103782:	50                   	push   %eax
c0103783:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0103789:	50                   	push   %eax
c010378a:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0103790:	e8 65 25 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103795:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c010379b:	83 c4 0c             	add    $0xc,%esp
c010379e:	56                   	push   %esi
c010379f:	50                   	push   %eax
c01037a0:	57                   	push   %edi
c01037a1:	e8 28 e3 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01037a6:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c01037ac:	89 04 24             	mov    %eax,(%esp)
c01037af:	e8 60 25 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01037b4:	89 34 24             	mov    %esi,(%esp)
c01037b7:	e8 58 25 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01037bc:	59                   	pop    %ecx
c01037bd:	58                   	pop    %eax
c01037be:	8d 83 15 3c fe ff    	lea    -0x1c3eb(%ebx),%eax
c01037c4:	50                   	push   %eax
c01037c5:	56                   	push   %esi
c01037c6:	e8 2f 25 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01037cb:	58                   	pop    %eax
c01037cc:	5a                   	pop    %edx
c01037cd:	56                   	push   %esi
c01037ce:	57                   	push   %edi
c01037cf:	e8 48 e4 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01037d4:	89 34 24             	mov    %esi,(%esp)
c01037d7:	e8 38 25 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01037dc:	89 3c 24             	mov    %edi,(%esp)
c01037df:	e8 84 e3 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c01037e4:	89 3c 24             	mov    %edi,(%esp)
c01037e7:	e8 c0 e3 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
    auto mm = (List<MM>::DLNode *)(kernel::pmm.kmalloc(sizeof(List<MM>::DLNode)));
c01037ec:	59                   	pop    %ecx
c01037ed:	5e                   	pop    %esi
c01037ee:	6a 24                	push   $0x24
c01037f0:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
c01037f6:	e8 e5 f1 ff ff       	call   c01029e0 <_ZN5PhyMM7kmallocEj>

    if (mm != nullptr) {
c01037fb:	83 c4 10             	add    $0x10,%esp
c01037fe:	85 c0                	test   %eax,%eax
c0103800:	74 23                	je     c0103825 <_ZN3VMM8mmCreateEv+0xdb>
        mm->next = mm->pre = nullptr;
c0103802:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
c0103809:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
        mm->data.mmap_cache = nullptr;
c0103810:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        mm->data.pdt = nullptr;
c0103817:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        //mm->data.map_count = 0;

        if (false) while(1);//swap_init_mm(mm);
        else mm->data.sm_priv = nullptr;
c010381e:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    return mm;
}
c0103825:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0103828:	5b                   	pop    %ebx
c0103829:	5e                   	pop    %esi
c010382a:	5f                   	pop    %edi
c010382b:	5d                   	pop    %ebp
c010382c:	c3                   	ret    
c010382d:	90                   	nop

c010382e <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE>:

void VMM::mmDestroy(List<MM>::DLNode *mm) {
c010382e:	55                   	push   %ebp
c010382f:	89 e5                	mov    %esp,%ebp
c0103831:	57                   	push   %edi
c0103832:	56                   	push   %esi
c0103833:	53                   	push   %ebx
c0103834:	83 ec 1c             	sub    $0x1c,%esp
c0103837:	e8 91 d3 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c010383c:	81 c3 e4 eb 01 00    	add    $0x1ebe4,%ebx
c0103842:	8b 75 0c             	mov    0xc(%ebp),%esi
    it.setCurrentNode(headNode.first);
c0103845:	8b 46 04             	mov    0x4(%esi),%eax
c0103848:	c7 c2 20 50 12 c0    	mov    $0xc0125020,%edx
                    currentNode = node;
c010384e:	89 06                	mov    %eax,(%esi)
                    if (!hasNext()) {
c0103850:	85 c0                	test   %eax,%eax
c0103852:	75 12                	jne    c0103866 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x38>
        #endif

        mm->data.vmaList.deleteLNode(vma);
        kernel::pmm.kfree(vma, sizeof(List<VMA>::DLNode));  //kfree vma        
    }
    kernel::pmm.kfree(mm, sizeof(List<MM>::DLNode));        //kfree mm
c0103854:	57                   	push   %edi
c0103855:	6a 24                	push   $0x24
c0103857:	56                   	push   %esi
c0103858:	52                   	push   %edx
c0103859:	e8 8a f3 ff ff       	call   c0102be8 <_ZN5PhyMM5kfreeEPvj>
    mm = nullptr;
}
c010385e:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0103861:	5b                   	pop    %ebx
c0103862:	5e                   	pop    %esi
c0103863:	5f                   	pop    %edi
c0103864:	5d                   	pop    %ebp
c0103865:	c3                   	ret    
    if (headNode.first == node) {       // is first Node
c0103866:	3b 46 04             	cmp    0x4(%esi),%eax
                    currentNode = currentNode->next;
c0103869:	8b 78 14             	mov    0x14(%eax),%edi
    if (headNode.first == node) {       // is first Node
c010386c:	75 19                	jne    c0103887 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x59>
        if (headNode.first == nullptr) {
c010386e:	85 ff                	test   %edi,%edi
        headNode.first = node->next;
c0103870:	89 7e 04             	mov    %edi,0x4(%esi)
        if (headNode.first == nullptr) {
c0103873:	75 09                	jne    c010387e <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x50>
            headNode.last = nullptr;
c0103875:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
c010387c:	eb 26                	jmp    c01038a4 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x76>
            headNode.first->pre = nullptr;
c010387e:	c7 47 10 00 00 00 00 	movl   $0x0,0x10(%edi)
c0103885:	eb 1d                	jmp    c01038a4 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x76>
    } else if (headNode.last == node) { // is trail Node[can't only a node]
c0103887:	3b 46 08             	cmp    0x8(%esi),%eax
c010388a:	8b 48 10             	mov    0x10(%eax),%ecx
c010388d:	75 0c                	jne    c010389b <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x6d>
        headNode.last = node->pre;
c010388f:	89 4e 08             	mov    %ecx,0x8(%esi)
        headNode.last->next = nullptr;
c0103892:	c7 41 14 00 00 00 00 	movl   $0x0,0x14(%ecx)
c0103899:	eb 09                	jmp    c01038a4 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x76>
        node->next->pre = node->pre;
c010389b:	89 4f 10             	mov    %ecx,0x10(%edi)
        node->pre->next = node->next;
c010389e:	8b 48 10             	mov    0x10(%eax),%ecx
c01038a1:	89 79 14             	mov    %edi,0x14(%ecx)
    node->next = node->pre = nullptr;
c01038a4:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
c01038ab:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    headNode.eNum--;
c01038b2:	ff 4e 0c             	decl   0xc(%esi)
        kernel::pmm.kfree(vma, sizeof(List<VMA>::DLNode));  //kfree vma        
c01038b5:	51                   	push   %ecx
c01038b6:	6a 18                	push   $0x18
c01038b8:	50                   	push   %eax
c01038b9:	52                   	push   %edx
c01038ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01038bd:	e8 26 f3 ff ff       	call   c0102be8 <_ZN5PhyMM5kfreeEPvj>
    while ((vma = it.nextLNode()) != nullptr) {
c01038c2:	83 c4 10             	add    $0x10,%esp
                    currentNode = currentNode->next;
c01038c5:	89 f8                	mov    %edi,%eax
c01038c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01038ca:	eb 84                	jmp    c0103850 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x22>

c01038cc <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_>:
    DEBUGPRINT("CheckVma succeeded!");

}

// check if vma1 overlaps vma2 ?
void VMM::checkVamOverlap(List<VMA>::DLNode *prev, List<VMA>::DLNode *next) {
c01038cc:	55                   	push   %ebp
c01038cd:	89 e5                	mov    %esp,%ebp
c01038cf:	57                   	push   %edi
c01038d0:	56                   	push   %esi
c01038d1:	53                   	push   %ebx
c01038d2:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
c01038d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038db:	e8 ed d2 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c01038e0:	81 c3 40 eb 01 00    	add    $0x1eb40,%ebx
    assert(prev->data.vm_start < prev->data.vm_end);
c01038e6:	8b 48 08             	mov    0x8(%eax),%ecx
c01038e9:	39 48 04             	cmp    %ecx,0x4(%eax)
c01038ec:	0f 82 9e 00 00 00    	jb     c0103990 <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_+0xc4>
c01038f2:	51                   	push   %ecx
c01038f3:	51                   	push   %ecx
c01038f4:	8d 93 b1 39 fe ff    	lea    -0x1c64f(%ebx),%edx
c01038fa:	52                   	push   %edx
c01038fb:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0103901:	56                   	push   %esi
c0103902:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c0103908:	e8 ed 23 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010390d:	8d 93 bb 39 fe ff    	lea    -0x1c645(%ebx),%edx
c0103913:	5f                   	pop    %edi
c0103914:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c010391a:	58                   	pop    %eax
c010391b:	52                   	push   %edx
c010391c:	8d 95 d6 fd ff ff    	lea    -0x22a(%ebp),%edx
c0103922:	52                   	push   %edx
c0103923:	89 95 c4 fd ff ff    	mov    %edx,-0x23c(%ebp)
c0103929:	e8 cc 23 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010392e:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c0103934:	83 c4 0c             	add    $0xc,%esp
c0103937:	56                   	push   %esi
c0103938:	52                   	push   %edx
c0103939:	57                   	push   %edi
c010393a:	e8 8f e1 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c010393f:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c0103945:	89 14 24             	mov    %edx,(%esp)
c0103948:	e8 c7 23 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010394d:	89 34 24             	mov    %esi,(%esp)
c0103950:	e8 bf 23 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103955:	58                   	pop    %eax
c0103956:	5a                   	pop    %edx
c0103957:	8d 93 26 3c fe ff    	lea    -0x1c3da(%ebx),%edx
c010395d:	52                   	push   %edx
c010395e:	56                   	push   %esi
c010395f:	e8 96 23 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103964:	59                   	pop    %ecx
c0103965:	58                   	pop    %eax
c0103966:	56                   	push   %esi
c0103967:	57                   	push   %edi
c0103968:	e8 af e2 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c010396d:	89 34 24             	mov    %esi,(%esp)
c0103970:	e8 9f 23 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103975:	89 3c 24             	mov    %edi,(%esp)
c0103978:	e8 eb e1 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010397d:	fa                   	cli    
    asm volatile ("hlt");
c010397e:	f4                   	hlt    
c010397f:	89 3c 24             	mov    %edi,(%esp)
c0103982:	e8 25 e2 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0103987:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c010398d:	83 c4 10             	add    $0x10,%esp
    assert(prev->data.vm_end <= next->data.vm_start);
c0103990:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0103993:	8b 49 04             	mov    0x4(%ecx),%ecx
c0103996:	39 48 08             	cmp    %ecx,0x8(%eax)
c0103999:	0f 86 92 00 00 00    	jbe    c0103a31 <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_+0x165>
c010399f:	50                   	push   %eax
c01039a0:	50                   	push   %eax
c01039a1:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c01039a7:	50                   	push   %eax
c01039a8:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01039ae:	56                   	push   %esi
c01039af:	e8 46 23 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01039b4:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01039ba:	58                   	pop    %eax
c01039bb:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c01039c1:	5a                   	pop    %edx
c01039c2:	50                   	push   %eax
c01039c3:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c01039c9:	50                   	push   %eax
c01039ca:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c01039d0:	e8 25 23 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01039d5:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c01039db:	83 c4 0c             	add    $0xc,%esp
c01039de:	56                   	push   %esi
c01039df:	50                   	push   %eax
c01039e0:	57                   	push   %edi
c01039e1:	e8 e8 e0 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01039e6:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c01039ec:	89 04 24             	mov    %eax,(%esp)
c01039ef:	e8 20 23 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01039f4:	89 34 24             	mov    %esi,(%esp)
c01039f7:	e8 18 23 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01039fc:	59                   	pop    %ecx
c01039fd:	58                   	pop    %eax
c01039fe:	8d 83 4e 3c fe ff    	lea    -0x1c3b2(%ebx),%eax
c0103a04:	50                   	push   %eax
c0103a05:	56                   	push   %esi
c0103a06:	e8 ef 22 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103a0b:	58                   	pop    %eax
c0103a0c:	5a                   	pop    %edx
c0103a0d:	56                   	push   %esi
c0103a0e:	57                   	push   %edi
c0103a0f:	e8 08 e2 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0103a14:	89 34 24             	mov    %esi,(%esp)
c0103a17:	e8 f8 22 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103a1c:	89 3c 24             	mov    %edi,(%esp)
c0103a1f:	e8 44 e1 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103a24:	fa                   	cli    
    asm volatile ("hlt");
c0103a25:	f4                   	hlt    
c0103a26:	89 3c 24             	mov    %edi,(%esp)
c0103a29:	e8 7e e1 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0103a2e:	83 c4 10             	add    $0x10,%esp
    assert(next->data.vm_start < next->data.vm_end);
c0103a31:	8b 45 10             	mov    0x10(%ebp),%eax
c0103a34:	8b 48 08             	mov    0x8(%eax),%ecx
c0103a37:	39 48 04             	cmp    %ecx,0x4(%eax)
c0103a3a:	0f 82 92 00 00 00    	jb     c0103ad2 <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_+0x206>
c0103a40:	50                   	push   %eax
c0103a41:	50                   	push   %eax
c0103a42:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0103a48:	50                   	push   %eax
c0103a49:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0103a4f:	56                   	push   %esi
c0103a50:	e8 a5 22 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103a55:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0103a5b:	5a                   	pop    %edx
c0103a5c:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0103a62:	59                   	pop    %ecx
c0103a63:	50                   	push   %eax
c0103a64:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0103a6a:	50                   	push   %eax
c0103a6b:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0103a71:	e8 84 22 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103a76:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0103a7c:	83 c4 0c             	add    $0xc,%esp
c0103a7f:	56                   	push   %esi
c0103a80:	50                   	push   %eax
c0103a81:	57                   	push   %edi
c0103a82:	e8 47 e0 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0103a87:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0103a8d:	89 04 24             	mov    %eax,(%esp)
c0103a90:	e8 7f 22 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103a95:	89 34 24             	mov    %esi,(%esp)
c0103a98:	e8 77 22 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103a9d:	58                   	pop    %eax
c0103a9e:	8d 83 77 3c fe ff    	lea    -0x1c389(%ebx),%eax
c0103aa4:	5a                   	pop    %edx
c0103aa5:	50                   	push   %eax
c0103aa6:	56                   	push   %esi
c0103aa7:	e8 4e 22 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103aac:	59                   	pop    %ecx
c0103aad:	58                   	pop    %eax
c0103aae:	56                   	push   %esi
c0103aaf:	57                   	push   %edi
c0103ab0:	e8 67 e1 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0103ab5:	89 34 24             	mov    %esi,(%esp)
c0103ab8:	e8 57 22 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103abd:	89 3c 24             	mov    %edi,(%esp)
c0103ac0:	e8 a3 e0 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103ac5:	fa                   	cli    
    asm volatile ("hlt");
c0103ac6:	f4                   	hlt    
c0103ac7:	89 3c 24             	mov    %edi,(%esp)
c0103aca:	e8 dd e0 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0103acf:	83 c4 10             	add    $0x10,%esp
}
c0103ad2:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0103ad5:	5b                   	pop    %ebx
c0103ad6:	5e                   	pop    %esi
c0103ad7:	5f                   	pop    %edi
c0103ad8:	5d                   	pop    %ebp
c0103ad9:	c3                   	ret    

c0103ada <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj>:
    DEBUGPRINT("check_pgfault() succeeded!");
}


// do_pgfault - interrupt handler to process the page fault execption
int VMM::doPageFault(List<MM>::DLNode *mm, uint32_t errorCode, uptr32_t addr) {
c0103ada:	55                   	push   %ebp
c0103adb:	89 e5                	mov    %esp,%ebp
c0103add:	57                   	push   %edi
c0103ade:	56                   	push   %esi
c0103adf:	53                   	push   %ebx
c0103ae0:	e8 e8 d0 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0103ae5:	81 c3 3b e9 01 00    	add    $0x1e93b,%ebx
c0103aeb:	81 ec 44 04 00 00    	sub    $0x444,%esp

    OStream out("\n\n errorCode = ", "blue");
c0103af1:	8d b5 d3 fb ff ff    	lea    -0x42d(%ebp),%esi
c0103af7:	8d bd d8 fb ff ff    	lea    -0x428(%ebp),%edi
c0103afd:	8d 83 96 39 fe ff    	lea    -0x1c66a(%ebx),%eax
c0103b03:	50                   	push   %eax
c0103b04:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c0103b0a:	50                   	push   %eax
c0103b0b:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c0103b11:	e8 e4 21 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103b16:	58                   	pop    %eax
c0103b17:	5a                   	pop    %edx
c0103b18:	8d 93 9f 3c fe ff    	lea    -0x1c361(%ebx),%edx
c0103b1e:	52                   	push   %edx
c0103b1f:	56                   	push   %esi
c0103b20:	e8 d5 21 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103b25:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103b2b:	83 c4 0c             	add    $0xc,%esp
c0103b2e:	50                   	push   %eax
c0103b2f:	56                   	push   %esi
c0103b30:	57                   	push   %edi
c0103b31:	e8 98 df ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0103b36:	89 34 24             	mov    %esi,(%esp)
c0103b39:	e8 d6 21 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103b3e:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103b44:	89 04 24             	mov    %eax,(%esp)
c0103b47:	e8 c8 21 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue(errorCode);
c0103b4c:	59                   	pop    %ecx
c0103b4d:	58                   	pop    %eax
c0103b4e:	8d 45 10             	lea    0x10(%ebp),%eax
c0103b51:	50                   	push   %eax
c0103b52:	57                   	push   %edi
c0103b53:	e8 08 e1 ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    out.flush();
c0103b58:	89 3c 24             	mov    %edi,(%esp)
c0103b5b:	e8 08 e0 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    int ret = -E_INVAL;
    uint32_t perm;
    MMU::PTEntry *pte = nullptr;

    //try to find a vma which include addr
    auto vma = findVma(mm, addr);
c0103b60:	83 c4 0c             	add    $0xc,%esp
c0103b63:	ff 75 14             	pushl  0x14(%ebp)
c0103b66:	ff 75 0c             	pushl  0xc(%ebp)
c0103b69:	ff 75 08             	pushl  0x8(%ebp)
c0103b6c:	e8 3b fa ff ff       	call   c01035ac <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>

    //pgfault_num++;
    //If the addr is in the range of a mm's vma?
    if (vma == nullptr || vma->data.vm_start > addr) {
c0103b71:	83 c4 10             	add    $0x10,%esp
c0103b74:	85 c0                	test   %eax,%eax
c0103b76:	74 0c                	je     c0103b84 <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0xaa>
c0103b78:	8b 4d 14             	mov    0x14(%ebp),%ecx
c0103b7b:	39 48 04             	cmp    %ecx,0x4(%eax)
c0103b7e:	0f 86 96 00 00 00    	jbe    c0103c1a <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x140>
        DEBUGPRINT("invalid address, not exist in mm");
c0103b84:	51                   	push   %ecx
c0103b85:	51                   	push   %ecx
c0103b86:	8d 93 b1 39 fe ff    	lea    -0x1c64f(%ebx),%edx
c0103b8c:	52                   	push   %edx
c0103b8d:	56                   	push   %esi
c0103b8e:	89 85 c0 fb ff ff    	mov    %eax,-0x440(%ebp)
c0103b94:	e8 61 21 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103b99:	8d 93 29 3b fe ff    	lea    -0x1c4d7(%ebx),%edx
c0103b9f:	5f                   	pop    %edi
c0103ba0:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0103ba6:	58                   	pop    %eax
c0103ba7:	52                   	push   %edx
c0103ba8:	8d 95 ce fb ff ff    	lea    -0x432(%ebp),%edx
c0103bae:	52                   	push   %edx
c0103baf:	89 95 c4 fb ff ff    	mov    %edx,-0x43c(%ebp)
c0103bb5:	e8 40 21 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103bba:	8b 95 c4 fb ff ff    	mov    -0x43c(%ebp),%edx
c0103bc0:	83 c4 0c             	add    $0xc,%esp
c0103bc3:	56                   	push   %esi
c0103bc4:	52                   	push   %edx
c0103bc5:	57                   	push   %edi
c0103bc6:	e8 03 df ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0103bcb:	8b 95 c4 fb ff ff    	mov    -0x43c(%ebp),%edx
c0103bd1:	89 14 24             	mov    %edx,(%esp)
c0103bd4:	e8 3b 21 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103bd9:	89 34 24             	mov    %esi,(%esp)
c0103bdc:	e8 33 21 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103be1:	58                   	pop    %eax
c0103be2:	5a                   	pop    %edx
c0103be3:	8d 93 af 3c fe ff    	lea    -0x1c351(%ebx),%edx
c0103be9:	52                   	push   %edx
c0103bea:	56                   	push   %esi
c0103beb:	e8 0a 21 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103bf0:	59                   	pop    %ecx
c0103bf1:	58                   	pop    %eax
c0103bf2:	56                   	push   %esi
c0103bf3:	57                   	push   %edi
c0103bf4:	e8 23 e0 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0103bf9:	89 34 24             	mov    %esi,(%esp)
c0103bfc:	e8 13 21 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103c01:	89 3c 24             	mov    %edi,(%esp)
c0103c04:	e8 5f df ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c0103c09:	89 3c 24             	mov    %edi,(%esp)
c0103c0c:	e8 9b df ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0103c11:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c0103c17:	83 c4 10             	add    $0x10,%esp
    } 
    //check the errorCode
    switch (errorCode & 0b11) {
c0103c1a:	8b 55 10             	mov    0x10(%ebp),%edx
c0103c1d:	83 e2 03             	and    $0x3,%edx
c0103c20:	83 fa 01             	cmp    $0x1,%edx
c0103c23:	74 7c                	je     c0103ca1 <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x1c7>
c0103c25:	8b 40 0c             	mov    0xc(%eax),%eax
c0103c28:	72 0e                	jb     c0103c38 <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x15e>
c0103c2a:	83 fa 02             	cmp    $0x2,%edx
c0103c2d:	0f 84 02 01 00 00    	je     c0103d35 <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x25b>
c0103c33:	e9 65 01 00 00       	jmp    c0103d9d <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x2c3>
        case 0: /* error code flag : (W/R=0, P=0): read, not present */
            if (!(vma->data.vm_flags & (VM_READ | VM_EXEC))) {
c0103c38:	a8 05                	test   $0x5,%al
c0103c3a:	0f 85 5d 01 00 00    	jne    c0103d9d <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x2c3>
                DEBUGPRINT("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec");
c0103c40:	51                   	push   %ecx
c0103c41:	51                   	push   %ecx
c0103c42:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0103c48:	50                   	push   %eax
c0103c49:	56                   	push   %esi
c0103c4a:	e8 ab 20 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103c4f:	5f                   	pop    %edi
c0103c50:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0103c56:	58                   	pop    %eax
c0103c57:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c0103c5d:	50                   	push   %eax
c0103c5e:	8d 85 ce fb ff ff    	lea    -0x432(%ebp),%eax
c0103c64:	50                   	push   %eax
c0103c65:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c0103c6b:	e8 8a 20 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103c70:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103c76:	83 c4 0c             	add    $0xc,%esp
c0103c79:	56                   	push   %esi
c0103c7a:	50                   	push   %eax
c0103c7b:	57                   	push   %edi
c0103c7c:	e8 4d de ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0103c81:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103c87:	89 04 24             	mov    %eax,(%esp)
c0103c8a:	e8 85 20 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103c8f:	89 34 24             	mov    %esi,(%esp)
c0103c92:	e8 7d 20 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103c97:	58                   	pop    %eax
c0103c98:	8d 83 d0 3c fe ff    	lea    -0x1c330(%ebx),%eax
c0103c9e:	5a                   	pop    %edx
c0103c9f:	eb 5f                	jmp    c0103d00 <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x226>
                goto failed;
            }
            break;

        case 1:     /* error code flag : (W/R=0, P=1): read, present */
            DEBUGPRINT("do_pgfault failed: error code flag = read AND present");
c0103ca1:	51                   	push   %ecx
c0103ca2:	51                   	push   %ecx
c0103ca3:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0103ca9:	50                   	push   %eax
c0103caa:	56                   	push   %esi
c0103cab:	e8 4a 20 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103cb0:	5f                   	pop    %edi
c0103cb1:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0103cb7:	58                   	pop    %eax
c0103cb8:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c0103cbe:	50                   	push   %eax
c0103cbf:	8d 85 ce fb ff ff    	lea    -0x432(%ebp),%eax
c0103cc5:	50                   	push   %eax
c0103cc6:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c0103ccc:	e8 29 20 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103cd1:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103cd7:	83 c4 0c             	add    $0xc,%esp
c0103cda:	56                   	push   %esi
c0103cdb:	50                   	push   %eax
c0103cdc:	57                   	push   %edi
c0103cdd:	e8 ec dd ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0103ce2:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103ce8:	89 04 24             	mov    %eax,(%esp)
c0103ceb:	e8 24 20 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103cf0:	89 34 24             	mov    %esi,(%esp)
c0103cf3:	e8 1c 20 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103cf8:	58                   	pop    %eax
c0103cf9:	8d 83 32 3d fe ff    	lea    -0x1c2ce(%ebx),%eax
c0103cff:	5a                   	pop    %edx
c0103d00:	50                   	push   %eax
c0103d01:	56                   	push   %esi
c0103d02:	e8 f3 1f 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103d07:	58                   	pop    %eax
c0103d08:	5a                   	pop    %edx
c0103d09:	56                   	push   %esi
c0103d0a:	57                   	push   %edi
c0103d0b:	e8 0c df ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0103d10:	89 34 24             	mov    %esi,(%esp)
c0103d13:	e8 fc 1f 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103d18:	89 3c 24             	mov    %edi,(%esp)
c0103d1b:	e8 48 de ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c0103d20:	89 3c 24             	mov    %edi,(%esp)
    int ret = -E_INVAL;
c0103d23:	bf fd ff ff ff       	mov    $0xfffffffd,%edi
            DEBUGPRINT("do_pgfault failed: error code flag = read AND present");
c0103d28:	e8 7f de ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
            goto failed;
c0103d2d:	83 c4 10             	add    $0x10,%esp
c0103d30:	e9 bd 02 00 00       	jmp    c0103ff2 <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x518>

        case 2:     /* error code flag : (W/R=1, P=0): write, not present */
            if (!(vma->data.vm_flags & VM_WRITE)) {
c0103d35:	a8 02                	test   $0x2,%al
c0103d37:	75 64                	jne    c0103d9d <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x2c3>
                DEBUGPRINT("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write");
c0103d39:	50                   	push   %eax
c0103d3a:	50                   	push   %eax
c0103d3b:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0103d41:	50                   	push   %eax
c0103d42:	56                   	push   %esi
c0103d43:	e8 b2 1f 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103d48:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0103d4e:	58                   	pop    %eax
c0103d4f:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c0103d55:	5a                   	pop    %edx
c0103d56:	50                   	push   %eax
c0103d57:	8d 85 ce fb ff ff    	lea    -0x432(%ebp),%eax
c0103d5d:	50                   	push   %eax
c0103d5e:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c0103d64:	e8 91 1f 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103d69:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103d6f:	83 c4 0c             	add    $0xc,%esp
c0103d72:	56                   	push   %esi
c0103d73:	50                   	push   %eax
c0103d74:	57                   	push   %edi
c0103d75:	e8 54 dd ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0103d7a:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103d80:	89 04 24             	mov    %eax,(%esp)
c0103d83:	e8 8c 1f 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103d88:	89 34 24             	mov    %esi,(%esp)
c0103d8b:	e8 84 1f 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103d90:	59                   	pop    %ecx
c0103d91:	58                   	pop    %eax
c0103d92:	8d 83 68 3d fe ff    	lea    -0x1c298(%ebx),%eax
c0103d98:	e9 63 ff ff ff       	jmp    c0103d00 <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x226>
            break;   /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    }
   

    perm = PTE_U;
    if (vma->data.vm_flags & VM_WRITE) {
c0103d9d:	83 e0 02             	and    $0x2,%eax
            return (a / n) * n;
c0103da0:	8b 7d 14             	mov    0x14(%ebp),%edi
        perm |= PTE_W;
c0103da3:	83 f8 01             	cmp    $0x1,%eax
                lad.OFF = vAd & 0xFFF;
c0103da6:	8b 85 e0 fd ff ff    	mov    -0x220(%ebp),%eax
c0103dac:	19 d2                	sbb    %edx,%edx

    ret = -E_NO_MEM;

    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((pte = kernel::pmm.getPTE(mm->data.pdt, MMU::LinearAD::LAD(addr))) == nullptr) {
c0103dae:	6a 01                	push   $0x1
        perm |= PTE_W;
c0103db0:	83 e2 fe             	and    $0xfffffffe,%edx
c0103db3:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c0103db9:	83 c2 06             	add    $0x6,%edx
c0103dbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103dc1:	66 89 85 e0 fd ff ff 	mov    %ax,-0x220(%ebp)
                lad.PTI = (vAd >> PGSHIFT) & 0x3FF;
c0103dc8:	89 f8                	mov    %edi,%eax
c0103dca:	25 00 f0 3f 00       	and    $0x3ff000,%eax
c0103dcf:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c0103dd5:	8b 85 e0 fd ff ff    	mov    -0x220(%ebp),%eax
                lad.PDI = (vAd >> PTSHIFT) & 0x3FF;
c0103ddb:	c1 ef 16             	shr    $0x16,%edi
c0103dde:	89 f9                	mov    %edi,%ecx
c0103de0:	c1 e1 06             	shl    $0x6,%ecx
    if ((pte = kernel::pmm.getPTE(mm->data.pdt, MMU::LinearAD::LAD(addr))) == nullptr) {
c0103de3:	8d b5 e0 fd ff ff    	lea    -0x220(%ebp),%esi
                lad.PTI = (vAd >> PGSHIFT) & 0x3FF;
c0103de9:	25 ff 0f c0 ff       	and    $0xffc00fff,%eax
c0103dee:	0b 85 c4 fb ff ff    	or     -0x43c(%ebp),%eax
c0103df4:	56                   	push   %esi
c0103df5:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)
                lad.PDI = (vAd >> PTSHIFT) & 0x3FF;
c0103dfb:	66 8b 85 e2 fd ff ff 	mov    -0x21e(%ebp),%ax
        perm |= PTE_W;
c0103e02:	89 95 bc fb ff ff    	mov    %edx,-0x444(%ebp)
c0103e08:	83 e0 3f             	and    $0x3f,%eax
c0103e0b:	09 c8                	or     %ecx,%eax
    if ((pte = kernel::pmm.getPTE(mm->data.pdt, MMU::LinearAD::LAD(addr))) == nullptr) {
c0103e0d:	c7 c1 20 50 12 c0    	mov    $0xc0125020,%ecx
c0103e13:	66 89 85 e2 fd ff ff 	mov    %ax,-0x21e(%ebp)
c0103e1a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e1d:	89 8d c0 fb ff ff    	mov    %ecx,-0x440(%ebp)
c0103e23:	ff 70 14             	pushl  0x14(%eax)
c0103e26:	51                   	push   %ecx
c0103e27:	e8 3c e7 ff ff       	call   c0102568 <_ZN5PhyMM6getPTEEPN3MMU7PTEntryERKNS0_8LinearADEb>
c0103e2c:	83 c4 10             	add    $0x10,%esp
c0103e2f:	8b 8d c0 fb ff ff    	mov    -0x440(%ebp),%ecx
c0103e35:	8b 95 bc fb ff ff    	mov    -0x444(%ebp),%edx
c0103e3b:	85 c0                	test   %eax,%eax
c0103e3d:	75 64                	jne    c0103ea3 <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x3c9>
        DEBUGPRINT("get_pte in do_pgfault failed");
c0103e3f:	50                   	push   %eax
c0103e40:	50                   	push   %eax
c0103e41:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0103e47:	50                   	push   %eax
c0103e48:	8d bd d3 fb ff ff    	lea    -0x42d(%ebp),%edi
c0103e4e:	57                   	push   %edi
c0103e4f:	e8 a6 1e 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103e54:	58                   	pop    %eax
c0103e55:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c0103e5b:	5a                   	pop    %edx
c0103e5c:	50                   	push   %eax
c0103e5d:	8d 85 ce fb ff ff    	lea    -0x432(%ebp),%eax
c0103e63:	50                   	push   %eax
c0103e64:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c0103e6a:	e8 8b 1e 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103e6f:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103e75:	83 c4 0c             	add    $0xc,%esp
c0103e78:	57                   	push   %edi
c0103e79:	50                   	push   %eax
c0103e7a:	56                   	push   %esi
c0103e7b:	e8 4e dc ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0103e80:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103e86:	89 04 24             	mov    %eax,(%esp)
c0103e89:	e8 86 1e 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103e8e:	89 3c 24             	mov    %edi,(%esp)
c0103e91:	e8 7e 1e 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103e96:	59                   	pop    %ecx
c0103e97:	58                   	pop    %eax
c0103e98:	8d 83 c4 3d fe ff    	lea    -0x1c23c(%ebx),%eax
c0103e9e:	e9 8c 00 00 00       	jmp    c0103f2f <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x455>
        goto failed;
    }
    
    if (pte->isEmpty()) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
c0103ea3:	83 38 00             	cmpl   $0x0,(%eax)
c0103ea6:	0f 85 b8 00 00 00    	jne    c0103f64 <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x48a>
c0103eac:	c1 e7 16             	shl    $0x16,%edi
        if (kernel::pmm.allocPageAndMap(mm->data.pdt, MMU::LinearAD::LAD(addr), perm) == nullptr) {
c0103eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103eb2:	0b bd c4 fb ff ff    	or     -0x43c(%ebp),%edi
c0103eb8:	52                   	push   %edx
c0103eb9:	57                   	push   %edi
            goto failed;
        }*/
        BREAKPOINT("swap not implement");
   }

   ret = 0;
c0103eba:	31 ff                	xor    %edi,%edi
        if (kernel::pmm.allocPageAndMap(mm->data.pdt, MMU::LinearAD::LAD(addr), perm) == nullptr) {
c0103ebc:	ff 70 14             	pushl  0x14(%eax)
c0103ebf:	51                   	push   %ecx
c0103ec0:	e8 cb f1 ff ff       	call   c0103090 <_ZN5PhyMM15allocPageAndMapEPN3MMU7PTEntryENS0_8LinearADEj>
c0103ec5:	83 c4 10             	add    $0x10,%esp
c0103ec8:	85 c0                	test   %eax,%eax
c0103eca:	0f 85 22 01 00 00    	jne    c0103ff2 <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x518>
            DEBUGPRINT("pgdir_alloc_page in do_pgfault failed");
c0103ed0:	51                   	push   %ecx
c0103ed1:	51                   	push   %ecx
c0103ed2:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0103ed8:	50                   	push   %eax
c0103ed9:	8d bd d3 fb ff ff    	lea    -0x42d(%ebp),%edi
c0103edf:	57                   	push   %edi
c0103ee0:	e8 15 1e 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103ee5:	58                   	pop    %eax
c0103ee6:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c0103eec:	5a                   	pop    %edx
c0103eed:	50                   	push   %eax
c0103eee:	8d 85 ce fb ff ff    	lea    -0x432(%ebp),%eax
c0103ef4:	50                   	push   %eax
c0103ef5:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c0103efb:	e8 fa 1d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103f00:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103f06:	83 c4 0c             	add    $0xc,%esp
c0103f09:	57                   	push   %edi
c0103f0a:	50                   	push   %eax
c0103f0b:	56                   	push   %esi
c0103f0c:	e8 bd db ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0103f11:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103f17:	89 04 24             	mov    %eax,(%esp)
c0103f1a:	e8 f5 1d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103f1f:	89 3c 24             	mov    %edi,(%esp)
c0103f22:	e8 ed 1d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103f27:	59                   	pop    %ecx
c0103f28:	58                   	pop    %eax
c0103f29:	8d 83 e1 3d fe ff    	lea    -0x1c21f(%ebx),%eax
c0103f2f:	50                   	push   %eax
c0103f30:	57                   	push   %edi
c0103f31:	e8 c4 1d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103f36:	58                   	pop    %eax
c0103f37:	5a                   	pop    %edx
c0103f38:	57                   	push   %edi
c0103f39:	56                   	push   %esi
c0103f3a:	e8 dd dc ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0103f3f:	89 3c 24             	mov    %edi,(%esp)
    ret = -E_NO_MEM;
c0103f42:	bf fc ff ff ff       	mov    $0xfffffffc,%edi
            DEBUGPRINT("pgdir_alloc_page in do_pgfault failed");
c0103f47:	e8 c8 1d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103f4c:	89 34 24             	mov    %esi,(%esp)
c0103f4f:	e8 14 dc ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c0103f54:	89 34 24             	mov    %esi,(%esp)
c0103f57:	e8 50 dc ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
            goto failed;
c0103f5c:	83 c4 10             	add    $0x10,%esp
c0103f5f:	e9 8e 00 00 00       	jmp    c0103ff2 <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj+0x518>
        BREAKPOINT("swap not implement");
c0103f64:	50                   	push   %eax
c0103f65:	50                   	push   %eax
c0103f66:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0103f6c:	50                   	push   %eax
c0103f6d:	8d bd d3 fb ff ff    	lea    -0x42d(%ebp),%edi
c0103f73:	57                   	push   %edi
c0103f74:	e8 81 1d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103f79:	8d 83 07 3e fe ff    	lea    -0x1c1f9(%ebx),%eax
c0103f7f:	5a                   	pop    %edx
c0103f80:	59                   	pop    %ecx
c0103f81:	50                   	push   %eax
c0103f82:	8d 85 ce fb ff ff    	lea    -0x432(%ebp),%eax
c0103f88:	50                   	push   %eax
c0103f89:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c0103f8f:	e8 66 1d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103f94:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103f9a:	83 c4 0c             	add    $0xc,%esp
c0103f9d:	57                   	push   %edi
c0103f9e:	50                   	push   %eax
c0103f9f:	56                   	push   %esi
c0103fa0:	e8 29 db ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0103fa5:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103fab:	89 04 24             	mov    %eax,(%esp)
c0103fae:	e8 61 1d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103fb3:	89 3c 24             	mov    %edi,(%esp)
c0103fb6:	e8 59 1d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103fbb:	58                   	pop    %eax
c0103fbc:	8d 83 15 3e fe ff    	lea    -0x1c1eb(%ebx),%eax
c0103fc2:	5a                   	pop    %edx
c0103fc3:	50                   	push   %eax
c0103fc4:	57                   	push   %edi
c0103fc5:	e8 30 1d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0103fca:	59                   	pop    %ecx
c0103fcb:	58                   	pop    %eax
c0103fcc:	57                   	push   %edi
c0103fcd:	56                   	push   %esi
c0103fce:	e8 49 dc ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0103fd3:	89 3c 24             	mov    %edi,(%esp)
c0103fd6:	e8 39 1d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0103fdb:	89 34 24             	mov    %esi,(%esp)
c0103fde:	e8 85 db ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103fe3:	fa                   	cli    
    asm volatile ("hlt");
c0103fe4:	f4                   	hlt    
   ret = 0;
c0103fe5:	31 ff                	xor    %edi,%edi
        BREAKPOINT("swap not implement");
c0103fe7:	89 34 24             	mov    %esi,(%esp)
c0103fea:	e8 bd db ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0103fef:	83 c4 10             	add    $0x10,%esp
    OStream out("\n\n errorCode = ", "blue");
c0103ff2:	8d 85 d8 fb ff ff    	lea    -0x428(%ebp),%eax
c0103ff8:	83 ec 0c             	sub    $0xc,%esp
c0103ffb:	50                   	push   %eax
c0103ffc:	e8 ab db ff ff       	call   c0101bac <_ZN7OStreamD1Ev>

failed:

    return ret;
c0104001:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0104004:	89 f8                	mov    %edi,%eax
c0104006:	5b                   	pop    %ebx
c0104007:	5e                   	pop    %esi
c0104008:	5f                   	pop    %edi
c0104009:	5d                   	pop    %ebp
c010400a:	c3                   	ret    
c010400b:	90                   	nop

c010400c <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE>:
void VMM::insertVma(List<MM>::DLNode *mm, List<VMA>::DLNode *vma) {
c010400c:	55                   	push   %ebp
c010400d:	89 e5                	mov    %esp,%ebp
c010400f:	57                   	push   %edi
c0104010:	56                   	push   %esi
c0104011:	53                   	push   %ebx
c0104012:	e8 b6 cb ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0104017:	81 c3 09 e4 01 00    	add    $0x1e409,%ebx
c010401d:	81 ec 44 04 00 00    	sub    $0x444,%esp
c0104023:	8b 45 10             	mov    0x10(%ebp),%eax
    OStream out("\n[new] vma: vm_start = ", "blue");
c0104026:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
void VMM::insertVma(List<MM>::DLNode *mm, List<VMA>::DLNode *vma) {
c010402c:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
    OStream out("\n[new] vma: vm_start = ", "blue");
c0104032:	8d 93 96 39 fe ff    	lea    -0x1c66a(%ebx),%edx
c0104038:	52                   	push   %edx
c0104039:	57                   	push   %edi
c010403a:	e8 bb 1c 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010403f:	8d 93 28 3e fe ff    	lea    -0x1c1d8(%ebx),%edx
c0104045:	59                   	pop    %ecx
c0104046:	5e                   	pop    %esi
c0104047:	8d b5 d3 fb ff ff    	lea    -0x42d(%ebp),%esi
c010404d:	52                   	push   %edx
c010404e:	56                   	push   %esi
c010404f:	e8 a6 1c 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104054:	83 c4 0c             	add    $0xc,%esp
c0104057:	57                   	push   %edi
c0104058:	56                   	push   %esi
c0104059:	8d 95 d8 fb ff ff    	lea    -0x428(%ebp),%edx
c010405f:	52                   	push   %edx
c0104060:	89 95 c0 fb ff ff    	mov    %edx,-0x440(%ebp)
c0104066:	e8 63 da ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c010406b:	89 34 24             	mov    %esi,(%esp)
c010406e:	e8 a1 1c 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104073:	89 3c 24             	mov    %edi,(%esp)
c0104076:	e8 99 1c 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue(vma->data.vm_start);
c010407b:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0104081:	8b 48 04             	mov    0x4(%eax),%ecx
c0104084:	58                   	pop    %eax
c0104085:	5a                   	pop    %edx
c0104086:	8b 95 c0 fb ff ff    	mov    -0x440(%ebp),%edx
c010408c:	89 8d e0 fd ff ff    	mov    %ecx,-0x220(%ebp)
c0104092:	57                   	push   %edi
c0104093:	52                   	push   %edx
c0104094:	e8 c7 db ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    assert(vma->data.vm_start < vma->data.vm_end);
c0104099:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c010409f:	83 c4 10             	add    $0x10,%esp
c01040a2:	8b 48 08             	mov    0x8(%eax),%ecx
c01040a5:	39 48 04             	cmp    %ecx,0x4(%eax)
c01040a8:	0f 82 92 00 00 00    	jb     c0104140 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x134>
c01040ae:	89 85 c0 fb ff ff    	mov    %eax,-0x440(%ebp)
c01040b4:	8d 93 b1 39 fe ff    	lea    -0x1c64f(%ebx),%edx
c01040ba:	50                   	push   %eax
c01040bb:	50                   	push   %eax
c01040bc:	52                   	push   %edx
c01040bd:	56                   	push   %esi
c01040be:	e8 37 1c 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01040c3:	58                   	pop    %eax
c01040c4:	5a                   	pop    %edx
c01040c5:	8d 93 bb 39 fe ff    	lea    -0x1c645(%ebx),%edx
c01040cb:	52                   	push   %edx
c01040cc:	8d 95 ce fb ff ff    	lea    -0x432(%ebp),%edx
c01040d2:	52                   	push   %edx
c01040d3:	89 95 c4 fb ff ff    	mov    %edx,-0x43c(%ebp)
c01040d9:	e8 1c 1c 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01040de:	8b 95 c4 fb ff ff    	mov    -0x43c(%ebp),%edx
c01040e4:	83 c4 0c             	add    $0xc,%esp
c01040e7:	56                   	push   %esi
c01040e8:	52                   	push   %edx
c01040e9:	57                   	push   %edi
c01040ea:	e8 df d9 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01040ef:	8b 95 c4 fb ff ff    	mov    -0x43c(%ebp),%edx
c01040f5:	89 14 24             	mov    %edx,(%esp)
c01040f8:	e8 17 1c 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01040fd:	89 34 24             	mov    %esi,(%esp)
c0104100:	e8 0f 1c 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104105:	8d 93 40 3e fe ff    	lea    -0x1c1c0(%ebx),%edx
c010410b:	59                   	pop    %ecx
c010410c:	58                   	pop    %eax
c010410d:	52                   	push   %edx
c010410e:	56                   	push   %esi
c010410f:	e8 e6 1b 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104114:	58                   	pop    %eax
c0104115:	5a                   	pop    %edx
c0104116:	56                   	push   %esi
c0104117:	57                   	push   %edi
c0104118:	e8 ff da ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c010411d:	89 34 24             	mov    %esi,(%esp)
c0104120:	e8 ef 1b 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104125:	89 3c 24             	mov    %edi,(%esp)
c0104128:	e8 3b da ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010412d:	fa                   	cli    
    asm volatile ("hlt");
c010412e:	f4                   	hlt    
c010412f:	89 3c 24             	mov    %edi,(%esp)
c0104132:	e8 75 da ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0104137:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c010413d:	83 c4 10             	add    $0x10,%esp
    it.setCurrentNode(headNode.first);
c0104140:	8b 7d 0c             	mov    0xc(%ebp),%edi
c0104143:	8b 77 04             	mov    0x4(%edi),%esi
                    currentNode = node;
c0104146:	89 37                	mov    %esi,(%edi)
    decltype(vma) vmaNode, preVma = nullptr;
c0104148:	31 ff                	xor    %edi,%edi
                    if (!hasNext()) {
c010414a:	85 f6                	test   %esi,%esi
c010414c:	0f 84 e5 01 00 00    	je     c0104337 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x32b>
        if (vmaNode->data.vm_start > vma->data.vm_start) {
c0104152:	8b 50 04             	mov    0x4(%eax),%edx
c0104155:	39 56 04             	cmp    %edx,0x4(%esi)
                    currentNode = currentNode->next;
c0104158:	8b 4e 14             	mov    0x14(%esi),%ecx
c010415b:	77 06                	ja     c0104163 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x157>
c010415d:	89 f7                	mov    %esi,%edi
c010415f:	89 ce                	mov    %ecx,%esi
c0104161:	eb e7                	jmp    c010414a <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x13e>
    if (preVma != nullptr) {    // pre-note
c0104163:	85 ff                	test   %edi,%edi
c0104165:	74 1a                	je     c0104181 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x175>
        checkVamOverlap(preVma, vma);
c0104167:	51                   	push   %ecx
c0104168:	50                   	push   %eax
c0104169:	57                   	push   %edi
c010416a:	ff 75 08             	pushl  0x8(%ebp)
c010416d:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c0104173:	e8 54 f7 ff ff       	call   c01038cc <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_>
c0104178:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c010417e:	83 c4 10             	add    $0x10,%esp
        checkVamOverlap(vma, vmaNode);
c0104181:	52                   	push   %edx
c0104182:	56                   	push   %esi
c0104183:	50                   	push   %eax
c0104184:	ff 75 08             	pushl  0x8(%ebp)
c0104187:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c010418d:	e8 3a f7 ff ff       	call   c01038cc <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_>
    vma->data.vm_mm = mm;       // pointer father-MM
c0104192:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    if (preVma == nullptr) {
c0104195:	83 c4 10             	add    $0x10,%esp
    vma->data.vm_mm = mm;       // pointer father-MM
c0104198:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
    if (preVma == nullptr) {
c010419e:	85 ff                	test   %edi,%edi
    vma->data.vm_mm = mm;       // pointer father-MM
c01041a0:	89 08                	mov    %ecx,(%eax)
    if (preVma == nullptr) {
c01041a2:	75 55                	jne    c01041f9 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x1ed>
    return (headNode.eNum == 0 && headNode.last == nullptr);
c01041a4:	8b 7d 0c             	mov    0xc(%ebp),%edi
c01041a7:	8b 57 0c             	mov    0xc(%edi),%edx
c01041aa:	85 d2                	test   %edx,%edx
c01041ac:	75 0a                	jne    c01041b8 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x1ac>
c01041ae:	83 7f 08 00          	cmpl   $0x0,0x8(%edi)
c01041b2:	0f 84 fd 00 00 00    	je     c01042b5 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x2a9>
        node->next = headNode.first;
c01041b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
        headNode.eNum++;
c01041bb:	42                   	inc    %edx
        headNode.first = node;
c01041bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
        node->pre = nullptr;
c01041bf:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        node->next = headNode.first;
c01041c6:	8b 49 04             	mov    0x4(%ecx),%ecx
c01041c9:	89 48 14             	mov    %ecx,0x14(%eax)
        headNode.first->pre = node;
c01041cc:	89 41 10             	mov    %eax,0x10(%ecx)
        headNode.first = node;
c01041cf:	89 47 04             	mov    %eax,0x4(%edi)
        headNode.eNum++;
c01041d2:	89 57 0c             	mov    %edx,0xc(%edi)
c01041d5:	e9 04 01 00 00       	jmp    c01042de <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x2d2>
        checkVamOverlap(preVma, vma);
c01041da:	52                   	push   %edx
c01041db:	50                   	push   %eax
c01041dc:	57                   	push   %edi
c01041dd:	ff 75 08             	pushl  0x8(%ebp)
c01041e0:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c01041e6:	e8 e1 f6 ff ff       	call   c01038cc <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_>
    vma->data.vm_mm = mm;       // pointer father-MM
c01041eb:	8b 55 0c             	mov    0xc(%ebp),%edx
c01041ee:	83 c4 10             	add    $0x10,%esp
c01041f1:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c01041f7:	89 10                	mov    %edx,(%eax)
        DEBUGPRINT("Inert-->mid");
c01041f9:	56                   	push   %esi
c01041fa:	56                   	push   %esi
c01041fb:	8d 8b b1 39 fe ff    	lea    -0x1c64f(%ebx),%ecx
c0104201:	51                   	push   %ecx
c0104202:	8d b5 d3 fb ff ff    	lea    -0x42d(%ebp),%esi
c0104208:	56                   	push   %esi
c0104209:	89 85 bc fb ff ff    	mov    %eax,-0x444(%ebp)
c010420f:	e8 e6 1a 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104214:	8d 8b 29 3b fe ff    	lea    -0x1c4d7(%ebx),%ecx
c010421a:	58                   	pop    %eax
c010421b:	5a                   	pop    %edx
c010421c:	51                   	push   %ecx
c010421d:	8d 8d ce fb ff ff    	lea    -0x432(%ebp),%ecx
c0104223:	51                   	push   %ecx
c0104224:	89 8d c4 fb ff ff    	mov    %ecx,-0x43c(%ebp)
c010422a:	e8 cb 1a 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010422f:	8b 8d c4 fb ff ff    	mov    -0x43c(%ebp),%ecx
c0104235:	83 c4 0c             	add    $0xc,%esp
c0104238:	56                   	push   %esi
c0104239:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c010423f:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c0104245:	51                   	push   %ecx
c0104246:	50                   	push   %eax
c0104247:	89 8d c0 fb ff ff    	mov    %ecx,-0x440(%ebp)
c010424d:	e8 7c d8 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0104252:	8b 8d c0 fb ff ff    	mov    -0x440(%ebp),%ecx
c0104258:	89 0c 24             	mov    %ecx,(%esp)
c010425b:	e8 b4 1a 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104260:	89 34 24             	mov    %esi,(%esp)
c0104263:	e8 ac 1a 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104268:	59                   	pop    %ecx
c0104269:	8d 8b 66 3e fe ff    	lea    -0x1c19a(%ebx),%ecx
c010426f:	58                   	pop    %eax
c0104270:	51                   	push   %ecx
c0104271:	56                   	push   %esi
c0104272:	e8 83 1a 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104277:	58                   	pop    %eax
c0104278:	5a                   	pop    %edx
c0104279:	56                   	push   %esi
c010427a:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c0104280:	e8 97 d9 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104285:	89 34 24             	mov    %esi,(%esp)
c0104288:	e8 87 1a 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010428d:	59                   	pop    %ecx
c010428e:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c0104294:	e8 cf d8 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c0104299:	5e                   	pop    %esi
c010429a:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c01042a0:	e8 07 d9 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
    if (node1->next == nullptr) {
c01042a5:	8b 4f 14             	mov    0x14(%edi),%ecx
c01042a8:	83 c4 10             	add    $0x10,%esp
c01042ab:	8b 85 bc fb ff ff    	mov    -0x444(%ebp),%eax
c01042b1:	85 c9                	test   %ecx,%ecx
c01042b3:	75 10                	jne    c01042c5 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x2b9>
        addLNode(*node2);
c01042b5:	51                   	push   %ecx
c01042b6:	51                   	push   %ecx
c01042b7:	50                   	push   %eax
c01042b8:	ff 75 0c             	pushl  0xc(%ebp)
c01042bb:	e8 9c 14 00 00       	call   c010575c <_ZN4ListIN3VMM3VMAEE8addLNodeERNS2_6DLNodeE>
c01042c0:	83 c4 10             	add    $0x10,%esp
c01042c3:	eb 19                	jmp    c01042de <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x2d2>
        node2->next = node1->next;
c01042c5:	89 48 14             	mov    %ecx,0x14(%eax)
        if (node1->next != nullptr) {
c01042c8:	8b 4f 14             	mov    0x14(%edi),%ecx
        node2->pre = node1;
c01042cb:	89 78 10             	mov    %edi,0x10(%eax)
        if (node1->next != nullptr) {
c01042ce:	85 c9                	test   %ecx,%ecx
c01042d0:	74 03                	je     c01042d5 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x2c9>
            node1->next->pre = node2;
c01042d2:	89 41 10             	mov    %eax,0x10(%ecx)
        node1->next = node2;
c01042d5:	89 47 14             	mov    %eax,0x14(%edi)
        headNode.eNum++;
c01042d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01042db:	ff 40 0c             	incl   0xc(%eax)
    out.write("\nnodeNum: ");
c01042de:	51                   	push   %ecx
c01042df:	51                   	push   %ecx
c01042e0:	8d 83 72 3e fe ff    	lea    -0x1c18e(%ebx),%eax
c01042e6:	50                   	push   %eax
c01042e7:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01042ed:	57                   	push   %edi
c01042ee:	e8 07 1a 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01042f3:	5e                   	pop    %esi
c01042f4:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c01042fa:	58                   	pop    %eax
c01042fb:	57                   	push   %edi
c01042fc:	56                   	push   %esi
c01042fd:	e8 1a d9 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104302:	89 3c 24             	mov    %edi,(%esp)
c0104305:	e8 0a 1a 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue((mm->data.vmaList.length()));
c010430a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010430d:	8b 40 0c             	mov    0xc(%eax),%eax
c0104310:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)
c0104316:	58                   	pop    %eax
c0104317:	5a                   	pop    %edx
c0104318:	57                   	push   %edi
c0104319:	56                   	push   %esi
c010431a:	e8 41 d9 ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    out.flush();
c010431f:	89 34 24             	mov    %esi,(%esp)
c0104322:	e8 41 d8 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    OStream out("\n[new] vma: vm_start = ", "blue");
c0104327:	89 34 24             	mov    %esi,(%esp)
c010432a:	e8 7d d8 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
}
c010432f:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0104332:	5b                   	pop    %ebx
c0104333:	5e                   	pop    %esi
c0104334:	5f                   	pop    %edi
c0104335:	5d                   	pop    %ebp
c0104336:	c3                   	ret    
    if (preVma != nullptr) {    // pre-note
c0104337:	85 ff                	test   %edi,%edi
c0104339:	0f 85 9b fe ff ff    	jne    c01041da <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x1ce>
    vma->data.vm_mm = mm;       // pointer father-MM
c010433f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104342:	89 10                	mov    %edx,(%eax)
c0104344:	e9 5b fe ff ff       	jmp    c01041a4 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x198>
c0104349:	90                   	nop

c010434a <_ZN3VMM8checkVmaEv>:
void VMM::checkVma() {
c010434a:	55                   	push   %ebp
c010434b:	89 e5                	mov    %esp,%ebp
c010434d:	57                   	push   %edi
c010434e:	56                   	push   %esi
c010434f:	53                   	push   %ebx
c0104350:	e8 78 c8 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0104355:	81 c3 cb e0 01 00    	add    $0x1e0cb,%ebx
c010435b:	81 ec 54 02 00 00    	sub    $0x254,%esp
    DEBUGPRINT("VMM::checkVma");
c0104361:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0104367:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c010436d:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0104373:	50                   	push   %eax
c0104374:	56                   	push   %esi
c0104375:	89 85 bc fd ff ff    	mov    %eax,-0x244(%ebp)
c010437b:	e8 7a 19 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104380:	58                   	pop    %eax
c0104381:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c0104387:	5a                   	pop    %edx
c0104388:	50                   	push   %eax
c0104389:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c010438f:	50                   	push   %eax
c0104390:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c0104396:	e8 5f 19 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010439b:	83 c4 0c             	add    $0xc,%esp
c010439e:	56                   	push   %esi
c010439f:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c01043a5:	57                   	push   %edi
c01043a6:	e8 23 d7 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01043ab:	59                   	pop    %ecx
c01043ac:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c01043b2:	e8 5d 19 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01043b7:	89 34 24             	mov    %esi,(%esp)
c01043ba:	e8 55 19 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01043bf:	58                   	pop    %eax
c01043c0:	8d 83 7d 3e fe ff    	lea    -0x1c183(%ebx),%eax
c01043c6:	5a                   	pop    %edx
c01043c7:	50                   	push   %eax
c01043c8:	56                   	push   %esi
c01043c9:	e8 2c 19 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01043ce:	59                   	pop    %ecx
c01043cf:	58                   	pop    %eax
c01043d0:	56                   	push   %esi
c01043d1:	57                   	push   %edi
c01043d2:	e8 45 d8 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01043d7:	89 34 24             	mov    %esi,(%esp)
c01043da:	e8 35 19 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01043df:	89 3c 24             	mov    %edi,(%esp)
c01043e2:	e8 81 d7 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c01043e7:	89 3c 24             	mov    %edi,(%esp)
c01043ea:	e8 bd d7 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
    uint32_t nr_free_pages_store = kernel::pmm.numFreePages();
c01043ef:	58                   	pop    %eax
c01043f0:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
c01043f6:	e8 7f e9 ff ff       	call   c0102d7a <_ZN5PhyMM12numFreePagesEv>
c01043fb:	89 85 ac fd ff ff    	mov    %eax,-0x254(%ebp)
    auto mm = mmCreate();
c0104401:	58                   	pop    %eax
c0104402:	ff 75 08             	pushl  0x8(%ebp)
c0104405:	e8 40 f3 ff ff       	call   c010374a <_ZN3VMM8mmCreateEv>
    assert(mm != nullptr);
c010440a:	83 c4 10             	add    $0x10,%esp
c010440d:	85 c0                	test   %eax,%eax
    auto mm = mmCreate();
c010440f:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
    assert(mm != nullptr);
c0104415:	75 7b                	jne    c0104492 <_ZN3VMM8checkVmaEv+0x148>
c0104417:	50                   	push   %eax
c0104418:	50                   	push   %eax
c0104419:	ff b5 bc fd ff ff    	pushl  -0x244(%ebp)
c010441f:	56                   	push   %esi
c0104420:	e8 d5 18 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104425:	58                   	pop    %eax
c0104426:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c010442c:	5a                   	pop    %edx
c010442d:	50                   	push   %eax
c010442e:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c0104434:	e8 c1 18 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104439:	83 c4 0c             	add    $0xc,%esp
c010443c:	56                   	push   %esi
c010443d:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c0104443:	57                   	push   %edi
c0104444:	e8 85 d6 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0104449:	59                   	pop    %ecx
c010444a:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c0104450:	e8 bf 18 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104455:	89 34 24             	mov    %esi,(%esp)
c0104458:	e8 b7 18 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010445d:	58                   	pop    %eax
c010445e:	8d 83 8b 3e fe ff    	lea    -0x1c175(%ebx),%eax
c0104464:	5a                   	pop    %edx
c0104465:	50                   	push   %eax
c0104466:	56                   	push   %esi
c0104467:	e8 8e 18 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010446c:	59                   	pop    %ecx
c010446d:	58                   	pop    %eax
c010446e:	56                   	push   %esi
c010446f:	57                   	push   %edi
c0104470:	e8 a7 d7 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104475:	89 34 24             	mov    %esi,(%esp)
c0104478:	e8 97 18 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010447d:	89 3c 24             	mov    %edi,(%esp)
c0104480:	e8 e3 d6 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0104485:	fa                   	cli    
    asm volatile ("hlt");
c0104486:	f4                   	hlt    
c0104487:	89 3c 24             	mov    %edi,(%esp)
c010448a:	e8 1d d7 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c010448f:	83 c4 10             	add    $0x10,%esp
void VMM::checkVma() {
c0104492:	c7 85 c0 fd ff ff 32 	movl   $0x32,-0x240(%ebp)
c0104499:	00 00 00 
        auto *vma = vmaCreate(i * 5, i * 5 + 2, 0);
c010449c:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01044a2:	6a 00                	push   $0x0
c01044a4:	83 c0 02             	add    $0x2,%eax
c01044a7:	50                   	push   %eax
c01044a8:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c01044ae:	ff 75 08             	pushl  0x8(%ebp)
c01044b1:	e8 3a f1 ff ff       	call   c01035f0 <_ZN3VMM9vmaCreateEjjj>
        assert(vma != nullptr);
c01044b6:	83 c4 10             	add    $0x10,%esp
c01044b9:	85 c0                	test   %eax,%eax
c01044bb:	0f 85 9e 00 00 00    	jne    c010455f <_ZN3VMM8checkVmaEv+0x215>
c01044c1:	51                   	push   %ecx
c01044c2:	51                   	push   %ecx
c01044c3:	8d 93 b1 39 fe ff    	lea    -0x1c64f(%ebx),%edx
c01044c9:	52                   	push   %edx
c01044ca:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01044d0:	56                   	push   %esi
c01044d1:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c01044d7:	e8 1e 18 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01044dc:	8d 93 bb 39 fe ff    	lea    -0x1c645(%ebx),%edx
c01044e2:	5f                   	pop    %edi
c01044e3:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01044e9:	58                   	pop    %eax
c01044ea:	52                   	push   %edx
c01044eb:	8d 95 d6 fd ff ff    	lea    -0x22a(%ebp),%edx
c01044f1:	52                   	push   %edx
c01044f2:	89 95 b8 fd ff ff    	mov    %edx,-0x248(%ebp)
c01044f8:	e8 fd 17 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01044fd:	8b 95 b8 fd ff ff    	mov    -0x248(%ebp),%edx
c0104503:	83 c4 0c             	add    $0xc,%esp
c0104506:	56                   	push   %esi
c0104507:	52                   	push   %edx
c0104508:	57                   	push   %edi
c0104509:	e8 c0 d5 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c010450e:	8b 95 b8 fd ff ff    	mov    -0x248(%ebp),%edx
c0104514:	89 14 24             	mov    %edx,(%esp)
c0104517:	e8 f8 17 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010451c:	89 34 24             	mov    %esi,(%esp)
c010451f:	e8 f0 17 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104524:	58                   	pop    %eax
c0104525:	5a                   	pop    %edx
c0104526:	8d 93 99 3e fe ff    	lea    -0x1c167(%ebx),%edx
c010452c:	52                   	push   %edx
c010452d:	56                   	push   %esi
c010452e:	e8 c7 17 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104533:	59                   	pop    %ecx
c0104534:	58                   	pop    %eax
c0104535:	56                   	push   %esi
c0104536:	57                   	push   %edi
c0104537:	e8 e0 d6 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c010453c:	89 34 24             	mov    %esi,(%esp)
c010453f:	e8 d0 17 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104544:	89 3c 24             	mov    %edi,(%esp)
c0104547:	e8 1c d6 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010454c:	fa                   	cli    
    asm volatile ("hlt");
c010454d:	f4                   	hlt    
c010454e:	89 3c 24             	mov    %edi,(%esp)
c0104551:	e8 56 d6 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0104556:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c010455c:	83 c4 10             	add    $0x10,%esp
        insertVma(mm, vma);
c010455f:	52                   	push   %edx
c0104560:	50                   	push   %eax
c0104561:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0104567:	ff 75 08             	pushl  0x8(%ebp)
c010456a:	e8 9d fa ff ff       	call   c010400c <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE>
    for (uint32_t i = step1; i >= 1; i--) {
c010456f:	83 c4 10             	add    $0x10,%esp
c0104572:	83 ad c0 fd ff ff 05 	subl   $0x5,-0x240(%ebp)
c0104579:	0f 85 1d ff ff ff    	jne    c010449c <_ZN3VMM8checkVmaEv+0x152>
c010457f:	c7 85 c0 fd ff ff 37 	movl   $0x37,-0x240(%ebp)
c0104586:	00 00 00 
        auto *vma = vmaCreate(i * 5, i * 5 + 2, 0);
c0104589:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c010458f:	6a 00                	push   $0x0
c0104591:	83 c0 02             	add    $0x2,%eax
c0104594:	50                   	push   %eax
c0104595:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c010459b:	ff 75 08             	pushl  0x8(%ebp)
c010459e:	e8 4d f0 ff ff       	call   c01035f0 <_ZN3VMM9vmaCreateEjjj>
        assert(vma != nullptr);
c01045a3:	83 c4 10             	add    $0x10,%esp
c01045a6:	85 c0                	test   %eax,%eax
c01045a8:	0f 85 9e 00 00 00    	jne    c010464c <_ZN3VMM8checkVmaEv+0x302>
c01045ae:	56                   	push   %esi
c01045af:	56                   	push   %esi
c01045b0:	8d 93 b1 39 fe ff    	lea    -0x1c64f(%ebx),%edx
c01045b6:	52                   	push   %edx
c01045b7:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01045bd:	56                   	push   %esi
c01045be:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c01045c4:	e8 31 17 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01045c9:	8d 93 bb 39 fe ff    	lea    -0x1c645(%ebx),%edx
c01045cf:	5f                   	pop    %edi
c01045d0:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01045d6:	58                   	pop    %eax
c01045d7:	52                   	push   %edx
c01045d8:	8d 95 d6 fd ff ff    	lea    -0x22a(%ebp),%edx
c01045de:	52                   	push   %edx
c01045df:	89 95 b8 fd ff ff    	mov    %edx,-0x248(%ebp)
c01045e5:	e8 10 17 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01045ea:	8b 95 b8 fd ff ff    	mov    -0x248(%ebp),%edx
c01045f0:	83 c4 0c             	add    $0xc,%esp
c01045f3:	56                   	push   %esi
c01045f4:	52                   	push   %edx
c01045f5:	57                   	push   %edi
c01045f6:	e8 d3 d4 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01045fb:	8b 95 b8 fd ff ff    	mov    -0x248(%ebp),%edx
c0104601:	89 14 24             	mov    %edx,(%esp)
c0104604:	e8 0b 17 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104609:	89 34 24             	mov    %esi,(%esp)
c010460c:	e8 03 17 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104611:	58                   	pop    %eax
c0104612:	5a                   	pop    %edx
c0104613:	8d 93 99 3e fe ff    	lea    -0x1c167(%ebx),%edx
c0104619:	52                   	push   %edx
c010461a:	56                   	push   %esi
c010461b:	e8 da 16 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104620:	59                   	pop    %ecx
c0104621:	58                   	pop    %eax
c0104622:	56                   	push   %esi
c0104623:	57                   	push   %edi
c0104624:	e8 f3 d5 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104629:	89 34 24             	mov    %esi,(%esp)
c010462c:	e8 e3 16 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104631:	89 3c 24             	mov    %edi,(%esp)
c0104634:	e8 2f d5 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0104639:	fa                   	cli    
    asm volatile ("hlt");
c010463a:	f4                   	hlt    
c010463b:	89 3c 24             	mov    %edi,(%esp)
c010463e:	e8 69 d5 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0104643:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0104649:	83 c4 10             	add    $0x10,%esp
        insertVma(mm, vma);
c010464c:	51                   	push   %ecx
c010464d:	50                   	push   %eax
c010464e:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0104654:	ff 75 08             	pushl  0x8(%ebp)
c0104657:	e8 b0 f9 ff ff       	call   c010400c <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE>
    for (uint32_t i = step1 + 1; i <= step2; i++) {
c010465c:	83 c4 10             	add    $0x10,%esp
c010465f:	83 85 c0 fd ff ff 05 	addl   $0x5,-0x240(%ebp)
c0104666:	81 bd c0 fd ff ff f9 	cmpl   $0x1f9,-0x240(%ebp)
c010466d:	01 00 00 
c0104670:	0f 85 13 ff ff ff    	jne    c0104589 <_ZN3VMM8checkVmaEv+0x23f>
    it.setCurrentNode(headNode.first);
c0104676:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
    return it;
c010467c:	31 d2                	xor    %edx,%edx
                    currentNode = node;
c010467e:	8b 8d c4 fd ff ff    	mov    -0x23c(%ebp),%ecx
    it.setCurrentNode(headNode.first);
c0104684:	8b 40 04             	mov    0x4(%eax),%eax
                    if (!hasNext()) {
c0104687:	85 c0                	test   %eax,%eax
                    currentNode = node;
c0104689:	89 01                	mov    %eax,(%ecx)
                    if (!hasNext()) {
c010468b:	74 03                	je     c0104690 <_ZN3VMM8checkVmaEv+0x346>
                    currentNode = currentNode->next;
c010468d:	8b 50 14             	mov    0x14(%eax),%edx
    return it;
c0104690:	c7 85 c0 fd ff ff 05 	movl   $0x5,-0x240(%ebp)
c0104697:	00 00 00 
        assert(vmaNode != nullptr);
c010469a:	85 c0                	test   %eax,%eax
c010469c:	0f 85 aa 00 00 00    	jne    c010474c <_ZN3VMM8checkVmaEv+0x402>
c01046a2:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c01046a8:	8d 8b b1 39 fe ff    	lea    -0x1c64f(%ebx),%ecx
c01046ae:	50                   	push   %eax
c01046af:	50                   	push   %eax
c01046b0:	51                   	push   %ecx
c01046b1:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01046b7:	56                   	push   %esi
c01046b8:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01046be:	89 95 b0 fd ff ff    	mov    %edx,-0x250(%ebp)
c01046c4:	e8 31 16 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01046c9:	8d 8b bb 39 fe ff    	lea    -0x1c645(%ebx),%ecx
c01046cf:	58                   	pop    %eax
c01046d0:	5a                   	pop    %edx
c01046d1:	51                   	push   %ecx
c01046d2:	8d 8d d6 fd ff ff    	lea    -0x22a(%ebp),%ecx
c01046d8:	51                   	push   %ecx
c01046d9:	89 8d b8 fd ff ff    	mov    %ecx,-0x248(%ebp)
c01046df:	e8 16 16 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01046e4:	8b 8d b8 fd ff ff    	mov    -0x248(%ebp),%ecx
c01046ea:	83 c4 0c             	add    $0xc,%esp
c01046ed:	56                   	push   %esi
c01046ee:	51                   	push   %ecx
c01046ef:	57                   	push   %edi
c01046f0:	e8 d9 d3 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01046f5:	8b 8d b8 fd ff ff    	mov    -0x248(%ebp),%ecx
c01046fb:	89 0c 24             	mov    %ecx,(%esp)
c01046fe:	e8 11 16 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104703:	89 34 24             	mov    %esi,(%esp)
c0104706:	e8 09 16 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010470b:	59                   	pop    %ecx
c010470c:	8d 8b a8 3e fe ff    	lea    -0x1c158(%ebx),%ecx
c0104712:	58                   	pop    %eax
c0104713:	51                   	push   %ecx
c0104714:	56                   	push   %esi
c0104715:	e8 e0 15 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010471a:	58                   	pop    %eax
c010471b:	5a                   	pop    %edx
c010471c:	56                   	push   %esi
c010471d:	57                   	push   %edi
c010471e:	e8 f9 d4 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104723:	89 34 24             	mov    %esi,(%esp)
c0104726:	e8 e9 15 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010472b:	89 3c 24             	mov    %edi,(%esp)
c010472e:	e8 35 d4 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0104733:	fa                   	cli    
    asm volatile ("hlt");
c0104734:	f4                   	hlt    
c0104735:	89 3c 24             	mov    %edi,(%esp)
c0104738:	e8 6f d4 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c010473d:	8b 95 b0 fd ff ff    	mov    -0x250(%ebp),%edx
c0104743:	83 c4 10             	add    $0x10,%esp
c0104746:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
        assert(vmaNode->data.vm_start == i * 5 && vmaNode->data.vm_end == i * 5 + 2);
c010474c:	8b 8d c0 fd ff ff    	mov    -0x240(%ebp),%ecx
c0104752:	39 48 04             	cmp    %ecx,0x4(%eax)
c0104755:	75 0c                	jne    c0104763 <_ZN3VMM8checkVmaEv+0x419>
c0104757:	83 c1 02             	add    $0x2,%ecx
c010475a:	39 48 08             	cmp    %ecx,0x8(%eax)
c010475d:	0f 84 9e 00 00 00    	je     c0104801 <_ZN3VMM8checkVmaEv+0x4b7>
c0104763:	56                   	push   %esi
c0104764:	56                   	push   %esi
c0104765:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c010476b:	50                   	push   %eax
c010476c:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0104772:	56                   	push   %esi
c0104773:	89 95 b4 fd ff ff    	mov    %edx,-0x24c(%ebp)
c0104779:	e8 7c 15 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010477e:	5f                   	pop    %edi
c010477f:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0104785:	58                   	pop    %eax
c0104786:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c010478c:	50                   	push   %eax
c010478d:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0104793:	50                   	push   %eax
c0104794:	89 85 b8 fd ff ff    	mov    %eax,-0x248(%ebp)
c010479a:	e8 5b 15 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010479f:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
c01047a5:	83 c4 0c             	add    $0xc,%esp
c01047a8:	56                   	push   %esi
c01047a9:	50                   	push   %eax
c01047aa:	57                   	push   %edi
c01047ab:	e8 1e d3 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01047b0:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
c01047b6:	89 04 24             	mov    %eax,(%esp)
c01047b9:	e8 56 15 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01047be:	89 34 24             	mov    %esi,(%esp)
c01047c1:	e8 4e 15 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01047c6:	58                   	pop    %eax
c01047c7:	8d 83 bb 3e fe ff    	lea    -0x1c145(%ebx),%eax
c01047cd:	5a                   	pop    %edx
c01047ce:	50                   	push   %eax
c01047cf:	56                   	push   %esi
c01047d0:	e8 25 15 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01047d5:	59                   	pop    %ecx
c01047d6:	58                   	pop    %eax
c01047d7:	56                   	push   %esi
c01047d8:	57                   	push   %edi
c01047d9:	e8 3e d4 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01047de:	89 34 24             	mov    %esi,(%esp)
c01047e1:	e8 2e 15 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01047e6:	89 3c 24             	mov    %edi,(%esp)
c01047e9:	e8 7a d3 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01047ee:	fa                   	cli    
    asm volatile ("hlt");
c01047ef:	f4                   	hlt    
c01047f0:	89 3c 24             	mov    %edi,(%esp)
c01047f3:	e8 b4 d3 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c01047f8:	8b 95 b4 fd ff ff    	mov    -0x24c(%ebp),%edx
c01047fe:	83 c4 10             	add    $0x10,%esp
                    if (!hasNext()) {
c0104801:	31 c9                	xor    %ecx,%ecx
c0104803:	85 d2                	test   %edx,%edx
c0104805:	74 03                	je     c010480a <_ZN3VMM8checkVmaEv+0x4c0>
                    currentNode = currentNode->next;
c0104807:	8b 4a 14             	mov    0x14(%edx),%ecx
c010480a:	83 85 c0 fd ff ff 05 	addl   $0x5,-0x240(%ebp)
c0104811:	89 d0                	mov    %edx,%eax
    for (uint32_t i = 1; i <= step2; i++) {
c0104813:	81 bd c0 fd ff ff f9 	cmpl   $0x1f9,-0x240(%ebp)
c010481a:	01 00 00 
c010481d:	74 07                	je     c0104826 <_ZN3VMM8checkVmaEv+0x4dc>
c010481f:	89 ca                	mov    %ecx,%edx
c0104821:	e9 74 fe ff ff       	jmp    c010469a <_ZN3VMM8checkVmaEv+0x350>
    for (uint32_t i = 5; i <= 5 * step2; i += 5) {      // 5 ~ 500
c0104826:	c7 85 c0 fd ff ff 05 	movl   $0x5,-0x240(%ebp)
c010482d:	00 00 00 
        auto vma1 = findVma(mm, i);
c0104830:	51                   	push   %ecx
c0104831:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c0104837:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c010483d:	ff 75 08             	pushl  0x8(%ebp)
c0104840:	e8 67 ed ff ff       	call   c01035ac <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma1 != nullptr);
c0104845:	83 c4 10             	add    $0x10,%esp
c0104848:	85 c0                	test   %eax,%eax
        auto vma1 = findVma(mm, i);
c010484a:	89 85 b8 fd ff ff    	mov    %eax,-0x248(%ebp)
        assert(vma1 != nullptr);
c0104850:	0f 85 92 00 00 00    	jne    c01048e8 <_ZN3VMM8checkVmaEv+0x59e>
c0104856:	50                   	push   %eax
c0104857:	50                   	push   %eax
c0104858:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c010485e:	50                   	push   %eax
c010485f:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0104865:	56                   	push   %esi
c0104866:	e8 8f 14 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010486b:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0104871:	58                   	pop    %eax
c0104872:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0104878:	5a                   	pop    %edx
c0104879:	50                   	push   %eax
c010487a:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0104880:	50                   	push   %eax
c0104881:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c0104887:	e8 6e 14 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010488c:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0104892:	83 c4 0c             	add    $0xc,%esp
c0104895:	56                   	push   %esi
c0104896:	50                   	push   %eax
c0104897:	57                   	push   %edi
c0104898:	e8 31 d2 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c010489d:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c01048a3:	89 04 24             	mov    %eax,(%esp)
c01048a6:	e8 69 14 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01048ab:	89 34 24             	mov    %esi,(%esp)
c01048ae:	e8 61 14 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01048b3:	59                   	pop    %ecx
c01048b4:	58                   	pop    %eax
c01048b5:	8d 83 00 3f fe ff    	lea    -0x1c100(%ebx),%eax
c01048bb:	50                   	push   %eax
c01048bc:	56                   	push   %esi
c01048bd:	e8 38 14 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01048c2:	58                   	pop    %eax
c01048c3:	5a                   	pop    %edx
c01048c4:	56                   	push   %esi
c01048c5:	57                   	push   %edi
c01048c6:	e8 51 d3 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01048cb:	89 34 24             	mov    %esi,(%esp)
c01048ce:	e8 41 14 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01048d3:	89 3c 24             	mov    %edi,(%esp)
c01048d6:	e8 8d d2 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01048db:	fa                   	cli    
    asm volatile ("hlt");
c01048dc:	f4                   	hlt    
c01048dd:	89 3c 24             	mov    %edi,(%esp)
c01048e0:	e8 c7 d2 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c01048e5:	83 c4 10             	add    $0x10,%esp
        auto vma2 = findVma(mm, i + 1);
c01048e8:	50                   	push   %eax
c01048e9:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01048ef:	40                   	inc    %eax
c01048f0:	50                   	push   %eax
c01048f1:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c01048f7:	ff 75 08             	pushl  0x8(%ebp)
c01048fa:	e8 ad ec ff ff       	call   c01035ac <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma2 != nullptr);
c01048ff:	83 c4 10             	add    $0x10,%esp
c0104902:	85 c0                	test   %eax,%eax
        auto vma2 = findVma(mm, i + 1);
c0104904:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
        assert(vma2 != nullptr);
c010490a:	0f 85 92 00 00 00    	jne    c01049a2 <_ZN3VMM8checkVmaEv+0x658>
c0104910:	51                   	push   %ecx
c0104911:	51                   	push   %ecx
c0104912:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0104918:	50                   	push   %eax
c0104919:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c010491f:	56                   	push   %esi
c0104920:	e8 d5 13 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104925:	5f                   	pop    %edi
c0104926:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c010492c:	58                   	pop    %eax
c010492d:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0104933:	50                   	push   %eax
c0104934:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c010493a:	50                   	push   %eax
c010493b:	89 85 b0 fd ff ff    	mov    %eax,-0x250(%ebp)
c0104941:	e8 b4 13 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104946:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c010494c:	83 c4 0c             	add    $0xc,%esp
c010494f:	56                   	push   %esi
c0104950:	50                   	push   %eax
c0104951:	57                   	push   %edi
c0104952:	e8 77 d1 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0104957:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c010495d:	89 04 24             	mov    %eax,(%esp)
c0104960:	e8 af 13 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104965:	89 34 24             	mov    %esi,(%esp)
c0104968:	e8 a7 13 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010496d:	58                   	pop    %eax
c010496e:	8d 83 10 3f fe ff    	lea    -0x1c0f0(%ebx),%eax
c0104974:	5a                   	pop    %edx
c0104975:	50                   	push   %eax
c0104976:	56                   	push   %esi
c0104977:	e8 7e 13 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010497c:	59                   	pop    %ecx
c010497d:	58                   	pop    %eax
c010497e:	56                   	push   %esi
c010497f:	57                   	push   %edi
c0104980:	e8 97 d2 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104985:	89 34 24             	mov    %esi,(%esp)
c0104988:	e8 87 13 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010498d:	89 3c 24             	mov    %edi,(%esp)
c0104990:	e8 d3 d1 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0104995:	fa                   	cli    
    asm volatile ("hlt");
c0104996:	f4                   	hlt    
c0104997:	89 3c 24             	mov    %edi,(%esp)
c010499a:	e8 0d d2 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c010499f:	83 c4 10             	add    $0x10,%esp
c01049a2:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
        auto vma3 = findVma(mm, i + 2);
c01049a8:	52                   	push   %edx
c01049a9:	83 c0 02             	add    $0x2,%eax
c01049ac:	50                   	push   %eax
c01049ad:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c01049b3:	89 85 b0 fd ff ff    	mov    %eax,-0x250(%ebp)
c01049b9:	ff 75 08             	pushl  0x8(%ebp)
c01049bc:	e8 eb eb ff ff       	call   c01035ac <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma3 == nullptr);
c01049c1:	83 c4 10             	add    $0x10,%esp
c01049c4:	85 c0                	test   %eax,%eax
c01049c6:	0f 84 92 00 00 00    	je     c0104a5e <_ZN3VMM8checkVmaEv+0x714>
c01049cc:	56                   	push   %esi
c01049cd:	56                   	push   %esi
c01049ce:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c01049d4:	50                   	push   %eax
c01049d5:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01049db:	56                   	push   %esi
c01049dc:	e8 19 13 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01049e1:	5f                   	pop    %edi
c01049e2:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01049e8:	58                   	pop    %eax
c01049e9:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c01049ef:	50                   	push   %eax
c01049f0:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c01049f6:	50                   	push   %eax
c01049f7:	89 85 a8 fd ff ff    	mov    %eax,-0x258(%ebp)
c01049fd:	e8 f8 12 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104a02:	8b 85 a8 fd ff ff    	mov    -0x258(%ebp),%eax
c0104a08:	83 c4 0c             	add    $0xc,%esp
c0104a0b:	56                   	push   %esi
c0104a0c:	50                   	push   %eax
c0104a0d:	57                   	push   %edi
c0104a0e:	e8 bb d0 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0104a13:	8b 85 a8 fd ff ff    	mov    -0x258(%ebp),%eax
c0104a19:	89 04 24             	mov    %eax,(%esp)
c0104a1c:	e8 f3 12 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104a21:	89 34 24             	mov    %esi,(%esp)
c0104a24:	e8 eb 12 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104a29:	58                   	pop    %eax
c0104a2a:	8d 83 20 3f fe ff    	lea    -0x1c0e0(%ebx),%eax
c0104a30:	5a                   	pop    %edx
c0104a31:	50                   	push   %eax
c0104a32:	56                   	push   %esi
c0104a33:	e8 c2 12 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104a38:	59                   	pop    %ecx
c0104a39:	58                   	pop    %eax
c0104a3a:	56                   	push   %esi
c0104a3b:	57                   	push   %edi
c0104a3c:	e8 db d1 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104a41:	89 34 24             	mov    %esi,(%esp)
c0104a44:	e8 cb 12 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104a49:	89 3c 24             	mov    %edi,(%esp)
c0104a4c:	e8 17 d1 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0104a51:	fa                   	cli    
    asm volatile ("hlt");
c0104a52:	f4                   	hlt    
c0104a53:	89 3c 24             	mov    %edi,(%esp)
c0104a56:	e8 51 d1 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0104a5b:	83 c4 10             	add    $0x10,%esp
        auto vma4 = findVma(mm, i + 3);
c0104a5e:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0104a64:	51                   	push   %ecx
c0104a65:	83 c0 03             	add    $0x3,%eax
c0104a68:	50                   	push   %eax
c0104a69:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0104a6f:	ff 75 08             	pushl  0x8(%ebp)
c0104a72:	e8 35 eb ff ff       	call   c01035ac <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma4 == nullptr);
c0104a77:	83 c4 10             	add    $0x10,%esp
c0104a7a:	85 c0                	test   %eax,%eax
c0104a7c:	0f 84 92 00 00 00    	je     c0104b14 <_ZN3VMM8checkVmaEv+0x7ca>
c0104a82:	50                   	push   %eax
c0104a83:	50                   	push   %eax
c0104a84:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0104a8a:	50                   	push   %eax
c0104a8b:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0104a91:	56                   	push   %esi
c0104a92:	e8 63 12 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104a97:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0104a9d:	58                   	pop    %eax
c0104a9e:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0104aa4:	5a                   	pop    %edx
c0104aa5:	50                   	push   %eax
c0104aa6:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0104aac:	50                   	push   %eax
c0104aad:	89 85 a8 fd ff ff    	mov    %eax,-0x258(%ebp)
c0104ab3:	e8 42 12 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104ab8:	8b 85 a8 fd ff ff    	mov    -0x258(%ebp),%eax
c0104abe:	83 c4 0c             	add    $0xc,%esp
c0104ac1:	56                   	push   %esi
c0104ac2:	50                   	push   %eax
c0104ac3:	57                   	push   %edi
c0104ac4:	e8 05 d0 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0104ac9:	8b 85 a8 fd ff ff    	mov    -0x258(%ebp),%eax
c0104acf:	89 04 24             	mov    %eax,(%esp)
c0104ad2:	e8 3d 12 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104ad7:	89 34 24             	mov    %esi,(%esp)
c0104ada:	e8 35 12 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104adf:	59                   	pop    %ecx
c0104ae0:	58                   	pop    %eax
c0104ae1:	8d 83 30 3f fe ff    	lea    -0x1c0d0(%ebx),%eax
c0104ae7:	50                   	push   %eax
c0104ae8:	56                   	push   %esi
c0104ae9:	e8 0c 12 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104aee:	58                   	pop    %eax
c0104aef:	5a                   	pop    %edx
c0104af0:	56                   	push   %esi
c0104af1:	57                   	push   %edi
c0104af2:	e8 25 d1 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104af7:	89 34 24             	mov    %esi,(%esp)
c0104afa:	e8 15 12 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104aff:	89 3c 24             	mov    %edi,(%esp)
c0104b02:	e8 61 d0 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0104b07:	fa                   	cli    
    asm volatile ("hlt");
c0104b08:	f4                   	hlt    
c0104b09:	89 3c 24             	mov    %edi,(%esp)
c0104b0c:	e8 9b d0 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0104b11:	83 c4 10             	add    $0x10,%esp
        auto vma5 = findVma(mm, i + 4);
c0104b14:	50                   	push   %eax
c0104b15:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0104b1b:	83 c0 04             	add    $0x4,%eax
c0104b1e:	50                   	push   %eax
c0104b1f:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0104b25:	ff 75 08             	pushl  0x8(%ebp)
c0104b28:	e8 7f ea ff ff       	call   c01035ac <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma5 == nullptr);
c0104b2d:	83 c4 10             	add    $0x10,%esp
c0104b30:	85 c0                	test   %eax,%eax
c0104b32:	0f 84 92 00 00 00    	je     c0104bca <_ZN3VMM8checkVmaEv+0x880>
c0104b38:	51                   	push   %ecx
c0104b39:	51                   	push   %ecx
c0104b3a:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0104b40:	50                   	push   %eax
c0104b41:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0104b47:	56                   	push   %esi
c0104b48:	e8 ad 11 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104b4d:	5f                   	pop    %edi
c0104b4e:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0104b54:	58                   	pop    %eax
c0104b55:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0104b5b:	50                   	push   %eax
c0104b5c:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0104b62:	50                   	push   %eax
c0104b63:	89 85 a8 fd ff ff    	mov    %eax,-0x258(%ebp)
c0104b69:	e8 8c 11 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104b6e:	8b 85 a8 fd ff ff    	mov    -0x258(%ebp),%eax
c0104b74:	83 c4 0c             	add    $0xc,%esp
c0104b77:	56                   	push   %esi
c0104b78:	50                   	push   %eax
c0104b79:	57                   	push   %edi
c0104b7a:	e8 4f cf ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0104b7f:	8b 85 a8 fd ff ff    	mov    -0x258(%ebp),%eax
c0104b85:	89 04 24             	mov    %eax,(%esp)
c0104b88:	e8 87 11 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104b8d:	89 34 24             	mov    %esi,(%esp)
c0104b90:	e8 7f 11 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104b95:	58                   	pop    %eax
c0104b96:	8d 83 40 3f fe ff    	lea    -0x1c0c0(%ebx),%eax
c0104b9c:	5a                   	pop    %edx
c0104b9d:	50                   	push   %eax
c0104b9e:	56                   	push   %esi
c0104b9f:	e8 56 11 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104ba4:	59                   	pop    %ecx
c0104ba5:	58                   	pop    %eax
c0104ba6:	56                   	push   %esi
c0104ba7:	57                   	push   %edi
c0104ba8:	e8 6f d0 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104bad:	89 34 24             	mov    %esi,(%esp)
c0104bb0:	e8 5f 11 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104bb5:	89 3c 24             	mov    %edi,(%esp)
c0104bb8:	e8 ab cf ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0104bbd:	fa                   	cli    
    asm volatile ("hlt");
c0104bbe:	f4                   	hlt    
c0104bbf:	89 3c 24             	mov    %edi,(%esp)
c0104bc2:	e8 e5 cf ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0104bc7:	83 c4 10             	add    $0x10,%esp
        assert(vma1->data.vm_start == i  && vma1->data.vm_end == i  + 2);
c0104bca:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
c0104bd0:	8b 8d c0 fd ff ff    	mov    -0x240(%ebp),%ecx
c0104bd6:	39 48 04             	cmp    %ecx,0x4(%eax)
c0104bd9:	75 0f                	jne    c0104bea <_ZN3VMM8checkVmaEv+0x8a0>
c0104bdb:	8b 8d b0 fd ff ff    	mov    -0x250(%ebp),%ecx
c0104be1:	39 48 08             	cmp    %ecx,0x8(%eax)
c0104be4:	0f 84 92 00 00 00    	je     c0104c7c <_ZN3VMM8checkVmaEv+0x932>
c0104bea:	50                   	push   %eax
c0104beb:	50                   	push   %eax
c0104bec:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0104bf2:	50                   	push   %eax
c0104bf3:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0104bf9:	56                   	push   %esi
c0104bfa:	e8 fb 10 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104bff:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0104c05:	58                   	pop    %eax
c0104c06:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0104c0c:	5a                   	pop    %edx
c0104c0d:	50                   	push   %eax
c0104c0e:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0104c14:	50                   	push   %eax
c0104c15:	89 85 b8 fd ff ff    	mov    %eax,-0x248(%ebp)
c0104c1b:	e8 da 10 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104c20:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
c0104c26:	83 c4 0c             	add    $0xc,%esp
c0104c29:	56                   	push   %esi
c0104c2a:	50                   	push   %eax
c0104c2b:	57                   	push   %edi
c0104c2c:	e8 9d ce ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0104c31:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
c0104c37:	89 04 24             	mov    %eax,(%esp)
c0104c3a:	e8 d5 10 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104c3f:	89 34 24             	mov    %esi,(%esp)
c0104c42:	e8 cd 10 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104c47:	59                   	pop    %ecx
c0104c48:	58                   	pop    %eax
c0104c49:	8d 83 50 3f fe ff    	lea    -0x1c0b0(%ebx),%eax
c0104c4f:	50                   	push   %eax
c0104c50:	56                   	push   %esi
c0104c51:	e8 a4 10 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104c56:	58                   	pop    %eax
c0104c57:	5a                   	pop    %edx
c0104c58:	56                   	push   %esi
c0104c59:	57                   	push   %edi
c0104c5a:	e8 bd cf ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104c5f:	89 34 24             	mov    %esi,(%esp)
c0104c62:	e8 ad 10 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104c67:	89 3c 24             	mov    %edi,(%esp)
c0104c6a:	e8 f9 ce ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0104c6f:	fa                   	cli    
    asm volatile ("hlt");
c0104c70:	f4                   	hlt    
c0104c71:	89 3c 24             	mov    %edi,(%esp)
c0104c74:	e8 33 cf ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0104c79:	83 c4 10             	add    $0x10,%esp
        assert(vma2->data.vm_start == i  && vma2->data.vm_end == i  + 2);
c0104c7c:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0104c82:	8b 8d c0 fd ff ff    	mov    -0x240(%ebp),%ecx
c0104c88:	39 48 04             	cmp    %ecx,0x4(%eax)
c0104c8b:	75 0f                	jne    c0104c9c <_ZN3VMM8checkVmaEv+0x952>
c0104c8d:	8b 8d b0 fd ff ff    	mov    -0x250(%ebp),%ecx
c0104c93:	39 48 08             	cmp    %ecx,0x8(%eax)
c0104c96:	0f 84 92 00 00 00    	je     c0104d2e <_ZN3VMM8checkVmaEv+0x9e4>
c0104c9c:	56                   	push   %esi
c0104c9d:	56                   	push   %esi
c0104c9e:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0104ca4:	50                   	push   %eax
c0104ca5:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0104cab:	56                   	push   %esi
c0104cac:	e8 49 10 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104cb1:	5f                   	pop    %edi
c0104cb2:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0104cb8:	58                   	pop    %eax
c0104cb9:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0104cbf:	50                   	push   %eax
c0104cc0:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0104cc6:	50                   	push   %eax
c0104cc7:	89 85 b8 fd ff ff    	mov    %eax,-0x248(%ebp)
c0104ccd:	e8 28 10 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104cd2:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
c0104cd8:	83 c4 0c             	add    $0xc,%esp
c0104cdb:	56                   	push   %esi
c0104cdc:	50                   	push   %eax
c0104cdd:	57                   	push   %edi
c0104cde:	e8 eb cd ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0104ce3:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
c0104ce9:	89 04 24             	mov    %eax,(%esp)
c0104cec:	e8 23 10 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104cf1:	89 34 24             	mov    %esi,(%esp)
c0104cf4:	e8 1b 10 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104cf9:	58                   	pop    %eax
c0104cfa:	8d 83 87 3f fe ff    	lea    -0x1c079(%ebx),%eax
c0104d00:	5a                   	pop    %edx
c0104d01:	50                   	push   %eax
c0104d02:	56                   	push   %esi
c0104d03:	e8 f2 0f 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104d08:	59                   	pop    %ecx
c0104d09:	58                   	pop    %eax
c0104d0a:	56                   	push   %esi
c0104d0b:	57                   	push   %edi
c0104d0c:	e8 0b cf ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104d11:	89 34 24             	mov    %esi,(%esp)
c0104d14:	e8 fb 0f 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104d19:	89 3c 24             	mov    %edi,(%esp)
c0104d1c:	e8 47 ce ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0104d21:	fa                   	cli    
    asm volatile ("hlt");
c0104d22:	f4                   	hlt    
c0104d23:	89 3c 24             	mov    %edi,(%esp)
c0104d26:	e8 81 ce ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0104d2b:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 5; i <= 5 * step2; i += 5) {      // 5 ~ 500
c0104d2e:	83 85 c0 fd ff ff 05 	addl   $0x5,-0x240(%ebp)
c0104d35:	81 bd c0 fd ff ff f9 	cmpl   $0x1f9,-0x240(%ebp)
c0104d3c:	01 00 00 
c0104d3f:	0f 85 eb fa ff ff    	jne    c0104830 <_ZN3VMM8checkVmaEv+0x4e6>
    for (int i = 4; i >= 0; i--) {
c0104d45:	c7 85 c0 fd ff ff 04 	movl   $0x4,-0x240(%ebp)
c0104d4c:	00 00 00 
        auto *vma_below_5= findVma(mm,i);
c0104d4f:	51                   	push   %ecx
c0104d50:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c0104d56:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0104d5c:	ff 75 08             	pushl  0x8(%ebp)
c0104d5f:	e8 48 e8 ff ff       	call   c01035ac <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma_below_5 == nullptr);
c0104d64:	83 c4 10             	add    $0x10,%esp
c0104d67:	85 c0                	test   %eax,%eax
c0104d69:	0f 84 92 00 00 00    	je     c0104e01 <_ZN3VMM8checkVmaEv+0xab7>
c0104d6f:	57                   	push   %edi
c0104d70:	57                   	push   %edi
c0104d71:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0104d77:	50                   	push   %eax
c0104d78:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0104d7e:	56                   	push   %esi
c0104d7f:	e8 76 0f 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104d84:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0104d8a:	58                   	pop    %eax
c0104d8b:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0104d91:	5a                   	pop    %edx
c0104d92:	50                   	push   %eax
c0104d93:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0104d99:	50                   	push   %eax
c0104d9a:	89 85 b8 fd ff ff    	mov    %eax,-0x248(%ebp)
c0104da0:	e8 55 0f 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104da5:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
c0104dab:	83 c4 0c             	add    $0xc,%esp
c0104dae:	56                   	push   %esi
c0104daf:	50                   	push   %eax
c0104db0:	57                   	push   %edi
c0104db1:	e8 18 cd ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0104db6:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
c0104dbc:	89 04 24             	mov    %eax,(%esp)
c0104dbf:	e8 50 0f 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104dc4:	89 34 24             	mov    %esi,(%esp)
c0104dc7:	e8 48 0f 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104dcc:	59                   	pop    %ecx
c0104dcd:	58                   	pop    %eax
c0104dce:	8d 83 be 3f fe ff    	lea    -0x1c042(%ebx),%eax
c0104dd4:	50                   	push   %eax
c0104dd5:	56                   	push   %esi
c0104dd6:	e8 1f 0f 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104ddb:	58                   	pop    %eax
c0104ddc:	5a                   	pop    %edx
c0104ddd:	56                   	push   %esi
c0104dde:	57                   	push   %edi
c0104ddf:	e8 38 ce ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104de4:	89 34 24             	mov    %esi,(%esp)
c0104de7:	e8 28 0f 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104dec:	89 3c 24             	mov    %edi,(%esp)
c0104def:	e8 74 cd ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0104df4:	fa                   	cli    
    asm volatile ("hlt");
c0104df5:	f4                   	hlt    
c0104df6:	89 3c 24             	mov    %edi,(%esp)
c0104df9:	e8 ae cd ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0104dfe:	83 c4 10             	add    $0x10,%esp
    for (int i = 4; i >= 0; i--) {
c0104e01:	ff 8d c0 fd ff ff    	decl   -0x240(%ebp)
c0104e07:	83 bd c0 fd ff ff ff 	cmpl   $0xffffffff,-0x240(%ebp)
c0104e0e:	0f 85 3b ff ff ff    	jne    c0104d4f <_ZN3VMM8checkVmaEv+0xa05>
    mmDestroy(mm);
c0104e14:	51                   	push   %ecx
c0104e15:	51                   	push   %ecx
c0104e16:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0104e1c:	ff 75 08             	pushl  0x8(%ebp)
c0104e1f:	e8 0a ea ff ff       	call   c010382e <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE>
    assert(nr_free_pages_store == kernel::pmm.numFreePages());
c0104e24:	5e                   	pop    %esi
c0104e25:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
c0104e2b:	e8 4a df ff ff       	call   c0102d7a <_ZN5PhyMM12numFreePagesEv>
c0104e30:	83 c4 10             	add    $0x10,%esp
c0104e33:	3b 85 ac fd ff ff    	cmp    -0x254(%ebp),%eax
c0104e39:	0f 84 91 00 00 00    	je     c0104ed0 <_ZN3VMM8checkVmaEv+0xb86>
c0104e3f:	50                   	push   %eax
c0104e40:	50                   	push   %eax
c0104e41:	ff b5 bc fd ff ff    	pushl  -0x244(%ebp)
c0104e47:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0104e4d:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0104e53:	56                   	push   %esi
c0104e54:	e8 a1 0e 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104e59:	58                   	pop    %eax
c0104e5a:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0104e60:	5a                   	pop    %edx
c0104e61:	50                   	push   %eax
c0104e62:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0104e68:	50                   	push   %eax
c0104e69:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0104e6f:	e8 86 0e 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104e74:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0104e7a:	83 c4 0c             	add    $0xc,%esp
c0104e7d:	56                   	push   %esi
c0104e7e:	50                   	push   %eax
c0104e7f:	57                   	push   %edi
c0104e80:	e8 49 cc ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0104e85:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0104e8b:	89 04 24             	mov    %eax,(%esp)
c0104e8e:	e8 81 0e 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104e93:	89 34 24             	mov    %esi,(%esp)
c0104e96:	e8 79 0e 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104e9b:	59                   	pop    %ecx
c0104e9c:	58                   	pop    %eax
c0104e9d:	8d 83 d5 3f fe ff    	lea    -0x1c02b(%ebx),%eax
c0104ea3:	50                   	push   %eax
c0104ea4:	56                   	push   %esi
c0104ea5:	e8 50 0e 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104eaa:	58                   	pop    %eax
c0104eab:	5a                   	pop    %edx
c0104eac:	56                   	push   %esi
c0104ead:	57                   	push   %edi
c0104eae:	e8 69 cd ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104eb3:	89 34 24             	mov    %esi,(%esp)
c0104eb6:	e8 59 0e 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104ebb:	89 3c 24             	mov    %edi,(%esp)
c0104ebe:	e8 a5 cc ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0104ec3:	fa                   	cli    
    asm volatile ("hlt");
c0104ec4:	f4                   	hlt    
c0104ec5:	89 3c 24             	mov    %edi,(%esp)
c0104ec8:	e8 df cc ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0104ecd:	83 c4 10             	add    $0x10,%esp
    DEBUGPRINT("CheckVma succeeded!");
c0104ed0:	50                   	push   %eax
c0104ed1:	50                   	push   %eax
c0104ed2:	ff b5 bc fd ff ff    	pushl  -0x244(%ebp)
c0104ed8:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0104ede:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0104ee4:	56                   	push   %esi
c0104ee5:	e8 10 0e 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104eea:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c0104ef0:	5a                   	pop    %edx
c0104ef1:	59                   	pop    %ecx
c0104ef2:	50                   	push   %eax
c0104ef3:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0104ef9:	50                   	push   %eax
c0104efa:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0104f00:	e8 f5 0d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104f05:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0104f0b:	83 c4 0c             	add    $0xc,%esp
c0104f0e:	56                   	push   %esi
c0104f0f:	50                   	push   %eax
c0104f10:	57                   	push   %edi
c0104f11:	e8 b8 cb ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0104f16:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0104f1c:	89 04 24             	mov    %eax,(%esp)
c0104f1f:	e8 f0 0d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104f24:	89 34 24             	mov    %esi,(%esp)
c0104f27:	e8 e8 0d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104f2c:	58                   	pop    %eax
c0104f2d:	8d 83 07 40 fe ff    	lea    -0x1bff9(%ebx),%eax
c0104f33:	5a                   	pop    %edx
c0104f34:	50                   	push   %eax
c0104f35:	56                   	push   %esi
c0104f36:	e8 bf 0d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104f3b:	59                   	pop    %ecx
c0104f3c:	58                   	pop    %eax
c0104f3d:	56                   	push   %esi
c0104f3e:	57                   	push   %edi
c0104f3f:	e8 d8 cc ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104f44:	89 34 24             	mov    %esi,(%esp)
c0104f47:	e8 c8 0d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104f4c:	89 3c 24             	mov    %edi,(%esp)
c0104f4f:	e8 14 cc ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c0104f54:	89 3c 24             	mov    %edi,(%esp)
c0104f57:	e8 50 cc ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
}
c0104f5c:	83 c4 10             	add    $0x10,%esp
c0104f5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0104f62:	5b                   	pop    %ebx
c0104f63:	5e                   	pop    %esi
c0104f64:	5f                   	pop    %edi
c0104f65:	5d                   	pop    %ebp
c0104f66:	c3                   	ret    
c0104f67:	90                   	nop

c0104f68 <_ZN3VMM14checkPageFaultEv>:
void VMM::checkPageFault() {
c0104f68:	55                   	push   %ebp
c0104f69:	89 e5                	mov    %esp,%ebp
c0104f6b:	57                   	push   %edi
c0104f6c:	56                   	push   %esi
c0104f6d:	53                   	push   %ebx
c0104f6e:	e8 5a bc ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0104f73:	81 c3 ad d4 01 00    	add    $0x1d4ad,%ebx
c0104f79:	81 ec 54 02 00 00    	sub    $0x254,%esp
    DEBUGPRINT("VMM::checkPageFault");
c0104f7f:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0104f85:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0104f8b:	8d 93 b1 39 fe ff    	lea    -0x1c64f(%ebx),%edx
c0104f91:	52                   	push   %edx
c0104f92:	56                   	push   %esi
c0104f93:	89 95 c0 fd ff ff    	mov    %edx,-0x240(%ebp)
c0104f99:	e8 5c 0d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104f9e:	58                   	pop    %eax
c0104f9f:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c0104fa5:	5a                   	pop    %edx
c0104fa6:	50                   	push   %eax
c0104fa7:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0104fad:	50                   	push   %eax
c0104fae:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0104fb4:	e8 41 0d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104fb9:	83 c4 0c             	add    $0xc,%esp
c0104fbc:	56                   	push   %esi
c0104fbd:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0104fc3:	57                   	push   %edi
c0104fc4:	e8 05 cb ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0104fc9:	59                   	pop    %ecx
c0104fca:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0104fd0:	e8 3f 0d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104fd5:	89 34 24             	mov    %esi,(%esp)
c0104fd8:	e8 37 0d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104fdd:	58                   	pop    %eax
c0104fde:	8d 83 1b 40 fe ff    	lea    -0x1bfe5(%ebx),%eax
c0104fe4:	5a                   	pop    %edx
c0104fe5:	50                   	push   %eax
c0104fe6:	56                   	push   %esi
c0104fe7:	e8 0e 0d 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0104fec:	59                   	pop    %ecx
c0104fed:	58                   	pop    %eax
c0104fee:	56                   	push   %esi
c0104fef:	57                   	push   %edi
c0104ff0:	e8 27 cc ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0104ff5:	89 34 24             	mov    %esi,(%esp)
c0104ff8:	e8 17 0d 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0104ffd:	89 3c 24             	mov    %edi,(%esp)
c0105000:	e8 63 cb ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c0105005:	89 3c 24             	mov    %edi,(%esp)
c0105008:	e8 9f cb ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
    uint32_t nr_free_pages_store = kernel::pmm.numFreePages();
c010500d:	58                   	pop    %eax
c010500e:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
c0105014:	e8 61 dd ff ff       	call   c0102d7a <_ZN5PhyMM12numFreePagesEv>
c0105019:	89 85 b8 fd ff ff    	mov    %eax,-0x248(%ebp)
    checkMM = mmCreate();
c010501f:	58                   	pop    %eax
c0105020:	ff 75 08             	pushl  0x8(%ebp)
c0105023:	e8 22 e7 ff ff       	call   c010374a <_ZN3VMM8mmCreateEv>
c0105028:	8b 4d 08             	mov    0x8(%ebp),%ecx
    assert(checkMM != nullptr);
c010502b:	83 c4 10             	add    $0x10,%esp
c010502e:	8b 95 c0 fd ff ff    	mov    -0x240(%ebp),%edx
c0105034:	85 c0                	test   %eax,%eax
    checkMM = mmCreate();
c0105036:	89 01                	mov    %eax,(%ecx)
    assert(checkMM != nullptr);
c0105038:	75 76                	jne    c01050b0 <_ZN3VMM14checkPageFaultEv+0x148>
c010503a:	51                   	push   %ecx
c010503b:	51                   	push   %ecx
c010503c:	52                   	push   %edx
c010503d:	56                   	push   %esi
c010503e:	e8 b7 0c 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105043:	58                   	pop    %eax
c0105044:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c010504a:	5a                   	pop    %edx
c010504b:	50                   	push   %eax
c010504c:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0105052:	e8 a3 0c 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105057:	83 c4 0c             	add    $0xc,%esp
c010505a:	56                   	push   %esi
c010505b:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0105061:	57                   	push   %edi
c0105062:	e8 67 ca ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0105067:	59                   	pop    %ecx
c0105068:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c010506e:	e8 a1 0c 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105073:	89 34 24             	mov    %esi,(%esp)
c0105076:	e8 99 0c 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010507b:	58                   	pop    %eax
c010507c:	8d 83 2f 40 fe ff    	lea    -0x1bfd1(%ebx),%eax
c0105082:	5a                   	pop    %edx
c0105083:	50                   	push   %eax
c0105084:	56                   	push   %esi
c0105085:	e8 70 0c 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010508a:	59                   	pop    %ecx
c010508b:	58                   	pop    %eax
c010508c:	56                   	push   %esi
c010508d:	57                   	push   %edi
c010508e:	e8 89 cb ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0105093:	89 34 24             	mov    %esi,(%esp)
c0105096:	e8 79 0c 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010509b:	89 3c 24             	mov    %edi,(%esp)
c010509e:	e8 c5 ca ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01050a3:	fa                   	cli    
    asm volatile ("hlt");
c01050a4:	f4                   	hlt    
c01050a5:	89 3c 24             	mov    %edi,(%esp)
c01050a8:	e8 ff ca ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c01050ad:	83 c4 10             	add    $0x10,%esp
    auto mm = checkMM;
c01050b0:	8b 45 08             	mov    0x8(%ebp),%eax
    auto pdt = mm->data.pdt = kernel::pmm.getPDT();
c01050b3:	83 ec 0c             	sub    $0xc,%esp
    auto mm = checkMM;
c01050b6:	8b 00                	mov    (%eax),%eax
    auto pdt = mm->data.pdt = kernel::pmm.getPDT();
c01050b8:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
    auto mm = checkMM;
c01050be:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
    auto pdt = mm->data.pdt = kernel::pmm.getPDT();
c01050c4:	e8 89 d8 ff ff       	call   c0102952 <_ZN5PhyMM6getPDTEv>
    assert(pdt[0].isEmpty());
c01050c9:	83 c4 10             	add    $0x10,%esp
    auto pdt = mm->data.pdt = kernel::pmm.getPDT();
c01050cc:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c01050d2:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c01050d8:	8b 8d c0 fd ff ff    	mov    -0x240(%ebp),%ecx
    assert(pdt[0].isEmpty());
c01050de:	83 39 00             	cmpl   $0x0,(%ecx)
    auto pdt = mm->data.pdt = kernel::pmm.getPDT();
c01050e1:	89 48 14             	mov    %ecx,0x14(%eax)
    assert(pdt[0].isEmpty());
c01050e4:	0f 84 92 00 00 00    	je     c010517c <_ZN3VMM14checkPageFaultEv+0x214>
c01050ea:	50                   	push   %eax
c01050eb:	50                   	push   %eax
c01050ec:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c01050f2:	50                   	push   %eax
c01050f3:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01050f9:	56                   	push   %esi
c01050fa:	e8 fb 0b 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01050ff:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0105105:	58                   	pop    %eax
c0105106:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c010510c:	5a                   	pop    %edx
c010510d:	50                   	push   %eax
c010510e:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0105114:	50                   	push   %eax
c0105115:	89 85 bc fd ff ff    	mov    %eax,-0x244(%ebp)
c010511b:	e8 da 0b 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105120:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
c0105126:	83 c4 0c             	add    $0xc,%esp
c0105129:	56                   	push   %esi
c010512a:	50                   	push   %eax
c010512b:	57                   	push   %edi
c010512c:	e8 9d c9 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0105131:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
c0105137:	89 04 24             	mov    %eax,(%esp)
c010513a:	e8 d5 0b 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010513f:	89 34 24             	mov    %esi,(%esp)
c0105142:	e8 cd 0b 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105147:	59                   	pop    %ecx
c0105148:	58                   	pop    %eax
c0105149:	8d 83 42 40 fe ff    	lea    -0x1bfbe(%ebx),%eax
c010514f:	50                   	push   %eax
c0105150:	56                   	push   %esi
c0105151:	e8 a4 0b 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105156:	58                   	pop    %eax
c0105157:	5a                   	pop    %edx
c0105158:	56                   	push   %esi
c0105159:	57                   	push   %edi
c010515a:	e8 bd ca ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c010515f:	89 34 24             	mov    %esi,(%esp)
c0105162:	e8 ad 0b 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105167:	89 3c 24             	mov    %edi,(%esp)
c010516a:	e8 f9 c9 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010516f:	fa                   	cli    
    asm volatile ("hlt");
c0105170:	f4                   	hlt    
c0105171:	89 3c 24             	mov    %edi,(%esp)
c0105174:	e8 33 ca ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0105179:	83 c4 10             	add    $0x10,%esp
    auto vma = vmaCreate(0, PTSIZE, VM_WRITE);
c010517c:	6a 02                	push   $0x2
c010517e:	68 00 00 40 00       	push   $0x400000
c0105183:	6a 00                	push   $0x0
c0105185:	ff 75 08             	pushl  0x8(%ebp)
c0105188:	e8 63 e4 ff ff       	call   c01035f0 <_ZN3VMM9vmaCreateEjjj>
    assert(vma != nullptr);
c010518d:	83 c4 10             	add    $0x10,%esp
c0105190:	85 c0                	test   %eax,%eax
    auto vma = vmaCreate(0, PTSIZE, VM_WRITE);
c0105192:	89 85 bc fd ff ff    	mov    %eax,-0x244(%ebp)
    assert(vma != nullptr);
c0105198:	0f 85 92 00 00 00    	jne    c0105230 <_ZN3VMM14checkPageFaultEv+0x2c8>
c010519e:	56                   	push   %esi
c010519f:	56                   	push   %esi
c01051a0:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c01051a6:	50                   	push   %eax
c01051a7:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01051ad:	56                   	push   %esi
c01051ae:	e8 47 0b 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01051b3:	5f                   	pop    %edi
c01051b4:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01051ba:	58                   	pop    %eax
c01051bb:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c01051c1:	50                   	push   %eax
c01051c2:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c01051c8:	50                   	push   %eax
c01051c9:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c01051cf:	e8 26 0b 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01051d4:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c01051da:	83 c4 0c             	add    $0xc,%esp
c01051dd:	56                   	push   %esi
c01051de:	50                   	push   %eax
c01051df:	57                   	push   %edi
c01051e0:	e8 e9 c8 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01051e5:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c01051eb:	89 04 24             	mov    %eax,(%esp)
c01051ee:	e8 21 0b 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01051f3:	89 34 24             	mov    %esi,(%esp)
c01051f6:	e8 19 0b 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01051fb:	58                   	pop    %eax
c01051fc:	8d 83 99 3e fe ff    	lea    -0x1c167(%ebx),%eax
c0105202:	5a                   	pop    %edx
c0105203:	50                   	push   %eax
c0105204:	56                   	push   %esi
c0105205:	e8 f0 0a 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010520a:	59                   	pop    %ecx
c010520b:	58                   	pop    %eax
c010520c:	56                   	push   %esi
c010520d:	57                   	push   %edi
c010520e:	e8 09 ca ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0105213:	89 34 24             	mov    %esi,(%esp)
c0105216:	e8 f9 0a 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010521b:	89 3c 24             	mov    %edi,(%esp)
c010521e:	e8 45 c9 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0105223:	fa                   	cli    
    asm volatile ("hlt");
c0105224:	f4                   	hlt    
c0105225:	89 3c 24             	mov    %edi,(%esp)
c0105228:	e8 7f c9 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c010522d:	83 c4 10             	add    $0x10,%esp
    insertVma(mm, vma);
c0105230:	51                   	push   %ecx
c0105231:	ff b5 bc fd ff ff    	pushl  -0x244(%ebp)
c0105237:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c010523d:	ff 75 08             	pushl  0x8(%ebp)
c0105240:	e8 c7 ed ff ff       	call   c010400c <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE>
    assert(findVma(mm, addr) == vma);
c0105245:	83 c4 0c             	add    $0xc,%esp
c0105248:	68 00 01 00 00       	push   $0x100
c010524d:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0105253:	ff 75 08             	pushl  0x8(%ebp)
c0105256:	e8 51 e3 ff ff       	call   c01035ac <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
c010525b:	83 c4 10             	add    $0x10,%esp
c010525e:	3b 85 bc fd ff ff    	cmp    -0x244(%ebp),%eax
c0105264:	0f 84 92 00 00 00    	je     c01052fc <_ZN3VMM14checkPageFaultEv+0x394>
c010526a:	50                   	push   %eax
c010526b:	50                   	push   %eax
c010526c:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0105272:	50                   	push   %eax
c0105273:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0105279:	56                   	push   %esi
c010527a:	e8 7b 0a 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010527f:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0105285:	58                   	pop    %eax
c0105286:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c010528c:	5a                   	pop    %edx
c010528d:	50                   	push   %eax
c010528e:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0105294:	50                   	push   %eax
c0105295:	89 85 bc fd ff ff    	mov    %eax,-0x244(%ebp)
c010529b:	e8 5a 0a 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01052a0:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
c01052a6:	83 c4 0c             	add    $0xc,%esp
c01052a9:	56                   	push   %esi
c01052aa:	50                   	push   %eax
c01052ab:	57                   	push   %edi
c01052ac:	e8 1d c8 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01052b1:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
c01052b7:	89 04 24             	mov    %eax,(%esp)
c01052ba:	e8 55 0a 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01052bf:	89 34 24             	mov    %esi,(%esp)
c01052c2:	e8 4d 0a 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01052c7:	59                   	pop    %ecx
c01052c8:	58                   	pop    %eax
c01052c9:	8d 83 53 40 fe ff    	lea    -0x1bfad(%ebx),%eax
c01052cf:	50                   	push   %eax
c01052d0:	56                   	push   %esi
c01052d1:	e8 24 0a 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01052d6:	58                   	pop    %eax
c01052d7:	5a                   	pop    %edx
c01052d8:	56                   	push   %esi
c01052d9:	57                   	push   %edi
c01052da:	e8 3d c9 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01052df:	89 34 24             	mov    %esi,(%esp)
c01052e2:	e8 2d 0a 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01052e7:	89 3c 24             	mov    %edi,(%esp)
c01052ea:	e8 79 c8 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01052ef:	fa                   	cli    
    asm volatile ("hlt");
c01052f0:	f4                   	hlt    
c01052f1:	89 3c 24             	mov    %edi,(%esp)
c01052f4:	e8 b3 c8 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c01052f9:	83 c4 10             	add    $0x10,%esp
void VMM::checkPageFault() {
c01052fc:	b8 00 01 00 00       	mov    $0x100,%eax
c0105301:	31 d2                	xor    %edx,%edx
        *(char *)(addr + i) = i;
c0105303:	88 10                	mov    %dl,(%eax)
c0105305:	40                   	inc    %eax
c0105306:	fe c2                	inc    %dl
    for (i = 0; i < 100; i ++) {
c0105308:	3d 64 01 00 00       	cmp    $0x164,%eax
c010530d:	75 f4                	jne    c0105303 <_ZN3VMM14checkPageFaultEv+0x39b>
c010530f:	b8 00 01 00 00       	mov    $0x100,%eax
        sum += i;
c0105314:	ba 56 13 00 00       	mov    $0x1356,%edx
        sum -= *(char *)(addr + i);
c0105319:	0f be 08             	movsbl (%eax),%ecx
c010531c:	40                   	inc    %eax
c010531d:	29 ca                	sub    %ecx,%edx
    for (i = 0; i < 100; i ++) {
c010531f:	3d 64 01 00 00       	cmp    $0x164,%eax
c0105324:	75 f3                	jne    c0105319 <_ZN3VMM14checkPageFaultEv+0x3b1>
    assert(sum == 0);
c0105326:	85 d2                	test   %edx,%edx
c0105328:	0f 84 92 00 00 00    	je     c01053c0 <_ZN3VMM14checkPageFaultEv+0x458>
c010532e:	56                   	push   %esi
c010532f:	56                   	push   %esi
c0105330:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0105336:	50                   	push   %eax
c0105337:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c010533d:	56                   	push   %esi
c010533e:	e8 b7 09 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105343:	5f                   	pop    %edi
c0105344:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c010534a:	58                   	pop    %eax
c010534b:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c0105351:	50                   	push   %eax
c0105352:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0105358:	50                   	push   %eax
c0105359:	89 85 bc fd ff ff    	mov    %eax,-0x244(%ebp)
c010535f:	e8 96 09 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105364:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
c010536a:	83 c4 0c             	add    $0xc,%esp
c010536d:	56                   	push   %esi
c010536e:	50                   	push   %eax
c010536f:	57                   	push   %edi
c0105370:	e8 59 c7 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0105375:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
c010537b:	89 04 24             	mov    %eax,(%esp)
c010537e:	e8 91 09 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105383:	89 34 24             	mov    %esi,(%esp)
c0105386:	e8 89 09 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010538b:	58                   	pop    %eax
c010538c:	8d 83 6c 40 fe ff    	lea    -0x1bf94(%ebx),%eax
c0105392:	5a                   	pop    %edx
c0105393:	50                   	push   %eax
c0105394:	56                   	push   %esi
c0105395:	e8 60 09 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010539a:	59                   	pop    %ecx
c010539b:	58                   	pop    %eax
c010539c:	56                   	push   %esi
c010539d:	57                   	push   %edi
c010539e:	e8 79 c8 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01053a3:	89 34 24             	mov    %esi,(%esp)
c01053a6:	e8 69 09 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01053ab:	89 3c 24             	mov    %edi,(%esp)
c01053ae:	e8 b5 c7 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01053b3:	fa                   	cli    
    asm volatile ("hlt");
c01053b4:	f4                   	hlt    
c01053b5:	89 3c 24             	mov    %edi,(%esp)
c01053b8:	e8 ef c7 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c01053bd:	83 c4 10             	add    $0x10,%esp
    kernel::pmm.removePage(pdt, MMU::LinearAD::LAD(Utils::roundDown(addr, PGSIZE)));
c01053c0:	51                   	push   %ecx
c01053c1:	c7 c6 20 50 12 c0    	mov    $0xc0125020,%esi
c01053c7:	6a 00                	push   $0x0
c01053c9:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c01053cf:	56                   	push   %esi
c01053d0:	e8 0f db ff ff       	call   c0102ee4 <_ZN5PhyMM10removePageEPN3MMU7PTEntryENS0_8LinearADE>
    kernel::pmm.freePages(kernel::pmm.pdeToPgNode(pdt[0]));    //pdt[0] = 0;
c01053d5:	5f                   	pop    %edi
c01053d6:	58                   	pop    %eax
c01053d7:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c01053dd:	56                   	push   %esi
c01053de:	e8 59 d1 ff ff       	call   c010253c <_ZN5PhyMM11pdeToPgNodeERKN3MMU7PTEntryE>
c01053e3:	83 c4 0c             	add    $0xc,%esp
c01053e6:	6a 01                	push   $0x1
c01053e8:	50                   	push   %eax
c01053e9:	56                   	push   %esi
c01053ea:	e8 c3 d5 ff ff       	call   c01029b2 <_ZN5PhyMM9freePagesEPN4ListIN3MMU4PageEE6DLNodeEj>
    mm->data.pdt = nullptr;
c01053ef:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c01053f5:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    mmDestroy(mm);
c01053fc:	5a                   	pop    %edx
c01053fd:	59                   	pop    %ecx
c01053fe:	50                   	push   %eax
c01053ff:	ff 75 08             	pushl  0x8(%ebp)
c0105402:	e8 27 e4 ff ff       	call   c010382e <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE>
    checkMM = nullptr;
c0105407:	8b 45 08             	mov    0x8(%ebp),%eax
c010540a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    assert(nr_free_pages_store == kernel::pmm.numFreePages());
c0105410:	89 34 24             	mov    %esi,(%esp)
c0105413:	e8 62 d9 ff ff       	call   c0102d7a <_ZN5PhyMM12numFreePagesEv>
c0105418:	83 c4 10             	add    $0x10,%esp
c010541b:	8d 93 b1 39 fe ff    	lea    -0x1c64f(%ebx),%edx
c0105421:	3b 85 b8 fd ff ff    	cmp    -0x248(%ebp),%eax
c0105427:	0f 84 98 00 00 00    	je     c01054c5 <_ZN3VMM14checkPageFaultEv+0x55d>
c010542d:	50                   	push   %eax
c010542e:	50                   	push   %eax
c010542f:	52                   	push   %edx
c0105430:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0105436:	56                   	push   %esi
c0105437:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c010543d:	89 95 c0 fd ff ff    	mov    %edx,-0x240(%ebp)
c0105443:	e8 b2 08 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105448:	58                   	pop    %eax
c0105449:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c010544f:	5a                   	pop    %edx
c0105450:	50                   	push   %eax
c0105451:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0105457:	50                   	push   %eax
c0105458:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c010545e:	e8 97 08 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105463:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0105469:	83 c4 0c             	add    $0xc,%esp
c010546c:	56                   	push   %esi
c010546d:	50                   	push   %eax
c010546e:	57                   	push   %edi
c010546f:	e8 5a c6 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0105474:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c010547a:	89 04 24             	mov    %eax,(%esp)
c010547d:	e8 92 08 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105482:	89 34 24             	mov    %esi,(%esp)
c0105485:	e8 8a 08 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010548a:	59                   	pop    %ecx
c010548b:	58                   	pop    %eax
c010548c:	8d 83 d5 3f fe ff    	lea    -0x1c02b(%ebx),%eax
c0105492:	50                   	push   %eax
c0105493:	56                   	push   %esi
c0105494:	e8 61 08 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105499:	58                   	pop    %eax
c010549a:	5a                   	pop    %edx
c010549b:	56                   	push   %esi
c010549c:	57                   	push   %edi
c010549d:	e8 7a c7 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01054a2:	89 34 24             	mov    %esi,(%esp)
c01054a5:	e8 6a 08 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01054aa:	89 3c 24             	mov    %edi,(%esp)
c01054ad:	e8 b6 c6 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01054b2:	fa                   	cli    
    asm volatile ("hlt");
c01054b3:	f4                   	hlt    
c01054b4:	89 3c 24             	mov    %edi,(%esp)
c01054b7:	e8 f0 c6 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c01054bc:	8b 95 c0 fd ff ff    	mov    -0x240(%ebp),%edx
c01054c2:	83 c4 10             	add    $0x10,%esp
    DEBUGPRINT("check_pgfault() succeeded!");
c01054c5:	50                   	push   %eax
c01054c6:	50                   	push   %eax
c01054c7:	52                   	push   %edx
c01054c8:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01054ce:	56                   	push   %esi
c01054cf:	e8 26 08 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01054d4:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c01054da:	5a                   	pop    %edx
c01054db:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01054e1:	59                   	pop    %ecx
c01054e2:	50                   	push   %eax
c01054e3:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c01054e9:	50                   	push   %eax
c01054ea:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c01054f0:	e8 05 08 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01054f5:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c01054fb:	83 c4 0c             	add    $0xc,%esp
c01054fe:	56                   	push   %esi
c01054ff:	50                   	push   %eax
c0105500:	57                   	push   %edi
c0105501:	e8 c8 c5 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0105506:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c010550c:	89 04 24             	mov    %eax,(%esp)
c010550f:	e8 00 08 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105514:	89 34 24             	mov    %esi,(%esp)
c0105517:	e8 f8 07 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010551c:	58                   	pop    %eax
c010551d:	8d 83 75 40 fe ff    	lea    -0x1bf8b(%ebx),%eax
c0105523:	5a                   	pop    %edx
c0105524:	50                   	push   %eax
c0105525:	56                   	push   %esi
c0105526:	e8 cf 07 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010552b:	59                   	pop    %ecx
c010552c:	58                   	pop    %eax
c010552d:	56                   	push   %esi
c010552e:	57                   	push   %edi
c010552f:	e8 e8 c6 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0105534:	89 34 24             	mov    %esi,(%esp)
c0105537:	e8 d8 07 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010553c:	89 3c 24             	mov    %edi,(%esp)
c010553f:	e8 24 c6 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c0105544:	89 3c 24             	mov    %edi,(%esp)
c0105547:	e8 60 c6 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
}
c010554c:	83 c4 10             	add    $0x10,%esp
c010554f:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0105552:	5b                   	pop    %ebx
c0105553:	5e                   	pop    %esi
c0105554:	5f                   	pop    %edi
c0105555:	5d                   	pop    %ebp
c0105556:	c3                   	ret    
c0105557:	90                   	nop

c0105558 <_ZN3VMM8checkVmmEv>:
void VMM::checkVmm() {
c0105558:	55                   	push   %ebp
c0105559:	89 e5                	mov    %esp,%ebp
c010555b:	57                   	push   %edi
c010555c:	56                   	push   %esi
c010555d:	53                   	push   %ebx
c010555e:	e8 6a b6 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0105563:	81 c3 bd ce 01 00    	add    $0x1cebd,%ebx
c0105569:	81 ec 44 04 00 00    	sub    $0x444,%esp
    DEBUGPRINT("VMM::checkVmm");
c010556f:	8d 85 d8 fb ff ff    	lea    -0x428(%ebp),%eax
c0105575:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c010557b:	8d b5 d3 fb ff ff    	lea    -0x42d(%ebp),%esi
c0105581:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0105587:	8d 93 b1 39 fe ff    	lea    -0x1c64f(%ebx),%edx
c010558d:	52                   	push   %edx
c010558e:	50                   	push   %eax
c010558f:	89 95 bc fb ff ff    	mov    %edx,-0x444(%ebp)
c0105595:	e8 60 07 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010559a:	58                   	pop    %eax
c010559b:	8d 83 29 3b fe ff    	lea    -0x1c4d7(%ebx),%eax
c01055a1:	5a                   	pop    %edx
c01055a2:	50                   	push   %eax
c01055a3:	56                   	push   %esi
c01055a4:	e8 51 07 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01055a9:	83 c4 0c             	add    $0xc,%esp
c01055ac:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c01055b2:	56                   	push   %esi
c01055b3:	57                   	push   %edi
c01055b4:	e8 15 c5 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01055b9:	89 34 24             	mov    %esi,(%esp)
c01055bc:	e8 53 07 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01055c1:	59                   	pop    %ecx
c01055c2:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c01055c8:	e8 47 07 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01055cd:	58                   	pop    %eax
c01055ce:	8d 83 90 40 fe ff    	lea    -0x1bf70(%ebx),%eax
c01055d4:	5a                   	pop    %edx
c01055d5:	50                   	push   %eax
c01055d6:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c01055dc:	e8 19 07 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01055e1:	59                   	pop    %ecx
c01055e2:	58                   	pop    %eax
c01055e3:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c01055e9:	57                   	push   %edi
c01055ea:	e8 2d c6 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c01055ef:	58                   	pop    %eax
c01055f0:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c01055f6:	e8 19 07 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01055fb:	89 3c 24             	mov    %edi,(%esp)
c01055fe:	e8 65 c5 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
c0105603:	89 3c 24             	mov    %edi,(%esp)
c0105606:	e8 a1 c5 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
    uint32_t nr_free_pages_store = kernel::pmm.numFreePages();
c010560b:	c7 c1 20 50 12 c0    	mov    $0xc0125020,%ecx
c0105611:	89 0c 24             	mov    %ecx,(%esp)
c0105614:	89 8d c0 fb ff ff    	mov    %ecx,-0x440(%ebp)
c010561a:	e8 5b d7 ff ff       	call   c0102d7a <_ZN5PhyMM12numFreePagesEv>
c010561f:	89 85 c8 fb ff ff    	mov    %eax,-0x438(%ebp)
    OStream out("\ncheckVMM : ", "blue");
c0105625:	58                   	pop    %eax
c0105626:	8d 83 96 39 fe ff    	lea    -0x1c66a(%ebx),%eax
c010562c:	5a                   	pop    %edx
c010562d:	50                   	push   %eax
c010562e:	57                   	push   %edi
c010562f:	e8 c6 06 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105634:	59                   	pop    %ecx
c0105635:	58                   	pop    %eax
c0105636:	8d 83 9e 40 fe ff    	lea    -0x1bf62(%ebx),%eax
c010563c:	50                   	push   %eax
c010563d:	56                   	push   %esi
c010563e:	e8 b7 06 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105643:	83 c4 0c             	add    $0xc,%esp
c0105646:	57                   	push   %edi
c0105647:	56                   	push   %esi
c0105648:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c010564e:	e8 7b c4 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0105653:	89 34 24             	mov    %esi,(%esp)
c0105656:	e8 b9 06 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c010565b:	89 3c 24             	mov    %edi,(%esp)
c010565e:	e8 b1 06 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue(nr_free_pages_store);
c0105663:	58                   	pop    %eax
c0105664:	8d 85 c8 fb ff ff    	lea    -0x438(%ebp),%eax
c010566a:	5a                   	pop    %edx
c010566b:	50                   	push   %eax
c010566c:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c0105672:	e8 e9 c5 ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    out.flush();
c0105677:	59                   	pop    %ecx
c0105678:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c010567e:	e8 e5 c4 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    checkVma();
c0105683:	58                   	pop    %eax
c0105684:	ff 75 08             	pushl  0x8(%ebp)
c0105687:	e8 be ec ff ff       	call   c010434a <_ZN3VMM8checkVmaEv>
    checkPageFault();
c010568c:	58                   	pop    %eax
c010568d:	ff 75 08             	pushl  0x8(%ebp)
c0105690:	e8 d3 f8 ff ff       	call   c0104f68 <_ZN3VMM14checkPageFaultEv>
    assert(nr_free_pages_store == kernel::pmm.numFreePages());
c0105695:	8b 8d c0 fb ff ff    	mov    -0x440(%ebp),%ecx
c010569b:	89 0c 24             	mov    %ecx,(%esp)
c010569e:	e8 d7 d6 ff ff       	call   c0102d7a <_ZN5PhyMM12numFreePagesEv>
c01056a3:	83 c4 10             	add    $0x10,%esp
c01056a6:	3b 85 c8 fb ff ff    	cmp    -0x438(%ebp),%eax
c01056ac:	0f 84 86 00 00 00    	je     c0105738 <_ZN3VMM8checkVmmEv+0x1e0>
c01056b2:	8b 95 bc fb ff ff    	mov    -0x444(%ebp),%edx
c01056b8:	50                   	push   %eax
c01056b9:	50                   	push   %eax
c01056ba:	52                   	push   %edx
c01056bb:	56                   	push   %esi
c01056bc:	e8 39 06 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01056c1:	8d 83 bb 39 fe ff    	lea    -0x1c645(%ebx),%eax
c01056c7:	5a                   	pop    %edx
c01056c8:	59                   	pop    %ecx
c01056c9:	50                   	push   %eax
c01056ca:	8d 85 ce fb ff ff    	lea    -0x432(%ebp),%eax
c01056d0:	50                   	push   %eax
c01056d1:	89 85 c0 fb ff ff    	mov    %eax,-0x440(%ebp)
c01056d7:	e8 1e 06 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01056dc:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c01056e2:	83 c4 0c             	add    $0xc,%esp
c01056e5:	56                   	push   %esi
c01056e6:	50                   	push   %eax
c01056e7:	57                   	push   %edi
c01056e8:	e8 e1 c3 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c01056ed:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c01056f3:	89 04 24             	mov    %eax,(%esp)
c01056f6:	e8 19 06 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c01056fb:	89 34 24             	mov    %esi,(%esp)
c01056fe:	e8 11 06 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105703:	58                   	pop    %eax
c0105704:	8d 83 d5 3f fe ff    	lea    -0x1c02b(%ebx),%eax
c010570a:	5a                   	pop    %edx
c010570b:	50                   	push   %eax
c010570c:	56                   	push   %esi
c010570d:	e8 e8 05 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105712:	59                   	pop    %ecx
c0105713:	58                   	pop    %eax
c0105714:	56                   	push   %esi
c0105715:	57                   	push   %edi
c0105716:	e8 01 c5 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c010571b:	89 34 24             	mov    %esi,(%esp)
c010571e:	e8 f1 05 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105723:	89 3c 24             	mov    %edi,(%esp)
c0105726:	e8 3d c4 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010572b:	fa                   	cli    
    asm volatile ("hlt");
c010572c:	f4                   	hlt    
c010572d:	89 3c 24             	mov    %edi,(%esp)
c0105730:	e8 77 c4 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0105735:	83 c4 10             	add    $0x10,%esp
    OStream out("\ncheckVMM : ", "blue");
c0105738:	83 ec 0c             	sub    $0xc,%esp
c010573b:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c0105741:	e8 66 c4 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
}
c0105746:	83 c4 10             	add    $0x10,%esp
c0105749:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010574c:	5b                   	pop    %ebx
c010574d:	5e                   	pop    %esi
c010574e:	5f                   	pop    %edi
c010574f:	5d                   	pop    %ebp
c0105750:	c3                   	ret    
c0105751:	90                   	nop

c0105752 <_ZN3VMM4initEv>:
c0105752:	55                   	push   %ebp
c0105753:	89 e5                	mov    %esp,%ebp
c0105755:	5d                   	pop    %ebp
c0105756:	e9 fd fd ff ff       	jmp    c0105558 <_ZN3VMM8checkVmmEv>
c010575b:	90                   	nop

c010575c <_ZN4ListIN3VMM3VMAEE8addLNodeERNS2_6DLNodeE>:
void List<Object>::addLNode(DLNode &node) {
c010575c:	55                   	push   %ebp
c010575d:	89 e5                	mov    %esp,%ebp
c010575f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105762:	53                   	push   %ebx
c0105763:	8b 45 0c             	mov    0xc(%ebp),%eax
    return (headNode.eNum == 0 && headNode.last == nullptr);
c0105766:	8b 4a 0c             	mov    0xc(%edx),%ecx
c0105769:	8b 5a 08             	mov    0x8(%edx),%ebx
c010576c:	85 c9                	test   %ecx,%ecx
c010576e:	75 1a                	jne    c010578a <_ZN4ListIN3VMM3VMAEE8addLNodeERNS2_6DLNodeE+0x2e>
c0105770:	85 db                	test   %ebx,%ebx
c0105772:	75 16                	jne    c010578a <_ZN4ListIN3VMM3VMAEE8addLNodeERNS2_6DLNodeE+0x2e>
        headNode.last = &node;
c0105774:	89 42 08             	mov    %eax,0x8(%edx)
        headNode.first = &node;
c0105777:	89 42 04             	mov    %eax,0x4(%edx)
        node.pre = nullptr;
c010577a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        node.next = nullptr;
c0105781:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
c0105788:	eb 10                	jmp    c010579a <_ZN4ListIN3VMM3VMAEE8addLNodeERNS2_6DLNodeE+0x3e>
        p->next = &node;
c010578a:	89 43 14             	mov    %eax,0x14(%ebx)
        node.pre = p;
c010578d:	89 58 10             	mov    %ebx,0x10(%eax)
        node.next = nullptr;
c0105790:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        headNode.last = &node;           // update 
c0105797:	89 42 08             	mov    %eax,0x8(%edx)
    headNode.eNum++;
c010579a:	41                   	inc    %ecx
c010579b:	89 4a 0c             	mov    %ecx,0xc(%edx)
}
c010579e:	5b                   	pop    %ebx
c010579f:	5d                   	pop    %ebp
c01057a0:	c3                   	ret    
c01057a1:	90                   	nop

c01057a2 <_ZN3MMUC1Ev>:
#include <mmu.h>
#include <kdebug.h>
#include <ostream.h>

MMU::MMU() {
c01057a2:	55                   	push   %ebp
c01057a3:	89 e5                	mov    %esp,%ebp

}
c01057a5:	5d                   	pop    %ebp
c01057a6:	c3                   	ret    
c01057a7:	90                   	nop

c01057a8 <_ZN3MMU10setSegDescEjjjj>:

MMU::SegDesc MMU::setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
c01057a8:	55                   	push   %ebp
c01057a9:	89 e5                	mov    %esp,%ebp
c01057ab:	57                   	push   %edi
c01057ac:	56                   	push   %esi
c01057ad:	53                   	push   %ebx
c01057ae:	81 ec 44 02 00 00    	sub    $0x244,%esp
c01057b4:	8b 75 08             	mov    0x8(%ebp),%esi
    sd.sd_avl = 0;
    sd.sd_l = 0;
    sd.sd_db = 1;
    sd.sd_g = 1;
    sd.sd_base_31_24 = (uint16_t)(base >> 24);
    OStream out("\nsetGDT-->Desc type ", "red");
c01057b7:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
MMU::SegDesc MMU::setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
c01057bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
    sd.sd_lim_15_0 = lim & 0xffff;
c01057c0:	0f b7 45 14          	movzwl 0x14(%ebp),%eax
    sd.sd_type = type;
c01057c4:	8a 55 0c             	mov    0xc(%ebp),%dl
c01057c7:	e8 01 b4 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c01057cc:	81 c3 54 cc 01 00    	add    $0x1cc54,%ebx
    sd.sd_lim_15_0 = lim & 0xffff;
c01057d2:	88 06                	mov    %al,(%esi)
c01057d4:	88 66 01             	mov    %ah,0x1(%esi)
    sd.sd_base_15_0 = (base) & 0xffff;
c01057d7:	0f b7 c1             	movzwl %cx,%eax
    sd.sd_type = type;
c01057da:	80 e2 0f             	and    $0xf,%dl
    sd.sd_base_15_0 = (base) & 0xffff;
c01057dd:	88 46 02             	mov    %al,0x2(%esi)
c01057e0:	88 66 03             	mov    %ah,0x3(%esi)
    sd.sd_base_23_16 = ((base) >> 16) & 0xff;
c01057e3:	89 c8                	mov    %ecx,%eax
c01057e5:	c1 e8 10             	shr    $0x10,%eax
c01057e8:	88 46 04             	mov    %al,0x4(%esi)
    sd.sd_type = type;
c01057eb:	8a 46 05             	mov    0x5(%esi),%al
    sd.sd_base_31_24 = (uint16_t)(base >> 24);
c01057ee:	c1 e9 18             	shr    $0x18,%ecx
c01057f1:	88 4e 07             	mov    %cl,0x7(%esi)
    sd.sd_type = type;
c01057f4:	24 f0                	and    $0xf0,%al
c01057f6:	08 d0                	or     %dl,%al
    sd.sd_dpl = dpl;
c01057f8:	8a 55 18             	mov    0x18(%ebp),%dl
    sd.sd_s = 1;
c01057fb:	0c 10                	or     $0x10,%al
    sd.sd_dpl = dpl;
c01057fd:	24 9f                	and    $0x9f,%al
c01057ff:	80 e2 03             	and    $0x3,%dl
c0105802:	c0 e2 05             	shl    $0x5,%dl
c0105805:	08 d0                	or     %dl,%al
    sd.sd_p = 1;
c0105807:	0c 80                	or     $0x80,%al
c0105809:	88 46 05             	mov    %al,0x5(%esi)
    sd.sd_lim_19_16 = (uint16_t)(lim >> 16);
c010580c:	8b 45 14             	mov    0x14(%ebp),%eax
c010580f:	c1 e8 10             	shr    $0x10,%eax
c0105812:	24 0f                	and    $0xf,%al
    sd.sd_g = 1;
c0105814:	0c c0                	or     $0xc0,%al
c0105816:	88 46 06             	mov    %al,0x6(%esi)
    OStream out("\nsetGDT-->Desc type ", "red");
c0105819:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c010581f:	50                   	push   %eax
c0105820:	8d 85 db fd ff ff    	lea    -0x225(%ebp),%eax
c0105826:	50                   	push   %eax
c0105827:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c010582d:	e8 c8 04 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105832:	58                   	pop    %eax
c0105833:	5a                   	pop    %edx
c0105834:	8d 93 ab 40 fe ff    	lea    -0x1bf55(%ebx),%edx
c010583a:	52                   	push   %edx
c010583b:	8d 95 d6 fd ff ff    	lea    -0x22a(%ebp),%edx
c0105841:	52                   	push   %edx
c0105842:	89 95 c4 fd ff ff    	mov    %edx,-0x23c(%ebp)
c0105848:	e8 ad 04 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c010584d:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0105853:	83 c4 0c             	add    $0xc,%esp
c0105856:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c010585c:	50                   	push   %eax
c010585d:	52                   	push   %edx
c010585e:	57                   	push   %edi
c010585f:	e8 6a c2 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0105864:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c010586a:	89 14 24             	mov    %edx,(%esp)
c010586d:	e8 a2 04 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105872:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0105878:	89 04 24             	mov    %eax,(%esp)
c010587b:	e8 94 04 00 00       	call   c0105d14 <_ZN6StringD1Ev>
    out.writeValue(type);
c0105880:	59                   	pop    %ecx
c0105881:	58                   	pop    %eax
c0105882:	8d 45 0c             	lea    0xc(%ebp),%eax
c0105885:	50                   	push   %eax
c0105886:	57                   	push   %edi
c0105887:	e8 d4 c3 ff ff       	call   c0101c60 <_ZN7OStream10writeValueERKj>
    OStream out("\nsetGDT-->Desc type ", "red");
c010588c:	89 3c 24             	mov    %edi,(%esp)
c010588f:	e8 18 c3 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
    return sd;
}
c0105894:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0105897:	89 f0                	mov    %esi,%eax
c0105899:	5b                   	pop    %ebx
c010589a:	5e                   	pop    %esi
c010589b:	5f                   	pop    %edi
c010589c:	5d                   	pop    %ebp
c010589d:	c2 04 00             	ret    $0x4

c01058a0 <_ZN3MMU10setTssDescEjjjj>:

MMU::SegDesc MMU::setTssDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
c01058a0:	55                   	push   %ebp
c01058a1:	89 e5                	mov    %esp,%ebp
c01058a3:	8b 55 14             	mov    0x14(%ebp),%edx
c01058a6:	56                   	push   %esi
c01058a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01058aa:	8b 75 10             	mov    0x10(%ebp),%esi
c01058ad:	53                   	push   %ebx
    td.sd_lim_15_0 = lim & 0xffff;
    td.sd_base_15_0 = (base) & 0xffff;
    td.sd_base_23_16 = ((base) >> 16) & 0xff;
    td.sd_type = type;
    td.sd_s = 0;
    td.sd_dpl = dpl;
c01058ae:	8a 5d 18             	mov    0x18(%ebp),%bl
    td.sd_lim_15_0 = lim & 0xffff;
c01058b1:	0f b7 ca             	movzwl %dx,%ecx
c01058b4:	88 08                	mov    %cl,(%eax)
    td.sd_p = 1;
    td.sd_lim_19_16 = (uint16_t)(lim >> 16);
c01058b6:	c1 ea 10             	shr    $0x10,%edx
    td.sd_lim_15_0 = lim & 0xffff;
c01058b9:	88 68 01             	mov    %ch,0x1(%eax)
    td.sd_base_15_0 = (base) & 0xffff;
c01058bc:	0f b7 ce             	movzwl %si,%ecx
    td.sd_lim_19_16 = (uint16_t)(lim >> 16);
c01058bf:	80 e2 0f             	and    $0xf,%dl
    td.sd_base_15_0 = (base) & 0xffff;
c01058c2:	88 48 02             	mov    %cl,0x2(%eax)
    td.sd_dpl = dpl;
c01058c5:	80 e3 03             	and    $0x3,%bl
    td.sd_avl = 0;
    td.sd_l = 0;
    td.sd_db = 1;
    td.sd_g = 0;
c01058c8:	80 ca 40             	or     $0x40,%dl
    td.sd_base_15_0 = (base) & 0xffff;
c01058cb:	88 68 03             	mov    %ch,0x3(%eax)
    td.sd_base_23_16 = ((base) >> 16) & 0xff;
c01058ce:	89 f1                	mov    %esi,%ecx
c01058d0:	c1 e9 10             	shr    $0x10,%ecx
c01058d3:	88 48 04             	mov    %cl,0x4(%eax)
    td.sd_type = type;
c01058d6:	8a 4d 0c             	mov    0xc(%ebp),%cl
    td.sd_dpl = dpl;
c01058d9:	c0 e3 05             	shl    $0x5,%bl
    td.sd_base_31_24 = (uint16_t)(base >> 24);
c01058dc:	c1 ee 18             	shr    $0x18,%esi
    td.sd_g = 0;
c01058df:	88 50 06             	mov    %dl,0x6(%eax)
    td.sd_base_31_24 = (uint16_t)(base >> 24);
c01058e2:	89 f2                	mov    %esi,%edx
c01058e4:	88 50 07             	mov    %dl,0x7(%eax)
    td.sd_type = type;
c01058e7:	80 e1 0f             	and    $0xf,%cl
    td.sd_dpl = dpl;
c01058ea:	08 d9                	or     %bl,%cl
    td.sd_p = 1;
c01058ec:	80 c9 80             	or     $0x80,%cl
c01058ef:	88 48 05             	mov    %cl,0x5(%eax)
    return td;                                      
}
c01058f2:	5b                   	pop    %ebx
c01058f3:	5e                   	pop    %esi
c01058f4:	5d                   	pop    %ebp
c01058f5:	c2 04 00             	ret    $0x4

c01058f8 <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>:

void MMU::setGateDesc(GateDesc &gate, uint32_t istrap, uint32_t sel, uint32_t off, uint32_t dpl) {
c01058f8:	55                   	push   %ebp
c01058f9:	89 e5                	mov    %esp,%ebp
c01058fb:	8b 55 14             	mov    0x14(%ebp),%edx
c01058fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105901:	53                   	push   %ebx
    gate.gd_ss = (sel);
    gate.gd_args = 0;                                    
    gate.gd_rsv1 = 0;                                    
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
    gate.gd_s = 0;                                    
    gate.gd_dpl = (dpl);                               
c0105902:	8a 5d 18             	mov    0x18(%ebp),%bl
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c0105905:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
c0105909:	0f b7 ca             	movzwl %dx,%ecx
c010590c:	88 08                	mov    %cl,(%eax)
c010590e:	88 68 01             	mov    %ch,0x1(%eax)
    gate.gd_ss = (sel);
c0105911:	0f b7 4d 10          	movzwl 0x10(%ebp),%ecx
    gate.gd_args = 0;                                    
c0105915:	c6 40 04 00          	movb   $0x0,0x4(%eax)
    gate.gd_ss = (sel);
c0105919:	88 48 02             	mov    %cl,0x2(%eax)
c010591c:	88 68 03             	mov    %ch,0x3(%eax)
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c010591f:	0f 95 c1             	setne  %cl
    gate.gd_dpl = (dpl);                               
c0105922:	80 e3 03             	and    $0x3,%bl
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c0105925:	80 c1 0e             	add    $0xe,%cl
    gate.gd_dpl = (dpl);                               
c0105928:	c0 e3 05             	shl    $0x5,%bl
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c010592b:	80 e1 0f             	and    $0xf,%cl
    gate.gd_dpl = (dpl);                               
c010592e:	08 d9                	or     %bl,%cl
    gate.gd_p = 1;                                    
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;        
c0105930:	c1 ea 10             	shr    $0x10,%edx
    gate.gd_p = 1;                                    
c0105933:	80 c9 80             	or     $0x80,%cl
c0105936:	88 48 05             	mov    %cl,0x5(%eax)
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;        
c0105939:	88 50 06             	mov    %dl,0x6(%eax)
c010593c:	88 70 07             	mov    %dh,0x7(%eax)
}
c010593f:	5b                   	pop    %ebx
c0105940:	5d                   	pop    %ebp
c0105941:	c3                   	ret    

c0105942 <_ZN3MMU11setCallGateERNS_8GateDescEjjj>:

void MMU::setCallGate(GateDesc &gate, uint32_t ss, uint32_t off, uint32_t dpl) {
c0105942:	55                   	push   %ebp
c0105943:	89 e5                	mov    %esp,%ebp
c0105945:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0105948:	8b 45 08             	mov    0x8(%ebp),%eax
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
c010594b:	0f b7 d1             	movzwl %cx,%edx
c010594e:	88 10                	mov    %dl,(%eax)
    gate.gd_rsv1 = 0;                                  
    gate.gd_type = STS_CG32;                          
    gate.gd_s = 0;                                   
    gate.gd_dpl = (dpl);                              
    gate.gd_p = 1;                                  
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;     
c0105950:	c1 e9 10             	shr    $0x10,%ecx
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
c0105953:	88 70 01             	mov    %dh,0x1(%eax)
    gate.gd_ss = (ss);                                
c0105956:	0f b7 55 0c          	movzwl 0xc(%ebp),%edx
    gate.gd_rsv1 = 0;                                  
c010595a:	c6 40 04 00          	movb   $0x0,0x4(%eax)
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;     
c010595e:	88 48 06             	mov    %cl,0x6(%eax)
c0105961:	88 68 07             	mov    %ch,0x7(%eax)
    gate.gd_ss = (ss);                                
c0105964:	88 50 02             	mov    %dl,0x2(%eax)
c0105967:	88 70 03             	mov    %dh,0x3(%eax)
    gate.gd_dpl = (dpl);                              
c010596a:	8a 55 14             	mov    0x14(%ebp),%dl
c010596d:	80 e2 03             	and    $0x3,%dl
c0105970:	c0 e2 05             	shl    $0x5,%dl
    gate.gd_p = 1;                                  
c0105973:	80 ca 8c             	or     $0x8c,%dl
c0105976:	88 50 05             	mov    %dl,0x5(%eax)
}
c0105979:	5d                   	pop    %ebp
c010597a:	c3                   	ret    
c010597b:	90                   	nop

c010597c <_ZN3MMU6setTCBEv>:

void MMU::setTCB() {
c010597c:	55                   	push   %ebp
c010597d:	89 e5                	mov    %esp,%ebp

}
c010597f:	5d                   	pop    %ebp
c0105980:	c3                   	ret    
c0105981:	90                   	nop

c0105982 <_ZN3MMU15setPageReservedERNS_4PageE>:

void MMU::setPageReserved(Page &p) {
c0105982:	55                   	push   %ebp
c0105983:	89 e5                	mov    %esp,%ebp
c0105985:	8b 45 08             	mov    0x8(%ebp),%eax
    p.status |= 0x1;
c0105988:	80 48 04 01          	orb    $0x1,0x4(%eax)
}
c010598c:	5d                   	pop    %ebp
c010598d:	c3                   	ret    

c010598e <_ZN3MMU15setPagePropertyERNS_4PageE>:

void MMU::setPageProperty(Page &p) {
c010598e:	55                   	push   %ebp
c010598f:	89 e5                	mov    %esp,%ebp
c0105991:	8b 45 08             	mov    0x8(%ebp),%eax
    p.status |= 0x2;
c0105994:	80 48 04 02          	orb    $0x2,0x4(%eax)
}
c0105998:	5d                   	pop    %ebp
c0105999:	c3                   	ret    

c010599a <_ZN3MMU17clearPagePropertyERNS_4PageE>:

void MMU::clearPageProperty(Page &p) {
c010599a:	55                   	push   %ebp
c010599b:	89 e5                	mov    %esp,%ebp
c010599d:	8b 45 08             	mov    0x8(%ebp),%eax
    p.status &= ~(0x2);                 // clear 2-bits to 0
c01059a0:	80 60 04 fd          	andb   $0xfd,0x4(%eax)
}
c01059a4:	5d                   	pop    %ebp
c01059a5:	c3                   	ret    

c01059a6 <_ZN4Trap16pageFaultHandlerEPNS_9TrapFrameE.part.0>:
        // in kernel, it must be a mistake
        BREAKPOINT("interrupt error");
    }
}

int Trap::pageFaultHandler(TrapFrame *tf) {
c01059a6:	55                   	push   %ebp
c01059a7:	89 e5                	mov    %esp,%ebp
c01059a9:	57                   	push   %edi
c01059aa:	56                   	push   %esi
c01059ab:	53                   	push   %ebx
c01059ac:	e8 1c b2 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c01059b1:	81 c3 6f ca 01 00    	add    $0x1ca6f,%ebx
c01059b7:	81 ec 44 02 00 00    	sub    $0x244,%esp
    if (kernel::vmm.checkMM != nullptr) {
        return kernel::vmm.doPageFault(kernel::vmm.checkMM, tf->tf_err, getCR2());
    } else {
        BREAKPOINT("Trap::pageFaultHandler: Failure");
c01059bd:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01059c3:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01059c9:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c01059cf:	50                   	push   %eax
c01059d0:	56                   	push   %esi
c01059d1:	e8 24 03 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01059d6:	58                   	pop    %eax
c01059d7:	8d 83 07 3e fe ff    	lea    -0x1c1f9(%ebx),%eax
c01059dd:	5a                   	pop    %edx
c01059de:	50                   	push   %eax
c01059df:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c01059e5:	50                   	push   %eax
c01059e6:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c01059ec:	e8 09 03 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c01059f1:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c01059f7:	83 c4 0c             	add    $0xc,%esp
c01059fa:	56                   	push   %esi
c01059fb:	50                   	push   %eax
c01059fc:	57                   	push   %edi
c01059fd:	e8 cc c0 ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0105a02:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0105a08:	89 04 24             	mov    %eax,(%esp)
c0105a0b:	e8 04 03 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105a10:	89 34 24             	mov    %esi,(%esp)
c0105a13:	e8 fc 02 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105a18:	59                   	pop    %ecx
c0105a19:	58                   	pop    %eax
c0105a1a:	8d 83 c0 40 fe ff    	lea    -0x1bf40(%ebx),%eax
c0105a20:	50                   	push   %eax
c0105a21:	56                   	push   %esi
c0105a22:	e8 d3 02 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105a27:	58                   	pop    %eax
c0105a28:	5a                   	pop    %edx
c0105a29:	56                   	push   %esi
c0105a2a:	57                   	push   %edi
c0105a2b:	e8 ec c1 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0105a30:	89 34 24             	mov    %esi,(%esp)
c0105a33:	e8 dc 02 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105a38:	89 3c 24             	mov    %edi,(%esp)
c0105a3b:	e8 28 c1 ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0105a40:	fa                   	cli    
    asm volatile ("hlt");
c0105a41:	f4                   	hlt    
c0105a42:	89 3c 24             	mov    %edi,(%esp)
c0105a45:	e8 62 c1 ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
        return -1;
    }
c0105a4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0105a4d:	83 c8 ff             	or     $0xffffffff,%eax
c0105a50:	5b                   	pop    %ebx
c0105a51:	5e                   	pop    %esi
c0105a52:	5f                   	pop    %edi
c0105a53:	5d                   	pop    %ebp
c0105a54:	c3                   	ret    
c0105a55:	90                   	nop

c0105a56 <_ZN4Trap16pageFaultHandlerEPNS_9TrapFrameE>:
int Trap::pageFaultHandler(TrapFrame *tf) {
c0105a56:	55                   	push   %ebp
c0105a57:	89 e5                	mov    %esp,%ebp
c0105a59:	53                   	push   %ebx
c0105a5a:	e8 6e b1 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0105a5f:	81 c3 c1 c9 01 00    	add    $0x1c9c1,%ebx
c0105a65:	50                   	push   %eax
c0105a66:	8b 55 08             	mov    0x8(%ebp),%edx
    if (kernel::vmm.checkMM != nullptr) {
c0105a69:	c7 c0 00 50 12 c0    	mov    $0xc0125000,%eax
c0105a6f:	83 38 00             	cmpl   $0x0,(%eax)
c0105a72:	75 09                	jne    c0105a7d <_ZN4Trap16pageFaultHandlerEPNS_9TrapFrameE+0x27>
c0105a74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0105a77:	c9                   	leave  
c0105a78:	e9 29 ff ff ff       	jmp    c01059a6 <_ZN4Trap16pageFaultHandlerEPNS_9TrapFrameE.part.0>
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0105a7d:	0f 20 d1             	mov    %cr2,%ecx
        return kernel::vmm.doPageFault(kernel::vmm.checkMM, tf->tf_err, getCR2());
c0105a80:	51                   	push   %ecx
c0105a81:	ff 72 34             	pushl  0x34(%edx)
c0105a84:	ff 30                	pushl  (%eax)
c0105a86:	50                   	push   %eax
c0105a87:	e8 4e e0 ff ff       	call   c0103ada <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj>
c0105a8c:	83 c4 10             	add    $0x10,%esp
c0105a8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0105a92:	c9                   	leave  
c0105a93:	c3                   	ret    

c0105a94 <_ZN4Trap12trapDispatchEPNS_9TrapFrameE>:
void Trap::trapDispatch(TrapFrame *tf) {
c0105a94:	55                   	push   %ebp
c0105a95:	89 e5                	mov    %esp,%ebp
c0105a97:	57                   	push   %edi
c0105a98:	56                   	push   %esi
c0105a99:	53                   	push   %ebx
c0105a9a:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
c0105aa0:	8b 55 08             	mov    0x8(%ebp),%edx
c0105aa3:	e8 25 b1 ff ff       	call   c0100bcd <__x86.get_pc_thunk.bx>
c0105aa8:	81 c3 78 c9 01 00    	add    $0x1c978,%ebx
    switch (tf->tf_trapno) {
c0105aae:	8b 42 30             	mov    0x30(%edx),%eax
c0105ab1:	83 f8 24             	cmp    $0x24,%eax
c0105ab4:	0f 84 42 01 00 00    	je     c0105bfc <_ZN4Trap12trapDispatchEPNS_9TrapFrameE+0x168>
c0105aba:	77 10                	ja     c0105acc <_ZN4Trap12trapDispatchEPNS_9TrapFrameE+0x38>
c0105abc:	83 f8 0e             	cmp    $0xe,%eax
c0105abf:	74 2e                	je     c0105aef <_ZN4Trap12trapDispatchEPNS_9TrapFrameE+0x5b>
c0105ac1:	0f 82 a3 00 00 00    	jb     c0105b6a <_ZN4Trap12trapDispatchEPNS_9TrapFrameE+0xd6>
c0105ac7:	83 e8 20             	sub    $0x20,%eax
c0105aca:	eb 15                	jmp    c0105ae1 <_ZN4Trap12trapDispatchEPNS_9TrapFrameE+0x4d>
c0105acc:	83 f8 2e             	cmp    $0x2e,%eax
c0105acf:	0f 82 95 00 00 00    	jb     c0105b6a <_ZN4Trap12trapDispatchEPNS_9TrapFrameE+0xd6>
c0105ad5:	83 f8 2f             	cmp    $0x2f,%eax
c0105ad8:	0f 86 1e 01 00 00    	jbe    c0105bfc <_ZN4Trap12trapDispatchEPNS_9TrapFrameE+0x168>
c0105ade:	83 e8 78             	sub    $0x78,%eax
c0105ae1:	83 f8 01             	cmp    $0x1,%eax
c0105ae4:	0f 87 80 00 00 00    	ja     c0105b6a <_ZN4Trap12trapDispatchEPNS_9TrapFrameE+0xd6>
c0105aea:	e9 0d 01 00 00       	jmp    c0105bfc <_ZN4Trap12trapDispatchEPNS_9TrapFrameE+0x168>
        if ((ret = pageFaultHandler(tf)) != 0) {
c0105aef:	83 ec 0c             	sub    $0xc,%esp
c0105af2:	52                   	push   %edx
c0105af3:	e8 5e ff ff ff       	call   c0105a56 <_ZN4Trap16pageFaultHandlerEPNS_9TrapFrameE>
c0105af8:	83 c4 10             	add    $0x10,%esp
c0105afb:	85 c0                	test   %eax,%eax
c0105afd:	0f 84 f9 00 00 00    	je     c0105bfc <_ZN4Trap12trapDispatchEPNS_9TrapFrameE+0x168>
            BREAKPOINT("handle pgfault failed.\n");
c0105b03:	51                   	push   %ecx
c0105b04:	51                   	push   %ecx
c0105b05:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0105b0b:	50                   	push   %eax
c0105b0c:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0105b12:	56                   	push   %esi
c0105b13:	e8 e2 01 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105b18:	5f                   	pop    %edi
c0105b19:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0105b1f:	58                   	pop    %eax
c0105b20:	8d 83 07 3e fe ff    	lea    -0x1c1f9(%ebx),%eax
c0105b26:	50                   	push   %eax
c0105b27:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0105b2d:	50                   	push   %eax
c0105b2e:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0105b34:	e8 c1 01 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105b39:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0105b3f:	83 c4 0c             	add    $0xc,%esp
c0105b42:	56                   	push   %esi
c0105b43:	50                   	push   %eax
c0105b44:	57                   	push   %edi
c0105b45:	e8 84 bf ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0105b4a:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0105b50:	89 04 24             	mov    %eax,(%esp)
c0105b53:	e8 bc 01 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105b58:	89 34 24             	mov    %esi,(%esp)
c0105b5b:	e8 b4 01 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105b60:	58                   	pop    %eax
c0105b61:	8d 83 e0 40 fe ff    	lea    -0x1bf20(%ebx),%eax
c0105b67:	5a                   	pop    %edx
c0105b68:	eb 65                	jmp    c0105bcf <_ZN4Trap12trapDispatchEPNS_9TrapFrameE+0x13b>
        BREAKPOINT("interrupt error");
c0105b6a:	51                   	push   %ecx
c0105b6b:	51                   	push   %ecx
c0105b6c:	8d 83 b1 39 fe ff    	lea    -0x1c64f(%ebx),%eax
c0105b72:	50                   	push   %eax
c0105b73:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0105b79:	56                   	push   %esi
c0105b7a:	e8 7b 01 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105b7f:	5f                   	pop    %edi
c0105b80:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0105b86:	58                   	pop    %eax
c0105b87:	8d 83 07 3e fe ff    	lea    -0x1c1f9(%ebx),%eax
c0105b8d:	50                   	push   %eax
c0105b8e:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0105b94:	50                   	push   %eax
c0105b95:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0105b9b:	e8 5a 01 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105ba0:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0105ba6:	83 c4 0c             	add    $0xc,%esp
c0105ba9:	56                   	push   %esi
c0105baa:	50                   	push   %eax
c0105bab:	57                   	push   %edi
c0105bac:	e8 1d bf ff ff       	call   c0101ace <_ZN7OStreamC1E6StringS0_>
c0105bb1:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0105bb7:	89 04 24             	mov    %eax,(%esp)
c0105bba:	e8 55 01 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105bbf:	89 34 24             	mov    %esi,(%esp)
c0105bc2:	e8 4d 01 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105bc7:	58                   	pop    %eax
c0105bc8:	8d 83 f8 40 fe ff    	lea    -0x1bf08(%ebx),%eax
c0105bce:	5a                   	pop    %edx
c0105bcf:	50                   	push   %eax
c0105bd0:	56                   	push   %esi
c0105bd1:	e8 24 01 00 00       	call   c0105cfa <_ZN6StringC1EPKc>
c0105bd6:	58                   	pop    %eax
c0105bd7:	5a                   	pop    %edx
c0105bd8:	56                   	push   %esi
c0105bd9:	57                   	push   %edi
c0105bda:	e8 3d c0 ff ff       	call   c0101c1c <_ZN7OStream5writeERK6String>
c0105bdf:	89 34 24             	mov    %esi,(%esp)
c0105be2:	e8 2d 01 00 00       	call   c0105d14 <_ZN6StringD1Ev>
c0105be7:	89 3c 24             	mov    %edi,(%esp)
c0105bea:	e8 79 bf ff ff       	call   c0101b68 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0105bef:	fa                   	cli    
    asm volatile ("hlt");
c0105bf0:	f4                   	hlt    
c0105bf1:	89 3c 24             	mov    %edi,(%esp)
c0105bf4:	e8 b3 bf ff ff       	call   c0101bac <_ZN7OStreamD1Ev>
c0105bf9:	83 c4 10             	add    $0x10,%esp
}
c0105bfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0105bff:	5b                   	pop    %ebx
c0105c00:	5e                   	pop    %esi
c0105c01:	5f                   	pop    %edi
c0105c02:	5d                   	pop    %ebp
c0105c03:	c3                   	ret    

c0105c04 <_ZN4Trap4trapEPNS_9TrapFrameE>:
void Trap::trap(TrapFrame *tf) {
c0105c04:	55                   	push   %ebp
c0105c05:	89 e5                	mov    %esp,%ebp
}
c0105c07:	5d                   	pop    %ebp
    trapDispatch(tf);
c0105c08:	e9 87 fe ff ff       	jmp    c0105a94 <_ZN4Trap12trapDispatchEPNS_9TrapFrameE>

c0105c0d <__cxa_pure_virtual>:
#include <icxxabi.h>


extern "C" {

    void __cxa_pure_virtual() {
c0105c0d:	55                   	push   %ebp
c0105c0e:	89 e5                	mov    %esp,%ebp
        // Do Nothing
    }
c0105c10:	5d                   	pop    %ebp
c0105c11:	c3                   	ret    

c0105c12 <__cxa_atexit>:
    atexitFuncEntry_t __atexitFuncs[ATEXIT_FUNC_MAX];
    uarch_t __atexitFuncCount = 0;

    void *__dso_handle = 0;

    int __cxa_atexit(void (*f)(void *), void *objptr, void *dso){
c0105c12:	e8 ad b4 ff ff       	call   c01010c4 <__x86.get_pc_thunk.cx>
c0105c17:	81 c1 09 c8 01 00    	add    $0x1c809,%ecx
        if(__atexitFuncCount >= ATEXIT_FUNC_MAX){
c0105c1d:	8b 91 24 36 00 00    	mov    0x3624(%ecx),%edx
c0105c23:	83 fa 7f             	cmp    $0x7f,%edx
c0105c26:	77 30                	ja     c0105c58 <__cxa_atexit+0x46>
    int __cxa_atexit(void (*f)(void *), void *objptr, void *dso){
c0105c28:	55                   	push   %ebp
c0105c29:	89 e5                	mov    %esp,%ebp
            return -1;
        }
        __atexitFuncs[__atexitFuncCount].destructorFunc = f;
c0105c2b:	6b c2 0c             	imul   $0xc,%edx,%eax
        __atexitFuncs[__atexitFuncCount].objPtr = objptr;
        __atexitFuncs[__atexitFuncCount].dsoHandle = dso;
        __atexitFuncCount++;
c0105c2e:	42                   	inc    %edx
    int __cxa_atexit(void (*f)(void *), void *objptr, void *dso){
c0105c2f:	53                   	push   %ebx
        __atexitFuncs[__atexitFuncCount].destructorFunc = f;
c0105c30:	8b 5d 08             	mov    0x8(%ebp),%ebx
        __atexitFuncCount++;
c0105c33:	89 91 24 36 00 00    	mov    %edx,0x3624(%ecx)
        __atexitFuncs[__atexitFuncCount].destructorFunc = f;
c0105c39:	89 9c 01 40 36 00 00 	mov    %ebx,0x3640(%ecx,%eax,1)
        __atexitFuncs[__atexitFuncCount].objPtr = objptr;
c0105c40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c0105c43:	8d 84 01 40 36 00 00 	lea    0x3640(%ecx,%eax,1),%eax
c0105c4a:	89 58 04             	mov    %ebx,0x4(%eax)
        __atexitFuncs[__atexitFuncCount].dsoHandle = dso;
c0105c4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
c0105c50:	89 58 08             	mov    %ebx,0x8(%eax)
        return 0;
c0105c53:	31 c0                	xor    %eax,%eax
    }
c0105c55:	5b                   	pop    %ebx
c0105c56:	5d                   	pop    %ebp
c0105c57:	c3                   	ret    
c0105c58:	83 c8 ff             	or     $0xffffffff,%eax
c0105c5b:	c3                   	ret    

c0105c5c <__cxa_finalize>:

    void __cxa_finalize(void *f){
c0105c5c:	55                   	push   %ebp
c0105c5d:	89 e5                	mov    %esp,%ebp
c0105c5f:	57                   	push   %edi
c0105c60:	56                   	push   %esi
c0105c61:	53                   	push   %ebx
c0105c62:	83 ec 1c             	sub    $0x1c,%esp
c0105c65:	e8 77 00 00 00       	call   c0105ce1 <__x86.get_pc_thunk.si>
c0105c6a:	81 c6 b6 c7 01 00    	add    $0x1c7b6,%esi
c0105c70:	8b 45 08             	mov    0x8(%ebp),%eax
        signed i = __atexitFuncCount;
        if(!f){
c0105c73:	85 c0                	test   %eax,%eax
        signed i = __atexitFuncCount;
c0105c75:	8b 9e 24 36 00 00    	mov    0x3624(%esi),%ebx
        if(!f){
c0105c7b:	74 0e                	je     c0105c8b <__cxa_finalize+0x2f>
c0105c7d:	6b d3 0c             	imul   $0xc,%ebx,%edx
c0105c80:	8d bc 16 40 36 00 00 	lea    0x3640(%esi,%edx,1),%edi
c0105c87:	31 f6                	xor    %esi,%esi
c0105c89:	eb 4a                	jmp    c0105cd5 <__cxa_finalize+0x79>
c0105c8b:	6b db 0c             	imul   $0xc,%ebx,%ebx
            while(i--){
c0105c8e:	85 db                	test   %ebx,%ebx
c0105c90:	74 47                	je     c0105cd9 <__cxa_finalize+0x7d>
                if(__atexitFuncs[i].destructorFunc){
c0105c92:	8b 84 33 34 36 00 00 	mov    0x3634(%ebx,%esi,1),%eax
c0105c99:	85 c0                	test   %eax,%eax
c0105c9b:	75 05                	jne    c0105ca2 <__cxa_finalize+0x46>
c0105c9d:	83 eb 0c             	sub    $0xc,%ebx
c0105ca0:	eb ec                	jmp    c0105c8e <__cxa_finalize+0x32>
                    (*__atexitFuncs[i].destructorFunc)(__atexitFuncs[i].objPtr);
c0105ca2:	83 ec 0c             	sub    $0xc,%esp
c0105ca5:	ff b4 33 38 36 00 00 	pushl  0x3638(%ebx,%esi,1)
c0105cac:	ff d0                	call   *%eax
c0105cae:	83 c4 10             	add    $0x10,%esp
c0105cb1:	eb ea                	jmp    c0105c9d <__cxa_finalize+0x41>
            }
            return;
        }

        for(; i >= 0; i--){
            if(__atexitFuncs[i].destructorFunc == f){
c0105cb3:	39 04 37             	cmp    %eax,(%edi,%esi,1)
c0105cb6:	75 19                	jne    c0105cd1 <__cxa_finalize+0x75>
                (*__atexitFuncs[i].destructorFunc)(__atexitFuncs[i].objPtr);
c0105cb8:	83 ec 0c             	sub    $0xc,%esp
c0105cbb:	ff 74 37 04          	pushl  0x4(%edi,%esi,1)
c0105cbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105cc2:	ff d0                	call   *%eax
c0105cc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
                __atexitFuncs[i].destructorFunc = 0;
c0105cc7:	c7 04 37 00 00 00 00 	movl   $0x0,(%edi,%esi,1)
c0105cce:	83 c4 10             	add    $0x10,%esp
        for(; i >= 0; i--){
c0105cd1:	4b                   	dec    %ebx
c0105cd2:	83 ee 0c             	sub    $0xc,%esi
c0105cd5:	85 db                	test   %ebx,%ebx
c0105cd7:	79 da                	jns    c0105cb3 <__cxa_finalize+0x57>
            }
        }
    }
c0105cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0105cdc:	5b                   	pop    %ebx
c0105cdd:	5e                   	pop    %esi
c0105cde:	5f                   	pop    %edi
c0105cdf:	5d                   	pop    %ebp
c0105ce0:	c3                   	ret    

c0105ce1 <__x86.get_pc_thunk.si>:
c0105ce1:	8b 34 24             	mov    (%esp),%esi
c0105ce4:	c3                   	ret    
c0105ce5:	90                   	nop

c0105ce6 <_ZN6String7cStrLenEPKc>:
 * @Last Modified time: 2020-03-25 19:21:46 
 */

#include <string.h>

uint32_t String::cStrLen(ccstring cstr) {
c0105ce6:	55                   	push   %ebp
    uint32_t len = 0;
c0105ce7:	31 c0                	xor    %eax,%eax
uint32_t String::cStrLen(ccstring cstr) {
c0105ce9:	89 e5                	mov    %esp,%ebp
c0105ceb:	8b 55 0c             	mov    0xc(%ebp),%edx
    auto it = cstr;
    while(*it++ != '\0') {
c0105cee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
c0105cf2:	74 03                	je     c0105cf7 <_ZN6String7cStrLenEPKc+0x11>
        len++;
c0105cf4:	40                   	inc    %eax
    while(*it++ != '\0') {
c0105cf5:	eb f7                	jmp    c0105cee <_ZN6String7cStrLenEPKc+0x8>
    }
    return len;
}
c0105cf7:	5d                   	pop    %ebp
c0105cf8:	c3                   	ret    
c0105cf9:	90                   	nop

c0105cfa <_ZN6StringC1EPKc>:


String::String(ccstring cstr) {
c0105cfa:	55                   	push   %ebp
c0105cfb:	89 e5                	mov    %esp,%ebp
c0105cfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0105d00:	8b 45 0c             	mov    0xc(%ebp),%eax
    str = (cstring)cstr;
c0105d03:	89 01                	mov    %eax,(%ecx)
    length = cStrLen(cstr);
c0105d05:	50                   	push   %eax
c0105d06:	51                   	push   %ecx
c0105d07:	e8 da ff ff ff       	call   c0105ce6 <_ZN6String7cStrLenEPKc>
c0105d0c:	5a                   	pop    %edx
c0105d0d:	5a                   	pop    %edx
c0105d0e:	88 41 04             	mov    %al,0x4(%ecx)
}
c0105d11:	c9                   	leave  
c0105d12:	c3                   	ret    
c0105d13:	90                   	nop

c0105d14 <_ZN6StringD1Ev>:


String::~String() {                                     //destructor
c0105d14:	55                   	push   %ebp
c0105d15:	89 e5                	mov    %esp,%ebp

}
c0105d17:	5d                   	pop    %ebp
c0105d18:	c3                   	ret    
c0105d19:	90                   	nop

c0105d1a <_ZN6StringaSEPKc>:


String & String::operator=(ccstring cstr) {             // copy assigment
c0105d1a:	55                   	push   %ebp
c0105d1b:	89 e5                	mov    %esp,%ebp
c0105d1d:	56                   	push   %esi
c0105d1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0105d21:	53                   	push   %ebx
c0105d22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    length = cStrLen(cstr);
c0105d25:	53                   	push   %ebx
c0105d26:	51                   	push   %ecx
c0105d27:	e8 ba ff ff ff       	call   c0105ce6 <_ZN6String7cStrLenEPKc>
c0105d2c:	5a                   	pop    %edx
c0105d2d:	5e                   	pop    %esi
c0105d2e:	88 41 04             	mov    %al,0x4(%ecx)
    //delete [] str;
    //str = new char[length];
    for (uint32_t i = 0; i < length; i++) {
c0105d31:	31 c0                	xor    %eax,%eax
c0105d33:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
c0105d37:	39 c2                	cmp    %eax,%edx
c0105d39:	76 0b                	jbe    c0105d46 <_ZN6StringaSEPKc+0x2c>
        str[i] = cstr[i];
c0105d3b:	8a 14 03             	mov    (%ebx,%eax,1),%dl
c0105d3e:	8b 31                	mov    (%ecx),%esi
c0105d40:	88 14 06             	mov    %dl,(%esi,%eax,1)
    for (uint32_t i = 0; i < length; i++) {
c0105d43:	40                   	inc    %eax
c0105d44:	eb ed                	jmp    c0105d33 <_ZN6StringaSEPKc+0x19>
    }
    return *this;
}
c0105d46:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0105d49:	89 c8                	mov    %ecx,%eax
c0105d4b:	5b                   	pop    %ebx
c0105d4c:	5e                   	pop    %esi
c0105d4d:	5d                   	pop    %ebp
c0105d4e:	c3                   	ret    
c0105d4f:	90                   	nop

c0105d50 <_ZNK6String4cStrEv>:

ccstring String::cStr() const {
c0105d50:	55                   	push   %ebp
c0105d51:	89 e5                	mov    %esp,%ebp
    return str;
c0105d53:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105d56:	5d                   	pop    %ebp
    return str;
c0105d57:	8b 00                	mov    (%eax),%eax
}
c0105d59:	c3                   	ret    

c0105d5a <_ZNK6String9getLengthEv>:

uint8_t String::getLength() const {
c0105d5a:	55                   	push   %ebp
c0105d5b:	89 e5                	mov    %esp,%ebp
    return length;
c0105d5d:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105d60:	5d                   	pop    %ebp
    return length;
c0105d61:	8a 40 04             	mov    0x4(%eax),%al
}
c0105d64:	c3                   	ret    
c0105d65:	90                   	nop

c0105d66 <_ZN6StringeqERKS_>:

bool String::operator==(const String &_str) {
c0105d66:	55                   	push   %ebp
    bool isEquals = false;
c0105d67:	31 c0                	xor    %eax,%eax
bool String::operator==(const String &_str) {
c0105d69:	89 e5                	mov    %esp,%ebp
c0105d6b:	57                   	push   %edi
c0105d6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0105d6f:	56                   	push   %esi
c0105d70:	53                   	push   %ebx
c0105d71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (_str.length == length) {
c0105d74:	8a 53 04             	mov    0x4(%ebx),%dl
c0105d77:	3a 51 04             	cmp    0x4(%ecx),%dl
c0105d7a:	75 1e                	jne    c0105d9a <_ZN6StringeqERKS_+0x34>
        for (uint32_t i = 0; i < length; i++) {
c0105d7c:	31 c0                	xor    %eax,%eax
c0105d7e:	0f b6 fa             	movzbl %dl,%edi
c0105d81:	39 c7                	cmp    %eax,%edi
c0105d83:	76 0f                	jbe    c0105d94 <_ZN6StringeqERKS_+0x2e>
            if (str[i] != (_str.str)[i]) {
c0105d85:	8b 13                	mov    (%ebx),%edx
c0105d87:	8b 31                	mov    (%ecx),%esi
c0105d89:	8a 14 02             	mov    (%edx,%eax,1),%dl
c0105d8c:	38 14 06             	cmp    %dl,(%esi,%eax,1)
c0105d8f:	75 07                	jne    c0105d98 <_ZN6StringeqERKS_+0x32>
        for (uint32_t i = 0; i < length; i++) {
c0105d91:	40                   	inc    %eax
c0105d92:	eb ed                	jmp    c0105d81 <_ZN6StringeqERKS_+0x1b>
                return false;
            }
        }
        isEquals = true;
c0105d94:	b0 01                	mov    $0x1,%al
c0105d96:	eb 02                	jmp    c0105d9a <_ZN6StringeqERKS_+0x34>
    bool isEquals = false;
c0105d98:	31 c0                	xor    %eax,%eax
    }
    return isEquals;
}
c0105d9a:	5b                   	pop    %ebx
c0105d9b:	5e                   	pop    %esi
c0105d9c:	5f                   	pop    %edi
c0105d9d:	5d                   	pop    %ebp
c0105d9e:	c3                   	ret    
c0105d9f:	90                   	nop

c0105da0 <_ZN6StringixEj>:

// index accessor
char & String::operator[](const uint32_t index) {
c0105da0:	55                   	push   %ebp
c0105da1:	89 e5                	mov    %esp,%ebp
    return str[index];
c0105da3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105da6:	8b 00                	mov    (%eax),%eax
c0105da8:	03 45 0c             	add    0xc(%ebp),%eax
}
c0105dab:	5d                   	pop    %ebp
c0105dac:	c3                   	ret    
