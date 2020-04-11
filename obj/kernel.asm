
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <entryKernel>:

.text
.globl entryKernel
entryKernel:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 f0 11 00       	mov    $0x11f000,%eax
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
c0100020:	a3 00 f0 11 c0       	mov    %eax,0xc011f000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 e0 11 c0       	mov    $0xc011e000,%esp
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
    call _ZN4Trap4trapEv
c010004c:	e8 dd 48 00 00       	call   c010492e <_ZN4Trap4trapEv>

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
c0100acd:	e8 ea 00 00 00       	call   c0100bbc <__x86.get_pc_thunk.ax>
c0100ad2:	05 4e d9 01 00       	add    $0x1d94e,%eax
c0100ad7:	55                   	push   %ebp
c0100ad8:	89 e5                	mov    %esp,%ebp
c0100ada:	56                   	push   %esi
c0100adb:	53                   	push   %ebx
    // Loop and call all the constructors
   for(uint32_t *ctor = &ctorStart; ctor < &ctorEnd; ctor++){
c0100adc:	c7 c6 04 b0 11 c0    	mov    $0xc011b004,%esi
c0100ae2:	c7 c3 00 b0 11 c0    	mov    $0xc011b000,%ebx
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
c0100afd:	e8 be 00 00 00       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0100b02:	81 c3 1e d9 01 00    	add    $0x1d91e,%ebx
c0100b08:	81 ec 48 02 00 00    	sub    $0x248,%esp

    kernel::console.init();
    kernel::console.setBackground("white");
c0100b0e:	8d b5 e0 fd ff ff    	lea    -0x220(%ebp),%esi
    kernel::console.init();
c0100b14:	c7 c7 68 10 12 c0    	mov    $0xc0121068,%edi
c0100b1a:	57                   	push   %edi
c0100b1b:	e8 22 03 00 00       	call   c0100e42 <_ZN7Console4initEv>
    kernel::console.setBackground("white");
c0100b20:	58                   	pop    %eax
c0100b21:	8d 83 30 67 fe ff    	lea    -0x198d0(%ebx),%eax
c0100b27:	5a                   	pop    %edx
c0100b28:	50                   	push   %eax
c0100b29:	56                   	push   %esi
c0100b2a:	e8 6b 3f 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0100b2f:	59                   	pop    %ecx
c0100b30:	58                   	pop    %eax
c0100b31:	56                   	push   %esi
c0100b32:	57                   	push   %edi
c0100b33:	e8 d8 01 00 00       	call   c0100d10 <_ZN7Console13setBackgroundE6String>
    
    OStream os("Welcome SPX OS.....\n\n", "blue");
c0100b38:	8d bd db fd ff ff    	lea    -0x225(%ebp),%edi
    kernel::console.setBackground("white");
c0100b3e:	89 34 24             	mov    %esi,(%esp)
c0100b41:	e8 6e 3f 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    OStream os("Welcome SPX OS.....\n\n", "blue");
c0100b46:	58                   	pop    %eax
c0100b47:	8d 83 36 67 fe ff    	lea    -0x198ca(%ebx),%eax
c0100b4d:	5a                   	pop    %edx
c0100b4e:	50                   	push   %eax
c0100b4f:	57                   	push   %edi
c0100b50:	e8 45 3f 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0100b55:	59                   	pop    %ecx
c0100b56:	58                   	pop    %eax
c0100b57:	8d 83 3b 67 fe ff    	lea    -0x198c5(%ebx),%eax
c0100b5d:	50                   	push   %eax
c0100b5e:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0100b64:	50                   	push   %eax
c0100b65:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0100b6b:	e8 2a 3f 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0100b70:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0100b76:	83 c4 0c             	add    $0xc,%esp
c0100b79:	57                   	push   %edi
c0100b7a:	50                   	push   %eax
c0100b7b:	56                   	push   %esi
c0100b7c:	e8 3f 0f 00 00       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0100b81:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0100b87:	89 04 24             	mov    %eax,(%esp)
c0100b8a:	e8 25 3f 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0100b8f:	89 3c 24             	mov    %edi,(%esp)
c0100b92:	e8 1d 3f 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    os.flush();
c0100b97:	89 34 24             	mov    %esi,(%esp)
c0100b9a:	e8 bb 0f 00 00       	call   c0101b5a <_ZN7OStream5flushEv>

    kernel::pmm.init();
c0100b9f:	58                   	pop    %eax
c0100ba0:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
c0100ba6:	e8 8b 1c 00 00       	call   c0102836 <_ZN5PhyMM4initEv>

    //kernel::interrupt.init();

    kernel::vmm.init();
c0100bab:	58                   	pop    %eax
c0100bac:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
c0100bb2:	e8 dd 3a 00 00       	call   c0104694 <_ZN3VMM4initEv>
c0100bb7:	83 c4 10             	add    $0x10,%esp
c0100bba:	eb fe                	jmp    c0100bba <initKernel+0xc3>

c0100bbc <__x86.get_pc_thunk.ax>:
c0100bbc:	8b 04 24             	mov    (%esp),%eax
c0100bbf:	c3                   	ret    

c0100bc0 <__x86.get_pc_thunk.bx>:
c0100bc0:	8b 1c 24             	mov    (%esp),%ebx
c0100bc3:	c3                   	ret    

c0100bc4 <_ZN7ConsoleC1Ev>:
 * @Last Modified time: 2020-04-10 21:25:43
 */

#include <console.h>

Console::Console() {
c0100bc4:	55                   	push   %ebp
c0100bc5:	89 e5                	mov    %esp,%ebp
c0100bc7:	57                   	push   %edi
c0100bc8:	56                   	push   %esi
c0100bc9:	53                   	push   %ebx
c0100bca:	83 ec 28             	sub    $0x28,%esp
c0100bcd:	e8 ee ff ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0100bd2:	81 c3 4e d8 01 00    	add    $0x1d84e,%ebx
c0100bd8:	8b 75 08             	mov    0x8(%ebp),%esi
c0100bdb:	56                   	push   %esi
c0100bdc:	e8 ab 06 00 00       	call   c010128c <_ZN11VideoMemoryC1Ev>
c0100be1:	58                   	pop    %eax
c0100be2:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c0100be8:	5a                   	pop    %edx
c0100be9:	50                   	push   %eax
c0100bea:	8d 46 06             	lea    0x6(%esi),%eax
c0100bed:	50                   	push   %eax
c0100bee:	e8 a7 3e 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0100bf3:	8d 83 55 67 fe ff    	lea    -0x198ab(%ebx),%eax
c0100bf9:	59                   	pop    %ecx
c0100bfa:	5f                   	pop    %edi
c0100bfb:	50                   	push   %eax
c0100bfc:	8d 46 0b             	lea    0xb(%esi),%eax
c0100bff:	50                   	push   %eax
c0100c00:	e8 95 3e 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0100c05:	58                   	pop    %eax
c0100c06:	8d 83 30 67 fe ff    	lea    -0x198d0(%ebx),%eax
c0100c0c:	5a                   	pop    %edx
c0100c0d:	50                   	push   %eax
c0100c0e:	8d 46 10             	lea    0x10(%esi),%eax
c0100c11:	50                   	push   %eax
c0100c12:	e8 83 3e 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0100c17:	8d 83 36 67 fe ff    	lea    -0x198ca(%ebx),%eax
c0100c1d:	59                   	pop    %ecx
c0100c1e:	5f                   	pop    %edi
c0100c1f:	50                   	push   %eax
c0100c20:	8d 46 15             	lea    0x15(%esi),%eax
c0100c23:	50                   	push   %eax
c0100c24:	e8 71 3e 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
    // set l and w
    length = 80;
c0100c29:	c7 c7 0c e4 11 c0    	mov    $0xc011e40c,%edi
    wide = 25;
c0100c2f:	c7 c0 08 e4 11 c0    	mov    $0xc011e408,%eax
Console::Console() {
c0100c35:	c7 46 1a 04 00 07 01 	movl   $0x1070004,0x1a(%esi)
    length = 80;
c0100c3c:	c7 07 50 00 00 00    	movl   $0x50,(%edi)
    wide = 25;
c0100c42:	c7 00 19 00 00 00    	movl   $0x19,(%eax)
    
    // get Video Memory buffer
    screen = (Char *)(VideoMemory::vmBuffer);
c0100c48:	c7 c0 30 1a 12 c0    	mov    $0xc0121a30,%eax
c0100c4e:	8b 16                	mov    (%esi),%edx
c0100c50:	89 10                	mov    %edx,(%eax)

    // get cursor position
    cPos.x = VideoMemory::getCursorPos() / length;
c0100c52:	89 34 24             	mov    %esi,(%esp)
c0100c55:	e8 5e 06 00 00       	call   c01012b8 <_ZN11VideoMemory12getCursorPosEv>
c0100c5a:	31 d2                	xor    %edx,%edx
c0100c5c:	c7 c1 2d 1a 12 c0    	mov    $0xc0121a2d,%ecx
c0100c62:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
c0100c65:	0f b7 c0             	movzwl %ax,%eax
c0100c68:	f7 37                	divl   (%edi)
c0100c6a:	88 01                	mov    %al,(%ecx)
    cPos.y = VideoMemory::getCursorPos() % length;
c0100c6c:	89 34 24             	mov    %esi,(%esp)
c0100c6f:	e8 44 06 00 00       	call   c01012b8 <_ZN11VideoMemory12getCursorPosEv>
c0100c74:	31 d2                	xor    %edx,%edx
c0100c76:	8b 4d e4             	mov    -0x1c(%ebp),%ecx

    // set cursor status
    cursorStatus.c = 'S';
    cursorStatus.attri = 0b10101010;        // light green and flash
}
c0100c79:	83 c4 10             	add    $0x10,%esp
    cPos.y = VideoMemory::getCursorPos() % length;
c0100c7c:	0f b7 c0             	movzwl %ax,%eax
c0100c7f:	f7 37                	divl   (%edi)
    cursorStatus.c = 'S';
c0100c81:	c7 c0 02 e4 11 c0    	mov    $0xc011e402,%eax
c0100c87:	66 c7 00 53 aa       	movw   $0xaa53,(%eax)
    cPos.y = VideoMemory::getCursorPos() % length;
c0100c8c:	88 51 01             	mov    %dl,0x1(%ecx)
}
c0100c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100c92:	5b                   	pop    %ebx
c0100c93:	5e                   	pop    %esi
c0100c94:	5f                   	pop    %edi
c0100c95:	5d                   	pop    %ebp
c0100c96:	c3                   	ret    
c0100c97:	90                   	nop

c0100c98 <_ZN7Console5clearEv>:

void Console::clear() {
c0100c98:	55                   	push   %ebp
c0100c99:	89 e5                	mov    %esp,%ebp
c0100c9b:	53                   	push   %ebx
c0100c9c:	e8 1f ff ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0100ca1:	81 c3 7f d7 01 00    	add    $0x1d77f,%ebx
c0100ca7:	83 ec 10             	sub    $0x10,%esp
    VideoMemory::initVmBuff();
c0100caa:	ff 75 08             	pushl  0x8(%ebp)
c0100cad:	e8 ee 05 00 00       	call   c01012a0 <_ZN11VideoMemory10initVmBuffEv>
}
c0100cb2:	83 c4 10             	add    $0x10,%esp
c0100cb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100cb8:	c9                   	leave  
c0100cb9:	c3                   	ret    

c0100cba <_ZN7Console8setColorE6String>:
void Console::init() {
    VideoMemory::initVmBuff();
    setCursorPos(0, 0);
}

void Console::setColor(String str) {
c0100cba:	55                   	push   %ebp
c0100cbb:	89 e5                	mov    %esp,%ebp
c0100cbd:	57                   	push   %edi
c0100cbe:	56                   	push   %esi
    uint32_t index;
    for (index = 0; index < COLOR_NUM; index++) {
c0100cbf:	31 f6                	xor    %esi,%esi
void Console::setColor(String str) {
c0100cc1:	53                   	push   %ebx
c0100cc2:	83 ec 0c             	sub    $0xc,%esp
c0100cc5:	e8 f6 fe ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0100cca:	81 c3 56 d7 01 00    	add    $0x1d756,%ebx
c0100cd0:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cd3:	8d 78 06             	lea    0x6(%eax),%edi
        if (str == color[index]) {
c0100cd6:	50                   	push   %eax
c0100cd7:	50                   	push   %eax
c0100cd8:	57                   	push   %edi
c0100cd9:	ff 75 0c             	pushl  0xc(%ebp)
c0100cdc:	e8 25 3e 00 00       	call   c0104b06 <_ZN6StringeqERKS_>
c0100ce1:	83 c4 10             	add    $0x10,%esp
c0100ce4:	84 c0                	test   %al,%al
c0100ce6:	75 0b                	jne    c0100cf3 <_ZN7Console8setColorE6String+0x39>
    for (index = 0; index < COLOR_NUM; index++) {
c0100ce8:	46                   	inc    %esi
c0100ce9:	83 c7 05             	add    $0x5,%edi
c0100cec:	83 fe 04             	cmp    $0x4,%esi
c0100cef:	75 e5                	jne    c0100cd6 <_ZN7Console8setColorE6String+0x1c>
c0100cf1:	eb 15                	jmp    c0100d08 <_ZN7Console8setColorE6String+0x4e>
            break;
        }
    }
    if (index < COLOR_NUM) {
        charEctype.attri = (charEctype.attri & 0xF0) | colorTable[index];
c0100cf3:	c7 c2 04 e4 11 c0    	mov    $0xc011e404,%edx
c0100cf9:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0100cfc:	8a 42 01             	mov    0x1(%edx),%al
c0100cff:	24 f0                	and    $0xf0,%al
c0100d01:	0a 44 31 1a          	or     0x1a(%ecx,%esi,1),%al
c0100d05:	88 42 01             	mov    %al,0x1(%edx)
    }
}
c0100d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100d0b:	5b                   	pop    %ebx
c0100d0c:	5e                   	pop    %esi
c0100d0d:	5f                   	pop    %edi
c0100d0e:	5d                   	pop    %ebp
c0100d0f:	c3                   	ret    

c0100d10 <_ZN7Console13setBackgroundE6String>:

void Console::setBackground(String str) {
c0100d10:	55                   	push   %ebp
c0100d11:	89 e5                	mov    %esp,%ebp
c0100d13:	57                   	push   %edi
    uint32_t index = 1;                             // default black
    for (uint32_t i = 0; i < COLOR_NUM; i++) {
c0100d14:	31 ff                	xor    %edi,%edi
void Console::setBackground(String str) {
c0100d16:	56                   	push   %esi
c0100d17:	53                   	push   %ebx
c0100d18:	83 ec 1c             	sub    $0x1c,%esp
c0100d1b:	e8 a0 fe ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0100d20:	81 c3 00 d7 01 00    	add    $0x1d700,%ebx
c0100d26:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d29:	8d 70 06             	lea    0x6(%eax),%esi
        if (str == color[i]) {
c0100d2c:	50                   	push   %eax
c0100d2d:	50                   	push   %eax
c0100d2e:	56                   	push   %esi
c0100d2f:	ff 75 0c             	pushl  0xc(%ebp)
c0100d32:	e8 cf 3d 00 00       	call   c0104b06 <_ZN6StringeqERKS_>
c0100d37:	83 c4 10             	add    $0x10,%esp
c0100d3a:	84 c0                	test   %al,%al
c0100d3c:	75 0e                	jne    c0100d4c <_ZN7Console13setBackgroundE6String+0x3c>
    for (uint32_t i = 0; i < COLOR_NUM; i++) {
c0100d3e:	47                   	inc    %edi
c0100d3f:	83 c6 05             	add    $0x5,%esi
c0100d42:	83 ff 04             	cmp    $0x4,%edi
c0100d45:	75 e5                	jne    c0100d2c <_ZN7Console13setBackgroundE6String+0x1c>
    uint32_t index = 1;                             // default black
c0100d47:	bf 01 00 00 00       	mov    $0x1,%edi
            index = i;
            break;
        }
    }
    charEctype.attri = (charEctype.attri & 0x0F) | ((colorTable[index]) << 4);
c0100d4c:	c7 c1 04 e4 11 c0    	mov    $0xc011e404,%ecx
c0100d52:	8b 55 08             	mov    0x8(%ebp),%edx
c0100d55:	8a 41 01             	mov    0x1(%ecx),%al
c0100d58:	0f b6 54 3a 1a       	movzbl 0x1a(%edx,%edi,1),%edx
c0100d5d:	24 0f                	and    $0xf,%al
c0100d5f:	c1 e2 04             	shl    $0x4,%edx
c0100d62:	08 d0                	or     %dl,%al
c0100d64:	88 41 01             	mov    %al,0x1(%ecx)
    for (uint32_t row = 0; row < wide; row++) {
c0100d67:	c7 c0 08 e4 11 c0    	mov    $0xc011e408,%eax
c0100d6d:	8b 00                	mov    (%eax),%eax
c0100d6f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (uint32_t col = 0; col < length; col++) {
c0100d72:	c7 c0 0c e4 11 c0    	mov    $0xc011e40c,%eax
c0100d78:	8b 30                	mov    (%eax),%esi
            if (cPos.x != row || cPos.y != col) {
c0100d7a:	c7 c0 2d 1a 12 c0    	mov    $0xc0121a2d,%eax
c0100d80:	0f b6 38             	movzbl (%eax),%edi
c0100d83:	0f b6 40 01          	movzbl 0x1(%eax),%eax
c0100d87:	89 7d e0             	mov    %edi,-0x20(%ebp)
    for (uint32_t row = 0; row < wide; row++) {
c0100d8a:	31 ff                	xor    %edi,%edi
            if (cPos.x != row || cPos.y != col) {
c0100d8c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100d8f:	8d 04 36             	lea    (%esi,%esi,1),%eax
c0100d92:	89 45 d8             	mov    %eax,-0x28(%ebp)
                screen[row * length + col].attri = charEctype.attri;
c0100d95:	c7 c0 30 1a 12 c0    	mov    $0xc0121a30,%eax
c0100d9b:	8b 18                	mov    (%eax),%ebx
    for (uint32_t row = 0; row < wide; row++) {
c0100d9d:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
c0100da0:	74 24                	je     c0100dc6 <_ZN7Console13setBackgroundE6String+0xb6>
        for (uint32_t col = 0; col < length; col++) {
c0100da2:	31 c0                	xor    %eax,%eax
c0100da4:	39 c6                	cmp    %eax,%esi
c0100da6:	74 14                	je     c0100dbc <_ZN7Console13setBackgroundE6String+0xac>
            if (cPos.x != row || cPos.y != col) {
c0100da8:	39 7d e0             	cmp    %edi,-0x20(%ebp)
c0100dab:	75 05                	jne    c0100db2 <_ZN7Console13setBackgroundE6String+0xa2>
c0100dad:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0100db0:	74 07                	je     c0100db9 <_ZN7Console13setBackgroundE6String+0xa9>
                screen[row * length + col].attri = charEctype.attri;
c0100db2:	8a 51 01             	mov    0x1(%ecx),%dl
c0100db5:	88 54 43 01          	mov    %dl,0x1(%ebx,%eax,2)
        for (uint32_t col = 0; col < length; col++) {
c0100db9:	40                   	inc    %eax
c0100dba:	eb e8                	jmp    c0100da4 <_ZN7Console13setBackgroundE6String+0x94>
    for (uint32_t row = 0; row < wide; row++) {
c0100dbc:	89 f8                	mov    %edi,%eax
c0100dbe:	40                   	inc    %eax
c0100dbf:	89 c7                	mov    %eax,%edi
c0100dc1:	03 5d d8             	add    -0x28(%ebp),%ebx
c0100dc4:	eb d7                	jmp    c0100d9d <_ZN7Console13setBackgroundE6String+0x8d>
            }
        }
    }
}
c0100dc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100dc9:	5b                   	pop    %ebx
c0100dca:	5e                   	pop    %esi
c0100dcb:	5f                   	pop    %edi
c0100dcc:	5d                   	pop    %ebp
c0100dcd:	c3                   	ret    

c0100dce <_ZN7Console12setCursorPosEhh>:

void Console::setCursorPos(uint8_t x, uint8_t y) {
c0100dce:	55                   	push   %ebp
c0100dcf:	89 e5                	mov    %esp,%ebp
c0100dd1:	57                   	push   %edi
c0100dd2:	56                   	push   %esi
c0100dd3:	53                   	push   %ebx
c0100dd4:	e8 e7 fd ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0100dd9:	81 c3 47 d6 01 00    	add    $0x1d647,%ebx
c0100ddf:	83 ec 24             	sub    $0x24,%esp
c0100de2:	8b 45 10             	mov    0x10(%ebp),%eax
c0100de5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
c0100de9:	88 45 e7             	mov    %al,-0x19(%ebp)
    cPos.x = x;
c0100dec:	c7 c6 2d 1a 12 c0    	mov    $0xc0121a2d,%esi
    cPos.y = y;
    // set cursor status
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100df2:	0f b6 7d e7          	movzbl -0x19(%ebp),%edi
    cPos.y = y;
c0100df6:	88 46 01             	mov    %al,0x1(%esi)
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100df9:	c7 c0 0c e4 11 c0    	mov    $0xc011e40c,%eax
    cPos.x = x;
c0100dff:	88 0e                	mov    %cl,(%esi)
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100e01:	0f b6 f1             	movzbl %cl,%esi
c0100e04:	8b 00                	mov    (%eax),%eax
c0100e06:	0f af f0             	imul   %eax,%esi
    VideoMemory::setCursorPos(cPos.x * length + cPos.y);
c0100e09:	0f af c1             	imul   %ecx,%eax
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100e0c:	8d 14 3e             	lea    (%esi,%edi,1),%edx
c0100e0f:	c7 c6 30 1a 12 c0    	mov    $0xc0121a30,%esi
c0100e15:	c7 c7 02 e4 11 c0    	mov    $0xc011e402,%edi
c0100e1b:	8b 36                	mov    (%esi),%esi
c0100e1d:	66 8b 3f             	mov    (%edi),%di
c0100e20:	66 89 3c 56          	mov    %di,(%esi,%edx,2)
    VideoMemory::setCursorPos(cPos.x * length + cPos.y);
c0100e24:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
c0100e28:	01 d0                	add    %edx,%eax
c0100e2a:	0f b7 c0             	movzwl %ax,%eax
c0100e2d:	50                   	push   %eax
c0100e2e:	ff 75 08             	pushl  0x8(%ebp)
c0100e31:	e8 b0 04 00 00       	call   c01012e6 <_ZN11VideoMemory12setCursorPosEt>
}
c0100e36:	83 c4 10             	add    $0x10,%esp
c0100e39:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100e3c:	5b                   	pop    %ebx
c0100e3d:	5e                   	pop    %esi
c0100e3e:	5f                   	pop    %edi
c0100e3f:	5d                   	pop    %ebp
c0100e40:	c3                   	ret    
c0100e41:	90                   	nop

c0100e42 <_ZN7Console4initEv>:
void Console::init() {
c0100e42:	55                   	push   %ebp
c0100e43:	89 e5                	mov    %esp,%ebp
c0100e45:	56                   	push   %esi
c0100e46:	8b 75 08             	mov    0x8(%ebp),%esi
c0100e49:	53                   	push   %ebx
c0100e4a:	e8 71 fd ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0100e4f:	81 c3 d1 d5 01 00    	add    $0x1d5d1,%ebx
    VideoMemory::initVmBuff();
c0100e55:	83 ec 0c             	sub    $0xc,%esp
c0100e58:	56                   	push   %esi
c0100e59:	e8 42 04 00 00       	call   c01012a0 <_ZN11VideoMemory10initVmBuffEv>
    setCursorPos(0, 0);
c0100e5e:	83 c4 0c             	add    $0xc,%esp
c0100e61:	6a 00                	push   $0x0
c0100e63:	6a 00                	push   $0x0
c0100e65:	56                   	push   %esi
c0100e66:	e8 63 ff ff ff       	call   c0100dce <_ZN7Console12setCursorPosEhh>
}
c0100e6b:	83 c4 10             	add    $0x10,%esp
c0100e6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0100e71:	5b                   	pop    %ebx
c0100e72:	5e                   	pop    %esi
c0100e73:	5d                   	pop    %ebp
c0100e74:	c3                   	ret    
c0100e75:	90                   	nop

c0100e76 <_ZN7Console12getCursorPosEv>:

const Console::CursorPos & Console::getCursorPos() {
c0100e76:	55                   	push   %ebp
c0100e77:	89 e5                	mov    %esp,%ebp
c0100e79:	57                   	push   %edi
c0100e7a:	56                   	push   %esi
c0100e7b:	53                   	push   %ebx
c0100e7c:	e8 3f fd ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0100e81:	81 c3 9f d5 01 00    	add    $0x1d59f,%ebx
c0100e87:	83 ec 18             	sub    $0x18,%esp
    cPos.x = VideoMemory::getCursorPos() / length;
c0100e8a:	ff 75 08             	pushl  0x8(%ebp)
c0100e8d:	e8 26 04 00 00       	call   c01012b8 <_ZN11VideoMemory12getCursorPosEv>
c0100e92:	c7 c6 0c e4 11 c0    	mov    $0xc011e40c,%esi
c0100e98:	31 d2                	xor    %edx,%edx
c0100e9a:	c7 c7 2d 1a 12 c0    	mov    $0xc0121a2d,%edi
c0100ea0:	0f b7 c0             	movzwl %ax,%eax
c0100ea3:	f7 36                	divl   (%esi)
c0100ea5:	88 07                	mov    %al,(%edi)
    cPos.y = VideoMemory::getCursorPos() % length;
c0100ea7:	58                   	pop    %eax
c0100ea8:	ff 75 08             	pushl  0x8(%ebp)
c0100eab:	e8 08 04 00 00       	call   c01012b8 <_ZN11VideoMemory12getCursorPosEv>
c0100eb0:	31 d2                	xor    %edx,%edx
c0100eb2:	0f b7 c0             	movzwl %ax,%eax
c0100eb5:	f7 36                	divl   (%esi)
    return cPos;
}
c0100eb7:	89 f8                	mov    %edi,%eax
    cPos.y = VideoMemory::getCursorPos() % length;
c0100eb9:	88 57 01             	mov    %dl,0x1(%edi)
}
c0100ebc:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100ebf:	5b                   	pop    %ebx
c0100ec0:	5e                   	pop    %esi
c0100ec1:	5f                   	pop    %edi
c0100ec2:	5d                   	pop    %ebp
c0100ec3:	c3                   	ret    

c0100ec4 <_ZN7Console4readEv>:
    for (uint32_t i = 0; i < len; i++) {
        wirte(cArry[i]);
    }
}

char Console::read() {
c0100ec4:	e8 f3 fc ff ff       	call   c0100bbc <__x86.get_pc_thunk.ax>
c0100ec9:	05 57 d5 01 00       	add    $0x1d557,%eax
c0100ece:	55                   	push   %ebp
c0100ecf:	89 e5                	mov    %esp,%ebp
    return screen[0].c;
}
c0100ed1:	5d                   	pop    %ebp
    return screen[0].c;
c0100ed2:	c7 c0 30 1a 12 c0    	mov    $0xc0121a30,%eax
c0100ed8:	8b 00                	mov    (%eax),%eax
c0100eda:	8a 00                	mov    (%eax),%al
}
c0100edc:	c3                   	ret    
c0100edd:	90                   	nop

c0100ede <_ZN7Console4readEPcRKt>:

void Console::read(char *cArry, const uint16_t &len) {
c0100ede:	55                   	push   %ebp
c0100edf:	89 e5                	mov    %esp,%ebp
   
}
c0100ee1:	5d                   	pop    %ebp
c0100ee2:	c3                   	ret    
c0100ee3:	90                   	nop

c0100ee4 <_ZN7Console12scrollScreenEv>:
    } else {
        setCursorPos(cPos.x + 1, 0);
    }
}

void Console::scrollScreen() {
c0100ee4:	e8 cd 01 00 00       	call   c01010b6 <__x86.get_pc_thunk.cx>
c0100ee9:	81 c1 37 d5 01 00    	add    $0x1d537,%ecx
    charEctype.c = ' ';
    for (uint32_t i = 0; i < length * wide; i++) {
c0100eef:	31 c0                	xor    %eax,%eax
void Console::scrollScreen() {
c0100ef1:	55                   	push   %ebp
c0100ef2:	89 e5                	mov    %esp,%ebp
c0100ef4:	57                   	push   %edi
c0100ef5:	56                   	push   %esi
c0100ef6:	53                   	push   %ebx
c0100ef7:	83 ec 1c             	sub    $0x1c,%esp
    for (uint32_t i = 0; i < length * wide; i++) {
c0100efa:	c7 c7 0c e4 11 c0    	mov    $0xc011e40c,%edi
    charEctype.c = ' ';
c0100f00:	c7 c6 04 e4 11 c0    	mov    $0xc011e404,%esi
    for (uint32_t i = 0; i < length * wide; i++) {
c0100f06:	89 7d e0             	mov    %edi,-0x20(%ebp)
c0100f09:	c7 c7 08 e4 11 c0    	mov    $0xc011e408,%edi
    charEctype.c = ' ';
c0100f0f:	c6 06 20             	movb   $0x20,(%esi)
    for (uint32_t i = 0; i < length * wide; i++) {
c0100f12:	89 7d dc             	mov    %edi,-0x24(%ebp)
c0100f15:	8b 7d e0             	mov    -0x20(%ebp),%edi
c0100f18:	8b 3f                	mov    (%edi),%edi
c0100f1a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
c0100f1d:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0100f20:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
c0100f23:	8b 17                	mov    (%edi),%edx
c0100f25:	0f af da             	imul   %edx,%ebx
c0100f28:	39 c3                	cmp    %eax,%ebx
c0100f2a:	76 28                	jbe    c0100f54 <_ZN7Console12scrollScreenEv+0x70>
c0100f2c:	c7 c2 30 1a 12 c0    	mov    $0xc0121a30,%edx
        if (i < length * (wide - 1)) {
c0100f32:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
c0100f35:	8b 3a                	mov    (%edx),%edi
c0100f37:	8d 14 00             	lea    (%eax,%eax,1),%edx
c0100f3a:	01 fa                	add    %edi,%edx
c0100f3c:	39 c3                	cmp    %eax,%ebx
c0100f3e:	76 0b                	jbe    c0100f4b <_ZN7Console12scrollScreenEv+0x67>
            screen[i] = screen[length + i];
c0100f40:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
c0100f43:	01 c3                	add    %eax,%ebx
c0100f45:	66 8b 1c 5f          	mov    (%edi,%ebx,2),%bx
c0100f49:	eb 03                	jmp    c0100f4e <_ZN7Console12scrollScreenEv+0x6a>
        } else {
            screen[i] = charEctype;
c0100f4b:	66 8b 1e             	mov    (%esi),%bx
c0100f4e:	66 89 1a             	mov    %bx,(%edx)
    for (uint32_t i = 0; i < length * wide; i++) {
c0100f51:	40                   	inc    %eax
c0100f52:	eb c1                	jmp    c0100f15 <_ZN7Console12scrollScreenEv+0x31>
        }
    }
    setCursorPos(wide - 1, 0);
c0100f54:	fe ca                	dec    %dl
c0100f56:	50                   	push   %eax
c0100f57:	0f b6 d2             	movzbl %dl,%edx
c0100f5a:	6a 00                	push   $0x0
c0100f5c:	52                   	push   %edx
c0100f5d:	ff 75 08             	pushl  0x8(%ebp)
c0100f60:	e8 69 fe ff ff       	call   c0100dce <_ZN7Console12setCursorPosEhh>
}
c0100f65:	83 c4 10             	add    $0x10,%esp
c0100f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100f6b:	5b                   	pop    %ebx
c0100f6c:	5e                   	pop    %esi
c0100f6d:	5f                   	pop    %edi
c0100f6e:	5d                   	pop    %ebp
c0100f6f:	c3                   	ret    

c0100f70 <_ZN7Console4nextEv>:
void Console::next() {
c0100f70:	55                   	push   %ebp
    cPos.y = (cPos.y + 1) % length;
c0100f71:	31 d2                	xor    %edx,%edx
void Console::next() {
c0100f73:	89 e5                	mov    %esp,%ebp
c0100f75:	57                   	push   %edi
c0100f76:	e8 3f 01 00 00       	call   c01010ba <__x86.get_pc_thunk.di>
c0100f7b:	81 c7 a5 d4 01 00    	add    $0x1d4a5,%edi
c0100f81:	56                   	push   %esi
c0100f82:	53                   	push   %ebx
c0100f83:	83 ec 0c             	sub    $0xc,%esp
c0100f86:	8b 75 08             	mov    0x8(%ebp),%esi
    cPos.y = (cPos.y + 1) % length;
c0100f89:	c7 c3 2d 1a 12 c0    	mov    $0xc0121a2d,%ebx
c0100f8f:	c7 c1 0c e4 11 c0    	mov    $0xc011e40c,%ecx
c0100f95:	0f b6 43 01          	movzbl 0x1(%ebx),%eax
c0100f99:	40                   	inc    %eax
c0100f9a:	f7 31                	divl   (%ecx)
    if (cPos.y == 0) {
c0100f9c:	84 d2                	test   %dl,%dl
    cPos.y = (cPos.y + 1) % length;
c0100f9e:	89 d1                	mov    %edx,%ecx
c0100fa0:	88 53 01             	mov    %dl,0x1(%ebx)
    if (cPos.y == 0) {
c0100fa3:	75 20                	jne    c0100fc5 <_ZN7Console4nextEv+0x55>
        cPos.x = (cPos.x + 1) % wide;
c0100fa5:	0f b6 03             	movzbl (%ebx),%eax
c0100fa8:	31 d2                	xor    %edx,%edx
c0100faa:	c7 c7 08 e4 11 c0    	mov    $0xc011e408,%edi
c0100fb0:	40                   	inc    %eax
c0100fb1:	f7 37                	divl   (%edi)
    if (cPos.y == 0 && cPos.x == 0) {   // jugde scroll screen
c0100fb3:	84 d2                	test   %dl,%dl
        cPos.x = (cPos.x + 1) % wide;
c0100fb5:	88 13                	mov    %dl,(%ebx)
    if (cPos.y == 0 && cPos.x == 0) {   // jugde scroll screen
c0100fb7:	75 0c                	jne    c0100fc5 <_ZN7Console4nextEv+0x55>
}
c0100fb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100fbc:	5b                   	pop    %ebx
c0100fbd:	5e                   	pop    %esi
c0100fbe:	5f                   	pop    %edi
c0100fbf:	5d                   	pop    %ebp
        scrollScreen();
c0100fc0:	e9 1f ff ff ff       	jmp    c0100ee4 <_ZN7Console12scrollScreenEv>
        setCursorPos(cPos.x, cPos.y);
c0100fc5:	50                   	push   %eax
c0100fc6:	0f b6 03             	movzbl (%ebx),%eax
c0100fc9:	0f b6 c9             	movzbl %cl,%ecx
c0100fcc:	51                   	push   %ecx
c0100fcd:	50                   	push   %eax
c0100fce:	56                   	push   %esi
c0100fcf:	e8 fa fd ff ff       	call   c0100dce <_ZN7Console12setCursorPosEhh>
c0100fd4:	83 c4 10             	add    $0x10,%esp
}
c0100fd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100fda:	5b                   	pop    %ebx
c0100fdb:	5e                   	pop    %esi
c0100fdc:	5f                   	pop    %edi
c0100fdd:	5d                   	pop    %ebp
c0100fde:	c3                   	ret    
c0100fdf:	90                   	nop

c0100fe0 <_ZN7Console8lineFeedEv>:
void Console::lineFeed() {
c0100fe0:	e8 cd 00 00 00       	call   c01010b2 <__x86.get_pc_thunk.dx>
c0100fe5:	81 c2 3b d4 01 00    	add    $0x1d43b,%edx
c0100feb:	55                   	push   %ebp
c0100fec:	89 e5                	mov    %esp,%ebp
c0100fee:	83 ec 08             	sub    $0x8,%esp
c0100ff1:	8b 4d 08             	mov    0x8(%ebp),%ecx
    if ((uint32_t)(cPos.x + 1) >= wide) {
c0100ff4:	c7 c0 2d 1a 12 c0    	mov    $0xc0121a2d,%eax
c0100ffa:	c7 c2 08 e4 11 c0    	mov    $0xc011e408,%edx
c0101000:	0f b6 00             	movzbl (%eax),%eax
c0101003:	40                   	inc    %eax
c0101004:	3b 02                	cmp    (%edx),%eax
c0101006:	72 06                	jb     c010100e <_ZN7Console8lineFeedEv+0x2e>
}
c0101008:	c9                   	leave  
        scrollScreen();
c0101009:	e9 d6 fe ff ff       	jmp    c0100ee4 <_ZN7Console12scrollScreenEv>
        setCursorPos(cPos.x + 1, 0);
c010100e:	52                   	push   %edx
c010100f:	0f b6 c0             	movzbl %al,%eax
c0101012:	6a 00                	push   $0x0
c0101014:	50                   	push   %eax
c0101015:	51                   	push   %ecx
c0101016:	e8 b3 fd ff ff       	call   c0100dce <_ZN7Console12setCursorPosEhh>
c010101b:	83 c4 10             	add    $0x10,%esp
}
c010101e:	c9                   	leave  
c010101f:	c3                   	ret    

c0101020 <_ZN7Console5wirteERKc>:
void Console::wirte(const char &c) {
c0101020:	e8 91 00 00 00       	call   c01010b6 <__x86.get_pc_thunk.cx>
c0101025:	81 c1 fb d3 01 00    	add    $0x1d3fb,%ecx
c010102b:	55                   	push   %ebp
c010102c:	89 e5                	mov    %esp,%ebp
c010102e:	57                   	push   %edi
    if (c == '\n') {
c010102f:	8b 45 0c             	mov    0xc(%ebp),%eax
void Console::wirte(const char &c) {
c0101032:	56                   	push   %esi
c0101033:	53                   	push   %ebx
c0101034:	c7 c6 2d 1a 12 c0    	mov    $0xc0121a2d,%esi
c010103a:	c7 c7 0c e4 11 c0    	mov    $0xc011e40c,%edi
    if (c == '\n') {
c0101040:	8a 10                	mov    (%eax),%dl
c0101042:	c7 c3 30 1a 12 c0    	mov    $0xc0121a30,%ebx
c0101048:	0f b6 06             	movzbl (%esi),%eax
c010104b:	0f b6 76 01          	movzbl 0x1(%esi),%esi
c010104f:	c7 c1 04 e4 11 c0    	mov    $0xc011e404,%ecx
c0101055:	0f af 07             	imul   (%edi),%eax
c0101058:	01 f0                	add    %esi,%eax
c010105a:	01 c0                	add    %eax,%eax
c010105c:	03 03                	add    (%ebx),%eax
c010105e:	80 fa 0a             	cmp    $0xa,%dl
c0101061:	75 12                	jne    c0101075 <_ZN7Console5wirteERKc+0x55>
        charEctype.c = ' ';
c0101063:	c6 01 20             	movb   $0x20,(%ecx)
        screen[cPos.x * length + cPos.y] = charEctype;
c0101066:	66 8b 11             	mov    (%ecx),%dx
c0101069:	66 89 10             	mov    %dx,(%eax)
}
c010106c:	5b                   	pop    %ebx
c010106d:	5e                   	pop    %esi
c010106e:	5f                   	pop    %edi
c010106f:	5d                   	pop    %ebp
        lineFeed();
c0101070:	e9 6b ff ff ff       	jmp    c0100fe0 <_ZN7Console8lineFeedEv>
        charEctype.c = c;
c0101075:	88 11                	mov    %dl,(%ecx)
        screen[cPos.x * length + cPos.y] = charEctype;
c0101077:	66 8b 11             	mov    (%ecx),%dx
c010107a:	66 89 10             	mov    %dx,(%eax)
}
c010107d:	5b                   	pop    %ebx
c010107e:	5e                   	pop    %esi
c010107f:	5f                   	pop    %edi
c0101080:	5d                   	pop    %ebp
        next();
c0101081:	e9 ea fe ff ff       	jmp    c0100f70 <_ZN7Console4nextEv>

c0101086 <_ZN7Console5wirteEPcRKt>:
void Console::wirte(char *cArry, const uint16_t &len) {
c0101086:	55                   	push   %ebp
c0101087:	89 e5                	mov    %esp,%ebp
c0101089:	53                   	push   %ebx
    for (uint32_t i = 0; i < len; i++) {
c010108a:	31 db                	xor    %ebx,%ebx
void Console::wirte(char *cArry, const uint16_t &len) {
c010108c:	52                   	push   %edx
    for (uint32_t i = 0; i < len; i++) {
c010108d:	8b 45 10             	mov    0x10(%ebp),%eax
c0101090:	0f b7 00             	movzwl (%eax),%eax
c0101093:	39 d8                	cmp    %ebx,%eax
c0101095:	76 16                	jbe    c01010ad <_ZN7Console5wirteEPcRKt+0x27>
        wirte(cArry[i]);
c0101097:	50                   	push   %eax
c0101098:	50                   	push   %eax
c0101099:	8b 45 0c             	mov    0xc(%ebp),%eax
c010109c:	01 d8                	add    %ebx,%eax
    for (uint32_t i = 0; i < len; i++) {
c010109e:	43                   	inc    %ebx
        wirte(cArry[i]);
c010109f:	50                   	push   %eax
c01010a0:	ff 75 08             	pushl  0x8(%ebp)
c01010a3:	e8 78 ff ff ff       	call   c0101020 <_ZN7Console5wirteERKc>
    for (uint32_t i = 0; i < len; i++) {
c01010a8:	83 c4 10             	add    $0x10,%esp
c01010ab:	eb e0                	jmp    c010108d <_ZN7Console5wirteEPcRKt+0x7>
}
c01010ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01010b0:	c9                   	leave  
c01010b1:	c3                   	ret    

c01010b2 <__x86.get_pc_thunk.dx>:
c01010b2:	8b 14 24             	mov    (%esp),%edx
c01010b5:	c3                   	ret    

c01010b6 <__x86.get_pc_thunk.cx>:
c01010b6:	8b 0c 24             	mov    (%esp),%ecx
c01010b9:	c3                   	ret    

c01010ba <__x86.get_pc_thunk.di>:
c01010ba:	8b 3c 24             	mov    (%esp),%edi
c01010bd:	c3                   	ret    

c01010be <_ZN9InterruptC1Ev>:
#include <interrupt.h>

Interrupt::Interrupt() {
c01010be:	55                   	push   %ebp
c01010bf:	89 e5                	mov    %esp,%ebp
    
}
c01010c1:	5d                   	pop    %ebp
c01010c2:	c3                   	ret    
c01010c3:	90                   	nop

c01010c4 <_ZN9Interrupt7initIDTEv>:
    enableIRQ(2);                                   // set master IR2, because of slave connection to IR2
    
    enableIRQ(8);                                   // set slave IR1, clock interrupt of RTC
}

void Interrupt::initIDT() {
c01010c4:	55                   	push   %ebp
c01010c5:	89 e5                	mov    %esp,%ebp
c01010c7:	57                   	push   %edi
c01010c8:	56                   	push   %esi
    extern uptr32_t __vectors[];
    for (uint32_t i = 0; i < sizeof(IDT) / sizeof(MMU::GateDesc); i++) {
c01010c9:	31 f6                	xor    %esi,%esi
void Interrupt::initIDT() {
c01010cb:	53                   	push   %ebx
c01010cc:	e8 ef fa ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c01010d1:	81 c3 4f d3 01 00    	add    $0x1d34f,%ebx
c01010d7:	83 ec 1c             	sub    $0x1c,%esp
        MMU::setGateDesc(IDT[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01010da:	c7 c0 00 e0 11 c0    	mov    $0xc011e000,%eax
c01010e0:	c7 c7 c0 11 12 c0    	mov    $0xc01211c0,%edi
c01010e6:	83 ec 0c             	sub    $0xc,%esp
c01010e9:	6a 00                	push   $0x0
c01010eb:	ff 34 b0             	pushl  (%eax,%esi,4)
c01010ee:	8d 14 f7             	lea    (%edi,%esi,8),%edx
    for (uint32_t i = 0; i < sizeof(IDT) / sizeof(MMU::GateDesc); i++) {
c01010f1:	46                   	inc    %esi
        MMU::setGateDesc(IDT[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01010f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01010f5:	6a 08                	push   $0x8
c01010f7:	6a 00                	push   $0x0
c01010f9:	52                   	push   %edx
c01010fa:	e8 3f 37 00 00       	call   c010483e <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>
    for (uint32_t i = 0; i < sizeof(IDT) / sizeof(MMU::GateDesc); i++) {
c01010ff:	83 c4 20             	add    $0x20,%esp
c0101102:	81 fe 00 01 00 00    	cmp    $0x100,%esi
c0101108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010110b:	75 d9                	jne    c01010e6 <_ZN9Interrupt7initIDTEv+0x22>
    }
	// set for switch from user to kernel
    MMU::setGateDesc(IDT[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c010110d:	83 ec 0c             	sub    $0xc,%esp
c0101110:	6a 03                	push   $0x3
c0101112:	ff b0 e4 01 00 00    	pushl  0x1e4(%eax)
c0101118:	8d 87 c8 03 00 00    	lea    0x3c8(%edi),%eax
c010111e:	6a 08                	push   $0x8
c0101120:	6a 00                	push   $0x0
c0101122:	50                   	push   %eax
c0101123:	e8 16 37 00 00       	call   c010483e <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>

/* -----------------> Set Register <------------------- */

static inline void
lidt(void *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
c0101128:	c7 c0 50 e4 11 c0    	mov    $0xc011e450,%eax
c010112e:	0f 01 18             	lidtl  (%eax)
	// load the IDT
    lidt(&idtPD);
}
c0101131:	83 c4 20             	add    $0x20,%esp
c0101134:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101137:	5b                   	pop    %ebx
c0101138:	5e                   	pop    %esi
c0101139:	5f                   	pop    %edi
c010113a:	5d                   	pop    %ebp
c010113b:	c3                   	ret    

c010113c <_ZN9Interrupt4initEv>:
void Interrupt::init() {
c010113c:	55                   	push   %ebp
c010113d:	89 e5                	mov    %esp,%ebp
c010113f:	56                   	push   %esi
c0101140:	8b 75 08             	mov    0x8(%ebp),%esi
c0101143:	53                   	push   %ebx
c0101144:	e8 77 fa ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0101149:	81 c3 d7 d2 01 00    	add    $0x1d2d7,%ebx
    initIDT();
c010114f:	83 ec 0c             	sub    $0xc,%esp
c0101152:	56                   	push   %esi
c0101153:	e8 6c ff ff ff       	call   c01010c4 <_ZN9Interrupt7initIDTEv>
    initPIC();
c0101158:	89 34 24             	mov    %esi,(%esp)
c010115b:	e8 36 00 00 00       	call   c0101196 <_ZN3PIC7initPICEv>
    initClock();
c0101160:	89 34 24             	mov    %esi,(%esp)
c0101163:	e8 fa 00 00 00       	call   c0101262 <_ZN3RTC9initClockEv>
    enableIRQ(2);                                   // set master IR2, because of slave connection to IR2
c0101168:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c010116f:	e8 7c 00 00 00       	call   c01011f0 <_ZN3PIC9enableIRQEj>
    enableIRQ(8);                                   // set slave IR1, clock interrupt of RTC
c0101174:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010117b:	e8 70 00 00 00       	call   c01011f0 <_ZN3PIC9enableIRQEj>
}
c0101180:	83 c4 10             	add    $0x10,%esp
c0101183:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101186:	5b                   	pop    %ebx
c0101187:	5e                   	pop    %esi
c0101188:	5d                   	pop    %ebp
c0101189:	c3                   	ret    

c010118a <_ZN9Interrupt6enableEv>:

void Interrupt::enable() {
c010118a:	55                   	push   %ebp
c010118b:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c010118d:	fb                   	sti    
    sti();
}
c010118e:	5d                   	pop    %ebp
c010118f:	c3                   	ret    

c0101190 <_ZN9Interrupt7disableEv>:

void Interrupt::disable() {
c0101190:	55                   	push   %ebp
c0101191:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli");
c0101193:	fa                   	cli    
    cli();
}
c0101194:	5d                   	pop    %ebp
c0101195:	c3                   	ret    

c0101196 <_ZN3PIC7initPICEv>:
#include <pic.h>

void PIC::initPIC() {
c0101196:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c0101197:	b0 ff                	mov    $0xff,%al
c0101199:	89 e5                	mov    %esp,%ebp
c010119b:	57                   	push   %edi
c010119c:	56                   	push   %esi
c010119d:	be 21 00 00 00       	mov    $0x21,%esi
c01011a2:	53                   	push   %ebx
c01011a3:	89 f2                	mov    %esi,%edx
c01011a5:	e8 10 ff ff ff       	call   c01010ba <__x86.get_pc_thunk.di>
c01011aa:	81 c7 76 d2 01 00    	add    $0x1d276,%edi
c01011b0:	ee                   	out    %al,(%dx)
c01011b1:	bb a1 00 00 00       	mov    $0xa1,%ebx
c01011b6:	89 da                	mov    %ebx,%edx
c01011b8:	ee                   	out    %al,(%dx)
c01011b9:	b1 11                	mov    $0x11,%cl
c01011bb:	ba 20 00 00 00       	mov    $0x20,%edx
c01011c0:	88 c8                	mov    %cl,%al
c01011c2:	ee                   	out    %al,(%dx)
c01011c3:	b0 20                	mov    $0x20,%al
c01011c5:	89 f2                	mov    %esi,%edx
c01011c7:	ee                   	out    %al,(%dx)
c01011c8:	b0 04                	mov    $0x4,%al
c01011ca:	ee                   	out    %al,(%dx)
c01011cb:	b0 01                	mov    $0x1,%al
c01011cd:	ee                   	out    %al,(%dx)
c01011ce:	ba a0 00 00 00       	mov    $0xa0,%edx
c01011d3:	88 c8                	mov    %cl,%al
c01011d5:	ee                   	out    %al,(%dx)
c01011d6:	b0 70                	mov    $0x70,%al
c01011d8:	89 da                	mov    %ebx,%edx
c01011da:	ee                   	out    %al,(%dx)
c01011db:	b0 04                	mov    $0x4,%al
c01011dd:	ee                   	out    %al,(%dx)
c01011de:	b0 01                	mov    $0x1,%al
c01011e0:	ee                   	out    %al,(%dx)
    outb(ICW1_ICW4, IO1_8259PIC2);                  // ICW1: edge-tri / cascade
    outb(0x70, IO2_8259PIC2);                       // ICW2: set first vectors of interrupt
    outb(0x04, IO2_8259PIC2);                       // ICW3: second chip is link to IR2 of first chip
    outb(0x01, IO2_8259PIC2);                       // ICW4; normal EOI

    didInit = true;                                 // 
c01011e1:	c7 c0 2c 1a 12 c0    	mov    $0xc0121a2c,%eax
c01011e7:	c6 00 01             	movb   $0x1,(%eax)
}
c01011ea:	5b                   	pop    %ebx
c01011eb:	5e                   	pop    %esi
c01011ec:	5f                   	pop    %edi
c01011ed:	5d                   	pop    %ebp
c01011ee:	c3                   	ret    
c01011ef:	90                   	nop

c01011f0 <_ZN3PIC9enableIRQEj>:

void PIC::enableIRQ(uint32_t irq) {                 // enable irq
c01011f0:	e8 bd fe ff ff       	call   c01010b2 <__x86.get_pc_thunk.dx>
c01011f5:	81 c2 2b d2 01 00    	add    $0x1d22b,%edx
    irqMask &= ~(1 << irq);
c01011fb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
void PIC::enableIRQ(uint32_t irq) {                 // enable irq
c0101200:	55                   	push   %ebp
c0101201:	89 e5                	mov    %esp,%ebp
    irqMask &= ~(1 << irq);
c0101203:	8b 4d 08             	mov    0x8(%ebp),%ecx
void PIC::enableIRQ(uint32_t irq) {                 // enable irq
c0101206:	53                   	push   %ebx
    irqMask &= ~(1 << irq);
c0101207:	c7 c3 00 e4 11 c0    	mov    $0xc011e400,%ebx
c010120d:	d3 c0                	rol    %cl,%eax
    if (didInit) {
c010120f:	c7 c2 2c 1a 12 c0    	mov    $0xc0121a2c,%edx
    irqMask &= ~(1 << irq);
c0101215:	66 8b 0b             	mov    (%ebx),%cx
c0101218:	21 c8                	and    %ecx,%eax
    if (didInit) {
c010121a:	80 3a 00             	cmpb   $0x0,(%edx)
    irqMask &= ~(1 << irq);
c010121d:	98                   	cwtl   
c010121e:	0f b7 c8             	movzwl %ax,%ecx
c0101221:	66 89 0b             	mov    %cx,(%ebx)
    if (didInit) {
c0101224:	74 11                	je     c0101237 <_ZN3PIC9enableIRQEj+0x47>
c0101226:	ba 21 00 00 00       	mov    $0x21,%edx
c010122b:	ee                   	out    %al,(%dx)
        outb(irqMask & 0xFF, IO2_8259PIC1);         // master chip
        outb((irqMask >> 8) & 0xFF, IO2_8259PIC2);  // slave chip
c010122c:	89 c8                	mov    %ecx,%eax
c010122e:	ba a1 00 00 00       	mov    $0xa1,%edx
c0101233:	c1 e8 08             	shr    $0x8,%eax
c0101236:	ee                   	out    %al,(%dx)
    }
}
c0101237:	5b                   	pop    %ebx
c0101238:	5d                   	pop    %ebp
c0101239:	c3                   	ret    

c010123a <_ZN3PIC7sendEOIEv>:

void PIC::sendEOI() {
c010123a:	55                   	push   %ebp
c010123b:	b0 20                	mov    $0x20,%al
c010123d:	89 e5                	mov    %esp,%ebp
c010123f:	ba a0 00 00 00       	mov    $0xa0,%edx
c0101244:	ee                   	out    %al,(%dx)
c0101245:	ba 20 00 00 00       	mov    $0x20,%edx
c010124a:	ee                   	out    %al,(%dx)
    outb(EOI_CMD, IO1_8259PIC2);                    // send EOI cmd for slave
    outb(EOI_CMD, IO1_8259PIC1);                    // send EOI cmd for master
c010124b:	5d                   	pop    %ebp
c010124c:	c3                   	ret    
c010124d:	90                   	nop

c010124e <_ZN3RTC12clInteStatusEv>:
    outb(regA, RTC_DATA_PORT1);                     // write A

    clInteStatus();                                 // clear Interrupt status
}

void RTC::clInteStatus() {
c010124e:	55                   	push   %ebp
c010124f:	b0 0c                	mov    $0xc,%al
c0101251:	89 e5                	mov    %esp,%ebp
c0101253:	ba 70 00 00 00       	mov    $0x70,%edx
c0101258:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c0101259:	ba 71 00 00 00       	mov    $0x71,%edx
c010125e:	ec                   	in     (%dx),%al
    outb(RTC_REG_C, RTC_INDEX_PORT1);               // choice reg C
    inb(RTC_DATA_PORT1);                            // read regC to clear interrupt status
c010125f:	5d                   	pop    %ebp
c0101260:	c3                   	ret    
c0101261:	90                   	nop

c0101262 <_ZN3RTC9initClockEv>:
void RTC::initClock() {
c0101262:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c0101263:	b0 8b                	mov    $0x8b,%al
c0101265:	89 e5                	mov    %esp,%ebp
c0101267:	53                   	push   %ebx
c0101268:	bb 70 00 00 00       	mov    $0x70,%ebx
c010126d:	89 da                	mov    %ebx,%edx
c010126f:	ee                   	out    %al,(%dx)
c0101270:	b9 71 00 00 00       	mov    $0x71,%ecx
c0101275:	b0 42                	mov    $0x42,%al
c0101277:	89 ca                	mov    %ecx,%edx
c0101279:	ee                   	out    %al,(%dx)
c010127a:	b0 0a                	mov    $0xa,%al
c010127c:	89 da                	mov    %ebx,%edx
c010127e:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c010127f:	89 ca                	mov    %ecx,%edx
c0101281:	ec                   	in     (%dx),%al
    regA = (regA & 0xF0) | 0x2;                     // 7.8125ms
c0101282:	24 f0                	and    $0xf0,%al
c0101284:	0c 02                	or     $0x2,%al
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c0101286:	ee                   	out    %al,(%dx)
}
c0101287:	5b                   	pop    %ebx
c0101288:	5d                   	pop    %ebp
    clInteStatus();                                 // clear Interrupt status
c0101289:	eb c3                	jmp    c010124e <_ZN3RTC12clInteStatusEv>
c010128b:	90                   	nop

c010128c <_ZN11VideoMemoryC1Ev>:
#include <vdieomemory.h>

VideoMemory::VideoMemory() {
c010128c:	55                   	push   %ebp
c010128d:	89 e5                	mov    %esp,%ebp
c010128f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101292:	c7 00 00 80 0b c0    	movl   $0xc00b8000,(%eax)
c0101298:	66 c7 40 04 a0 0f    	movw   $0xfa0,0x4(%eax)

}
c010129e:	5d                   	pop    %ebp
c010129f:	c3                   	ret    

c01012a0 <_ZN11VideoMemory10initVmBuffEv>:

void VideoMemory::initVmBuff() {
c01012a0:	55                   	push   %ebp
    for (uint32_t i = 0; i < VGA_BUFF_SIZE; i++) {
c01012a1:	31 c0                	xor    %eax,%eax
void VideoMemory::initVmBuff() {
c01012a3:	89 e5                	mov    %esp,%ebp
c01012a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
        vmBuffer[i] = 0;
c01012a8:	8b 11                	mov    (%ecx),%edx
c01012aa:	c6 04 02 00          	movb   $0x0,(%edx,%eax,1)
    for (uint32_t i = 0; i < VGA_BUFF_SIZE; i++) {
c01012ae:	40                   	inc    %eax
c01012af:	3d a0 0f 00 00       	cmp    $0xfa0,%eax
c01012b4:	75 f2                	jne    c01012a8 <_ZN11VideoMemory10initVmBuffEv+0x8>
    }
}
c01012b6:	5d                   	pop    %ebp
c01012b7:	c3                   	ret    

c01012b8 <_ZN11VideoMemory12getCursorPosEv>:

uint16_t VideoMemory::getCursorPos() {
c01012b8:	55                   	push   %ebp
c01012b9:	b0 0f                	mov    $0xf,%al
c01012bb:	89 e5                	mov    %esp,%ebp
c01012bd:	56                   	push   %esi
c01012be:	be d4 03 00 00       	mov    $0x3d4,%esi
c01012c3:	53                   	push   %ebx
c01012c4:	89 f2                	mov    %esi,%edx
c01012c6:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c01012c7:	bb d5 03 00 00       	mov    $0x3d5,%ebx
c01012cc:	89 da                	mov    %ebx,%edx
c01012ce:	ec                   	in     (%dx),%al
c01012cf:	0f b6 c8             	movzbl %al,%ecx
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c01012d2:	89 f2                	mov    %esi,%edx
c01012d4:	b0 0e                	mov    $0xe,%al
c01012d6:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c01012d7:	89 da                	mov    %ebx,%edx
c01012d9:	ec                   	in     (%dx),%al
    outb(VGA_CURSOR_PORT_D, VGA_INDEX_PORT);
    uint8_t low = inb(VGA_DATA_PORT);
    outb(VGA_CURSOR_PORT_H, VGA_INDEX_PORT);
    uint16_t pos = inb(VGA_DATA_PORT);
    return (pos << 8) + low;
}
c01012da:	5b                   	pop    %ebx
    uint16_t pos = inb(VGA_DATA_PORT);
c01012db:	0f b6 c0             	movzbl %al,%eax
    return (pos << 8) + low;
c01012de:	c1 e0 08             	shl    $0x8,%eax
}
c01012e1:	5e                   	pop    %esi
    return (pos << 8) + low;
c01012e2:	01 c8                	add    %ecx,%eax
}
c01012e4:	5d                   	pop    %ebp
c01012e5:	c3                   	ret    

c01012e6 <_ZN11VideoMemory12setCursorPosEt>:

void VideoMemory::setCursorPos(uint16_t pos) {
c01012e6:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c01012e7:	b0 0f                	mov    $0xf,%al
c01012e9:	89 e5                	mov    %esp,%ebp
c01012eb:	56                   	push   %esi
c01012ec:	be d4 03 00 00       	mov    $0x3d4,%esi
c01012f1:	0f b7 4d 0c          	movzwl 0xc(%ebp),%ecx
c01012f5:	53                   	push   %ebx
c01012f6:	89 f2                	mov    %esi,%edx
c01012f8:	ee                   	out    %al,(%dx)
c01012f9:	bb d5 03 00 00       	mov    $0x3d5,%ebx
c01012fe:	88 c8                	mov    %cl,%al
c0101300:	89 da                	mov    %ebx,%edx
c0101302:	ee                   	out    %al,(%dx)
c0101303:	b0 0e                	mov    $0xe,%al
c0101305:	89 f2                	mov    %esi,%edx
c0101307:	ee                   	out    %al,(%dx)
    outb(VGA_CURSOR_PORT_D, VGA_INDEX_PORT);
    outb((pos & 0xFF), VGA_DATA_PORT);
    outb(VGA_CURSOR_PORT_H, VGA_INDEX_PORT);
    outb(((pos >> 8) & 0xFF), VGA_DATA_PORT);
c0101308:	89 c8                	mov    %ecx,%eax
c010130a:	89 da                	mov    %ebx,%edx
c010130c:	c1 e8 08             	shr    $0x8,%eax
c010130f:	ee                   	out    %al,(%dx)
}
c0101310:	5b                   	pop    %ebx
c0101311:	5e                   	pop    %esi
c0101312:	5d                   	pop    %ebp
c0101313:	c3                   	ret    

c0101314 <_ZN3IDE7isValidEj>:
    // enable ide interrupt
    PIC::enableIRQ(IRQ_IDE1);
    PIC::enableIRQ(IRQ_IDE2);
}

bool IDE::isValid(uint32_t ideno) {
c0101314:	55                   	push   %ebp
c0101315:	31 c0                	xor    %eax,%eax
c0101317:	89 e5                	mov    %esp,%ebp
c0101319:	8b 55 08             	mov    0x8(%ebp),%edx
c010131c:	e8 95 fd ff ff       	call   c01010b6 <__x86.get_pc_thunk.cx>
c0101321:	81 c1 ff d0 01 00    	add    $0x1d0ff,%ecx
    return ((ideno) >= 0) && ((ideno) < MAX_IDE) && (ideDevs[ideno].valid);
c0101327:	83 fa 03             	cmp    $0x3,%edx
c010132a:	77 0f                	ja     c010133b <_ZN3IDE7isValidEj+0x27>
c010132c:	6b d2 32             	imul   $0x32,%edx,%edx
c010132f:	81 c2 a0 10 12 c0    	add    $0xc01210a0,%edx
c0101335:	80 3a 00             	cmpb   $0x0,(%edx)
c0101338:	0f 95 c0             	setne  %al
}
c010133b:	5d                   	pop    %ebp
c010133c:	c3                   	ret    
c010133d:	90                   	nop

c010133e <_ZN3IDE9waitReadyEtb>:

uint32_t IDE::waitReady(uint16_t iobase, bool check) {
c010133e:	55                   	push   %ebp
c010133f:	89 e5                	mov    %esp,%ebp
c0101341:	0f b7 55 08          	movzwl 0x8(%ebp),%edx
c0101345:	8a 4d 0c             	mov    0xc(%ebp),%cl
    uint32_t r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0101348:	83 c2 07             	add    $0x7,%edx
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c010134b:	ec                   	in     (%dx),%al
c010134c:	84 c0                	test   %al,%al
c010134e:	78 fb                	js     c010134b <_ZN3IDE9waitReadyEtb+0xd>
        /* nothing */;
    if (check && (r & (IDE_DF | IDE_ERR)) != 0) {
        return -1;
    }
    return 0;
c0101350:	31 d2                	xor    %edx,%edx
    if (check && (r & (IDE_DF | IDE_ERR)) != 0) {
c0101352:	84 c9                	test   %cl,%cl
c0101354:	74 09                	je     c010135f <_ZN3IDE9waitReadyEtb+0x21>
c0101356:	31 d2                	xor    %edx,%edx
c0101358:	a8 21                	test   $0x21,%al
c010135a:	0f 95 c2             	setne  %dl
c010135d:	f7 da                	neg    %edx
}
c010135f:	89 d0                	mov    %edx,%eax
c0101361:	5d                   	pop    %ebp
c0101362:	c3                   	ret    
c0101363:	90                   	nop

c0101364 <_ZN3IDE4initEv>:
void IDE::init() {
c0101364:	55                   	push   %ebp
c0101365:	89 e5                	mov    %esp,%ebp
c0101367:	57                   	push   %edi
c0101368:	56                   	push   %esi
c0101369:	53                   	push   %ebx
c010136a:	e8 51 f8 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c010136f:	81 c3 b1 d0 01 00    	add    $0x1d0b1,%ebx
c0101375:	81 ec 4c 04 00 00    	sub    $0x44c,%esp
c010137b:	c6 85 bf fb ff ff 00 	movb   $0x0,-0x441(%ebp)
c0101382:	c7 85 c0 fb ff ff 00 	movl   $0x0,-0x440(%ebp)
c0101389:	00 00 00 
c010138c:	c7 c0 a0 10 12 c0    	mov    $0xc01210a0,%eax
c0101392:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
        iobase = IO_BASE(ideno);
c0101398:	c7 c0 38 4c 10 c0    	mov    $0xc0104c38,%eax
c010139e:	89 85 b8 fb ff ff    	mov    %eax,-0x448(%ebp)
        ideDevs[ideno].valid = 0;
c01013a4:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
        iobase = IO_BASE(ideno);
c01013aa:	8b 8d b8 fb ff ff    	mov    -0x448(%ebp),%ecx
        ideDevs[ideno].valid = 0;
c01013b0:	c6 00 00             	movb   $0x0,(%eax)
        iobase = IO_BASE(ideno);
c01013b3:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c01013b9:	d1 f8                	sar    %eax
c01013bb:	0f b7 34 81          	movzwl (%ecx,%eax,4),%esi
        waitReady(iobase);
c01013bf:	6a 00                	push   $0x0
c01013c1:	56                   	push   %esi
c01013c2:	e8 77 ff ff ff       	call   c010133e <_ZN3IDE9waitReadyEtb>
        outb(0xE0 | ((ideno & 1) << 4), iobase + ISA_SDH);
c01013c7:	8a 85 bf fb ff ff    	mov    -0x441(%ebp),%al
c01013cd:	8d 56 06             	lea    0x6(%esi),%edx
c01013d0:	24 10                	and    $0x10,%al
c01013d2:	0c e0                	or     $0xe0,%al
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c01013d4:	ee                   	out    %al,(%dx)
        waitReady(iobase);
c01013d5:	6a 00                	push   $0x0
c01013d7:	56                   	push   %esi
c01013d8:	e8 61 ff ff ff       	call   c010133e <_ZN3IDE9waitReadyEtb>
        outb(IDE_CMD_IDENTIFY, iobase + ISA_COMMAND);
c01013dd:	8d 56 07             	lea    0x7(%esi),%edx
c01013e0:	b0 ec                	mov    $0xec,%al
c01013e2:	0f b7 d2             	movzwl %dx,%edx
c01013e5:	ee                   	out    %al,(%dx)
        waitReady(iobase);
c01013e6:	6a 00                	push   $0x0
c01013e8:	56                   	push   %esi
c01013e9:	89 95 b4 fb ff ff    	mov    %edx,-0x44c(%ebp)
c01013ef:	e8 4a ff ff ff       	call   c010133e <_ZN3IDE9waitReadyEtb>
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c01013f4:	8b 95 b4 fb ff ff    	mov    -0x44c(%ebp),%edx
c01013fa:	ec                   	in     (%dx),%al
        if (inb(iobase + ISA_STATUS) == 0 || waitReady(iobase, true) != 0) {
c01013fb:	83 c4 18             	add    $0x18,%esp
c01013fe:	84 c0                	test   %al,%al
c0101400:	0f 84 37 02 00 00    	je     c010163d <_ZN3IDE4initEv+0x2d9>
c0101406:	6a 01                	push   $0x1
c0101408:	56                   	push   %esi
c0101409:	e8 30 ff ff ff       	call   c010133e <_ZN3IDE9waitReadyEtb>
c010140e:	59                   	pop    %ecx
c010140f:	5f                   	pop    %edi
c0101410:	85 c0                	test   %eax,%eax
c0101412:	0f 85 25 02 00 00    	jne    c010163d <_ZN3IDE4initEv+0x2d9>
        ideDevs[ideno].valid = 1;
c0101418:	8b 8d c4 fb ff ff    	mov    -0x43c(%ebp),%ecx
        : "memory", "cc");
c010141e:	8d bd e0 fb ff ff    	lea    -0x420(%ebp),%edi
c0101424:	89 f2                	mov    %esi,%edx
c0101426:	c6 01 01             	movb   $0x1,(%ecx)
c0101429:	b9 80 00 00 00       	mov    $0x80,%ecx
c010142e:	fc                   	cld    
c010142f:	f2 6d                	repnz insl (%dx),%es:(%edi)
        uint32_t cmdsets = *(uint32_t *)(ident + IDE_IDENT_CMDSETS);
c0101431:	8b 8d 84 fc ff ff    	mov    -0x37c(%ebp),%ecx
        if (cmdsets & (1 << 26)) {
c0101437:	0f ba e1 1a          	bt     $0x1a,%ecx
c010143b:	73 08                	jae    c0101445 <_ZN3IDE4initEv+0xe1>
            sectors = *(uint32_t *)(ident + IDE_IDENT_MAX_LBA_EXT);
c010143d:	8b 95 a8 fc ff ff    	mov    -0x358(%ebp),%edx
c0101443:	eb 06                	jmp    c010144b <_ZN3IDE4initEv+0xe7>
            sectors = *(uint32_t *)(ident + IDE_IDENT_MAX_LBA);
c0101445:	8b 95 58 fc ff ff    	mov    -0x3a8(%ebp),%edx
        ideDevs[ideno].sets = cmdsets;
c010144b:	8b bd c4 fb ff ff    	mov    -0x43c(%ebp),%edi
        assert((*(uint16_t *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0101451:	f6 85 43 fc ff ff 02 	testb  $0x2,-0x3bd(%ebp)
        ideDevs[ideno].sets = cmdsets;
c0101458:	89 4f 01             	mov    %ecx,0x1(%edi)
        ideDevs[ideno].size = sectors;
c010145b:	89 57 05             	mov    %edx,0x5(%edi)
        assert((*(uint16_t *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c010145e:	0f 85 9e 00 00 00    	jne    c0101502 <_ZN3IDE4initEv+0x19e>
c0101464:	89 85 b0 fb ff ff    	mov    %eax,-0x450(%ebp)
c010146a:	8d 93 51 67 fe ff    	lea    -0x198af(%ebx),%edx
c0101470:	50                   	push   %eax
c0101471:	50                   	push   %eax
c0101472:	52                   	push   %edx
c0101473:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c0101479:	56                   	push   %esi
c010147a:	e8 1b 36 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010147f:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0101485:	58                   	pop    %eax
c0101486:	5a                   	pop    %edx
c0101487:	8d 93 5b 67 fe ff    	lea    -0x198a5(%ebx),%edx
c010148d:	52                   	push   %edx
c010148e:	8d 95 d3 fb ff ff    	lea    -0x42d(%ebp),%edx
c0101494:	52                   	push   %edx
c0101495:	89 95 b4 fb ff ff    	mov    %edx,-0x44c(%ebp)
c010149b:	e8 fa 35 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01014a0:	8b 95 b4 fb ff ff    	mov    -0x44c(%ebp),%edx
c01014a6:	83 c4 0c             	add    $0xc,%esp
c01014a9:	56                   	push   %esi
c01014aa:	52                   	push   %edx
c01014ab:	57                   	push   %edi
c01014ac:	e8 0f 06 00 00       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c01014b1:	8b 95 b4 fb ff ff    	mov    -0x44c(%ebp),%edx
c01014b7:	89 14 24             	mov    %edx,(%esp)
c01014ba:	e8 f5 35 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01014bf:	89 34 24             	mov    %esi,(%esp)
c01014c2:	e8 ed 35 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01014c7:	8d 93 6c 67 fe ff    	lea    -0x19894(%ebx),%edx
c01014cd:	59                   	pop    %ecx
c01014ce:	58                   	pop    %eax
c01014cf:	52                   	push   %edx
c01014d0:	56                   	push   %esi
c01014d1:	e8 c4 35 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01014d6:	58                   	pop    %eax
c01014d7:	5a                   	pop    %edx
c01014d8:	56                   	push   %esi
c01014d9:	57                   	push   %edi
c01014da:	e8 2f 07 00 00       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01014df:	89 34 24             	mov    %esi,(%esp)
c01014e2:	e8 cd 35 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01014e7:	89 3c 24             	mov    %edi,(%esp)
c01014ea:	e8 6b 06 00 00       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01014ef:	fa                   	cli    
    );
}

static inline void
hlt() {
    asm volatile ("hlt");
c01014f0:	f4                   	hlt    
c01014f1:	89 3c 24             	mov    %edi,(%esp)
c01014f4:	e8 a5 06 00 00       	call   c0101b9e <_ZN7OStreamD1Ev>
c01014f9:	8b 85 b0 fb ff ff    	mov    -0x450(%ebp),%eax
c01014ff:	83 c4 10             	add    $0x10,%esp
c0101502:	8b 8d c4 fb ff ff    	mov    -0x43c(%ebp),%ecx
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101508:	8d b5 17 fc ff ff    	lea    -0x3e9(%ebp),%esi
c010150e:	8d bd 16 fc ff ff    	lea    -0x3ea(%ebp),%edi
c0101514:	8d 51 09             	lea    0x9(%ecx),%edx
c0101517:	8a 0c 06             	mov    (%esi,%eax,1),%cl
c010151a:	88 0c 02             	mov    %cl,(%edx,%eax,1)
c010151d:	8a 0c 07             	mov    (%edi,%eax,1),%cl
c0101520:	88 4c 02 01          	mov    %cl,0x1(%edx,%eax,1)
        for (i = 0; i < length; i += 2) {
c0101524:	83 c0 02             	add    $0x2,%eax
c0101527:	83 f8 28             	cmp    $0x28,%eax
c010152a:	75 eb                	jne    c0101517 <_ZN3IDE4initEv+0x1b3>
c010152c:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0101532:	83 c0 31             	add    $0x31,%eax
        } while (i -- > 0 && model[i] == ' ');
c0101535:	39 d0                	cmp    %edx,%eax
            model[i] = '\0';
c0101537:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c010153a:	74 06                	je     c0101542 <_ZN3IDE4initEv+0x1de>
c010153c:	48                   	dec    %eax
c010153d:	80 38 20             	cmpb   $0x20,(%eax)
c0101540:	74 f3                	je     c0101535 <_ZN3IDE4initEv+0x1d1>
        OStream out("\nide", "blue");
c0101542:	50                   	push   %eax
c0101543:	50                   	push   %eax
c0101544:	8d 83 36 67 fe ff    	lea    -0x198ca(%ebx),%eax
c010154a:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c0101550:	50                   	push   %eax
c0101551:	56                   	push   %esi
c0101552:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0101558:	89 95 b0 fb ff ff    	mov    %edx,-0x450(%ebp)
c010155e:	e8 37 35 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0101563:	8d 83 a9 67 fe ff    	lea    -0x19857(%ebx),%eax
c0101569:	5a                   	pop    %edx
c010156a:	59                   	pop    %ecx
c010156b:	50                   	push   %eax
c010156c:	8d 85 d3 fb ff ff    	lea    -0x42d(%ebp),%eax
c0101572:	50                   	push   %eax
c0101573:	89 85 b4 fb ff ff    	mov    %eax,-0x44c(%ebp)
c0101579:	e8 1c 35 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010157e:	8b 85 b4 fb ff ff    	mov    -0x44c(%ebp),%eax
c0101584:	83 c4 0c             	add    $0xc,%esp
c0101587:	56                   	push   %esi
c0101588:	50                   	push   %eax
c0101589:	57                   	push   %edi
c010158a:	e8 31 05 00 00       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c010158f:	8b 85 b4 fb ff ff    	mov    -0x44c(%ebp),%eax
c0101595:	89 04 24             	mov    %eax,(%esp)
c0101598:	e8 17 35 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010159d:	89 34 24             	mov    %esi,(%esp)
c01015a0:	e8 0f 35 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
        out.writeValue(ideno);
c01015a5:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c01015ab:	89 85 d8 fb ff ff    	mov    %eax,-0x428(%ebp)
c01015b1:	58                   	pop    %eax
c01015b2:	5a                   	pop    %edx
c01015b3:	56                   	push   %esi
c01015b4:	57                   	push   %edi
c01015b5:	e8 98 06 00 00       	call   c0101c52 <_ZN7OStream10writeValueERKj>
        out.write(": ");
c01015ba:	59                   	pop    %ecx
c01015bb:	58                   	pop    %eax
c01015bc:	8d 83 f8 6b fe ff    	lea    -0x19408(%ebx),%eax
c01015c2:	50                   	push   %eax
c01015c3:	56                   	push   %esi
c01015c4:	e8 d1 34 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01015c9:	58                   	pop    %eax
c01015ca:	5a                   	pop    %edx
c01015cb:	56                   	push   %esi
c01015cc:	57                   	push   %edi
c01015cd:	e8 3c 06 00 00       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01015d2:	89 34 24             	mov    %esi,(%esp)
c01015d5:	e8 da 34 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
        out.writeValue(ideDevs[ideno].size);
c01015da:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c01015e0:	59                   	pop    %ecx
c01015e1:	8b 40 05             	mov    0x5(%eax),%eax
c01015e4:	89 85 d8 fb ff ff    	mov    %eax,-0x428(%ebp)
c01015ea:	58                   	pop    %eax
c01015eb:	56                   	push   %esi
c01015ec:	57                   	push   %edi
c01015ed:	e8 60 06 00 00       	call   c0101c52 <_ZN7OStream10writeValueERKj>
        out.write(", model: ");
c01015f2:	58                   	pop    %eax
c01015f3:	8d 83 ae 67 fe ff    	lea    -0x19852(%ebx),%eax
c01015f9:	5a                   	pop    %edx
c01015fa:	50                   	push   %eax
c01015fb:	56                   	push   %esi
c01015fc:	e8 99 34 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0101601:	59                   	pop    %ecx
c0101602:	58                   	pop    %eax
c0101603:	56                   	push   %esi
c0101604:	57                   	push   %edi
c0101605:	e8 04 06 00 00       	call   c0101c0e <_ZN7OStream5writeERK6String>
c010160a:	89 34 24             	mov    %esi,(%esp)
c010160d:	e8 a2 34 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
        String temp((ccstring)(ideDevs[ideno].model)); 
c0101612:	58                   	pop    %eax
c0101613:	5a                   	pop    %edx
c0101614:	8b 95 b0 fb ff ff    	mov    -0x450(%ebp),%edx
c010161a:	52                   	push   %edx
c010161b:	56                   	push   %esi
c010161c:	e8 79 34 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
        out.write(temp);
c0101621:	59                   	pop    %ecx
c0101622:	58                   	pop    %eax
c0101623:	56                   	push   %esi
c0101624:	57                   	push   %edi
c0101625:	e8 e4 05 00 00       	call   c0101c0e <_ZN7OStream5writeERK6String>
        String temp((ccstring)(ideDevs[ideno].model)); 
c010162a:	89 34 24             	mov    %esi,(%esp)
c010162d:	e8 82 34 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
        OStream out("\nide", "blue");
c0101632:	89 3c 24             	mov    %edi,(%esp)
c0101635:	e8 64 05 00 00       	call   c0101b9e <_ZN7OStreamD1Ev>
c010163a:	83 c4 10             	add    $0x10,%esp
c010163d:	ff 85 c0 fb ff ff    	incl   -0x440(%ebp)
c0101643:	83 85 c4 fb ff ff 32 	addl   $0x32,-0x43c(%ebp)
c010164a:	80 85 bf fb ff ff 10 	addb   $0x10,-0x441(%ebp)
    for (ideno = 0; ideno < MAX_IDE; ideno++) {
c0101651:	83 bd c0 fb ff ff 04 	cmpl   $0x4,-0x440(%ebp)
c0101658:	0f 85 46 fd ff ff    	jne    c01013a4 <_ZN3IDE4initEv+0x40>
    PIC::enableIRQ(IRQ_IDE1);
c010165e:	83 ec 0c             	sub    $0xc,%esp
c0101661:	6a 0e                	push   $0xe
c0101663:	e8 88 fb ff ff       	call   c01011f0 <_ZN3PIC9enableIRQEj>
    PIC::enableIRQ(IRQ_IDE2);
c0101668:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c010166f:	e8 7c fb ff ff       	call   c01011f0 <_ZN3PIC9enableIRQEj>
}
c0101674:	83 c4 10             	add    $0x10,%esp
c0101677:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010167a:	5b                   	pop    %ebx
c010167b:	5e                   	pop    %esi
c010167c:	5f                   	pop    %edi
c010167d:	5d                   	pop    %ebp
c010167e:	c3                   	ret    
c010167f:	90                   	nop

c0101680 <_ZN3IDE8readSecsEtjPvj>:

uint32_t IDE::readSecs(uint16_t ideno, uint32_t secno, void *dst, uint32_t nsecs) {
c0101680:	55                   	push   %ebp
c0101681:	89 e5                	mov    %esp,%ebp
c0101683:	57                   	push   %edi
c0101684:	56                   	push   %esi
c0101685:	53                   	push   %ebx
c0101686:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
c010168c:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
c0101690:	e8 2b f5 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0101695:	81 c3 8b cd 01 00    	add    $0x1cd8b,%ebx
    assert(nsecs <= MAX_NSECS && isValid(ideno));
c010169b:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
uint32_t IDE::readSecs(uint16_t ideno, uint32_t secno, void *dst, uint32_t nsecs) {
c01016a2:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
    assert(nsecs <= MAX_NSECS && isValid(ideno));
c01016a8:	77 0f                	ja     c01016b9 <_ZN3IDE8readSecsEtjPvj+0x39>
c01016aa:	50                   	push   %eax
c01016ab:	e8 64 fc ff ff       	call   c0101314 <_ZN3IDE7isValidEj>
c01016b0:	59                   	pop    %ecx
c01016b1:	84 c0                	test   %al,%al
c01016b3:	0f 85 92 00 00 00    	jne    c010174b <_ZN3IDE8readSecsEtjPvj+0xcb>
c01016b9:	50                   	push   %eax
c01016ba:	50                   	push   %eax
c01016bb:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c01016c1:	50                   	push   %eax
c01016c2:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01016c8:	56                   	push   %esi
c01016c9:	e8 cc 33 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01016ce:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01016d4:	58                   	pop    %eax
c01016d5:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c01016db:	5a                   	pop    %edx
c01016dc:	50                   	push   %eax
c01016dd:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c01016e3:	50                   	push   %eax
c01016e4:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c01016ea:	e8 ab 33 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01016ef:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01016f5:	83 c4 0c             	add    $0xc,%esp
c01016f8:	56                   	push   %esi
c01016f9:	50                   	push   %eax
c01016fa:	57                   	push   %edi
c01016fb:	e8 c0 03 00 00       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0101700:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0101706:	89 04 24             	mov    %eax,(%esp)
c0101709:	e8 a6 33 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010170e:	89 34 24             	mov    %esi,(%esp)
c0101711:	e8 9e 33 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0101716:	59                   	pop    %ecx
c0101717:	58                   	pop    %eax
c0101718:	8d 83 b8 67 fe ff    	lea    -0x19848(%ebx),%eax
c010171e:	50                   	push   %eax
c010171f:	56                   	push   %esi
c0101720:	e8 75 33 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0101725:	58                   	pop    %eax
c0101726:	5a                   	pop    %edx
c0101727:	56                   	push   %esi
c0101728:	57                   	push   %edi
c0101729:	e8 e0 04 00 00       	call   c0101c0e <_ZN7OStream5writeERK6String>
c010172e:	89 34 24             	mov    %esi,(%esp)
c0101731:	e8 7e 33 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0101736:	89 3c 24             	mov    %edi,(%esp)
c0101739:	e8 1c 04 00 00       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010173e:	fa                   	cli    
    asm volatile ("hlt");
c010173f:	f4                   	hlt    
c0101740:	89 3c 24             	mov    %edi,(%esp)
c0101743:	e8 56 04 00 00       	call   c0101b9e <_ZN7OStreamD1Ev>
c0101748:	83 c4 10             	add    $0x10,%esp
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010174b:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101752:	77 11                	ja     c0101765 <_ZN3IDE8readSecsEtjPvj+0xe5>
c0101754:	8b 45 14             	mov    0x14(%ebp),%eax
c0101757:	03 45 0c             	add    0xc(%ebp),%eax
c010175a:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010175f:	0f 86 92 00 00 00    	jbe    c01017f7 <_ZN3IDE8readSecsEtjPvj+0x177>
c0101765:	51                   	push   %ecx
c0101766:	51                   	push   %ecx
c0101767:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c010176d:	50                   	push   %eax
c010176e:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0101774:	56                   	push   %esi
c0101775:	e8 20 33 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010177a:	5f                   	pop    %edi
c010177b:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0101781:	58                   	pop    %eax
c0101782:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c0101788:	50                   	push   %eax
c0101789:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c010178f:	50                   	push   %eax
c0101790:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c0101796:	e8 ff 32 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010179b:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01017a1:	83 c4 0c             	add    $0xc,%esp
c01017a4:	56                   	push   %esi
c01017a5:	50                   	push   %eax
c01017a6:	57                   	push   %edi
c01017a7:	e8 14 03 00 00       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c01017ac:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01017b2:	89 04 24             	mov    %eax,(%esp)
c01017b5:	e8 fa 32 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01017ba:	89 34 24             	mov    %esi,(%esp)
c01017bd:	e8 f2 32 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01017c2:	58                   	pop    %eax
c01017c3:	8d 83 dd 67 fe ff    	lea    -0x19823(%ebx),%eax
c01017c9:	5a                   	pop    %edx
c01017ca:	50                   	push   %eax
c01017cb:	56                   	push   %esi
c01017cc:	e8 c9 32 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01017d1:	59                   	pop    %ecx
c01017d2:	58                   	pop    %eax
c01017d3:	56                   	push   %esi
c01017d4:	57                   	push   %edi
c01017d5:	e8 34 04 00 00       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01017da:	89 34 24             	mov    %esi,(%esp)
c01017dd:	e8 d2 32 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01017e2:	89 3c 24             	mov    %edi,(%esp)
c01017e5:	e8 70 03 00 00       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01017ea:	fa                   	cli    
    asm volatile ("hlt");
c01017eb:	f4                   	hlt    
c01017ec:	89 3c 24             	mov    %edi,(%esp)
c01017ef:	e8 aa 03 00 00       	call   c0101b9e <_ZN7OStreamD1Ev>
c01017f4:	83 c4 10             	add    $0x10,%esp
    uint16_t iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c01017f7:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c01017fd:	c7 c0 38 4c 10 c0    	mov    $0xc0104c38,%eax
c0101803:	d1 fa                	sar    %edx
c0101805:	0f b7 1c 90          	movzwl (%eax,%edx,4),%ebx
c0101809:	0f b7 74 90 02       	movzwl 0x2(%eax,%edx,4),%esi

    waitReady(iobase, 0);
c010180e:	52                   	push   %edx
c010180f:	52                   	push   %edx
c0101810:	6a 00                	push   $0x0
c0101812:	53                   	push   %ebx
c0101813:	e8 26 fb ff ff       	call   c010133e <_ZN3IDE9waitReadyEtb>

    // generate interrupt
    outb(0, ioctrl + ISA_CTRL);
c0101818:	8d 56 02             	lea    0x2(%esi),%edx
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c010181b:	31 c0                	xor    %eax,%eax
c010181d:	ee                   	out    %al,(%dx)
    outb(nsecs, iobase + ISA_SECCNT);
c010181e:	8d 53 02             	lea    0x2(%ebx),%edx
c0101821:	8a 45 14             	mov    0x14(%ebp),%al
c0101824:	ee                   	out    %al,(%dx)
    outb(secno & 0xFF, iobase + ISA_SECTOR);
c0101825:	8d 53 03             	lea    0x3(%ebx),%edx
c0101828:	8a 45 0c             	mov    0xc(%ebp),%al
c010182b:	ee                   	out    %al,(%dx)
    outb((secno >> 8) & 0xFF, iobase + ISA_CYL_LO);
c010182c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010182f:	8d 53 04             	lea    0x4(%ebx),%edx
c0101832:	c1 e8 08             	shr    $0x8,%eax
c0101835:	ee                   	out    %al,(%dx)
    outb((secno >> 16) & 0xFF, iobase + ISA_CYL_HI);
c0101836:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101839:	8d 53 05             	lea    0x5(%ebx),%edx
c010183c:	c1 e8 10             	shr    $0x10,%eax
c010183f:	ee                   	out    %al,(%dx)
    outb(0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF), iobase + ISA_SDH);
c0101840:	8a 85 c4 fd ff ff    	mov    -0x23c(%ebp),%al
c0101846:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101849:	c0 e0 04             	shl    $0x4,%al
c010184c:	24 10                	and    $0x10,%al
c010184e:	c1 ea 18             	shr    $0x18,%edx
c0101851:	0c e0                	or     $0xe0,%al
c0101853:	80 e2 0f             	and    $0xf,%dl
c0101856:	08 d0                	or     %dl,%al
c0101858:	8d 53 06             	lea    0x6(%ebx),%edx
c010185b:	ee                   	out    %al,(%dx)
c010185c:	b0 20                	mov    $0x20,%al
    outb(IDE_CMD_READ, iobase + ISA_COMMAND);
c010185e:	8d 53 07             	lea    0x7(%ebx),%edx
c0101861:	ee                   	out    %al,(%dx)
c0101862:	83 c4 10             	add    $0x10,%esp

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101865:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101869:	74 2a                	je     c0101895 <_ZN3IDE8readSecsEtjPvj+0x215>
        if ((ret = waitReady(iobase, true)) != 0) {
c010186b:	50                   	push   %eax
c010186c:	50                   	push   %eax
c010186d:	6a 01                	push   $0x1
c010186f:	53                   	push   %ebx
c0101870:	e8 c9 fa ff ff       	call   c010133e <_ZN3IDE9waitReadyEtb>
c0101875:	83 c4 10             	add    $0x10,%esp
c0101878:	85 c0                	test   %eax,%eax
c010187a:	75 1b                	jne    c0101897 <_ZN3IDE8readSecsEtjPvj+0x217>
        : "memory", "cc");
c010187c:	8b 7d 10             	mov    0x10(%ebp),%edi
c010187f:	b9 80 00 00 00       	mov    $0x80,%ecx
c0101884:	89 da                	mov    %ebx,%edx
c0101886:	fc                   	cld    
c0101887:	f2 6d                	repnz insl (%dx),%es:(%edi)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c0101889:	ff 4d 14             	decl   0x14(%ebp)
c010188c:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101893:	eb d0                	jmp    c0101865 <_ZN3IDE8readSecsEtjPvj+0x1e5>
c0101895:	31 c0                	xor    %eax,%eax
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

    return ret;
}
c0101897:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010189a:	5b                   	pop    %ebx
c010189b:	5e                   	pop    %esi
c010189c:	5f                   	pop    %edi
c010189d:	5d                   	pop    %ebp
c010189e:	c3                   	ret    
c010189f:	90                   	nop

c01018a0 <_ZN3IDE9writeSecsEtjPKvj>:

uint32_t IDE::writeSecs(uint16_t ideno, uint32_t secno, const void *src, uint32_t nsecs) {
c01018a0:	55                   	push   %ebp
c01018a1:	89 e5                	mov    %esp,%ebp
c01018a3:	57                   	push   %edi
c01018a4:	56                   	push   %esi
c01018a5:	53                   	push   %ebx
c01018a6:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
c01018ac:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
c01018b0:	e8 0b f3 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c01018b5:	81 c3 6b cb 01 00    	add    $0x1cb6b,%ebx
    assert(nsecs <= MAX_NSECS && isValid(ideno));
c01018bb:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
uint32_t IDE::writeSecs(uint16_t ideno, uint32_t secno, const void *src, uint32_t nsecs) {
c01018c2:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
    assert(nsecs <= MAX_NSECS && isValid(ideno));
c01018c8:	77 0f                	ja     c01018d9 <_ZN3IDE9writeSecsEtjPKvj+0x39>
c01018ca:	50                   	push   %eax
c01018cb:	e8 44 fa ff ff       	call   c0101314 <_ZN3IDE7isValidEj>
c01018d0:	59                   	pop    %ecx
c01018d1:	84 c0                	test   %al,%al
c01018d3:	0f 85 92 00 00 00    	jne    c010196b <_ZN3IDE9writeSecsEtjPKvj+0xcb>
c01018d9:	50                   	push   %eax
c01018da:	50                   	push   %eax
c01018db:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c01018e1:	50                   	push   %eax
c01018e2:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01018e8:	56                   	push   %esi
c01018e9:	e8 ac 31 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01018ee:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01018f4:	58                   	pop    %eax
c01018f5:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c01018fb:	5a                   	pop    %edx
c01018fc:	50                   	push   %eax
c01018fd:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0101903:	50                   	push   %eax
c0101904:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c010190a:	e8 8b 31 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010190f:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0101915:	83 c4 0c             	add    $0xc,%esp
c0101918:	56                   	push   %esi
c0101919:	50                   	push   %eax
c010191a:	57                   	push   %edi
c010191b:	e8 a0 01 00 00       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0101920:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0101926:	89 04 24             	mov    %eax,(%esp)
c0101929:	e8 86 31 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010192e:	89 34 24             	mov    %esi,(%esp)
c0101931:	e8 7e 31 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0101936:	59                   	pop    %ecx
c0101937:	58                   	pop    %eax
c0101938:	8d 83 b8 67 fe ff    	lea    -0x19848(%ebx),%eax
c010193e:	50                   	push   %eax
c010193f:	56                   	push   %esi
c0101940:	e8 55 31 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0101945:	58                   	pop    %eax
c0101946:	5a                   	pop    %edx
c0101947:	56                   	push   %esi
c0101948:	57                   	push   %edi
c0101949:	e8 c0 02 00 00       	call   c0101c0e <_ZN7OStream5writeERK6String>
c010194e:	89 34 24             	mov    %esi,(%esp)
c0101951:	e8 5e 31 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0101956:	89 3c 24             	mov    %edi,(%esp)
c0101959:	e8 fc 01 00 00       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010195e:	fa                   	cli    
    asm volatile ("hlt");
c010195f:	f4                   	hlt    
c0101960:	89 3c 24             	mov    %edi,(%esp)
c0101963:	e8 36 02 00 00       	call   c0101b9e <_ZN7OStreamD1Ev>
c0101968:	83 c4 10             	add    $0x10,%esp
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010196b:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101972:	77 11                	ja     c0101985 <_ZN3IDE9writeSecsEtjPKvj+0xe5>
c0101974:	8b 45 14             	mov    0x14(%ebp),%eax
c0101977:	03 45 0c             	add    0xc(%ebp),%eax
c010197a:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010197f:	0f 86 92 00 00 00    	jbe    c0101a17 <_ZN3IDE9writeSecsEtjPKvj+0x177>
c0101985:	51                   	push   %ecx
c0101986:	51                   	push   %ecx
c0101987:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c010198d:	50                   	push   %eax
c010198e:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0101994:	56                   	push   %esi
c0101995:	e8 00 31 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010199a:	5f                   	pop    %edi
c010199b:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01019a1:	58                   	pop    %eax
c01019a2:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c01019a8:	50                   	push   %eax
c01019a9:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c01019af:	50                   	push   %eax
c01019b0:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c01019b6:	e8 df 30 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01019bb:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01019c1:	83 c4 0c             	add    $0xc,%esp
c01019c4:	56                   	push   %esi
c01019c5:	50                   	push   %eax
c01019c6:	57                   	push   %edi
c01019c7:	e8 f4 00 00 00       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c01019cc:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01019d2:	89 04 24             	mov    %eax,(%esp)
c01019d5:	e8 da 30 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01019da:	89 34 24             	mov    %esi,(%esp)
c01019dd:	e8 d2 30 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01019e2:	58                   	pop    %eax
c01019e3:	8d 83 dd 67 fe ff    	lea    -0x19823(%ebx),%eax
c01019e9:	5a                   	pop    %edx
c01019ea:	50                   	push   %eax
c01019eb:	56                   	push   %esi
c01019ec:	e8 a9 30 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01019f1:	59                   	pop    %ecx
c01019f2:	58                   	pop    %eax
c01019f3:	56                   	push   %esi
c01019f4:	57                   	push   %edi
c01019f5:	e8 14 02 00 00       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01019fa:	89 34 24             	mov    %esi,(%esp)
c01019fd:	e8 b2 30 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0101a02:	89 3c 24             	mov    %edi,(%esp)
c0101a05:	e8 50 01 00 00       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0101a0a:	fa                   	cli    
    asm volatile ("hlt");
c0101a0b:	f4                   	hlt    
c0101a0c:	89 3c 24             	mov    %edi,(%esp)
c0101a0f:	e8 8a 01 00 00       	call   c0101b9e <_ZN7OStreamD1Ev>
c0101a14:	83 c4 10             	add    $0x10,%esp
    uint16_t iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101a17:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c0101a1d:	c7 c0 38 4c 10 c0    	mov    $0xc0104c38,%eax
c0101a23:	d1 fa                	sar    %edx
c0101a25:	0f b7 1c 90          	movzwl (%eax,%edx,4),%ebx
c0101a29:	0f b7 74 90 02       	movzwl 0x2(%eax,%edx,4),%esi

    waitReady(iobase);
c0101a2e:	52                   	push   %edx
c0101a2f:	52                   	push   %edx
c0101a30:	6a 00                	push   $0x0
c0101a32:	53                   	push   %ebx
c0101a33:	e8 06 f9 ff ff       	call   c010133e <_ZN3IDE9waitReadyEtb>

    // generate interrupt
    outb(0, ioctrl + ISA_CTRL);
c0101a38:	8d 56 02             	lea    0x2(%esi),%edx
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c0101a3b:	31 c0                	xor    %eax,%eax
c0101a3d:	ee                   	out    %al,(%dx)
    outb(nsecs, iobase + ISA_SECCNT);
c0101a3e:	8d 53 02             	lea    0x2(%ebx),%edx
c0101a41:	8a 45 14             	mov    0x14(%ebp),%al
c0101a44:	ee                   	out    %al,(%dx)
    outb(secno & 0xFF, iobase + ISA_SECTOR);
c0101a45:	8d 53 03             	lea    0x3(%ebx),%edx
c0101a48:	8a 45 0c             	mov    0xc(%ebp),%al
c0101a4b:	ee                   	out    %al,(%dx)
    outb((secno >> 8) & 0xFF, iobase + ISA_CYL_LO);
c0101a4c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a4f:	8d 53 04             	lea    0x4(%ebx),%edx
c0101a52:	c1 e8 08             	shr    $0x8,%eax
c0101a55:	ee                   	out    %al,(%dx)
    outb((secno >> 16) & 0xFF, iobase + ISA_CYL_HI);
c0101a56:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101a59:	8d 53 05             	lea    0x5(%ebx),%edx
c0101a5c:	c1 e8 10             	shr    $0x10,%eax
c0101a5f:	ee                   	out    %al,(%dx)
    outb(0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF), iobase + ISA_SDH);
c0101a60:	8a 85 c4 fd ff ff    	mov    -0x23c(%ebp),%al
c0101a66:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101a69:	c0 e0 04             	shl    $0x4,%al
c0101a6c:	24 10                	and    $0x10,%al
c0101a6e:	c1 ea 18             	shr    $0x18,%edx
c0101a71:	0c e0                	or     $0xe0,%al
c0101a73:	80 e2 0f             	and    $0xf,%dl
c0101a76:	08 d0                	or     %dl,%al
c0101a78:	8d 53 06             	lea    0x6(%ebx),%edx
c0101a7b:	ee                   	out    %al,(%dx)
c0101a7c:	b0 20                	mov    $0x20,%al
    outb(IDE_CMD_READ, iobase + ISA_COMMAND);
c0101a7e:	8d 53 07             	lea    0x7(%ebx),%edx
c0101a81:	ee                   	out    %al,(%dx)
c0101a82:	83 c4 10             	add    $0x10,%esp

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101a85:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101a89:	74 2a                	je     c0101ab5 <_ZN3IDE9writeSecsEtjPKvj+0x215>
        if ((ret = waitReady(iobase, true)) != 0) {
c0101a8b:	50                   	push   %eax
c0101a8c:	50                   	push   %eax
c0101a8d:	6a 01                	push   $0x1
c0101a8f:	53                   	push   %ebx
c0101a90:	e8 a9 f8 ff ff       	call   c010133e <_ZN3IDE9waitReadyEtb>
c0101a95:	83 c4 10             	add    $0x10,%esp
c0101a98:	85 c0                	test   %eax,%eax
c0101a9a:	75 1b                	jne    c0101ab7 <_ZN3IDE9writeSecsEtjPKvj+0x217>
        : "memory", "cc");
c0101a9c:	8b 75 10             	mov    0x10(%ebp),%esi
c0101a9f:	b9 80 00 00 00       	mov    $0x80,%ecx
c0101aa4:	89 da                	mov    %ebx,%edx
c0101aa6:	fc                   	cld    
c0101aa7:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101aa9:	ff 4d 14             	decl   0x14(%ebp)
c0101aac:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101ab3:	eb d0                	jmp    c0101a85 <_ZN3IDE9writeSecsEtjPKvj+0x1e5>
c0101ab5:	31 c0                	xor    %eax,%eax
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

    return ret;
}
c0101ab7:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101aba:	5b                   	pop    %ebx
c0101abb:	5e                   	pop    %esi
c0101abc:	5f                   	pop    %edi
c0101abd:	5d                   	pop    %ebp
c0101abe:	c3                   	ret    
c0101abf:	90                   	nop

c0101ac0 <_ZN7OStreamC1E6StringS0_>:
 */

#include <ostream.h>
#include <global.h>

OStream::OStream(String str, String col) {
c0101ac0:	55                   	push   %ebp
c0101ac1:	89 e5                	mov    %esp,%ebp
c0101ac3:	57                   	push   %edi
c0101ac4:	56                   	push   %esi
c0101ac5:	53                   	push   %ebx
c0101ac6:	83 ec 24             	sub    $0x24,%esp
c0101ac9:	e8 f2 f0 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0101ace:	81 c3 52 c9 01 00    	add    $0x1c952,%ebx
c0101ad4:	8b 75 08             	mov    0x8(%ebp),%esi
    kernel::console.setColor(col);
c0101ad7:	8d 7d e3             	lea    -0x1d(%ebp),%edi
OStream::OStream(String str, String col) {
c0101ada:	8b 45 10             	mov    0x10(%ebp),%eax
c0101add:	c7 86 04 02 00 00 00 	movl   $0x200,0x204(%esi)
c0101ae4:	02 00 00 
    kernel::console.setColor(col);
c0101ae7:	8b 08                	mov    (%eax),%ecx
c0101ae9:	8a 40 04             	mov    0x4(%eax),%al
c0101aec:	57                   	push   %edi
c0101aed:	ff b3 f0 ff ff ff    	pushl  -0x10(%ebx)
c0101af3:	89 4d e3             	mov    %ecx,-0x1d(%ebp)
c0101af6:	88 45 e7             	mov    %al,-0x19(%ebp)
c0101af9:	e8 bc f1 ff ff       	call   c0100cba <_ZN7Console8setColorE6String>
c0101afe:	89 3c 24             	mov    %edi,(%esp)
c0101b01:	e8 ae 2f 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    buffPointer = 0;
c0101b06:	c7 86 00 02 00 00 00 	movl   $0x0,0x200(%esi)
c0101b0d:	00 00 00 
c0101b10:	83 c4 10             	add    $0x10,%esp
    for (; buffPointer < str.getLength(); buffPointer++) {
c0101b13:	8b be 00 02 00 00    	mov    0x200(%esi),%edi
c0101b19:	83 ec 0c             	sub    $0xc,%esp
c0101b1c:	ff 75 0c             	pushl  0xc(%ebp)
c0101b1f:	e8 d6 2f 00 00       	call   c0104afa <_ZNK6String9getLengthEv>
c0101b24:	83 c4 10             	add    $0x10,%esp
c0101b27:	0f b6 c0             	movzbl %al,%eax
c0101b2a:	39 c7                	cmp    %eax,%edi
c0101b2c:	73 24                	jae    c0101b52 <_ZN7OStreamC1E6StringS0_+0x92>
        buffer[buffPointer] = str[buffPointer];
c0101b2e:	50                   	push   %eax
c0101b2f:	50                   	push   %eax
c0101b30:	ff b6 00 02 00 00    	pushl  0x200(%esi)
c0101b36:	ff 75 0c             	pushl  0xc(%ebp)
c0101b39:	e8 02 30 00 00       	call   c0104b40 <_ZN6StringixEj>
c0101b3e:	8b 8e 00 02 00 00    	mov    0x200(%esi),%ecx
c0101b44:	8a 00                	mov    (%eax),%al
c0101b46:	88 04 0e             	mov    %al,(%esi,%ecx,1)
    for (; buffPointer < str.getLength(); buffPointer++) {
c0101b49:	41                   	inc    %ecx
c0101b4a:	89 8e 00 02 00 00    	mov    %ecx,0x200(%esi)
c0101b50:	eb be                	jmp    c0101b10 <_ZN7OStreamC1E6StringS0_+0x50>
    }
}
c0101b52:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101b55:	5b                   	pop    %ebx
c0101b56:	5e                   	pop    %esi
c0101b57:	5f                   	pop    %edi
c0101b58:	5d                   	pop    %ebp
c0101b59:	c3                   	ret    

c0101b5a <_ZN7OStream5flushEv>:

OStream::~OStream() {
    flush();
}

void OStream::flush() {
c0101b5a:	55                   	push   %ebp
c0101b5b:	89 e5                	mov    %esp,%ebp
c0101b5d:	56                   	push   %esi
c0101b5e:	53                   	push   %ebx
c0101b5f:	83 ec 14             	sub    $0x14,%esp
c0101b62:	8b 75 08             	mov    0x8(%ebp),%esi
c0101b65:	e8 56 f0 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0101b6a:	81 c3 b6 c8 01 00    	add    $0x1c8b6,%ebx
    kernel::console.wirte(buffer, buffPointer);
c0101b70:	8b 86 00 02 00 00    	mov    0x200(%esi),%eax
c0101b76:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101b7a:	8d 45 f6             	lea    -0xa(%ebp),%eax
c0101b7d:	50                   	push   %eax
c0101b7e:	56                   	push   %esi
c0101b7f:	ff b3 f0 ff ff ff    	pushl  -0x10(%ebx)
c0101b85:	e8 fc f4 ff ff       	call   c0101086 <_ZN7Console5wirteEPcRKt>
    buffPointer = 0;
}
c0101b8a:	83 c4 10             	add    $0x10,%esp
    buffPointer = 0;
c0101b8d:	c7 86 00 02 00 00 00 	movl   $0x0,0x200(%esi)
c0101b94:	00 00 00 
}
c0101b97:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101b9a:	5b                   	pop    %ebx
c0101b9b:	5e                   	pop    %esi
c0101b9c:	5d                   	pop    %ebp
c0101b9d:	c3                   	ret    

c0101b9e <_ZN7OStreamD1Ev>:
OStream::~OStream() {
c0101b9e:	55                   	push   %ebp
c0101b9f:	89 e5                	mov    %esp,%ebp
}
c0101ba1:	5d                   	pop    %ebp
    flush();
c0101ba2:	eb b6                	jmp    c0101b5a <_ZN7OStream5flushEv>

c0101ba4 <_ZN7OStream5writeERKc>:

void OStream::write(const char &c) {
c0101ba4:	55                   	push   %ebp
c0101ba5:	89 e5                	mov    %esp,%ebp
c0101ba7:	53                   	push   %ebx
c0101ba8:	50                   	push   %eax
c0101ba9:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (buffPointer + 1 > BUFFER_MAX) {
c0101bac:	8b 83 00 02 00 00    	mov    0x200(%ebx),%eax
c0101bb2:	40                   	inc    %eax
c0101bb3:	3b 83 04 02 00 00    	cmp    0x204(%ebx),%eax
c0101bb9:	76 0c                	jbe    c0101bc7 <_ZN7OStream5writeERKc+0x23>
        flush();
c0101bbb:	83 ec 0c             	sub    $0xc,%esp
c0101bbe:	53                   	push   %ebx
c0101bbf:	e8 96 ff ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
c0101bc4:	83 c4 10             	add    $0x10,%esp
    }
    buffer[buffPointer++] = c;
c0101bc7:	8b 83 00 02 00 00    	mov    0x200(%ebx),%eax
c0101bcd:	8d 50 01             	lea    0x1(%eax),%edx
c0101bd0:	89 93 00 02 00 00    	mov    %edx,0x200(%ebx)
c0101bd6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101bd9:	8a 12                	mov    (%edx),%dl
c0101bdb:	88 14 03             	mov    %dl,(%ebx,%eax,1)
}
c0101bde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101be1:	c9                   	leave  
c0101be2:	c3                   	ret    
c0101be3:	90                   	nop

c0101be4 <_ZN7OStream5writeEPKcRKj>:

void OStream::write(const char *arr, const uint32_t &len) {
c0101be4:	55                   	push   %ebp
c0101be5:	89 e5                	mov    %esp,%ebp
c0101be7:	53                   	push   %ebx
    for (uint32_t i = 0; i < len; i++) {
c0101be8:	31 db                	xor    %ebx,%ebx
void OStream::write(const char *arr, const uint32_t &len) {
c0101bea:	52                   	push   %edx
    for (uint32_t i = 0; i < len; i++) {
c0101beb:	8b 45 10             	mov    0x10(%ebp),%eax
c0101bee:	39 18                	cmp    %ebx,(%eax)
c0101bf0:	76 16                	jbe    c0101c08 <_ZN7OStream5writeEPKcRKj+0x24>
        write(arr[i]);
c0101bf2:	50                   	push   %eax
c0101bf3:	50                   	push   %eax
c0101bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101bf7:	01 d8                	add    %ebx,%eax
    for (uint32_t i = 0; i < len; i++) {
c0101bf9:	43                   	inc    %ebx
        write(arr[i]);
c0101bfa:	50                   	push   %eax
c0101bfb:	ff 75 08             	pushl  0x8(%ebp)
c0101bfe:	e8 a1 ff ff ff       	call   c0101ba4 <_ZN7OStream5writeERKc>
    for (uint32_t i = 0; i < len; i++) {
c0101c03:	83 c4 10             	add    $0x10,%esp
c0101c06:	eb e3                	jmp    c0101beb <_ZN7OStream5writeEPKcRKj+0x7>
    }
}
c0101c08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101c0b:	c9                   	leave  
c0101c0c:	c3                   	ret    
c0101c0d:	90                   	nop

c0101c0e <_ZN7OStream5writeERK6String>:

void OStream::write(const String &str) {
c0101c0e:	55                   	push   %ebp
c0101c0f:	89 e5                	mov    %esp,%ebp
c0101c11:	56                   	push   %esi
c0101c12:	53                   	push   %ebx
c0101c13:	83 ec 1c             	sub    $0x1c,%esp
c0101c16:	e8 a5 ef ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0101c1b:	81 c3 05 c8 01 00    	add    $0x1c805,%ebx
c0101c21:	8b 75 0c             	mov    0xc(%ebp),%esi
    write(str.cStr(), str.getLength());
c0101c24:	56                   	push   %esi
c0101c25:	e8 d0 2e 00 00       	call   c0104afa <_ZNK6String9getLengthEv>
c0101c2a:	89 34 24             	mov    %esi,(%esp)
c0101c2d:	0f b6 c0             	movzbl %al,%eax
c0101c30:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101c33:	e8 b8 2e 00 00       	call   c0104af0 <_ZNK6String4cStrEv>
c0101c38:	83 c4 0c             	add    $0xc,%esp
c0101c3b:	8d 55 f4             	lea    -0xc(%ebp),%edx
c0101c3e:	52                   	push   %edx
c0101c3f:	50                   	push   %eax
c0101c40:	ff 75 08             	pushl  0x8(%ebp)
c0101c43:	e8 9c ff ff ff       	call   c0101be4 <_ZN7OStream5writeEPKcRKj>
}
c0101c48:	83 c4 10             	add    $0x10,%esp
c0101c4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101c4e:	5b                   	pop    %ebx
c0101c4f:	5e                   	pop    %esi
c0101c50:	5d                   	pop    %ebp
c0101c51:	c3                   	ret    

c0101c52 <_ZN7OStream10writeValueERKj>:

void OStream::writeValue(const uint32_t &val) {
c0101c52:	55                   	push   %ebp
c0101c53:	89 e5                	mov    %esp,%ebp
c0101c55:	57                   	push   %edi
c0101c56:	56                   	push   %esi
c0101c57:	53                   	push   %ebx
c0101c58:	83 ec 3c             	sub    $0x3c,%esp
    if (val < 10) {
c0101c5b:	8b 45 0c             	mov    0xc(%ebp),%eax
void OStream::writeValue(const uint32_t &val) {
c0101c5e:	8b 75 08             	mov    0x8(%ebp),%esi
    if (val < 10) {
c0101c61:	8b 00                	mov    (%eax),%eax
c0101c63:	83 f8 09             	cmp    $0x9,%eax
c0101c66:	77 16                	ja     c0101c7e <_ZN7OStream10writeValueERKj+0x2c>
        write(val + '0');
c0101c68:	04 30                	add    $0x30,%al
c0101c6a:	52                   	push   %edx
c0101c6b:	52                   	push   %edx
c0101c6c:	88 45 c5             	mov    %al,-0x3b(%ebp)
c0101c6f:	8d 45 c5             	lea    -0x3b(%ebp),%eax
c0101c72:	50                   	push   %eax
c0101c73:	56                   	push   %esi
c0101c74:	e8 2b ff ff ff       	call   c0101ba4 <_ZN7OStream5writeERKc>
c0101c79:	83 c4 10             	add    $0x10,%esp
c0101c7c:	eb 30                	jmp    c0101cae <_ZN7OStream10writeValueERKj+0x5c>
c0101c7e:	31 db                	xor    %ebx,%ebx
c0101c80:	8d 7d c4             	lea    -0x3c(%ebp),%edi
    } else {
        uint8_t s[35];
        uint32_t temp = val, pos = 0;
        while (temp) {
            s[pos++] = temp % 10;
c0101c83:	31 d2                	xor    %edx,%edx
c0101c85:	b9 0a 00 00 00       	mov    $0xa,%ecx
c0101c8a:	f7 f1                	div    %ecx
c0101c8c:	43                   	inc    %ebx
        while (temp) {
c0101c8d:	85 c0                	test   %eax,%eax
            s[pos++] = temp % 10;
c0101c8f:	88 14 1f             	mov    %dl,(%edi,%ebx,1)
        while (temp) {
c0101c92:	75 ef                	jne    c0101c83 <_ZN7OStream10writeValueERKj+0x31>
            temp /= 10;
        }
        while (pos) {
            write(s[--pos] + '0');
c0101c94:	4b                   	dec    %ebx
c0101c95:	8a 44 1d c5          	mov    -0x3b(%ebp,%ebx,1),%al
c0101c99:	04 30                	add    $0x30,%al
c0101c9b:	88 45 c4             	mov    %al,-0x3c(%ebp)
c0101c9e:	50                   	push   %eax
c0101c9f:	50                   	push   %eax
c0101ca0:	57                   	push   %edi
c0101ca1:	56                   	push   %esi
c0101ca2:	e8 fd fe ff ff       	call   c0101ba4 <_ZN7OStream5writeERKc>
        while (pos) {
c0101ca7:	83 c4 10             	add    $0x10,%esp
c0101caa:	85 db                	test   %ebx,%ebx
c0101cac:	75 e6                	jne    c0101c94 <_ZN7OStream10writeValueERKj+0x42>
        }
    }
c0101cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101cb1:	5b                   	pop    %ebx
c0101cb2:	5e                   	pop    %esi
c0101cb3:	5f                   	pop    %edi
c0101cb4:	5d                   	pop    %ebp
c0101cb5:	c3                   	ret    

c0101cb6 <_Znwj>:
    IDE ide;

    VMM vmm;
};

void *operator new(uint32_t size) {
c0101cb6:	55                   	push   %ebp
c0101cb7:	89 e5                	mov    %esp,%ebp
c0101cb9:	53                   	push   %ebx
c0101cba:	e8 01 ef ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0101cbf:	81 c3 61 c7 01 00    	add    $0x1c761,%ebx
c0101cc5:	83 ec 0c             	sub    $0xc,%esp
    return kernel::pmm.kmalloc(size);
c0101cc8:	ff 75 08             	pushl  0x8(%ebp)
c0101ccb:	8d 83 00 2c 00 00    	lea    0x2c00(%ebx),%eax
c0101cd1:	50                   	push   %eax
c0101cd2:	e8 39 0c 00 00       	call   c0102910 <_ZN5PhyMM7kmallocEj>
}
c0101cd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101cda:	c9                   	leave  
c0101cdb:	c3                   	ret    

c0101cdc <_Znaj>:
c0101cdc:	55                   	push   %ebp
c0101cdd:	89 e5                	mov    %esp,%ebp
c0101cdf:	5d                   	pop    %ebp
c0101ce0:	eb d4                	jmp    c0101cb6 <_Znwj>

c0101ce2 <_ZnwjPv>:

void * operator new[](uint32_t size) {
    return kernel::pmm.kmalloc(size);
}

void * operator new(uint32_t size, void *ptr) {
c0101ce2:	55                   	push   %ebp
c0101ce3:	89 e5                	mov    %esp,%ebp
    return ptr;
}
c0101ce5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101ce8:	5d                   	pop    %ebp
c0101ce9:	c3                   	ret    

c0101cea <_ZnajPv>:
c0101cea:	55                   	push   %ebp
c0101ceb:	89 e5                	mov    %esp,%ebp
c0101ced:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101cf0:	5d                   	pop    %ebp
c0101cf1:	c3                   	ret    

c0101cf2 <_ZdlPv>:
c0101cf2:	55                   	push   %ebp
c0101cf3:	89 e5                	mov    %esp,%ebp
c0101cf5:	53                   	push   %ebx
c0101cf6:	e8 c5 ee ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0101cfb:	81 c3 25 c7 01 00    	add    $0x1c725,%ebx
c0101d01:	83 ec 08             	sub    $0x8,%esp
c0101d04:	68 00 10 00 00       	push   $0x1000
c0101d09:	ff 75 08             	pushl  0x8(%ebp)
c0101d0c:	8d 83 00 2c 00 00    	lea    0x2c00(%ebx),%eax
c0101d12:	50                   	push   %eax
c0101d13:	e8 04 0e 00 00       	call   c0102b1c <_ZN5PhyMM5kfreeEPvj>
c0101d18:	83 c4 10             	add    $0x10,%esp
c0101d1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101d1e:	c9                   	leave  
c0101d1f:	c3                   	ret    

c0101d20 <_ZdaPv>:
c0101d20:	55                   	push   %ebp
c0101d21:	89 e5                	mov    %esp,%ebp
c0101d23:	5d                   	pop    %ebp
c0101d24:	eb cc                	jmp    c0101cf2 <_ZdlPv>

c0101d26 <_ZN7ConsoleD1Ev>:
#include <vdieomemory.h>
#include <string.h>

#define COLOR_NUM       4

class Console : public VideoMemory {
c0101d26:	55                   	push   %ebp
c0101d27:	89 e5                	mov    %esp,%ebp
c0101d29:	57                   	push   %edi
c0101d2a:	56                   	push   %esi
c0101d2b:	53                   	push   %ebx
c0101d2c:	83 ec 0c             	sub    $0xc,%esp
c0101d2f:	e8 8c ee ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0101d34:	81 c3 ec c6 01 00    	add    $0x1c6ec,%ebx
c0101d3a:	8b 75 08             	mov    0x8(%ebp),%esi
c0101d3d:	8d 7e 06             	lea    0x6(%esi),%edi
c0101d40:	83 c6 1a             	add    $0x1a,%esi
c0101d43:	39 f7                	cmp    %esi,%edi
c0101d45:	74 11                	je     c0101d58 <_ZN7ConsoleD1Ev+0x32>
c0101d47:	83 ec 0c             	sub    $0xc,%esp
c0101d4a:	83 ee 05             	sub    $0x5,%esi
c0101d4d:	56                   	push   %esi
c0101d4e:	e8 61 2d 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0101d53:	83 c4 10             	add    $0x10,%esp
c0101d56:	eb eb                	jmp    c0101d43 <_ZN7ConsoleD1Ev+0x1d>
c0101d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101d5b:	5b                   	pop    %ebx
c0101d5c:	5e                   	pop    %esi
c0101d5d:	5f                   	pop    %edi
c0101d5e:	5d                   	pop    %ebp
c0101d5f:	c3                   	ret    

c0101d60 <_ZN5PhyMMD1Ev>:
#include <list.hpp>
#include <flags.h>

/*      physical Memory management      */

class PhyMM : public MMU {
c0101d60:	55                   	push   %ebp
c0101d61:	89 e5                	mov    %esp,%ebp
c0101d63:	53                   	push   %ebx
c0101d64:	e8 57 ee ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0101d69:	81 c3 b7 c6 01 00    	add    $0x1c6b7,%ebx
c0101d6f:	83 ec 10             	sub    $0x10,%esp
c0101d72:	8b 45 08             	mov    0x8(%ebp),%eax
#include <defs.h>
#include <mmu.h>
#include <list.hpp>
#include <string.h>

class PmmManager {
c0101d75:	83 c0 24             	add    $0x24,%eax
c0101d78:	8d 93 14 00 00 00    	lea    0x14(%ebx),%edx
c0101d7e:	89 50 fc             	mov    %edx,-0x4(%eax)
c0101d81:	50                   	push   %eax
c0101d82:	e8 2d 2d 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0101d87:	83 c4 10             	add    $0x10,%esp
c0101d8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101d8d:	c9                   	leave  
c0101d8e:	c3                   	ret    

c0101d8f <_GLOBAL__sub_I__ZN6kernel7consoleE>:
    kernel::pmm.kfree(ptr, PGSIZE);
}
 
void operator delete[](void *ptr) {
    kernel::pmm.kfree(ptr, PGSIZE);
c0101d8f:	55                   	push   %ebp
c0101d90:	89 e5                	mov    %esp,%ebp
c0101d92:	57                   	push   %edi
c0101d93:	56                   	push   %esi
c0101d94:	53                   	push   %ebx
c0101d95:	e8 26 ee ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0101d9a:	81 c3 86 c6 01 00    	add    $0x1c686,%ebx
c0101da0:	83 ec 18             	sub    $0x18,%esp
    Console console;
c0101da3:	8d b3 48 2c 00 00    	lea    0x2c48(%ebx),%esi
c0101da9:	56                   	push   %esi
c0101daa:	e8 15 ee ff ff       	call   c0100bc4 <_ZN7ConsoleC1Ev>
c0101daf:	8d bb 20 36 00 00    	lea    0x3620(%ebx),%edi
c0101db5:	83 c4 0c             	add    $0xc,%esp
c0101db8:	57                   	push   %edi
c0101db9:	56                   	push   %esi
c0101dba:	8d 83 06 39 fe ff    	lea    -0x1c6fa(%ebx),%eax
c0101dc0:	50                   	push   %eax
    PhyMM pmm;
c0101dc1:	8d b3 00 2c 00 00    	lea    0x2c00(%ebx),%esi
    Console console;
c0101dc7:	e8 e6 2b 00 00       	call   c01049b2 <__cxa_atexit>
    PhyMM pmm;
c0101dcc:	89 34 24             	mov    %esi,(%esp)
c0101dcf:	e8 98 00 00 00       	call   c0101e6c <_ZN5PhyMMC1Ev>
c0101dd4:	83 c4 0c             	add    $0xc,%esp
c0101dd7:	57                   	push   %edi
c0101dd8:	56                   	push   %esi
c0101dd9:	8d 83 40 39 fe ff    	lea    -0x1c6c0(%ebx),%eax
c0101ddf:	50                   	push   %eax
c0101de0:	e8 cd 2b 00 00       	call   c01049b2 <__cxa_atexit>
    Interrupt interrupt;
c0101de5:	8d 83 f1 2b 00 00    	lea    0x2bf1(%ebx),%eax
c0101deb:	89 04 24             	mov    %eax,(%esp)
c0101dee:	e8 cb f2 ff ff       	call   c01010be <_ZN9InterruptC1Ev>
c0101df3:	83 c4 10             	add    $0x10,%esp
        struct LHeadNode {
            DLNode *first, *last;
            uint32_t eNum;
        }__attribute__((packed));

        class NodeIterator {
c0101df6:	c7 83 e0 2b 00 00 00 	movl   $0x0,0x2be0(%ebx)
c0101dfd:	00 00 00 
        LHeadNode headNode;
};

template <typename Object>
List<Object>::List() {
    headNode.first = nullptr;
c0101e00:	c7 83 e4 2b 00 00 00 	movl   $0x0,0x2be4(%ebx)
c0101e07:	00 00 00 
    headNode.last = nullptr;
c0101e0a:	c7 83 e8 2b 00 00 00 	movl   $0x0,0x2be8(%ebx)
c0101e11:	00 00 00 
    headNode.eNum = 0;
c0101e14:	c7 83 ec 2b 00 00 00 	movl   $0x0,0x2bec(%ebx)
c0101e1b:	00 00 00 
c0101e1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101e21:	5b                   	pop    %ebx
c0101e22:	5e                   	pop    %esi
c0101e23:	5f                   	pop    %edi
c0101e24:	5d                   	pop    %ebp
c0101e25:	c3                   	ret    

c0101e26 <_ZN5Utils7roundUpEjj>:
        static void memset(uptr32_t ad, uint8_t byte, uint32_t size);


};

uint32_t Utils::roundUp(uint32_t a, uint32_t n) {
c0101e26:	55                   	push   %ebp
c0101e27:	31 d2                	xor    %edx,%edx
c0101e29:	89 e5                	mov    %esp,%ebp
c0101e2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0101e2e:	89 c8                	mov    %ecx,%eax
c0101e30:	f7 75 0c             	divl   0xc(%ebp)
    a = (a % n == 0) ? a : (a / n + 1) * n;
c0101e33:	85 d2                	test   %edx,%edx
c0101e35:	74 07                	je     c0101e3e <_ZN5Utils7roundUpEjj+0x18>
c0101e37:	8d 48 01             	lea    0x1(%eax),%ecx
c0101e3a:	0f af 4d 0c          	imul   0xc(%ebp),%ecx
    return a;
}
c0101e3e:	89 c8                	mov    %ecx,%eax
c0101e40:	5d                   	pop    %ebp
c0101e41:	c3                   	ret    

c0101e42 <_ZN5Utils9roundDownEjj>:

uint32_t Utils::roundDown(uint32_t a, uint32_t n) {
c0101e42:	55                   	push   %ebp
    return (a / n) * n;
c0101e43:	31 d2                	xor    %edx,%edx
uint32_t Utils::roundDown(uint32_t a, uint32_t n) {
c0101e45:	89 e5                	mov    %esp,%ebp
c0101e47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0101e4a:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0101e4d:	5d                   	pop    %ebp
    return (a / n) * n;
c0101e4e:	f7 f1                	div    %ecx
c0101e50:	0f af c1             	imul   %ecx,%eax
}
c0101e53:	c3                   	ret    

c0101e54 <_ZN5Utils6memsetEjhj>:

void Utils::memset(uptr32_t ad, uint8_t byte, uint32_t size) {
c0101e54:	55                   	push   %ebp
    uint8_t *p = (uint8_t *)ad;
    for (uint32_t i = 0; i < size; i++) {
c0101e55:	31 c0                	xor    %eax,%eax
void Utils::memset(uptr32_t ad, uint8_t byte, uint32_t size) {
c0101e57:	89 e5                	mov    %esp,%ebp
c0101e59:	8b 55 08             	mov    0x8(%ebp),%edx
c0101e5c:	8a 4d 0c             	mov    0xc(%ebp),%cl
    for (uint32_t i = 0; i < size; i++) {
c0101e5f:	3b 45 10             	cmp    0x10(%ebp),%eax
c0101e62:	74 06                	je     c0101e6a <_ZN5Utils6memsetEjhj+0x16>
        p[i] = byte;
c0101e64:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    for (uint32_t i = 0; i < size; i++) {
c0101e67:	40                   	inc    %eax
c0101e68:	eb f5                	jmp    c0101e5f <_ZN5Utils6memsetEjhj+0xb>
    }
}
c0101e6a:	5d                   	pop    %ebp
c0101e6b:	c3                   	ret    

c0101e6c <_ZN5PhyMMC1Ev>:
#include <kdebug.h>
#include <sync.h>
#include <ostream.h>
#include <utils.hpp>

PhyMM::PhyMM() {
c0101e6c:	55                   	push   %ebp
c0101e6d:	89 e5                	mov    %esp,%ebp
c0101e6f:	56                   	push   %esi
c0101e70:	8b 75 08             	mov    0x8(%ebp),%esi
c0101e73:	53                   	push   %ebx
c0101e74:	e8 47 ed ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0101e79:	81 c3 a7 c5 01 00    	add    $0x1c5a7,%ebx
c0101e7f:	83 ec 0c             	sub    $0xc,%esp
c0101e82:	56                   	push   %esi
c0101e83:	e8 60 28 00 00       	call   c01046e8 <_ZN3MMUC1Ev>
c0101e88:	8d 83 14 00 00 00    	lea    0x14(%ebx),%eax
c0101e8e:	89 46 20             	mov    %eax,0x20(%esi)
c0101e91:	58                   	pop    %eax
c0101e92:	8d 83 20 68 fe ff    	lea    -0x197e0(%ebx),%eax
c0101e98:	5a                   	pop    %edx
c0101e99:	50                   	push   %eax
c0101e9a:	8d 46 24             	lea    0x24(%esi),%eax
c0101e9d:	50                   	push   %eax
c0101e9e:	e8 f7 2b 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
#include <PmmManager.h>
#include <list.hpp>

// First-Fit Memory Allocation (FFMA) Algorithm

class FFMA : public PmmManager{
c0101ea3:	c7 c0 58 e4 11 c0    	mov    $0xc011e458,%eax
        pad += PGSIZE;
    }
}

uptr32_t PhyMM::vToPhyAD(uptr32_t kvAd) {
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c0101ea9:	83 c4 10             	add    $0x10,%esp
        class NodeIterator {
c0101eac:	c7 46 29 00 00 00 00 	movl   $0x0,0x29(%esi)
    headNode.first = nullptr;
c0101eb3:	c7 46 2d 00 00 00 00 	movl   $0x0,0x2d(%esi)
    headNode.last = nullptr;
c0101eba:	c7 46 31 00 00 00 00 	movl   $0x0,0x31(%esi)
c0101ec1:	83 c0 08             	add    $0x8,%eax
c0101ec4:	89 46 20             	mov    %eax,0x20(%esi)
    bootPDT = &__boot_pgdir;
c0101ec7:	c7 c0 00 f0 11 c0    	mov    $0xc011f000,%eax
    headNode.eNum = 0;
c0101ecd:	c7 46 35 00 00 00 00 	movl   $0x0,0x35(%esi)
c0101ed4:	c7 46 39 00 00 00 00 	movl   $0x0,0x39(%esi)
c0101edb:	89 46 18             	mov    %eax,0x18(%esi)
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c0101ede:	05 00 00 00 40       	add    $0x40000000,%eax
c0101ee3:	3d 00 00 00 38       	cmp    $0x38000000,%eax
c0101ee8:	76 02                	jbe    c0101eec <_ZN5PhyMMC1Ev+0x80>
        return kvAd - KERNEL_BASE;
    }
    return 0;
c0101eea:	31 c0                	xor    %eax,%eax
    bootCR3 = vToPhyAD((uptr32_t)bootPDT);
c0101eec:	c7 c2 28 1a 12 c0    	mov    $0xc0121a28,%edx
c0101ef2:	89 02                	mov    %eax,(%edx)
    stack = bootstack;
c0101ef4:	c7 c0 00 c0 11 c0    	mov    $0xc011c000,%eax
c0101efa:	89 46 10             	mov    %eax,0x10(%esi)
    stackTop = bootstacktop;
c0101efd:	c7 c0 00 e0 11 c0    	mov    $0xc011e000,%eax
c0101f03:	89 46 14             	mov    %eax,0x14(%esi)
}
c0101f06:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101f09:	5b                   	pop    %ebx
c0101f0a:	5e                   	pop    %esi
c0101f0b:	5d                   	pop    %ebp
c0101f0c:	c3                   	ret    
c0101f0d:	90                   	nop

c0101f0e <_ZN5PhyMM8initPageEv>:
void PhyMM::initPage() {
c0101f0e:	55                   	push   %ebp
c0101f0f:	89 e5                	mov    %esp,%ebp
c0101f11:	57                   	push   %edi
c0101f12:	56                   	push   %esi
c0101f13:	53                   	push   %ebx
c0101f14:	e8 a7 ec ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0101f19:	81 c3 07 c5 01 00    	add    $0x1c507,%ebx
c0101f1f:	81 ec 64 02 00 00    	sub    $0x264,%esp
    OStream out("\nMemmory Map [E820Map] begin...\n", "blue");
c0101f25:	8d b5 d8 fd ff ff    	lea    -0x228(%ebp),%esi
c0101f2b:	8d bd d3 fd ff ff    	lea    -0x22d(%ebp),%edi
c0101f31:	8d 83 36 67 fe ff    	lea    -0x198ca(%ebx),%eax
c0101f37:	50                   	push   %eax
c0101f38:	56                   	push   %esi
c0101f39:	e8 5c 2b 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0101f3e:	58                   	pop    %eax
c0101f3f:	8d 83 2f 68 fe ff    	lea    -0x197d1(%ebx),%eax
c0101f45:	5a                   	pop    %edx
c0101f46:	50                   	push   %eax
c0101f47:	57                   	push   %edi
c0101f48:	e8 4d 2b 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0101f4d:	83 c4 0c             	add    $0xc,%esp
c0101f50:	56                   	push   %esi
c0101f51:	57                   	push   %edi
c0101f52:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c0101f58:	50                   	push   %eax
c0101f59:	e8 62 fb ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0101f5e:	89 3c 24             	mov    %edi,(%esp)
c0101f61:	e8 4e 2b 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0101f66:	89 34 24             	mov    %esi,(%esp)
c0101f69:	e8 46 2b 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0101f6e:	83 c4 10             	add    $0x10,%esp
    uint64_t maxpa = 0;                                                             // size of all mem-block
c0101f71:	31 c9                	xor    %ecx,%ecx
    for (uint32_t i = 0; i < memMap->numARDS; i++) {                               // scan all of free memory block
c0101f73:	c7 85 b0 fd ff ff 00 	movl   $0x0,-0x250(%ebp)
c0101f7a:	00 00 00 
    uint64_t maxpa = 0;                                                             // size of all mem-block
c0101f7d:	c7 85 b4 fd ff ff 00 	movl   $0x0,-0x24c(%ebp)
c0101f84:	00 00 00 
    for (uint32_t i = 0; i < memMap->numARDS; i++) {                               // scan all of free memory block
c0101f87:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c0101f8d:	39 05 00 80 00 c0    	cmp    %eax,0xc0008000
c0101f93:	0f 86 e0 01 00 00    	jbe    c0102179 <_ZN5PhyMM8initPageEv+0x26b>
c0101f99:	6b c0 14             	imul   $0x14,%eax,%eax
c0101f9c:	89 8d a4 fd ff ff    	mov    %ecx,-0x25c(%ebp)
        uint64_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c0101fa2:	8b b0 04 80 00 c0    	mov    -0x3fff7ffc(%eax),%esi
c0101fa8:	8d 90 00 80 00 c0    	lea    -0x3fff8000(%eax),%edx
c0101fae:	8b b8 08 80 00 c0    	mov    -0x3fff7ff8(%eax),%edi
c0101fb4:	89 95 ac fd ff ff    	mov    %edx,-0x254(%ebp)
c0101fba:	89 85 a8 fd ff ff    	mov    %eax,-0x258(%ebp)
c0101fc0:	89 b5 c0 fd ff ff    	mov    %esi,-0x240(%ebp)
c0101fc6:	03 b0 0c 80 00 c0    	add    -0x3fff7ff4(%eax),%esi
c0101fcc:	89 bd c4 fd ff ff    	mov    %edi,-0x23c(%ebp)
c0101fd2:	13 b8 10 80 00 c0    	adc    -0x3fff7ff0(%eax),%edi
        out.write(" >> size = ");
c0101fd8:	51                   	push   %ecx
c0101fd9:	51                   	push   %ecx
        uint64_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c0101fda:	89 b5 b8 fd ff ff    	mov    %esi,-0x248(%ebp)
        out.write(" >> size = ");
c0101fe0:	8d b3 50 68 fe ff    	lea    -0x197b0(%ebx),%esi
c0101fe6:	56                   	push   %esi
c0101fe7:	8d b5 d8 fd ff ff    	lea    -0x228(%ebp),%esi
c0101fed:	56                   	push   %esi
        uint64_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c0101fee:	89 bd bc fd ff ff    	mov    %edi,-0x244(%ebp)
        out.write(" >> size = ");
c0101ff4:	e8 a1 2a 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0101ff9:	5f                   	pop    %edi
c0101ffa:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0102000:	58                   	pop    %eax
c0102001:	56                   	push   %esi
c0102002:	57                   	push   %edi
c0102003:	e8 06 fc ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0102008:	89 34 24             	mov    %esi,(%esp)
c010200b:	e8 a4 2a 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
        out.writeValue(memMap->ARDS[i].size);
c0102010:	8b 95 ac fd ff ff    	mov    -0x254(%ebp),%edx
c0102016:	58                   	pop    %eax
c0102017:	8b 52 0c             	mov    0xc(%edx),%edx
c010201a:	89 95 d8 fd ff ff    	mov    %edx,-0x228(%ebp)
c0102020:	5a                   	pop    %edx
c0102021:	56                   	push   %esi
c0102022:	57                   	push   %edi
c0102023:	e8 2a fc ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
        out.write(" range: ");
c0102028:	8d 93 5c 68 fe ff    	lea    -0x197a4(%ebx),%edx
c010202e:	59                   	pop    %ecx
c010202f:	58                   	pop    %eax
c0102030:	52                   	push   %edx
c0102031:	56                   	push   %esi
c0102032:	e8 63 2a 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102037:	58                   	pop    %eax
c0102038:	5a                   	pop    %edx
c0102039:	56                   	push   %esi
c010203a:	57                   	push   %edi
c010203b:	e8 ce fb ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0102040:	89 34 24             	mov    %esi,(%esp)
c0102043:	e8 6c 2a 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
        out.writeValue(begin);
c0102048:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c010204e:	59                   	pop    %ecx
c010204f:	89 85 d8 fd ff ff    	mov    %eax,-0x228(%ebp)
c0102055:	58                   	pop    %eax
c0102056:	56                   	push   %esi
c0102057:	57                   	push   %edi
c0102058:	e8 f5 fb ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
        out.write(" ~ ");
c010205d:	58                   	pop    %eax
c010205e:	5a                   	pop    %edx
c010205f:	8d 93 65 68 fe ff    	lea    -0x1979b(%ebx),%edx
c0102065:	52                   	push   %edx
c0102066:	56                   	push   %esi
c0102067:	e8 2e 2a 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010206c:	59                   	pop    %ecx
c010206d:	58                   	pop    %eax
c010206e:	56                   	push   %esi
c010206f:	57                   	push   %edi
c0102070:	e8 99 fb ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0102075:	89 34 24             	mov    %esi,(%esp)
c0102078:	e8 37 2a 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
        out.writeValue(end - 1);
c010207d:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
c0102083:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102086:	58                   	pop    %eax
c0102087:	89 95 d8 fd ff ff    	mov    %edx,-0x228(%ebp)
c010208d:	5a                   	pop    %edx
c010208e:	56                   	push   %esi
c010208f:	57                   	push   %edi
c0102090:	e8 bd fb ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
        out.write(" type = ");
c0102095:	8d 93 69 68 fe ff    	lea    -0x19797(%ebx),%edx
c010209b:	59                   	pop    %ecx
c010209c:	58                   	pop    %eax
c010209d:	52                   	push   %edx
c010209e:	56                   	push   %esi
c010209f:	e8 f6 29 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01020a4:	58                   	pop    %eax
c01020a5:	5a                   	pop    %edx
c01020a6:	56                   	push   %esi
c01020a7:	57                   	push   %edi
c01020a8:	e8 61 fb ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01020ad:	89 34 24             	mov    %esi,(%esp)
c01020b0:	e8 ff 29 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
        out.writeValue(memMap->ARDS[i].type);
c01020b5:	8b 85 a8 fd ff ff    	mov    -0x258(%ebp),%eax
c01020bb:	59                   	pop    %ecx
c01020bc:	8b 90 14 80 00 c0    	mov    -0x3fff7fec(%eax),%edx
c01020c2:	89 85 ac fd ff ff    	mov    %eax,-0x254(%ebp)
c01020c8:	58                   	pop    %eax
c01020c9:	89 95 d8 fd ff ff    	mov    %edx,-0x228(%ebp)
c01020cf:	56                   	push   %esi
c01020d0:	57                   	push   %edi
c01020d1:	e8 7c fb ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
        if (memMap->ARDS[i].type == E820_ARM) {                                    // is ARM Area
c01020d6:	8b 85 ac fd ff ff    	mov    -0x254(%ebp),%eax
c01020dc:	83 c4 10             	add    $0x10,%esp
c01020df:	8b 8d a4 fd ff ff    	mov    -0x25c(%ebp),%ecx
c01020e5:	83 b8 14 80 00 c0 01 	cmpl   $0x1,-0x3fff7fec(%eax)
c01020ec:	75 45                	jne    c0102133 <_ZN5PhyMM8initPageEv+0x225>
            if (maxpa < end && begin < KERNEL_MEM_SIZE) {
c01020ee:	8b bd bc fd ff ff    	mov    -0x244(%ebp),%edi
c01020f4:	39 bd b4 fd ff ff    	cmp    %edi,-0x24c(%ebp)
c01020fa:	72 0a                	jb     c0102106 <_ZN5PhyMM8initPageEv+0x1f8>
c01020fc:	77 35                	ja     c0102133 <_ZN5PhyMM8initPageEv+0x225>
c01020fe:	3b 8d b8 fd ff ff    	cmp    -0x248(%ebp),%ecx
c0102104:	73 2d                	jae    c0102133 <_ZN5PhyMM8initPageEv+0x225>
c0102106:	83 bd c4 fd ff ff 00 	cmpl   $0x0,-0x23c(%ebp)
c010210d:	77 24                	ja     c0102133 <_ZN5PhyMM8initPageEv+0x225>
c010210f:	81 bd c0 fd ff ff ff 	cmpl   $0x37ffffff,-0x240(%ebp)
c0102116:	ff ff 37 
c0102119:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
c010211f:	0f 47 85 b4 fd ff ff 	cmova  -0x24c(%ebp),%eax
c0102126:	0f 46 8d b8 fd ff ff 	cmovbe -0x248(%ebp),%ecx
c010212d:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
        out.write("\n");
c0102133:	50                   	push   %eax
c0102134:	50                   	push   %eax
c0102135:	8d 83 4f 67 fe ff    	lea    -0x198b1(%ebx),%eax
c010213b:	50                   	push   %eax
c010213c:	8d b5 d8 fd ff ff    	lea    -0x228(%ebp),%esi
c0102142:	56                   	push   %esi
c0102143:	89 8d c0 fd ff ff    	mov    %ecx,-0x240(%ebp)
c0102149:	e8 4c 29 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010214e:	58                   	pop    %eax
c010214f:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c0102155:	5a                   	pop    %edx
c0102156:	56                   	push   %esi
c0102157:	50                   	push   %eax
c0102158:	e8 b1 fa ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c010215d:	89 34 24             	mov    %esi,(%esp)
c0102160:	e8 4f 29 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    for (uint32_t i = 0; i < memMap->numARDS; i++) {                               // scan all of free memory block
c0102165:	83 c4 10             	add    $0x10,%esp
c0102168:	8b 8d c0 fd ff ff    	mov    -0x240(%ebp),%ecx
c010216e:	ff 85 b0 fd ff ff    	incl   -0x250(%ebp)
c0102174:	e9 0e fe ff ff       	jmp    c0101f87 <_ZN5PhyMM8initPageEv+0x79>
    numPage = maxpa / PGSIZE;          // get number of page
c0102179:	8b bd b4 fd ff ff    	mov    -0x24c(%ebp),%edi
c010217f:	89 ce                	mov    %ecx,%esi
c0102181:	83 ff 00             	cmp    $0x0,%edi
c0102184:	77 08                	ja     c010218e <_ZN5PhyMM8initPageEv+0x280>
c0102186:	81 f9 00 00 00 38    	cmp    $0x38000000,%ecx
c010218c:	76 07                	jbe    c0102195 <_ZN5PhyMM8initPageEv+0x287>
c010218e:	be 00 00 00 38       	mov    $0x38000000,%esi
c0102193:	31 ff                	xor    %edi,%edi
c0102195:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0102198:	89 f0                	mov    %esi,%eax
c010219a:	0f ac f8 0c          	shrd   $0xc,%edi,%eax
c010219e:	89 41 1c             	mov    %eax,0x1c(%ecx)
    out.write("\n numPage = ");
c01021a1:	8d 83 72 68 fe ff    	lea    -0x1978e(%ebx),%eax
c01021a7:	56                   	push   %esi
c01021a8:	56                   	push   %esi
c01021a9:	50                   	push   %eax
c01021aa:	8d b5 d8 fd ff ff    	lea    -0x228(%ebp),%esi
c01021b0:	56                   	push   %esi
c01021b1:	e8 e4 28 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01021b6:	5f                   	pop    %edi
c01021b7:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01021bd:	58                   	pop    %eax
c01021be:	56                   	push   %esi
c01021bf:	57                   	push   %edi
c01021c0:	e8 49 fa ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01021c5:	89 34 24             	mov    %esi,(%esp)
c01021c8:	e8 e7 28 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue(numPage);
c01021cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01021d0:	8b 40 1c             	mov    0x1c(%eax),%eax
c01021d3:	89 85 d8 fd ff ff    	mov    %eax,-0x228(%ebp)
c01021d9:	58                   	pop    %eax
c01021da:	5a                   	pop    %edx
c01021db:	56                   	push   %esi
c01021dc:	57                   	push   %edi
c01021dd:	e8 70 fa ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    pNodeArr = (List<Page>::DLNode *)Utils::roundUp((uint32_t)end, PGSIZE);
c01021e2:	59                   	pop    %ecx
c01021e3:	58                   	pop    %eax
c01021e4:	68 00 10 00 00       	push   $0x1000
c01021e9:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
c01021ef:	e8 32 fc ff ff       	call   c0101e26 <_ZN5Utils7roundUpEjj>
c01021f4:	5a                   	pop    %edx
c01021f5:	59                   	pop    %ecx
c01021f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
c01021f9:	89 41 41             	mov    %eax,0x41(%ecx)
    out.write("\n pNodeArr = ");
c01021fc:	8d 83 7f 68 fe ff    	lea    -0x19781(%ebx),%eax
c0102202:	50                   	push   %eax
c0102203:	56                   	push   %esi
c0102204:	e8 91 28 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102209:	58                   	pop    %eax
c010220a:	5a                   	pop    %edx
c010220b:	56                   	push   %esi
c010220c:	57                   	push   %edi
c010220d:	e8 fc f9 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0102212:	89 34 24             	mov    %esi,(%esp)
c0102215:	e8 9a 28 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue((uint32_t)pNodeArr);
c010221a:	8b 45 08             	mov    0x8(%ebp),%eax
c010221d:	59                   	pop    %ecx
c010221e:	8b 40 41             	mov    0x41(%eax),%eax
c0102221:	89 85 d8 fd ff ff    	mov    %eax,-0x228(%ebp)
c0102227:	58                   	pop    %eax
c0102228:	56                   	push   %esi
c0102229:	57                   	push   %edi
    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c010222a:	31 ff                	xor    %edi,%edi
    out.writeValue((uint32_t)pNodeArr);
c010222c:	e8 21 fa ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
c0102231:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c0102234:	8b 45 08             	mov    0x8(%ebp),%eax
c0102237:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010223a:	8b 40 1c             	mov    0x1c(%eax),%eax
c010223d:	8b 51 41             	mov    0x41(%ecx),%edx
c0102240:	39 f8                	cmp    %edi,%eax
c0102242:	76 14                	jbe    c0102258 <_ZN5PhyMM8initPageEv+0x34a>
        setPageReserved(pNodeArr[i].data);
c0102244:	6b c7 11             	imul   $0x11,%edi,%eax
c0102247:	83 ec 0c             	sub    $0xc,%esp
    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c010224a:	47                   	inc    %edi
        setPageReserved(pNodeArr[i].data);
c010224b:	01 c2                	add    %eax,%edx
c010224d:	52                   	push   %edx
c010224e:	e8 75 26 00 00       	call   c01048c8 <_ZN3MMU15setPageReservedERNS_4PageE>
    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c0102253:	83 c4 10             	add    $0x10,%esp
c0102256:	eb dc                	jmp    c0102234 <_ZN5PhyMM8initPageEv+0x326>
    uptr32_t freeMem = vToPhyAD((uptr32_t)(pNodeArr + numPage));
c0102258:	6b c0 11             	imul   $0x11,%eax,%eax
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c010225b:	8d bc 02 00 00 00 40 	lea    0x40000000(%edx,%eax,1),%edi
c0102262:	81 ff 00 00 00 38    	cmp    $0x38000000,%edi
c0102268:	76 02                	jbe    c010226c <_ZN5PhyMM8initPageEv+0x35e>
    return 0;
c010226a:	31 ff                	xor    %edi,%edi
    out.write("\n freeMem = ");
c010226c:	51                   	push   %ecx
c010226d:	51                   	push   %ecx
c010226e:	8d 83 8d 68 fe ff    	lea    -0x19773(%ebx),%eax
c0102274:	50                   	push   %eax
c0102275:	56                   	push   %esi
c0102276:	e8 1f 28 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010227b:	58                   	pop    %eax
c010227c:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c0102282:	5a                   	pop    %edx
c0102283:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c0102289:	56                   	push   %esi
c010228a:	50                   	push   %eax
c010228b:	e8 7e f9 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0102290:	89 34 24             	mov    %esi,(%esp)
c0102293:	e8 1c 28 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue((uint32_t)freeMem);
c0102298:	59                   	pop    %ecx
c0102299:	89 bd d8 fd ff ff    	mov    %edi,-0x228(%ebp)
c010229f:	58                   	pop    %eax
c01022a0:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01022a6:	56                   	push   %esi
    for (uint32_t i = 0; i < memMap->numARDS; i++) {
c01022a7:	31 f6                	xor    %esi,%esi
    out.writeValue((uint32_t)freeMem);
c01022a9:	50                   	push   %eax
c01022aa:	e8 a3 f9 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    out.flush();
c01022af:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01022b5:	89 04 24             	mov    %eax,(%esp)
c01022b8:	e8 9d f8 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
c01022bd:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 0; i < memMap->numARDS; i++) {
c01022c0:	39 35 00 80 00 c0    	cmp    %esi,0xc0008000
c01022c6:	0f 86 90 00 00 00    	jbe    c010235c <_ZN5PhyMM8initPageEv+0x44e>
        if (memMap->ARDS[i].type == E820_ARM) {                                    // is ARM Area
c01022cc:	6b c6 14             	imul   $0x14,%esi,%eax
c01022cf:	83 b8 14 80 00 c0 01 	cmpl   $0x1,-0x3fff7fec(%eax)
c01022d6:	8d 88 00 80 00 c0    	lea    -0x3fff8000(%eax),%ecx
c01022dc:	75 78                	jne    c0102356 <_ZN5PhyMM8initPageEv+0x448>
        uptr32_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c01022de:	8b 90 04 80 00 c0    	mov    -0x3fff7ffc(%eax),%edx
c01022e4:	89 f8                	mov    %edi,%eax
c01022e6:	39 fa                	cmp    %edi,%edx
c01022e8:	0f 43 c2             	cmovae %edx,%eax
c01022eb:	03 51 0c             	add    0xc(%ecx),%edx
c01022ee:	b9 00 00 00 38       	mov    $0x38000000,%ecx
c01022f3:	81 fa 00 00 00 38    	cmp    $0x38000000,%edx
c01022f9:	0f 47 d1             	cmova  %ecx,%edx
            if (begin < end) {
c01022fc:	39 c2                	cmp    %eax,%edx
c01022fe:	89 95 c0 fd ff ff    	mov    %edx,-0x240(%ebp)
c0102304:	76 50                	jbe    c0102356 <_ZN5PhyMM8initPageEv+0x448>
                begin = Utils::roundUp(begin, PGSIZE);
c0102306:	52                   	push   %edx
c0102307:	52                   	push   %edx
c0102308:	68 00 10 00 00       	push   $0x1000
c010230d:	50                   	push   %eax
c010230e:	e8 13 fb ff ff       	call   c0101e26 <_ZN5Utils7roundUpEjj>
    return (a / n) * n;
c0102313:	8b 95 c0 fd ff ff    	mov    -0x240(%ebp),%edx
c0102319:	83 c4 10             	add    $0x10,%esp
c010231c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
                if (begin < end) {
c0102322:	39 c2                	cmp    %eax,%edx
c0102324:	76 30                	jbe    c0102356 <_ZN5PhyMM8initPageEv+0x448>
                    manager->initMemMap(phyADtoPage(begin), (end - begin) / PGSIZE);
c0102326:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0102329:	29 c2                	sub    %eax,%edx
c010232b:	83 ec 04             	sub    $0x4,%esp
c010232e:	c1 ea 0c             	shr    $0xc,%edx
    }
    return 0;
}

List<MMU::Page>::DLNode * PhyMM::phyADtoPage(uptr32_t pAd) {
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
c0102331:	c1 e8 0c             	shr    $0xc,%eax
    return &(pNodeArr[pIndex]);
c0102334:	6b c0 11             	imul   $0x11,%eax,%eax
                    manager->initMemMap(phyADtoPage(begin), (end - begin) / PGSIZE);
c0102337:	8b 49 3d             	mov    0x3d(%ecx),%ecx
c010233a:	89 8d c0 fd ff ff    	mov    %ecx,-0x240(%ebp)
c0102340:	8b 09                	mov    (%ecx),%ecx
c0102342:	52                   	push   %edx
    return &(pNodeArr[pIndex]);
c0102343:	8b 55 08             	mov    0x8(%ebp),%edx
c0102346:	03 42 41             	add    0x41(%edx),%eax
                    manager->initMemMap(phyADtoPage(begin), (end - begin) / PGSIZE);
c0102349:	50                   	push   %eax
c010234a:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c0102350:	ff 51 04             	call   *0x4(%ecx)
c0102353:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 0; i < memMap->numARDS; i++) {
c0102356:	46                   	inc    %esi
c0102357:	e9 64 ff ff ff       	jmp    c01022c0 <_ZN5PhyMM8initPageEv+0x3b2>
    OStream out("\nMemmory Map [E820Map] begin...\n", "blue");
c010235c:	83 ec 0c             	sub    $0xc,%esp
c010235f:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c0102365:	50                   	push   %eax
c0102366:	e8 33 f8 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
}
c010236b:	83 c4 10             	add    $0x10,%esp
c010236e:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102371:	5b                   	pop    %ebx
c0102372:	5e                   	pop    %esi
c0102373:	5f                   	pop    %edi
c0102374:	5d                   	pop    %ebp
c0102375:	c3                   	ret    

c0102376 <_ZN5PhyMM13initGDTAndTSSEv>:
void PhyMM::initGDTAndTSS() {
c0102376:	55                   	push   %ebp
c0102377:	89 e5                	mov    %esp,%ebp
c0102379:	57                   	push   %edi
c010237a:	56                   	push   %esi
c010237b:	53                   	push   %ebx
c010237c:	e8 3f e8 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0102381:	81 c3 9f c0 01 00    	add    $0x1c09f,%ebx
c0102387:	83 ec 28             	sub    $0x28,%esp
    tss.ts_esp0 = (uptr32_t)stackTop;
c010238a:	8b 45 08             	mov    0x8(%ebp),%eax
    GDT[SEG_KTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_KERNEL);
c010238d:	8d 7d e0             	lea    -0x20(%ebp),%edi
    tss.ts_esp0 = (uptr32_t)stackTop;
c0102390:	8b 40 14             	mov    0x14(%eax),%eax
c0102393:	c7 c1 c0 19 12 c0    	mov    $0xc01219c0,%ecx
    GDT[0] = SEG_NULL;
c0102399:	c7 c6 80 11 12 c0    	mov    $0xc0121180,%esi
    tss.ts_esp0 = (uptr32_t)stackTop;
c010239f:	89 41 04             	mov    %eax,0x4(%ecx)
    tss.ts_ss0 = KERNEL_DS;
c01023a2:	66 c7 41 08 10 00    	movw   $0x10,0x8(%ecx)
    GDT[SEG_KTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_KERNEL);
c01023a8:	6a 00                	push   $0x0
c01023aa:	6a ff                	push   $0xffffffff
c01023ac:	6a 00                	push   $0x0
c01023ae:	6a 0a                	push   $0xa
c01023b0:	57                   	push   %edi
    tss.ts_ss0 = KERNEL_DS;
c01023b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    GDT[0] = SEG_NULL;
c01023b4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
c01023ba:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
    GDT[SEG_KTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_KERNEL);
c01023c1:	e8 28 23 00 00       	call   c01046ee <_ZN3MMU10setSegDescEjjjj>
c01023c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01023c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01023cc:	89 46 08             	mov    %eax,0x8(%esi)
c01023cf:	89 56 0c             	mov    %edx,0xc(%esi)
    GDT[SEG_KDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_KERNEL);
c01023d2:	6a 00                	push   $0x0
c01023d4:	6a ff                	push   $0xffffffff
c01023d6:	6a 00                	push   $0x0
c01023d8:	6a 02                	push   $0x2
c01023da:	57                   	push   %edi
c01023db:	e8 0e 23 00 00       	call   c01046ee <_ZN3MMU10setSegDescEjjjj>
c01023e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01023e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01023e6:	89 46 10             	mov    %eax,0x10(%esi)
c01023e9:	89 56 14             	mov    %edx,0x14(%esi)
    GDT[SEG_UTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_USER);
c01023ec:	83 c4 20             	add    $0x20,%esp
c01023ef:	6a 03                	push   $0x3
c01023f1:	6a ff                	push   $0xffffffff
c01023f3:	6a 00                	push   $0x0
c01023f5:	6a 0a                	push   $0xa
c01023f7:	57                   	push   %edi
c01023f8:	e8 f1 22 00 00       	call   c01046ee <_ZN3MMU10setSegDescEjjjj>
c01023fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102400:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102403:	89 46 18             	mov    %eax,0x18(%esi)
c0102406:	89 56 1c             	mov    %edx,0x1c(%esi)
    GDT[SEG_UDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_USER);
c0102409:	6a 03                	push   $0x3
c010240b:	6a ff                	push   $0xffffffff
c010240d:	6a 00                	push   $0x0
c010240f:	6a 02                	push   $0x2
c0102411:	57                   	push   %edi
c0102412:	e8 d7 22 00 00       	call   c01046ee <_ZN3MMU10setSegDescEjjjj>
    GDT[SEG_TSS] = setTssDesc(STS_T32A, (uptr32_t)(&tss), sizeof(tss), DPL_KERNEL);
c0102417:	8b 4d dc             	mov    -0x24(%ebp),%ecx
    GDT[SEG_UDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_USER);
c010241a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010241d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102420:	89 46 20             	mov    %eax,0x20(%esi)
    GDT[SEG_TSS] = setTssDesc(STS_T32A, (uptr32_t)(&tss), sizeof(tss), DPL_KERNEL);
c0102423:	83 c4 20             	add    $0x20,%esp
c0102426:	6a 00                	push   $0x0
c0102428:	6a 68                	push   $0x68
c010242a:	51                   	push   %ecx
c010242b:	6a 09                	push   $0x9
c010242d:	57                   	push   %edi
    GDT[SEG_UDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_USER);
c010242e:	89 56 24             	mov    %edx,0x24(%esi)
    GDT[SEG_TSS] = setTssDesc(STS_T32A, (uptr32_t)(&tss), sizeof(tss), DPL_KERNEL);
c0102431:	e8 b0 23 00 00       	call   c01047e6 <_ZN3MMU10setTssDescEjjjj>
c0102436:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102439:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010243c:	89 46 28             	mov    %eax,0x28(%esi)
    asm volatile ("lgdt (%0)" :: "r" (pd));
c010243f:	c7 c0 48 e4 11 c0    	mov    $0xc011e448,%eax
c0102445:	89 56 2c             	mov    %edx,0x2c(%esi)
c0102448:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%ds" :: "a" (ds));
c010244b:	b8 10 00 00 00       	mov    $0x10,%eax
c0102450:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (ss));
c0102452:	8e d0                	mov    %eax,%ss
    asm volatile ("movw %%ax, %%es" :: "a" (es));
c0102454:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%fs" :: "a" (fs));
c0102456:	b8 23 00 00 00       	mov    $0x23,%eax
c010245b:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%gs" :: "a" (gs));
c010245d:	8e e8                	mov    %eax,%gs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (cs));
c010245f:	ea 66 24 10 c0 08 00 	ljmp   $0x8,$0xc0102466
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102466:	b8 28 00 00 00       	mov    $0x28,%eax
c010246b:	0f 00 d8             	ltr    %ax
}
c010246e:	83 c4 1c             	add    $0x1c,%esp
c0102471:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102474:	5b                   	pop    %ebx
c0102475:	5e                   	pop    %esi
c0102476:	5f                   	pop    %edi
c0102477:	5d                   	pop    %ebp
c0102478:	c3                   	ret    
c0102479:	90                   	nop

c010247a <_ZN5PhyMM14initPmmManagerEv>:
void PhyMM::initPmmManager() {
c010247a:	55                   	push   %ebp
c010247b:	89 e5                	mov    %esp,%ebp
c010247d:	8b 45 08             	mov    0x8(%ebp),%eax
    manager = &ff;
c0102480:	8d 50 20             	lea    0x20(%eax),%edx
c0102483:	89 50 3d             	mov    %edx,0x3d(%eax)
}
c0102486:	5d                   	pop    %ebp
c0102487:	c3                   	ret    

c0102488 <_ZN5PhyMM8vToPhyADEj>:
uptr32_t PhyMM::vToPhyAD(uptr32_t kvAd) {
c0102488:	55                   	push   %ebp
c0102489:	89 e5                	mov    %esp,%ebp
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c010248b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010248e:	05 00 00 00 40       	add    $0x40000000,%eax
c0102493:	3d 00 00 00 38       	cmp    $0x38000000,%eax
c0102498:	76 02                	jbe    c010249c <_ZN5PhyMM8vToPhyADEj+0x14>
    return 0;
c010249a:	31 c0                	xor    %eax,%eax
}
c010249c:	5d                   	pop    %ebp
c010249d:	c3                   	ret    

c010249e <_ZN5PhyMM8pToVirADEj>:
uptr32_t PhyMM::pToVirAD(uptr32_t pAd) {
c010249e:	55                   	push   %ebp
c010249f:	89 e5                	mov    %esp,%ebp
c01024a1:	8b 55 0c             	mov    0xc(%ebp),%edx
    if (pAd <= KERNEL_MEM_SIZE) {
c01024a4:	81 fa 00 00 00 38    	cmp    $0x38000000,%edx
        return pAd + KERNEL_BASE;
c01024aa:	8d 82 00 00 00 c0    	lea    -0x40000000(%edx),%eax
    if (pAd <= KERNEL_MEM_SIZE) {
c01024b0:	76 02                	jbe    c01024b4 <_ZN5PhyMM8pToVirADEj+0x16>
c01024b2:	31 c0                	xor    %eax,%eax
}
c01024b4:	5d                   	pop    %ebp
c01024b5:	c3                   	ret    

c01024b6 <_ZN5PhyMM11phyADtoPageEj>:
List<MMU::Page>::DLNode * PhyMM::phyADtoPage(uptr32_t pAd) {
c01024b6:	55                   	push   %ebp
c01024b7:	89 e5                	mov    %esp,%ebp
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
c01024b9:	8b 45 0c             	mov    0xc(%ebp),%eax
    return &(pNodeArr[pIndex]);
c01024bc:	8b 55 08             	mov    0x8(%ebp),%edx
}
c01024bf:	5d                   	pop    %ebp
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
c01024c0:	c1 e8 0c             	shr    $0xc,%eax
    return &(pNodeArr[pIndex]);
c01024c3:	6b c0 11             	imul   $0x11,%eax,%eax
c01024c6:	03 42 41             	add    0x41(%edx),%eax
}
c01024c9:	c3                   	ret    

c01024ca <_ZN5PhyMM10pnodeToLADEPN4ListIN3MMU4PageEE6DLNodeE>:

uptr32_t PhyMM::pnodeToLAD(List<Page>::DLNode *node) {
c01024ca:	55                   	push   %ebp
c01024cb:	89 e5                	mov    %esp,%ebp
    uint32_t pageNo = node - pNodeArr;       // physical memory page NO
c01024cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01024d0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01024d3:	2b 50 41             	sub    0x41(%eax),%edx
c01024d6:	69 d2 f1 f0 f0 f0    	imul   $0xf0f0f0f1,%edx,%edx
    return pToVirAD(pageNo << PGSHIFT);
c01024dc:	c1 e2 0c             	shl    $0xc,%edx
    if (pAd <= KERNEL_MEM_SIZE) {
c01024df:	81 fa 00 00 00 38    	cmp    $0x38000000,%edx
        return pAd + KERNEL_BASE;
c01024e5:	8d 82 00 00 00 c0    	lea    -0x40000000(%edx),%eax
    if (pAd <= KERNEL_MEM_SIZE) {
c01024eb:	76 02                	jbe    c01024ef <_ZN5PhyMM10pnodeToLADEPN4ListIN3MMU4PageEE6DLNodeE+0x25>
c01024ed:	31 c0                	xor    %eax,%eax
}
c01024ef:	5d                   	pop    %ebp
c01024f0:	c3                   	ret    
c01024f1:	90                   	nop

c01024f2 <_ZN5PhyMM11pdeToPTableERKN3MMU7PTEntryE>:

MMU::PTEntry * PhyMM::pdeToPTable(const PTEntry &pte) {
c01024f2:	55                   	push   %ebp
c01024f3:	89 e5                	mov    %esp,%ebp
c01024f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    uptr32_t ptAD= pToVirAD(pte.p_ppn);
    return (PTEntry *)ptAD;
}
c01024f8:	5d                   	pop    %ebp
    uptr32_t ptAD= pToVirAD(pte.p_ppn);
c01024f9:	8a 41 01             	mov    0x1(%ecx),%al
c01024fc:	c0 e8 04             	shr    $0x4,%al
c01024ff:	0f b6 d0             	movzbl %al,%edx
c0102502:	0f b6 41 02          	movzbl 0x2(%ecx),%eax
c0102506:	c1 e0 04             	shl    $0x4,%eax
c0102509:	09 c2                	or     %eax,%edx
c010250b:	0f b6 41 03          	movzbl 0x3(%ecx),%eax
c010250f:	c1 e0 0c             	shl    $0xc,%eax
c0102512:	09 d0                	or     %edx,%eax
        return pAd + KERNEL_BASE;
c0102514:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0102519:	c3                   	ret    

c010251a <_ZN5PhyMM6getPTEERKN3MMU8LinearADEb>:
void PhyMM::setPermission(T &t, uint32_t perm) {
    uint32_t &temp =  *(uint32_t *)(&t);  // format data to uint32_t
    temp |= perm;
}

MMU::PTEntry * PhyMM::getPTE(const LinearAD &lad, bool create) {
c010251a:	55                   	push   %ebp
c010251b:	89 e5                	mov    %esp,%ebp
c010251d:	57                   	push   %edi
c010251e:	56                   	push   %esi
c010251f:	53                   	push   %ebx
c0102520:	83 ec 0c             	sub    $0xc,%esp
c0102523:	8b 75 0c             	mov    0xc(%ebp),%esi
c0102526:	8b 7d 08             	mov    0x8(%ebp),%edi
c0102529:	8a 45 10             	mov    0x10(%ebp),%al
    PTEntry &pde = bootPDT[lad.PDI];
c010252c:	8a 56 02             	mov    0x2(%esi),%dl
c010252f:	c0 ea 06             	shr    $0x6,%dl
c0102532:	0f b6 ca             	movzbl %dl,%ecx
c0102535:	0f b6 56 03          	movzbl 0x3(%esi),%edx
c0102539:	c1 e2 02             	shl    $0x2,%edx
c010253c:	09 ca                	or     %ecx,%edx
c010253e:	8b 4f 18             	mov    0x18(%edi),%ecx
c0102541:	8d 1c 91             	lea    (%ecx,%edx,4),%ebx
    if (!(pde.p_p) && create) {                          // check present bit and is create?
c0102544:	8a 13                	mov    (%ebx),%dl
c0102546:	f6 d2                	not    %dl
c0102548:	80 e2 01             	and    $0x1,%dl
c010254b:	84 d2                	test   %dl,%dl
c010254d:	74 41                	je     c0102590 <_ZN5PhyMM6getPTEERKN3MMU8LinearADEb+0x76>
c010254f:	84 c0                	test   %al,%al
c0102551:	74 3d                	je     c0102590 <_ZN5PhyMM6getPTEERKN3MMU8LinearADEb+0x76>
        /*      wait 2020.4.6      */
        List<Page>::DLNode *pnode;
        if ((pnode = manager->allocPages()) == nullptr) {
c0102553:	8b 47 3d             	mov    0x3d(%edi),%eax
c0102556:	52                   	push   %edx
c0102557:	52                   	push   %edx
c0102558:	8b 10                	mov    (%eax),%edx
c010255a:	6a 01                	push   $0x1
c010255c:	50                   	push   %eax
c010255d:	ff 52 08             	call   *0x8(%edx)
c0102560:	83 c4 10             	add    $0x10,%esp
c0102563:	89 c2                	mov    %eax,%edx
            return nullptr;
c0102565:	31 c0                	xor    %eax,%eax
        if ((pnode = manager->allocPages()) == nullptr) {
c0102567:	85 d2                	test   %edx,%edx
c0102569:	74 5c                	je     c01025c7 <_ZN5PhyMM6getPTEERKN3MMU8LinearADEb+0xad>
        }
        pnode->data.ref = 1;
c010256b:	c7 02 01 00 00 00    	movl   $0x1,(%edx)
        // clear page content
        Utils::memset(pnodeToLAD(pnode), 0, PGSIZE);
c0102571:	50                   	push   %eax
c0102572:	50                   	push   %eax
c0102573:	52                   	push   %edx
c0102574:	57                   	push   %edi
c0102575:	e8 50 ff ff ff       	call   c01024ca <_ZN5PhyMM10pnodeToLADEPN4ListIN3MMU4PageEE6DLNodeE>
c010257a:	83 c4 0c             	add    $0xc,%esp
c010257d:	68 00 10 00 00       	push   $0x1000
c0102582:	6a 00                	push   $0x0
c0102584:	50                   	push   %eax
c0102585:	e8 ca f8 ff ff       	call   c0101e54 <_ZN5Utils6memsetEjhj>
c010258a:	83 c4 10             	add    $0x10,%esp
        // set permssion
        pde.p_us = 1;
        pde.p_rw = 1;
        pde.p_p = 1;
c010258d:	80 0b 07             	orb    $0x7,(%ebx)
    uptr32_t ptAD= pToVirAD(pte.p_ppn);
c0102590:	8a 53 01             	mov    0x1(%ebx),%dl
c0102593:	c0 ea 04             	shr    $0x4,%dl
c0102596:	0f b6 c2             	movzbl %dl,%eax
c0102599:	0f b6 53 02          	movzbl 0x2(%ebx),%edx
c010259d:	c1 e2 04             	shl    $0x4,%edx
c01025a0:	09 d0                	or     %edx,%eax
c01025a2:	0f b6 53 03          	movzbl 0x3(%ebx),%edx
c01025a6:	c1 e2 0c             	shl    $0xc,%edx
c01025a9:	09 c2                	or     %eax,%edx
    }
    return &(pdeToPTable(pde)[lad.PTI]);
c01025ab:	8a 46 01             	mov    0x1(%esi),%al
c01025ae:	c0 e8 04             	shr    $0x4,%al
c01025b1:	0f b6 c8             	movzbl %al,%ecx
c01025b4:	0f b6 46 02          	movzbl 0x2(%esi),%eax
c01025b8:	83 e0 3f             	and    $0x3f,%eax
c01025bb:	c1 e0 04             	shl    $0x4,%eax
c01025be:	09 c8                	or     %ecx,%eax
c01025c0:	8d 84 82 00 00 00 c0 	lea    -0x40000000(%edx,%eax,4),%eax
}
c01025c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01025ca:	5b                   	pop    %ebx
c01025cb:	5e                   	pop    %esi
c01025cc:	5f                   	pop    %edi
c01025cd:	5d                   	pop    %ebp
c01025ce:	c3                   	ret    
c01025cf:	90                   	nop

c01025d0 <_ZN5PhyMM10mapSegmentEjjjj>:
void PhyMM::mapSegment(uptr32_t lad, uptr32_t pad, uint32_t size, uint32_t perm) {
c01025d0:	55                   	push   %ebp
c01025d1:	89 e5                	mov    %esp,%ebp
c01025d3:	57                   	push   %edi
c01025d4:	56                   	push   %esi
c01025d5:	53                   	push   %ebx
c01025d6:	e8 e5 e5 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c01025db:	81 c3 45 be 01 00    	add    $0x1be45,%ebx
c01025e1:	81 ec 54 02 00 00    	sub    $0x254,%esp
    OStream out("\nmapSegment:\n lad: ", "blue");
c01025e7:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01025ed:	8d 83 36 67 fe ff    	lea    -0x198ca(%ebx),%eax
c01025f3:	50                   	push   %eax
c01025f4:	56                   	push   %esi
c01025f5:	e8 a0 24 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01025fa:	8d 83 9a 68 fe ff    	lea    -0x19766(%ebx),%eax
c0102600:	59                   	pop    %ecx
c0102601:	5f                   	pop    %edi
c0102602:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0102608:	50                   	push   %eax
c0102609:	8d 85 d4 fd ff ff    	lea    -0x22c(%ebp),%eax
c010260f:	50                   	push   %eax
c0102610:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c0102616:	e8 7f 24 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010261b:	83 c4 0c             	add    $0xc,%esp
c010261e:	56                   	push   %esi
c010261f:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c0102625:	57                   	push   %edi
c0102626:	e8 95 f4 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c010262b:	58                   	pop    %eax
c010262c:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c0102632:	e8 7d 24 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102637:	89 34 24             	mov    %esi,(%esp)
c010263a:	e8 75 24 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue(lad);
c010263f:	58                   	pop    %eax
c0102640:	5a                   	pop    %edx
c0102641:	8d 55 0c             	lea    0xc(%ebp),%edx
c0102644:	89 95 b4 fd ff ff    	mov    %edx,-0x24c(%ebp)
c010264a:	52                   	push   %edx
c010264b:	57                   	push   %edi
c010264c:	e8 01 f6 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    out.write(" to pad: ");
c0102651:	59                   	pop    %ecx
c0102652:	58                   	pop    %eax
c0102653:	8d 83 ae 68 fe ff    	lea    -0x19752(%ebx),%eax
c0102659:	89 85 bc fd ff ff    	mov    %eax,-0x244(%ebp)
c010265f:	50                   	push   %eax
c0102660:	56                   	push   %esi
c0102661:	e8 34 24 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102666:	58                   	pop    %eax
c0102667:	5a                   	pop    %edx
c0102668:	56                   	push   %esi
c0102669:	57                   	push   %edi
c010266a:	e8 9f f5 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c010266f:	89 34 24             	mov    %esi,(%esp)
c0102672:	e8 3d 24 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue(pad);
c0102677:	59                   	pop    %ecx
c0102678:	58                   	pop    %eax
c0102679:	8d 45 10             	lea    0x10(%ebp),%eax
c010267c:	89 85 b8 fd ff ff    	mov    %eax,-0x248(%ebp)
c0102682:	50                   	push   %eax
c0102683:	57                   	push   %edi
c0102684:	e8 c9 f5 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    out.write("   size = ");
c0102689:	8d 8b b8 68 fe ff    	lea    -0x19748(%ebx),%ecx
c010268f:	58                   	pop    %eax
c0102690:	5a                   	pop    %edx
c0102691:	51                   	push   %ecx
c0102692:	56                   	push   %esi
c0102693:	e8 02 24 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102698:	59                   	pop    %ecx
c0102699:	58                   	pop    %eax
c010269a:	56                   	push   %esi
c010269b:	57                   	push   %edi
c010269c:	e8 6d f5 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01026a1:	89 34 24             	mov    %esi,(%esp)
c01026a4:	e8 0b 24 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue(size);
c01026a9:	8d 4d 14             	lea    0x14(%ebp),%ecx
c01026ac:	58                   	pop    %eax
c01026ad:	5a                   	pop    %edx
c01026ae:	51                   	push   %ecx
c01026af:	57                   	push   %edi
c01026b0:	e8 9d f5 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    out.flush();
c01026b5:	89 3c 24             	mov    %edi,(%esp)
c01026b8:	e8 9d f4 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    out.write("\n");
c01026bd:	59                   	pop    %ecx
c01026be:	8d 8b 4f 67 fe ff    	lea    -0x198b1(%ebx),%ecx
c01026c4:	58                   	pop    %eax
c01026c5:	51                   	push   %ecx
c01026c6:	56                   	push   %esi
c01026c7:	e8 ce 23 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01026cc:	58                   	pop    %eax
c01026cd:	5a                   	pop    %edx
c01026ce:	56                   	push   %esi
c01026cf:	57                   	push   %edi
c01026d0:	e8 39 f5 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01026d5:	89 34 24             	mov    %esi,(%esp)
c01026d8:	e8 d7 23 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue(lad);
c01026dd:	8b 95 b4 fd ff ff    	mov    -0x24c(%ebp),%edx
c01026e3:	59                   	pop    %ecx
c01026e4:	81 65 0c 00 f0 ff ff 	andl   $0xfffff000,0xc(%ebp)
c01026eb:	58                   	pop    %eax
c01026ec:	81 65 10 00 f0 ff ff 	andl   $0xfffff000,0x10(%ebp)
c01026f3:	52                   	push   %edx
c01026f4:	57                   	push   %edi
c01026f5:	e8 58 f5 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    out.write(" to pad: ");
c01026fa:	58                   	pop    %eax
c01026fb:	5a                   	pop    %edx
c01026fc:	ff b5 bc fd ff ff    	pushl  -0x244(%ebp)
c0102702:	56                   	push   %esi
c0102703:	e8 92 23 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102708:	59                   	pop    %ecx
c0102709:	58                   	pop    %eax
c010270a:	56                   	push   %esi
c010270b:	57                   	push   %edi
c010270c:	e8 fd f4 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0102711:	89 34 24             	mov    %esi,(%esp)
c0102714:	e8 9b 23 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue(pad);
c0102719:	58                   	pop    %eax
c010271a:	8b 85 b8 fd ff ff    	mov    -0x248(%ebp),%eax
c0102720:	5a                   	pop    %edx
c0102721:	50                   	push   %eax
c0102722:	57                   	push   %edi
c0102723:	e8 2a f5 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    out.flush();
c0102728:	89 3c 24             	mov    %edi,(%esp)
c010272b:	e8 2a f4 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    uint32_t n = Utils::roundUp(size + LAD(lad).OFF, PGSIZE) / PGSIZE;
c0102730:	83 c4 0c             	add    $0xc,%esp
c0102733:	ff 75 0c             	pushl  0xc(%ebp)
c0102736:	8d 85 c4 fd ff ff    	lea    -0x23c(%ebp),%eax
c010273c:	ff 75 08             	pushl  0x8(%ebp)
c010273f:	50                   	push   %eax
c0102740:	e8 a7 21 00 00       	call   c01048ec <_ZN3MMU3LADEj>
c0102745:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c010274b:	83 ec 0c             	sub    $0xc,%esp
c010274e:	25 ff 0f 00 00       	and    $0xfff,%eax
c0102753:	03 45 14             	add    0x14(%ebp),%eax
c0102756:	68 00 10 00 00       	push   $0x1000
c010275b:	50                   	push   %eax
c010275c:	e8 c5 f6 ff ff       	call   c0101e26 <_ZN5Utils7roundUpEjj>
c0102761:	83 c4 18             	add    $0x18,%esp
c0102764:	c1 e8 0c             	shr    $0xc,%eax
c0102767:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
    out.write("\nn = ");
c010276d:	8d 83 c3 68 fe ff    	lea    -0x1973d(%ebx),%eax
c0102773:	50                   	push   %eax
c0102774:	56                   	push   %esi
c0102775:	e8 20 23 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010277a:	59                   	pop    %ecx
c010277b:	58                   	pop    %eax
c010277c:	56                   	push   %esi
c010277d:	57                   	push   %edi
c010277e:	e8 8b f4 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0102783:	89 34 24             	mov    %esi,(%esp)
    for (uint32_t i = 0; i < n; i++) {
c0102786:	31 f6                	xor    %esi,%esi
    out.write("\nn = ");
c0102788:	e8 27 23 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue(n);
c010278d:	58                   	pop    %eax
c010278e:	5a                   	pop    %edx
c010278f:	ff b5 c0 fd ff ff    	pushl  -0x240(%ebp)
c0102795:	57                   	push   %edi
c0102796:	e8 b7 f4 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    out.flush();
c010279b:	89 3c 24             	mov    %edi,(%esp)
c010279e:	e8 b7 f3 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
c01027a3:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 0; i < n; i++) {
c01027a6:	39 b5 d4 fd ff ff    	cmp    %esi,-0x22c(%ebp)
c01027ac:	76 6e                	jbe    c010281c <_ZN5PhyMM10mapSegmentEjjjj+0x24c>
        PTEntry *pte = getPTE(LAD(lad));
c01027ae:	50                   	push   %eax
    for (uint32_t i = 0; i < n; i++) {
c01027af:	46                   	inc    %esi
        PTEntry *pte = getPTE(LAD(lad));
c01027b0:	ff 75 0c             	pushl  0xc(%ebp)
c01027b3:	8d bd db fd ff ff    	lea    -0x225(%ebp),%edi
c01027b9:	ff 75 08             	pushl  0x8(%ebp)
c01027bc:	57                   	push   %edi
c01027bd:	e8 2a 21 00 00       	call   c01048ec <_ZN3MMU3LADEj>
c01027c2:	52                   	push   %edx
c01027c3:	52                   	push   %edx
c01027c4:	6a 01                	push   $0x1
c01027c6:	57                   	push   %edi
c01027c7:	ff 75 08             	pushl  0x8(%ebp)
c01027ca:	e8 4b fd ff ff       	call   c010251a <_ZN5PhyMM6getPTEERKN3MMU8LinearADEb>
        setPermission(*pte, PTE_P | perm);
c01027cf:	8b 55 18             	mov    0x18(%ebp),%edx
    for (uint32_t i = 0; i < n; i++) {
c01027d2:	83 c4 20             	add    $0x20,%esp
        setPermission(*pte, PTE_P | perm);
c01027d5:	83 ca 01             	or     $0x1,%edx
    temp |= perm;
c01027d8:	09 10                	or     %edx,(%eax)
        pte->p_ppn = (pad >> PGSHIFT);         // set physical address (20-bits)
c01027da:	8b 55 10             	mov    0x10(%ebp),%edx
c01027dd:	89 d1                	mov    %edx,%ecx
c01027df:	c1 e9 0c             	shr    $0xc,%ecx
c01027e2:	c0 e1 04             	shl    $0x4,%cl
c01027e5:	88 8d c0 fd ff ff    	mov    %cl,-0x240(%ebp)
c01027eb:	8a 48 01             	mov    0x1(%eax),%cl
c01027ee:	80 e1 0f             	and    $0xf,%cl
c01027f1:	0a 8d c0 fd ff ff    	or     -0x240(%ebp),%cl
c01027f7:	88 48 01             	mov    %cl,0x1(%eax)
c01027fa:	89 d1                	mov    %edx,%ecx
c01027fc:	c1 e9 10             	shr    $0x10,%ecx
c01027ff:	88 48 02             	mov    %cl,0x2(%eax)
c0102802:	89 d1                	mov    %edx,%ecx
        pad += PGSIZE;
c0102804:	81 c2 00 10 00 00    	add    $0x1000,%edx
        pte->p_ppn = (pad >> PGSHIFT);         // set physical address (20-bits)
c010280a:	c1 e9 18             	shr    $0x18,%ecx
c010280d:	88 48 03             	mov    %cl,0x3(%eax)
        lad += PGSIZE;
c0102810:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
        pad += PGSIZE;
c0102817:	89 55 10             	mov    %edx,0x10(%ebp)
    for (uint32_t i = 0; i < n; i++) {
c010281a:	eb 8a                	jmp    c01027a6 <_ZN5PhyMM10mapSegmentEjjjj+0x1d6>
    OStream out("\nmapSegment:\n lad: ", "blue");
c010281c:	83 ec 0c             	sub    $0xc,%esp
c010281f:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c0102825:	50                   	push   %eax
c0102826:	e8 73 f3 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
}
c010282b:	83 c4 10             	add    $0x10,%esp
c010282e:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102831:	5b                   	pop    %ebx
c0102832:	5e                   	pop    %esi
c0102833:	5f                   	pop    %edi
c0102834:	5d                   	pop    %ebp
c0102835:	c3                   	ret    

c0102836 <_ZN5PhyMM4initEv>:
void PhyMM::init() {
c0102836:	55                   	push   %ebp
c0102837:	89 e5                	mov    %esp,%ebp
c0102839:	57                   	push   %edi
c010283a:	56                   	push   %esi
c010283b:	53                   	push   %ebx
c010283c:	83 ec 28             	sub    $0x28,%esp
c010283f:	8b 75 08             	mov    0x8(%ebp),%esi
c0102842:	e8 79 e3 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0102847:	81 c3 d9 bb 01 00    	add    $0x1bbd9,%ebx
    manager = &ff;
c010284d:	8d 46 20             	lea    0x20(%esi),%eax
c0102850:	89 46 3d             	mov    %eax,0x3d(%esi)
    initPage();
c0102853:	56                   	push   %esi
c0102854:	e8 b5 f6 ff ff       	call   c0101f0e <_ZN5PhyMM8initPageEv>
    bootPDT[LAD(VPT).PDI].p_ppn = (vToPhyAD((uptr32_t)bootPDT) >> PGSHIFT) && 0xFFFFF;
c0102859:	8b 7e 18             	mov    0x18(%esi),%edi
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c010285c:	83 c4 10             	add    $0x10,%esp
c010285f:	8d 87 00 00 00 40    	lea    0x40000000(%edi),%eax
c0102865:	3d 00 00 00 38       	cmp    $0x38000000,%eax
c010286a:	76 02                	jbe    c010286e <_ZN5PhyMM4initEv+0x38>
    return 0;
c010286c:	31 c0                	xor    %eax,%eax
    bootPDT[LAD(VPT).PDI].p_ppn = (vToPhyAD((uptr32_t)bootPDT) >> PGSHIFT) && 0xFFFFF;
c010286e:	52                   	push   %edx
c010286f:	68 00 00 c0 fa       	push   $0xfac00000
c0102874:	56                   	push   %esi
c0102875:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102878:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c010287b:	50                   	push   %eax
c010287c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010287f:	e8 68 20 00 00       	call   c01048ec <_ZN3MMU3LADEj>
c0102884:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102887:	c1 ea 16             	shr    $0x16,%edx
c010288a:	59                   	pop    %ecx
c010288b:	8a 4c 97 01          	mov    0x1(%edi,%edx,4),%cl
c010288f:	58                   	pop    %eax
c0102890:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102893:	c6 44 97 02 00       	movb   $0x0,0x2(%edi,%edx,4)
c0102898:	c6 44 97 03 00       	movb   $0x0,0x3(%edi,%edx,4)
c010289d:	c1 e8 0c             	shr    $0xc,%eax
c01028a0:	0f 95 c0             	setne  %al
c01028a3:	80 e1 0f             	and    $0xf,%cl
c01028a6:	0f b6 c0             	movzbl %al,%eax
c01028a9:	c0 e0 04             	shl    $0x4,%al
c01028ac:	08 c8                	or     %cl,%al
c01028ae:	88 44 97 01          	mov    %al,0x1(%edi,%edx,4)
    bootPDT[LAD(VPT).PDI].p_p = 1;
c01028b2:	8b 7e 18             	mov    0x18(%esi),%edi
c01028b5:	68 00 00 c0 fa       	push   $0xfac00000
c01028ba:	56                   	push   %esi
c01028bb:	ff 75 e0             	pushl  -0x20(%ebp)
c01028be:	e8 29 20 00 00       	call   c01048ec <_ZN3MMU3LADEj>
c01028c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01028c6:	c1 e8 16             	shr    $0x16,%eax
c01028c9:	80 0c 87 01          	orb    $0x1,(%edi,%eax,4)
    bootPDT[LAD(VPT).PDI].p_rw = 1;
c01028cd:	8b 7e 18             	mov    0x18(%esi),%edi
c01028d0:	50                   	push   %eax
c01028d1:	50                   	push   %eax
c01028d2:	68 00 00 c0 fa       	push   $0xfac00000
c01028d7:	56                   	push   %esi
c01028d8:	ff 75 e0             	pushl  -0x20(%ebp)
c01028db:	e8 0c 20 00 00       	call   c01048ec <_ZN3MMU3LADEj>
c01028e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01028e3:	c1 e8 16             	shr    $0x16,%eax
c01028e6:	80 0c 87 02          	orb    $0x2,(%edi,%eax,4)
    mapSegment(KERNEL_BASE, 0, KERNEL_MEM_SIZE, PTE_W);
c01028ea:	6a 02                	push   $0x2
c01028ec:	68 00 00 00 38       	push   $0x38000000
c01028f1:	6a 00                	push   $0x0
c01028f3:	68 00 00 00 c0       	push   $0xc0000000
c01028f8:	56                   	push   %esi
c01028f9:	e8 d2 fc ff ff       	call   c01025d0 <_ZN5PhyMM10mapSegmentEjjjj>
    initGDTAndTSS();
c01028fe:	83 c4 30             	add    $0x30,%esp
c0102901:	89 75 08             	mov    %esi,0x8(%ebp)
}
c0102904:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102907:	5b                   	pop    %ebx
c0102908:	5e                   	pop    %esi
c0102909:	5f                   	pop    %edi
c010290a:	5d                   	pop    %ebp
    initGDTAndTSS();
c010290b:	e9 66 fa ff ff       	jmp    c0102376 <_ZN5PhyMM13initGDTAndTSSEv>

c0102910 <_ZN5PhyMM7kmallocEj>:

void * PhyMM::kmalloc(uint32_t size) {
c0102910:	55                   	push   %ebp
c0102911:	89 e5                	mov    %esp,%ebp
c0102913:	57                   	push   %edi
c0102914:	56                   	push   %esi
c0102915:	53                   	push   %ebx
c0102916:	e8 a5 e2 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c010291b:	81 c3 05 bb 01 00    	add    $0x1bb05,%ebx
c0102921:	81 ec 44 02 00 00    	sub    $0x244,%esp
    DEBUGPRINT("PhyMM::kmalloc");
c0102927:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c010292d:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0102933:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c0102939:	50                   	push   %eax
c010293a:	56                   	push   %esi
c010293b:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c0102941:	e8 54 21 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102946:	58                   	pop    %eax
c0102947:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c010294d:	5a                   	pop    %edx
c010294e:	8d 93 c9 68 fe ff    	lea    -0x19737(%ebx),%edx
c0102954:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c010295a:	52                   	push   %edx
c010295b:	50                   	push   %eax
c010295c:	e8 39 21 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102961:	83 c4 0c             	add    $0xc,%esp
c0102964:	56                   	push   %esi
c0102965:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c010296b:	57                   	push   %edi
c010296c:	e8 4f f1 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0102971:	59                   	pop    %ecx
c0102972:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0102978:	e8 37 21 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010297d:	89 34 24             	mov    %esi,(%esp)
c0102980:	e8 2f 21 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102985:	58                   	pop    %eax
c0102986:	5a                   	pop    %edx
c0102987:	8d 93 d3 68 fe ff    	lea    -0x1972d(%ebx),%edx
c010298d:	52                   	push   %edx
c010298e:	56                   	push   %esi
c010298f:	e8 06 21 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102994:	59                   	pop    %ecx
c0102995:	58                   	pop    %eax
c0102996:	56                   	push   %esi
c0102997:	57                   	push   %edi
c0102998:	e8 71 f2 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c010299d:	89 34 24             	mov    %esi,(%esp)
c01029a0:	e8 0f 21 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01029a5:	89 3c 24             	mov    %edi,(%esp)
c01029a8:	e8 ad f1 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
c01029ad:	89 3c 24             	mov    %edi,(%esp)
c01029b0:	e8 e9 f1 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
    void * ptr = nullptr;
    List<Page>::DLNode *base = nullptr;
    assert(size > 0 && size < 1024*0124);
c01029b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01029b8:	83 c4 10             	add    $0x10,%esp
c01029bb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01029be:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01029c4:	81 fa fe 4f 01 00    	cmp    $0x14ffe,%edx
c01029ca:	76 76                	jbe    c0102a42 <_ZN5PhyMM7kmallocEj+0x132>
c01029cc:	52                   	push   %edx
c01029cd:	52                   	push   %edx
c01029ce:	50                   	push   %eax
c01029cf:	56                   	push   %esi
c01029d0:	e8 c5 20 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01029d5:	59                   	pop    %ecx
c01029d6:	58                   	pop    %eax
c01029d7:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c01029dd:	50                   	push   %eax
c01029de:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c01029e4:	e8 b1 20 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01029e9:	83 c4 0c             	add    $0xc,%esp
c01029ec:	56                   	push   %esi
c01029ed:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c01029f3:	57                   	push   %edi
c01029f4:	e8 c7 f0 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c01029f9:	58                   	pop    %eax
c01029fa:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0102a00:	e8 af 20 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102a05:	89 34 24             	mov    %esi,(%esp)
c0102a08:	e8 a7 20 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102a0d:	58                   	pop    %eax
c0102a0e:	8d 83 e2 68 fe ff    	lea    -0x1971e(%ebx),%eax
c0102a14:	5a                   	pop    %edx
c0102a15:	50                   	push   %eax
c0102a16:	56                   	push   %esi
c0102a17:	e8 7e 20 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102a1c:	59                   	pop    %ecx
c0102a1d:	58                   	pop    %eax
c0102a1e:	56                   	push   %esi
c0102a1f:	57                   	push   %edi
c0102a20:	e8 e9 f1 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0102a25:	89 34 24             	mov    %esi,(%esp)
c0102a28:	e8 87 20 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102a2d:	89 3c 24             	mov    %edi,(%esp)
c0102a30:	e8 25 f1 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0102a35:	fa                   	cli    
    asm volatile ("hlt");
c0102a36:	f4                   	hlt    
c0102a37:	89 3c 24             	mov    %edi,(%esp)
c0102a3a:	e8 5f f1 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0102a3f:	83 c4 10             	add    $0x10,%esp
    uint32_t num_pages = (size + PGSIZE - 1 ) / PGSIZE;
    base = manager->allocPages(num_pages);
c0102a42:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a45:	8b 50 3d             	mov    0x3d(%eax),%edx
c0102a48:	50                   	push   %eax
c0102a49:	50                   	push   %eax
    uint32_t num_pages = (size + PGSIZE - 1 ) / PGSIZE;
c0102a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
    base = manager->allocPages(num_pages);
c0102a4d:	8b 0a                	mov    (%edx),%ecx
    uint32_t num_pages = (size + PGSIZE - 1 ) / PGSIZE;
c0102a4f:	05 ff 0f 00 00       	add    $0xfff,%eax
c0102a54:	c1 e8 0c             	shr    $0xc,%eax
    base = manager->allocPages(num_pages);
c0102a57:	50                   	push   %eax
c0102a58:	52                   	push   %edx
c0102a59:	ff 51 08             	call   *0x8(%ecx)
    assert(base != nullptr);
c0102a5c:	83 c4 10             	add    $0x10,%esp
c0102a5f:	85 c0                	test   %eax,%eax
c0102a61:	0f 85 9e 00 00 00    	jne    c0102b05 <_ZN5PhyMM7kmallocEj+0x1f5>
c0102a67:	51                   	push   %ecx
c0102a68:	51                   	push   %ecx
c0102a69:	8d 93 51 67 fe ff    	lea    -0x198af(%ebx),%edx
c0102a6f:	52                   	push   %edx
c0102a70:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0102a76:	56                   	push   %esi
c0102a77:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c0102a7d:	e8 18 20 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102a82:	8d 93 5b 67 fe ff    	lea    -0x198a5(%ebx),%edx
c0102a88:	5f                   	pop    %edi
c0102a89:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0102a8f:	58                   	pop    %eax
c0102a90:	52                   	push   %edx
c0102a91:	8d 95 d6 fd ff ff    	lea    -0x22a(%ebp),%edx
c0102a97:	52                   	push   %edx
c0102a98:	89 95 c4 fd ff ff    	mov    %edx,-0x23c(%ebp)
c0102a9e:	e8 f7 1f 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102aa3:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c0102aa9:	83 c4 0c             	add    $0xc,%esp
c0102aac:	56                   	push   %esi
c0102aad:	52                   	push   %edx
c0102aae:	57                   	push   %edi
c0102aaf:	e8 0c f0 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0102ab4:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c0102aba:	89 14 24             	mov    %edx,(%esp)
c0102abd:	e8 f2 1f 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102ac2:	89 34 24             	mov    %esi,(%esp)
c0102ac5:	e8 ea 1f 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102aca:	58                   	pop    %eax
c0102acb:	5a                   	pop    %edx
c0102acc:	8d 93 ff 68 fe ff    	lea    -0x19701(%ebx),%edx
c0102ad2:	52                   	push   %edx
c0102ad3:	56                   	push   %esi
c0102ad4:	e8 c1 1f 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102ad9:	59                   	pop    %ecx
c0102ada:	58                   	pop    %eax
c0102adb:	56                   	push   %esi
c0102adc:	57                   	push   %edi
c0102add:	e8 2c f1 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0102ae2:	89 34 24             	mov    %esi,(%esp)
c0102ae5:	e8 ca 1f 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102aea:	89 3c 24             	mov    %edi,(%esp)
c0102aed:	e8 68 f0 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0102af2:	fa                   	cli    
    asm volatile ("hlt");
c0102af3:	f4                   	hlt    
c0102af4:	89 3c 24             	mov    %edi,(%esp)
c0102af7:	e8 a2 f0 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0102afc:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0102b02:	83 c4 10             	add    $0x10,%esp
    ptr = (void *)pnodeToLAD(base);
c0102b05:	52                   	push   %edx
c0102b06:	52                   	push   %edx
c0102b07:	50                   	push   %eax
c0102b08:	ff 75 08             	pushl  0x8(%ebp)
c0102b0b:	e8 ba f9 ff ff       	call   c01024ca <_ZN5PhyMM10pnodeToLADEPN4ListIN3MMU4PageEE6DLNodeE>
c0102b10:	83 c4 10             	add    $0x10,%esp
    return ptr;
}
c0102b13:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102b16:	5b                   	pop    %ebx
c0102b17:	5e                   	pop    %esi
c0102b18:	5f                   	pop    %edi
c0102b19:	5d                   	pop    %ebp
c0102b1a:	c3                   	ret    
c0102b1b:	90                   	nop

c0102b1c <_ZN5PhyMM5kfreeEPvj>:

void PhyMM::kfree(void *ptr, uint32_t size) {
c0102b1c:	55                   	push   %ebp
c0102b1d:	89 e5                	mov    %esp,%ebp
c0102b1f:	57                   	push   %edi
c0102b20:	56                   	push   %esi
c0102b21:	53                   	push   %ebx
c0102b22:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
    assert(size > 0 && size < 1024*0124);
c0102b28:	8b 45 10             	mov    0x10(%ebp),%eax
c0102b2b:	e8 90 e0 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0102b30:	81 c3 f0 b8 01 00    	add    $0x1b8f0,%ebx
c0102b36:	48                   	dec    %eax
c0102b37:	3d fe 4f 01 00       	cmp    $0x14ffe,%eax
c0102b3c:	0f 86 92 00 00 00    	jbe    c0102bd4 <_ZN5PhyMM5kfreeEPvj+0xb8>
c0102b42:	50                   	push   %eax
c0102b43:	50                   	push   %eax
c0102b44:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c0102b4a:	50                   	push   %eax
c0102b4b:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0102b51:	56                   	push   %esi
c0102b52:	e8 43 1f 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102b57:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0102b5d:	58                   	pop    %eax
c0102b5e:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c0102b64:	5a                   	pop    %edx
c0102b65:	50                   	push   %eax
c0102b66:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0102b6c:	50                   	push   %eax
c0102b6d:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0102b73:	e8 22 1f 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102b78:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102b7e:	83 c4 0c             	add    $0xc,%esp
c0102b81:	56                   	push   %esi
c0102b82:	50                   	push   %eax
c0102b83:	57                   	push   %edi
c0102b84:	e8 37 ef ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0102b89:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102b8f:	89 04 24             	mov    %eax,(%esp)
c0102b92:	e8 1d 1f 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102b97:	89 34 24             	mov    %esi,(%esp)
c0102b9a:	e8 15 1f 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102b9f:	59                   	pop    %ecx
c0102ba0:	58                   	pop    %eax
c0102ba1:	8d 83 e2 68 fe ff    	lea    -0x1971e(%ebx),%eax
c0102ba7:	50                   	push   %eax
c0102ba8:	56                   	push   %esi
c0102ba9:	e8 ec 1e 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102bae:	58                   	pop    %eax
c0102baf:	5a                   	pop    %edx
c0102bb0:	56                   	push   %esi
c0102bb1:	57                   	push   %edi
c0102bb2:	e8 57 f0 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0102bb7:	89 34 24             	mov    %esi,(%esp)
c0102bba:	e8 f5 1e 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102bbf:	89 3c 24             	mov    %edi,(%esp)
c0102bc2:	e8 93 ef ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0102bc7:	fa                   	cli    
    asm volatile ("hlt");
c0102bc8:	f4                   	hlt    
c0102bc9:	89 3c 24             	mov    %edi,(%esp)
c0102bcc:	e8 cd ef ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0102bd1:	83 c4 10             	add    $0x10,%esp
    assert(ptr != nullptr);
c0102bd4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102bd8:	0f 85 92 00 00 00    	jne    c0102c70 <_ZN5PhyMM5kfreeEPvj+0x154>
c0102bde:	56                   	push   %esi
c0102bdf:	56                   	push   %esi
c0102be0:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c0102be6:	50                   	push   %eax
c0102be7:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0102bed:	56                   	push   %esi
c0102bee:	e8 a7 1e 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102bf3:	5f                   	pop    %edi
c0102bf4:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0102bfa:	58                   	pop    %eax
c0102bfb:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c0102c01:	50                   	push   %eax
c0102c02:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0102c08:	50                   	push   %eax
c0102c09:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0102c0f:	e8 86 1e 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102c14:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102c1a:	83 c4 0c             	add    $0xc,%esp
c0102c1d:	56                   	push   %esi
c0102c1e:	50                   	push   %eax
c0102c1f:	57                   	push   %edi
c0102c20:	e8 9b ee ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0102c25:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102c2b:	89 04 24             	mov    %eax,(%esp)
c0102c2e:	e8 81 1e 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102c33:	89 34 24             	mov    %esi,(%esp)
c0102c36:	e8 79 1e 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102c3b:	58                   	pop    %eax
c0102c3c:	8d 83 0f 69 fe ff    	lea    -0x196f1(%ebx),%eax
c0102c42:	5a                   	pop    %edx
c0102c43:	50                   	push   %eax
c0102c44:	56                   	push   %esi
c0102c45:	e8 50 1e 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102c4a:	59                   	pop    %ecx
c0102c4b:	58                   	pop    %eax
c0102c4c:	56                   	push   %esi
c0102c4d:	57                   	push   %edi
c0102c4e:	e8 bb ef ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0102c53:	89 34 24             	mov    %esi,(%esp)
c0102c56:	e8 59 1e 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102c5b:	89 3c 24             	mov    %edi,(%esp)
c0102c5e:	e8 f7 ee ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0102c63:	fa                   	cli    
    asm volatile ("hlt");
c0102c64:	f4                   	hlt    
c0102c65:	89 3c 24             	mov    %edi,(%esp)
c0102c68:	e8 31 ef ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0102c6d:	83 c4 10             	add    $0x10,%esp
    List<Page>::DLNode *base = nullptr;
    uint32_t num_pages = (size + PGSIZE - 1) / PGSIZE;
c0102c70:	8b 45 10             	mov    0x10(%ebp),%eax
c0102c73:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c0102c79:	8b 45 0c             	mov    0xc(%ebp),%eax
    uint32_t num_pages = (size + PGSIZE - 1) / PGSIZE;
c0102c7c:	c1 eb 0c             	shr    $0xc,%ebx
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c0102c7f:	05 00 00 00 40       	add    $0x40000000,%eax
c0102c84:	3d 00 00 00 38       	cmp    $0x38000000,%eax
c0102c89:	76 02                	jbe    c0102c8d <_ZN5PhyMM5kfreeEPvj+0x171>
    return 0;
c0102c8b:	31 c0                	xor    %eax,%eax
    base = phyADtoPage(vToPhyAD((uptr32_t)ptr));
    manager->freePages(base, num_pages);
c0102c8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
c0102c90:	c1 e8 0c             	shr    $0xc,%eax
    return &(pNodeArr[pIndex]);
c0102c93:	8b 7d 08             	mov    0x8(%ebp),%edi
c0102c96:	6b c0 11             	imul   $0x11,%eax,%eax
    manager->freePages(base, num_pages);
c0102c99:	8b 51 3d             	mov    0x3d(%ecx),%edx
c0102c9c:	51                   	push   %ecx
    return &(pNodeArr[pIndex]);
c0102c9d:	03 47 41             	add    0x41(%edi),%eax
    manager->freePages(base, num_pages);
c0102ca0:	8b 0a                	mov    (%edx),%ecx
c0102ca2:	53                   	push   %ebx
c0102ca3:	50                   	push   %eax
c0102ca4:	52                   	push   %edx
c0102ca5:	ff 51 0c             	call   *0xc(%ecx)
}
c0102ca8:	83 c4 10             	add    $0x10,%esp
c0102cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102cae:	5b                   	pop    %ebx
c0102caf:	5e                   	pop    %esi
c0102cb0:	5f                   	pop    %edi
c0102cb1:	5d                   	pop    %ebp
c0102cb2:	c3                   	ret    
c0102cb3:	90                   	nop

c0102cb4 <_ZN5PhyMM12numFreePagesEv>:

uint32_t PhyMM::numFreePages() {
c0102cb4:	55                   	push   %ebp
c0102cb5:	89 e5                	mov    %esp,%ebp
c0102cb7:	53                   	push   %ebx
c0102cb8:	50                   	push   %eax
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102cb9:	9c                   	pushf  
c0102cba:	58                   	pop    %eax
c0102cbb:	31 db                	xor    %ebx,%ebx
#include <x86.h>
#include <flags.h>

static inline bool
__intr_save(void) {
    if (readEflags() & FL_IF) {
c0102cbd:	0f ba e0 09          	bt     $0x9,%eax
c0102cc1:	73 03                	jae    c0102cc6 <_ZN5PhyMM12numFreePagesEv+0x12>
    asm volatile ("cli");
c0102cc3:	fa                   	cli    
        cli();                  // clear interrupt
        return 1;
c0102cc4:	b3 01                	mov    $0x1,%bl
    uint32_t ret;
    bool intr_flag;
    local_intr_save(intr_flag); 
    {
        ret = manager->numFreePages();
c0102cc6:	8b 45 08             	mov    0x8(%ebp),%eax
c0102cc9:	83 ec 0c             	sub    $0xc,%esp
c0102ccc:	8b 40 3d             	mov    0x3d(%eax),%eax
c0102ccf:	8b 10                	mov    (%eax),%edx
c0102cd1:	50                   	push   %eax
c0102cd2:	ff 52 10             	call   *0x10(%edx)
    return 0;
}

static inline void
__intr_restore(bool flag) {
    if (flag) {
c0102cd5:	83 c4 10             	add    $0x10,%esp
c0102cd8:	84 db                	test   %bl,%bl
c0102cda:	74 01                	je     c0102cdd <_ZN5PhyMM12numFreePagesEv+0x29>
    asm volatile ("sti");
c0102cdc:	fb                   	sti    
    }
    local_intr_restore(intr_flag);
    return ret;
c0102cdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102ce0:	c9                   	leave  
c0102ce1:	c3                   	ret    

c0102ce2 <_ZN4FFMA12numFreePagesEv>:
    } else {
        freeArea.insertLNode(pnode->pre, pnArr);
    }
}

uint32_t FFMA::numFreePages() {
c0102ce2:	55                   	push   %ebp
c0102ce3:	89 e5                	mov    %esp,%ebp
    return nfp;
c0102ce5:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0102ce8:	5d                   	pop    %ebp
    return nfp;
c0102ce9:	8b 40 19             	mov    0x19(%eax),%eax
}
c0102cec:	c3                   	ret    
c0102ced:	90                   	nop

c0102cee <_ZN4FFMA4initEv>:
void FFMA::init() {
c0102cee:	55                   	push   %ebp
c0102cef:	89 e5                	mov    %esp,%ebp
c0102cf1:	53                   	push   %ebx
c0102cf2:	e8 c9 de ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0102cf7:	81 c3 29 b7 01 00    	add    $0x1b729,%ebx
c0102cfd:	83 ec 0c             	sub    $0xc,%esp
    name = "First-Fit Memory Allocation (FFMA) Algorithm";
c0102d00:	8d 83 1e 69 fe ff    	lea    -0x196e2(%ebx),%eax
c0102d06:	50                   	push   %eax
c0102d07:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d0a:	83 c0 04             	add    $0x4,%eax
c0102d0d:	50                   	push   %eax
c0102d0e:	e8 a7 1d 00 00       	call   c0104aba <_ZN6StringaSEPKc>
}
c0102d13:	83 c4 10             	add    $0x10,%esp
c0102d16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0102d19:	c9                   	leave  
c0102d1a:	c3                   	ret    
c0102d1b:	90                   	nop

c0102d1c <_ZN4FFMA10initMemMapEPN4ListIN3MMU4PageEE6DLNodeEj>:
void FFMA::initMemMap(List<MMU::Page>::DLNode *pArr, uint32_t num) {
c0102d1c:	55                   	push   %ebp
c0102d1d:	89 e5                	mov    %esp,%ebp
c0102d1f:	57                   	push   %edi
c0102d20:	56                   	push   %esi
c0102d21:	53                   	push   %ebx
c0102d22:	e8 99 de ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0102d27:	81 c3 f9 b6 01 00    	add    $0x1b6f9,%ebx
c0102d2d:	81 ec 44 02 00 00    	sub    $0x244,%esp
    OStream out("\n\ninitMemMap:\n\n firstAd = ", "red");
c0102d33:	8d b5 d8 fd ff ff    	lea    -0x228(%ebp),%esi
c0102d39:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c0102d3f:	50                   	push   %eax
c0102d40:	56                   	push   %esi
c0102d41:	e8 54 1d 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102d46:	8d 83 4b 69 fe ff    	lea    -0x196b5(%ebx),%eax
c0102d4c:	59                   	pop    %ecx
c0102d4d:	5f                   	pop    %edi
c0102d4e:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0102d54:	50                   	push   %eax
c0102d55:	8d 85 d3 fd ff ff    	lea    -0x22d(%ebp),%eax
c0102d5b:	50                   	push   %eax
c0102d5c:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0102d62:	e8 33 1d 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102d67:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102d6d:	83 c4 0c             	add    $0xc,%esp
c0102d70:	56                   	push   %esi
c0102d71:	50                   	push   %eax
c0102d72:	57                   	push   %edi
c0102d73:	e8 48 ed ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0102d78:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102d7e:	89 04 24             	mov    %eax,(%esp)
c0102d81:	e8 2e 1d 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0102d86:	89 34 24             	mov    %esi,(%esp)
c0102d89:	e8 26 1d 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue((uint32_t)pArr);
c0102d8e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d91:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0102d97:	89 85 d8 fd ff ff    	mov    %eax,-0x228(%ebp)
c0102d9d:	58                   	pop    %eax
c0102d9e:	5a                   	pop    %edx
c0102d9f:	56                   	push   %esi
c0102da0:	57                   	push   %edi
c0102da1:	e8 ac ee ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    out.write("\n num = ");
c0102da6:	8d 93 66 69 fe ff    	lea    -0x1969a(%ebx),%edx
c0102dac:	59                   	pop    %ecx
c0102dad:	58                   	pop    %eax
c0102dae:	52                   	push   %edx
c0102daf:	56                   	push   %esi
c0102db0:	e8 e5 1c 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102db5:	58                   	pop    %eax
c0102db6:	5a                   	pop    %edx
c0102db7:	56                   	push   %esi
c0102db8:	57                   	push   %edi
c0102db9:	e8 50 ee ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0102dbe:	89 34 24             	mov    %esi,(%esp)
c0102dc1:	e8 ee 1c 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue(num);
c0102dc6:	8d 55 10             	lea    0x10(%ebp),%edx
c0102dc9:	59                   	pop    %ecx
c0102dca:	58                   	pop    %eax
c0102dcb:	52                   	push   %edx
c0102dcc:	57                   	push   %edi
c0102dcd:	e8 80 ee ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    out.write("\n");
c0102dd2:	58                   	pop    %eax
c0102dd3:	5a                   	pop    %edx
c0102dd4:	8d 93 4f 67 fe ff    	lea    -0x198b1(%ebx),%edx
c0102dda:	52                   	push   %edx
c0102ddb:	56                   	push   %esi
c0102ddc:	e8 b9 1c 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0102de1:	59                   	pop    %ecx
c0102de2:	58                   	pop    %eax
c0102de3:	56                   	push   %esi
c0102de4:	57                   	push   %edi
c0102de5:	e8 24 ee ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0102dea:	89 34 24             	mov    %esi,(%esp)
c0102ded:	e8 c2 1c 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.flush();
c0102df2:	89 3c 24             	mov    %edi,(%esp)
c0102df5:	e8 60 ed ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    for (uint32_t i = 0; i < num; i++) {    // init Page struct for the mem-area
c0102dfa:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0102dfd:	83 c4 10             	add    $0x10,%esp
c0102e00:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0102e06:	6b d1 11             	imul   $0x11,%ecx,%edx
c0102e09:	03 55 0c             	add    0xc(%ebp),%edx
c0102e0c:	39 d0                	cmp    %edx,%eax
c0102e0e:	74 16                	je     c0102e26 <_ZN4FFMA10initMemMapEPN4ListIN3MMU4PageEE6DLNodeEj+0x10a>
        pArr[i].data.ref = 0;
c0102e10:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0102e16:	83 c0 11             	add    $0x11,%eax
        pArr[i].data.status = 0;
c0102e19:	c6 40 f3 00          	movb   $0x0,-0xd(%eax)
        pArr[i].data.property = 0;
c0102e1d:	c7 40 f4 00 00 00 00 	movl   $0x0,-0xc(%eax)
    for (uint32_t i = 0; i < num; i++) {    // init Page struct for the mem-area
c0102e24:	eb e6                	jmp    c0102e0c <_ZN4FFMA10initMemMapEPN4ListIN3MMU4PageEE6DLNodeEj+0xf0>
    pArr[0].data.property = num;
c0102e26:	8b 45 0c             	mov    0xc(%ebp),%eax
    MMU::setPageProperty(pArr[0].data);
c0102e29:	83 ec 0c             	sub    $0xc,%esp
    pArr[0].data.property = num;
c0102e2c:	89 48 05             	mov    %ecx,0x5(%eax)
    MMU::setPageProperty(pArr[0].data);
c0102e2f:	50                   	push   %eax
c0102e30:	e8 9f 1a 00 00       	call   c01048d4 <_ZN3MMU15setPagePropertyERNS_4PageE>
    nfp += num;
c0102e35:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0102e38:	8b 45 10             	mov    0x10(%ebp),%eax
c0102e3b:	01 41 19             	add    %eax,0x19(%ecx)
    freeArea.addLNode(*pArr);
c0102e3e:	58                   	pop    %eax
c0102e3f:	89 c8                	mov    %ecx,%eax
c0102e41:	83 c0 09             	add    $0x9,%eax
c0102e44:	5a                   	pop    %edx
c0102e45:	ff 75 0c             	pushl  0xc(%ebp)
c0102e48:	50                   	push   %eax
c0102e49:	e8 f4 01 00 00       	call   c0103042 <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE>
    OStream out("\n\ninitMemMap:\n\n firstAd = ", "red");
c0102e4e:	89 3c 24             	mov    %edi,(%esp)
c0102e51:	e8 48 ed ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
}
c0102e56:	83 c4 10             	add    $0x10,%esp
c0102e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102e5c:	5b                   	pop    %ebx
c0102e5d:	5e                   	pop    %esi
c0102e5e:	5f                   	pop    %edi
c0102e5f:	5d                   	pop    %ebp
c0102e60:	c3                   	ret    
c0102e61:	90                   	nop

c0102e62 <_ZN4FFMA10allocPagesEj>:
List<MMU::Page>::DLNode * FFMA::allocPages(uint32_t n) {
c0102e62:	55                   	push   %ebp
c0102e63:	89 e5                	mov    %esp,%ebp
c0102e65:	57                   	push   %edi
c0102e66:	56                   	push   %esi
c0102e67:	53                   	push   %ebx
c0102e68:	83 ec 1c             	sub    $0x1c,%esp
c0102e6b:	8b 7d 08             	mov    0x8(%ebp),%edi
    if (n > nfp) {                                 // if n great than  number of free-page
c0102e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102e71:	e8 4a dd ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0102e76:	81 c3 aa b5 01 00    	add    $0x1b5aa,%ebx
c0102e7c:	39 47 19             	cmp    %eax,0x19(%edi)
c0102e7f:	73 04                	jae    c0102e85 <_ZN4FFMA10allocPagesEj+0x23>
        return nullptr;
c0102e81:	31 f6                	xor    %esi,%esi
c0102e83:	eb 6b                	jmp    c0102ef0 <_ZN4FFMA10allocPagesEj+0x8e>
    return p->data;
}

template <typename Object>
typename List<Object>::NodeIterator List<Object>::getNodeIterator() {
    it.setCurrentNode(headNode.first);
c0102e85:	8b 77 0d             	mov    0xd(%edi),%esi
                    currentNode = node;
c0102e88:	89 77 09             	mov    %esi,0x9(%edi)
                    if (!hasNext()) {
c0102e8b:	85 f6                	test   %esi,%esi
c0102e8d:	74 f2                	je     c0102e81 <_ZN4FFMA10allocPagesEj+0x1f>
        if (pnode->data.property >= n) {            // current continuous area[page num] is Ok
c0102e8f:	8b 4e 05             	mov    0x5(%esi),%ecx
c0102e92:	3b 4d 0c             	cmp    0xc(%ebp),%ecx
                    currentNode = currentNode->next;
c0102e95:	8b 56 0d             	mov    0xd(%esi),%edx
c0102e98:	73 04                	jae    c0102e9e <_ZN4FFMA10allocPagesEj+0x3c>
c0102e9a:	89 d6                	mov    %edx,%esi
c0102e9c:	eb ed                	jmp    c0102e8b <_ZN4FFMA10allocPagesEj+0x29>
        if (pnode->data.property > n) {             // need resolve continuous area ?
c0102e9e:	3b 4d 0c             	cmp    0xc(%ebp),%ecx
    auto it = freeArea.getNodeIterator();
c0102ea1:	8d 47 09             	lea    0x9(%edi),%eax
c0102ea4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (pnode->data.property > n) {             // need resolve continuous area ?
c0102ea7:	76 2b                	jbe    c0102ed4 <_ZN4FFMA10allocPagesEj+0x72>
            List<MMU::Page>::DLNode *newNode = pnode + n;
c0102ea9:	6b 55 0c 11          	imul   $0x11,0xc(%ebp),%edx
            MMU::setPageProperty(newNode->data);
c0102ead:	83 ec 0c             	sub    $0xc,%esp
            newNode->data.property = pnode->data.property - n;
c0102eb0:	2b 4d 0c             	sub    0xc(%ebp),%ecx
            List<MMU::Page>::DLNode *newNode = pnode + n;
c0102eb3:	01 f2                	add    %esi,%edx
            newNode->data.property = pnode->data.property - n;
c0102eb5:	89 4a 05             	mov    %ecx,0x5(%edx)
            MMU::setPageProperty(newNode->data);
c0102eb8:	52                   	push   %edx
c0102eb9:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0102ebc:	e8 13 1a 00 00       	call   c01048d4 <_ZN3MMU15setPagePropertyERNS_4PageE>
            freeArea.insertLNode(pnode, newNode);   // insert new pageNode
c0102ec1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102ec4:	83 c4 0c             	add    $0xc,%esp
c0102ec7:	52                   	push   %edx
c0102ec8:	56                   	push   %esi
c0102ec9:	ff 75 e4             	pushl  -0x1c(%ebp)
c0102ecc:	e8 b7 01 00 00       	call   c0103088 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_>
c0102ed1:	83 c4 10             	add    $0x10,%esp
        freeArea.deleteLNode(pnode);
c0102ed4:	50                   	push   %eax
c0102ed5:	50                   	push   %eax
c0102ed6:	56                   	push   %esi
c0102ed7:	ff 75 e4             	pushl  -0x1c(%ebp)
c0102eda:	e8 e5 01 00 00       	call   c01030c4 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE>
        nfp -= n;
c0102edf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102ee2:	29 47 19             	sub    %eax,0x19(%edi)
        MMU::clearPageProperty(pnode->data);
c0102ee5:	89 34 24             	mov    %esi,(%esp)
c0102ee8:	e8 f3 19 00 00       	call   c01048e0 <_ZN3MMU17clearPagePropertyERNS_4PageE>
c0102eed:	83 c4 10             	add    $0x10,%esp
}
c0102ef0:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102ef3:	89 f0                	mov    %esi,%eax
c0102ef5:	5b                   	pop    %ebx
c0102ef6:	5e                   	pop    %esi
c0102ef7:	5f                   	pop    %edi
c0102ef8:	5d                   	pop    %ebp
c0102ef9:	c3                   	ret    

c0102efa <_ZN4FFMA9freePagesEPvj>:
c0102efa:	55                   	push   %ebp
c0102efb:	89 e5                	mov    %esp,%ebp
c0102efd:	57                   	push   %edi
c0102efe:	56                   	push   %esi
c0102eff:	53                   	push   %ebx
c0102f00:	83 ec 1c             	sub    $0x1c,%esp
c0102f03:	8b 7d 10             	mov    0x10(%ebp),%edi
c0102f06:	e8 b5 dc ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0102f0b:	81 c3 15 b5 01 00    	add    $0x1b515,%ebx
c0102f11:	8b 75 0c             	mov    0xc(%ebp),%esi
c0102f14:	8b 55 08             	mov    0x8(%ebp),%edx
c0102f17:	6b cf 11             	imul   $0x11,%edi,%ecx
c0102f1a:	89 f0                	mov    %esi,%eax
c0102f1c:	01 f1                	add    %esi,%ecx
c0102f1e:	39 c8                	cmp    %ecx,%eax
c0102f20:	74 10                	je     c0102f32 <_ZN4FFMA9freePagesEPvj+0x38>
c0102f22:	c6 40 04 00          	movb   $0x0,0x4(%eax)
c0102f26:	83 c0 11             	add    $0x11,%eax
c0102f29:	c7 40 ef 00 00 00 00 	movl   $0x0,-0x11(%eax)
c0102f30:	eb ec                	jmp    c0102f1e <_ZN4FFMA9freePagesEPvj+0x24>
c0102f32:	83 ec 0c             	sub    $0xc,%esp
c0102f35:	89 7e 05             	mov    %edi,0x5(%esi)
c0102f38:	56                   	push   %esi
c0102f39:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0102f3c:	e8 93 19 00 00       	call   c01048d4 <_ZN3MMU15setPagePropertyERNS_4PageE>
c0102f41:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102f44:	83 c4 10             	add    $0x10,%esp
c0102f47:	8b 7a 0d             	mov    0xd(%edx),%edi
c0102f4a:	8d 42 09             	lea    0x9(%edx),%eax
c0102f4d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0102f50:	89 7a 09             	mov    %edi,0x9(%edx)
c0102f53:	85 ff                	test   %edi,%edi
c0102f55:	74 77                	je     c0102fce <_ZN4FFMA9freePagesEPvj+0xd4>
c0102f57:	8b 47 0d             	mov    0xd(%edi),%eax
c0102f5a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102f5d:	8b 47 05             	mov    0x5(%edi),%eax
c0102f60:	6b c8 11             	imul   $0x11,%eax,%ecx
c0102f63:	01 f9                	add    %edi,%ecx
c0102f65:	39 f1                	cmp    %esi,%ecx
c0102f67:	75 27                	jne    c0102f90 <_ZN4FFMA9freePagesEPvj+0x96>
c0102f69:	03 46 05             	add    0x5(%esi),%eax
c0102f6c:	83 ec 0c             	sub    $0xc,%esp
c0102f6f:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0102f72:	89 47 05             	mov    %eax,0x5(%edi)
c0102f75:	56                   	push   %esi
c0102f76:	89 fe                	mov    %edi,%esi
c0102f78:	e8 63 19 00 00       	call   c01048e0 <_ZN3MMU17clearPagePropertyERNS_4PageE>
c0102f7d:	59                   	pop    %ecx
c0102f7e:	5b                   	pop    %ebx
c0102f7f:	57                   	push   %edi
c0102f80:	ff 75 e4             	pushl  -0x1c(%ebp)
c0102f83:	e8 3c 01 00 00       	call   c01030c4 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE>
c0102f88:	83 c4 10             	add    $0x10,%esp
c0102f8b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102f8e:	eb 3e                	jmp    c0102fce <_ZN4FFMA9freePagesEPvj+0xd4>
c0102f90:	8b 4e 05             	mov    0x5(%esi),%ecx
c0102f93:	89 4d e0             	mov    %ecx,-0x20(%ebp)
c0102f96:	6b c9 11             	imul   $0x11,%ecx,%ecx
c0102f99:	01 f1                	add    %esi,%ecx
c0102f9b:	39 f9                	cmp    %edi,%ecx
c0102f9d:	74 05                	je     c0102fa4 <_ZN4FFMA9freePagesEPvj+0xaa>
c0102f9f:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0102fa2:	eb af                	jmp    c0102f53 <_ZN4FFMA9freePagesEPvj+0x59>
c0102fa4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0102fa7:	83 ec 0c             	sub    $0xc,%esp
c0102faa:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0102fad:	01 c1                	add    %eax,%ecx
c0102faf:	89 4e 05             	mov    %ecx,0x5(%esi)
c0102fb2:	57                   	push   %edi
c0102fb3:	e8 28 19 00 00       	call   c01048e0 <_ZN3MMU17clearPagePropertyERNS_4PageE>
c0102fb8:	58                   	pop    %eax
c0102fb9:	5a                   	pop    %edx
c0102fba:	57                   	push   %edi
c0102fbb:	ff 75 e4             	pushl  -0x1c(%ebp)
c0102fbe:	e8 01 01 00 00       	call   c01030c4 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE>
c0102fc3:	83 c4 10             	add    $0x10,%esp
c0102fc6:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0102fc9:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102fcc:	eb 85                	jmp    c0102f53 <_ZN4FFMA9freePagesEPvj+0x59>
c0102fce:	8b 4a 0d             	mov    0xd(%edx),%ecx
c0102fd1:	89 4a 09             	mov    %ecx,0x9(%edx)
c0102fd4:	89 c8                	mov    %ecx,%eax
c0102fd6:	85 c0                	test   %eax,%eax
c0102fd8:	74 0b                	je     c0102fe5 <_ZN4FFMA9freePagesEPvj+0xeb>
c0102fda:	39 f0                	cmp    %esi,%eax
c0102fdc:	8b 58 0d             	mov    0xd(%eax),%ebx
c0102fdf:	73 42                	jae    c0103023 <_ZN4FFMA9freePagesEPvj+0x129>
c0102fe1:	89 d8                	mov    %ebx,%eax
c0102fe3:	eb f1                	jmp    c0102fd6 <_ZN4FFMA9freePagesEPvj+0xdc>
c0102fe5:	8b 42 15             	mov    0x15(%edx),%eax
c0102fe8:	85 c0                	test   %eax,%eax
c0102fea:	75 06                	jne    c0102ff2 <_ZN4FFMA9freePagesEPvj+0xf8>
c0102fec:	83 7a 11 00          	cmpl   $0x0,0x11(%edx)
c0102ff0:	74 1c                	je     c010300e <_ZN4FFMA9freePagesEPvj+0x114>
c0102ff2:	40                   	inc    %eax
c0102ff3:	c7 46 09 00 00 00 00 	movl   $0x0,0x9(%esi)
c0102ffa:	89 4e 0d             	mov    %ecx,0xd(%esi)
c0102ffd:	89 71 09             	mov    %esi,0x9(%ecx)
c0103000:	89 72 0d             	mov    %esi,0xd(%edx)
c0103003:	89 42 15             	mov    %eax,0x15(%edx)
c0103006:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0103009:	5b                   	pop    %ebx
c010300a:	5e                   	pop    %esi
c010300b:	5f                   	pop    %edi
c010300c:	5d                   	pop    %ebp
c010300d:	c3                   	ret    
c010300e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103011:	89 75 0c             	mov    %esi,0xc(%ebp)
c0103014:	89 45 08             	mov    %eax,0x8(%ebp)
c0103017:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010301a:	5b                   	pop    %ebx
c010301b:	5e                   	pop    %esi
c010301c:	5f                   	pop    %edi
c010301d:	5d                   	pop    %ebp
c010301e:	e9 1f 00 00 00       	jmp    c0103042 <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE>
c0103023:	8b 40 09             	mov    0x9(%eax),%eax
c0103026:	85 c0                	test   %eax,%eax
c0103028:	74 bb                	je     c0102fe5 <_ZN4FFMA9freePagesEPvj+0xeb>
c010302a:	89 45 0c             	mov    %eax,0xc(%ebp)
c010302d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103030:	89 75 10             	mov    %esi,0x10(%ebp)
c0103033:	89 45 08             	mov    %eax,0x8(%ebp)
c0103036:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0103039:	5b                   	pop    %ebx
c010303a:	5e                   	pop    %esi
c010303b:	5f                   	pop    %edi
c010303c:	5d                   	pop    %ebp
c010303d:	e9 46 00 00 00       	jmp    c0103088 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_>

c0103042 <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE>:
void List<Object>::addLNode(DLNode &node) {
c0103042:	55                   	push   %ebp
c0103043:	89 e5                	mov    %esp,%ebp
c0103045:	8b 55 08             	mov    0x8(%ebp),%edx
c0103048:	53                   	push   %ebx
c0103049:	8b 45 0c             	mov    0xc(%ebp),%eax
    return (headNode.eNum == 0 && headNode.last == nullptr);
c010304c:	8b 4a 0c             	mov    0xc(%edx),%ecx
c010304f:	8b 5a 08             	mov    0x8(%edx),%ebx
c0103052:	85 c9                	test   %ecx,%ecx
c0103054:	75 1a                	jne    c0103070 <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE+0x2e>
c0103056:	85 db                	test   %ebx,%ebx
c0103058:	75 16                	jne    c0103070 <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE+0x2e>
        headNode.last = &node;
c010305a:	89 42 08             	mov    %eax,0x8(%edx)
        headNode.first = &node;
c010305d:	89 42 04             	mov    %eax,0x4(%edx)
        node.pre = nullptr;
c0103060:	c7 40 09 00 00 00 00 	movl   $0x0,0x9(%eax)
        node.next = nullptr;
c0103067:	c7 40 0d 00 00 00 00 	movl   $0x0,0xd(%eax)
c010306e:	eb 10                	jmp    c0103080 <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE+0x3e>
        p->next = &node;
c0103070:	89 43 0d             	mov    %eax,0xd(%ebx)
        node.pre = p;
c0103073:	89 58 09             	mov    %ebx,0x9(%eax)
        node.next = nullptr;
c0103076:	c7 40 0d 00 00 00 00 	movl   $0x0,0xd(%eax)
        headNode.last = &node;           // update 
c010307d:	89 42 08             	mov    %eax,0x8(%edx)
    headNode.eNum++;
c0103080:	41                   	inc    %ecx
c0103081:	89 4a 0c             	mov    %ecx,0xc(%edx)
}
c0103084:	5b                   	pop    %ebx
c0103085:	5d                   	pop    %ebp
c0103086:	c3                   	ret    
c0103087:	90                   	nop

c0103088 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_>:
void List<Object>::insertLNode(DLNode *node1, DLNode *node2) {
c0103088:	55                   	push   %ebp
c0103089:	89 e5                	mov    %esp,%ebp
c010308b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010308e:	53                   	push   %ebx
c010308f:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0103092:	8b 55 10             	mov    0x10(%ebp),%edx
    if (node1 == nullptr) {
c0103095:	85 c0                	test   %eax,%eax
c0103097:	74 27                	je     c01030c0 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_+0x38>
    if (node1->next == nullptr) {
c0103099:	8b 58 0d             	mov    0xd(%eax),%ebx
c010309c:	85 db                	test   %ebx,%ebx
c010309e:	75 0a                	jne    c01030aa <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_+0x22>
}
c01030a0:	5b                   	pop    %ebx
        addLNode(*node2);
c01030a1:	89 55 0c             	mov    %edx,0xc(%ebp)
}
c01030a4:	5d                   	pop    %ebp
        addLNode(*node2);
c01030a5:	e9 98 ff ff ff       	jmp    c0103042 <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE>
        node2->next = node1->next;
c01030aa:	89 5a 0d             	mov    %ebx,0xd(%edx)
        if (node1->next != nullptr) {
c01030ad:	8b 58 0d             	mov    0xd(%eax),%ebx
        node2->pre = node1;
c01030b0:	89 42 09             	mov    %eax,0x9(%edx)
        if (node1->next != nullptr) {
c01030b3:	85 db                	test   %ebx,%ebx
c01030b5:	74 03                	je     c01030ba <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_+0x32>
            node1->next->pre = node2;
c01030b7:	89 53 09             	mov    %edx,0x9(%ebx)
        node1->next = node2;
c01030ba:	89 50 0d             	mov    %edx,0xd(%eax)
        headNode.eNum++;
c01030bd:	ff 41 0c             	incl   0xc(%ecx)
}
c01030c0:	5b                   	pop    %ebx
c01030c1:	5d                   	pop    %ebp
c01030c2:	c3                   	ret    
c01030c3:	90                   	nop

c01030c4 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE>:
void List<Object>::deleteLNode(DLNode *node) {
c01030c4:	55                   	push   %ebp
c01030c5:	89 e5                	mov    %esp,%ebp
c01030c7:	8b 55 08             	mov    0x8(%ebp),%edx
c01030ca:	53                   	push   %ebx
c01030cb:	8b 45 0c             	mov    0xc(%ebp),%eax
    if (headNode.first == node) {       // is first Node
c01030ce:	39 42 04             	cmp    %eax,0x4(%edx)
c01030d1:	75 1c                	jne    c01030ef <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x2b>
        headNode.first = node->next;
c01030d3:	8b 48 0d             	mov    0xd(%eax),%ecx
        if (headNode.first == nullptr) {
c01030d6:	85 c9                	test   %ecx,%ecx
        headNode.first = node->next;
c01030d8:	89 4a 04             	mov    %ecx,0x4(%edx)
        if (headNode.first == nullptr) {
c01030db:	75 09                	jne    c01030e6 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x22>
            headNode.last = nullptr;
c01030dd:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
c01030e4:	eb 29                	jmp    c010310f <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x4b>
            headNode.first->pre = nullptr;
c01030e6:	c7 41 09 00 00 00 00 	movl   $0x0,0x9(%ecx)
c01030ed:	eb 20                	jmp    c010310f <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x4b>
    } else if (headNode.last == node) { // is trail Node[can't only a node]
c01030ef:	39 42 08             	cmp    %eax,0x8(%edx)
c01030f2:	8b 48 09             	mov    0x9(%eax),%ecx
c01030f5:	75 0c                	jne    c0103103 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x3f>
        headNode.last = node->pre;
c01030f7:	89 4a 08             	mov    %ecx,0x8(%edx)
        headNode.last->next = nullptr;
c01030fa:	c7 41 0d 00 00 00 00 	movl   $0x0,0xd(%ecx)
c0103101:	eb 0c                	jmp    c010310f <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x4b>
        node->next->pre = node->pre;
c0103103:	8b 58 0d             	mov    0xd(%eax),%ebx
c0103106:	89 4b 09             	mov    %ecx,0x9(%ebx)
        node->pre->next = node->next;
c0103109:	8b 48 09             	mov    0x9(%eax),%ecx
c010310c:	89 59 0d             	mov    %ebx,0xd(%ecx)
    node->next = node->pre = nullptr;
c010310f:	c7 40 09 00 00 00 00 	movl   $0x0,0x9(%eax)
c0103116:	c7 40 0d 00 00 00 00 	movl   $0x0,0xd(%eax)
    headNode.eNum--;
c010311d:	ff 4a 0c             	decl   0xc(%edx)
}
c0103120:	5b                   	pop    %ebx
c0103121:	5d                   	pop    %ebp
c0103122:	c3                   	ret    
c0103123:	90                   	nop

c0103124 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>:

void VMM::init() {
    checkVmm();
}

List<VMM::VMA>::DLNode * VMM::findVma(List<MM>::DLNode *mm, uptr32_t addr) {
c0103124:	55                   	push   %ebp
c0103125:	89 e5                	mov    %esp,%ebp
c0103127:	8b 55 0c             	mov    0xc(%ebp),%edx
c010312a:	53                   	push   %ebx
c010312b:	8b 4d 10             	mov    0x10(%ebp),%ecx
        DEBUGPRINT("VMM::findVma");
    #endif
    
    List<VMA>::DLNode *vma = nullptr;

    if (mm != nullptr) {
c010312e:	85 d2                	test   %edx,%edx
c0103130:	75 04                	jne    c0103136 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x12>
    List<VMA>::DLNode *vma = nullptr;
c0103132:	31 c0                	xor    %eax,%eax
c0103134:	eb 2e                	jmp    c0103164 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x40>
        vma = mm->data.mmap_cache;
c0103136:	8b 42 10             	mov    0x10(%edx),%eax
        if (!(vma != nullptr && vma->data.vm_start <= addr && vma->data.vm_end > addr)) {
c0103139:	85 c0                	test   %eax,%eax
c010313b:	74 0a                	je     c0103147 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x23>
c010313d:	39 48 04             	cmp    %ecx,0x4(%eax)
c0103140:	77 05                	ja     c0103147 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x23>
c0103142:	39 48 08             	cmp    %ecx,0x8(%eax)
c0103145:	77 1a                	ja     c0103161 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x3d>
    it.setCurrentNode(headNode.first);
c0103147:	8b 42 04             	mov    0x4(%edx),%eax
                    currentNode = node;
c010314a:	89 02                	mov    %eax,(%edx)
                    if (!hasNext()) {
c010314c:	85 c0                	test   %eax,%eax
c010314e:	74 e2                	je     c0103132 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0xe>
                        out.write(" now = ");
                        out.writeValue(vma->data.vm_start);
                        out.flush();
                    #endif
                    
                    if (vma->data.vm_start <= addr && addr < vma->data.vm_end) {
c0103150:	39 48 04             	cmp    %ecx,0x4(%eax)
                    currentNode = currentNode->next;
c0103153:	8b 58 14             	mov    0x14(%eax),%ebx
c0103156:	76 04                	jbe    c010315c <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x38>
List<VMM::VMA>::DLNode * VMM::findVma(List<MM>::DLNode *mm, uptr32_t addr) {
c0103158:	89 d8                	mov    %ebx,%eax
c010315a:	eb f0                	jmp    c010314c <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x28>
                    if (vma->data.vm_start <= addr && addr < vma->data.vm_end) {
c010315c:	39 48 08             	cmp    %ecx,0x8(%eax)
c010315f:	76 f7                	jbe    c0103158 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x34>
                if (!found) {
                    vma = nullptr;
                }
        }
        if (vma != nullptr) {
            mm->data.mmap_cache = vma;
c0103161:	89 42 10             	mov    %eax,0x10(%edx)
        }
    }

    return vma;

}
c0103164:	5b                   	pop    %ebx
c0103165:	5d                   	pop    %ebp
c0103166:	c3                   	ret    
c0103167:	90                   	nop

c0103168 <_ZN3VMM9vmaCreateEjjj>:

List<VMM::VMA>::DLNode * VMM::vmaCreate(uptr32_t vmStart, uptr32_t vmEnd, uint32_t vmFlags) {
c0103168:	55                   	push   %ebp
c0103169:	89 e5                	mov    %esp,%ebp
c010316b:	57                   	push   %edi
c010316c:	56                   	push   %esi
c010316d:	53                   	push   %ebx
c010316e:	e8 4d da ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0103173:	81 c3 ad b2 01 00    	add    $0x1b2ad,%ebx
c0103179:	81 ec 44 02 00 00    	sub    $0x244,%esp
    DEBUGPRINT("VMM::vmaCreate");
c010317f:	8d b5 d8 fd ff ff    	lea    -0x228(%ebp),%esi
c0103185:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c010318b:	50                   	push   %eax
c010318c:	56                   	push   %esi
c010318d:	e8 08 19 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103192:	8d 83 c9 68 fe ff    	lea    -0x19737(%ebx),%eax
c0103198:	59                   	pop    %ecx
c0103199:	5f                   	pop    %edi
c010319a:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01031a0:	50                   	push   %eax
c01031a1:	8d 85 d3 fd ff ff    	lea    -0x22d(%ebp),%eax
c01031a7:	50                   	push   %eax
c01031a8:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c01031ae:	e8 e7 18 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01031b3:	83 c4 0c             	add    $0xc,%esp
c01031b6:	56                   	push   %esi
c01031b7:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c01031bd:	57                   	push   %edi
c01031be:	e8 fd e8 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c01031c3:	58                   	pop    %eax
c01031c4:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c01031ca:	e8 e5 18 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01031cf:	89 34 24             	mov    %esi,(%esp)
c01031d2:	e8 dd 18 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01031d7:	58                   	pop    %eax
c01031d8:	8d 83 6f 69 fe ff    	lea    -0x19691(%ebx),%eax
c01031de:	5a                   	pop    %edx
c01031df:	50                   	push   %eax
c01031e0:	56                   	push   %esi
c01031e1:	e8 b4 18 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01031e6:	59                   	pop    %ecx
c01031e7:	58                   	pop    %eax
c01031e8:	56                   	push   %esi
c01031e9:	57                   	push   %edi
c01031ea:	e8 1f ea ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01031ef:	89 34 24             	mov    %esi,(%esp)
c01031f2:	e8 bd 18 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01031f7:	89 3c 24             	mov    %edi,(%esp)
c01031fa:	e8 5b e9 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
c01031ff:	89 3c 24             	mov    %edi,(%esp)
c0103202:	e8 97 e9 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
    auto vma = (List<VMA>::DLNode *)(kernel::pmm.kmalloc(sizeof(List<VMA>::DLNode)));
c0103207:	58                   	pop    %eax
c0103208:	5a                   	pop    %edx
c0103209:	6a 18                	push   $0x18
c010320b:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
c0103211:	e8 fa f6 ff ff       	call   c0102910 <_ZN5PhyMM7kmallocEj>
    
    if (vma != nullptr) {
c0103216:	83 c4 10             	add    $0x10,%esp
c0103219:	85 c0                	test   %eax,%eax
c010321b:	0f 84 99 00 00 00    	je     c01032ba <_ZN3VMM9vmaCreateEjjj+0x152>
c0103221:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
        OStream out("", "blue");
c0103227:	8d 93 36 67 fe ff    	lea    -0x198ca(%ebx),%edx
c010322d:	50                   	push   %eax
c010322e:	50                   	push   %eax
c010322f:	52                   	push   %edx
c0103230:	56                   	push   %esi
c0103231:	e8 64 18 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103236:	5a                   	pop    %edx
c0103237:	8d 93 50 67 fe ff    	lea    -0x198b0(%ebx),%edx
c010323d:	59                   	pop    %ecx
c010323e:	52                   	push   %edx
c010323f:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0103245:	e8 50 18 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010324a:	83 c4 0c             	add    $0xc,%esp
c010324d:	56                   	push   %esi
c010324e:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0103254:	57                   	push   %edi
c0103255:	e8 66 e8 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c010325a:	58                   	pop    %eax
c010325b:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0103261:	e8 4e 18 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103266:	89 34 24             	mov    %esi,(%esp)
c0103269:	e8 46 18 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
        out.writeValue((uint32_t)vma);
c010326e:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0103274:	89 85 d8 fd ff ff    	mov    %eax,-0x228(%ebp)
c010327a:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0103280:	58                   	pop    %eax
c0103281:	5a                   	pop    %edx
c0103282:	56                   	push   %esi
c0103283:	57                   	push   %edi
c0103284:	e8 c9 e9 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
        out.flush();
c0103289:	89 3c 24             	mov    %edi,(%esp)
c010328c:	e8 c9 e8 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>

        vma->data.vm_start = vmStart;
c0103291:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0103297:	8b 55 0c             	mov    0xc(%ebp),%edx
c010329a:	89 50 04             	mov    %edx,0x4(%eax)
        vma->data.vm_end = vmEnd;
c010329d:	8b 55 10             	mov    0x10(%ebp),%edx
c01032a0:	89 50 08             	mov    %edx,0x8(%eax)
        vma->data.vm_flags = vmFlags;
c01032a3:	8b 55 14             	mov    0x14(%ebp),%edx
c01032a6:	89 50 0c             	mov    %edx,0xc(%eax)
        OStream out("", "blue");
c01032a9:	89 3c 24             	mov    %edi,(%esp)
c01032ac:	e8 ed e8 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c01032b1:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c01032b7:	83 c4 10             	add    $0x10,%esp
    }
    
    return vma;
}
c01032ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01032bd:	5b                   	pop    %ebx
c01032be:	5e                   	pop    %esi
c01032bf:	5f                   	pop    %edi
c01032c0:	5d                   	pop    %ebp
c01032c1:	c3                   	ret    

c01032c2 <_ZN3VMM8mmCreateEv>:
    }
    out.write("\nnodeNum: ");
    out.writeValue((mm->data.vmaList.length()));
}

List<VMM::MM>::DLNode * VMM::mmCreate() {
c01032c2:	55                   	push   %ebp
c01032c3:	89 e5                	mov    %esp,%ebp
c01032c5:	57                   	push   %edi
c01032c6:	56                   	push   %esi
c01032c7:	53                   	push   %ebx
c01032c8:	e8 f3 d8 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c01032cd:	81 c3 53 b1 01 00    	add    $0x1b153,%ebx
c01032d3:	81 ec 44 02 00 00    	sub    $0x244,%esp
    DEBUGPRINT(" VMM::mmCreate()");
c01032d9:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01032df:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01032e5:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c01032eb:	50                   	push   %eax
c01032ec:	56                   	push   %esi
c01032ed:	e8 a8 17 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01032f2:	58                   	pop    %eax
c01032f3:	8d 83 c9 68 fe ff    	lea    -0x19737(%ebx),%eax
c01032f9:	5a                   	pop    %edx
c01032fa:	50                   	push   %eax
c01032fb:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0103301:	50                   	push   %eax
c0103302:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0103308:	e8 8d 17 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010330d:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0103313:	83 c4 0c             	add    $0xc,%esp
c0103316:	56                   	push   %esi
c0103317:	50                   	push   %eax
c0103318:	57                   	push   %edi
c0103319:	e8 a2 e7 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c010331e:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c0103324:	89 04 24             	mov    %eax,(%esp)
c0103327:	e8 88 17 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010332c:	89 34 24             	mov    %esi,(%esp)
c010332f:	e8 80 17 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103334:	59                   	pop    %ecx
c0103335:	58                   	pop    %eax
c0103336:	8d 83 7e 69 fe ff    	lea    -0x19682(%ebx),%eax
c010333c:	50                   	push   %eax
c010333d:	56                   	push   %esi
c010333e:	e8 57 17 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103343:	58                   	pop    %eax
c0103344:	5a                   	pop    %edx
c0103345:	56                   	push   %esi
c0103346:	57                   	push   %edi
c0103347:	e8 c2 e8 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c010334c:	89 34 24             	mov    %esi,(%esp)
c010334f:	e8 60 17 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103354:	89 3c 24             	mov    %edi,(%esp)
c0103357:	e8 fe e7 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
c010335c:	89 3c 24             	mov    %edi,(%esp)
c010335f:	e8 3a e8 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
    auto mm = (List<MM>::DLNode *)(kernel::pmm.kmalloc(sizeof(List<MM>::DLNode)));
c0103364:	59                   	pop    %ecx
c0103365:	5e                   	pop    %esi
c0103366:	6a 24                	push   $0x24
c0103368:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
c010336e:	e8 9d f5 ff ff       	call   c0102910 <_ZN5PhyMM7kmallocEj>

    if (mm != nullptr) {
c0103373:	83 c4 10             	add    $0x10,%esp
c0103376:	85 c0                	test   %eax,%eax
c0103378:	74 23                	je     c010339d <_ZN3VMM8mmCreateEv+0xdb>
        mm->next = mm->pre = nullptr;
c010337a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
c0103381:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
        mm->data.mmap_cache = nullptr;
c0103388:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        mm->data.pgdir = nullptr;
c010338f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        //mm->data.map_count = 0;

        if (false) while(1);//swap_init_mm(mm);
        else mm->data.sm_priv = nullptr;
c0103396:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    return mm;
}
c010339d:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01033a0:	5b                   	pop    %ebx
c01033a1:	5e                   	pop    %esi
c01033a2:	5f                   	pop    %edi
c01033a3:	5d                   	pop    %ebp
c01033a4:	c3                   	ret    
c01033a5:	90                   	nop

c01033a6 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE>:

void VMM::mmDestroy(List<MM>::DLNode *mm) {
c01033a6:	55                   	push   %ebp
c01033a7:	89 e5                	mov    %esp,%ebp
c01033a9:	57                   	push   %edi
c01033aa:	56                   	push   %esi
c01033ab:	53                   	push   %ebx
c01033ac:	83 ec 1c             	sub    $0x1c,%esp
c01033af:	e8 0c d8 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c01033b4:	81 c3 6c b0 01 00    	add    $0x1b06c,%ebx
c01033ba:	8b 75 0c             	mov    0xc(%ebp),%esi
    it.setCurrentNode(headNode.first);
c01033bd:	8b 46 04             	mov    0x4(%esi),%eax
c01033c0:	c7 c2 20 10 12 c0    	mov    $0xc0121020,%edx
                    currentNode = node;
c01033c6:	89 06                	mov    %eax,(%esi)
                    if (!hasNext()) {
c01033c8:	85 c0                	test   %eax,%eax
c01033ca:	75 12                	jne    c01033de <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x38>
    List<VMA>::DLNode *vma;
    while ((vma = it.nextLNode()) != nullptr) {
        mm->data.vmaList.deleteLNode(vma);
        kernel::pmm.kfree(vma, sizeof(List<VMA>::DLNode));  //kfree vma        
    }
    kernel::pmm.kfree(mm, sizeof(List<MM>::DLNode));        //kfree mm
c01033cc:	57                   	push   %edi
c01033cd:	6a 24                	push   $0x24
c01033cf:	56                   	push   %esi
c01033d0:	52                   	push   %edx
c01033d1:	e8 46 f7 ff ff       	call   c0102b1c <_ZN5PhyMM5kfreeEPvj>
    mm = nullptr;
}
c01033d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01033d9:	5b                   	pop    %ebx
c01033da:	5e                   	pop    %esi
c01033db:	5f                   	pop    %edi
c01033dc:	5d                   	pop    %ebp
c01033dd:	c3                   	ret    
    if (headNode.first == node) {       // is first Node
c01033de:	3b 46 04             	cmp    0x4(%esi),%eax
                    currentNode = currentNode->next;
c01033e1:	8b 78 14             	mov    0x14(%eax),%edi
    if (headNode.first == node) {       // is first Node
c01033e4:	75 19                	jne    c01033ff <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x59>
        if (headNode.first == nullptr) {
c01033e6:	85 ff                	test   %edi,%edi
        headNode.first = node->next;
c01033e8:	89 7e 04             	mov    %edi,0x4(%esi)
        if (headNode.first == nullptr) {
c01033eb:	75 09                	jne    c01033f6 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x50>
            headNode.last = nullptr;
c01033ed:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
c01033f4:	eb 26                	jmp    c010341c <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x76>
            headNode.first->pre = nullptr;
c01033f6:	c7 47 10 00 00 00 00 	movl   $0x0,0x10(%edi)
c01033fd:	eb 1d                	jmp    c010341c <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x76>
    } else if (headNode.last == node) { // is trail Node[can't only a node]
c01033ff:	3b 46 08             	cmp    0x8(%esi),%eax
c0103402:	8b 48 10             	mov    0x10(%eax),%ecx
c0103405:	75 0c                	jne    c0103413 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x6d>
        headNode.last = node->pre;
c0103407:	89 4e 08             	mov    %ecx,0x8(%esi)
        headNode.last->next = nullptr;
c010340a:	c7 41 14 00 00 00 00 	movl   $0x0,0x14(%ecx)
c0103411:	eb 09                	jmp    c010341c <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x76>
        node->next->pre = node->pre;
c0103413:	89 4f 10             	mov    %ecx,0x10(%edi)
        node->pre->next = node->next;
c0103416:	8b 48 10             	mov    0x10(%eax),%ecx
c0103419:	89 79 14             	mov    %edi,0x14(%ecx)
    node->next = node->pre = nullptr;
c010341c:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
c0103423:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    headNode.eNum--;
c010342a:	ff 4e 0c             	decl   0xc(%esi)
        kernel::pmm.kfree(vma, sizeof(List<VMA>::DLNode));  //kfree vma        
c010342d:	51                   	push   %ecx
c010342e:	6a 18                	push   $0x18
c0103430:	50                   	push   %eax
c0103431:	52                   	push   %edx
c0103432:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0103435:	e8 e2 f6 ff ff       	call   c0102b1c <_ZN5PhyMM5kfreeEPvj>
    while ((vma = it.nextLNode()) != nullptr) {
c010343a:	83 c4 10             	add    $0x10,%esp
                    currentNode = currentNode->next;
c010343d:	89 f8                	mov    %edi,%eax
c010343f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103442:	eb 84                	jmp    c01033c8 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x22>

c0103444 <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj>:

uint32_t VMM::doPageFault(List<MM>::DLNode *mm, uint32_t errorCode, uptr32_t addr) {
c0103444:	55                   	push   %ebp
    return 0;
}
c0103445:	31 c0                	xor    %eax,%eax
uint32_t VMM::doPageFault(List<MM>::DLNode *mm, uint32_t errorCode, uptr32_t addr) {
c0103447:	89 e5                	mov    %esp,%ebp
}
c0103449:	5d                   	pop    %ebp
c010344a:	c3                   	ret    
c010344b:	90                   	nop

c010344c <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_>:

    BREAKPOINT("IIIIII");
}

// check if vma1 overlaps vma2 ?
void VMM::checkVamOverlap(List<VMA>::DLNode *prev, List<VMA>::DLNode *next) {
c010344c:	55                   	push   %ebp
c010344d:	89 e5                	mov    %esp,%ebp
c010344f:	57                   	push   %edi
c0103450:	56                   	push   %esi
c0103451:	53                   	push   %ebx
c0103452:	81 ec 3c 02 00 00    	sub    $0x23c,%esp
c0103458:	8b 45 0c             	mov    0xc(%ebp),%eax
c010345b:	e8 60 d7 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0103460:	81 c3 c0 af 01 00    	add    $0x1afc0,%ebx
    assert(prev->data.vm_start < prev->data.vm_end);
c0103466:	8b 48 08             	mov    0x8(%eax),%ecx
c0103469:	39 48 04             	cmp    %ecx,0x4(%eax)
c010346c:	0f 82 9e 00 00 00    	jb     c0103510 <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_+0xc4>
c0103472:	51                   	push   %ecx
c0103473:	51                   	push   %ecx
c0103474:	8d 93 51 67 fe ff    	lea    -0x198af(%ebx),%edx
c010347a:	52                   	push   %edx
c010347b:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0103481:	56                   	push   %esi
c0103482:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c0103488:	e8 0d 16 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010348d:	8d 93 5b 67 fe ff    	lea    -0x198a5(%ebx),%edx
c0103493:	5f                   	pop    %edi
c0103494:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c010349a:	58                   	pop    %eax
c010349b:	52                   	push   %edx
c010349c:	8d 95 d6 fd ff ff    	lea    -0x22a(%ebp),%edx
c01034a2:	52                   	push   %edx
c01034a3:	89 95 c4 fd ff ff    	mov    %edx,-0x23c(%ebp)
c01034a9:	e8 ec 15 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01034ae:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c01034b4:	83 c4 0c             	add    $0xc,%esp
c01034b7:	56                   	push   %esi
c01034b8:	52                   	push   %edx
c01034b9:	57                   	push   %edi
c01034ba:	e8 01 e6 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c01034bf:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c01034c5:	89 14 24             	mov    %edx,(%esp)
c01034c8:	e8 e7 15 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01034cd:	89 34 24             	mov    %esi,(%esp)
c01034d0:	e8 df 15 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01034d5:	58                   	pop    %eax
c01034d6:	5a                   	pop    %edx
c01034d7:	8d 93 8f 69 fe ff    	lea    -0x19671(%ebx),%edx
c01034dd:	52                   	push   %edx
c01034de:	56                   	push   %esi
c01034df:	e8 b6 15 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01034e4:	59                   	pop    %ecx
c01034e5:	58                   	pop    %eax
c01034e6:	56                   	push   %esi
c01034e7:	57                   	push   %edi
c01034e8:	e8 21 e7 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01034ed:	89 34 24             	mov    %esi,(%esp)
c01034f0:	e8 bf 15 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01034f5:	89 3c 24             	mov    %edi,(%esp)
c01034f8:	e8 5d e6 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01034fd:	fa                   	cli    
    asm volatile ("hlt");
c01034fe:	f4                   	hlt    
c01034ff:	89 3c 24             	mov    %edi,(%esp)
c0103502:	e8 97 e6 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0103507:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c010350d:	83 c4 10             	add    $0x10,%esp
    assert(prev->data.vm_end <= next->data.vm_start);
c0103510:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0103513:	8b 49 04             	mov    0x4(%ecx),%ecx
c0103516:	39 48 08             	cmp    %ecx,0x8(%eax)
c0103519:	0f 86 92 00 00 00    	jbe    c01035b1 <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_+0x165>
c010351f:	50                   	push   %eax
c0103520:	50                   	push   %eax
c0103521:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c0103527:	50                   	push   %eax
c0103528:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c010352e:	56                   	push   %esi
c010352f:	e8 66 15 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103534:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c010353a:	58                   	pop    %eax
c010353b:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c0103541:	5a                   	pop    %edx
c0103542:	50                   	push   %eax
c0103543:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c0103549:	50                   	push   %eax
c010354a:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c0103550:	e8 45 15 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103555:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c010355b:	83 c4 0c             	add    $0xc,%esp
c010355e:	56                   	push   %esi
c010355f:	50                   	push   %eax
c0103560:	57                   	push   %edi
c0103561:	e8 5a e5 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0103566:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c010356c:	89 04 24             	mov    %eax,(%esp)
c010356f:	e8 40 15 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103574:	89 34 24             	mov    %esi,(%esp)
c0103577:	e8 38 15 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010357c:	59                   	pop    %ecx
c010357d:	58                   	pop    %eax
c010357e:	8d 83 b7 69 fe ff    	lea    -0x19649(%ebx),%eax
c0103584:	50                   	push   %eax
c0103585:	56                   	push   %esi
c0103586:	e8 0f 15 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010358b:	58                   	pop    %eax
c010358c:	5a                   	pop    %edx
c010358d:	56                   	push   %esi
c010358e:	57                   	push   %edi
c010358f:	e8 7a e6 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0103594:	89 34 24             	mov    %esi,(%esp)
c0103597:	e8 18 15 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010359c:	89 3c 24             	mov    %edi,(%esp)
c010359f:	e8 b6 e5 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01035a4:	fa                   	cli    
    asm volatile ("hlt");
c01035a5:	f4                   	hlt    
c01035a6:	89 3c 24             	mov    %edi,(%esp)
c01035a9:	e8 f0 e5 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c01035ae:	83 c4 10             	add    $0x10,%esp
    assert(next->data.vm_start < next->data.vm_end);
c01035b1:	8b 45 10             	mov    0x10(%ebp),%eax
c01035b4:	8b 48 08             	mov    0x8(%eax),%ecx
c01035b7:	39 48 04             	cmp    %ecx,0x4(%eax)
c01035ba:	0f 82 92 00 00 00    	jb     c0103652 <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_+0x206>
c01035c0:	50                   	push   %eax
c01035c1:	50                   	push   %eax
c01035c2:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c01035c8:	50                   	push   %eax
c01035c9:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c01035cf:	56                   	push   %esi
c01035d0:	e8 c5 14 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01035d5:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c01035db:	5a                   	pop    %edx
c01035dc:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01035e2:	59                   	pop    %ecx
c01035e3:	50                   	push   %eax
c01035e4:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c01035ea:	50                   	push   %eax
c01035eb:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c01035f1:	e8 a4 14 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01035f6:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c01035fc:	83 c4 0c             	add    $0xc,%esp
c01035ff:	56                   	push   %esi
c0103600:	50                   	push   %eax
c0103601:	57                   	push   %edi
c0103602:	e8 b9 e4 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0103607:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c010360d:	89 04 24             	mov    %eax,(%esp)
c0103610:	e8 9f 14 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103615:	89 34 24             	mov    %esi,(%esp)
c0103618:	e8 97 14 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010361d:	58                   	pop    %eax
c010361e:	8d 83 e0 69 fe ff    	lea    -0x19620(%ebx),%eax
c0103624:	5a                   	pop    %edx
c0103625:	50                   	push   %eax
c0103626:	56                   	push   %esi
c0103627:	e8 6e 14 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010362c:	59                   	pop    %ecx
c010362d:	58                   	pop    %eax
c010362e:	56                   	push   %esi
c010362f:	57                   	push   %edi
c0103630:	e8 d9 e5 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0103635:	89 34 24             	mov    %esi,(%esp)
c0103638:	e8 77 14 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010363d:	89 3c 24             	mov    %edi,(%esp)
c0103640:	e8 15 e5 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103645:	fa                   	cli    
    asm volatile ("hlt");
c0103646:	f4                   	hlt    
c0103647:	89 3c 24             	mov    %edi,(%esp)
c010364a:	e8 4f e5 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c010364f:	83 c4 10             	add    $0x10,%esp
c0103652:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0103655:	5b                   	pop    %ebx
c0103656:	5e                   	pop    %esi
c0103657:	5f                   	pop    %edi
c0103658:	5d                   	pop    %ebp
c0103659:	c3                   	ret    

c010365a <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE>:
void VMM::insertVma(List<MM>::DLNode *mm, List<VMA>::DLNode *vma) {
c010365a:	55                   	push   %ebp
c010365b:	89 e5                	mov    %esp,%ebp
c010365d:	57                   	push   %edi
c010365e:	56                   	push   %esi
c010365f:	53                   	push   %ebx
c0103660:	e8 5b d5 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0103665:	81 c3 bb ad 01 00    	add    $0x1adbb,%ebx
c010366b:	81 ec 44 04 00 00    	sub    $0x444,%esp
c0103671:	8b 45 10             	mov    0x10(%ebp),%eax
    OStream out("\n[new] vma: vm_start = ", "blue");
c0103674:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
void VMM::insertVma(List<MM>::DLNode *mm, List<VMA>::DLNode *vma) {
c010367a:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
    OStream out("\n[new] vma: vm_start = ", "blue");
c0103680:	8d 93 36 67 fe ff    	lea    -0x198ca(%ebx),%edx
c0103686:	52                   	push   %edx
c0103687:	57                   	push   %edi
c0103688:	e8 0d 14 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010368d:	8d 93 08 6a fe ff    	lea    -0x195f8(%ebx),%edx
c0103693:	59                   	pop    %ecx
c0103694:	5e                   	pop    %esi
c0103695:	8d b5 d3 fb ff ff    	lea    -0x42d(%ebp),%esi
c010369b:	52                   	push   %edx
c010369c:	56                   	push   %esi
c010369d:	e8 f8 13 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01036a2:	83 c4 0c             	add    $0xc,%esp
c01036a5:	57                   	push   %edi
c01036a6:	56                   	push   %esi
c01036a7:	8d 95 d8 fb ff ff    	lea    -0x428(%ebp),%edx
c01036ad:	52                   	push   %edx
c01036ae:	89 95 c0 fb ff ff    	mov    %edx,-0x440(%ebp)
c01036b4:	e8 07 e4 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c01036b9:	89 34 24             	mov    %esi,(%esp)
c01036bc:	e8 f3 13 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01036c1:	89 3c 24             	mov    %edi,(%esp)
c01036c4:	e8 eb 13 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue(vma->data.vm_start);
c01036c9:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c01036cf:	8b 48 04             	mov    0x4(%eax),%ecx
c01036d2:	58                   	pop    %eax
c01036d3:	5a                   	pop    %edx
c01036d4:	8b 95 c0 fb ff ff    	mov    -0x440(%ebp),%edx
c01036da:	89 8d e0 fd ff ff    	mov    %ecx,-0x220(%ebp)
c01036e0:	57                   	push   %edi
c01036e1:	52                   	push   %edx
c01036e2:	e8 6b e5 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    assert(vma->data.vm_start < vma->data.vm_end);
c01036e7:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c01036ed:	83 c4 10             	add    $0x10,%esp
c01036f0:	8b 48 08             	mov    0x8(%eax),%ecx
c01036f3:	39 48 04             	cmp    %ecx,0x4(%eax)
c01036f6:	0f 82 92 00 00 00    	jb     c010378e <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x134>
c01036fc:	89 85 c0 fb ff ff    	mov    %eax,-0x440(%ebp)
c0103702:	8d 93 51 67 fe ff    	lea    -0x198af(%ebx),%edx
c0103708:	50                   	push   %eax
c0103709:	50                   	push   %eax
c010370a:	52                   	push   %edx
c010370b:	56                   	push   %esi
c010370c:	e8 89 13 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103711:	58                   	pop    %eax
c0103712:	5a                   	pop    %edx
c0103713:	8d 93 5b 67 fe ff    	lea    -0x198a5(%ebx),%edx
c0103719:	52                   	push   %edx
c010371a:	8d 95 ce fb ff ff    	lea    -0x432(%ebp),%edx
c0103720:	52                   	push   %edx
c0103721:	89 95 c4 fb ff ff    	mov    %edx,-0x43c(%ebp)
c0103727:	e8 6e 13 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010372c:	8b 95 c4 fb ff ff    	mov    -0x43c(%ebp),%edx
c0103732:	83 c4 0c             	add    $0xc,%esp
c0103735:	56                   	push   %esi
c0103736:	52                   	push   %edx
c0103737:	57                   	push   %edi
c0103738:	e8 83 e3 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c010373d:	8b 95 c4 fb ff ff    	mov    -0x43c(%ebp),%edx
c0103743:	89 14 24             	mov    %edx,(%esp)
c0103746:	e8 69 13 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010374b:	89 34 24             	mov    %esi,(%esp)
c010374e:	e8 61 13 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103753:	8d 93 20 6a fe ff    	lea    -0x195e0(%ebx),%edx
c0103759:	59                   	pop    %ecx
c010375a:	58                   	pop    %eax
c010375b:	52                   	push   %edx
c010375c:	56                   	push   %esi
c010375d:	e8 38 13 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103762:	58                   	pop    %eax
c0103763:	5a                   	pop    %edx
c0103764:	56                   	push   %esi
c0103765:	57                   	push   %edi
c0103766:	e8 a3 e4 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c010376b:	89 34 24             	mov    %esi,(%esp)
c010376e:	e8 41 13 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103773:	89 3c 24             	mov    %edi,(%esp)
c0103776:	e8 df e3 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010377b:	fa                   	cli    
    asm volatile ("hlt");
c010377c:	f4                   	hlt    
c010377d:	89 3c 24             	mov    %edi,(%esp)
c0103780:	e8 19 e4 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0103785:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c010378b:	83 c4 10             	add    $0x10,%esp
    it.setCurrentNode(headNode.first);
c010378e:	8b 7d 0c             	mov    0xc(%ebp),%edi
c0103791:	8b 77 04             	mov    0x4(%edi),%esi
                    currentNode = node;
c0103794:	89 37                	mov    %esi,(%edi)
    decltype(vma) vmaNode, preVma = nullptr;
c0103796:	31 ff                	xor    %edi,%edi
                    if (!hasNext()) {
c0103798:	85 f6                	test   %esi,%esi
c010379a:	0f 84 da 01 00 00    	je     c010397a <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x320>
        if (vmaNode->data.vm_start > vma->data.vm_start) {
c01037a0:	8b 50 04             	mov    0x4(%eax),%edx
c01037a3:	39 56 04             	cmp    %edx,0x4(%esi)
                    currentNode = currentNode->next;
c01037a6:	8b 4e 14             	mov    0x14(%esi),%ecx
c01037a9:	77 06                	ja     c01037b1 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x157>
c01037ab:	89 f7                	mov    %esi,%edi
c01037ad:	89 ce                	mov    %ecx,%esi
c01037af:	eb e7                	jmp    c0103798 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x13e>
    if (preVma != nullptr) {    // pre-note
c01037b1:	85 ff                	test   %edi,%edi
c01037b3:	74 1a                	je     c01037cf <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x175>
        checkVamOverlap(preVma, vma);
c01037b5:	51                   	push   %ecx
c01037b6:	50                   	push   %eax
c01037b7:	57                   	push   %edi
c01037b8:	ff 75 08             	pushl  0x8(%ebp)
c01037bb:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c01037c1:	e8 86 fc ff ff       	call   c010344c <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_>
c01037c6:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c01037cc:	83 c4 10             	add    $0x10,%esp
        checkVamOverlap(vma, vmaNode);
c01037cf:	52                   	push   %edx
c01037d0:	56                   	push   %esi
c01037d1:	50                   	push   %eax
c01037d2:	ff 75 08             	pushl  0x8(%ebp)
c01037d5:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c01037db:	e8 6c fc ff ff       	call   c010344c <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_>
    vma->data.vm_mm = mm;       // pointer father-MM
c01037e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    if (preVma == nullptr) {
c01037e3:	83 c4 10             	add    $0x10,%esp
    vma->data.vm_mm = mm;       // pointer father-MM
c01037e6:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
    if (preVma == nullptr) {
c01037ec:	85 ff                	test   %edi,%edi
    vma->data.vm_mm = mm;       // pointer father-MM
c01037ee:	89 08                	mov    %ecx,(%eax)
    if (preVma == nullptr) {
c01037f0:	75 52                	jne    c0103844 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x1ea>
    return (headNode.eNum == 0 && headNode.last == nullptr);
c01037f2:	8b 7d 0c             	mov    0xc(%ebp),%edi
c01037f5:	8b 57 0c             	mov    0xc(%edi),%edx
c01037f8:	85 d2                	test   %edx,%edx
c01037fa:	75 0a                	jne    c0103806 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x1ac>
c01037fc:	83 7f 08 00          	cmpl   $0x0,0x8(%edi)
c0103800:	0f 84 fa 00 00 00    	je     c0103900 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x2a6>
        node->next = headNode.first;
c0103806:	8b 7d 0c             	mov    0xc(%ebp),%edi
        headNode.eNum++;
c0103809:	42                   	inc    %edx
        node->pre = nullptr;
c010380a:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        node->next = headNode.first;
c0103811:	8b 4f 04             	mov    0x4(%edi),%ecx
c0103814:	89 48 14             	mov    %ecx,0x14(%eax)
        headNode.first->pre = node;
c0103817:	89 41 10             	mov    %eax,0x10(%ecx)
        headNode.first = node;
c010381a:	89 47 04             	mov    %eax,0x4(%edi)
        headNode.eNum++;
c010381d:	89 57 0c             	mov    %edx,0xc(%edi)
c0103820:	e9 04 01 00 00       	jmp    c0103929 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x2cf>
        checkVamOverlap(preVma, vma);
c0103825:	52                   	push   %edx
c0103826:	50                   	push   %eax
c0103827:	57                   	push   %edi
c0103828:	ff 75 08             	pushl  0x8(%ebp)
c010382b:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c0103831:	e8 16 fc ff ff       	call   c010344c <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_>
    vma->data.vm_mm = mm;       // pointer father-MM
c0103836:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103839:	83 c4 10             	add    $0x10,%esp
c010383c:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
c0103842:	89 10                	mov    %edx,(%eax)
        DEBUGPRINT("Inert-->mid");
c0103844:	56                   	push   %esi
c0103845:	56                   	push   %esi
c0103846:	8d 8b 51 67 fe ff    	lea    -0x198af(%ebx),%ecx
c010384c:	51                   	push   %ecx
c010384d:	8d b5 d3 fb ff ff    	lea    -0x42d(%ebp),%esi
c0103853:	56                   	push   %esi
c0103854:	89 85 bc fb ff ff    	mov    %eax,-0x444(%ebp)
c010385a:	e8 3b 12 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010385f:	8d 8b c9 68 fe ff    	lea    -0x19737(%ebx),%ecx
c0103865:	58                   	pop    %eax
c0103866:	5a                   	pop    %edx
c0103867:	51                   	push   %ecx
c0103868:	8d 8d ce fb ff ff    	lea    -0x432(%ebp),%ecx
c010386e:	51                   	push   %ecx
c010386f:	89 8d c4 fb ff ff    	mov    %ecx,-0x43c(%ebp)
c0103875:	e8 20 12 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010387a:	8b 8d c4 fb ff ff    	mov    -0x43c(%ebp),%ecx
c0103880:	83 c4 0c             	add    $0xc,%esp
c0103883:	56                   	push   %esi
c0103884:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c010388a:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
c0103890:	51                   	push   %ecx
c0103891:	50                   	push   %eax
c0103892:	89 8d c0 fb ff ff    	mov    %ecx,-0x440(%ebp)
c0103898:	e8 23 e2 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c010389d:	8b 8d c0 fb ff ff    	mov    -0x440(%ebp),%ecx
c01038a3:	89 0c 24             	mov    %ecx,(%esp)
c01038a6:	e8 09 12 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01038ab:	89 34 24             	mov    %esi,(%esp)
c01038ae:	e8 01 12 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01038b3:	59                   	pop    %ecx
c01038b4:	8d 8b 46 6a fe ff    	lea    -0x195ba(%ebx),%ecx
c01038ba:	58                   	pop    %eax
c01038bb:	51                   	push   %ecx
c01038bc:	56                   	push   %esi
c01038bd:	e8 d8 11 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01038c2:	58                   	pop    %eax
c01038c3:	5a                   	pop    %edx
c01038c4:	56                   	push   %esi
c01038c5:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c01038cb:	e8 3e e3 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01038d0:	89 34 24             	mov    %esi,(%esp)
c01038d3:	e8 dc 11 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01038d8:	59                   	pop    %ecx
c01038d9:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c01038df:	e8 76 e2 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
c01038e4:	5e                   	pop    %esi
c01038e5:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c01038eb:	e8 ae e2 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
    if (node1->next == nullptr) {
c01038f0:	8b 4f 14             	mov    0x14(%edi),%ecx
c01038f3:	83 c4 10             	add    $0x10,%esp
c01038f6:	8b 85 bc fb ff ff    	mov    -0x444(%ebp),%eax
c01038fc:	85 c9                	test   %ecx,%ecx
c01038fe:	75 10                	jne    c0103910 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x2b6>
        addLNode(*node2);
c0103900:	51                   	push   %ecx
c0103901:	51                   	push   %ecx
c0103902:	50                   	push   %eax
c0103903:	ff 75 0c             	pushl  0xc(%ebp)
c0103906:	e8 97 0d 00 00       	call   c01046a2 <_ZN4ListIN3VMM3VMAEE8addLNodeERNS2_6DLNodeE>
c010390b:	83 c4 10             	add    $0x10,%esp
c010390e:	eb 19                	jmp    c0103929 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x2cf>
        node2->next = node1->next;
c0103910:	89 48 14             	mov    %ecx,0x14(%eax)
        if (node1->next != nullptr) {
c0103913:	8b 4f 14             	mov    0x14(%edi),%ecx
        node2->pre = node1;
c0103916:	89 78 10             	mov    %edi,0x10(%eax)
        if (node1->next != nullptr) {
c0103919:	85 c9                	test   %ecx,%ecx
c010391b:	74 03                	je     c0103920 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x2c6>
            node1->next->pre = node2;
c010391d:	89 41 10             	mov    %eax,0x10(%ecx)
        node1->next = node2;
c0103920:	89 47 14             	mov    %eax,0x14(%edi)
        headNode.eNum++;
c0103923:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103926:	ff 40 0c             	incl   0xc(%eax)
    out.write("\nnodeNum: ");
c0103929:	51                   	push   %ecx
c010392a:	51                   	push   %ecx
c010392b:	8d 83 52 6a fe ff    	lea    -0x195ae(%ebx),%eax
c0103931:	50                   	push   %eax
c0103932:	8d b5 e0 fd ff ff    	lea    -0x220(%ebp),%esi
c0103938:	56                   	push   %esi
c0103939:	e8 5c 11 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010393e:	5f                   	pop    %edi
c010393f:	8d bd d8 fb ff ff    	lea    -0x428(%ebp),%edi
c0103945:	58                   	pop    %eax
c0103946:	56                   	push   %esi
c0103947:	57                   	push   %edi
c0103948:	e8 c1 e2 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c010394d:	89 34 24             	mov    %esi,(%esp)
c0103950:	e8 5f 11 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue((mm->data.vmaList.length()));
c0103955:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103958:	8b 40 0c             	mov    0xc(%eax),%eax
c010395b:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)
c0103961:	58                   	pop    %eax
c0103962:	5a                   	pop    %edx
c0103963:	56                   	push   %esi
c0103964:	57                   	push   %edi
c0103965:	e8 e8 e2 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    OStream out("\n[new] vma: vm_start = ", "blue");
c010396a:	89 3c 24             	mov    %edi,(%esp)
c010396d:	e8 2c e2 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
}
c0103972:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0103975:	5b                   	pop    %ebx
c0103976:	5e                   	pop    %esi
c0103977:	5f                   	pop    %edi
c0103978:	5d                   	pop    %ebp
c0103979:	c3                   	ret    
    if (preVma != nullptr) {    // pre-note
c010397a:	85 ff                	test   %edi,%edi
c010397c:	0f 85 a3 fe ff ff    	jne    c0103825 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x1cb>
    vma->data.vm_mm = mm;       // pointer father-MM
c0103982:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103985:	89 10                	mov    %edx,(%eax)
c0103987:	e9 66 fe ff ff       	jmp    c01037f2 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x198>

c010398c <_ZN3VMM8checkVmaEv>:
void VMM::checkVma() {
c010398c:	55                   	push   %ebp
c010398d:	89 e5                	mov    %esp,%ebp
c010398f:	57                   	push   %edi
c0103990:	56                   	push   %esi
c0103991:	53                   	push   %ebx
c0103992:	e8 29 d2 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0103997:	81 c3 89 aa 01 00    	add    $0x1aa89,%ebx
c010399d:	81 ec 54 04 00 00    	sub    $0x454,%esp
    DEBUGPRINT("VMM::checkVma");
c01039a3:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c01039a9:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01039af:	8d 93 51 67 fe ff    	lea    -0x198af(%ebx),%edx
c01039b5:	52                   	push   %edx
c01039b6:	56                   	push   %esi
c01039b7:	89 95 bc fb ff ff    	mov    %edx,-0x444(%ebp)
c01039bd:	e8 d8 10 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01039c2:	58                   	pop    %eax
c01039c3:	8d 83 c9 68 fe ff    	lea    -0x19737(%ebx),%eax
c01039c9:	5a                   	pop    %edx
c01039ca:	50                   	push   %eax
c01039cb:	8d 85 d3 fb ff ff    	lea    -0x42d(%ebp),%eax
c01039d1:	50                   	push   %eax
c01039d2:	89 85 c0 fb ff ff    	mov    %eax,-0x440(%ebp)
c01039d8:	e8 bd 10 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01039dd:	83 c4 0c             	add    $0xc,%esp
c01039e0:	56                   	push   %esi
c01039e1:	ff b5 c0 fb ff ff    	pushl  -0x440(%ebp)
c01039e7:	57                   	push   %edi
c01039e8:	e8 d3 e0 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c01039ed:	59                   	pop    %ecx
c01039ee:	ff b5 c0 fb ff ff    	pushl  -0x440(%ebp)
c01039f4:	e8 bb 10 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01039f9:	89 34 24             	mov    %esi,(%esp)
c01039fc:	e8 b3 10 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103a01:	58                   	pop    %eax
c0103a02:	8d 83 5d 6a fe ff    	lea    -0x195a3(%ebx),%eax
c0103a08:	5a                   	pop    %edx
c0103a09:	50                   	push   %eax
c0103a0a:	56                   	push   %esi
c0103a0b:	e8 8a 10 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103a10:	59                   	pop    %ecx
c0103a11:	58                   	pop    %eax
c0103a12:	56                   	push   %esi
c0103a13:	57                   	push   %edi
c0103a14:	e8 f5 e1 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0103a19:	89 34 24             	mov    %esi,(%esp)
c0103a1c:	e8 93 10 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103a21:	89 3c 24             	mov    %edi,(%esp)
c0103a24:	e8 31 e1 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
c0103a29:	89 3c 24             	mov    %edi,(%esp)
c0103a2c:	e8 6d e1 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
    uint32_t nr_free_pages_store = kernel::pmm.numFreePages();
c0103a31:	58                   	pop    %eax
c0103a32:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
c0103a38:	e8 77 f2 ff ff       	call   c0102cb4 <_ZN5PhyMM12numFreePagesEv>
    auto mm = mmCreate();
c0103a3d:	58                   	pop    %eax
c0103a3e:	ff 75 08             	pushl  0x8(%ebp)
c0103a41:	e8 7c f8 ff ff       	call   c01032c2 <_ZN3VMM8mmCreateEv>
    assert(mm != nullptr);
c0103a46:	83 c4 10             	add    $0x10,%esp
c0103a49:	8b 95 bc fb ff ff    	mov    -0x444(%ebp),%edx
c0103a4f:	85 c0                	test   %eax,%eax
    auto mm = mmCreate();
c0103a51:	89 85 c4 fb ff ff    	mov    %eax,-0x43c(%ebp)
    assert(mm != nullptr);
c0103a57:	75 76                	jne    c0103acf <_ZN3VMM8checkVmaEv+0x143>
c0103a59:	50                   	push   %eax
c0103a5a:	50                   	push   %eax
c0103a5b:	52                   	push   %edx
c0103a5c:	56                   	push   %esi
c0103a5d:	e8 38 10 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103a62:	58                   	pop    %eax
c0103a63:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c0103a69:	5a                   	pop    %edx
c0103a6a:	50                   	push   %eax
c0103a6b:	ff b5 c0 fb ff ff    	pushl  -0x440(%ebp)
c0103a71:	e8 24 10 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103a76:	83 c4 0c             	add    $0xc,%esp
c0103a79:	56                   	push   %esi
c0103a7a:	ff b5 c0 fb ff ff    	pushl  -0x440(%ebp)
c0103a80:	57                   	push   %edi
c0103a81:	e8 3a e0 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0103a86:	59                   	pop    %ecx
c0103a87:	ff b5 c0 fb ff ff    	pushl  -0x440(%ebp)
c0103a8d:	e8 22 10 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103a92:	89 34 24             	mov    %esi,(%esp)
c0103a95:	e8 1a 10 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103a9a:	58                   	pop    %eax
c0103a9b:	8d 83 6b 6a fe ff    	lea    -0x19595(%ebx),%eax
c0103aa1:	5a                   	pop    %edx
c0103aa2:	50                   	push   %eax
c0103aa3:	56                   	push   %esi
c0103aa4:	e8 f1 0f 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103aa9:	59                   	pop    %ecx
c0103aaa:	58                   	pop    %eax
c0103aab:	56                   	push   %esi
c0103aac:	57                   	push   %edi
c0103aad:	e8 5c e1 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0103ab2:	89 34 24             	mov    %esi,(%esp)
c0103ab5:	e8 fa 0f 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103aba:	89 3c 24             	mov    %edi,(%esp)
c0103abd:	e8 98 e0 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103ac2:	fa                   	cli    
    asm volatile ("hlt");
c0103ac3:	f4                   	hlt    
c0103ac4:	89 3c 24             	mov    %edi,(%esp)
c0103ac7:	e8 d2 e0 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0103acc:	83 c4 10             	add    $0x10,%esp
void VMM::checkVma() {
c0103acf:	c7 85 c0 fb ff ff 32 	movl   $0x32,-0x440(%ebp)
c0103ad6:	00 00 00 
        auto *vma = vmaCreate(i * 5, i * 5 + 2, 0);
c0103ad9:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c0103adf:	6a 00                	push   $0x0
c0103ae1:	83 c0 02             	add    $0x2,%eax
c0103ae4:	50                   	push   %eax
c0103ae5:	ff b5 c0 fb ff ff    	pushl  -0x440(%ebp)
c0103aeb:	ff 75 08             	pushl  0x8(%ebp)
c0103aee:	e8 75 f6 ff ff       	call   c0103168 <_ZN3VMM9vmaCreateEjjj>
        assert(vma != nullptr);
c0103af3:	83 c4 10             	add    $0x10,%esp
c0103af6:	85 c0                	test   %eax,%eax
c0103af8:	0f 85 9e 00 00 00    	jne    c0103b9c <_ZN3VMM8checkVmaEv+0x210>
c0103afe:	51                   	push   %ecx
c0103aff:	51                   	push   %ecx
c0103b00:	8d 93 51 67 fe ff    	lea    -0x198af(%ebx),%edx
c0103b06:	52                   	push   %edx
c0103b07:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c0103b0d:	56                   	push   %esi
c0103b0e:	89 85 b8 fb ff ff    	mov    %eax,-0x448(%ebp)
c0103b14:	e8 81 0f 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103b19:	8d 93 5b 67 fe ff    	lea    -0x198a5(%ebx),%edx
c0103b1f:	5f                   	pop    %edi
c0103b20:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0103b26:	58                   	pop    %eax
c0103b27:	52                   	push   %edx
c0103b28:	8d 95 d3 fb ff ff    	lea    -0x42d(%ebp),%edx
c0103b2e:	52                   	push   %edx
c0103b2f:	89 95 bc fb ff ff    	mov    %edx,-0x444(%ebp)
c0103b35:	e8 60 0f 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103b3a:	8b 95 bc fb ff ff    	mov    -0x444(%ebp),%edx
c0103b40:	83 c4 0c             	add    $0xc,%esp
c0103b43:	56                   	push   %esi
c0103b44:	52                   	push   %edx
c0103b45:	57                   	push   %edi
c0103b46:	e8 75 df ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0103b4b:	8b 95 bc fb ff ff    	mov    -0x444(%ebp),%edx
c0103b51:	89 14 24             	mov    %edx,(%esp)
c0103b54:	e8 5b 0f 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103b59:	89 34 24             	mov    %esi,(%esp)
c0103b5c:	e8 53 0f 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103b61:	58                   	pop    %eax
c0103b62:	5a                   	pop    %edx
c0103b63:	8d 93 79 6a fe ff    	lea    -0x19587(%ebx),%edx
c0103b69:	52                   	push   %edx
c0103b6a:	56                   	push   %esi
c0103b6b:	e8 2a 0f 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103b70:	59                   	pop    %ecx
c0103b71:	58                   	pop    %eax
c0103b72:	56                   	push   %esi
c0103b73:	57                   	push   %edi
c0103b74:	e8 95 e0 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0103b79:	89 34 24             	mov    %esi,(%esp)
c0103b7c:	e8 33 0f 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103b81:	89 3c 24             	mov    %edi,(%esp)
c0103b84:	e8 d1 df ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103b89:	fa                   	cli    
    asm volatile ("hlt");
c0103b8a:	f4                   	hlt    
c0103b8b:	89 3c 24             	mov    %edi,(%esp)
c0103b8e:	e8 0b e0 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0103b93:	8b 85 b8 fb ff ff    	mov    -0x448(%ebp),%eax
c0103b99:	83 c4 10             	add    $0x10,%esp
        insertVma(mm, vma);
c0103b9c:	52                   	push   %edx
c0103b9d:	50                   	push   %eax
c0103b9e:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c0103ba4:	ff 75 08             	pushl  0x8(%ebp)
c0103ba7:	e8 ae fa ff ff       	call   c010365a <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE>
    for (uint32_t i = step1; i >= 1; i--) {
c0103bac:	83 c4 10             	add    $0x10,%esp
c0103baf:	83 ad c0 fb ff ff 05 	subl   $0x5,-0x440(%ebp)
c0103bb6:	0f 85 1d ff ff ff    	jne    c0103ad9 <_ZN3VMM8checkVmaEv+0x14d>
c0103bbc:	c7 85 c0 fb ff ff 37 	movl   $0x37,-0x440(%ebp)
c0103bc3:	00 00 00 
        auto *vma = vmaCreate(i * 5, i * 5 + 2, 0);
c0103bc6:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c0103bcc:	6a 00                	push   $0x0
c0103bce:	83 c0 02             	add    $0x2,%eax
c0103bd1:	50                   	push   %eax
c0103bd2:	ff b5 c0 fb ff ff    	pushl  -0x440(%ebp)
c0103bd8:	ff 75 08             	pushl  0x8(%ebp)
c0103bdb:	e8 88 f5 ff ff       	call   c0103168 <_ZN3VMM9vmaCreateEjjj>
        assert(vma != nullptr);
c0103be0:	83 c4 10             	add    $0x10,%esp
c0103be3:	85 c0                	test   %eax,%eax
c0103be5:	0f 85 9e 00 00 00    	jne    c0103c89 <_ZN3VMM8checkVmaEv+0x2fd>
c0103beb:	56                   	push   %esi
c0103bec:	56                   	push   %esi
c0103bed:	8d 93 51 67 fe ff    	lea    -0x198af(%ebx),%edx
c0103bf3:	52                   	push   %edx
c0103bf4:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c0103bfa:	56                   	push   %esi
c0103bfb:	89 85 b8 fb ff ff    	mov    %eax,-0x448(%ebp)
c0103c01:	e8 94 0e 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103c06:	8d 93 5b 67 fe ff    	lea    -0x198a5(%ebx),%edx
c0103c0c:	5f                   	pop    %edi
c0103c0d:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0103c13:	58                   	pop    %eax
c0103c14:	52                   	push   %edx
c0103c15:	8d 95 d3 fb ff ff    	lea    -0x42d(%ebp),%edx
c0103c1b:	52                   	push   %edx
c0103c1c:	89 95 bc fb ff ff    	mov    %edx,-0x444(%ebp)
c0103c22:	e8 73 0e 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103c27:	8b 95 bc fb ff ff    	mov    -0x444(%ebp),%edx
c0103c2d:	83 c4 0c             	add    $0xc,%esp
c0103c30:	56                   	push   %esi
c0103c31:	52                   	push   %edx
c0103c32:	57                   	push   %edi
c0103c33:	e8 88 de ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0103c38:	8b 95 bc fb ff ff    	mov    -0x444(%ebp),%edx
c0103c3e:	89 14 24             	mov    %edx,(%esp)
c0103c41:	e8 6e 0e 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103c46:	89 34 24             	mov    %esi,(%esp)
c0103c49:	e8 66 0e 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103c4e:	58                   	pop    %eax
c0103c4f:	5a                   	pop    %edx
c0103c50:	8d 93 79 6a fe ff    	lea    -0x19587(%ebx),%edx
c0103c56:	52                   	push   %edx
c0103c57:	56                   	push   %esi
c0103c58:	e8 3d 0e 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103c5d:	59                   	pop    %ecx
c0103c5e:	58                   	pop    %eax
c0103c5f:	56                   	push   %esi
c0103c60:	57                   	push   %edi
c0103c61:	e8 a8 df ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0103c66:	89 34 24             	mov    %esi,(%esp)
c0103c69:	e8 46 0e 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103c6e:	89 3c 24             	mov    %edi,(%esp)
c0103c71:	e8 e4 de ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103c76:	fa                   	cli    
    asm volatile ("hlt");
c0103c77:	f4                   	hlt    
c0103c78:	89 3c 24             	mov    %edi,(%esp)
c0103c7b:	e8 1e df ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0103c80:	8b 85 b8 fb ff ff    	mov    -0x448(%ebp),%eax
c0103c86:	83 c4 10             	add    $0x10,%esp
        insertVma(mm, vma);
c0103c89:	51                   	push   %ecx
c0103c8a:	50                   	push   %eax
c0103c8b:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c0103c91:	ff 75 08             	pushl  0x8(%ebp)
c0103c94:	e8 c1 f9 ff ff       	call   c010365a <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE>
    for (uint32_t i = step1 + 1; i <= step2; i++) {
c0103c99:	83 c4 10             	add    $0x10,%esp
c0103c9c:	83 85 c0 fb ff ff 05 	addl   $0x5,-0x440(%ebp)
c0103ca3:	81 bd c0 fb ff ff f9 	cmpl   $0x1f9,-0x440(%ebp)
c0103caa:	01 00 00 
c0103cad:	0f 85 13 ff ff ff    	jne    c0103bc6 <_ZN3VMM8checkVmaEv+0x23a>
    it.setCurrentNode(headNode.first);
c0103cb3:	8b 85 c4 fb ff ff    	mov    -0x43c(%ebp),%eax
    return it;
c0103cb9:	31 d2                	xor    %edx,%edx
                    currentNode = node;
c0103cbb:	8b 8d c4 fb ff ff    	mov    -0x43c(%ebp),%ecx
    it.setCurrentNode(headNode.first);
c0103cc1:	8b 40 04             	mov    0x4(%eax),%eax
                    if (!hasNext()) {
c0103cc4:	85 c0                	test   %eax,%eax
                    currentNode = node;
c0103cc6:	89 01                	mov    %eax,(%ecx)
                    if (!hasNext()) {
c0103cc8:	74 03                	je     c0103ccd <_ZN3VMM8checkVmaEv+0x341>
                    currentNode = currentNode->next;
c0103cca:	8b 50 14             	mov    0x14(%eax),%edx
    return it;
c0103ccd:	c7 85 c0 fb ff ff 05 	movl   $0x5,-0x440(%ebp)
c0103cd4:	00 00 00 
        assert(vmaNode != nullptr);
c0103cd7:	85 c0                	test   %eax,%eax
c0103cd9:	0f 85 aa 00 00 00    	jne    c0103d89 <_ZN3VMM8checkVmaEv+0x3fd>
c0103cdf:	89 85 b8 fb ff ff    	mov    %eax,-0x448(%ebp)
c0103ce5:	8d 8b 51 67 fe ff    	lea    -0x198af(%ebx),%ecx
c0103ceb:	50                   	push   %eax
c0103cec:	50                   	push   %eax
c0103ced:	51                   	push   %ecx
c0103cee:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c0103cf4:	56                   	push   %esi
c0103cf5:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0103cfb:	89 95 b4 fb ff ff    	mov    %edx,-0x44c(%ebp)
c0103d01:	e8 94 0d 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103d06:	8d 8b 5b 67 fe ff    	lea    -0x198a5(%ebx),%ecx
c0103d0c:	58                   	pop    %eax
c0103d0d:	5a                   	pop    %edx
c0103d0e:	51                   	push   %ecx
c0103d0f:	8d 8d d3 fb ff ff    	lea    -0x42d(%ebp),%ecx
c0103d15:	51                   	push   %ecx
c0103d16:	89 8d bc fb ff ff    	mov    %ecx,-0x444(%ebp)
c0103d1c:	e8 79 0d 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103d21:	8b 8d bc fb ff ff    	mov    -0x444(%ebp),%ecx
c0103d27:	83 c4 0c             	add    $0xc,%esp
c0103d2a:	56                   	push   %esi
c0103d2b:	51                   	push   %ecx
c0103d2c:	57                   	push   %edi
c0103d2d:	e8 8e dd ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0103d32:	8b 8d bc fb ff ff    	mov    -0x444(%ebp),%ecx
c0103d38:	89 0c 24             	mov    %ecx,(%esp)
c0103d3b:	e8 74 0d 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103d40:	89 34 24             	mov    %esi,(%esp)
c0103d43:	e8 6c 0d 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103d48:	59                   	pop    %ecx
c0103d49:	8d 8b 88 6a fe ff    	lea    -0x19578(%ebx),%ecx
c0103d4f:	58                   	pop    %eax
c0103d50:	51                   	push   %ecx
c0103d51:	56                   	push   %esi
c0103d52:	e8 43 0d 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103d57:	58                   	pop    %eax
c0103d58:	5a                   	pop    %edx
c0103d59:	56                   	push   %esi
c0103d5a:	57                   	push   %edi
c0103d5b:	e8 ae de ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0103d60:	89 34 24             	mov    %esi,(%esp)
c0103d63:	e8 4c 0d 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103d68:	89 3c 24             	mov    %edi,(%esp)
c0103d6b:	e8 ea dd ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103d70:	fa                   	cli    
    asm volatile ("hlt");
c0103d71:	f4                   	hlt    
c0103d72:	89 3c 24             	mov    %edi,(%esp)
c0103d75:	e8 24 de ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0103d7a:	8b 95 b4 fb ff ff    	mov    -0x44c(%ebp),%edx
c0103d80:	83 c4 10             	add    $0x10,%esp
c0103d83:	8b 85 b8 fb ff ff    	mov    -0x448(%ebp),%eax
        assert(vmaNode->data.vm_start == i * 5 && vmaNode->data.vm_end == i * 5 + 2);
c0103d89:	8b 8d c0 fb ff ff    	mov    -0x440(%ebp),%ecx
c0103d8f:	39 48 04             	cmp    %ecx,0x4(%eax)
c0103d92:	75 0c                	jne    c0103da0 <_ZN3VMM8checkVmaEv+0x414>
c0103d94:	83 c1 02             	add    $0x2,%ecx
c0103d97:	39 48 08             	cmp    %ecx,0x8(%eax)
c0103d9a:	0f 84 9e 00 00 00    	je     c0103e3e <_ZN3VMM8checkVmaEv+0x4b2>
c0103da0:	56                   	push   %esi
c0103da1:	56                   	push   %esi
c0103da2:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c0103da8:	50                   	push   %eax
c0103da9:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c0103daf:	56                   	push   %esi
c0103db0:	89 95 b8 fb ff ff    	mov    %edx,-0x448(%ebp)
c0103db6:	e8 df 0c 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103dbb:	5f                   	pop    %edi
c0103dbc:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0103dc2:	58                   	pop    %eax
c0103dc3:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c0103dc9:	50                   	push   %eax
c0103dca:	8d 85 d3 fb ff ff    	lea    -0x42d(%ebp),%eax
c0103dd0:	50                   	push   %eax
c0103dd1:	89 85 bc fb ff ff    	mov    %eax,-0x444(%ebp)
c0103dd7:	e8 be 0c 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103ddc:	8b 85 bc fb ff ff    	mov    -0x444(%ebp),%eax
c0103de2:	83 c4 0c             	add    $0xc,%esp
c0103de5:	56                   	push   %esi
c0103de6:	50                   	push   %eax
c0103de7:	57                   	push   %edi
c0103de8:	e8 d3 dc ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0103ded:	8b 85 bc fb ff ff    	mov    -0x444(%ebp),%eax
c0103df3:	89 04 24             	mov    %eax,(%esp)
c0103df6:	e8 b9 0c 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103dfb:	89 34 24             	mov    %esi,(%esp)
c0103dfe:	e8 b1 0c 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103e03:	58                   	pop    %eax
c0103e04:	8d 83 9b 6a fe ff    	lea    -0x19565(%ebx),%eax
c0103e0a:	5a                   	pop    %edx
c0103e0b:	50                   	push   %eax
c0103e0c:	56                   	push   %esi
c0103e0d:	e8 88 0c 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103e12:	59                   	pop    %ecx
c0103e13:	58                   	pop    %eax
c0103e14:	56                   	push   %esi
c0103e15:	57                   	push   %edi
c0103e16:	e8 f3 dd ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0103e1b:	89 34 24             	mov    %esi,(%esp)
c0103e1e:	e8 91 0c 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103e23:	89 3c 24             	mov    %edi,(%esp)
c0103e26:	e8 2f dd ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103e2b:	fa                   	cli    
    asm volatile ("hlt");
c0103e2c:	f4                   	hlt    
c0103e2d:	89 3c 24             	mov    %edi,(%esp)
c0103e30:	e8 69 dd ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0103e35:	8b 95 b8 fb ff ff    	mov    -0x448(%ebp),%edx
c0103e3b:	83 c4 10             	add    $0x10,%esp
                    if (!hasNext()) {
c0103e3e:	31 c9                	xor    %ecx,%ecx
c0103e40:	85 d2                	test   %edx,%edx
c0103e42:	74 03                	je     c0103e47 <_ZN3VMM8checkVmaEv+0x4bb>
                    currentNode = currentNode->next;
c0103e44:	8b 4a 14             	mov    0x14(%edx),%ecx
c0103e47:	83 85 c0 fb ff ff 05 	addl   $0x5,-0x440(%ebp)
c0103e4e:	89 d0                	mov    %edx,%eax
    for (uint32_t i = 1; i <= step2; i++) {
c0103e50:	81 bd c0 fb ff ff f9 	cmpl   $0x1f9,-0x440(%ebp)
c0103e57:	01 00 00 
c0103e5a:	74 07                	je     c0103e63 <_ZN3VMM8checkVmaEv+0x4d7>
c0103e5c:	89 ca                	mov    %ecx,%edx
c0103e5e:	e9 74 fe ff ff       	jmp    c0103cd7 <_ZN3VMM8checkVmaEv+0x34b>
    for (uint32_t i = 5; i <= 5 * step2; i += 5) {      // 5 ~ 500
c0103e63:	c7 85 c0 fb ff ff 05 	movl   $0x5,-0x440(%ebp)
c0103e6a:	00 00 00 
        auto vma1 = findVma(mm, i);
c0103e6d:	51                   	push   %ecx
c0103e6e:	ff b5 c0 fb ff ff    	pushl  -0x440(%ebp)
c0103e74:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c0103e7a:	ff 75 08             	pushl  0x8(%ebp)
c0103e7d:	e8 a2 f2 ff ff       	call   c0103124 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma1 != nullptr);
c0103e82:	83 c4 10             	add    $0x10,%esp
c0103e85:	85 c0                	test   %eax,%eax
        auto vma1 = findVma(mm, i);
c0103e87:	89 85 bc fb ff ff    	mov    %eax,-0x444(%ebp)
        assert(vma1 != nullptr);
c0103e8d:	0f 85 92 00 00 00    	jne    c0103f25 <_ZN3VMM8checkVmaEv+0x599>
c0103e93:	50                   	push   %eax
c0103e94:	50                   	push   %eax
c0103e95:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c0103e9b:	50                   	push   %eax
c0103e9c:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c0103ea2:	56                   	push   %esi
c0103ea3:	e8 f2 0b 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103ea8:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0103eae:	58                   	pop    %eax
c0103eaf:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c0103eb5:	5a                   	pop    %edx
c0103eb6:	50                   	push   %eax
c0103eb7:	8d 85 d3 fb ff ff    	lea    -0x42d(%ebp),%eax
c0103ebd:	50                   	push   %eax
c0103ebe:	89 85 b8 fb ff ff    	mov    %eax,-0x448(%ebp)
c0103ec4:	e8 d1 0b 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103ec9:	8b 85 b8 fb ff ff    	mov    -0x448(%ebp),%eax
c0103ecf:	83 c4 0c             	add    $0xc,%esp
c0103ed2:	56                   	push   %esi
c0103ed3:	50                   	push   %eax
c0103ed4:	57                   	push   %edi
c0103ed5:	e8 e6 db ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0103eda:	8b 85 b8 fb ff ff    	mov    -0x448(%ebp),%eax
c0103ee0:	89 04 24             	mov    %eax,(%esp)
c0103ee3:	e8 cc 0b 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103ee8:	89 34 24             	mov    %esi,(%esp)
c0103eeb:	e8 c4 0b 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103ef0:	59                   	pop    %ecx
c0103ef1:	58                   	pop    %eax
c0103ef2:	8d 83 e0 6a fe ff    	lea    -0x19520(%ebx),%eax
c0103ef8:	50                   	push   %eax
c0103ef9:	56                   	push   %esi
c0103efa:	e8 9b 0b 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103eff:	58                   	pop    %eax
c0103f00:	5a                   	pop    %edx
c0103f01:	56                   	push   %esi
c0103f02:	57                   	push   %edi
c0103f03:	e8 06 dd ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0103f08:	89 34 24             	mov    %esi,(%esp)
c0103f0b:	e8 a4 0b 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103f10:	89 3c 24             	mov    %edi,(%esp)
c0103f13:	e8 42 dc ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103f18:	fa                   	cli    
    asm volatile ("hlt");
c0103f19:	f4                   	hlt    
c0103f1a:	89 3c 24             	mov    %edi,(%esp)
c0103f1d:	e8 7c dc ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0103f22:	83 c4 10             	add    $0x10,%esp
        auto vma2 = findVma(mm, i + 1);
c0103f25:	50                   	push   %eax
c0103f26:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c0103f2c:	40                   	inc    %eax
c0103f2d:	50                   	push   %eax
c0103f2e:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c0103f34:	ff 75 08             	pushl  0x8(%ebp)
c0103f37:	e8 e8 f1 ff ff       	call   c0103124 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma2 != nullptr);
c0103f3c:	83 c4 10             	add    $0x10,%esp
c0103f3f:	85 c0                	test   %eax,%eax
        auto vma2 = findVma(mm, i + 1);
c0103f41:	89 85 b8 fb ff ff    	mov    %eax,-0x448(%ebp)
        assert(vma2 != nullptr);
c0103f47:	0f 85 92 00 00 00    	jne    c0103fdf <_ZN3VMM8checkVmaEv+0x653>
c0103f4d:	56                   	push   %esi
c0103f4e:	56                   	push   %esi
c0103f4f:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c0103f55:	50                   	push   %eax
c0103f56:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c0103f5c:	56                   	push   %esi
c0103f5d:	e8 38 0b 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103f62:	5f                   	pop    %edi
c0103f63:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0103f69:	58                   	pop    %eax
c0103f6a:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c0103f70:	50                   	push   %eax
c0103f71:	8d 85 d3 fb ff ff    	lea    -0x42d(%ebp),%eax
c0103f77:	50                   	push   %eax
c0103f78:	89 85 b4 fb ff ff    	mov    %eax,-0x44c(%ebp)
c0103f7e:	e8 17 0b 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103f83:	8b 85 b4 fb ff ff    	mov    -0x44c(%ebp),%eax
c0103f89:	83 c4 0c             	add    $0xc,%esp
c0103f8c:	56                   	push   %esi
c0103f8d:	50                   	push   %eax
c0103f8e:	57                   	push   %edi
c0103f8f:	e8 2c db ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0103f94:	8b 85 b4 fb ff ff    	mov    -0x44c(%ebp),%eax
c0103f9a:	89 04 24             	mov    %eax,(%esp)
c0103f9d:	e8 12 0b 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103fa2:	89 34 24             	mov    %esi,(%esp)
c0103fa5:	e8 0a 0b 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103faa:	58                   	pop    %eax
c0103fab:	8d 83 f0 6a fe ff    	lea    -0x19510(%ebx),%eax
c0103fb1:	5a                   	pop    %edx
c0103fb2:	50                   	push   %eax
c0103fb3:	56                   	push   %esi
c0103fb4:	e8 e1 0a 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0103fb9:	59                   	pop    %ecx
c0103fba:	58                   	pop    %eax
c0103fbb:	56                   	push   %esi
c0103fbc:	57                   	push   %edi
c0103fbd:	e8 4c dc ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0103fc2:	89 34 24             	mov    %esi,(%esp)
c0103fc5:	e8 ea 0a 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0103fca:	89 3c 24             	mov    %edi,(%esp)
c0103fcd:	e8 88 db ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103fd2:	fa                   	cli    
    asm volatile ("hlt");
c0103fd3:	f4                   	hlt    
c0103fd4:	89 3c 24             	mov    %edi,(%esp)
c0103fd7:	e8 c2 db ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0103fdc:	83 c4 10             	add    $0x10,%esp
c0103fdf:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
        auto vma3 = findVma(mm, i + 2);
c0103fe5:	51                   	push   %ecx
c0103fe6:	83 c0 02             	add    $0x2,%eax
c0103fe9:	50                   	push   %eax
c0103fea:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c0103ff0:	89 85 b4 fb ff ff    	mov    %eax,-0x44c(%ebp)
c0103ff6:	ff 75 08             	pushl  0x8(%ebp)
c0103ff9:	e8 26 f1 ff ff       	call   c0103124 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma3 == nullptr);
c0103ffe:	83 c4 10             	add    $0x10,%esp
c0104001:	85 c0                	test   %eax,%eax
c0104003:	0f 84 92 00 00 00    	je     c010409b <_ZN3VMM8checkVmaEv+0x70f>
c0104009:	50                   	push   %eax
c010400a:	50                   	push   %eax
c010400b:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c0104011:	50                   	push   %eax
c0104012:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c0104018:	56                   	push   %esi
c0104019:	e8 7c 0a 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010401e:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0104024:	58                   	pop    %eax
c0104025:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c010402b:	5a                   	pop    %edx
c010402c:	50                   	push   %eax
c010402d:	8d 85 d3 fb ff ff    	lea    -0x42d(%ebp),%eax
c0104033:	50                   	push   %eax
c0104034:	89 85 b0 fb ff ff    	mov    %eax,-0x450(%ebp)
c010403a:	e8 5b 0a 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010403f:	8b 85 b0 fb ff ff    	mov    -0x450(%ebp),%eax
c0104045:	83 c4 0c             	add    $0xc,%esp
c0104048:	56                   	push   %esi
c0104049:	50                   	push   %eax
c010404a:	57                   	push   %edi
c010404b:	e8 70 da ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0104050:	8b 85 b0 fb ff ff    	mov    -0x450(%ebp),%eax
c0104056:	89 04 24             	mov    %eax,(%esp)
c0104059:	e8 56 0a 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010405e:	89 34 24             	mov    %esi,(%esp)
c0104061:	e8 4e 0a 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0104066:	59                   	pop    %ecx
c0104067:	58                   	pop    %eax
c0104068:	8d 83 00 6b fe ff    	lea    -0x19500(%ebx),%eax
c010406e:	50                   	push   %eax
c010406f:	56                   	push   %esi
c0104070:	e8 25 0a 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0104075:	58                   	pop    %eax
c0104076:	5a                   	pop    %edx
c0104077:	56                   	push   %esi
c0104078:	57                   	push   %edi
c0104079:	e8 90 db ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c010407e:	89 34 24             	mov    %esi,(%esp)
c0104081:	e8 2e 0a 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0104086:	89 3c 24             	mov    %edi,(%esp)
c0104089:	e8 cc da ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010408e:	fa                   	cli    
    asm volatile ("hlt");
c010408f:	f4                   	hlt    
c0104090:	89 3c 24             	mov    %edi,(%esp)
c0104093:	e8 06 db ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0104098:	83 c4 10             	add    $0x10,%esp
        auto vma4 = findVma(mm, i + 3);
c010409b:	50                   	push   %eax
c010409c:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c01040a2:	83 c0 03             	add    $0x3,%eax
c01040a5:	50                   	push   %eax
c01040a6:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c01040ac:	ff 75 08             	pushl  0x8(%ebp)
c01040af:	e8 70 f0 ff ff       	call   c0103124 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma4 == nullptr);
c01040b4:	83 c4 10             	add    $0x10,%esp
c01040b7:	85 c0                	test   %eax,%eax
c01040b9:	0f 84 92 00 00 00    	je     c0104151 <_ZN3VMM8checkVmaEv+0x7c5>
c01040bf:	56                   	push   %esi
c01040c0:	56                   	push   %esi
c01040c1:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c01040c7:	50                   	push   %eax
c01040c8:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c01040ce:	56                   	push   %esi
c01040cf:	e8 c6 09 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01040d4:	5f                   	pop    %edi
c01040d5:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01040db:	58                   	pop    %eax
c01040dc:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c01040e2:	50                   	push   %eax
c01040e3:	8d 85 d3 fb ff ff    	lea    -0x42d(%ebp),%eax
c01040e9:	50                   	push   %eax
c01040ea:	89 85 b0 fb ff ff    	mov    %eax,-0x450(%ebp)
c01040f0:	e8 a5 09 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01040f5:	8b 85 b0 fb ff ff    	mov    -0x450(%ebp),%eax
c01040fb:	83 c4 0c             	add    $0xc,%esp
c01040fe:	56                   	push   %esi
c01040ff:	50                   	push   %eax
c0104100:	57                   	push   %edi
c0104101:	e8 ba d9 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0104106:	8b 85 b0 fb ff ff    	mov    -0x450(%ebp),%eax
c010410c:	89 04 24             	mov    %eax,(%esp)
c010410f:	e8 a0 09 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0104114:	89 34 24             	mov    %esi,(%esp)
c0104117:	e8 98 09 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010411c:	58                   	pop    %eax
c010411d:	8d 83 10 6b fe ff    	lea    -0x194f0(%ebx),%eax
c0104123:	5a                   	pop    %edx
c0104124:	50                   	push   %eax
c0104125:	56                   	push   %esi
c0104126:	e8 6f 09 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010412b:	59                   	pop    %ecx
c010412c:	58                   	pop    %eax
c010412d:	56                   	push   %esi
c010412e:	57                   	push   %edi
c010412f:	e8 da da ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0104134:	89 34 24             	mov    %esi,(%esp)
c0104137:	e8 78 09 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010413c:	89 3c 24             	mov    %edi,(%esp)
c010413f:	e8 16 da ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0104144:	fa                   	cli    
    asm volatile ("hlt");
c0104145:	f4                   	hlt    
c0104146:	89 3c 24             	mov    %edi,(%esp)
c0104149:	e8 50 da ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c010414e:	83 c4 10             	add    $0x10,%esp
        auto vma5 = findVma(mm, i + 4);
c0104151:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c0104157:	51                   	push   %ecx
c0104158:	83 c0 04             	add    $0x4,%eax
c010415b:	50                   	push   %eax
c010415c:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c0104162:	ff 75 08             	pushl  0x8(%ebp)
c0104165:	e8 ba ef ff ff       	call   c0103124 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma5 == nullptr);
c010416a:	83 c4 10             	add    $0x10,%esp
c010416d:	85 c0                	test   %eax,%eax
c010416f:	0f 84 92 00 00 00    	je     c0104207 <_ZN3VMM8checkVmaEv+0x87b>
c0104175:	50                   	push   %eax
c0104176:	50                   	push   %eax
c0104177:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c010417d:	50                   	push   %eax
c010417e:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c0104184:	56                   	push   %esi
c0104185:	e8 10 09 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010418a:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0104190:	58                   	pop    %eax
c0104191:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c0104197:	5a                   	pop    %edx
c0104198:	50                   	push   %eax
c0104199:	8d 85 d3 fb ff ff    	lea    -0x42d(%ebp),%eax
c010419f:	50                   	push   %eax
c01041a0:	89 85 b0 fb ff ff    	mov    %eax,-0x450(%ebp)
c01041a6:	e8 ef 08 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01041ab:	8b 85 b0 fb ff ff    	mov    -0x450(%ebp),%eax
c01041b1:	83 c4 0c             	add    $0xc,%esp
c01041b4:	56                   	push   %esi
c01041b5:	50                   	push   %eax
c01041b6:	57                   	push   %edi
c01041b7:	e8 04 d9 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c01041bc:	8b 85 b0 fb ff ff    	mov    -0x450(%ebp),%eax
c01041c2:	89 04 24             	mov    %eax,(%esp)
c01041c5:	e8 ea 08 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01041ca:	89 34 24             	mov    %esi,(%esp)
c01041cd:	e8 e2 08 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01041d2:	59                   	pop    %ecx
c01041d3:	58                   	pop    %eax
c01041d4:	8d 83 20 6b fe ff    	lea    -0x194e0(%ebx),%eax
c01041da:	50                   	push   %eax
c01041db:	56                   	push   %esi
c01041dc:	e8 b9 08 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01041e1:	58                   	pop    %eax
c01041e2:	5a                   	pop    %edx
c01041e3:	56                   	push   %esi
c01041e4:	57                   	push   %edi
c01041e5:	e8 24 da ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01041ea:	89 34 24             	mov    %esi,(%esp)
c01041ed:	e8 c2 08 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01041f2:	89 3c 24             	mov    %edi,(%esp)
c01041f5:	e8 60 d9 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01041fa:	fa                   	cli    
    asm volatile ("hlt");
c01041fb:	f4                   	hlt    
c01041fc:	89 3c 24             	mov    %edi,(%esp)
c01041ff:	e8 9a d9 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0104204:	83 c4 10             	add    $0x10,%esp
        assert(vma1->data.vm_start == i  && vma1->data.vm_end == i  + 2);
c0104207:	8b 85 bc fb ff ff    	mov    -0x444(%ebp),%eax
c010420d:	8b 8d c0 fb ff ff    	mov    -0x440(%ebp),%ecx
c0104213:	39 48 04             	cmp    %ecx,0x4(%eax)
c0104216:	75 0f                	jne    c0104227 <_ZN3VMM8checkVmaEv+0x89b>
c0104218:	8b 8d b4 fb ff ff    	mov    -0x44c(%ebp),%ecx
c010421e:	39 48 08             	cmp    %ecx,0x8(%eax)
c0104221:	0f 84 92 00 00 00    	je     c01042b9 <_ZN3VMM8checkVmaEv+0x92d>
c0104227:	51                   	push   %ecx
c0104228:	51                   	push   %ecx
c0104229:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c010422f:	50                   	push   %eax
c0104230:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c0104236:	56                   	push   %esi
c0104237:	e8 5e 08 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010423c:	5f                   	pop    %edi
c010423d:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c0104243:	58                   	pop    %eax
c0104244:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c010424a:	50                   	push   %eax
c010424b:	8d 85 d3 fb ff ff    	lea    -0x42d(%ebp),%eax
c0104251:	50                   	push   %eax
c0104252:	89 85 bc fb ff ff    	mov    %eax,-0x444(%ebp)
c0104258:	e8 3d 08 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010425d:	8b 85 bc fb ff ff    	mov    -0x444(%ebp),%eax
c0104263:	83 c4 0c             	add    $0xc,%esp
c0104266:	56                   	push   %esi
c0104267:	50                   	push   %eax
c0104268:	57                   	push   %edi
c0104269:	e8 52 d8 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c010426e:	8b 85 bc fb ff ff    	mov    -0x444(%ebp),%eax
c0104274:	89 04 24             	mov    %eax,(%esp)
c0104277:	e8 38 08 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010427c:	89 34 24             	mov    %esi,(%esp)
c010427f:	e8 30 08 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0104284:	58                   	pop    %eax
c0104285:	8d 83 30 6b fe ff    	lea    -0x194d0(%ebx),%eax
c010428b:	5a                   	pop    %edx
c010428c:	50                   	push   %eax
c010428d:	56                   	push   %esi
c010428e:	e8 07 08 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0104293:	59                   	pop    %ecx
c0104294:	58                   	pop    %eax
c0104295:	56                   	push   %esi
c0104296:	57                   	push   %edi
c0104297:	e8 72 d9 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c010429c:	89 34 24             	mov    %esi,(%esp)
c010429f:	e8 10 08 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01042a4:	89 3c 24             	mov    %edi,(%esp)
c01042a7:	e8 ae d8 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01042ac:	fa                   	cli    
    asm volatile ("hlt");
c01042ad:	f4                   	hlt    
c01042ae:	89 3c 24             	mov    %edi,(%esp)
c01042b1:	e8 e8 d8 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c01042b6:	83 c4 10             	add    $0x10,%esp
        assert(vma2->data.vm_start == i  && vma2->data.vm_end == i  + 2);
c01042b9:	8b 85 b8 fb ff ff    	mov    -0x448(%ebp),%eax
c01042bf:	8b 8d c0 fb ff ff    	mov    -0x440(%ebp),%ecx
c01042c5:	39 48 04             	cmp    %ecx,0x4(%eax)
c01042c8:	75 0f                	jne    c01042d9 <_ZN3VMM8checkVmaEv+0x94d>
c01042ca:	8b 8d b4 fb ff ff    	mov    -0x44c(%ebp),%ecx
c01042d0:	39 48 08             	cmp    %ecx,0x8(%eax)
c01042d3:	0f 84 92 00 00 00    	je     c010436b <_ZN3VMM8checkVmaEv+0x9df>
c01042d9:	50                   	push   %eax
c01042da:	50                   	push   %eax
c01042db:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c01042e1:	50                   	push   %eax
c01042e2:	8d b5 d8 fb ff ff    	lea    -0x428(%ebp),%esi
c01042e8:	56                   	push   %esi
c01042e9:	e8 ac 07 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01042ee:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c01042f4:	58                   	pop    %eax
c01042f5:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c01042fb:	5a                   	pop    %edx
c01042fc:	50                   	push   %eax
c01042fd:	8d 85 d3 fb ff ff    	lea    -0x42d(%ebp),%eax
c0104303:	50                   	push   %eax
c0104304:	89 85 bc fb ff ff    	mov    %eax,-0x444(%ebp)
c010430a:	e8 8b 07 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010430f:	8b 85 bc fb ff ff    	mov    -0x444(%ebp),%eax
c0104315:	83 c4 0c             	add    $0xc,%esp
c0104318:	56                   	push   %esi
c0104319:	50                   	push   %eax
c010431a:	57                   	push   %edi
c010431b:	e8 a0 d7 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0104320:	8b 85 bc fb ff ff    	mov    -0x444(%ebp),%eax
c0104326:	89 04 24             	mov    %eax,(%esp)
c0104329:	e8 86 07 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010432e:	89 34 24             	mov    %esi,(%esp)
c0104331:	e8 7e 07 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0104336:	59                   	pop    %ecx
c0104337:	58                   	pop    %eax
c0104338:	8d 83 67 6b fe ff    	lea    -0x19499(%ebx),%eax
c010433e:	50                   	push   %eax
c010433f:	56                   	push   %esi
c0104340:	e8 55 07 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0104345:	58                   	pop    %eax
c0104346:	5a                   	pop    %edx
c0104347:	56                   	push   %esi
c0104348:	57                   	push   %edi
c0104349:	e8 c0 d8 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c010434e:	89 34 24             	mov    %esi,(%esp)
c0104351:	e8 5e 07 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0104356:	89 3c 24             	mov    %edi,(%esp)
c0104359:	e8 fc d7 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010435e:	fa                   	cli    
    asm volatile ("hlt");
c010435f:	f4                   	hlt    
c0104360:	89 3c 24             	mov    %edi,(%esp)
c0104363:	e8 36 d8 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c0104368:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 5; i <= 5 * step2; i += 5) {      // 5 ~ 500
c010436b:	83 85 c0 fb ff ff 05 	addl   $0x5,-0x440(%ebp)
c0104372:	81 bd c0 fb ff ff f9 	cmpl   $0x1f9,-0x440(%ebp)
c0104379:	01 00 00 
c010437c:	0f 85 eb fa ff ff    	jne    c0103e6d <_ZN3VMM8checkVmaEv+0x4e1>
    OStream out("", "blue");
c0104382:	56                   	push   %esi
c0104383:	56                   	push   %esi
c0104384:	8d 83 36 67 fe ff    	lea    -0x198ca(%ebx),%eax
c010438a:	50                   	push   %eax
c010438b:	8d b5 e0 fd ff ff    	lea    -0x220(%ebp),%esi
c0104391:	56                   	push   %esi
c0104392:	e8 03 07 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0104397:	5f                   	pop    %edi
c0104398:	8d bd d3 fb ff ff    	lea    -0x42d(%ebp),%edi
c010439e:	58                   	pop    %eax
c010439f:	8d 83 50 67 fe ff    	lea    -0x198b0(%ebx),%eax
c01043a5:	50                   	push   %eax
c01043a6:	57                   	push   %edi
c01043a7:	e8 ee 06 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01043ac:	83 c4 0c             	add    $0xc,%esp
c01043af:	56                   	push   %esi
c01043b0:	57                   	push   %edi
c01043b1:	8d 85 d8 fb ff ff    	lea    -0x428(%ebp),%eax
c01043b7:	50                   	push   %eax
c01043b8:	89 85 c0 fb ff ff    	mov    %eax,-0x440(%ebp)
c01043be:	e8 fd d6 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c01043c3:	89 3c 24             	mov    %edi,(%esp)
c01043c6:	e8 e9 06 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01043cb:	89 34 24             	mov    %esi,(%esp)
c01043ce:	e8 e1 06 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.write("\ncheckVma(): vmaBelow5 [i, start, end]\n");
c01043d3:	58                   	pop    %eax
c01043d4:	5a                   	pop    %edx
c01043d5:	8d 93 9e 6b fe ff    	lea    -0x19462(%ebx),%edx
c01043db:	52                   	push   %edx
c01043dc:	56                   	push   %esi
c01043dd:	e8 b8 06 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01043e2:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c01043e8:	59                   	pop    %ecx
c01043e9:	5f                   	pop    %edi
c01043ea:	56                   	push   %esi
c01043eb:	50                   	push   %eax
c01043ec:	e8 1d d8 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01043f1:	89 34 24             	mov    %esi,(%esp)
c01043f4:	e8 bb 06 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    for (uint32_t i = 4; i >= 0; i--) {
c01043f9:	83 c4 10             	add    $0x10,%esp
c01043fc:	c7 85 c8 fb ff ff 04 	movl   $0x4,-0x438(%ebp)
c0104403:	00 00 00 
        auto *vma_below_5= findVma(mm,i);
c0104406:	51                   	push   %ecx
c0104407:	ff b5 c8 fb ff ff    	pushl  -0x438(%ebp)
c010440d:	ff b5 c4 fb ff ff    	pushl  -0x43c(%ebp)
c0104413:	ff 75 08             	pushl  0x8(%ebp)
c0104416:	e8 09 ed ff ff       	call   c0103124 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        if (vma_below_5 != nullptr ) {
c010441b:	83 c4 10             	add    $0x10,%esp
c010441e:	85 c0                	test   %eax,%eax
c0104420:	89 85 c0 fb ff ff    	mov    %eax,-0x440(%ebp)
c0104426:	0f 84 45 01 00 00    	je     c0104571 <_ZN3VMM8checkVmaEv+0xbe5>
           out.writeValue(i);
c010442c:	50                   	push   %eax
c010442d:	50                   	push   %eax
c010442e:	8d 95 c8 fb ff ff    	lea    -0x438(%ebp),%edx
c0104434:	52                   	push   %edx
c0104435:	8d bd d8 fb ff ff    	lea    -0x428(%ebp),%edi
c010443b:	57                   	push   %edi
c010443c:	e8 11 d8 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
           out.write(", ");
c0104441:	8d b5 e0 fd ff ff    	lea    -0x220(%ebp),%esi
c0104447:	5a                   	pop    %edx
c0104448:	8d 93 c6 6b fe ff    	lea    -0x1943a(%ebx),%edx
c010444e:	59                   	pop    %ecx
c010444f:	89 95 bc fb ff ff    	mov    %edx,-0x444(%ebp)
c0104455:	52                   	push   %edx
c0104456:	56                   	push   %esi
c0104457:	e8 3e 06 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010445c:	58                   	pop    %eax
c010445d:	5a                   	pop    %edx
c010445e:	56                   	push   %esi
c010445f:	57                   	push   %edi
c0104460:	e8 a9 d7 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0104465:	89 34 24             	mov    %esi,(%esp)
c0104468:	e8 47 06 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
           out.writeValue(vma_below_5->data.vm_start);
c010446d:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c0104473:	8b 48 04             	mov    0x4(%eax),%ecx
c0104476:	89 8d e0 fd ff ff    	mov    %ecx,-0x220(%ebp)
c010447c:	59                   	pop    %ecx
c010447d:	58                   	pop    %eax
c010447e:	56                   	push   %esi
c010447f:	57                   	push   %edi
c0104480:	e8 cd d7 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
           out.write(", ");
c0104485:	58                   	pop    %eax
c0104486:	5a                   	pop    %edx
c0104487:	8b 95 bc fb ff ff    	mov    -0x444(%ebp),%edx
c010448d:	52                   	push   %edx
c010448e:	56                   	push   %esi
c010448f:	e8 06 06 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0104494:	59                   	pop    %ecx
c0104495:	58                   	pop    %eax
c0104496:	56                   	push   %esi
c0104497:	57                   	push   %edi
c0104498:	e8 71 d7 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c010449d:	89 34 24             	mov    %esi,(%esp)
c01044a0:	e8 0f 06 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
           out.writeValue(vma_below_5->data.vm_end);
c01044a5:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c01044ab:	8b 40 08             	mov    0x8(%eax),%eax
c01044ae:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)
c01044b4:	58                   	pop    %eax
c01044b5:	5a                   	pop    %edx
c01044b6:	56                   	push   %esi
c01044b7:	57                   	push   %edi
c01044b8:	e8 95 d7 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
           out.write("\n");
c01044bd:	59                   	pop    %ecx
c01044be:	58                   	pop    %eax
c01044bf:	8d 83 4f 67 fe ff    	lea    -0x198b1(%ebx),%eax
c01044c5:	50                   	push   %eax
c01044c6:	56                   	push   %esi
c01044c7:	e8 ce 05 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01044cc:	58                   	pop    %eax
c01044cd:	5a                   	pop    %edx
c01044ce:	56                   	push   %esi
c01044cf:	57                   	push   %edi
c01044d0:	e8 39 d7 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c01044d5:	89 34 24             	mov    %esi,(%esp)
c01044d8:	e8 d7 05 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
           out.flush();
c01044dd:	89 3c 24             	mov    %edi,(%esp)
c01044e0:	e8 75 d6 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
        assert(vma_below_5 == nullptr);
c01044e5:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c01044eb:	59                   	pop    %ecx
c01044ec:	5f                   	pop    %edi
c01044ed:	8d bd d3 fb ff ff    	lea    -0x42d(%ebp),%edi
c01044f3:	50                   	push   %eax
c01044f4:	57                   	push   %edi
c01044f5:	e8 a0 05 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01044fa:	58                   	pop    %eax
c01044fb:	8d 83 5b 67 fe ff    	lea    -0x198a5(%ebx),%eax
c0104501:	5a                   	pop    %edx
c0104502:	50                   	push   %eax
c0104503:	8d 85 ce fb ff ff    	lea    -0x432(%ebp),%eax
c0104509:	50                   	push   %eax
c010450a:	89 85 c0 fb ff ff    	mov    %eax,-0x440(%ebp)
c0104510:	e8 85 05 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0104515:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c010451b:	83 c4 0c             	add    $0xc,%esp
c010451e:	57                   	push   %edi
c010451f:	50                   	push   %eax
c0104520:	56                   	push   %esi
c0104521:	e8 9a d5 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0104526:	8b 85 c0 fb ff ff    	mov    -0x440(%ebp),%eax
c010452c:	89 04 24             	mov    %eax,(%esp)
c010452f:	e8 80 05 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0104534:	89 3c 24             	mov    %edi,(%esp)
c0104537:	e8 78 05 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010453c:	59                   	pop    %ecx
c010453d:	58                   	pop    %eax
c010453e:	8d 83 c9 6b fe ff    	lea    -0x19437(%ebx),%eax
c0104544:	50                   	push   %eax
c0104545:	57                   	push   %edi
c0104546:	e8 4f 05 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010454b:	58                   	pop    %eax
c010454c:	5a                   	pop    %edx
c010454d:	57                   	push   %edi
c010454e:	56                   	push   %esi
c010454f:	e8 ba d6 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0104554:	89 3c 24             	mov    %edi,(%esp)
c0104557:	e8 58 05 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010455c:	89 34 24             	mov    %esi,(%esp)
c010455f:	e8 f6 d5 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0104564:	fa                   	cli    
    asm volatile ("hlt");
c0104565:	f4                   	hlt    
c0104566:	89 34 24             	mov    %esi,(%esp)
c0104569:	e8 30 d6 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c010456e:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 4; i >= 0; i--) {
c0104571:	ff 8d c8 fb ff ff    	decl   -0x438(%ebp)
    }
c0104577:	e9 8a fe ff ff       	jmp    c0104406 <_ZN3VMM8checkVmaEv+0xa7a>

c010457c <_ZN3VMM8checkVmmEv>:
void VMM::checkVmm() {
c010457c:	55                   	push   %ebp
c010457d:	89 e5                	mov    %esp,%ebp
c010457f:	57                   	push   %edi
c0104580:	56                   	push   %esi
c0104581:	53                   	push   %ebx
c0104582:	e8 39 c6 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0104587:	81 c3 99 9e 01 00    	add    $0x19e99,%ebx
c010458d:	81 ec 44 02 00 00    	sub    $0x244,%esp
    DEBUGPRINT("VMM::checkVmm");
c0104593:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c0104599:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
c010459f:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c01045a5:	50                   	push   %eax
c01045a6:	56                   	push   %esi
c01045a7:	e8 ee 04 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01045ac:	58                   	pop    %eax
c01045ad:	8d 83 c9 68 fe ff    	lea    -0x19737(%ebx),%eax
c01045b3:	5a                   	pop    %edx
c01045b4:	50                   	push   %eax
c01045b5:	8d 85 d6 fd ff ff    	lea    -0x22a(%ebp),%eax
c01045bb:	50                   	push   %eax
c01045bc:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c01045c2:	e8 d3 04 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01045c7:	83 c4 0c             	add    $0xc,%esp
c01045ca:	56                   	push   %esi
c01045cb:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c01045d1:	57                   	push   %edi
c01045d2:	e8 e9 d4 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c01045d7:	59                   	pop    %ecx
c01045d8:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c01045de:	e8 d1 04 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01045e3:	89 34 24             	mov    %esi,(%esp)
c01045e6:	e8 c9 04 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01045eb:	58                   	pop    %eax
c01045ec:	8d 83 e0 6b fe ff    	lea    -0x19420(%ebx),%eax
c01045f2:	5a                   	pop    %edx
c01045f3:	50                   	push   %eax
c01045f4:	56                   	push   %esi
c01045f5:	e8 a0 04 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c01045fa:	59                   	pop    %ecx
c01045fb:	58                   	pop    %eax
c01045fc:	56                   	push   %esi
c01045fd:	57                   	push   %edi
c01045fe:	e8 0b d6 ff ff       	call   c0101c0e <_ZN7OStream5writeERK6String>
c0104603:	89 34 24             	mov    %esi,(%esp)
c0104606:	e8 a9 04 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010460b:	89 3c 24             	mov    %edi,(%esp)
c010460e:	e8 47 d5 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
c0104613:	89 3c 24             	mov    %edi,(%esp)
c0104616:	e8 83 d5 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
    uint32_t nr_free_pages_store = kernel::pmm.numFreePages();
c010461b:	58                   	pop    %eax
c010461c:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
c0104622:	e8 8d e6 ff ff       	call   c0102cb4 <_ZN5PhyMM12numFreePagesEv>
c0104627:	89 85 d0 fd ff ff    	mov    %eax,-0x230(%ebp)
    OStream out("\ncheckVMM : ", "blue");
c010462d:	58                   	pop    %eax
c010462e:	8d 83 36 67 fe ff    	lea    -0x198ca(%ebx),%eax
c0104634:	5a                   	pop    %edx
c0104635:	50                   	push   %eax
c0104636:	56                   	push   %esi
c0104637:	e8 5e 04 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010463c:	59                   	pop    %ecx
c010463d:	58                   	pop    %eax
c010463e:	8d 83 ee 6b fe ff    	lea    -0x19412(%ebx),%eax
c0104644:	50                   	push   %eax
c0104645:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c010464b:	e8 4a 04 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0104650:	83 c4 0c             	add    $0xc,%esp
c0104653:	56                   	push   %esi
c0104654:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c010465a:	57                   	push   %edi
c010465b:	e8 60 d4 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0104660:	58                   	pop    %eax
c0104661:	ff b5 c4 fd ff ff    	pushl  -0x23c(%ebp)
c0104667:	e8 48 04 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010466c:	89 34 24             	mov    %esi,(%esp)
c010466f:	e8 40 04 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue(nr_free_pages_store);
c0104674:	58                   	pop    %eax
c0104675:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
c010467b:	5a                   	pop    %edx
c010467c:	50                   	push   %eax
c010467d:	57                   	push   %edi
c010467e:	e8 cf d5 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    out.flush();
c0104683:	89 3c 24             	mov    %edi,(%esp)
c0104686:	e8 cf d4 ff ff       	call   c0101b5a <_ZN7OStream5flushEv>
    checkVma();
c010468b:	59                   	pop    %ecx
c010468c:	ff 75 08             	pushl  0x8(%ebp)
c010468f:	e8 f8 f2 ff ff       	call   c010398c <_ZN3VMM8checkVmaEv>

c0104694 <_ZN3VMM4initEv>:
c0104694:	55                   	push   %ebp
c0104695:	89 e5                	mov    %esp,%ebp
c0104697:	83 ec 14             	sub    $0x14,%esp
c010469a:	ff 75 08             	pushl  0x8(%ebp)
c010469d:	e8 da fe ff ff       	call   c010457c <_ZN3VMM8checkVmmEv>

c01046a2 <_ZN4ListIN3VMM3VMAEE8addLNodeERNS2_6DLNodeE>:
void List<Object>::addLNode(DLNode &node) {
c01046a2:	55                   	push   %ebp
c01046a3:	89 e5                	mov    %esp,%ebp
c01046a5:	8b 55 08             	mov    0x8(%ebp),%edx
c01046a8:	53                   	push   %ebx
c01046a9:	8b 45 0c             	mov    0xc(%ebp),%eax
    return (headNode.eNum == 0 && headNode.last == nullptr);
c01046ac:	8b 4a 0c             	mov    0xc(%edx),%ecx
c01046af:	8b 5a 08             	mov    0x8(%edx),%ebx
c01046b2:	85 c9                	test   %ecx,%ecx
c01046b4:	75 1a                	jne    c01046d0 <_ZN4ListIN3VMM3VMAEE8addLNodeERNS2_6DLNodeE+0x2e>
c01046b6:	85 db                	test   %ebx,%ebx
c01046b8:	75 16                	jne    c01046d0 <_ZN4ListIN3VMM3VMAEE8addLNodeERNS2_6DLNodeE+0x2e>
        headNode.last = &node;
c01046ba:	89 42 08             	mov    %eax,0x8(%edx)
        headNode.first = &node;
c01046bd:	89 42 04             	mov    %eax,0x4(%edx)
        node.pre = nullptr;
c01046c0:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        node.next = nullptr;
c01046c7:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
c01046ce:	eb 10                	jmp    c01046e0 <_ZN4ListIN3VMM3VMAEE8addLNodeERNS2_6DLNodeE+0x3e>
        p->next = &node;
c01046d0:	89 43 14             	mov    %eax,0x14(%ebx)
        node.pre = p;
c01046d3:	89 58 10             	mov    %ebx,0x10(%eax)
        node.next = nullptr;
c01046d6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        headNode.last = &node;           // update 
c01046dd:	89 42 08             	mov    %eax,0x8(%edx)
    headNode.eNum++;
c01046e0:	41                   	inc    %ecx
c01046e1:	89 4a 0c             	mov    %ecx,0xc(%edx)
}
c01046e4:	5b                   	pop    %ebx
c01046e5:	5d                   	pop    %ebp
c01046e6:	c3                   	ret    
c01046e7:	90                   	nop

c01046e8 <_ZN3MMUC1Ev>:
#include <mmu.h>
#include <kdebug.h>
#include <ostream.h>

MMU::MMU() {
c01046e8:	55                   	push   %ebp
c01046e9:	89 e5                	mov    %esp,%ebp

}
c01046eb:	5d                   	pop    %ebp
c01046ec:	c3                   	ret    
c01046ed:	90                   	nop

c01046ee <_ZN3MMU10setSegDescEjjjj>:

MMU::SegDesc MMU::setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
c01046ee:	55                   	push   %ebp
c01046ef:	89 e5                	mov    %esp,%ebp
c01046f1:	57                   	push   %edi
c01046f2:	56                   	push   %esi
c01046f3:	53                   	push   %ebx
c01046f4:	81 ec 44 02 00 00    	sub    $0x244,%esp
c01046fa:	8b 75 08             	mov    0x8(%ebp),%esi
    sd.sd_avl = 0;
    sd.sd_l = 0;
    sd.sd_db = 1;
    sd.sd_g = 1;
    sd.sd_base_31_24 = (uint16_t)(base >> 24);
    OStream out("\nsetGDT-->Desc type ", "red");
c01046fd:	8d bd e0 fd ff ff    	lea    -0x220(%ebp),%edi
MMU::SegDesc MMU::setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
c0104703:	8b 4d 10             	mov    0x10(%ebp),%ecx
    sd.sd_lim_15_0 = lim & 0xffff;
c0104706:	0f b7 45 14          	movzwl 0x14(%ebp),%eax
    sd.sd_type = type;
c010470a:	8a 55 0c             	mov    0xc(%ebp),%dl
c010470d:	e8 ae c4 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0104712:	81 c3 0e 9d 01 00    	add    $0x19d0e,%ebx
    sd.sd_lim_15_0 = lim & 0xffff;
c0104718:	88 06                	mov    %al,(%esi)
c010471a:	88 66 01             	mov    %ah,0x1(%esi)
    sd.sd_base_15_0 = (base) & 0xffff;
c010471d:	0f b7 c1             	movzwl %cx,%eax
    sd.sd_type = type;
c0104720:	80 e2 0f             	and    $0xf,%dl
    sd.sd_base_15_0 = (base) & 0xffff;
c0104723:	88 46 02             	mov    %al,0x2(%esi)
c0104726:	88 66 03             	mov    %ah,0x3(%esi)
    sd.sd_base_23_16 = ((base) >> 16) & 0xff;
c0104729:	89 c8                	mov    %ecx,%eax
c010472b:	c1 e8 10             	shr    $0x10,%eax
c010472e:	88 46 04             	mov    %al,0x4(%esi)
    sd.sd_type = type;
c0104731:	8a 46 05             	mov    0x5(%esi),%al
    sd.sd_base_31_24 = (uint16_t)(base >> 24);
c0104734:	c1 e9 18             	shr    $0x18,%ecx
c0104737:	88 4e 07             	mov    %cl,0x7(%esi)
    sd.sd_type = type;
c010473a:	24 f0                	and    $0xf0,%al
c010473c:	08 d0                	or     %dl,%al
    sd.sd_dpl = dpl;
c010473e:	8a 55 18             	mov    0x18(%ebp),%dl
    sd.sd_s = 1;
c0104741:	0c 10                	or     $0x10,%al
    sd.sd_dpl = dpl;
c0104743:	24 9f                	and    $0x9f,%al
c0104745:	80 e2 03             	and    $0x3,%dl
c0104748:	c0 e2 05             	shl    $0x5,%dl
c010474b:	08 d0                	or     %dl,%al
    sd.sd_p = 1;
c010474d:	0c 80                	or     $0x80,%al
c010474f:	88 46 05             	mov    %al,0x5(%esi)
    sd.sd_lim_19_16 = (uint16_t)(lim >> 16);
c0104752:	8b 45 14             	mov    0x14(%ebp),%eax
c0104755:	c1 e8 10             	shr    $0x10,%eax
c0104758:	24 0f                	and    $0xf,%al
    sd.sd_g = 1;
c010475a:	0c c0                	or     $0xc0,%al
c010475c:	88 46 06             	mov    %al,0x6(%esi)
    OStream out("\nsetGDT-->Desc type ", "red");
c010475f:	8d 83 51 67 fe ff    	lea    -0x198af(%ebx),%eax
c0104765:	50                   	push   %eax
c0104766:	8d 85 db fd ff ff    	lea    -0x225(%ebp),%eax
c010476c:	50                   	push   %eax
c010476d:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c0104773:	e8 22 03 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0104778:	58                   	pop    %eax
c0104779:	5a                   	pop    %edx
c010477a:	8d 93 fb 6b fe ff    	lea    -0x19405(%ebx),%edx
c0104780:	52                   	push   %edx
c0104781:	8d 95 d6 fd ff ff    	lea    -0x22a(%ebp),%edx
c0104787:	52                   	push   %edx
c0104788:	89 95 c4 fd ff ff    	mov    %edx,-0x23c(%ebp)
c010478e:	e8 07 03 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c0104793:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c0104799:	83 c4 0c             	add    $0xc,%esp
c010479c:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c01047a2:	50                   	push   %eax
c01047a3:	52                   	push   %edx
c01047a4:	57                   	push   %edi
c01047a5:	e8 16 d3 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c01047aa:	8b 95 c4 fd ff ff    	mov    -0x23c(%ebp),%edx
c01047b0:	89 14 24             	mov    %edx,(%esp)
c01047b3:	e8 fc 02 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c01047b8:	8b 85 c0 fd ff ff    	mov    -0x240(%ebp),%eax
c01047be:	89 04 24             	mov    %eax,(%esp)
c01047c1:	e8 ee 02 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
    out.writeValue(type);
c01047c6:	59                   	pop    %ecx
c01047c7:	58                   	pop    %eax
c01047c8:	8d 45 0c             	lea    0xc(%ebp),%eax
c01047cb:	50                   	push   %eax
c01047cc:	57                   	push   %edi
c01047cd:	e8 80 d4 ff ff       	call   c0101c52 <_ZN7OStream10writeValueERKj>
    OStream out("\nsetGDT-->Desc type ", "red");
c01047d2:	89 3c 24             	mov    %edi,(%esp)
c01047d5:	e8 c4 d3 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
    return sd;
}
c01047da:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01047dd:	89 f0                	mov    %esi,%eax
c01047df:	5b                   	pop    %ebx
c01047e0:	5e                   	pop    %esi
c01047e1:	5f                   	pop    %edi
c01047e2:	5d                   	pop    %ebp
c01047e3:	c2 04 00             	ret    $0x4

c01047e6 <_ZN3MMU10setTssDescEjjjj>:

MMU::SegDesc MMU::setTssDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
c01047e6:	55                   	push   %ebp
c01047e7:	89 e5                	mov    %esp,%ebp
c01047e9:	8b 55 14             	mov    0x14(%ebp),%edx
c01047ec:	56                   	push   %esi
c01047ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01047f0:	8b 75 10             	mov    0x10(%ebp),%esi
c01047f3:	53                   	push   %ebx
    td.sd_lim_15_0 = lim & 0xffff;
    td.sd_base_15_0 = (base) & 0xffff;
    td.sd_base_23_16 = ((base) >> 16) & 0xff;
    td.sd_type = type;
    td.sd_s = 0;
    td.sd_dpl = dpl;
c01047f4:	8a 5d 18             	mov    0x18(%ebp),%bl
    td.sd_lim_15_0 = lim & 0xffff;
c01047f7:	0f b7 ca             	movzwl %dx,%ecx
c01047fa:	88 08                	mov    %cl,(%eax)
    td.sd_p = 1;
    td.sd_lim_19_16 = (uint16_t)(lim >> 16);
c01047fc:	c1 ea 10             	shr    $0x10,%edx
    td.sd_lim_15_0 = lim & 0xffff;
c01047ff:	88 68 01             	mov    %ch,0x1(%eax)
    td.sd_base_15_0 = (base) & 0xffff;
c0104802:	0f b7 ce             	movzwl %si,%ecx
    td.sd_lim_19_16 = (uint16_t)(lim >> 16);
c0104805:	80 e2 0f             	and    $0xf,%dl
    td.sd_base_15_0 = (base) & 0xffff;
c0104808:	88 48 02             	mov    %cl,0x2(%eax)
    td.sd_dpl = dpl;
c010480b:	80 e3 03             	and    $0x3,%bl
    td.sd_avl = 0;
    td.sd_l = 0;
    td.sd_db = 1;
    td.sd_g = 0;
c010480e:	80 ca 40             	or     $0x40,%dl
    td.sd_base_15_0 = (base) & 0xffff;
c0104811:	88 68 03             	mov    %ch,0x3(%eax)
    td.sd_base_23_16 = ((base) >> 16) & 0xff;
c0104814:	89 f1                	mov    %esi,%ecx
c0104816:	c1 e9 10             	shr    $0x10,%ecx
c0104819:	88 48 04             	mov    %cl,0x4(%eax)
    td.sd_type = type;
c010481c:	8a 4d 0c             	mov    0xc(%ebp),%cl
    td.sd_dpl = dpl;
c010481f:	c0 e3 05             	shl    $0x5,%bl
    td.sd_base_31_24 = (uint16_t)(base >> 24);
c0104822:	c1 ee 18             	shr    $0x18,%esi
    td.sd_g = 0;
c0104825:	88 50 06             	mov    %dl,0x6(%eax)
    td.sd_base_31_24 = (uint16_t)(base >> 24);
c0104828:	89 f2                	mov    %esi,%edx
c010482a:	88 50 07             	mov    %dl,0x7(%eax)
    td.sd_type = type;
c010482d:	80 e1 0f             	and    $0xf,%cl
    td.sd_dpl = dpl;
c0104830:	08 d9                	or     %bl,%cl
    td.sd_p = 1;
c0104832:	80 c9 80             	or     $0x80,%cl
c0104835:	88 48 05             	mov    %cl,0x5(%eax)
    return td;                                      
}
c0104838:	5b                   	pop    %ebx
c0104839:	5e                   	pop    %esi
c010483a:	5d                   	pop    %ebp
c010483b:	c2 04 00             	ret    $0x4

c010483e <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>:

void MMU::setGateDesc(GateDesc &gate, uint32_t istrap, uint32_t sel, uint32_t off, uint32_t dpl) {
c010483e:	55                   	push   %ebp
c010483f:	89 e5                	mov    %esp,%ebp
c0104841:	8b 55 14             	mov    0x14(%ebp),%edx
c0104844:	8b 45 08             	mov    0x8(%ebp),%eax
c0104847:	53                   	push   %ebx
    gate.gd_ss = (sel);
    gate.gd_args = 0;                                    
    gate.gd_rsv1 = 0;                                    
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
    gate.gd_s = 0;                                    
    gate.gd_dpl = (dpl);                               
c0104848:	8a 5d 18             	mov    0x18(%ebp),%bl
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c010484b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
c010484f:	0f b7 ca             	movzwl %dx,%ecx
c0104852:	88 08                	mov    %cl,(%eax)
c0104854:	88 68 01             	mov    %ch,0x1(%eax)
    gate.gd_ss = (sel);
c0104857:	0f b7 4d 10          	movzwl 0x10(%ebp),%ecx
    gate.gd_args = 0;                                    
c010485b:	c6 40 04 00          	movb   $0x0,0x4(%eax)
    gate.gd_ss = (sel);
c010485f:	88 48 02             	mov    %cl,0x2(%eax)
c0104862:	88 68 03             	mov    %ch,0x3(%eax)
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c0104865:	0f 95 c1             	setne  %cl
    gate.gd_dpl = (dpl);                               
c0104868:	80 e3 03             	and    $0x3,%bl
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c010486b:	80 c1 0e             	add    $0xe,%cl
    gate.gd_dpl = (dpl);                               
c010486e:	c0 e3 05             	shl    $0x5,%bl
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c0104871:	80 e1 0f             	and    $0xf,%cl
    gate.gd_dpl = (dpl);                               
c0104874:	08 d9                	or     %bl,%cl
    gate.gd_p = 1;                                    
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;        
c0104876:	c1 ea 10             	shr    $0x10,%edx
    gate.gd_p = 1;                                    
c0104879:	80 c9 80             	or     $0x80,%cl
c010487c:	88 48 05             	mov    %cl,0x5(%eax)
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;        
c010487f:	88 50 06             	mov    %dl,0x6(%eax)
c0104882:	88 70 07             	mov    %dh,0x7(%eax)
}
c0104885:	5b                   	pop    %ebx
c0104886:	5d                   	pop    %ebp
c0104887:	c3                   	ret    

c0104888 <_ZN3MMU11setCallGateERNS_8GateDescEjjj>:

void MMU::setCallGate(GateDesc &gate, uint32_t ss, uint32_t off, uint32_t dpl) {
c0104888:	55                   	push   %ebp
c0104889:	89 e5                	mov    %esp,%ebp
c010488b:	8b 4d 10             	mov    0x10(%ebp),%ecx
c010488e:	8b 45 08             	mov    0x8(%ebp),%eax
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
c0104891:	0f b7 d1             	movzwl %cx,%edx
c0104894:	88 10                	mov    %dl,(%eax)
    gate.gd_rsv1 = 0;                                  
    gate.gd_type = STS_CG32;                          
    gate.gd_s = 0;                                   
    gate.gd_dpl = (dpl);                              
    gate.gd_p = 1;                                  
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;     
c0104896:	c1 e9 10             	shr    $0x10,%ecx
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
c0104899:	88 70 01             	mov    %dh,0x1(%eax)
    gate.gd_ss = (ss);                                
c010489c:	0f b7 55 0c          	movzwl 0xc(%ebp),%edx
    gate.gd_rsv1 = 0;                                  
c01048a0:	c6 40 04 00          	movb   $0x0,0x4(%eax)
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;     
c01048a4:	88 48 06             	mov    %cl,0x6(%eax)
c01048a7:	88 68 07             	mov    %ch,0x7(%eax)
    gate.gd_ss = (ss);                                
c01048aa:	88 50 02             	mov    %dl,0x2(%eax)
c01048ad:	88 70 03             	mov    %dh,0x3(%eax)
    gate.gd_dpl = (dpl);                              
c01048b0:	8a 55 14             	mov    0x14(%ebp),%dl
c01048b3:	80 e2 03             	and    $0x3,%dl
c01048b6:	c0 e2 05             	shl    $0x5,%dl
    gate.gd_p = 1;                                  
c01048b9:	80 ca 8c             	or     $0x8c,%dl
c01048bc:	88 50 05             	mov    %dl,0x5(%eax)
}
c01048bf:	5d                   	pop    %ebp
c01048c0:	c3                   	ret    
c01048c1:	90                   	nop

c01048c2 <_ZN3MMU6setTCBEv>:

void MMU::setTCB() {
c01048c2:	55                   	push   %ebp
c01048c3:	89 e5                	mov    %esp,%ebp

}
c01048c5:	5d                   	pop    %ebp
c01048c6:	c3                   	ret    
c01048c7:	90                   	nop

c01048c8 <_ZN3MMU15setPageReservedERNS_4PageE>:

void MMU::setPageReserved(Page &p) {
c01048c8:	55                   	push   %ebp
c01048c9:	89 e5                	mov    %esp,%ebp
c01048cb:	8b 45 08             	mov    0x8(%ebp),%eax
    p.status |= 0x1;
c01048ce:	80 48 04 01          	orb    $0x1,0x4(%eax)
}
c01048d2:	5d                   	pop    %ebp
c01048d3:	c3                   	ret    

c01048d4 <_ZN3MMU15setPagePropertyERNS_4PageE>:

void MMU::setPageProperty(Page &p) {
c01048d4:	55                   	push   %ebp
c01048d5:	89 e5                	mov    %esp,%ebp
c01048d7:	8b 45 08             	mov    0x8(%ebp),%eax
    p.status |= 0x2;
c01048da:	80 48 04 02          	orb    $0x2,0x4(%eax)
}
c01048de:	5d                   	pop    %ebp
c01048df:	c3                   	ret    

c01048e0 <_ZN3MMU17clearPagePropertyERNS_4PageE>:

void MMU::clearPageProperty(Page &p) {
c01048e0:	55                   	push   %ebp
c01048e1:	89 e5                	mov    %esp,%ebp
c01048e3:	8b 45 08             	mov    0x8(%ebp),%eax
    p.status &= ~(0x2);                 // clear 2-bits to 0
c01048e6:	80 60 04 fd          	andb   $0xfd,0x4(%eax)
}
c01048ea:	5d                   	pop    %ebp
c01048eb:	c3                   	ret    

c01048ec <_ZN3MMU3LADEj>:

MMU::LinearAD MMU::LAD(uptr32_t vAd) {
c01048ec:	55                   	push   %ebp
c01048ed:	89 e5                	mov    %esp,%ebp
c01048ef:	8b 55 10             	mov    0x10(%ebp),%edx
c01048f2:	53                   	push   %ebx
c01048f3:	8b 45 08             	mov    0x8(%ebp),%eax
    LinearAD lad;
    lad.OFF = vAd & 0xFFF;
c01048f6:	89 d1                	mov    %edx,%ecx
    lad.PTI = (vAd >> PGSHIFT) & 0x3FF;
c01048f8:	89 d3                	mov    %edx,%ebx
    lad.OFF = vAd & 0xFFF;
c01048fa:	c1 e9 08             	shr    $0x8,%ecx
    lad.PTI = (vAd >> PGSHIFT) & 0x3FF;
c01048fd:	c1 eb 0c             	shr    $0xc,%ebx
c0104900:	80 e1 0f             	and    $0xf,%cl
c0104903:	c0 e3 04             	shl    $0x4,%bl
c0104906:	08 d9                	or     %bl,%cl
    lad.PDI = (vAd >> PTSHIFT) & 0x3FF;
c0104908:	89 d3                	mov    %edx,%ebx
    lad.PTI = (vAd >> PGSHIFT) & 0x3FF;
c010490a:	88 48 01             	mov    %cl,0x1(%eax)
c010490d:	89 d1                	mov    %edx,%ecx
c010490f:	c1 e9 10             	shr    $0x10,%ecx
    lad.PDI = (vAd >> PTSHIFT) & 0x3FF;
c0104912:	c1 eb 16             	shr    $0x16,%ebx
c0104915:	80 e1 3f             	and    $0x3f,%cl
c0104918:	c0 e3 06             	shl    $0x6,%bl
    lad.OFF = vAd & 0xFFF;
c010491b:	88 10                	mov    %dl,(%eax)
    lad.PDI = (vAd >> PTSHIFT) & 0x3FF;
c010491d:	08 d9                	or     %bl,%cl
c010491f:	c1 ea 18             	shr    $0x18,%edx
c0104922:	88 48 02             	mov    %cl,0x2(%eax)
c0104925:	88 50 03             	mov    %dl,0x3(%eax)
    return lad;
c0104928:	5b                   	pop    %ebx
c0104929:	5d                   	pop    %ebp
c010492a:	c2 04 00             	ret    $0x4
c010492d:	90                   	nop

c010492e <_ZN4Trap4trapEv>:
#include <trap.h>
#include <ostream.h>

void Trap::trap() {
c010492e:	55                   	push   %ebp
c010492f:	89 e5                	mov    %esp,%ebp
c0104931:	57                   	push   %edi
c0104932:	56                   	push   %esi
c0104933:	53                   	push   %ebx
c0104934:	e8 87 c2 ff ff       	call   c0100bc0 <__x86.get_pc_thunk.bx>
c0104939:	81 c3 e7 9a 01 00    	add    $0x19ae7,%ebx
c010493f:	81 ec 44 02 00 00    	sub    $0x244,%esp
    OStream out("interrupt...\n", "blue");
c0104945:	8d b5 db fd ff ff    	lea    -0x225(%ebp),%esi
c010494b:	8d bd d6 fd ff ff    	lea    -0x22a(%ebp),%edi
c0104951:	8d 83 36 67 fe ff    	lea    -0x198ca(%ebx),%eax
c0104957:	50                   	push   %eax
c0104958:	56                   	push   %esi
c0104959:	e8 3c 01 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010495e:	58                   	pop    %eax
c010495f:	8d 83 10 6c fe ff    	lea    -0x193f0(%ebx),%eax
c0104965:	5a                   	pop    %edx
c0104966:	50                   	push   %eax
c0104967:	57                   	push   %edi
c0104968:	e8 2d 01 00 00       	call   c0104a9a <_ZN6StringC1EPKc>
c010496d:	83 c4 0c             	add    $0xc,%esp
c0104970:	56                   	push   %esi
c0104971:	57                   	push   %edi
c0104972:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
c0104978:	50                   	push   %eax
c0104979:	89 85 c4 fd ff ff    	mov    %eax,-0x23c(%ebp)
c010497f:	e8 3c d1 ff ff       	call   c0101ac0 <_ZN7OStreamC1E6StringS0_>
c0104984:	89 3c 24             	mov    %edi,(%esp)
c0104987:	e8 28 01 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c010498c:	89 34 24             	mov    %esi,(%esp)
c010498f:	e8 20 01 00 00       	call   c0104ab4 <_ZN6StringD1Ev>
c0104994:	8b 85 c4 fd ff ff    	mov    -0x23c(%ebp),%eax
c010499a:	89 04 24             	mov    %eax,(%esp)
c010499d:	e8 fc d1 ff ff       	call   c0101b9e <_ZN7OStreamD1Ev>
c01049a2:	83 c4 10             	add    $0x10,%esp
c01049a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01049a8:	5b                   	pop    %ebx
c01049a9:	5e                   	pop    %esi
c01049aa:	5f                   	pop    %edi
c01049ab:	5d                   	pop    %ebp
c01049ac:	c3                   	ret    

c01049ad <__cxa_pure_virtual>:
#include <icxxabi.h>


extern "C" {

    void __cxa_pure_virtual() {
c01049ad:	55                   	push   %ebp
c01049ae:	89 e5                	mov    %esp,%ebp
        // Do Nothing
    }
c01049b0:	5d                   	pop    %ebp
c01049b1:	c3                   	ret    

c01049b2 <__cxa_atexit>:
    atexitFuncEntry_t __atexitFuncs[ATEXIT_FUNC_MAX];
    uarch_t __atexitFuncCount = 0;

    void *__dso_handle = 0;

    int __cxa_atexit(void (*f)(void *), void *objptr, void *dso){
c01049b2:	e8 ff c6 ff ff       	call   c01010b6 <__x86.get_pc_thunk.cx>
c01049b7:	81 c1 69 9a 01 00    	add    $0x19a69,%ecx
        if(__atexitFuncCount >= ATEXIT_FUNC_MAX){
c01049bd:	8b 91 24 36 00 00    	mov    0x3624(%ecx),%edx
c01049c3:	83 fa 7f             	cmp    $0x7f,%edx
c01049c6:	77 30                	ja     c01049f8 <__cxa_atexit+0x46>
    int __cxa_atexit(void (*f)(void *), void *objptr, void *dso){
c01049c8:	55                   	push   %ebp
c01049c9:	89 e5                	mov    %esp,%ebp
            return -1;
        }
        __atexitFuncs[__atexitFuncCount].destructorFunc = f;
c01049cb:	6b c2 0c             	imul   $0xc,%edx,%eax
        __atexitFuncs[__atexitFuncCount].objPtr = objptr;
        __atexitFuncs[__atexitFuncCount].dsoHandle = dso;
        __atexitFuncCount++;
c01049ce:	42                   	inc    %edx
    int __cxa_atexit(void (*f)(void *), void *objptr, void *dso){
c01049cf:	53                   	push   %ebx
        __atexitFuncs[__atexitFuncCount].destructorFunc = f;
c01049d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
        __atexitFuncCount++;
c01049d3:	89 91 24 36 00 00    	mov    %edx,0x3624(%ecx)
        __atexitFuncs[__atexitFuncCount].destructorFunc = f;
c01049d9:	89 9c 01 40 36 00 00 	mov    %ebx,0x3640(%ecx,%eax,1)
        __atexitFuncs[__atexitFuncCount].objPtr = objptr;
c01049e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c01049e3:	8d 84 01 40 36 00 00 	lea    0x3640(%ecx,%eax,1),%eax
c01049ea:	89 58 04             	mov    %ebx,0x4(%eax)
        __atexitFuncs[__atexitFuncCount].dsoHandle = dso;
c01049ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
c01049f0:	89 58 08             	mov    %ebx,0x8(%eax)
        return 0;
c01049f3:	31 c0                	xor    %eax,%eax
    }
c01049f5:	5b                   	pop    %ebx
c01049f6:	5d                   	pop    %ebp
c01049f7:	c3                   	ret    
c01049f8:	83 c8 ff             	or     $0xffffffff,%eax
c01049fb:	c3                   	ret    

c01049fc <__cxa_finalize>:

    void __cxa_finalize(void *f){
c01049fc:	55                   	push   %ebp
c01049fd:	89 e5                	mov    %esp,%ebp
c01049ff:	57                   	push   %edi
c0104a00:	56                   	push   %esi
c0104a01:	53                   	push   %ebx
c0104a02:	83 ec 1c             	sub    $0x1c,%esp
c0104a05:	e8 77 00 00 00       	call   c0104a81 <__x86.get_pc_thunk.si>
c0104a0a:	81 c6 16 9a 01 00    	add    $0x19a16,%esi
c0104a10:	8b 45 08             	mov    0x8(%ebp),%eax
        signed i = __atexitFuncCount;
        if(!f){
c0104a13:	85 c0                	test   %eax,%eax
        signed i = __atexitFuncCount;
c0104a15:	8b 9e 24 36 00 00    	mov    0x3624(%esi),%ebx
        if(!f){
c0104a1b:	74 0e                	je     c0104a2b <__cxa_finalize+0x2f>
c0104a1d:	6b d3 0c             	imul   $0xc,%ebx,%edx
c0104a20:	8d bc 16 40 36 00 00 	lea    0x3640(%esi,%edx,1),%edi
c0104a27:	31 f6                	xor    %esi,%esi
c0104a29:	eb 4a                	jmp    c0104a75 <__cxa_finalize+0x79>
c0104a2b:	6b db 0c             	imul   $0xc,%ebx,%ebx
            while(i--){
c0104a2e:	85 db                	test   %ebx,%ebx
c0104a30:	74 47                	je     c0104a79 <__cxa_finalize+0x7d>
                if(__atexitFuncs[i].destructorFunc){
c0104a32:	8b 84 33 34 36 00 00 	mov    0x3634(%ebx,%esi,1),%eax
c0104a39:	85 c0                	test   %eax,%eax
c0104a3b:	75 05                	jne    c0104a42 <__cxa_finalize+0x46>
c0104a3d:	83 eb 0c             	sub    $0xc,%ebx
c0104a40:	eb ec                	jmp    c0104a2e <__cxa_finalize+0x32>
                    (*__atexitFuncs[i].destructorFunc)(__atexitFuncs[i].objPtr);
c0104a42:	83 ec 0c             	sub    $0xc,%esp
c0104a45:	ff b4 33 38 36 00 00 	pushl  0x3638(%ebx,%esi,1)
c0104a4c:	ff d0                	call   *%eax
c0104a4e:	83 c4 10             	add    $0x10,%esp
c0104a51:	eb ea                	jmp    c0104a3d <__cxa_finalize+0x41>
            }
            return;
        }

        for(; i >= 0; i--){
            if(__atexitFuncs[i].destructorFunc == f){
c0104a53:	39 04 37             	cmp    %eax,(%edi,%esi,1)
c0104a56:	75 19                	jne    c0104a71 <__cxa_finalize+0x75>
                (*__atexitFuncs[i].destructorFunc)(__atexitFuncs[i].objPtr);
c0104a58:	83 ec 0c             	sub    $0xc,%esp
c0104a5b:	ff 74 37 04          	pushl  0x4(%edi,%esi,1)
c0104a5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104a62:	ff d0                	call   *%eax
c0104a64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
                __atexitFuncs[i].destructorFunc = 0;
c0104a67:	c7 04 37 00 00 00 00 	movl   $0x0,(%edi,%esi,1)
c0104a6e:	83 c4 10             	add    $0x10,%esp
        for(; i >= 0; i--){
c0104a71:	4b                   	dec    %ebx
c0104a72:	83 ee 0c             	sub    $0xc,%esi
c0104a75:	85 db                	test   %ebx,%ebx
c0104a77:	79 da                	jns    c0104a53 <__cxa_finalize+0x57>
            }
        }
    }
c0104a79:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0104a7c:	5b                   	pop    %ebx
c0104a7d:	5e                   	pop    %esi
c0104a7e:	5f                   	pop    %edi
c0104a7f:	5d                   	pop    %ebp
c0104a80:	c3                   	ret    

c0104a81 <__x86.get_pc_thunk.si>:
c0104a81:	8b 34 24             	mov    (%esp),%esi
c0104a84:	c3                   	ret    
c0104a85:	90                   	nop

c0104a86 <_ZN6String7cStrLenEPKc>:
 * @Last Modified time: 2020-03-25 19:21:46 
 */

#include <string.h>

uint32_t String::cStrLen(ccstring cstr) {
c0104a86:	55                   	push   %ebp
    uint32_t len = 0;
c0104a87:	31 c0                	xor    %eax,%eax
uint32_t String::cStrLen(ccstring cstr) {
c0104a89:	89 e5                	mov    %esp,%ebp
c0104a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
    auto it = cstr;
    while(*it++ != '\0') {
c0104a8e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
c0104a92:	74 03                	je     c0104a97 <_ZN6String7cStrLenEPKc+0x11>
        len++;
c0104a94:	40                   	inc    %eax
    while(*it++ != '\0') {
c0104a95:	eb f7                	jmp    c0104a8e <_ZN6String7cStrLenEPKc+0x8>
    }
    return len;
}
c0104a97:	5d                   	pop    %ebp
c0104a98:	c3                   	ret    
c0104a99:	90                   	nop

c0104a9a <_ZN6StringC1EPKc>:


String::String(ccstring cstr) {
c0104a9a:	55                   	push   %ebp
c0104a9b:	89 e5                	mov    %esp,%ebp
c0104a9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0104aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
    str = (cstring)cstr;
c0104aa3:	89 01                	mov    %eax,(%ecx)
    length = cStrLen(cstr);
c0104aa5:	50                   	push   %eax
c0104aa6:	51                   	push   %ecx
c0104aa7:	e8 da ff ff ff       	call   c0104a86 <_ZN6String7cStrLenEPKc>
c0104aac:	5a                   	pop    %edx
c0104aad:	5a                   	pop    %edx
c0104aae:	88 41 04             	mov    %al,0x4(%ecx)
}
c0104ab1:	c9                   	leave  
c0104ab2:	c3                   	ret    
c0104ab3:	90                   	nop

c0104ab4 <_ZN6StringD1Ev>:


String::~String() {                                     //destructor
c0104ab4:	55                   	push   %ebp
c0104ab5:	89 e5                	mov    %esp,%ebp

}
c0104ab7:	5d                   	pop    %ebp
c0104ab8:	c3                   	ret    
c0104ab9:	90                   	nop

c0104aba <_ZN6StringaSEPKc>:


String & String::operator=(ccstring cstr) {             // copy assigment
c0104aba:	55                   	push   %ebp
c0104abb:	89 e5                	mov    %esp,%ebp
c0104abd:	56                   	push   %esi
c0104abe:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0104ac1:	53                   	push   %ebx
c0104ac2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    length = cStrLen(cstr);
c0104ac5:	53                   	push   %ebx
c0104ac6:	51                   	push   %ecx
c0104ac7:	e8 ba ff ff ff       	call   c0104a86 <_ZN6String7cStrLenEPKc>
c0104acc:	5a                   	pop    %edx
c0104acd:	5e                   	pop    %esi
c0104ace:	88 41 04             	mov    %al,0x4(%ecx)
    //delete [] str;
    //str = new char[length];
    for (uint32_t i = 0; i < length; i++) {
c0104ad1:	31 c0                	xor    %eax,%eax
c0104ad3:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
c0104ad7:	39 c2                	cmp    %eax,%edx
c0104ad9:	76 0b                	jbe    c0104ae6 <_ZN6StringaSEPKc+0x2c>
        str[i] = cstr[i];
c0104adb:	8a 14 03             	mov    (%ebx,%eax,1),%dl
c0104ade:	8b 31                	mov    (%ecx),%esi
c0104ae0:	88 14 06             	mov    %dl,(%esi,%eax,1)
    for (uint32_t i = 0; i < length; i++) {
c0104ae3:	40                   	inc    %eax
c0104ae4:	eb ed                	jmp    c0104ad3 <_ZN6StringaSEPKc+0x19>
    }
    return *this;
}
c0104ae6:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0104ae9:	89 c8                	mov    %ecx,%eax
c0104aeb:	5b                   	pop    %ebx
c0104aec:	5e                   	pop    %esi
c0104aed:	5d                   	pop    %ebp
c0104aee:	c3                   	ret    
c0104aef:	90                   	nop

c0104af0 <_ZNK6String4cStrEv>:

ccstring String::cStr() const {
c0104af0:	55                   	push   %ebp
c0104af1:	89 e5                	mov    %esp,%ebp
    return str;
c0104af3:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0104af6:	5d                   	pop    %ebp
    return str;
c0104af7:	8b 00                	mov    (%eax),%eax
}
c0104af9:	c3                   	ret    

c0104afa <_ZNK6String9getLengthEv>:

uint8_t String::getLength() const {
c0104afa:	55                   	push   %ebp
c0104afb:	89 e5                	mov    %esp,%ebp
    return length;
c0104afd:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0104b00:	5d                   	pop    %ebp
    return length;
c0104b01:	8a 40 04             	mov    0x4(%eax),%al
}
c0104b04:	c3                   	ret    
c0104b05:	90                   	nop

c0104b06 <_ZN6StringeqERKS_>:

bool String::operator==(const String &_str) {
c0104b06:	55                   	push   %ebp
    bool isEquals = false;
c0104b07:	31 c0                	xor    %eax,%eax
bool String::operator==(const String &_str) {
c0104b09:	89 e5                	mov    %esp,%ebp
c0104b0b:	57                   	push   %edi
c0104b0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0104b0f:	56                   	push   %esi
c0104b10:	53                   	push   %ebx
c0104b11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (_str.length == length) {
c0104b14:	8a 53 04             	mov    0x4(%ebx),%dl
c0104b17:	3a 51 04             	cmp    0x4(%ecx),%dl
c0104b1a:	75 1e                	jne    c0104b3a <_ZN6StringeqERKS_+0x34>
        for (uint32_t i = 0; i < length; i++) {
c0104b1c:	31 c0                	xor    %eax,%eax
c0104b1e:	0f b6 fa             	movzbl %dl,%edi
c0104b21:	39 c7                	cmp    %eax,%edi
c0104b23:	76 0f                	jbe    c0104b34 <_ZN6StringeqERKS_+0x2e>
            if (str[i] != (_str.str)[i]) {
c0104b25:	8b 13                	mov    (%ebx),%edx
c0104b27:	8b 31                	mov    (%ecx),%esi
c0104b29:	8a 14 02             	mov    (%edx,%eax,1),%dl
c0104b2c:	38 14 06             	cmp    %dl,(%esi,%eax,1)
c0104b2f:	75 07                	jne    c0104b38 <_ZN6StringeqERKS_+0x32>
        for (uint32_t i = 0; i < length; i++) {
c0104b31:	40                   	inc    %eax
c0104b32:	eb ed                	jmp    c0104b21 <_ZN6StringeqERKS_+0x1b>
                return false;
            }
        }
        isEquals = true;
c0104b34:	b0 01                	mov    $0x1,%al
c0104b36:	eb 02                	jmp    c0104b3a <_ZN6StringeqERKS_+0x34>
    bool isEquals = false;
c0104b38:	31 c0                	xor    %eax,%eax
    }
    return isEquals;
}
c0104b3a:	5b                   	pop    %ebx
c0104b3b:	5e                   	pop    %esi
c0104b3c:	5f                   	pop    %edi
c0104b3d:	5d                   	pop    %ebp
c0104b3e:	c3                   	ret    
c0104b3f:	90                   	nop

c0104b40 <_ZN6StringixEj>:

// index accessor
char & String::operator[](const uint32_t index) {
c0104b40:	55                   	push   %ebp
c0104b41:	89 e5                	mov    %esp,%ebp
    return str[index];
c0104b43:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b46:	8b 00                	mov    (%eax),%eax
c0104b48:	03 45 0c             	add    0xc(%ebp),%eax
}
c0104b4b:	5d                   	pop    %ebp
c0104b4c:	c3                   	ret    
