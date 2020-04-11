
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <entryKernel>:

.text
.globl entryKernel
entryKernel:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 d0 11 00       	mov    $0x11d000,%eax
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
c0100020:	a3 00 d0 11 c0       	mov    %eax,0xc011d000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 c0 11 c0       	mov    $0xc011c000,%esp
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
c010004c:	e8 93 44 00 00       	call   c01044e4 <_ZN4Trap4trapEv>

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
c0100acd:	e8 df 00 00 00       	call   c0100bb1 <__x86.get_pc_thunk.ax>
c0100ad2:	05 3e b9 01 00       	add    $0x1b93e,%eax
c0100ad7:	55                   	push   %ebp
c0100ad8:	89 e5                	mov    %esp,%ebp
c0100ada:	56                   	push   %esi
c0100adb:	53                   	push   %ebx
    // Loop and call all the constructors
   for(uint32_t *ctor = &ctorStart; ctor < &ctorEnd; ctor++){
c0100adc:	c7 c6 04 90 11 c0    	mov    $0xc0119004,%esi
c0100ae2:	c7 c3 00 90 11 c0    	mov    $0xc0119000,%ebx
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
c0100afd:	e8 b3 00 00 00       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0100b02:	81 c3 0e b9 01 00    	add    $0x1b90e,%ebx
c0100b08:	81 ec 58 02 00 00    	sub    $0x258,%esp

    kernel::console.init();
    kernel::console.setBackground("white");
c0100b0e:	8d b5 c2 fd ff ff    	lea    -0x23e(%ebp),%esi
    kernel::console.init();
c0100b14:	c7 c7 68 f0 11 c0    	mov    $0xc011f068,%edi
c0100b1a:	57                   	push   %edi
c0100b1b:	e8 c4 02 00 00       	call   c0100de4 <_ZN7Console4initEv>
    kernel::console.setBackground("white");
c0100b20:	58                   	pop    %eax
c0100b21:	8d 83 f4 82 fe ff    	lea    -0x17d0c(%ebx),%eax
c0100b27:	5a                   	pop    %edx
c0100b28:	50                   	push   %eax
c0100b29:	56                   	push   %esi
c0100b2a:	e8 21 3b 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0100b2f:	59                   	pop    %ecx
c0100b30:	58                   	pop    %eax
c0100b31:	56                   	push   %esi
c0100b32:	57                   	push   %edi
c0100b33:	e8 7a 01 00 00       	call   c0100cb2 <_ZN7Console13setBackgroundE6String>
    
    OStream os("Welcome SPX OS.....\n\n", "blue");
c0100b38:	8d bd bd fd ff ff    	lea    -0x243(%ebp),%edi
    kernel::console.setBackground("white");
c0100b3e:	89 34 24             	mov    %esi,(%esp)
c0100b41:	e8 24 3b 00 00       	call   c010466a <_ZN6StringD1Ev>
    OStream os("Welcome SPX OS.....\n\n", "blue");
c0100b46:	58                   	pop    %eax
c0100b47:	8d 83 fa 82 fe ff    	lea    -0x17d06(%ebx),%eax
c0100b4d:	5a                   	pop    %edx
c0100b4e:	50                   	push   %eax
c0100b4f:	57                   	push   %edi
c0100b50:	e8 fb 3a 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0100b55:	59                   	pop    %ecx
c0100b56:	58                   	pop    %eax
c0100b57:	8d 83 ff 82 fe ff    	lea    -0x17d01(%ebx),%eax
c0100b5d:	50                   	push   %eax
c0100b5e:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c0100b64:	50                   	push   %eax
c0100b65:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c0100b6b:	e8 e0 3a 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0100b70:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0100b76:	83 c4 0c             	add    $0xc,%esp
c0100b79:	57                   	push   %edi
c0100b7a:	50                   	push   %eax
c0100b7b:	56                   	push   %esi
c0100b7c:	e8 e5 0e 00 00       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0100b81:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0100b87:	89 04 24             	mov    %eax,(%esp)
c0100b8a:	e8 db 3a 00 00       	call   c010466a <_ZN6StringD1Ev>
c0100b8f:	89 3c 24             	mov    %edi,(%esp)
c0100b92:	e8 d3 3a 00 00       	call   c010466a <_ZN6StringD1Ev>
    os.flush();
c0100b97:	89 34 24             	mov    %esi,(%esp)
c0100b9a:	e8 65 0f 00 00       	call   c0101b04 <_ZN7OStream5flushEv>

    kernel::pmm.init();
c0100b9f:	58                   	pop    %eax
c0100ba0:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
c0100ba6:	e8 eb 1a 00 00       	call   c0102696 <_ZN5PhyMM4initEv>
c0100bab:	83 c4 10             	add    $0x10,%esp
    );
}

static inline void
hlt() {
    asm volatile ("hlt");
c0100bae:	f4                   	hlt    
c0100baf:	eb fd                	jmp    c0100bae <initKernel+0xb7>

c0100bb1 <__x86.get_pc_thunk.ax>:
c0100bb1:	8b 04 24             	mov    (%esp),%eax
c0100bb4:	c3                   	ret    

c0100bb5 <__x86.get_pc_thunk.bx>:
c0100bb5:	8b 1c 24             	mov    (%esp),%ebx
c0100bb8:	c3                   	ret    
c0100bb9:	90                   	nop

c0100bba <_ZN7ConsoleC1Ev>:
 * @Last Modified time: 2020-04-10 21:25:43
 */

#include <console.h>

Console::Console() {
c0100bba:	55                   	push   %ebp
c0100bbb:	89 e5                	mov    %esp,%ebp
c0100bbd:	56                   	push   %esi
c0100bbe:	8b 75 08             	mov    0x8(%ebp),%esi
c0100bc1:	53                   	push   %ebx
c0100bc2:	e8 ee ff ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0100bc7:	81 c3 49 b8 01 00    	add    $0x1b849,%ebx
c0100bcd:	83 ec 0c             	sub    $0xc,%esp
c0100bd0:	56                   	push   %esi
c0100bd1:	e8 5c 06 00 00       	call   c0101232 <_ZN11VideoMemoryC1Ev>
c0100bd6:	58                   	pop    %eax
c0100bd7:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0100bdd:	5a                   	pop    %edx
c0100bde:	50                   	push   %eax
c0100bdf:	8d 46 06             	lea    0x6(%esi),%eax
c0100be2:	50                   	push   %eax
c0100be3:	e8 68 3a 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0100be8:	59                   	pop    %ecx
c0100be9:	58                   	pop    %eax
c0100bea:	8d 83 19 83 fe ff    	lea    -0x17ce7(%ebx),%eax
c0100bf0:	50                   	push   %eax
c0100bf1:	8d 46 0b             	lea    0xb(%esi),%eax
c0100bf4:	50                   	push   %eax
c0100bf5:	e8 56 3a 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0100bfa:	58                   	pop    %eax
c0100bfb:	8d 83 f4 82 fe ff    	lea    -0x17d0c(%ebx),%eax
c0100c01:	5a                   	pop    %edx
c0100c02:	50                   	push   %eax
c0100c03:	8d 46 10             	lea    0x10(%esi),%eax
c0100c06:	50                   	push   %eax
c0100c07:	e8 44 3a 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0100c0c:	59                   	pop    %ecx
c0100c0d:	58                   	pop    %eax
c0100c0e:	8d 83 fa 82 fe ff    	lea    -0x17d06(%ebx),%eax
c0100c14:	50                   	push   %eax
c0100c15:	8d 46 15             	lea    0x15(%esi),%eax
c0100c18:	50                   	push   %eax
c0100c19:	e8 32 3a 00 00       	call   c0104650 <_ZN6StringC1EPKc>
    // get Video Memory buffer
    screen = (Char *)(VideoMemory::vmBuffer);
c0100c1e:	8b 16                	mov    (%esi),%edx
}
c0100c20:	83 c4 10             	add    $0x10,%esp
    screen = (Char *)(VideoMemory::vmBuffer);
c0100c23:	c7 c0 30 fa 11 c0    	mov    $0xc011fa30,%eax
Console::Console() {
c0100c29:	c7 46 1a 04 00 07 01 	movl   $0x1070004,0x1a(%esi)
    screen = (Char *)(VideoMemory::vmBuffer);
c0100c30:	89 10                	mov    %edx,(%eax)
}
c0100c32:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0100c35:	5b                   	pop    %ebx
c0100c36:	5e                   	pop    %esi
c0100c37:	5d                   	pop    %ebp
c0100c38:	c3                   	ret    
c0100c39:	90                   	nop

c0100c3a <_ZN7Console5clearEv>:

void Console::clear() {
c0100c3a:	55                   	push   %ebp
c0100c3b:	89 e5                	mov    %esp,%ebp
c0100c3d:	53                   	push   %ebx
c0100c3e:	e8 72 ff ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0100c43:	81 c3 cd b7 01 00    	add    $0x1b7cd,%ebx
c0100c49:	83 ec 10             	sub    $0x10,%esp
    VideoMemory::initVmBuff();
c0100c4c:	ff 75 08             	pushl  0x8(%ebp)
c0100c4f:	e8 f2 05 00 00       	call   c0101246 <_ZN11VideoMemory10initVmBuffEv>
}
c0100c54:	83 c4 10             	add    $0x10,%esp
c0100c57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100c5a:	c9                   	leave  
c0100c5b:	c3                   	ret    

c0100c5c <_ZN7Console8setColorE6String>:
void Console::init() {
    VideoMemory::initVmBuff();
    setCursorPos(0, 0);
}

void Console::setColor(String str) {
c0100c5c:	55                   	push   %ebp
c0100c5d:	89 e5                	mov    %esp,%ebp
c0100c5f:	57                   	push   %edi
c0100c60:	56                   	push   %esi
    uint32_t index;
    for (index = 0; index < COLOR_NUM; index++) {
c0100c61:	31 f6                	xor    %esi,%esi
void Console::setColor(String str) {
c0100c63:	53                   	push   %ebx
c0100c64:	83 ec 0c             	sub    $0xc,%esp
c0100c67:	e8 49 ff ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0100c6c:	81 c3 a4 b7 01 00    	add    $0x1b7a4,%ebx
c0100c72:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c75:	8d 78 06             	lea    0x6(%eax),%edi
        if (str == color[index]) {
c0100c78:	50                   	push   %eax
c0100c79:	50                   	push   %eax
c0100c7a:	57                   	push   %edi
c0100c7b:	ff 75 0c             	pushl  0xc(%ebp)
c0100c7e:	e8 39 3a 00 00       	call   c01046bc <_ZN6StringeqERKS_>
c0100c83:	83 c4 10             	add    $0x10,%esp
c0100c86:	84 c0                	test   %al,%al
c0100c88:	75 0b                	jne    c0100c95 <_ZN7Console8setColorE6String+0x39>
    for (index = 0; index < COLOR_NUM; index++) {
c0100c8a:	46                   	inc    %esi
c0100c8b:	83 c7 05             	add    $0x5,%edi
c0100c8e:	83 fe 04             	cmp    $0x4,%esi
c0100c91:	75 e5                	jne    c0100c78 <_ZN7Console8setColorE6String+0x1c>
c0100c93:	eb 15                	jmp    c0100caa <_ZN7Console8setColorE6String+0x4e>
            break;
        }
    }
    if (index < COLOR_NUM) {
        charEctype.attri = (charEctype.attri & 0xF0) | colorTable[index];
c0100c95:	c7 c2 04 c4 11 c0    	mov    $0xc011c404,%edx
c0100c9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0100c9e:	8a 42 01             	mov    0x1(%edx),%al
c0100ca1:	24 f0                	and    $0xf0,%al
c0100ca3:	0a 44 31 1a          	or     0x1a(%ecx,%esi,1),%al
c0100ca7:	88 42 01             	mov    %al,0x1(%edx)
    }
}
c0100caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100cad:	5b                   	pop    %ebx
c0100cae:	5e                   	pop    %esi
c0100caf:	5f                   	pop    %edi
c0100cb0:	5d                   	pop    %ebp
c0100cb1:	c3                   	ret    

c0100cb2 <_ZN7Console13setBackgroundE6String>:

void Console::setBackground(String str) {
c0100cb2:	55                   	push   %ebp
c0100cb3:	89 e5                	mov    %esp,%ebp
c0100cb5:	57                   	push   %edi
    uint32_t index = 1;                             // default black
    for (uint32_t i = 0; i < COLOR_NUM; i++) {
c0100cb6:	31 ff                	xor    %edi,%edi
void Console::setBackground(String str) {
c0100cb8:	56                   	push   %esi
c0100cb9:	53                   	push   %ebx
c0100cba:	83 ec 1c             	sub    $0x1c,%esp
c0100cbd:	e8 f3 fe ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0100cc2:	81 c3 4e b7 01 00    	add    $0x1b74e,%ebx
c0100cc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ccb:	8d 70 06             	lea    0x6(%eax),%esi
        if (str == color[i]) {
c0100cce:	50                   	push   %eax
c0100ccf:	50                   	push   %eax
c0100cd0:	56                   	push   %esi
c0100cd1:	ff 75 0c             	pushl  0xc(%ebp)
c0100cd4:	e8 e3 39 00 00       	call   c01046bc <_ZN6StringeqERKS_>
c0100cd9:	83 c4 10             	add    $0x10,%esp
c0100cdc:	84 c0                	test   %al,%al
c0100cde:	75 0e                	jne    c0100cee <_ZN7Console13setBackgroundE6String+0x3c>
    for (uint32_t i = 0; i < COLOR_NUM; i++) {
c0100ce0:	47                   	inc    %edi
c0100ce1:	83 c6 05             	add    $0x5,%esi
c0100ce4:	83 ff 04             	cmp    $0x4,%edi
c0100ce7:	75 e5                	jne    c0100cce <_ZN7Console13setBackgroundE6String+0x1c>
    uint32_t index = 1;                             // default black
c0100ce9:	bf 01 00 00 00       	mov    $0x1,%edi
            index = i;
            break;
        }
    }
    charEctype.attri = (charEctype.attri & 0x0F) | ((colorTable[index]) << 4);
c0100cee:	c7 c1 04 c4 11 c0    	mov    $0xc011c404,%ecx
c0100cf4:	8b 55 08             	mov    0x8(%ebp),%edx
c0100cf7:	8a 41 01             	mov    0x1(%ecx),%al
c0100cfa:	0f b6 54 3a 1a       	movzbl 0x1a(%edx,%edi,1),%edx
c0100cff:	24 0f                	and    $0xf,%al
c0100d01:	c1 e2 04             	shl    $0x4,%edx
c0100d04:	08 d0                	or     %dl,%al
c0100d06:	88 41 01             	mov    %al,0x1(%ecx)
    for (uint32_t row = 0; row < wide; row++) {
c0100d09:	c7 c0 f4 47 10 c0    	mov    $0xc01047f4,%eax
c0100d0f:	8b 00                	mov    (%eax),%eax
c0100d11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (uint32_t col = 0; col < length; col++) {
c0100d14:	c7 c0 f8 47 10 c0    	mov    $0xc01047f8,%eax
c0100d1a:	8b 30                	mov    (%eax),%esi
            if (cPos.x != row || cPos.y != col) {
c0100d1c:	c7 c0 2d fa 11 c0    	mov    $0xc011fa2d,%eax
c0100d22:	0f b6 38             	movzbl (%eax),%edi
c0100d25:	0f b6 40 01          	movzbl 0x1(%eax),%eax
c0100d29:	89 7d e0             	mov    %edi,-0x20(%ebp)
    for (uint32_t row = 0; row < wide; row++) {
c0100d2c:	31 ff                	xor    %edi,%edi
            if (cPos.x != row || cPos.y != col) {
c0100d2e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100d31:	8d 04 36             	lea    (%esi,%esi,1),%eax
c0100d34:	89 45 d8             	mov    %eax,-0x28(%ebp)
                screen[row * length + col].attri = charEctype.attri;
c0100d37:	c7 c0 30 fa 11 c0    	mov    $0xc011fa30,%eax
c0100d3d:	8b 18                	mov    (%eax),%ebx
    for (uint32_t row = 0; row < wide; row++) {
c0100d3f:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
c0100d42:	74 24                	je     c0100d68 <_ZN7Console13setBackgroundE6String+0xb6>
        for (uint32_t col = 0; col < length; col++) {
c0100d44:	31 c0                	xor    %eax,%eax
c0100d46:	39 c6                	cmp    %eax,%esi
c0100d48:	74 14                	je     c0100d5e <_ZN7Console13setBackgroundE6String+0xac>
            if (cPos.x != row || cPos.y != col) {
c0100d4a:	39 7d e0             	cmp    %edi,-0x20(%ebp)
c0100d4d:	75 05                	jne    c0100d54 <_ZN7Console13setBackgroundE6String+0xa2>
c0100d4f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0100d52:	74 07                	je     c0100d5b <_ZN7Console13setBackgroundE6String+0xa9>
                screen[row * length + col].attri = charEctype.attri;
c0100d54:	8a 51 01             	mov    0x1(%ecx),%dl
c0100d57:	88 54 43 01          	mov    %dl,0x1(%ebx,%eax,2)
        for (uint32_t col = 0; col < length; col++) {
c0100d5b:	40                   	inc    %eax
c0100d5c:	eb e8                	jmp    c0100d46 <_ZN7Console13setBackgroundE6String+0x94>
    for (uint32_t row = 0; row < wide; row++) {
c0100d5e:	89 f8                	mov    %edi,%eax
c0100d60:	40                   	inc    %eax
c0100d61:	89 c7                	mov    %eax,%edi
c0100d63:	03 5d d8             	add    -0x28(%ebp),%ebx
c0100d66:	eb d7                	jmp    c0100d3f <_ZN7Console13setBackgroundE6String+0x8d>
            }
        }
    }
}
c0100d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100d6b:	5b                   	pop    %ebx
c0100d6c:	5e                   	pop    %esi
c0100d6d:	5f                   	pop    %edi
c0100d6e:	5d                   	pop    %ebp
c0100d6f:	c3                   	ret    

c0100d70 <_ZN7Console12setCursorPosEhh>:

void Console::setCursorPos(uint8_t x, uint8_t y) {
c0100d70:	55                   	push   %ebp
c0100d71:	89 e5                	mov    %esp,%ebp
c0100d73:	57                   	push   %edi
c0100d74:	56                   	push   %esi
c0100d75:	53                   	push   %ebx
c0100d76:	e8 3a fe ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0100d7b:	81 c3 95 b6 01 00    	add    $0x1b695,%ebx
c0100d81:	83 ec 24             	sub    $0x24,%esp
c0100d84:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d87:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
c0100d8b:	88 45 e7             	mov    %al,-0x19(%ebp)
    cPos.x = x;
c0100d8e:	c7 c6 2d fa 11 c0    	mov    $0xc011fa2d,%esi
    cPos.y = y;
    // set cursor status
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100d94:	0f b6 7d e7          	movzbl -0x19(%ebp),%edi
    cPos.y = y;
c0100d98:	88 46 01             	mov    %al,0x1(%esi)
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100d9b:	c7 c0 f8 47 10 c0    	mov    $0xc01047f8,%eax
    cPos.x = x;
c0100da1:	88 0e                	mov    %cl,(%esi)
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100da3:	0f b6 f1             	movzbl %cl,%esi
c0100da6:	8b 00                	mov    (%eax),%eax
c0100da8:	0f af f0             	imul   %eax,%esi
    VideoMemory::setCursorPos(cPos.x * length + cPos.y);
c0100dab:	0f af c1             	imul   %ecx,%eax
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100dae:	8d 14 3e             	lea    (%esi,%edi,1),%edx
c0100db1:	c7 c6 30 fa 11 c0    	mov    $0xc011fa30,%esi
c0100db7:	c7 c7 02 c4 11 c0    	mov    $0xc011c402,%edi
c0100dbd:	8b 36                	mov    (%esi),%esi
c0100dbf:	66 8b 3f             	mov    (%edi),%di
c0100dc2:	66 89 3c 56          	mov    %di,(%esi,%edx,2)
    VideoMemory::setCursorPos(cPos.x * length + cPos.y);
c0100dc6:	0f b6 55 e7          	movzbl -0x19(%ebp),%edx
c0100dca:	01 d0                	add    %edx,%eax
c0100dcc:	0f b7 c0             	movzwl %ax,%eax
c0100dcf:	50                   	push   %eax
c0100dd0:	ff 75 08             	pushl  0x8(%ebp)
c0100dd3:	e8 b4 04 00 00       	call   c010128c <_ZN11VideoMemory12setCursorPosEt>
}
c0100dd8:	83 c4 10             	add    $0x10,%esp
c0100ddb:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100dde:	5b                   	pop    %ebx
c0100ddf:	5e                   	pop    %esi
c0100de0:	5f                   	pop    %edi
c0100de1:	5d                   	pop    %ebp
c0100de2:	c3                   	ret    
c0100de3:	90                   	nop

c0100de4 <_ZN7Console4initEv>:
void Console::init() {
c0100de4:	55                   	push   %ebp
c0100de5:	89 e5                	mov    %esp,%ebp
c0100de7:	56                   	push   %esi
c0100de8:	8b 75 08             	mov    0x8(%ebp),%esi
c0100deb:	53                   	push   %ebx
c0100dec:	e8 c4 fd ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0100df1:	81 c3 1f b6 01 00    	add    $0x1b61f,%ebx
    VideoMemory::initVmBuff();
c0100df7:	83 ec 0c             	sub    $0xc,%esp
c0100dfa:	56                   	push   %esi
c0100dfb:	e8 46 04 00 00       	call   c0101246 <_ZN11VideoMemory10initVmBuffEv>
    setCursorPos(0, 0);
c0100e00:	83 c4 0c             	add    $0xc,%esp
c0100e03:	6a 00                	push   $0x0
c0100e05:	6a 00                	push   $0x0
c0100e07:	56                   	push   %esi
c0100e08:	e8 63 ff ff ff       	call   c0100d70 <_ZN7Console12setCursorPosEhh>
}
c0100e0d:	83 c4 10             	add    $0x10,%esp
c0100e10:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0100e13:	5b                   	pop    %ebx
c0100e14:	5e                   	pop    %esi
c0100e15:	5d                   	pop    %ebp
c0100e16:	c3                   	ret    
c0100e17:	90                   	nop

c0100e18 <_ZN7Console12getCursorPosEv>:

const Console::CursorPos & Console::getCursorPos() {
c0100e18:	55                   	push   %ebp
c0100e19:	89 e5                	mov    %esp,%ebp
c0100e1b:	57                   	push   %edi
c0100e1c:	56                   	push   %esi
c0100e1d:	53                   	push   %ebx
c0100e1e:	e8 92 fd ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0100e23:	81 c3 ed b5 01 00    	add    $0x1b5ed,%ebx
c0100e29:	83 ec 18             	sub    $0x18,%esp
    cPos.x = VideoMemory::getCursorPos() / length;
c0100e2c:	ff 75 08             	pushl  0x8(%ebp)
c0100e2f:	e8 2a 04 00 00       	call   c010125e <_ZN11VideoMemory12getCursorPosEv>
c0100e34:	c7 c2 f8 47 10 c0    	mov    $0xc01047f8,%edx
c0100e3a:	c7 c7 2d fa 11 c0    	mov    $0xc011fa2d,%edi
c0100e40:	8b 32                	mov    (%edx),%esi
c0100e42:	31 d2                	xor    %edx,%edx
c0100e44:	0f b7 c0             	movzwl %ax,%eax
c0100e47:	f7 f6                	div    %esi
c0100e49:	88 07                	mov    %al,(%edi)
    cPos.y = VideoMemory::getCursorPos() % length;
c0100e4b:	58                   	pop    %eax
c0100e4c:	ff 75 08             	pushl  0x8(%ebp)
c0100e4f:	e8 0a 04 00 00       	call   c010125e <_ZN11VideoMemory12getCursorPosEv>
c0100e54:	31 d2                	xor    %edx,%edx
c0100e56:	0f b7 c0             	movzwl %ax,%eax
c0100e59:	f7 f6                	div    %esi
    return cPos;
}
c0100e5b:	89 f8                	mov    %edi,%eax
    cPos.y = VideoMemory::getCursorPos() % length;
c0100e5d:	88 57 01             	mov    %dl,0x1(%edi)
}
c0100e60:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100e63:	5b                   	pop    %ebx
c0100e64:	5e                   	pop    %esi
c0100e65:	5f                   	pop    %edi
c0100e66:	5d                   	pop    %ebp
c0100e67:	c3                   	ret    

c0100e68 <_ZN7Console4readEv>:
    for (uint32_t i = 0; i < len; i++) {
        wirte(cArry[i]);
    }
}

char Console::read() {
c0100e68:	e8 44 fd ff ff       	call   c0100bb1 <__x86.get_pc_thunk.ax>
c0100e6d:	05 a3 b5 01 00       	add    $0x1b5a3,%eax
c0100e72:	55                   	push   %ebp
c0100e73:	89 e5                	mov    %esp,%ebp
    return screen[0].c;
}
c0100e75:	5d                   	pop    %ebp
    return screen[0].c;
c0100e76:	c7 c0 30 fa 11 c0    	mov    $0xc011fa30,%eax
c0100e7c:	8b 00                	mov    (%eax),%eax
c0100e7e:	8a 00                	mov    (%eax),%al
}
c0100e80:	c3                   	ret    
c0100e81:	90                   	nop

c0100e82 <_ZN7Console4readEPcRKt>:

void Console::read(char *cArry, const uint16_t &len) {
c0100e82:	55                   	push   %ebp
c0100e83:	89 e5                	mov    %esp,%ebp
   
}
c0100e85:	5d                   	pop    %ebp
c0100e86:	c3                   	ret    
c0100e87:	90                   	nop

c0100e88 <_ZN7Console12scrollScreenEv>:
    } else {
        setCursorPos(cPos.x + 1, 0);
    }
}

void Console::scrollScreen() {
c0100e88:	e8 cf 01 00 00       	call   c010105c <__x86.get_pc_thunk.cx>
c0100e8d:	81 c1 83 b5 01 00    	add    $0x1b583,%ecx
    charEctype.c = ' ';
    for (uint32_t i = 0; i < length * wide; i++) {
c0100e93:	31 c0                	xor    %eax,%eax
void Console::scrollScreen() {
c0100e95:	55                   	push   %ebp
c0100e96:	89 e5                	mov    %esp,%ebp
c0100e98:	57                   	push   %edi
c0100e99:	56                   	push   %esi
c0100e9a:	53                   	push   %ebx
c0100e9b:	83 ec 1c             	sub    $0x1c,%esp
    for (uint32_t i = 0; i < length * wide; i++) {
c0100e9e:	c7 c2 f8 47 10 c0    	mov    $0xc01047f8,%edx
    charEctype.c = ' ';
c0100ea4:	c7 c3 04 c4 11 c0    	mov    $0xc011c404,%ebx
    for (uint32_t i = 0; i < length * wide; i++) {
c0100eaa:	8b 32                	mov    (%edx),%esi
c0100eac:	c7 c2 f4 47 10 c0    	mov    $0xc01047f4,%edx
    charEctype.c = ' ';
c0100eb2:	c6 03 20             	movb   $0x20,(%ebx)
    for (uint32_t i = 0; i < length * wide; i++) {
c0100eb5:	89 75 e4             	mov    %esi,-0x1c(%ebp)
c0100eb8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
c0100ebb:	8b 32                	mov    (%edx),%esi
c0100ebd:	0f af fe             	imul   %esi,%edi
c0100ec0:	89 75 e0             	mov    %esi,-0x20(%ebp)
c0100ec3:	89 7d dc             	mov    %edi,-0x24(%ebp)
c0100ec6:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0100ec9:	76 2c                	jbe    c0100ef7 <_ZN7Console12scrollScreenEv+0x6f>
c0100ecb:	c7 c6 30 fa 11 c0    	mov    $0xc011fa30,%esi
c0100ed1:	8d 3c 00             	lea    (%eax,%eax,1),%edi
c0100ed4:	8b 36                	mov    (%esi),%esi
c0100ed6:	8d 14 3e             	lea    (%esi,%edi,1),%edx
        if (i < length * (wide - 1)) {
c0100ed9:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0100edc:	2b 7d e4             	sub    -0x1c(%ebp),%edi
c0100edf:	39 c7                	cmp    %eax,%edi
c0100ee1:	76 0b                	jbe    c0100eee <_ZN7Console12scrollScreenEv+0x66>
            screen[i] = screen[length + i];
c0100ee3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
c0100ee6:	01 c7                	add    %eax,%edi
c0100ee8:	66 8b 34 7e          	mov    (%esi,%edi,2),%si
c0100eec:	eb 03                	jmp    c0100ef1 <_ZN7Console12scrollScreenEv+0x69>
        } else {
            screen[i] = charEctype;
c0100eee:	66 8b 33             	mov    (%ebx),%si
c0100ef1:	66 89 32             	mov    %si,(%edx)
    for (uint32_t i = 0; i < length * wide; i++) {
c0100ef4:	40                   	inc    %eax
c0100ef5:	eb cf                	jmp    c0100ec6 <_ZN7Console12scrollScreenEv+0x3e>
        }
    }
    setCursorPos(wide - 1, 0);
c0100ef7:	8a 55 e0             	mov    -0x20(%ebp),%dl
c0100efa:	50                   	push   %eax
c0100efb:	6a 00                	push   $0x0
c0100efd:	fe ca                	dec    %dl
c0100eff:	0f b6 d2             	movzbl %dl,%edx
c0100f02:	52                   	push   %edx
c0100f03:	ff 75 08             	pushl  0x8(%ebp)
c0100f06:	e8 65 fe ff ff       	call   c0100d70 <_ZN7Console12setCursorPosEhh>
}
c0100f0b:	83 c4 10             	add    $0x10,%esp
c0100f0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100f11:	5b                   	pop    %ebx
c0100f12:	5e                   	pop    %esi
c0100f13:	5f                   	pop    %edi
c0100f14:	5d                   	pop    %ebp
c0100f15:	c3                   	ret    

c0100f16 <_ZN7Console4nextEv>:
void Console::next() {
c0100f16:	55                   	push   %ebp
    cPos.y = (cPos.y + 1) % length;
c0100f17:	31 d2                	xor    %edx,%edx
void Console::next() {
c0100f19:	89 e5                	mov    %esp,%ebp
c0100f1b:	57                   	push   %edi
c0100f1c:	e8 3f 01 00 00       	call   c0101060 <__x86.get_pc_thunk.di>
c0100f21:	81 c7 ef b4 01 00    	add    $0x1b4ef,%edi
c0100f27:	56                   	push   %esi
c0100f28:	53                   	push   %ebx
c0100f29:	83 ec 0c             	sub    $0xc,%esp
c0100f2c:	8b 75 08             	mov    0x8(%ebp),%esi
    cPos.y = (cPos.y + 1) % length;
c0100f2f:	c7 c3 2d fa 11 c0    	mov    $0xc011fa2d,%ebx
c0100f35:	c7 c1 f8 47 10 c0    	mov    $0xc01047f8,%ecx
c0100f3b:	0f b6 43 01          	movzbl 0x1(%ebx),%eax
c0100f3f:	40                   	inc    %eax
c0100f40:	f7 31                	divl   (%ecx)
    if (cPos.y == 0) {
c0100f42:	84 d2                	test   %dl,%dl
    cPos.y = (cPos.y + 1) % length;
c0100f44:	89 d1                	mov    %edx,%ecx
c0100f46:	88 53 01             	mov    %dl,0x1(%ebx)
    if (cPos.y == 0) {
c0100f49:	75 20                	jne    c0100f6b <_ZN7Console4nextEv+0x55>
        cPos.x = (cPos.x + 1) % wide;
c0100f4b:	0f b6 03             	movzbl (%ebx),%eax
c0100f4e:	31 d2                	xor    %edx,%edx
c0100f50:	c7 c7 f4 47 10 c0    	mov    $0xc01047f4,%edi
c0100f56:	40                   	inc    %eax
c0100f57:	f7 37                	divl   (%edi)
    if (cPos.y == 0 && cPos.x == 0) {   // jugde scroll screen
c0100f59:	84 d2                	test   %dl,%dl
        cPos.x = (cPos.x + 1) % wide;
c0100f5b:	88 13                	mov    %dl,(%ebx)
    if (cPos.y == 0 && cPos.x == 0) {   // jugde scroll screen
c0100f5d:	75 0c                	jne    c0100f6b <_ZN7Console4nextEv+0x55>
}
c0100f5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100f62:	5b                   	pop    %ebx
c0100f63:	5e                   	pop    %esi
c0100f64:	5f                   	pop    %edi
c0100f65:	5d                   	pop    %ebp
        scrollScreen();
c0100f66:	e9 1d ff ff ff       	jmp    c0100e88 <_ZN7Console12scrollScreenEv>
        setCursorPos(cPos.x, cPos.y);
c0100f6b:	50                   	push   %eax
c0100f6c:	0f b6 03             	movzbl (%ebx),%eax
c0100f6f:	0f b6 c9             	movzbl %cl,%ecx
c0100f72:	51                   	push   %ecx
c0100f73:	50                   	push   %eax
c0100f74:	56                   	push   %esi
c0100f75:	e8 f6 fd ff ff       	call   c0100d70 <_ZN7Console12setCursorPosEhh>
c0100f7a:	83 c4 10             	add    $0x10,%esp
}
c0100f7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100f80:	5b                   	pop    %ebx
c0100f81:	5e                   	pop    %esi
c0100f82:	5f                   	pop    %edi
c0100f83:	5d                   	pop    %ebp
c0100f84:	c3                   	ret    
c0100f85:	90                   	nop

c0100f86 <_ZN7Console8lineFeedEv>:
void Console::lineFeed() {
c0100f86:	e8 cd 00 00 00       	call   c0101058 <__x86.get_pc_thunk.dx>
c0100f8b:	81 c2 85 b4 01 00    	add    $0x1b485,%edx
c0100f91:	55                   	push   %ebp
c0100f92:	89 e5                	mov    %esp,%ebp
c0100f94:	83 ec 08             	sub    $0x8,%esp
c0100f97:	8b 4d 08             	mov    0x8(%ebp),%ecx
    if ((uint32_t)(cPos.x + 1) >= wide) {
c0100f9a:	c7 c0 2d fa 11 c0    	mov    $0xc011fa2d,%eax
c0100fa0:	c7 c2 f4 47 10 c0    	mov    $0xc01047f4,%edx
c0100fa6:	0f b6 00             	movzbl (%eax),%eax
c0100fa9:	40                   	inc    %eax
c0100faa:	3b 02                	cmp    (%edx),%eax
c0100fac:	72 06                	jb     c0100fb4 <_ZN7Console8lineFeedEv+0x2e>
}
c0100fae:	c9                   	leave  
        scrollScreen();
c0100faf:	e9 d4 fe ff ff       	jmp    c0100e88 <_ZN7Console12scrollScreenEv>
        setCursorPos(cPos.x + 1, 0);
c0100fb4:	52                   	push   %edx
c0100fb5:	0f b6 c0             	movzbl %al,%eax
c0100fb8:	6a 00                	push   $0x0
c0100fba:	50                   	push   %eax
c0100fbb:	51                   	push   %ecx
c0100fbc:	e8 af fd ff ff       	call   c0100d70 <_ZN7Console12setCursorPosEhh>
c0100fc1:	83 c4 10             	add    $0x10,%esp
}
c0100fc4:	c9                   	leave  
c0100fc5:	c3                   	ret    

c0100fc6 <_ZN7Console5wirteERKc>:
void Console::wirte(const char &c) {
c0100fc6:	e8 91 00 00 00       	call   c010105c <__x86.get_pc_thunk.cx>
c0100fcb:	81 c1 45 b4 01 00    	add    $0x1b445,%ecx
c0100fd1:	55                   	push   %ebp
c0100fd2:	89 e5                	mov    %esp,%ebp
c0100fd4:	57                   	push   %edi
    if (c == '\n') {
c0100fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
void Console::wirte(const char &c) {
c0100fd8:	56                   	push   %esi
c0100fd9:	53                   	push   %ebx
c0100fda:	c7 c6 2d fa 11 c0    	mov    $0xc011fa2d,%esi
c0100fe0:	c7 c7 f8 47 10 c0    	mov    $0xc01047f8,%edi
    if (c == '\n') {
c0100fe6:	8a 10                	mov    (%eax),%dl
c0100fe8:	c7 c3 30 fa 11 c0    	mov    $0xc011fa30,%ebx
c0100fee:	0f b6 06             	movzbl (%esi),%eax
c0100ff1:	0f b6 76 01          	movzbl 0x1(%esi),%esi
c0100ff5:	c7 c1 04 c4 11 c0    	mov    $0xc011c404,%ecx
c0100ffb:	0f af 07             	imul   (%edi),%eax
c0100ffe:	01 f0                	add    %esi,%eax
c0101000:	01 c0                	add    %eax,%eax
c0101002:	03 03                	add    (%ebx),%eax
c0101004:	80 fa 0a             	cmp    $0xa,%dl
c0101007:	75 12                	jne    c010101b <_ZN7Console5wirteERKc+0x55>
        charEctype.c = ' ';
c0101009:	c6 01 20             	movb   $0x20,(%ecx)
        screen[cPos.x * length + cPos.y] = charEctype;
c010100c:	66 8b 11             	mov    (%ecx),%dx
c010100f:	66 89 10             	mov    %dx,(%eax)
}
c0101012:	5b                   	pop    %ebx
c0101013:	5e                   	pop    %esi
c0101014:	5f                   	pop    %edi
c0101015:	5d                   	pop    %ebp
        lineFeed();
c0101016:	e9 6b ff ff ff       	jmp    c0100f86 <_ZN7Console8lineFeedEv>
        charEctype.c = c;
c010101b:	88 11                	mov    %dl,(%ecx)
        screen[cPos.x * length + cPos.y] = charEctype;
c010101d:	66 8b 11             	mov    (%ecx),%dx
c0101020:	66 89 10             	mov    %dx,(%eax)
}
c0101023:	5b                   	pop    %ebx
c0101024:	5e                   	pop    %esi
c0101025:	5f                   	pop    %edi
c0101026:	5d                   	pop    %ebp
        next();
c0101027:	e9 ea fe ff ff       	jmp    c0100f16 <_ZN7Console4nextEv>

c010102c <_ZN7Console5wirteEPcRKt>:
void Console::wirte(char *cArry, const uint16_t &len) {
c010102c:	55                   	push   %ebp
c010102d:	89 e5                	mov    %esp,%ebp
c010102f:	53                   	push   %ebx
    for (uint32_t i = 0; i < len; i++) {
c0101030:	31 db                	xor    %ebx,%ebx
void Console::wirte(char *cArry, const uint16_t &len) {
c0101032:	52                   	push   %edx
    for (uint32_t i = 0; i < len; i++) {
c0101033:	8b 45 10             	mov    0x10(%ebp),%eax
c0101036:	0f b7 00             	movzwl (%eax),%eax
c0101039:	39 d8                	cmp    %ebx,%eax
c010103b:	76 16                	jbe    c0101053 <_ZN7Console5wirteEPcRKt+0x27>
        wirte(cArry[i]);
c010103d:	50                   	push   %eax
c010103e:	50                   	push   %eax
c010103f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101042:	01 d8                	add    %ebx,%eax
    for (uint32_t i = 0; i < len; i++) {
c0101044:	43                   	inc    %ebx
        wirte(cArry[i]);
c0101045:	50                   	push   %eax
c0101046:	ff 75 08             	pushl  0x8(%ebp)
c0101049:	e8 78 ff ff ff       	call   c0100fc6 <_ZN7Console5wirteERKc>
    for (uint32_t i = 0; i < len; i++) {
c010104e:	83 c4 10             	add    $0x10,%esp
c0101051:	eb e0                	jmp    c0101033 <_ZN7Console5wirteEPcRKt+0x7>
}
c0101053:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101056:	c9                   	leave  
c0101057:	c3                   	ret    

c0101058 <__x86.get_pc_thunk.dx>:
c0101058:	8b 14 24             	mov    (%esp),%edx
c010105b:	c3                   	ret    

c010105c <__x86.get_pc_thunk.cx>:
c010105c:	8b 0c 24             	mov    (%esp),%ecx
c010105f:	c3                   	ret    

c0101060 <__x86.get_pc_thunk.di>:
c0101060:	8b 3c 24             	mov    (%esp),%edi
c0101063:	c3                   	ret    

c0101064 <_ZN9InterruptC1Ev>:
#include <interrupt.h>

Interrupt::Interrupt() {
c0101064:	55                   	push   %ebp
c0101065:	89 e5                	mov    %esp,%ebp
    
}
c0101067:	5d                   	pop    %ebp
c0101068:	c3                   	ret    
c0101069:	90                   	nop

c010106a <_ZN9Interrupt7initIDTEv>:
    enableIRQ(2);                                   // set master IR2, because of slave connection to IR2
    
    enableIRQ(8);                                   // set slave IR1, clock interrupt of RTC
}

void Interrupt::initIDT() {
c010106a:	55                   	push   %ebp
c010106b:	89 e5                	mov    %esp,%ebp
c010106d:	57                   	push   %edi
c010106e:	56                   	push   %esi
    extern uptr32_t __vectors[];
    for (uint32_t i = 0; i < sizeof(IDT) / sizeof(MMU::GateDesc); i++) {
c010106f:	31 f6                	xor    %esi,%esi
void Interrupt::initIDT() {
c0101071:	53                   	push   %ebx
c0101072:	e8 3e fb ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0101077:	81 c3 99 b3 01 00    	add    $0x1b399,%ebx
c010107d:	83 ec 1c             	sub    $0x1c,%esp
        MMU::setGateDesc(IDT[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0101080:	c7 c0 00 c0 11 c0    	mov    $0xc011c000,%eax
c0101086:	c7 c7 c0 f1 11 c0    	mov    $0xc011f1c0,%edi
c010108c:	83 ec 0c             	sub    $0xc,%esp
c010108f:	6a 00                	push   $0x0
c0101091:	ff 34 b0             	pushl  (%eax,%esi,4)
c0101094:	8d 14 f7             	lea    (%edi,%esi,8),%edx
    for (uint32_t i = 0; i < sizeof(IDT) / sizeof(MMU::GateDesc); i++) {
c0101097:	46                   	inc    %esi
        MMU::setGateDesc(IDT[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0101098:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010109b:	6a 08                	push   $0x8
c010109d:	6a 00                	push   $0x0
c010109f:	52                   	push   %edx
c01010a0:	e8 4f 33 00 00       	call   c01043f4 <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>
    for (uint32_t i = 0; i < sizeof(IDT) / sizeof(MMU::GateDesc); i++) {
c01010a5:	83 c4 20             	add    $0x20,%esp
c01010a8:	81 fe 00 01 00 00    	cmp    $0x100,%esi
c01010ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01010b1:	75 d9                	jne    c010108c <_ZN9Interrupt7initIDTEv+0x22>
    }
	// set for switch from user to kernel
    MMU::setGateDesc(IDT[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c01010b3:	83 ec 0c             	sub    $0xc,%esp
c01010b6:	6a 03                	push   $0x3
c01010b8:	ff b0 e4 01 00 00    	pushl  0x1e4(%eax)
c01010be:	8d 87 c8 03 00 00    	lea    0x3c8(%edi),%eax
c01010c4:	6a 08                	push   $0x8
c01010c6:	6a 00                	push   $0x0
c01010c8:	50                   	push   %eax
c01010c9:	e8 26 33 00 00       	call   c01043f4 <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>
    asm volatile ("lidt (%0)" :: "r" (pd));
c01010ce:	c7 c0 40 c4 11 c0    	mov    $0xc011c440,%eax
c01010d4:	0f 01 18             	lidtl  (%eax)
	// load the IDT
    lidt(&idtPD);
}
c01010d7:	83 c4 20             	add    $0x20,%esp
c01010da:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01010dd:	5b                   	pop    %ebx
c01010de:	5e                   	pop    %esi
c01010df:	5f                   	pop    %edi
c01010e0:	5d                   	pop    %ebp
c01010e1:	c3                   	ret    

c01010e2 <_ZN9Interrupt4initEv>:
void Interrupt::init() {
c01010e2:	55                   	push   %ebp
c01010e3:	89 e5                	mov    %esp,%ebp
c01010e5:	56                   	push   %esi
c01010e6:	8b 75 08             	mov    0x8(%ebp),%esi
c01010e9:	53                   	push   %ebx
c01010ea:	e8 c6 fa ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c01010ef:	81 c3 21 b3 01 00    	add    $0x1b321,%ebx
    initIDT();
c01010f5:	83 ec 0c             	sub    $0xc,%esp
c01010f8:	56                   	push   %esi
c01010f9:	e8 6c ff ff ff       	call   c010106a <_ZN9Interrupt7initIDTEv>
    initPIC();
c01010fe:	89 34 24             	mov    %esi,(%esp)
c0101101:	e8 36 00 00 00       	call   c010113c <_ZN3PIC7initPICEv>
    initClock();
c0101106:	89 34 24             	mov    %esi,(%esp)
c0101109:	e8 fa 00 00 00       	call   c0101208 <_ZN3RTC9initClockEv>
    enableIRQ(2);                                   // set master IR2, because of slave connection to IR2
c010110e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0101115:	e8 7c 00 00 00       	call   c0101196 <_ZN3PIC9enableIRQEj>
    enableIRQ(8);                                   // set slave IR1, clock interrupt of RTC
c010111a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101121:	e8 70 00 00 00       	call   c0101196 <_ZN3PIC9enableIRQEj>
}
c0101126:	83 c4 10             	add    $0x10,%esp
c0101129:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010112c:	5b                   	pop    %ebx
c010112d:	5e                   	pop    %esi
c010112e:	5d                   	pop    %ebp
c010112f:	c3                   	ret    

c0101130 <_ZN9Interrupt6enableEv>:

void Interrupt::enable() {
c0101130:	55                   	push   %ebp
c0101131:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101133:	fb                   	sti    
    sti();
}
c0101134:	5d                   	pop    %ebp
c0101135:	c3                   	ret    

c0101136 <_ZN9Interrupt7disableEv>:

void Interrupt::disable() {
c0101136:	55                   	push   %ebp
c0101137:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli");
c0101139:	fa                   	cli    
    cli();
}
c010113a:	5d                   	pop    %ebp
c010113b:	c3                   	ret    

c010113c <_ZN3PIC7initPICEv>:
#include <pic.h>

void PIC::initPIC() {
c010113c:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c010113d:	b0 ff                	mov    $0xff,%al
c010113f:	89 e5                	mov    %esp,%ebp
c0101141:	57                   	push   %edi
c0101142:	56                   	push   %esi
c0101143:	be 21 00 00 00       	mov    $0x21,%esi
c0101148:	53                   	push   %ebx
c0101149:	89 f2                	mov    %esi,%edx
c010114b:	e8 10 ff ff ff       	call   c0101060 <__x86.get_pc_thunk.di>
c0101150:	81 c7 c0 b2 01 00    	add    $0x1b2c0,%edi
c0101156:	ee                   	out    %al,(%dx)
c0101157:	bb a1 00 00 00       	mov    $0xa1,%ebx
c010115c:	89 da                	mov    %ebx,%edx
c010115e:	ee                   	out    %al,(%dx)
c010115f:	b1 11                	mov    $0x11,%cl
c0101161:	ba 20 00 00 00       	mov    $0x20,%edx
c0101166:	88 c8                	mov    %cl,%al
c0101168:	ee                   	out    %al,(%dx)
c0101169:	b0 20                	mov    $0x20,%al
c010116b:	89 f2                	mov    %esi,%edx
c010116d:	ee                   	out    %al,(%dx)
c010116e:	b0 04                	mov    $0x4,%al
c0101170:	ee                   	out    %al,(%dx)
c0101171:	b0 01                	mov    $0x1,%al
c0101173:	ee                   	out    %al,(%dx)
c0101174:	ba a0 00 00 00       	mov    $0xa0,%edx
c0101179:	88 c8                	mov    %cl,%al
c010117b:	ee                   	out    %al,(%dx)
c010117c:	b0 70                	mov    $0x70,%al
c010117e:	89 da                	mov    %ebx,%edx
c0101180:	ee                   	out    %al,(%dx)
c0101181:	b0 04                	mov    $0x4,%al
c0101183:	ee                   	out    %al,(%dx)
c0101184:	b0 01                	mov    $0x1,%al
c0101186:	ee                   	out    %al,(%dx)
    outb(ICW1_ICW4, IO1_8259PIC2);                  // ICW1: edge-tri / cascade
    outb(0x70, IO2_8259PIC2);                       // ICW2: set first vectors of interrupt
    outb(0x04, IO2_8259PIC2);                       // ICW3: second chip is link to IR2 of first chip
    outb(0x01, IO2_8259PIC2);                       // ICW4; normal EOI

    didInit = true;                                 // 
c0101187:	c7 c0 2c fa 11 c0    	mov    $0xc011fa2c,%eax
c010118d:	c6 00 01             	movb   $0x1,(%eax)
}
c0101190:	5b                   	pop    %ebx
c0101191:	5e                   	pop    %esi
c0101192:	5f                   	pop    %edi
c0101193:	5d                   	pop    %ebp
c0101194:	c3                   	ret    
c0101195:	90                   	nop

c0101196 <_ZN3PIC9enableIRQEj>:

void PIC::enableIRQ(uint32_t irq) {                 // enable irq
c0101196:	e8 bd fe ff ff       	call   c0101058 <__x86.get_pc_thunk.dx>
c010119b:	81 c2 75 b2 01 00    	add    $0x1b275,%edx
    irqMask &= ~(1 << irq);
c01011a1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
void PIC::enableIRQ(uint32_t irq) {                 // enable irq
c01011a6:	55                   	push   %ebp
c01011a7:	89 e5                	mov    %esp,%ebp
    irqMask &= ~(1 << irq);
c01011a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
void PIC::enableIRQ(uint32_t irq) {                 // enable irq
c01011ac:	53                   	push   %ebx
    irqMask &= ~(1 << irq);
c01011ad:	c7 c3 00 c4 11 c0    	mov    $0xc011c400,%ebx
c01011b3:	d3 c0                	rol    %cl,%eax
    if (didInit) {
c01011b5:	c7 c2 2c fa 11 c0    	mov    $0xc011fa2c,%edx
    irqMask &= ~(1 << irq);
c01011bb:	66 8b 0b             	mov    (%ebx),%cx
c01011be:	21 c8                	and    %ecx,%eax
    if (didInit) {
c01011c0:	80 3a 00             	cmpb   $0x0,(%edx)
    irqMask &= ~(1 << irq);
c01011c3:	98                   	cwtl   
c01011c4:	0f b7 c8             	movzwl %ax,%ecx
c01011c7:	66 89 0b             	mov    %cx,(%ebx)
    if (didInit) {
c01011ca:	74 11                	je     c01011dd <_ZN3PIC9enableIRQEj+0x47>
c01011cc:	ba 21 00 00 00       	mov    $0x21,%edx
c01011d1:	ee                   	out    %al,(%dx)
        outb(irqMask & 0xFF, IO2_8259PIC1);         // master chip
        outb((irqMask >> 8) & 0xFF, IO2_8259PIC2);  // slave chip
c01011d2:	89 c8                	mov    %ecx,%eax
c01011d4:	ba a1 00 00 00       	mov    $0xa1,%edx
c01011d9:	c1 e8 08             	shr    $0x8,%eax
c01011dc:	ee                   	out    %al,(%dx)
    }
}
c01011dd:	5b                   	pop    %ebx
c01011de:	5d                   	pop    %ebp
c01011df:	c3                   	ret    

c01011e0 <_ZN3PIC7sendEOIEv>:

void PIC::sendEOI() {
c01011e0:	55                   	push   %ebp
c01011e1:	b0 20                	mov    $0x20,%al
c01011e3:	89 e5                	mov    %esp,%ebp
c01011e5:	ba a0 00 00 00       	mov    $0xa0,%edx
c01011ea:	ee                   	out    %al,(%dx)
c01011eb:	ba 20 00 00 00       	mov    $0x20,%edx
c01011f0:	ee                   	out    %al,(%dx)
    outb(EOI_CMD, IO1_8259PIC2);                    // send EOI cmd for slave
    outb(EOI_CMD, IO1_8259PIC1);                    // send EOI cmd for master
c01011f1:	5d                   	pop    %ebp
c01011f2:	c3                   	ret    
c01011f3:	90                   	nop

c01011f4 <_ZN3RTC12clInteStatusEv>:
    outb(regA, RTC_DATA_PORT1);                     // write A

    clInteStatus();                                 // clear Interrupt status
}

void RTC::clInteStatus() {
c01011f4:	55                   	push   %ebp
c01011f5:	b0 0c                	mov    $0xc,%al
c01011f7:	89 e5                	mov    %esp,%ebp
c01011f9:	ba 70 00 00 00       	mov    $0x70,%edx
c01011fe:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c01011ff:	ba 71 00 00 00       	mov    $0x71,%edx
c0101204:	ec                   	in     (%dx),%al
    outb(RTC_REG_C, RTC_INDEX_PORT1);               // choice reg C
    inb(RTC_DATA_PORT1);                            // read regC to clear interrupt status
c0101205:	5d                   	pop    %ebp
c0101206:	c3                   	ret    
c0101207:	90                   	nop

c0101208 <_ZN3RTC9initClockEv>:
void RTC::initClock() {
c0101208:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c0101209:	b0 8b                	mov    $0x8b,%al
c010120b:	89 e5                	mov    %esp,%ebp
c010120d:	53                   	push   %ebx
c010120e:	bb 70 00 00 00       	mov    $0x70,%ebx
c0101213:	89 da                	mov    %ebx,%edx
c0101215:	ee                   	out    %al,(%dx)
c0101216:	b9 71 00 00 00       	mov    $0x71,%ecx
c010121b:	b0 42                	mov    $0x42,%al
c010121d:	89 ca                	mov    %ecx,%edx
c010121f:	ee                   	out    %al,(%dx)
c0101220:	b0 0a                	mov    $0xa,%al
c0101222:	89 da                	mov    %ebx,%edx
c0101224:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c0101225:	89 ca                	mov    %ecx,%edx
c0101227:	ec                   	in     (%dx),%al
    regA = (regA & 0xF0) | 0x2;                     // 7.8125ms
c0101228:	24 f0                	and    $0xf0,%al
c010122a:	0c 02                	or     $0x2,%al
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c010122c:	ee                   	out    %al,(%dx)
}
c010122d:	5b                   	pop    %ebx
c010122e:	5d                   	pop    %ebp
    clInteStatus();                                 // clear Interrupt status
c010122f:	eb c3                	jmp    c01011f4 <_ZN3RTC12clInteStatusEv>
c0101231:	90                   	nop

c0101232 <_ZN11VideoMemoryC1Ev>:
#include <vdieomemory.h>

VideoMemory::VideoMemory() {
c0101232:	55                   	push   %ebp
c0101233:	89 e5                	mov    %esp,%ebp
c0101235:	8b 45 08             	mov    0x8(%ebp),%eax
c0101238:	c7 00 00 80 0b c0    	movl   $0xc00b8000,(%eax)
c010123e:	66 c7 40 04 a0 0f    	movw   $0xfa0,0x4(%eax)

}
c0101244:	5d                   	pop    %ebp
c0101245:	c3                   	ret    

c0101246 <_ZN11VideoMemory10initVmBuffEv>:

void VideoMemory::initVmBuff() {
c0101246:	55                   	push   %ebp
    for (uint32_t i = 0; i < VGA_BUFF_SIZE; i++) {
c0101247:	31 c0                	xor    %eax,%eax
void VideoMemory::initVmBuff() {
c0101249:	89 e5                	mov    %esp,%ebp
c010124b:	8b 4d 08             	mov    0x8(%ebp),%ecx
        vmBuffer[i] = 0;
c010124e:	8b 11                	mov    (%ecx),%edx
c0101250:	c6 04 02 00          	movb   $0x0,(%edx,%eax,1)
    for (uint32_t i = 0; i < VGA_BUFF_SIZE; i++) {
c0101254:	40                   	inc    %eax
c0101255:	3d a0 0f 00 00       	cmp    $0xfa0,%eax
c010125a:	75 f2                	jne    c010124e <_ZN11VideoMemory10initVmBuffEv+0x8>
    }
}
c010125c:	5d                   	pop    %ebp
c010125d:	c3                   	ret    

c010125e <_ZN11VideoMemory12getCursorPosEv>:

uint16_t VideoMemory::getCursorPos() {
c010125e:	55                   	push   %ebp
c010125f:	b0 0f                	mov    $0xf,%al
c0101261:	89 e5                	mov    %esp,%ebp
c0101263:	56                   	push   %esi
c0101264:	be d4 03 00 00       	mov    $0x3d4,%esi
c0101269:	53                   	push   %ebx
c010126a:	89 f2                	mov    %esi,%edx
c010126c:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c010126d:	bb d5 03 00 00       	mov    $0x3d5,%ebx
c0101272:	89 da                	mov    %ebx,%edx
c0101274:	ec                   	in     (%dx),%al
c0101275:	0f b6 c8             	movzbl %al,%ecx
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c0101278:	89 f2                	mov    %esi,%edx
c010127a:	b0 0e                	mov    $0xe,%al
c010127c:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c010127d:	89 da                	mov    %ebx,%edx
c010127f:	ec                   	in     (%dx),%al
    outb(VGA_CURSOR_PORT_D, VGA_INDEX_PORT);
    uint8_t low = inb(VGA_DATA_PORT);
    outb(VGA_CURSOR_PORT_H, VGA_INDEX_PORT);
    uint16_t pos = inb(VGA_DATA_PORT);
    return (pos << 8) + low;
}
c0101280:	5b                   	pop    %ebx
    uint16_t pos = inb(VGA_DATA_PORT);
c0101281:	0f b6 c0             	movzbl %al,%eax
    return (pos << 8) + low;
c0101284:	c1 e0 08             	shl    $0x8,%eax
}
c0101287:	5e                   	pop    %esi
    return (pos << 8) + low;
c0101288:	01 c8                	add    %ecx,%eax
}
c010128a:	5d                   	pop    %ebp
c010128b:	c3                   	ret    

c010128c <_ZN11VideoMemory12setCursorPosEt>:

void VideoMemory::setCursorPos(uint16_t pos) {
c010128c:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c010128d:	b0 0f                	mov    $0xf,%al
c010128f:	89 e5                	mov    %esp,%ebp
c0101291:	56                   	push   %esi
c0101292:	be d4 03 00 00       	mov    $0x3d4,%esi
c0101297:	0f b7 4d 0c          	movzwl 0xc(%ebp),%ecx
c010129b:	53                   	push   %ebx
c010129c:	89 f2                	mov    %esi,%edx
c010129e:	ee                   	out    %al,(%dx)
c010129f:	bb d5 03 00 00       	mov    $0x3d5,%ebx
c01012a4:	88 c8                	mov    %cl,%al
c01012a6:	89 da                	mov    %ebx,%edx
c01012a8:	ee                   	out    %al,(%dx)
c01012a9:	b0 0e                	mov    $0xe,%al
c01012ab:	89 f2                	mov    %esi,%edx
c01012ad:	ee                   	out    %al,(%dx)
    outb(VGA_CURSOR_PORT_D, VGA_INDEX_PORT);
    outb((pos & 0xFF), VGA_DATA_PORT);
    outb(VGA_CURSOR_PORT_H, VGA_INDEX_PORT);
    outb(((pos >> 8) & 0xFF), VGA_DATA_PORT);
c01012ae:	89 c8                	mov    %ecx,%eax
c01012b0:	89 da                	mov    %ebx,%edx
c01012b2:	c1 e8 08             	shr    $0x8,%eax
c01012b5:	ee                   	out    %al,(%dx)
}
c01012b6:	5b                   	pop    %ebx
c01012b7:	5e                   	pop    %esi
c01012b8:	5d                   	pop    %ebp
c01012b9:	c3                   	ret    

c01012ba <_ZN3IDE7isValidEj>:
    // enable ide interrupt
    PIC::enableIRQ(IRQ_IDE1);
    PIC::enableIRQ(IRQ_IDE2);
}

bool IDE::isValid(uint32_t ideno) {
c01012ba:	55                   	push   %ebp
c01012bb:	31 c0                	xor    %eax,%eax
c01012bd:	89 e5                	mov    %esp,%ebp
c01012bf:	8b 55 08             	mov    0x8(%ebp),%edx
c01012c2:	e8 95 fd ff ff       	call   c010105c <__x86.get_pc_thunk.cx>
c01012c7:	81 c1 49 b1 01 00    	add    $0x1b149,%ecx
    return ((ideno) >= 0) && ((ideno) < MAX_IDE) && (ideDevs[ideno].valid);
c01012cd:	83 fa 03             	cmp    $0x3,%edx
c01012d0:	77 0f                	ja     c01012e1 <_ZN3IDE7isValidEj+0x27>
c01012d2:	6b d2 32             	imul   $0x32,%edx,%edx
c01012d5:	81 c2 a0 f0 11 c0    	add    $0xc011f0a0,%edx
c01012db:	80 3a 00             	cmpb   $0x0,(%edx)
c01012de:	0f 95 c0             	setne  %al
}
c01012e1:	5d                   	pop    %ebp
c01012e2:	c3                   	ret    
c01012e3:	90                   	nop

c01012e4 <_ZN3IDE9waitReadyEtb>:

uint32_t IDE::waitReady(uint16_t iobase, bool check) {
c01012e4:	55                   	push   %ebp
c01012e5:	89 e5                	mov    %esp,%ebp
c01012e7:	0f b7 55 08          	movzwl 0x8(%ebp),%edx
c01012eb:	8a 4d 0c             	mov    0xc(%ebp),%cl
    uint32_t r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c01012ee:	83 c2 07             	add    $0x7,%edx
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c01012f1:	ec                   	in     (%dx),%al
c01012f2:	84 c0                	test   %al,%al
c01012f4:	78 fb                	js     c01012f1 <_ZN3IDE9waitReadyEtb+0xd>
        /* nothing */;
    if (check && (r & (IDE_DF | IDE_ERR)) != 0) {
        return -1;
    }
    return 0;
c01012f6:	31 d2                	xor    %edx,%edx
    if (check && (r & (IDE_DF | IDE_ERR)) != 0) {
c01012f8:	84 c9                	test   %cl,%cl
c01012fa:	74 09                	je     c0101305 <_ZN3IDE9waitReadyEtb+0x21>
c01012fc:	31 d2                	xor    %edx,%edx
c01012fe:	a8 21                	test   $0x21,%al
c0101300:	0f 95 c2             	setne  %dl
c0101303:	f7 da                	neg    %edx
}
c0101305:	89 d0                	mov    %edx,%eax
c0101307:	5d                   	pop    %ebp
c0101308:	c3                   	ret    
c0101309:	90                   	nop

c010130a <_ZN3IDE4initEv>:
void IDE::init() {
c010130a:	55                   	push   %ebp
c010130b:	89 e5                	mov    %esp,%ebp
c010130d:	57                   	push   %edi
c010130e:	56                   	push   %esi
c010130f:	53                   	push   %ebx
c0101310:	e8 a0 f8 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0101315:	81 c3 fb b0 01 00    	add    $0x1b0fb,%ebx
c010131b:	81 ec 6c 04 00 00    	sub    $0x46c,%esp
c0101321:	c6 85 9f fb ff ff 00 	movb   $0x0,-0x461(%ebp)
c0101328:	c7 85 a0 fb ff ff 00 	movl   $0x0,-0x460(%ebp)
c010132f:	00 00 00 
c0101332:	c7 c0 a0 f0 11 c0    	mov    $0xc011f0a0,%eax
c0101338:	89 85 a4 fb ff ff    	mov    %eax,-0x45c(%ebp)
        iobase = IO_BASE(ideno);
c010133e:	c7 c0 ec 47 10 c0    	mov    $0xc01047ec,%eax
c0101344:	89 85 98 fb ff ff    	mov    %eax,-0x468(%ebp)
        ideDevs[ideno].valid = 0;
c010134a:	8b 85 a4 fb ff ff    	mov    -0x45c(%ebp),%eax
        iobase = IO_BASE(ideno);
c0101350:	8b 8d 98 fb ff ff    	mov    -0x468(%ebp),%ecx
        ideDevs[ideno].valid = 0;
c0101356:	c6 00 00             	movb   $0x0,(%eax)
        iobase = IO_BASE(ideno);
c0101359:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
c010135f:	d1 f8                	sar    %eax
c0101361:	0f b7 34 81          	movzwl (%ecx,%eax,4),%esi
        waitReady(iobase);
c0101365:	6a 00                	push   $0x0
c0101367:	56                   	push   %esi
c0101368:	e8 77 ff ff ff       	call   c01012e4 <_ZN3IDE9waitReadyEtb>
        outb(0xE0 | ((ideno & 1) << 4), iobase + ISA_SDH);
c010136d:	8a 85 9f fb ff ff    	mov    -0x461(%ebp),%al
c0101373:	8d 56 06             	lea    0x6(%esi),%edx
c0101376:	24 10                	and    $0x10,%al
c0101378:	0c e0                	or     $0xe0,%al
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c010137a:	ee                   	out    %al,(%dx)
        waitReady(iobase);
c010137b:	6a 00                	push   $0x0
c010137d:	56                   	push   %esi
c010137e:	e8 61 ff ff ff       	call   c01012e4 <_ZN3IDE9waitReadyEtb>
        outb(IDE_CMD_IDENTIFY, iobase + ISA_COMMAND);
c0101383:	8d 56 07             	lea    0x7(%esi),%edx
c0101386:	b0 ec                	mov    $0xec,%al
c0101388:	0f b7 d2             	movzwl %dx,%edx
c010138b:	ee                   	out    %al,(%dx)
        waitReady(iobase);
c010138c:	6a 00                	push   $0x0
c010138e:	56                   	push   %esi
c010138f:	89 95 94 fb ff ff    	mov    %edx,-0x46c(%ebp)
c0101395:	e8 4a ff ff ff       	call   c01012e4 <_ZN3IDE9waitReadyEtb>
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c010139a:	8b 95 94 fb ff ff    	mov    -0x46c(%ebp),%edx
c01013a0:	ec                   	in     (%dx),%al
        if (inb(iobase + ISA_STATUS) == 0 || waitReady(iobase, true) != 0) {
c01013a1:	83 c4 18             	add    $0x18,%esp
c01013a4:	84 c0                	test   %al,%al
c01013a6:	0f 84 37 02 00 00    	je     c01015e3 <_ZN3IDE4initEv+0x2d9>
c01013ac:	6a 01                	push   $0x1
c01013ae:	56                   	push   %esi
c01013af:	e8 30 ff ff ff       	call   c01012e4 <_ZN3IDE9waitReadyEtb>
c01013b4:	59                   	pop    %ecx
c01013b5:	5f                   	pop    %edi
c01013b6:	85 c0                	test   %eax,%eax
c01013b8:	0f 85 25 02 00 00    	jne    c01015e3 <_ZN3IDE4initEv+0x2d9>
        ideDevs[ideno].valid = 1;
c01013be:	8b 8d a4 fb ff ff    	mov    -0x45c(%ebp),%ecx
        : "memory", "cc");
c01013c4:	8d bd c0 fb ff ff    	lea    -0x440(%ebp),%edi
c01013ca:	89 f2                	mov    %esi,%edx
c01013cc:	c6 01 01             	movb   $0x1,(%ecx)
c01013cf:	b9 80 00 00 00       	mov    $0x80,%ecx
c01013d4:	fc                   	cld    
c01013d5:	f2 6d                	repnz insl (%dx),%es:(%edi)
        uint32_t cmdsets = *(uint32_t *)(ident + IDE_IDENT_CMDSETS);
c01013d7:	8b 8d 64 fc ff ff    	mov    -0x39c(%ebp),%ecx
        if (cmdsets & (1 << 26)) {
c01013dd:	0f ba e1 1a          	bt     $0x1a,%ecx
c01013e1:	73 08                	jae    c01013eb <_ZN3IDE4initEv+0xe1>
            sectors = *(uint32_t *)(ident + IDE_IDENT_MAX_LBA_EXT);
c01013e3:	8b 95 88 fc ff ff    	mov    -0x378(%ebp),%edx
c01013e9:	eb 06                	jmp    c01013f1 <_ZN3IDE4initEv+0xe7>
            sectors = *(uint32_t *)(ident + IDE_IDENT_MAX_LBA);
c01013eb:	8b 95 38 fc ff ff    	mov    -0x3c8(%ebp),%edx
        ideDevs[ideno].sets = cmdsets;
c01013f1:	8b bd a4 fb ff ff    	mov    -0x45c(%ebp),%edi
        assert((*(uint16_t *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c01013f7:	f6 85 23 fc ff ff 02 	testb  $0x2,-0x3dd(%ebp)
        ideDevs[ideno].sets = cmdsets;
c01013fe:	89 4f 01             	mov    %ecx,0x1(%edi)
        ideDevs[ideno].size = sectors;
c0101401:	89 57 05             	mov    %edx,0x5(%edi)
        assert((*(uint16_t *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0101404:	0f 85 9e 00 00 00    	jne    c01014a8 <_ZN3IDE4initEv+0x19e>
c010140a:	89 85 90 fb ff ff    	mov    %eax,-0x470(%ebp)
c0101410:	8d 93 15 83 fe ff    	lea    -0x17ceb(%ebx),%edx
c0101416:	50                   	push   %eax
c0101417:	50                   	push   %eax
c0101418:	52                   	push   %edx
c0101419:	8d b5 b8 fb ff ff    	lea    -0x448(%ebp),%esi
c010141f:	56                   	push   %esi
c0101420:	e8 2b 32 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101425:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c010142b:	58                   	pop    %eax
c010142c:	5a                   	pop    %edx
c010142d:	8d 93 1f 83 fe ff    	lea    -0x17ce1(%ebx),%edx
c0101433:	52                   	push   %edx
c0101434:	8d 95 b3 fb ff ff    	lea    -0x44d(%ebp),%edx
c010143a:	52                   	push   %edx
c010143b:	89 95 94 fb ff ff    	mov    %edx,-0x46c(%ebp)
c0101441:	e8 0a 32 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101446:	8b 95 94 fb ff ff    	mov    -0x46c(%ebp),%edx
c010144c:	83 c4 0c             	add    $0xc,%esp
c010144f:	56                   	push   %esi
c0101450:	52                   	push   %edx
c0101451:	57                   	push   %edi
c0101452:	e8 0f 06 00 00       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0101457:	8b 95 94 fb ff ff    	mov    -0x46c(%ebp),%edx
c010145d:	89 14 24             	mov    %edx,(%esp)
c0101460:	e8 05 32 00 00       	call   c010466a <_ZN6StringD1Ev>
c0101465:	89 34 24             	mov    %esi,(%esp)
c0101468:	e8 fd 31 00 00       	call   c010466a <_ZN6StringD1Ev>
c010146d:	8d 93 30 83 fe ff    	lea    -0x17cd0(%ebx),%edx
c0101473:	59                   	pop    %ecx
c0101474:	58                   	pop    %eax
c0101475:	52                   	push   %edx
c0101476:	56                   	push   %esi
c0101477:	e8 d4 31 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010147c:	58                   	pop    %eax
c010147d:	5a                   	pop    %edx
c010147e:	56                   	push   %esi
c010147f:	57                   	push   %edi
c0101480:	e8 6b 07 00 00       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0101485:	89 34 24             	mov    %esi,(%esp)
c0101488:	e8 dd 31 00 00       	call   c010466a <_ZN6StringD1Ev>
c010148d:	89 3c 24             	mov    %edi,(%esp)
c0101490:	e8 6f 06 00 00       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0101495:	fa                   	cli    
    asm volatile ("hlt");
c0101496:	f4                   	hlt    
c0101497:	89 3c 24             	mov    %edi,(%esp)
c010149a:	e8 a7 06 00 00       	call   c0101b46 <_ZN7OStreamD1Ev>
c010149f:	8b 85 90 fb ff ff    	mov    -0x470(%ebp),%eax
c01014a5:	83 c4 10             	add    $0x10,%esp
c01014a8:	8b 8d a4 fb ff ff    	mov    -0x45c(%ebp),%ecx
            model[i] = data[i + 1], model[i + 1] = data[i];
c01014ae:	8d b5 f7 fb ff ff    	lea    -0x409(%ebp),%esi
c01014b4:	8d bd f6 fb ff ff    	lea    -0x40a(%ebp),%edi
c01014ba:	8d 51 09             	lea    0x9(%ecx),%edx
c01014bd:	8a 0c 06             	mov    (%esi,%eax,1),%cl
c01014c0:	88 0c 02             	mov    %cl,(%edx,%eax,1)
c01014c3:	8a 0c 07             	mov    (%edi,%eax,1),%cl
c01014c6:	88 4c 02 01          	mov    %cl,0x1(%edx,%eax,1)
        for (i = 0; i < length; i += 2) {
c01014ca:	83 c0 02             	add    $0x2,%eax
c01014cd:	83 f8 28             	cmp    $0x28,%eax
c01014d0:	75 eb                	jne    c01014bd <_ZN3IDE4initEv+0x1b3>
c01014d2:	8b 85 a4 fb ff ff    	mov    -0x45c(%ebp),%eax
c01014d8:	83 c0 31             	add    $0x31,%eax
        } while (i -- > 0 && model[i] == ' ');
c01014db:	39 d0                	cmp    %edx,%eax
            model[i] = '\0';
c01014dd:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c01014e0:	74 06                	je     c01014e8 <_ZN3IDE4initEv+0x1de>
c01014e2:	48                   	dec    %eax
c01014e3:	80 38 20             	cmpb   $0x20,(%eax)
c01014e6:	74 f3                	je     c01014db <_ZN3IDE4initEv+0x1d1>
        OStream out("\nide", "blue");
c01014e8:	50                   	push   %eax
c01014e9:	50                   	push   %eax
c01014ea:	8d 83 fa 82 fe ff    	lea    -0x17d06(%ebx),%eax
c01014f0:	8d b5 b8 fb ff ff    	lea    -0x448(%ebp),%esi
c01014f6:	50                   	push   %eax
c01014f7:	56                   	push   %esi
c01014f8:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c01014fe:	89 95 90 fb ff ff    	mov    %edx,-0x470(%ebp)
c0101504:	e8 47 31 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101509:	8d 83 6d 83 fe ff    	lea    -0x17c93(%ebx),%eax
c010150f:	5a                   	pop    %edx
c0101510:	59                   	pop    %ecx
c0101511:	50                   	push   %eax
c0101512:	8d 85 b3 fb ff ff    	lea    -0x44d(%ebp),%eax
c0101518:	50                   	push   %eax
c0101519:	89 85 94 fb ff ff    	mov    %eax,-0x46c(%ebp)
c010151f:	e8 2c 31 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101524:	8b 85 94 fb ff ff    	mov    -0x46c(%ebp),%eax
c010152a:	83 c4 0c             	add    $0xc,%esp
c010152d:	56                   	push   %esi
c010152e:	50                   	push   %eax
c010152f:	57                   	push   %edi
c0101530:	e8 31 05 00 00       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0101535:	8b 85 94 fb ff ff    	mov    -0x46c(%ebp),%eax
c010153b:	89 04 24             	mov    %eax,(%esp)
c010153e:	e8 27 31 00 00       	call   c010466a <_ZN6StringD1Ev>
c0101543:	89 34 24             	mov    %esi,(%esp)
c0101546:	e8 1f 31 00 00       	call   c010466a <_ZN6StringD1Ev>
        out.writeValue(ideno);
c010154b:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
c0101551:	89 85 b8 fb ff ff    	mov    %eax,-0x448(%ebp)
c0101557:	58                   	pop    %eax
c0101558:	5a                   	pop    %edx
c0101559:	56                   	push   %esi
c010155a:	57                   	push   %edi
c010155b:	e8 d4 06 00 00       	call   c0101c34 <_ZN7OStream10writeValueERKj>
        out.write(": ");
c0101560:	59                   	pop    %ecx
c0101561:	58                   	pop    %eax
c0101562:	8d 83 29 87 fe ff    	lea    -0x178d7(%ebx),%eax
c0101568:	50                   	push   %eax
c0101569:	56                   	push   %esi
c010156a:	e8 e1 30 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010156f:	58                   	pop    %eax
c0101570:	5a                   	pop    %edx
c0101571:	56                   	push   %esi
c0101572:	57                   	push   %edi
c0101573:	e8 78 06 00 00       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0101578:	89 34 24             	mov    %esi,(%esp)
c010157b:	e8 ea 30 00 00       	call   c010466a <_ZN6StringD1Ev>
        out.writeValue(ideDevs[ideno].size);
c0101580:	8b 85 a4 fb ff ff    	mov    -0x45c(%ebp),%eax
c0101586:	59                   	pop    %ecx
c0101587:	8b 40 05             	mov    0x5(%eax),%eax
c010158a:	89 85 b8 fb ff ff    	mov    %eax,-0x448(%ebp)
c0101590:	58                   	pop    %eax
c0101591:	56                   	push   %esi
c0101592:	57                   	push   %edi
c0101593:	e8 9c 06 00 00       	call   c0101c34 <_ZN7OStream10writeValueERKj>
        out.write(", model: ");
c0101598:	58                   	pop    %eax
c0101599:	8d 83 72 83 fe ff    	lea    -0x17c8e(%ebx),%eax
c010159f:	5a                   	pop    %edx
c01015a0:	50                   	push   %eax
c01015a1:	56                   	push   %esi
c01015a2:	e8 a9 30 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01015a7:	59                   	pop    %ecx
c01015a8:	58                   	pop    %eax
c01015a9:	56                   	push   %esi
c01015aa:	57                   	push   %edi
c01015ab:	e8 40 06 00 00       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c01015b0:	89 34 24             	mov    %esi,(%esp)
c01015b3:	e8 b2 30 00 00       	call   c010466a <_ZN6StringD1Ev>
        String temp((ccstring)(ideDevs[ideno].model)); 
c01015b8:	58                   	pop    %eax
c01015b9:	5a                   	pop    %edx
c01015ba:	8b 95 90 fb ff ff    	mov    -0x470(%ebp),%edx
c01015c0:	52                   	push   %edx
c01015c1:	56                   	push   %esi
c01015c2:	e8 89 30 00 00       	call   c0104650 <_ZN6StringC1EPKc>
        out.write(temp);
c01015c7:	59                   	pop    %ecx
c01015c8:	58                   	pop    %eax
c01015c9:	56                   	push   %esi
c01015ca:	57                   	push   %edi
c01015cb:	e8 20 06 00 00       	call   c0101bf0 <_ZN7OStream5writeERK6String>
        String temp((ccstring)(ideDevs[ideno].model)); 
c01015d0:	89 34 24             	mov    %esi,(%esp)
c01015d3:	e8 92 30 00 00       	call   c010466a <_ZN6StringD1Ev>
        OStream out("\nide", "blue");
c01015d8:	89 3c 24             	mov    %edi,(%esp)
c01015db:	e8 66 05 00 00       	call   c0101b46 <_ZN7OStreamD1Ev>
c01015e0:	83 c4 10             	add    $0x10,%esp
c01015e3:	ff 85 a0 fb ff ff    	incl   -0x460(%ebp)
c01015e9:	83 85 a4 fb ff ff 32 	addl   $0x32,-0x45c(%ebp)
c01015f0:	80 85 9f fb ff ff 10 	addb   $0x10,-0x461(%ebp)
    for (ideno = 0; ideno < MAX_IDE; ideno++) {
c01015f7:	83 bd a0 fb ff ff 04 	cmpl   $0x4,-0x460(%ebp)
c01015fe:	0f 85 46 fd ff ff    	jne    c010134a <_ZN3IDE4initEv+0x40>
    PIC::enableIRQ(IRQ_IDE1);
c0101604:	83 ec 0c             	sub    $0xc,%esp
c0101607:	6a 0e                	push   $0xe
c0101609:	e8 88 fb ff ff       	call   c0101196 <_ZN3PIC9enableIRQEj>
    PIC::enableIRQ(IRQ_IDE2);
c010160e:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101615:	e8 7c fb ff ff       	call   c0101196 <_ZN3PIC9enableIRQEj>
}
c010161a:	83 c4 10             	add    $0x10,%esp
c010161d:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101620:	5b                   	pop    %ebx
c0101621:	5e                   	pop    %esi
c0101622:	5f                   	pop    %edi
c0101623:	5d                   	pop    %ebp
c0101624:	c3                   	ret    
c0101625:	90                   	nop

c0101626 <_ZN3IDE8readSecsEtjPvj>:

uint32_t IDE::readSecs(uint16_t ideno, uint32_t secno, void *dst, uint32_t nsecs) {
c0101626:	55                   	push   %ebp
c0101627:	89 e5                	mov    %esp,%ebp
c0101629:	57                   	push   %edi
c010162a:	56                   	push   %esi
c010162b:	53                   	push   %ebx
c010162c:	81 ec 4c 02 00 00    	sub    $0x24c,%esp
c0101632:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
c0101636:	e8 7a f5 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c010163b:	81 c3 d5 ad 01 00    	add    $0x1add5,%ebx
    assert(nsecs <= MAX_NSECS && isValid(ideno));
c0101641:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
uint32_t IDE::readSecs(uint16_t ideno, uint32_t secno, void *dst, uint32_t nsecs) {
c0101648:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
    assert(nsecs <= MAX_NSECS && isValid(ideno));
c010164e:	77 0f                	ja     c010165f <_ZN3IDE8readSecsEtjPvj+0x39>
c0101650:	50                   	push   %eax
c0101651:	e8 64 fc ff ff       	call   c01012ba <_ZN3IDE7isValidEj>
c0101656:	59                   	pop    %ecx
c0101657:	84 c0                	test   %al,%al
c0101659:	0f 85 92 00 00 00    	jne    c01016f1 <_ZN3IDE8readSecsEtjPvj+0xcb>
c010165f:	50                   	push   %eax
c0101660:	50                   	push   %eax
c0101661:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0101667:	50                   	push   %eax
c0101668:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c010166e:	56                   	push   %esi
c010166f:	e8 dc 2f 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101674:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c010167a:	58                   	pop    %eax
c010167b:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c0101681:	5a                   	pop    %edx
c0101682:	50                   	push   %eax
c0101683:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c0101689:	50                   	push   %eax
c010168a:	89 85 b0 fd ff ff    	mov    %eax,-0x250(%ebp)
c0101690:	e8 bb 2f 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101695:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c010169b:	83 c4 0c             	add    $0xc,%esp
c010169e:	56                   	push   %esi
c010169f:	50                   	push   %eax
c01016a0:	57                   	push   %edi
c01016a1:	e8 c0 03 00 00       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c01016a6:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c01016ac:	89 04 24             	mov    %eax,(%esp)
c01016af:	e8 b6 2f 00 00       	call   c010466a <_ZN6StringD1Ev>
c01016b4:	89 34 24             	mov    %esi,(%esp)
c01016b7:	e8 ae 2f 00 00       	call   c010466a <_ZN6StringD1Ev>
c01016bc:	59                   	pop    %ecx
c01016bd:	58                   	pop    %eax
c01016be:	8d 83 7c 83 fe ff    	lea    -0x17c84(%ebx),%eax
c01016c4:	50                   	push   %eax
c01016c5:	56                   	push   %esi
c01016c6:	e8 85 2f 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01016cb:	58                   	pop    %eax
c01016cc:	5a                   	pop    %edx
c01016cd:	56                   	push   %esi
c01016ce:	57                   	push   %edi
c01016cf:	e8 1c 05 00 00       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c01016d4:	89 34 24             	mov    %esi,(%esp)
c01016d7:	e8 8e 2f 00 00       	call   c010466a <_ZN6StringD1Ev>
c01016dc:	89 3c 24             	mov    %edi,(%esp)
c01016df:	e8 20 04 00 00       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01016e4:	fa                   	cli    
    asm volatile ("hlt");
c01016e5:	f4                   	hlt    
c01016e6:	89 3c 24             	mov    %edi,(%esp)
c01016e9:	e8 58 04 00 00       	call   c0101b46 <_ZN7OStreamD1Ev>
c01016ee:	83 c4 10             	add    $0x10,%esp
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01016f1:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c01016f8:	77 11                	ja     c010170b <_ZN3IDE8readSecsEtjPvj+0xe5>
c01016fa:	8b 45 14             	mov    0x14(%ebp),%eax
c01016fd:	03 45 0c             	add    0xc(%ebp),%eax
c0101700:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101705:	0f 86 92 00 00 00    	jbe    c010179d <_ZN3IDE8readSecsEtjPvj+0x177>
c010170b:	51                   	push   %ecx
c010170c:	51                   	push   %ecx
c010170d:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0101713:	50                   	push   %eax
c0101714:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c010171a:	56                   	push   %esi
c010171b:	e8 30 2f 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101720:	5f                   	pop    %edi
c0101721:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c0101727:	58                   	pop    %eax
c0101728:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c010172e:	50                   	push   %eax
c010172f:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c0101735:	50                   	push   %eax
c0101736:	89 85 b0 fd ff ff    	mov    %eax,-0x250(%ebp)
c010173c:	e8 0f 2f 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101741:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c0101747:	83 c4 0c             	add    $0xc,%esp
c010174a:	56                   	push   %esi
c010174b:	50                   	push   %eax
c010174c:	57                   	push   %edi
c010174d:	e8 14 03 00 00       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0101752:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c0101758:	89 04 24             	mov    %eax,(%esp)
c010175b:	e8 0a 2f 00 00       	call   c010466a <_ZN6StringD1Ev>
c0101760:	89 34 24             	mov    %esi,(%esp)
c0101763:	e8 02 2f 00 00       	call   c010466a <_ZN6StringD1Ev>
c0101768:	58                   	pop    %eax
c0101769:	8d 83 a1 83 fe ff    	lea    -0x17c5f(%ebx),%eax
c010176f:	5a                   	pop    %edx
c0101770:	50                   	push   %eax
c0101771:	56                   	push   %esi
c0101772:	e8 d9 2e 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101777:	59                   	pop    %ecx
c0101778:	58                   	pop    %eax
c0101779:	56                   	push   %esi
c010177a:	57                   	push   %edi
c010177b:	e8 70 04 00 00       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0101780:	89 34 24             	mov    %esi,(%esp)
c0101783:	e8 e2 2e 00 00       	call   c010466a <_ZN6StringD1Ev>
c0101788:	89 3c 24             	mov    %edi,(%esp)
c010178b:	e8 74 03 00 00       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0101790:	fa                   	cli    
    asm volatile ("hlt");
c0101791:	f4                   	hlt    
c0101792:	89 3c 24             	mov    %edi,(%esp)
c0101795:	e8 ac 03 00 00       	call   c0101b46 <_ZN7OStreamD1Ev>
c010179a:	83 c4 10             	add    $0x10,%esp
    uint16_t iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010179d:	8b 95 b4 fd ff ff    	mov    -0x24c(%ebp),%edx
c01017a3:	c7 c0 ec 47 10 c0    	mov    $0xc01047ec,%eax
c01017a9:	d1 fa                	sar    %edx
c01017ab:	0f b7 1c 90          	movzwl (%eax,%edx,4),%ebx
c01017af:	0f b7 74 90 02       	movzwl 0x2(%eax,%edx,4),%esi

    waitReady(iobase, 0);
c01017b4:	52                   	push   %edx
c01017b5:	52                   	push   %edx
c01017b6:	6a 00                	push   $0x0
c01017b8:	53                   	push   %ebx
c01017b9:	e8 26 fb ff ff       	call   c01012e4 <_ZN3IDE9waitReadyEtb>

    // generate interrupt
    outb(0, ioctrl + ISA_CTRL);
c01017be:	8d 56 02             	lea    0x2(%esi),%edx
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c01017c1:	31 c0                	xor    %eax,%eax
c01017c3:	ee                   	out    %al,(%dx)
    outb(nsecs, iobase + ISA_SECCNT);
c01017c4:	8d 53 02             	lea    0x2(%ebx),%edx
c01017c7:	8a 45 14             	mov    0x14(%ebp),%al
c01017ca:	ee                   	out    %al,(%dx)
    outb(secno & 0xFF, iobase + ISA_SECTOR);
c01017cb:	8d 53 03             	lea    0x3(%ebx),%edx
c01017ce:	8a 45 0c             	mov    0xc(%ebp),%al
c01017d1:	ee                   	out    %al,(%dx)
    outb((secno >> 8) & 0xFF, iobase + ISA_CYL_LO);
c01017d2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01017d5:	8d 53 04             	lea    0x4(%ebx),%edx
c01017d8:	c1 e8 08             	shr    $0x8,%eax
c01017db:	ee                   	out    %al,(%dx)
    outb((secno >> 16) & 0xFF, iobase + ISA_CYL_HI);
c01017dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01017df:	8d 53 05             	lea    0x5(%ebx),%edx
c01017e2:	c1 e8 10             	shr    $0x10,%eax
c01017e5:	ee                   	out    %al,(%dx)
    outb(0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF), iobase + ISA_SDH);
c01017e6:	8a 85 b4 fd ff ff    	mov    -0x24c(%ebp),%al
c01017ec:	8b 55 0c             	mov    0xc(%ebp),%edx
c01017ef:	c0 e0 04             	shl    $0x4,%al
c01017f2:	24 10                	and    $0x10,%al
c01017f4:	c1 ea 18             	shr    $0x18,%edx
c01017f7:	0c e0                	or     $0xe0,%al
c01017f9:	80 e2 0f             	and    $0xf,%dl
c01017fc:	08 d0                	or     %dl,%al
c01017fe:	8d 53 06             	lea    0x6(%ebx),%edx
c0101801:	ee                   	out    %al,(%dx)
c0101802:	b0 20                	mov    $0x20,%al
    outb(IDE_CMD_READ, iobase + ISA_COMMAND);
c0101804:	8d 53 07             	lea    0x7(%ebx),%edx
c0101807:	ee                   	out    %al,(%dx)
c0101808:	83 c4 10             	add    $0x10,%esp

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c010180b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c010180f:	74 2a                	je     c010183b <_ZN3IDE8readSecsEtjPvj+0x215>
        if ((ret = waitReady(iobase, true)) != 0) {
c0101811:	50                   	push   %eax
c0101812:	50                   	push   %eax
c0101813:	6a 01                	push   $0x1
c0101815:	53                   	push   %ebx
c0101816:	e8 c9 fa ff ff       	call   c01012e4 <_ZN3IDE9waitReadyEtb>
c010181b:	83 c4 10             	add    $0x10,%esp
c010181e:	85 c0                	test   %eax,%eax
c0101820:	75 1b                	jne    c010183d <_ZN3IDE8readSecsEtjPvj+0x217>
        : "memory", "cc");
c0101822:	8b 7d 10             	mov    0x10(%ebp),%edi
c0101825:	b9 80 00 00 00       	mov    $0x80,%ecx
c010182a:	89 da                	mov    %ebx,%edx
c010182c:	fc                   	cld    
c010182d:	f2 6d                	repnz insl (%dx),%es:(%edi)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c010182f:	ff 4d 14             	decl   0x14(%ebp)
c0101832:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101839:	eb d0                	jmp    c010180b <_ZN3IDE8readSecsEtjPvj+0x1e5>
c010183b:	31 c0                	xor    %eax,%eax
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

    return ret;
}
c010183d:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101840:	5b                   	pop    %ebx
c0101841:	5e                   	pop    %esi
c0101842:	5f                   	pop    %edi
c0101843:	5d                   	pop    %ebp
c0101844:	c3                   	ret    
c0101845:	90                   	nop

c0101846 <_ZN3IDE9writeSecsEtjPKvj>:

uint32_t IDE::writeSecs(uint16_t ideno, uint32_t secno, const void *src, uint32_t nsecs) {
c0101846:	55                   	push   %ebp
c0101847:	89 e5                	mov    %esp,%ebp
c0101849:	57                   	push   %edi
c010184a:	56                   	push   %esi
c010184b:	53                   	push   %ebx
c010184c:	81 ec 4c 02 00 00    	sub    $0x24c,%esp
c0101852:	0f b7 45 08          	movzwl 0x8(%ebp),%eax
c0101856:	e8 5a f3 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c010185b:	81 c3 b5 ab 01 00    	add    $0x1abb5,%ebx
    assert(nsecs <= MAX_NSECS && isValid(ideno));
c0101861:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
uint32_t IDE::writeSecs(uint16_t ideno, uint32_t secno, const void *src, uint32_t nsecs) {
c0101868:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
    assert(nsecs <= MAX_NSECS && isValid(ideno));
c010186e:	77 0f                	ja     c010187f <_ZN3IDE9writeSecsEtjPKvj+0x39>
c0101870:	50                   	push   %eax
c0101871:	e8 44 fa ff ff       	call   c01012ba <_ZN3IDE7isValidEj>
c0101876:	59                   	pop    %ecx
c0101877:	84 c0                	test   %al,%al
c0101879:	0f 85 92 00 00 00    	jne    c0101911 <_ZN3IDE9writeSecsEtjPKvj+0xcb>
c010187f:	50                   	push   %eax
c0101880:	50                   	push   %eax
c0101881:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0101887:	50                   	push   %eax
c0101888:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c010188e:	56                   	push   %esi
c010188f:	e8 bc 2d 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101894:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c010189a:	58                   	pop    %eax
c010189b:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c01018a1:	5a                   	pop    %edx
c01018a2:	50                   	push   %eax
c01018a3:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c01018a9:	50                   	push   %eax
c01018aa:	89 85 b0 fd ff ff    	mov    %eax,-0x250(%ebp)
c01018b0:	e8 9b 2d 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01018b5:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c01018bb:	83 c4 0c             	add    $0xc,%esp
c01018be:	56                   	push   %esi
c01018bf:	50                   	push   %eax
c01018c0:	57                   	push   %edi
c01018c1:	e8 a0 01 00 00       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c01018c6:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c01018cc:	89 04 24             	mov    %eax,(%esp)
c01018cf:	e8 96 2d 00 00       	call   c010466a <_ZN6StringD1Ev>
c01018d4:	89 34 24             	mov    %esi,(%esp)
c01018d7:	e8 8e 2d 00 00       	call   c010466a <_ZN6StringD1Ev>
c01018dc:	59                   	pop    %ecx
c01018dd:	58                   	pop    %eax
c01018de:	8d 83 7c 83 fe ff    	lea    -0x17c84(%ebx),%eax
c01018e4:	50                   	push   %eax
c01018e5:	56                   	push   %esi
c01018e6:	e8 65 2d 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01018eb:	58                   	pop    %eax
c01018ec:	5a                   	pop    %edx
c01018ed:	56                   	push   %esi
c01018ee:	57                   	push   %edi
c01018ef:	e8 fc 02 00 00       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c01018f4:	89 34 24             	mov    %esi,(%esp)
c01018f7:	e8 6e 2d 00 00       	call   c010466a <_ZN6StringD1Ev>
c01018fc:	89 3c 24             	mov    %edi,(%esp)
c01018ff:	e8 00 02 00 00       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0101904:	fa                   	cli    
    asm volatile ("hlt");
c0101905:	f4                   	hlt    
c0101906:	89 3c 24             	mov    %edi,(%esp)
c0101909:	e8 38 02 00 00       	call   c0101b46 <_ZN7OStreamD1Ev>
c010190e:	83 c4 10             	add    $0x10,%esp
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c0101911:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101918:	77 11                	ja     c010192b <_ZN3IDE9writeSecsEtjPKvj+0xe5>
c010191a:	8b 45 14             	mov    0x14(%ebp),%eax
c010191d:	03 45 0c             	add    0xc(%ebp),%eax
c0101920:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101925:	0f 86 92 00 00 00    	jbe    c01019bd <_ZN3IDE9writeSecsEtjPKvj+0x177>
c010192b:	51                   	push   %ecx
c010192c:	51                   	push   %ecx
c010192d:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0101933:	50                   	push   %eax
c0101934:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c010193a:	56                   	push   %esi
c010193b:	e8 10 2d 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101940:	5f                   	pop    %edi
c0101941:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c0101947:	58                   	pop    %eax
c0101948:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c010194e:	50                   	push   %eax
c010194f:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c0101955:	50                   	push   %eax
c0101956:	89 85 b0 fd ff ff    	mov    %eax,-0x250(%ebp)
c010195c:	e8 ef 2c 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101961:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c0101967:	83 c4 0c             	add    $0xc,%esp
c010196a:	56                   	push   %esi
c010196b:	50                   	push   %eax
c010196c:	57                   	push   %edi
c010196d:	e8 f4 00 00 00       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0101972:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c0101978:	89 04 24             	mov    %eax,(%esp)
c010197b:	e8 ea 2c 00 00       	call   c010466a <_ZN6StringD1Ev>
c0101980:	89 34 24             	mov    %esi,(%esp)
c0101983:	e8 e2 2c 00 00       	call   c010466a <_ZN6StringD1Ev>
c0101988:	58                   	pop    %eax
c0101989:	8d 83 a1 83 fe ff    	lea    -0x17c5f(%ebx),%eax
c010198f:	5a                   	pop    %edx
c0101990:	50                   	push   %eax
c0101991:	56                   	push   %esi
c0101992:	e8 b9 2c 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101997:	59                   	pop    %ecx
c0101998:	58                   	pop    %eax
c0101999:	56                   	push   %esi
c010199a:	57                   	push   %edi
c010199b:	e8 50 02 00 00       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c01019a0:	89 34 24             	mov    %esi,(%esp)
c01019a3:	e8 c2 2c 00 00       	call   c010466a <_ZN6StringD1Ev>
c01019a8:	89 3c 24             	mov    %edi,(%esp)
c01019ab:	e8 54 01 00 00       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01019b0:	fa                   	cli    
    asm volatile ("hlt");
c01019b1:	f4                   	hlt    
c01019b2:	89 3c 24             	mov    %edi,(%esp)
c01019b5:	e8 8c 01 00 00       	call   c0101b46 <_ZN7OStreamD1Ev>
c01019ba:	83 c4 10             	add    $0x10,%esp
    uint16_t iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c01019bd:	8b 95 b4 fd ff ff    	mov    -0x24c(%ebp),%edx
c01019c3:	c7 c0 ec 47 10 c0    	mov    $0xc01047ec,%eax
c01019c9:	d1 fa                	sar    %edx
c01019cb:	0f b7 1c 90          	movzwl (%eax,%edx,4),%ebx
c01019cf:	0f b7 74 90 02       	movzwl 0x2(%eax,%edx,4),%esi

    waitReady(iobase);
c01019d4:	52                   	push   %edx
c01019d5:	52                   	push   %edx
c01019d6:	6a 00                	push   $0x0
c01019d8:	53                   	push   %ebx
c01019d9:	e8 06 f9 ff ff       	call   c01012e4 <_ZN3IDE9waitReadyEtb>

    // generate interrupt
    outb(0, ioctrl + ISA_CTRL);
c01019de:	8d 56 02             	lea    0x2(%esi),%edx
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c01019e1:	31 c0                	xor    %eax,%eax
c01019e3:	ee                   	out    %al,(%dx)
    outb(nsecs, iobase + ISA_SECCNT);
c01019e4:	8d 53 02             	lea    0x2(%ebx),%edx
c01019e7:	8a 45 14             	mov    0x14(%ebp),%al
c01019ea:	ee                   	out    %al,(%dx)
    outb(secno & 0xFF, iobase + ISA_SECTOR);
c01019eb:	8d 53 03             	lea    0x3(%ebx),%edx
c01019ee:	8a 45 0c             	mov    0xc(%ebp),%al
c01019f1:	ee                   	out    %al,(%dx)
    outb((secno >> 8) & 0xFF, iobase + ISA_CYL_LO);
c01019f2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019f5:	8d 53 04             	lea    0x4(%ebx),%edx
c01019f8:	c1 e8 08             	shr    $0x8,%eax
c01019fb:	ee                   	out    %al,(%dx)
    outb((secno >> 16) & 0xFF, iobase + ISA_CYL_HI);
c01019fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01019ff:	8d 53 05             	lea    0x5(%ebx),%edx
c0101a02:	c1 e8 10             	shr    $0x10,%eax
c0101a05:	ee                   	out    %al,(%dx)
    outb(0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF), iobase + ISA_SDH);
c0101a06:	8a 85 b4 fd ff ff    	mov    -0x24c(%ebp),%al
c0101a0c:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101a0f:	c0 e0 04             	shl    $0x4,%al
c0101a12:	24 10                	and    $0x10,%al
c0101a14:	c1 ea 18             	shr    $0x18,%edx
c0101a17:	0c e0                	or     $0xe0,%al
c0101a19:	80 e2 0f             	and    $0xf,%dl
c0101a1c:	08 d0                	or     %dl,%al
c0101a1e:	8d 53 06             	lea    0x6(%ebx),%edx
c0101a21:	ee                   	out    %al,(%dx)
c0101a22:	b0 20                	mov    $0x20,%al
    outb(IDE_CMD_READ, iobase + ISA_COMMAND);
c0101a24:	8d 53 07             	lea    0x7(%ebx),%edx
c0101a27:	ee                   	out    %al,(%dx)
c0101a28:	83 c4 10             	add    $0x10,%esp

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101a2b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c0101a2f:	74 2a                	je     c0101a5b <_ZN3IDE9writeSecsEtjPKvj+0x215>
        if ((ret = waitReady(iobase, true)) != 0) {
c0101a31:	50                   	push   %eax
c0101a32:	50                   	push   %eax
c0101a33:	6a 01                	push   $0x1
c0101a35:	53                   	push   %ebx
c0101a36:	e8 a9 f8 ff ff       	call   c01012e4 <_ZN3IDE9waitReadyEtb>
c0101a3b:	83 c4 10             	add    $0x10,%esp
c0101a3e:	85 c0                	test   %eax,%eax
c0101a40:	75 1b                	jne    c0101a5d <_ZN3IDE9writeSecsEtjPKvj+0x217>
        : "memory", "cc");
c0101a42:	8b 75 10             	mov    0x10(%ebp),%esi
c0101a45:	b9 80 00 00 00       	mov    $0x80,%ecx
c0101a4a:	89 da                	mov    %ebx,%edx
c0101a4c:	fc                   	cld    
c0101a4d:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101a4f:	ff 4d 14             	decl   0x14(%ebp)
c0101a52:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c0101a59:	eb d0                	jmp    c0101a2b <_ZN3IDE9writeSecsEtjPKvj+0x1e5>
c0101a5b:	31 c0                	xor    %eax,%eax
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

    return ret;
}
c0101a5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101a60:	5b                   	pop    %ebx
c0101a61:	5e                   	pop    %esi
c0101a62:	5f                   	pop    %edi
c0101a63:	5d                   	pop    %ebp
c0101a64:	c3                   	ret    
c0101a65:	90                   	nop

c0101a66 <_ZN7OStreamC1E6StringS0_>:
 * @Last Modified time: 2020-04-10 17:26:15
 */

#include <ostream.h>

OStream::OStream(String str, String col) {
c0101a66:	55                   	push   %ebp
c0101a67:	89 e5                	mov    %esp,%ebp
c0101a69:	57                   	push   %edi
c0101a6a:	56                   	push   %esi
c0101a6b:	53                   	push   %ebx
c0101a6c:	83 ec 28             	sub    $0x28,%esp
c0101a6f:	e8 41 f1 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0101a74:	81 c3 9c a9 01 00    	add    $0x1a99c,%ebx
c0101a7a:	8b 75 08             	mov    0x8(%ebp),%esi
c0101a7d:	8b 7d 10             	mov    0x10(%ebp),%edi
c0101a80:	56                   	push   %esi
c0101a81:	e8 34 f1 ff ff       	call   c0100bba <_ZN7ConsoleC1Ev>
    cons.setColor(col);
c0101a86:	8b 07                	mov    (%edi),%eax
OStream::OStream(String str, String col) {
c0101a88:	c7 86 22 02 00 00 00 	movl   $0x200,0x222(%esi)
c0101a8f:	02 00 00 
    cons.setColor(col);
c0101a92:	5a                   	pop    %edx
c0101a93:	59                   	pop    %ecx
c0101a94:	89 45 e3             	mov    %eax,-0x1d(%ebp)
c0101a97:	8a 47 04             	mov    0x4(%edi),%al
c0101a9a:	8d 7d e3             	lea    -0x1d(%ebp),%edi
c0101a9d:	57                   	push   %edi
c0101a9e:	56                   	push   %esi
c0101a9f:	88 45 e7             	mov    %al,-0x19(%ebp)
c0101aa2:	e8 b5 f1 ff ff       	call   c0100c5c <_ZN7Console8setColorE6String>
c0101aa7:	89 3c 24             	mov    %edi,(%esp)
c0101aaa:	e8 bb 2b 00 00       	call   c010466a <_ZN6StringD1Ev>
    buffPointer = 0;
c0101aaf:	c7 86 1e 02 00 00 00 	movl   $0x0,0x21e(%esi)
c0101ab6:	00 00 00 
c0101ab9:	83 c4 10             	add    $0x10,%esp
    for (; buffPointer < str.getLength(); buffPointer++) {
c0101abc:	8b be 1e 02 00 00    	mov    0x21e(%esi),%edi
c0101ac2:	83 ec 0c             	sub    $0xc,%esp
c0101ac5:	ff 75 0c             	pushl  0xc(%ebp)
c0101ac8:	e8 e3 2b 00 00       	call   c01046b0 <_ZNK6String9getLengthEv>
c0101acd:	83 c4 10             	add    $0x10,%esp
c0101ad0:	0f b6 c0             	movzbl %al,%eax
c0101ad3:	39 c7                	cmp    %eax,%edi
c0101ad5:	73 25                	jae    c0101afc <_ZN7OStreamC1E6StringS0_+0x96>
        buffer[buffPointer] = str[buffPointer];
c0101ad7:	50                   	push   %eax
c0101ad8:	50                   	push   %eax
c0101ad9:	ff b6 1e 02 00 00    	pushl  0x21e(%esi)
c0101adf:	ff 75 0c             	pushl  0xc(%ebp)
c0101ae2:	e8 0f 2c 00 00       	call   c01046f6 <_ZN6StringixEj>
c0101ae7:	8b 8e 1e 02 00 00    	mov    0x21e(%esi),%ecx
c0101aed:	8a 00                	mov    (%eax),%al
c0101aef:	88 44 0e 1e          	mov    %al,0x1e(%esi,%ecx,1)
    for (; buffPointer < str.getLength(); buffPointer++) {
c0101af3:	41                   	inc    %ecx
c0101af4:	89 8e 1e 02 00 00    	mov    %ecx,0x21e(%esi)
c0101afa:	eb bd                	jmp    c0101ab9 <_ZN7OStreamC1E6StringS0_+0x53>
    }
}
c0101afc:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101aff:	5b                   	pop    %ebx
c0101b00:	5e                   	pop    %esi
c0101b01:	5f                   	pop    %edi
c0101b02:	5d                   	pop    %ebp
c0101b03:	c3                   	ret    

c0101b04 <_ZN7OStream5flushEv>:

OStream::~OStream() {
    flush();
}

void OStream::flush() {
c0101b04:	55                   	push   %ebp
c0101b05:	89 e5                	mov    %esp,%ebp
c0101b07:	56                   	push   %esi
c0101b08:	53                   	push   %ebx
c0101b09:	83 ec 14             	sub    $0x14,%esp
c0101b0c:	8b 75 08             	mov    0x8(%ebp),%esi
c0101b0f:	e8 a1 f0 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0101b14:	81 c3 fc a8 01 00    	add    $0x1a8fc,%ebx
    cons.wirte(buffer, buffPointer);
c0101b1a:	8b 86 1e 02 00 00    	mov    0x21e(%esi),%eax
c0101b20:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c0101b24:	8d 45 f6             	lea    -0xa(%ebp),%eax
c0101b27:	50                   	push   %eax
c0101b28:	8d 46 1e             	lea    0x1e(%esi),%eax
c0101b2b:	50                   	push   %eax
c0101b2c:	56                   	push   %esi
c0101b2d:	e8 fa f4 ff ff       	call   c010102c <_ZN7Console5wirteEPcRKt>
    buffPointer = 0;
}
c0101b32:	83 c4 10             	add    $0x10,%esp
    buffPointer = 0;
c0101b35:	c7 86 1e 02 00 00 00 	movl   $0x0,0x21e(%esi)
c0101b3c:	00 00 00 
}
c0101b3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101b42:	5b                   	pop    %ebx
c0101b43:	5e                   	pop    %esi
c0101b44:	5d                   	pop    %ebp
c0101b45:	c3                   	ret    

c0101b46 <_ZN7OStreamD1Ev>:
OStream::~OStream() {
c0101b46:	55                   	push   %ebp
c0101b47:	89 e5                	mov    %esp,%ebp
c0101b49:	57                   	push   %edi
c0101b4a:	56                   	push   %esi
c0101b4b:	53                   	push   %ebx
c0101b4c:	83 ec 18             	sub    $0x18,%esp
c0101b4f:	8b 75 08             	mov    0x8(%ebp),%esi
c0101b52:	e8 5e f0 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0101b57:	81 c3 b9 a8 01 00    	add    $0x1a8b9,%ebx
    flush();
c0101b5d:	56                   	push   %esi
c0101b5e:	e8 a1 ff ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
#include <vdieomemory.h>
#include <string.h>

#define COLOR_NUM       4

class Console : public VideoMemory {
c0101b63:	8d 7e 06             	lea    0x6(%esi),%edi
c0101b66:	83 c6 1a             	add    $0x1a,%esi
c0101b69:	83 c4 10             	add    $0x10,%esp
c0101b6c:	39 f7                	cmp    %esi,%edi
c0101b6e:	74 0e                	je     c0101b7e <_ZN7OStreamD1Ev+0x38>
c0101b70:	83 ee 05             	sub    $0x5,%esi
c0101b73:	83 ec 0c             	sub    $0xc,%esp
c0101b76:	56                   	push   %esi
c0101b77:	e8 ee 2a 00 00       	call   c010466a <_ZN6StringD1Ev>
c0101b7c:	eb eb                	jmp    c0101b69 <_ZN7OStreamD1Ev+0x23>
}
c0101b7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101b81:	5b                   	pop    %ebx
c0101b82:	5e                   	pop    %esi
c0101b83:	5f                   	pop    %edi
c0101b84:	5d                   	pop    %ebp
c0101b85:	c3                   	ret    

c0101b86 <_ZN7OStream5writeERKc>:

void OStream::write(const char &c) {
c0101b86:	55                   	push   %ebp
c0101b87:	89 e5                	mov    %esp,%ebp
c0101b89:	53                   	push   %ebx
c0101b8a:	50                   	push   %eax
c0101b8b:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (buffPointer + 1 > BUFFER_MAX) {
c0101b8e:	8b 83 1e 02 00 00    	mov    0x21e(%ebx),%eax
c0101b94:	40                   	inc    %eax
c0101b95:	3b 83 22 02 00 00    	cmp    0x222(%ebx),%eax
c0101b9b:	76 0c                	jbe    c0101ba9 <_ZN7OStream5writeERKc+0x23>
        flush();
c0101b9d:	83 ec 0c             	sub    $0xc,%esp
c0101ba0:	53                   	push   %ebx
c0101ba1:	e8 5e ff ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
c0101ba6:	83 c4 10             	add    $0x10,%esp
    }
    buffer[buffPointer++] = c;
c0101ba9:	8b 83 1e 02 00 00    	mov    0x21e(%ebx),%eax
c0101baf:	8d 50 01             	lea    0x1(%eax),%edx
c0101bb2:	89 93 1e 02 00 00    	mov    %edx,0x21e(%ebx)
c0101bb8:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101bbb:	8a 12                	mov    (%edx),%dl
c0101bbd:	88 54 03 1e          	mov    %dl,0x1e(%ebx,%eax,1)
}
c0101bc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101bc4:	c9                   	leave  
c0101bc5:	c3                   	ret    

c0101bc6 <_ZN7OStream5writeEPKcRKj>:

void OStream::write(const char *arr, const uint32_t &len) {
c0101bc6:	55                   	push   %ebp
c0101bc7:	89 e5                	mov    %esp,%ebp
c0101bc9:	53                   	push   %ebx
    for (uint32_t i = 0; i < len; i++) {
c0101bca:	31 db                	xor    %ebx,%ebx
void OStream::write(const char *arr, const uint32_t &len) {
c0101bcc:	52                   	push   %edx
    for (uint32_t i = 0; i < len; i++) {
c0101bcd:	8b 45 10             	mov    0x10(%ebp),%eax
c0101bd0:	39 18                	cmp    %ebx,(%eax)
c0101bd2:	76 16                	jbe    c0101bea <_ZN7OStream5writeEPKcRKj+0x24>
        write(arr[i]);
c0101bd4:	50                   	push   %eax
c0101bd5:	50                   	push   %eax
c0101bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101bd9:	01 d8                	add    %ebx,%eax
    for (uint32_t i = 0; i < len; i++) {
c0101bdb:	43                   	inc    %ebx
        write(arr[i]);
c0101bdc:	50                   	push   %eax
c0101bdd:	ff 75 08             	pushl  0x8(%ebp)
c0101be0:	e8 a1 ff ff ff       	call   c0101b86 <_ZN7OStream5writeERKc>
    for (uint32_t i = 0; i < len; i++) {
c0101be5:	83 c4 10             	add    $0x10,%esp
c0101be8:	eb e3                	jmp    c0101bcd <_ZN7OStream5writeEPKcRKj+0x7>
    }
}
c0101bea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101bed:	c9                   	leave  
c0101bee:	c3                   	ret    
c0101bef:	90                   	nop

c0101bf0 <_ZN7OStream5writeERK6String>:

void OStream::write(const String &str) {
c0101bf0:	55                   	push   %ebp
c0101bf1:	89 e5                	mov    %esp,%ebp
c0101bf3:	56                   	push   %esi
c0101bf4:	53                   	push   %ebx
c0101bf5:	83 ec 1c             	sub    $0x1c,%esp
c0101bf8:	e8 b8 ef ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0101bfd:	81 c3 13 a8 01 00    	add    $0x1a813,%ebx
c0101c03:	8b 75 0c             	mov    0xc(%ebp),%esi
    write(str.cStr(), str.getLength());
c0101c06:	56                   	push   %esi
c0101c07:	e8 a4 2a 00 00       	call   c01046b0 <_ZNK6String9getLengthEv>
c0101c0c:	89 34 24             	mov    %esi,(%esp)
c0101c0f:	0f b6 c0             	movzbl %al,%eax
c0101c12:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101c15:	e8 8c 2a 00 00       	call   c01046a6 <_ZNK6String4cStrEv>
c0101c1a:	83 c4 0c             	add    $0xc,%esp
c0101c1d:	8d 55 f4             	lea    -0xc(%ebp),%edx
c0101c20:	52                   	push   %edx
c0101c21:	50                   	push   %eax
c0101c22:	ff 75 08             	pushl  0x8(%ebp)
c0101c25:	e8 9c ff ff ff       	call   c0101bc6 <_ZN7OStream5writeEPKcRKj>
}
c0101c2a:	83 c4 10             	add    $0x10,%esp
c0101c2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101c30:	5b                   	pop    %ebx
c0101c31:	5e                   	pop    %esi
c0101c32:	5d                   	pop    %ebp
c0101c33:	c3                   	ret    

c0101c34 <_ZN7OStream10writeValueERKj>:

void OStream::writeValue(const uint32_t &val) {
c0101c34:	55                   	push   %ebp
c0101c35:	89 e5                	mov    %esp,%ebp
c0101c37:	57                   	push   %edi
c0101c38:	56                   	push   %esi
c0101c39:	53                   	push   %ebx
c0101c3a:	83 ec 3c             	sub    $0x3c,%esp
    if (val < 10) {
c0101c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
void OStream::writeValue(const uint32_t &val) {
c0101c40:	8b 75 08             	mov    0x8(%ebp),%esi
    if (val < 10) {
c0101c43:	8b 00                	mov    (%eax),%eax
c0101c45:	83 f8 09             	cmp    $0x9,%eax
c0101c48:	77 16                	ja     c0101c60 <_ZN7OStream10writeValueERKj+0x2c>
        write(val + '0');
c0101c4a:	04 30                	add    $0x30,%al
c0101c4c:	52                   	push   %edx
c0101c4d:	52                   	push   %edx
c0101c4e:	88 45 c5             	mov    %al,-0x3b(%ebp)
c0101c51:	8d 45 c5             	lea    -0x3b(%ebp),%eax
c0101c54:	50                   	push   %eax
c0101c55:	56                   	push   %esi
c0101c56:	e8 2b ff ff ff       	call   c0101b86 <_ZN7OStream5writeERKc>
c0101c5b:	83 c4 10             	add    $0x10,%esp
c0101c5e:	eb 30                	jmp    c0101c90 <_ZN7OStream10writeValueERKj+0x5c>
c0101c60:	31 db                	xor    %ebx,%ebx
c0101c62:	8d 7d c4             	lea    -0x3c(%ebp),%edi
    } else {
        uint8_t s[35];
        uint32_t temp = val, pos = 0;
        while (temp) {
            s[pos++] = temp % 10;
c0101c65:	31 d2                	xor    %edx,%edx
c0101c67:	b9 0a 00 00 00       	mov    $0xa,%ecx
c0101c6c:	f7 f1                	div    %ecx
c0101c6e:	43                   	inc    %ebx
        while (temp) {
c0101c6f:	85 c0                	test   %eax,%eax
            s[pos++] = temp % 10;
c0101c71:	88 14 1f             	mov    %dl,(%edi,%ebx,1)
        while (temp) {
c0101c74:	75 ef                	jne    c0101c65 <_ZN7OStream10writeValueERKj+0x31>
            temp /= 10;
        }
        while (pos) {
            write(s[--pos] + '0');
c0101c76:	4b                   	dec    %ebx
c0101c77:	8a 44 1d c5          	mov    -0x3b(%ebp,%ebx,1),%al
c0101c7b:	04 30                	add    $0x30,%al
c0101c7d:	88 45 c4             	mov    %al,-0x3c(%ebp)
c0101c80:	50                   	push   %eax
c0101c81:	50                   	push   %eax
c0101c82:	57                   	push   %edi
c0101c83:	56                   	push   %esi
c0101c84:	e8 fd fe ff ff       	call   c0101b86 <_ZN7OStream5writeERKc>
        while (pos) {
c0101c89:	83 c4 10             	add    $0x10,%esp
c0101c8c:	85 db                	test   %ebx,%ebx
c0101c8e:	75 e6                	jne    c0101c76 <_ZN7OStream10writeValueERKj+0x42>
        }
    }
c0101c90:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101c93:	5b                   	pop    %ebx
c0101c94:	5e                   	pop    %esi
c0101c95:	5f                   	pop    %edi
c0101c96:	5d                   	pop    %ebp
c0101c97:	c3                   	ret    

c0101c98 <_ZN7ConsoleD1Ev>:
c0101c98:	55                   	push   %ebp
c0101c99:	89 e5                	mov    %esp,%ebp
c0101c9b:	57                   	push   %edi
c0101c9c:	56                   	push   %esi
c0101c9d:	53                   	push   %ebx
c0101c9e:	83 ec 0c             	sub    $0xc,%esp
c0101ca1:	e8 0f ef ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0101ca6:	81 c3 6a a7 01 00    	add    $0x1a76a,%ebx
c0101cac:	8b 75 08             	mov    0x8(%ebp),%esi
c0101caf:	8d 7e 06             	lea    0x6(%esi),%edi
c0101cb2:	83 c6 1a             	add    $0x1a,%esi
c0101cb5:	39 f7                	cmp    %esi,%edi
c0101cb7:	74 11                	je     c0101cca <_ZN7ConsoleD1Ev+0x32>
c0101cb9:	83 ec 0c             	sub    $0xc,%esp
c0101cbc:	83 ee 05             	sub    $0x5,%esi
c0101cbf:	56                   	push   %esi
c0101cc0:	e8 a5 29 00 00       	call   c010466a <_ZN6StringD1Ev>
c0101cc5:	83 c4 10             	add    $0x10,%esp
c0101cc8:	eb eb                	jmp    c0101cb5 <_ZN7ConsoleD1Ev+0x1d>
c0101cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101ccd:	5b                   	pop    %ebx
c0101cce:	5e                   	pop    %esi
c0101ccf:	5f                   	pop    %edi
c0101cd0:	5d                   	pop    %ebp
c0101cd1:	c3                   	ret    

c0101cd2 <_ZN5PhyMMD1Ev>:
#include <list.hpp>
#include <flags.h>

/*      physical Memory management      */

class PhyMM : public MMU {
c0101cd2:	55                   	push   %ebp
c0101cd3:	89 e5                	mov    %esp,%ebp
c0101cd5:	53                   	push   %ebx
c0101cd6:	e8 da ee ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0101cdb:	81 c3 35 a7 01 00    	add    $0x1a735,%ebx
c0101ce1:	83 ec 10             	sub    $0x10,%esp
c0101ce4:	8b 45 08             	mov    0x8(%ebp),%eax
#include <defs.h>
#include <mmu.h>
#include <list.hpp>
#include <string.h>

class PmmManager {
c0101ce7:	83 c0 24             	add    $0x24,%eax
c0101cea:	8d 93 14 00 00 00    	lea    0x14(%ebx),%edx
c0101cf0:	89 50 fc             	mov    %edx,-0x4(%eax)
c0101cf3:	50                   	push   %eax
c0101cf4:	e8 71 29 00 00       	call   c010466a <_ZN6StringD1Ev>
c0101cf9:	83 c4 10             	add    $0x10,%esp
c0101cfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101cff:	c9                   	leave  
c0101d00:	c3                   	ret    

c0101d01 <_GLOBAL__sub_I__ZN6kernel7consoleE>:
    Console console;

    PhyMM pmm;

    Interrupt interrupt;
c0101d01:	55                   	push   %ebp
c0101d02:	89 e5                	mov    %esp,%ebp
c0101d04:	57                   	push   %edi
c0101d05:	56                   	push   %esi
c0101d06:	53                   	push   %ebx
c0101d07:	e8 a9 ee ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0101d0c:	81 c3 04 a7 01 00    	add    $0x1a704,%ebx
c0101d12:	83 ec 18             	sub    $0x18,%esp
    Console console;
c0101d15:	8d b3 58 2c 00 00    	lea    0x2c58(%ebx),%esi
c0101d1b:	56                   	push   %esi
c0101d1c:	e8 99 ee ff ff       	call   c0100bba <_ZN7ConsoleC1Ev>
c0101d21:	8d bb 30 36 00 00    	lea    0x3630(%ebx),%edi
c0101d27:	83 c4 0c             	add    $0xc,%esp
c0101d2a:	57                   	push   %edi
c0101d2b:	56                   	push   %esi
c0101d2c:	8d 83 88 58 fe ff    	lea    -0x1a778(%ebx),%eax
c0101d32:	50                   	push   %eax
    PhyMM pmm;
c0101d33:	8d b3 10 2c 00 00    	lea    0x2c10(%ebx),%esi
    Console console;
c0101d39:	e8 2b 28 00 00       	call   c0104569 <__cxa_atexit>
    PhyMM pmm;
c0101d3e:	89 34 24             	mov    %esi,(%esp)
c0101d41:	e8 70 00 00 00       	call   c0101db6 <_ZN5PhyMMC1Ev>
c0101d46:	83 c4 0c             	add    $0xc,%esp
c0101d49:	57                   	push   %edi
c0101d4a:	56                   	push   %esi
c0101d4b:	8d 83 c2 58 fe ff    	lea    -0x1a73e(%ebx),%eax
c0101d51:	50                   	push   %eax
c0101d52:	e8 12 28 00 00       	call   c0104569 <__cxa_atexit>
    Interrupt interrupt;
c0101d57:	8d 83 f0 2b 00 00    	lea    0x2bf0(%ebx),%eax
c0101d5d:	89 04 24             	mov    %eax,(%esp)
c0101d60:	e8 ff f2 ff ff       	call   c0101064 <_ZN9InterruptC1Ev>
c0101d65:	83 c4 10             	add    $0x10,%esp
c0101d68:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101d6b:	5b                   	pop    %ebx
c0101d6c:	5e                   	pop    %esi
c0101d6d:	5f                   	pop    %edi
c0101d6e:	5d                   	pop    %ebp
c0101d6f:	c3                   	ret    

c0101d70 <_ZN5Utils7roundUpEjj>:
        static void memset(uptr32_t ad, uint8_t byte, uint32_t size);


};

uint32_t Utils::roundUp(uint32_t a, uint32_t n) {
c0101d70:	55                   	push   %ebp
c0101d71:	31 d2                	xor    %edx,%edx
c0101d73:	89 e5                	mov    %esp,%ebp
c0101d75:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0101d78:	89 c8                	mov    %ecx,%eax
c0101d7a:	f7 75 0c             	divl   0xc(%ebp)
    a = (a % n == 0) ? a : (a / n + 1) * n;
c0101d7d:	85 d2                	test   %edx,%edx
c0101d7f:	74 07                	je     c0101d88 <_ZN5Utils7roundUpEjj+0x18>
c0101d81:	8d 48 01             	lea    0x1(%eax),%ecx
c0101d84:	0f af 4d 0c          	imul   0xc(%ebp),%ecx
    return a;
}
c0101d88:	89 c8                	mov    %ecx,%eax
c0101d8a:	5d                   	pop    %ebp
c0101d8b:	c3                   	ret    

c0101d8c <_ZN5Utils9roundDownEjj>:

uint32_t Utils::roundDown(uint32_t a, uint32_t n) {
c0101d8c:	55                   	push   %ebp
    return (a / n) * n;
c0101d8d:	31 d2                	xor    %edx,%edx
uint32_t Utils::roundDown(uint32_t a, uint32_t n) {
c0101d8f:	89 e5                	mov    %esp,%ebp
c0101d91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0101d94:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0101d97:	5d                   	pop    %ebp
    return (a / n) * n;
c0101d98:	f7 f1                	div    %ecx
c0101d9a:	0f af c1             	imul   %ecx,%eax
}
c0101d9d:	c3                   	ret    

c0101d9e <_ZN5Utils6memsetEjhj>:

void Utils::memset(uptr32_t ad, uint8_t byte, uint32_t size) {
c0101d9e:	55                   	push   %ebp
    uint8_t *p = (uint8_t *)ad;
    for (uint32_t i = 0; i < size; i++) {
c0101d9f:	31 c0                	xor    %eax,%eax
void Utils::memset(uptr32_t ad, uint8_t byte, uint32_t size) {
c0101da1:	89 e5                	mov    %esp,%ebp
c0101da3:	8b 55 08             	mov    0x8(%ebp),%edx
c0101da6:	8a 4d 0c             	mov    0xc(%ebp),%cl
    for (uint32_t i = 0; i < size; i++) {
c0101da9:	3b 45 10             	cmp    0x10(%ebp),%eax
c0101dac:	74 06                	je     c0101db4 <_ZN5Utils6memsetEjhj+0x16>
        p[i] = byte;
c0101dae:	88 0c 10             	mov    %cl,(%eax,%edx,1)
    for (uint32_t i = 0; i < size; i++) {
c0101db1:	40                   	inc    %eax
c0101db2:	eb f5                	jmp    c0101da9 <_ZN5Utils6memsetEjhj+0xb>
    }
}
c0101db4:	5d                   	pop    %ebp
c0101db5:	c3                   	ret    

c0101db6 <_ZN5PhyMMC1Ev>:
#include <kdebug.h>
#include <sync.h>
#include <ostream.h>
#include <utils.hpp>

PhyMM::PhyMM() {
c0101db6:	55                   	push   %ebp
c0101db7:	89 e5                	mov    %esp,%ebp
c0101db9:	56                   	push   %esi
c0101dba:	8b 75 08             	mov    0x8(%ebp),%esi
c0101dbd:	53                   	push   %ebx
c0101dbe:	e8 f2 ed ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0101dc3:	81 c3 4d a6 01 00    	add    $0x1a64d,%ebx
c0101dc9:	83 ec 0c             	sub    $0xc,%esp
c0101dcc:	56                   	push   %esi
c0101dcd:	e8 cc 24 00 00       	call   c010429e <_ZN3MMUC1Ev>
c0101dd2:	8d 83 14 00 00 00    	lea    0x14(%ebx),%eax
c0101dd8:	89 46 20             	mov    %eax,0x20(%esi)
c0101ddb:	58                   	pop    %eax
c0101ddc:	8d 83 ec 83 fe ff    	lea    -0x17c14(%ebx),%eax
c0101de2:	5a                   	pop    %edx
c0101de3:	50                   	push   %eax
c0101de4:	8d 46 24             	lea    0x24(%esi),%eax
c0101de7:	50                   	push   %eax
c0101de8:	e8 63 28 00 00       	call   c0104650 <_ZN6StringC1EPKc>
#include <PmmManager.h>
#include <list.hpp>

// First-Fit Memory Allocation (FFMA) Algorithm

class FFMA : public PmmManager{
c0101ded:	c7 c0 48 c4 11 c0    	mov    $0xc011c448,%eax

    extern uint8_t bootstack[], bootstacktop[];
    stack = bootstack;
    stackTop = bootstacktop;

}
c0101df3:	83 c4 10             	add    $0x10,%esp
        struct LHeadNode {
            DLNode *first, *last;
            uint32_t eNum;
        }__attribute__((packed));

        class NodeIterator {
c0101df6:	c7 46 29 00 00 00 00 	movl   $0x0,0x29(%esi)
        LHeadNode headNode;
};

template <typename Object>
List<Object>::List() {
    headNode.first = nullptr;
c0101dfd:	c7 46 2d 00 00 00 00 	movl   $0x0,0x2d(%esi)
    headNode.last = nullptr;
c0101e04:	c7 46 31 00 00 00 00 	movl   $0x0,0x31(%esi)
c0101e0b:	83 c0 08             	add    $0x8,%eax
c0101e0e:	89 46 20             	mov    %eax,0x20(%esi)
    bootPDT = &__boot_pgdir;
c0101e11:	c7 c0 00 d0 11 c0    	mov    $0xc011d000,%eax
    headNode.eNum = 0;
c0101e17:	c7 46 35 00 00 00 00 	movl   $0x0,0x35(%esi)
c0101e1e:	c7 46 39 00 00 00 00 	movl   $0x0,0x39(%esi)
c0101e25:	89 46 18             	mov    %eax,0x18(%esi)
    stack = bootstack;
c0101e28:	c7 c0 00 a0 11 c0    	mov    $0xc011a000,%eax
c0101e2e:	89 46 10             	mov    %eax,0x10(%esi)
    stackTop = bootstacktop;
c0101e31:	c7 c0 00 c0 11 c0    	mov    $0xc011c000,%eax
c0101e37:	89 46 14             	mov    %eax,0x14(%esi)
}
c0101e3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101e3d:	5b                   	pop    %ebx
c0101e3e:	5e                   	pop    %esi
c0101e3f:	5d                   	pop    %ebp
c0101e40:	c3                   	ret    
c0101e41:	90                   	nop

c0101e42 <_ZN5PhyMM8initPageEv>:
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    initGDTAndTSS();

}

void PhyMM::initPage() {
c0101e42:	55                   	push   %ebp
c0101e43:	89 e5                	mov    %esp,%ebp
c0101e45:	57                   	push   %edi
c0101e46:	56                   	push   %esi
c0101e47:	53                   	push   %ebx
c0101e48:	e8 68 ed ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0101e4d:	81 c3 c3 a5 01 00    	add    $0x1a5c3,%ebx
c0101e53:	81 ec 84 02 00 00    	sub    $0x284,%esp
    E820Map *memMap = (E820Map *)(E820_BUFF + KERNEL_BASE);                      
    uint64_t maxpa = 0;                                                             // size of all mem-block

    OStream out("\nMemmory Map [E820Map] begin...\n", "blue");
c0101e59:	8d b5 bc fd ff ff    	lea    -0x244(%ebp),%esi
c0101e5f:	8d bd b7 fd ff ff    	lea    -0x249(%ebp),%edi
c0101e65:	8d 83 fa 82 fe ff    	lea    -0x17d06(%ebx),%eax
c0101e6b:	50                   	push   %eax
c0101e6c:	56                   	push   %esi
c0101e6d:	e8 de 27 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101e72:	58                   	pop    %eax
c0101e73:	8d 83 fb 83 fe ff    	lea    -0x17c05(%ebx),%eax
c0101e79:	5a                   	pop    %edx
c0101e7a:	50                   	push   %eax
c0101e7b:	57                   	push   %edi
c0101e7c:	e8 cf 27 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101e81:	83 c4 0c             	add    $0xc,%esp
c0101e84:	56                   	push   %esi
c0101e85:	57                   	push   %edi
c0101e86:	8d 85 c2 fd ff ff    	lea    -0x23e(%ebp),%eax
c0101e8c:	50                   	push   %eax
c0101e8d:	e8 d4 fb ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0101e92:	89 3c 24             	mov    %edi,(%esp)
c0101e95:	e8 d0 27 00 00       	call   c010466a <_ZN6StringD1Ev>
c0101e9a:	89 34 24             	mov    %esi,(%esp)
c0101e9d:	e8 c8 27 00 00       	call   c010466a <_ZN6StringD1Ev>
c0101ea2:	83 c4 10             	add    $0x10,%esp
    uint64_t maxpa = 0;                                                             // size of all mem-block
c0101ea5:	31 c9                	xor    %ecx,%ecx
    for (uint32_t i = 0; i < memMap->numARDS; i++) {                               // scan all of free memory block
c0101ea7:	c7 85 90 fd ff ff 00 	movl   $0x0,-0x270(%ebp)
c0101eae:	00 00 00 
    uint64_t maxpa = 0;                                                             // size of all mem-block
c0101eb1:	c7 85 94 fd ff ff 00 	movl   $0x0,-0x26c(%ebp)
c0101eb8:	00 00 00 
    for (uint32_t i = 0; i < memMap->numARDS; i++) {                               // scan all of free memory block
c0101ebb:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
c0101ec1:	39 05 00 80 00 c0    	cmp    %eax,0xc0008000
c0101ec7:	0f 86 e0 01 00 00    	jbe    c01020ad <_ZN5PhyMM8initPageEv+0x26b>
c0101ecd:	6b c0 14             	imul   $0x14,%eax,%eax
c0101ed0:	89 8d 84 fd ff ff    	mov    %ecx,-0x27c(%ebp)
        // get AD of begin and end of current Mem-Block 
        uint64_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c0101ed6:	8b b0 04 80 00 c0    	mov    -0x3fff7ffc(%eax),%esi
c0101edc:	8d 90 00 80 00 c0    	lea    -0x3fff8000(%eax),%edx
c0101ee2:	8b b8 08 80 00 c0    	mov    -0x3fff7ff8(%eax),%edi
c0101ee8:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
c0101eee:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
c0101ef4:	89 b5 a0 fd ff ff    	mov    %esi,-0x260(%ebp)
c0101efa:	03 b0 0c 80 00 c0    	add    -0x3fff7ff4(%eax),%esi
c0101f00:	89 bd a4 fd ff ff    	mov    %edi,-0x25c(%ebp)
c0101f06:	13 b8 10 80 00 c0    	adc    -0x3fff7ff0(%eax),%edi
        
        out.write(" >> size = ");
c0101f0c:	51                   	push   %ecx
c0101f0d:	51                   	push   %ecx
        uint64_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c0101f0e:	89 b5 98 fd ff ff    	mov    %esi,-0x268(%ebp)
        out.write(" >> size = ");
c0101f14:	8d b3 1c 84 fe ff    	lea    -0x17be4(%ebx),%esi
c0101f1a:	56                   	push   %esi
c0101f1b:	8d b5 bc fd ff ff    	lea    -0x244(%ebp),%esi
c0101f21:	56                   	push   %esi
        uint64_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c0101f22:	89 bd 9c fd ff ff    	mov    %edi,-0x264(%ebp)
        out.write(" >> size = ");
c0101f28:	e8 23 27 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101f2d:	5f                   	pop    %edi
c0101f2e:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c0101f34:	58                   	pop    %eax
c0101f35:	56                   	push   %esi
c0101f36:	57                   	push   %edi
c0101f37:	e8 b4 fc ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0101f3c:	89 34 24             	mov    %esi,(%esp)
c0101f3f:	e8 26 27 00 00       	call   c010466a <_ZN6StringD1Ev>
        out.writeValue(memMap->ARDS[i].size);
c0101f44:	8b 95 8c fd ff ff    	mov    -0x274(%ebp),%edx
c0101f4a:	58                   	pop    %eax
c0101f4b:	8b 52 0c             	mov    0xc(%edx),%edx
c0101f4e:	89 95 bc fd ff ff    	mov    %edx,-0x244(%ebp)
c0101f54:	5a                   	pop    %edx
c0101f55:	56                   	push   %esi
c0101f56:	57                   	push   %edi
c0101f57:	e8 d8 fc ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
        out.write(" range: ");
c0101f5c:	8d 93 28 84 fe ff    	lea    -0x17bd8(%ebx),%edx
c0101f62:	59                   	pop    %ecx
c0101f63:	58                   	pop    %eax
c0101f64:	52                   	push   %edx
c0101f65:	56                   	push   %esi
c0101f66:	e8 e5 26 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101f6b:	58                   	pop    %eax
c0101f6c:	5a                   	pop    %edx
c0101f6d:	56                   	push   %esi
c0101f6e:	57                   	push   %edi
c0101f6f:	e8 7c fc ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0101f74:	89 34 24             	mov    %esi,(%esp)
c0101f77:	e8 ee 26 00 00       	call   c010466a <_ZN6StringD1Ev>
        out.writeValue(begin);
c0101f7c:	8b 85 a0 fd ff ff    	mov    -0x260(%ebp),%eax
c0101f82:	59                   	pop    %ecx
c0101f83:	89 85 bc fd ff ff    	mov    %eax,-0x244(%ebp)
c0101f89:	58                   	pop    %eax
c0101f8a:	56                   	push   %esi
c0101f8b:	57                   	push   %edi
c0101f8c:	e8 a3 fc ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
        out.write(" ~ ");
c0101f91:	58                   	pop    %eax
c0101f92:	5a                   	pop    %edx
c0101f93:	8d 93 31 84 fe ff    	lea    -0x17bcf(%ebx),%edx
c0101f99:	52                   	push   %edx
c0101f9a:	56                   	push   %esi
c0101f9b:	e8 b0 26 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101fa0:	59                   	pop    %ecx
c0101fa1:	58                   	pop    %eax
c0101fa2:	56                   	push   %esi
c0101fa3:	57                   	push   %edi
c0101fa4:	e8 47 fc ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0101fa9:	89 34 24             	mov    %esi,(%esp)
c0101fac:	e8 b9 26 00 00       	call   c010466a <_ZN6StringD1Ev>
        out.writeValue(end - 1);
c0101fb1:	8b 85 98 fd ff ff    	mov    -0x268(%ebp),%eax
c0101fb7:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101fba:	58                   	pop    %eax
c0101fbb:	89 95 bc fd ff ff    	mov    %edx,-0x244(%ebp)
c0101fc1:	5a                   	pop    %edx
c0101fc2:	56                   	push   %esi
c0101fc3:	57                   	push   %edi
c0101fc4:	e8 6b fc ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
        out.write(" type = ");
c0101fc9:	8d 93 35 84 fe ff    	lea    -0x17bcb(%ebx),%edx
c0101fcf:	59                   	pop    %ecx
c0101fd0:	58                   	pop    %eax
c0101fd1:	52                   	push   %edx
c0101fd2:	56                   	push   %esi
c0101fd3:	e8 78 26 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0101fd8:	58                   	pop    %eax
c0101fd9:	5a                   	pop    %edx
c0101fda:	56                   	push   %esi
c0101fdb:	57                   	push   %edi
c0101fdc:	e8 0f fc ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0101fe1:	89 34 24             	mov    %esi,(%esp)
c0101fe4:	e8 81 26 00 00       	call   c010466a <_ZN6StringD1Ev>
        out.writeValue(memMap->ARDS[i].type);
c0101fe9:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
c0101fef:	59                   	pop    %ecx
c0101ff0:	8b 90 14 80 00 c0    	mov    -0x3fff7fec(%eax),%edx
c0101ff6:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
c0101ffc:	58                   	pop    %eax
c0101ffd:	89 95 bc fd ff ff    	mov    %edx,-0x244(%ebp)
c0102003:	56                   	push   %esi
c0102004:	57                   	push   %edi
c0102005:	e8 2a fc ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
        
        if (memMap->ARDS[i].type == E820_ARM) {                                    // is ARM Area
c010200a:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
c0102010:	83 c4 10             	add    $0x10,%esp
c0102013:	8b 8d 84 fd ff ff    	mov    -0x27c(%ebp),%ecx
c0102019:	83 b8 14 80 00 c0 01 	cmpl   $0x1,-0x3fff7fec(%eax)
c0102020:	75 45                	jne    c0102067 <_ZN5PhyMM8initPageEv+0x225>
            if (maxpa < end && begin < KERNEL_MEM_SIZE) {
c0102022:	8b bd 9c fd ff ff    	mov    -0x264(%ebp),%edi
c0102028:	39 bd 94 fd ff ff    	cmp    %edi,-0x26c(%ebp)
c010202e:	72 0a                	jb     c010203a <_ZN5PhyMM8initPageEv+0x1f8>
c0102030:	77 35                	ja     c0102067 <_ZN5PhyMM8initPageEv+0x225>
c0102032:	3b 8d 98 fd ff ff    	cmp    -0x268(%ebp),%ecx
c0102038:	73 2d                	jae    c0102067 <_ZN5PhyMM8initPageEv+0x225>
c010203a:	83 bd a4 fd ff ff 00 	cmpl   $0x0,-0x25c(%ebp)
c0102041:	77 24                	ja     c0102067 <_ZN5PhyMM8initPageEv+0x225>
c0102043:	81 bd a0 fd ff ff ff 	cmpl   $0x37ffffff,-0x260(%ebp)
c010204a:	ff ff 37 
c010204d:	8b 85 9c fd ff ff    	mov    -0x264(%ebp),%eax
c0102053:	0f 47 85 94 fd ff ff 	cmova  -0x26c(%ebp),%eax
c010205a:	0f 46 8d 98 fd ff ff 	cmovbe -0x268(%ebp),%ecx
c0102061:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
                maxpa = end;
            }
        }
        
        out.write("\n");
c0102067:	50                   	push   %eax
c0102068:	50                   	push   %eax
c0102069:	8d 83 13 83 fe ff    	lea    -0x17ced(%ebx),%eax
c010206f:	50                   	push   %eax
c0102070:	8d b5 bc fd ff ff    	lea    -0x244(%ebp),%esi
c0102076:	56                   	push   %esi
c0102077:	89 8d a0 fd ff ff    	mov    %ecx,-0x260(%ebp)
c010207d:	e8 ce 25 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102082:	58                   	pop    %eax
c0102083:	8d 85 c2 fd ff ff    	lea    -0x23e(%ebp),%eax
c0102089:	5a                   	pop    %edx
c010208a:	56                   	push   %esi
c010208b:	50                   	push   %eax
c010208c:	e8 5f fb ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0102091:	89 34 24             	mov    %esi,(%esp)
c0102094:	e8 d1 25 00 00       	call   c010466a <_ZN6StringD1Ev>
    for (uint32_t i = 0; i < memMap->numARDS; i++) {                               // scan all of free memory block
c0102099:	83 c4 10             	add    $0x10,%esp
c010209c:	8b 8d a0 fd ff ff    	mov    -0x260(%ebp),%ecx
c01020a2:	ff 85 90 fd ff ff    	incl   -0x270(%ebp)
c01020a8:	e9 0e fe ff ff       	jmp    c0101ebb <_ZN5PhyMM8initPageEv+0x79>
        maxpa = KERNEL_MEM_SIZE;
    }


    extern uint8_t end[];
    numPage = maxpa / PGSIZE;          // get number of page
c01020ad:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
c01020b3:	89 ce                	mov    %ecx,%esi
c01020b5:	83 ff 00             	cmp    $0x0,%edi
c01020b8:	77 08                	ja     c01020c2 <_ZN5PhyMM8initPageEv+0x280>
c01020ba:	81 f9 00 00 00 38    	cmp    $0x38000000,%ecx
c01020c0:	76 07                	jbe    c01020c9 <_ZN5PhyMM8initPageEv+0x287>
c01020c2:	be 00 00 00 38       	mov    $0x38000000,%esi
c01020c7:	31 ff                	xor    %edi,%edi
c01020c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
c01020cc:	89 f0                	mov    %esi,%eax
c01020ce:	0f ac f8 0c          	shrd   $0xc,%edi,%eax
c01020d2:	89 41 1c             	mov    %eax,0x1c(%ecx)
    
    out.write("\n numPage = ");
c01020d5:	8d 83 3e 84 fe ff    	lea    -0x17bc2(%ebx),%eax
c01020db:	56                   	push   %esi
c01020dc:	56                   	push   %esi
c01020dd:	50                   	push   %eax
c01020de:	8d b5 bc fd ff ff    	lea    -0x244(%ebp),%esi
c01020e4:	56                   	push   %esi
c01020e5:	e8 66 25 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01020ea:	5f                   	pop    %edi
c01020eb:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c01020f1:	58                   	pop    %eax
c01020f2:	56                   	push   %esi
c01020f3:	57                   	push   %edi
c01020f4:	e8 f7 fa ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c01020f9:	89 34 24             	mov    %esi,(%esp)
c01020fc:	e8 69 25 00 00       	call   c010466a <_ZN6StringD1Ev>
    out.writeValue(numPage);
c0102101:	8b 45 08             	mov    0x8(%ebp),%eax
c0102104:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102107:	89 85 bc fd ff ff    	mov    %eax,-0x244(%ebp)
c010210d:	58                   	pop    %eax
c010210e:	5a                   	pop    %edx
c010210f:	56                   	push   %esi
c0102110:	57                   	push   %edi
c0102111:	e8 1e fb ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
    
    pNodeArr = (List<Page>::DLNode *)Utils::roundUp((uint32_t)end, PGSIZE);
c0102116:	59                   	pop    %ecx
c0102117:	58                   	pop    %eax
c0102118:	68 00 10 00 00       	push   $0x1000
c010211d:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
c0102123:	e8 48 fc ff ff       	call   c0101d70 <_ZN5Utils7roundUpEjj>
c0102128:	5a                   	pop    %edx
c0102129:	59                   	pop    %ecx
c010212a:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010212d:	89 41 41             	mov    %eax,0x41(%ecx)

    out.write("\n pNodeArr = ");
c0102130:	8d 83 4b 84 fe ff    	lea    -0x17bb5(%ebx),%eax
c0102136:	50                   	push   %eax
c0102137:	56                   	push   %esi
c0102138:	e8 13 25 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010213d:	58                   	pop    %eax
c010213e:	5a                   	pop    %edx
c010213f:	56                   	push   %esi
c0102140:	57                   	push   %edi
c0102141:	e8 aa fa ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0102146:	89 34 24             	mov    %esi,(%esp)
c0102149:	e8 1c 25 00 00       	call   c010466a <_ZN6StringD1Ev>
    out.writeValue((uint32_t)pNodeArr);
c010214e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102151:	59                   	pop    %ecx
c0102152:	8b 40 41             	mov    0x41(%eax),%eax
c0102155:	89 85 bc fd ff ff    	mov    %eax,-0x244(%ebp)
c010215b:	58                   	pop    %eax
c010215c:	56                   	push   %esi
c010215d:	57                   	push   %edi

    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c010215e:	31 ff                	xor    %edi,%edi
    out.writeValue((uint32_t)pNodeArr);
c0102160:	e8 cf fa ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
c0102165:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c0102168:	8b 45 08             	mov    0x8(%ebp),%eax
c010216b:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010216e:	8b 40 1c             	mov    0x1c(%eax),%eax
c0102171:	8b 51 41             	mov    0x41(%ecx),%edx
c0102174:	39 f8                	cmp    %edi,%eax
c0102176:	76 14                	jbe    c010218c <_ZN5PhyMM8initPageEv+0x34a>
        setPageReserved(pNodeArr[i].data);
c0102178:	6b c7 11             	imul   $0x11,%edi,%eax
c010217b:	83 ec 0c             	sub    $0xc,%esp
    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c010217e:	47                   	inc    %edi
        setPageReserved(pNodeArr[i].data);
c010217f:	01 c2                	add    %eax,%edx
c0102181:	52                   	push   %edx
c0102182:	e8 f7 22 00 00       	call   c010447e <_ZN3MMU15setPageReservedERNS_4PageE>
    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c0102187:	83 c4 10             	add    $0x10,%esp
c010218a:	eb dc                	jmp    c0102168 <_ZN5PhyMM8initPageEv+0x326>
    }

    // get top-address of pNodeArr[] element in the end, it is free area when great than the AD
    uptr32_t freeMem = vToPhyAD((uptr32_t)(pNodeArr + numPage));
c010218c:	6b c0 11             	imul   $0x11,%eax,%eax
        pad += PGSIZE;
    }
}

uptr32_t PhyMM::vToPhyAD(uptr32_t kvAd) {
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c010218f:	8d bc 02 00 00 00 40 	lea    0x40000000(%edx,%eax,1),%edi
c0102196:	81 ff 00 00 00 38    	cmp    $0x38000000,%edi
c010219c:	76 02                	jbe    c01021a0 <_ZN5PhyMM8initPageEv+0x35e>
        return kvAd - KERNEL_BASE;
    }
    return 0;
c010219e:	31 ff                	xor    %edi,%edi
    out.write("\n freeMem = ");
c01021a0:	51                   	push   %ecx
c01021a1:	51                   	push   %ecx
c01021a2:	8d 83 59 84 fe ff    	lea    -0x17ba7(%ebx),%eax
c01021a8:	50                   	push   %eax
c01021a9:	56                   	push   %esi
c01021aa:	e8 a1 24 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01021af:	58                   	pop    %eax
c01021b0:	8d 85 c2 fd ff ff    	lea    -0x23e(%ebp),%eax
c01021b6:	5a                   	pop    %edx
c01021b7:	89 85 a0 fd ff ff    	mov    %eax,-0x260(%ebp)
c01021bd:	56                   	push   %esi
c01021be:	50                   	push   %eax
c01021bf:	e8 2c fa ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c01021c4:	89 34 24             	mov    %esi,(%esp)
c01021c7:	e8 9e 24 00 00       	call   c010466a <_ZN6StringD1Ev>
    out.writeValue((uint32_t)freeMem);
c01021cc:	59                   	pop    %ecx
c01021cd:	89 bd bc fd ff ff    	mov    %edi,-0x244(%ebp)
c01021d3:	58                   	pop    %eax
c01021d4:	8b 85 a0 fd ff ff    	mov    -0x260(%ebp),%eax
c01021da:	56                   	push   %esi
    for (uint32_t i = 0; i < memMap->numARDS; i++) {
c01021db:	31 f6                	xor    %esi,%esi
    out.writeValue((uint32_t)freeMem);
c01021dd:	50                   	push   %eax
c01021de:	e8 51 fa ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
    out.flush();
c01021e3:	8b 85 a0 fd ff ff    	mov    -0x260(%ebp),%eax
c01021e9:	89 04 24             	mov    %eax,(%esp)
c01021ec:	e8 13 f9 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
c01021f1:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 0; i < memMap->numARDS; i++) {
c01021f4:	39 35 00 80 00 c0    	cmp    %esi,0xc0008000
c01021fa:	0f 86 90 00 00 00    	jbe    c0102290 <_ZN5PhyMM8initPageEv+0x44e>
        if (memMap->ARDS[i].type == E820_ARM) {                                    // is ARM Area
c0102200:	6b c6 14             	imul   $0x14,%esi,%eax
c0102203:	83 b8 14 80 00 c0 01 	cmpl   $0x1,-0x3fff7fec(%eax)
c010220a:	8d 88 00 80 00 c0    	lea    -0x3fff8000(%eax),%ecx
c0102210:	75 78                	jne    c010228a <_ZN5PhyMM8initPageEv+0x448>
        uptr32_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c0102212:	8b 90 04 80 00 c0    	mov    -0x3fff7ffc(%eax),%edx
c0102218:	89 f8                	mov    %edi,%eax
c010221a:	39 fa                	cmp    %edi,%edx
c010221c:	0f 43 c2             	cmovae %edx,%eax
c010221f:	03 51 0c             	add    0xc(%ecx),%edx
c0102222:	b9 00 00 00 38       	mov    $0x38000000,%ecx
c0102227:	81 fa 00 00 00 38    	cmp    $0x38000000,%edx
c010222d:	0f 47 d1             	cmova  %ecx,%edx
            if (begin < end) {
c0102230:	39 c2                	cmp    %eax,%edx
c0102232:	89 95 a0 fd ff ff    	mov    %edx,-0x260(%ebp)
c0102238:	76 50                	jbe    c010228a <_ZN5PhyMM8initPageEv+0x448>
                begin = Utils::roundUp(begin, PGSIZE);
c010223a:	52                   	push   %edx
c010223b:	52                   	push   %edx
c010223c:	68 00 10 00 00       	push   $0x1000
c0102241:	50                   	push   %eax
c0102242:	e8 29 fb ff ff       	call   c0101d70 <_ZN5Utils7roundUpEjj>
    return (a / n) * n;
c0102247:	8b 95 a0 fd ff ff    	mov    -0x260(%ebp),%edx
c010224d:	83 c4 10             	add    $0x10,%esp
c0102250:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
                if (begin < end) {
c0102256:	39 c2                	cmp    %eax,%edx
c0102258:	76 30                	jbe    c010228a <_ZN5PhyMM8initPageEv+0x448>
                    manager->initMemMap(phyADtoPage(begin), (end - begin) / PGSIZE);
c010225a:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010225d:	29 c2                	sub    %eax,%edx
c010225f:	83 ec 04             	sub    $0x4,%esp
c0102262:	c1 ea 0c             	shr    $0xc,%edx
    }
    return 0;
}

List<MMU::Page>::DLNode * PhyMM::phyADtoPage(uptr32_t pAd) {
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
c0102265:	c1 e8 0c             	shr    $0xc,%eax
    return &(pNodeArr[pIndex]);
c0102268:	6b c0 11             	imul   $0x11,%eax,%eax
                    manager->initMemMap(phyADtoPage(begin), (end - begin) / PGSIZE);
c010226b:	8b 49 3d             	mov    0x3d(%ecx),%ecx
c010226e:	89 8d a0 fd ff ff    	mov    %ecx,-0x260(%ebp)
c0102274:	8b 09                	mov    (%ecx),%ecx
c0102276:	52                   	push   %edx
    return &(pNodeArr[pIndex]);
c0102277:	8b 55 08             	mov    0x8(%ebp),%edx
c010227a:	03 42 41             	add    0x41(%edx),%eax
                    manager->initMemMap(phyADtoPage(begin), (end - begin) / PGSIZE);
c010227d:	50                   	push   %eax
c010227e:	ff b5 a0 fd ff ff    	pushl  -0x260(%ebp)
c0102284:	ff 51 04             	call   *0x4(%ecx)
c0102287:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 0; i < memMap->numARDS; i++) {
c010228a:	46                   	inc    %esi
c010228b:	e9 64 ff ff ff       	jmp    c01021f4 <_ZN5PhyMM8initPageEv+0x3b2>
    OStream out("\nMemmory Map [E820Map] begin...\n", "blue");
c0102290:	83 ec 0c             	sub    $0xc,%esp
c0102293:	8d 85 c2 fd ff ff    	lea    -0x23e(%ebp),%eax
c0102299:	50                   	push   %eax
c010229a:	e8 a7 f8 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
}
c010229f:	83 c4 10             	add    $0x10,%esp
c01022a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01022a5:	5b                   	pop    %ebx
c01022a6:	5e                   	pop    %esi
c01022a7:	5f                   	pop    %edi
c01022a8:	5d                   	pop    %ebp
c01022a9:	c3                   	ret    

c01022aa <_ZN5PhyMM13initGDTAndTSSEv>:
void PhyMM::initGDTAndTSS() {
c01022aa:	55                   	push   %ebp
c01022ab:	89 e5                	mov    %esp,%ebp
c01022ad:	57                   	push   %edi
c01022ae:	56                   	push   %esi
c01022af:	53                   	push   %ebx
c01022b0:	e8 00 e9 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c01022b5:	81 c3 5b a1 01 00    	add    $0x1a15b,%ebx
c01022bb:	83 ec 28             	sub    $0x28,%esp
    tss.ts_esp0 = (uptr32_t)stackTop;
c01022be:	8b 45 08             	mov    0x8(%ebp),%eax
    GDT[SEG_KTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_KERNEL);
c01022c1:	8d 7d e0             	lea    -0x20(%ebp),%edi
    tss.ts_esp0 = (uptr32_t)stackTop;
c01022c4:	8b 40 14             	mov    0x14(%eax),%eax
c01022c7:	c7 c1 c0 f9 11 c0    	mov    $0xc011f9c0,%ecx
    GDT[0] = SEG_NULL;
c01022cd:	c7 c6 80 f1 11 c0    	mov    $0xc011f180,%esi
    tss.ts_esp0 = (uptr32_t)stackTop;
c01022d3:	89 41 04             	mov    %eax,0x4(%ecx)
    tss.ts_ss0 = KERNEL_DS;
c01022d6:	66 c7 41 08 10 00    	movw   $0x10,0x8(%ecx)
    GDT[SEG_KTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_KERNEL);
c01022dc:	6a 00                	push   $0x0
c01022de:	6a ff                	push   $0xffffffff
c01022e0:	6a 00                	push   $0x0
c01022e2:	6a 0a                	push   $0xa
c01022e4:	57                   	push   %edi
    tss.ts_ss0 = KERNEL_DS;
c01022e5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    GDT[0] = SEG_NULL;
c01022e8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
c01022ee:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
    GDT[SEG_KTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_KERNEL);
c01022f5:	e8 aa 1f 00 00       	call   c01042a4 <_ZN3MMU10setSegDescEjjjj>
c01022fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01022fd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102300:	89 46 08             	mov    %eax,0x8(%esi)
c0102303:	89 56 0c             	mov    %edx,0xc(%esi)
    GDT[SEG_KDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_KERNEL);
c0102306:	6a 00                	push   $0x0
c0102308:	6a ff                	push   $0xffffffff
c010230a:	6a 00                	push   $0x0
c010230c:	6a 02                	push   $0x2
c010230e:	57                   	push   %edi
c010230f:	e8 90 1f 00 00       	call   c01042a4 <_ZN3MMU10setSegDescEjjjj>
c0102314:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102317:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010231a:	89 46 10             	mov    %eax,0x10(%esi)
c010231d:	89 56 14             	mov    %edx,0x14(%esi)
    GDT[SEG_UTEXT] = MMU::setSegDesc(STA_E_R, 0x0, 0xFFFFFFFF, DPL_USER);
c0102320:	83 c4 20             	add    $0x20,%esp
c0102323:	6a 03                	push   $0x3
c0102325:	6a ff                	push   $0xffffffff
c0102327:	6a 00                	push   $0x0
c0102329:	6a 0a                	push   $0xa
c010232b:	57                   	push   %edi
c010232c:	e8 73 1f 00 00       	call   c01042a4 <_ZN3MMU10setSegDescEjjjj>
c0102331:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102334:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102337:	89 46 18             	mov    %eax,0x18(%esi)
c010233a:	89 56 1c             	mov    %edx,0x1c(%esi)
    GDT[SEG_UDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_USER);
c010233d:	6a 03                	push   $0x3
c010233f:	6a ff                	push   $0xffffffff
c0102341:	6a 00                	push   $0x0
c0102343:	6a 02                	push   $0x2
c0102345:	57                   	push   %edi
c0102346:	e8 59 1f 00 00       	call   c01042a4 <_ZN3MMU10setSegDescEjjjj>
    GDT[SEG_TSS] = setTssDesc(STS_T32A, (uptr32_t)(&tss), sizeof(tss), DPL_KERNEL);
c010234b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
    GDT[SEG_UDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_USER);
c010234e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102351:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102354:	89 46 20             	mov    %eax,0x20(%esi)
    GDT[SEG_TSS] = setTssDesc(STS_T32A, (uptr32_t)(&tss), sizeof(tss), DPL_KERNEL);
c0102357:	83 c4 20             	add    $0x20,%esp
c010235a:	6a 00                	push   $0x0
c010235c:	6a 68                	push   $0x68
c010235e:	51                   	push   %ecx
c010235f:	6a 09                	push   $0x9
c0102361:	57                   	push   %edi
    GDT[SEG_UDATA] = MMU::setSegDesc(STA_RW, 0x0, 0xFFFFFFFF, DPL_USER);
c0102362:	89 56 24             	mov    %edx,0x24(%esi)
    GDT[SEG_TSS] = setTssDesc(STS_T32A, (uptr32_t)(&tss), sizeof(tss), DPL_KERNEL);
c0102365:	e8 32 20 00 00       	call   c010439c <_ZN3MMU10setTssDescEjjjj>
c010236a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010236d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102370:	89 46 28             	mov    %eax,0x28(%esi)
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102373:	c7 c0 38 c4 11 c0    	mov    $0xc011c438,%eax
c0102379:	89 56 2c             	mov    %edx,0x2c(%esi)
c010237c:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%ds" :: "a" (ds));
c010237f:	b8 10 00 00 00       	mov    $0x10,%eax
c0102384:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (ss));
c0102386:	8e d0                	mov    %eax,%ss
    asm volatile ("movw %%ax, %%es" :: "a" (es));
c0102388:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%fs" :: "a" (fs));
c010238a:	b8 23 00 00 00       	mov    $0x23,%eax
c010238f:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%gs" :: "a" (gs));
c0102391:	8e e8                	mov    %eax,%gs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (cs));
c0102393:	ea 9a 23 10 c0 08 00 	ljmp   $0x8,$0xc010239a
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c010239a:	b8 28 00 00 00       	mov    $0x28,%eax
c010239f:	0f 00 d8             	ltr    %ax
}
c01023a2:	83 c4 1c             	add    $0x1c,%esp
c01023a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01023a8:	5b                   	pop    %ebx
c01023a9:	5e                   	pop    %esi
c01023aa:	5f                   	pop    %edi
c01023ab:	5d                   	pop    %ebp
c01023ac:	c3                   	ret    
c01023ad:	90                   	nop

c01023ae <_ZN5PhyMM14initPmmManagerEv>:
void PhyMM::initPmmManager() {
c01023ae:	55                   	push   %ebp
c01023af:	89 e5                	mov    %esp,%ebp
c01023b1:	8b 45 08             	mov    0x8(%ebp),%eax
    manager = &ff;
c01023b4:	8d 50 20             	lea    0x20(%eax),%edx
c01023b7:	89 50 3d             	mov    %edx,0x3d(%eax)
}
c01023ba:	5d                   	pop    %ebp
c01023bb:	c3                   	ret    

c01023bc <_ZN5PhyMM8vToPhyADEj>:
uptr32_t PhyMM::vToPhyAD(uptr32_t kvAd) {
c01023bc:	55                   	push   %ebp
c01023bd:	89 e5                	mov    %esp,%ebp
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c01023bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01023c2:	05 00 00 00 40       	add    $0x40000000,%eax
c01023c7:	3d 00 00 00 38       	cmp    $0x38000000,%eax
c01023cc:	76 02                	jbe    c01023d0 <_ZN5PhyMM8vToPhyADEj+0x14>
    return 0;
c01023ce:	31 c0                	xor    %eax,%eax
}
c01023d0:	5d                   	pop    %ebp
c01023d1:	c3                   	ret    

c01023d2 <_ZN5PhyMM8pToVirADEj>:
uptr32_t PhyMM::pToVirAD(uptr32_t pAd) {
c01023d2:	55                   	push   %ebp
c01023d3:	89 e5                	mov    %esp,%ebp
c01023d5:	8b 55 0c             	mov    0xc(%ebp),%edx
    if (pAd <= KERNEL_MEM_SIZE) {
c01023d8:	81 fa 00 00 00 38    	cmp    $0x38000000,%edx
        return pAd + KERNEL_BASE;
c01023de:	8d 82 00 00 00 c0    	lea    -0x40000000(%edx),%eax
    if (pAd <= KERNEL_MEM_SIZE) {
c01023e4:	76 02                	jbe    c01023e8 <_ZN5PhyMM8pToVirADEj+0x16>
c01023e6:	31 c0                	xor    %eax,%eax
}
c01023e8:	5d                   	pop    %ebp
c01023e9:	c3                   	ret    

c01023ea <_ZN5PhyMM11phyADtoPageEj>:
List<MMU::Page>::DLNode * PhyMM::phyADtoPage(uptr32_t pAd) {
c01023ea:	55                   	push   %ebp
c01023eb:	89 e5                	mov    %esp,%ebp
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
c01023ed:	8b 45 0c             	mov    0xc(%ebp),%eax
    return &(pNodeArr[pIndex]);
c01023f0:	8b 55 08             	mov    0x8(%ebp),%edx
}
c01023f3:	5d                   	pop    %ebp
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
c01023f4:	c1 e8 0c             	shr    $0xc,%eax
    return &(pNodeArr[pIndex]);
c01023f7:	6b c0 11             	imul   $0x11,%eax,%eax
c01023fa:	03 42 41             	add    0x41(%edx),%eax
}
c01023fd:	c3                   	ret    

c01023fe <_ZN5PhyMM10pnodeToLADEPN4ListIN3MMU4PageEE6DLNodeE>:

uptr32_t PhyMM::pnodeToLAD(List<Page>::DLNode *node) {
c01023fe:	55                   	push   %ebp
c01023ff:	89 e5                	mov    %esp,%ebp
    uint32_t pageNo = node - pNodeArr;       // physical memory page NO
c0102401:	8b 45 08             	mov    0x8(%ebp),%eax
c0102404:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102407:	2b 50 41             	sub    0x41(%eax),%edx
c010240a:	69 d2 f1 f0 f0 f0    	imul   $0xf0f0f0f1,%edx,%edx
    return pToVirAD(pageNo << PGSHIFT);
c0102410:	c1 e2 0c             	shl    $0xc,%edx
    if (pAd <= KERNEL_MEM_SIZE) {
c0102413:	81 fa 00 00 00 38    	cmp    $0x38000000,%edx
        return pAd + KERNEL_BASE;
c0102419:	8d 82 00 00 00 c0    	lea    -0x40000000(%edx),%eax
    if (pAd <= KERNEL_MEM_SIZE) {
c010241f:	76 02                	jbe    c0102423 <_ZN5PhyMM10pnodeToLADEPN4ListIN3MMU4PageEE6DLNodeE+0x25>
c0102421:	31 c0                	xor    %eax,%eax
}
c0102423:	5d                   	pop    %ebp
c0102424:	c3                   	ret    
c0102425:	90                   	nop

c0102426 <_ZN5PhyMM11pdeToPTableERKN3MMU7PTEntryE>:

MMU::PTEntry * PhyMM::pdeToPTable(const PTEntry &pte) {
c0102426:	55                   	push   %ebp
c0102427:	89 e5                	mov    %esp,%ebp
c0102429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
    uptr32_t ptAD= pToVirAD(pte.p_ppn);
    return (PTEntry *)ptAD;
}
c010242c:	5d                   	pop    %ebp
    uptr32_t ptAD= pToVirAD(pte.p_ppn);
c010242d:	8a 41 01             	mov    0x1(%ecx),%al
c0102430:	c0 e8 04             	shr    $0x4,%al
c0102433:	0f b6 d0             	movzbl %al,%edx
c0102436:	0f b6 41 02          	movzbl 0x2(%ecx),%eax
c010243a:	c1 e0 04             	shl    $0x4,%eax
c010243d:	09 c2                	or     %eax,%edx
c010243f:	0f b6 41 03          	movzbl 0x3(%ecx),%eax
c0102443:	c1 e0 0c             	shl    $0xc,%eax
c0102446:	09 d0                	or     %edx,%eax
        return pAd + KERNEL_BASE;
c0102448:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010244d:	c3                   	ret    

c010244e <_ZN5PhyMM6getPTEERKN3MMU8LinearADEb>:
void PhyMM::setPermission(T &t, uint32_t perm) {
    uint32_t &temp =  *(uint32_t *)(&t);  // format data to uint32_t
    temp |= perm;
}

MMU::PTEntry * PhyMM::getPTE(const LinearAD &lad, bool create) {
c010244e:	55                   	push   %ebp
c010244f:	89 e5                	mov    %esp,%ebp
c0102451:	57                   	push   %edi
c0102452:	56                   	push   %esi
c0102453:	53                   	push   %ebx
c0102454:	83 ec 0c             	sub    $0xc,%esp
c0102457:	8b 75 0c             	mov    0xc(%ebp),%esi
c010245a:	8b 7d 08             	mov    0x8(%ebp),%edi
c010245d:	8a 45 10             	mov    0x10(%ebp),%al
    PTEntry &pde = bootPDT[lad.PDI];
c0102460:	8a 56 02             	mov    0x2(%esi),%dl
c0102463:	c0 ea 06             	shr    $0x6,%dl
c0102466:	0f b6 ca             	movzbl %dl,%ecx
c0102469:	0f b6 56 03          	movzbl 0x3(%esi),%edx
c010246d:	c1 e2 02             	shl    $0x2,%edx
c0102470:	09 ca                	or     %ecx,%edx
c0102472:	8b 4f 18             	mov    0x18(%edi),%ecx
c0102475:	8d 1c 91             	lea    (%ecx,%edx,4),%ebx
    if (!(pde.p_p) && create) {                          // check present bit and is create?
c0102478:	8a 13                	mov    (%ebx),%dl
c010247a:	f6 d2                	not    %dl
c010247c:	80 e2 01             	and    $0x1,%dl
c010247f:	84 d2                	test   %dl,%dl
c0102481:	74 41                	je     c01024c4 <_ZN5PhyMM6getPTEERKN3MMU8LinearADEb+0x76>
c0102483:	84 c0                	test   %al,%al
c0102485:	74 3d                	je     c01024c4 <_ZN5PhyMM6getPTEERKN3MMU8LinearADEb+0x76>
        /*      wait 2020.4.6      */
        List<Page>::DLNode *pnode;
        if ((pnode = manager->allocPages()) == nullptr) {
c0102487:	8b 47 3d             	mov    0x3d(%edi),%eax
c010248a:	52                   	push   %edx
c010248b:	52                   	push   %edx
c010248c:	8b 10                	mov    (%eax),%edx
c010248e:	6a 01                	push   $0x1
c0102490:	50                   	push   %eax
c0102491:	ff 52 08             	call   *0x8(%edx)
c0102494:	83 c4 10             	add    $0x10,%esp
c0102497:	89 c2                	mov    %eax,%edx
            return nullptr;
c0102499:	31 c0                	xor    %eax,%eax
        if ((pnode = manager->allocPages()) == nullptr) {
c010249b:	85 d2                	test   %edx,%edx
c010249d:	74 5c                	je     c01024fb <_ZN5PhyMM6getPTEERKN3MMU8LinearADEb+0xad>
        }
        pnode->data.ref = 1;
c010249f:	c7 02 01 00 00 00    	movl   $0x1,(%edx)
        // clear page content
        Utils::memset(pnodeToLAD(pnode), 0, PGSIZE);
c01024a5:	50                   	push   %eax
c01024a6:	50                   	push   %eax
c01024a7:	52                   	push   %edx
c01024a8:	57                   	push   %edi
c01024a9:	e8 50 ff ff ff       	call   c01023fe <_ZN5PhyMM10pnodeToLADEPN4ListIN3MMU4PageEE6DLNodeE>
c01024ae:	83 c4 0c             	add    $0xc,%esp
c01024b1:	68 00 10 00 00       	push   $0x1000
c01024b6:	6a 00                	push   $0x0
c01024b8:	50                   	push   %eax
c01024b9:	e8 e0 f8 ff ff       	call   c0101d9e <_ZN5Utils6memsetEjhj>
c01024be:	83 c4 10             	add    $0x10,%esp
        // set permssion
        pde.p_us = 1;
        pde.p_rw = 1;
        pde.p_p = 1;
c01024c1:	80 0b 07             	orb    $0x7,(%ebx)
    uptr32_t ptAD= pToVirAD(pte.p_ppn);
c01024c4:	8a 53 01             	mov    0x1(%ebx),%dl
c01024c7:	c0 ea 04             	shr    $0x4,%dl
c01024ca:	0f b6 c2             	movzbl %dl,%eax
c01024cd:	0f b6 53 02          	movzbl 0x2(%ebx),%edx
c01024d1:	c1 e2 04             	shl    $0x4,%edx
c01024d4:	09 d0                	or     %edx,%eax
c01024d6:	0f b6 53 03          	movzbl 0x3(%ebx),%edx
c01024da:	c1 e2 0c             	shl    $0xc,%edx
c01024dd:	09 c2                	or     %eax,%edx
    }
    return &(pdeToPTable(pde)[lad.PTI]);
c01024df:	8a 46 01             	mov    0x1(%esi),%al
c01024e2:	c0 e8 04             	shr    $0x4,%al
c01024e5:	0f b6 c8             	movzbl %al,%ecx
c01024e8:	0f b6 46 02          	movzbl 0x2(%esi),%eax
c01024ec:	83 e0 3f             	and    $0x3f,%eax
c01024ef:	c1 e0 04             	shl    $0x4,%eax
c01024f2:	09 c8                	or     %ecx,%eax
c01024f4:	8d 84 82 00 00 00 c0 	lea    -0x40000000(%edx,%eax,4),%eax
}
c01024fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01024fe:	5b                   	pop    %ebx
c01024ff:	5e                   	pop    %esi
c0102500:	5f                   	pop    %edi
c0102501:	5d                   	pop    %ebp
c0102502:	c3                   	ret    
c0102503:	90                   	nop

c0102504 <_ZN5PhyMM10mapSegmentEjjjj>:
void PhyMM::mapSegment(uptr32_t lad, uptr32_t pad, uint32_t size, uint32_t perm) {
c0102504:	55                   	push   %ebp
c0102505:	89 e5                	mov    %esp,%ebp
c0102507:	57                   	push   %edi
c0102508:	56                   	push   %esi
c0102509:	53                   	push   %ebx
c010250a:	e8 a6 e6 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c010250f:	81 c3 01 9f 01 00    	add    $0x19f01,%ebx
c0102515:	81 ec 54 02 00 00    	sub    $0x254,%esp
    OStream out("\n\nmapSegment:\n lad: ", "blue");
c010251b:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c0102521:	8d 83 fa 82 fe ff    	lea    -0x17d06(%ebx),%eax
c0102527:	50                   	push   %eax
c0102528:	56                   	push   %esi
c0102529:	e8 22 21 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010252e:	8d 83 66 84 fe ff    	lea    -0x17b9a(%ebx),%eax
c0102534:	59                   	pop    %ecx
c0102535:	5f                   	pop    %edi
c0102536:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c010253c:	50                   	push   %eax
c010253d:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c0102543:	50                   	push   %eax
c0102544:	89 85 b0 fd ff ff    	mov    %eax,-0x250(%ebp)
c010254a:	e8 01 21 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010254f:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c0102555:	83 c4 0c             	add    $0xc,%esp
c0102558:	56                   	push   %esi
c0102559:	50                   	push   %eax
c010255a:	57                   	push   %edi
c010255b:	e8 06 f5 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0102560:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c0102566:	89 04 24             	mov    %eax,(%esp)
c0102569:	e8 fc 20 00 00       	call   c010466a <_ZN6StringD1Ev>
c010256e:	89 34 24             	mov    %esi,(%esp)
c0102571:	e8 f4 20 00 00       	call   c010466a <_ZN6StringD1Ev>
    out.writeValue(lad);
c0102576:	58                   	pop    %eax
c0102577:	8d 45 0c             	lea    0xc(%ebp),%eax
c010257a:	5a                   	pop    %edx
c010257b:	50                   	push   %eax
c010257c:	57                   	push   %edi
c010257d:	e8 b2 f6 ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
    out.write(" to pad: ");
c0102582:	59                   	pop    %ecx
c0102583:	58                   	pop    %eax
c0102584:	8d 83 7b 84 fe ff    	lea    -0x17b85(%ebx),%eax
c010258a:	50                   	push   %eax
c010258b:	56                   	push   %esi
c010258c:	e8 bf 20 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102591:	58                   	pop    %eax
c0102592:	5a                   	pop    %edx
c0102593:	56                   	push   %esi
c0102594:	57                   	push   %edi
c0102595:	e8 56 f6 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c010259a:	89 34 24             	mov    %esi,(%esp)
c010259d:	e8 c8 20 00 00       	call   c010466a <_ZN6StringD1Ev>
    out.writeValue(pad);
c01025a2:	8d 45 10             	lea    0x10(%ebp),%eax
c01025a5:	59                   	pop    %ecx
c01025a6:	5e                   	pop    %esi
    for (uint32_t i = 0; i < n; i++) {
c01025a7:	31 f6                	xor    %esi,%esi
    out.writeValue(pad);
c01025a9:	50                   	push   %eax
c01025aa:	57                   	push   %edi
c01025ab:	e8 84 f6 ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
    out.flush();
c01025b0:	89 3c 24             	mov    %edi,(%esp)
c01025b3:	e8 4c f5 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
c01025b8:	8b 45 0c             	mov    0xc(%ebp),%eax
    uint32_t n = Utils::roundUp(size + LAD(lad).OFF, PGSIZE) / PGSIZE;
c01025bb:	83 c4 0c             	add    $0xc,%esp
c01025be:	8d 95 b4 fd ff ff    	lea    -0x24c(%ebp),%edx
c01025c4:	81 65 10 00 f0 ff ff 	andl   $0xfffff000,0x10(%ebp)
c01025cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01025d0:	50                   	push   %eax
c01025d1:	ff 75 08             	pushl  0x8(%ebp)
    lad = Utils::roundDown(lad, PGSIZE);
c01025d4:	89 45 0c             	mov    %eax,0xc(%ebp)
    uint32_t n = Utils::roundUp(size + LAD(lad).OFF, PGSIZE) / PGSIZE;
c01025d7:	52                   	push   %edx
c01025d8:	e8 c5 1e 00 00       	call   c01044a2 <_ZN3MMU3LADEj>
c01025dd:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c01025e3:	25 ff 0f 00 00       	and    $0xfff,%eax
c01025e8:	03 45 14             	add    0x14(%ebp),%eax
c01025eb:	83 ec 0c             	sub    $0xc,%esp
c01025ee:	68 00 10 00 00       	push   $0x1000
c01025f3:	50                   	push   %eax
c01025f4:	e8 77 f7 ff ff       	call   c0101d70 <_ZN5Utils7roundUpEjj>
c01025f9:	83 c4 20             	add    $0x20,%esp
c01025fc:	c1 e8 0c             	shr    $0xc,%eax
c01025ff:	89 85 b0 fd ff ff    	mov    %eax,-0x250(%ebp)
    for (uint32_t i = 0; i < n; i++) {
c0102605:	3b b5 b0 fd ff ff    	cmp    -0x250(%ebp),%esi
c010260b:	74 6e                	je     c010267b <_ZN5PhyMM10mapSegmentEjjjj+0x177>
        PTEntry *pte = getPTE(LAD(lad));
c010260d:	50                   	push   %eax
    for (uint32_t i = 0; i < n; i++) {
c010260e:	46                   	inc    %esi
        PTEntry *pte = getPTE(LAD(lad));
c010260f:	ff 75 0c             	pushl  0xc(%ebp)
c0102612:	8d bd bd fd ff ff    	lea    -0x243(%ebp),%edi
c0102618:	ff 75 08             	pushl  0x8(%ebp)
c010261b:	57                   	push   %edi
c010261c:	e8 81 1e 00 00       	call   c01044a2 <_ZN3MMU3LADEj>
c0102621:	52                   	push   %edx
c0102622:	52                   	push   %edx
c0102623:	6a 01                	push   $0x1
c0102625:	57                   	push   %edi
c0102626:	ff 75 08             	pushl  0x8(%ebp)
c0102629:	e8 20 fe ff ff       	call   c010244e <_ZN5PhyMM6getPTEERKN3MMU8LinearADEb>
        setPermission(*pte, PTE_P | perm);
c010262e:	8b 55 18             	mov    0x18(%ebp),%edx
    for (uint32_t i = 0; i < n; i++) {
c0102631:	83 c4 20             	add    $0x20,%esp
        setPermission(*pte, PTE_P | perm);
c0102634:	83 ca 01             	or     $0x1,%edx
    temp |= perm;
c0102637:	09 10                	or     %edx,(%eax)
        pte->p_ppn = (pad >> PGSHIFT);         // set physical address (20-bits)
c0102639:	8b 55 10             	mov    0x10(%ebp),%edx
c010263c:	89 d1                	mov    %edx,%ecx
c010263e:	c1 e9 0c             	shr    $0xc,%ecx
c0102641:	c0 e1 04             	shl    $0x4,%cl
c0102644:	88 8d af fd ff ff    	mov    %cl,-0x251(%ebp)
c010264a:	8a 48 01             	mov    0x1(%eax),%cl
c010264d:	80 e1 0f             	and    $0xf,%cl
c0102650:	0a 8d af fd ff ff    	or     -0x251(%ebp),%cl
c0102656:	88 48 01             	mov    %cl,0x1(%eax)
c0102659:	89 d1                	mov    %edx,%ecx
c010265b:	c1 e9 10             	shr    $0x10,%ecx
c010265e:	88 48 02             	mov    %cl,0x2(%eax)
c0102661:	89 d1                	mov    %edx,%ecx
        pad += PGSIZE;
c0102663:	81 c2 00 10 00 00    	add    $0x1000,%edx
        pte->p_ppn = (pad >> PGSHIFT);         // set physical address (20-bits)
c0102669:	c1 e9 18             	shr    $0x18,%ecx
c010266c:	88 48 03             	mov    %cl,0x3(%eax)
        lad += PGSIZE;
c010266f:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
        pad += PGSIZE;
c0102676:	89 55 10             	mov    %edx,0x10(%ebp)
    for (uint32_t i = 0; i < n; i++) {
c0102679:	eb 8a                	jmp    c0102605 <_ZN5PhyMM10mapSegmentEjjjj+0x101>
    OStream out("\n\nmapSegment:\n lad: ", "blue");
c010267b:	83 ec 0c             	sub    $0xc,%esp
c010267e:	8d 85 c2 fd ff ff    	lea    -0x23e(%ebp),%eax
c0102684:	50                   	push   %eax
c0102685:	e8 bc f4 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
}
c010268a:	83 c4 10             	add    $0x10,%esp
c010268d:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102690:	5b                   	pop    %ebx
c0102691:	5e                   	pop    %esi
c0102692:	5f                   	pop    %edi
c0102693:	5d                   	pop    %ebp
c0102694:	c3                   	ret    
c0102695:	90                   	nop

c0102696 <_ZN5PhyMM4initEv>:
void PhyMM::init() {
c0102696:	55                   	push   %ebp
c0102697:	89 e5                	mov    %esp,%ebp
c0102699:	57                   	push   %edi
c010269a:	56                   	push   %esi
c010269b:	53                   	push   %ebx
c010269c:	e8 14 e5 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c01026a1:	81 c3 6f 9d 01 00    	add    $0x19d6f,%ebx
c01026a7:	83 ec 1c             	sub    $0x1c,%esp
c01026aa:	8b 75 08             	mov    0x8(%ebp),%esi
    bootCR3 = vToPhyAD(__boot_pgdir);
c01026ad:	c7 c0 00 d0 11 c0    	mov    $0xc011d000,%eax
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c01026b3:	8b 00                	mov    (%eax),%eax
c01026b5:	05 00 00 00 40       	add    $0x40000000,%eax
c01026ba:	3d 00 00 00 38       	cmp    $0x38000000,%eax
c01026bf:	76 02                	jbe    c01026c3 <_ZN5PhyMM4initEv+0x2d>
    return 0;
c01026c1:	31 c0                	xor    %eax,%eax
    bootCR3 = vToPhyAD(__boot_pgdir);
c01026c3:	c7 c2 28 fa 11 c0    	mov    $0xc011fa28,%edx
    initPage();
c01026c9:	83 ec 0c             	sub    $0xc,%esp
    bootCR3 = vToPhyAD(__boot_pgdir);
c01026cc:	89 02                	mov    %eax,(%edx)
    manager = &ff;
c01026ce:	8d 46 20             	lea    0x20(%esi),%eax
c01026d1:	89 46 3d             	mov    %eax,0x3d(%esi)
    initPage();
c01026d4:	56                   	push   %esi
c01026d5:	e8 68 f7 ff ff       	call   c0101e42 <_ZN5PhyMM8initPageEv>
    bootPDT[LAD(VPT).PDI].p_ppn = (vToPhyAD((uptr32_t)bootPDT) >> PGSHIFT) && 0xFFFFF;
c01026da:	8b 7e 18             	mov    0x18(%esi),%edi
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c01026dd:	83 c4 10             	add    $0x10,%esp
c01026e0:	8d 87 00 00 00 40    	lea    0x40000000(%edi),%eax
c01026e6:	3d 00 00 00 38       	cmp    $0x38000000,%eax
c01026eb:	76 02                	jbe    c01026ef <_ZN5PhyMM4initEv+0x59>
    return 0;
c01026ed:	31 c0                	xor    %eax,%eax
    bootPDT[LAD(VPT).PDI].p_ppn = (vToPhyAD((uptr32_t)bootPDT) >> PGSHIFT) && 0xFFFFF;
c01026ef:	52                   	push   %edx
c01026f0:	68 00 00 c0 fa       	push   $0xfac00000
c01026f5:	56                   	push   %esi
c01026f6:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01026f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01026fc:	50                   	push   %eax
c01026fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102700:	e8 9d 1d 00 00       	call   c01044a2 <_ZN3MMU3LADEj>
c0102705:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102708:	c1 ea 16             	shr    $0x16,%edx
c010270b:	59                   	pop    %ecx
c010270c:	8a 4c 97 01          	mov    0x1(%edi,%edx,4),%cl
c0102710:	58                   	pop    %eax
c0102711:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102714:	c6 44 97 02 00       	movb   $0x0,0x2(%edi,%edx,4)
c0102719:	c6 44 97 03 00       	movb   $0x0,0x3(%edi,%edx,4)
c010271e:	c1 e8 0c             	shr    $0xc,%eax
c0102721:	0f 95 c0             	setne  %al
c0102724:	80 e1 0f             	and    $0xf,%cl
c0102727:	0f b6 c0             	movzbl %al,%eax
c010272a:	c0 e0 04             	shl    $0x4,%al
c010272d:	08 c8                	or     %cl,%al
c010272f:	88 44 97 01          	mov    %al,0x1(%edi,%edx,4)
    bootPDT[LAD(VPT).PDI].p_p = 1;
c0102733:	8b 7e 18             	mov    0x18(%esi),%edi
c0102736:	68 00 00 c0 fa       	push   $0xfac00000
c010273b:	56                   	push   %esi
c010273c:	ff 75 e0             	pushl  -0x20(%ebp)
c010273f:	e8 5e 1d 00 00       	call   c01044a2 <_ZN3MMU3LADEj>
c0102744:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102747:	c1 e8 16             	shr    $0x16,%eax
c010274a:	80 0c 87 01          	orb    $0x1,(%edi,%eax,4)
    bootPDT[LAD(VPT).PDI].p_rw = 1;
c010274e:	8b 7e 18             	mov    0x18(%esi),%edi
c0102751:	50                   	push   %eax
c0102752:	50                   	push   %eax
c0102753:	68 00 00 c0 fa       	push   $0xfac00000
c0102758:	56                   	push   %esi
c0102759:	ff 75 e0             	pushl  -0x20(%ebp)
c010275c:	e8 41 1d 00 00       	call   c01044a2 <_ZN3MMU3LADEj>
c0102761:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102764:	c1 e8 16             	shr    $0x16,%eax
c0102767:	80 0c 87 02          	orb    $0x2,(%edi,%eax,4)
    mapSegment(KERNEL_BASE, 0, KERNEL_MEM_SIZE, PTE_W);
c010276b:	6a 02                	push   $0x2
c010276d:	68 00 00 00 38       	push   $0x38000000
c0102772:	6a 00                	push   $0x0
c0102774:	68 00 00 00 c0       	push   $0xc0000000
c0102779:	56                   	push   %esi
c010277a:	e8 85 fd ff ff       	call   c0102504 <_ZN5PhyMM10mapSegmentEjjjj>
    initGDTAndTSS();
c010277f:	83 c4 30             	add    $0x30,%esp
c0102782:	89 75 08             	mov    %esi,0x8(%ebp)
}
c0102785:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102788:	5b                   	pop    %ebx
c0102789:	5e                   	pop    %esi
c010278a:	5f                   	pop    %edi
c010278b:	5d                   	pop    %ebp
    initGDTAndTSS();
c010278c:	e9 19 fb ff ff       	jmp    c01022aa <_ZN5PhyMM13initGDTAndTSSEv>
c0102791:	90                   	nop

c0102792 <_ZN5PhyMM7kmallocEj>:

void * PhyMM::kmalloc(uint32_t size) {
c0102792:	55                   	push   %ebp
c0102793:	89 e5                	mov    %esp,%ebp
c0102795:	57                   	push   %edi
c0102796:	56                   	push   %esi
c0102797:	53                   	push   %ebx
c0102798:	81 ec 4c 02 00 00    	sub    $0x24c,%esp

    void * ptr = nullptr;
    List<Page>::DLNode *base = nullptr;
    assert(size > 0 && size < 1024*0124);
c010279e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01027a1:	e8 0f e4 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c01027a6:	81 c3 6a 9c 01 00    	add    $0x19c6a,%ebx
c01027ac:	48                   	dec    %eax
c01027ad:	3d fe 4f 01 00       	cmp    $0x14ffe,%eax
c01027b2:	0f 86 92 00 00 00    	jbe    c010284a <_ZN5PhyMM7kmallocEj+0xb8>
c01027b8:	50                   	push   %eax
c01027b9:	50                   	push   %eax
c01027ba:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c01027c0:	50                   	push   %eax
c01027c1:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c01027c7:	56                   	push   %esi
c01027c8:	e8 83 1e 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01027cd:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c01027d3:	58                   	pop    %eax
c01027d4:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c01027da:	5a                   	pop    %edx
c01027db:	50                   	push   %eax
c01027dc:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c01027e2:	50                   	push   %eax
c01027e3:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c01027e9:	e8 62 1e 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01027ee:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c01027f4:	83 c4 0c             	add    $0xc,%esp
c01027f7:	56                   	push   %esi
c01027f8:	50                   	push   %eax
c01027f9:	57                   	push   %edi
c01027fa:	e8 67 f2 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c01027ff:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0102805:	89 04 24             	mov    %eax,(%esp)
c0102808:	e8 5d 1e 00 00       	call   c010466a <_ZN6StringD1Ev>
c010280d:	89 34 24             	mov    %esi,(%esp)
c0102810:	e8 55 1e 00 00       	call   c010466a <_ZN6StringD1Ev>
c0102815:	59                   	pop    %ecx
c0102816:	58                   	pop    %eax
c0102817:	8d 83 85 84 fe ff    	lea    -0x17b7b(%ebx),%eax
c010281d:	50                   	push   %eax
c010281e:	56                   	push   %esi
c010281f:	e8 2c 1e 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102824:	58                   	pop    %eax
c0102825:	5a                   	pop    %edx
c0102826:	56                   	push   %esi
c0102827:	57                   	push   %edi
c0102828:	e8 c3 f3 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c010282d:	89 34 24             	mov    %esi,(%esp)
c0102830:	e8 35 1e 00 00       	call   c010466a <_ZN6StringD1Ev>
c0102835:	89 3c 24             	mov    %edi,(%esp)
c0102838:	e8 c7 f2 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010283d:	fa                   	cli    
    asm volatile ("hlt");
c010283e:	f4                   	hlt    
c010283f:	89 3c 24             	mov    %edi,(%esp)
c0102842:	e8 ff f2 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c0102847:	83 c4 10             	add    $0x10,%esp
    uint32_t num_pages = (size + PGSIZE - 1 ) / PGSIZE;
    base = manager->allocPages(num_pages);
c010284a:	8b 45 08             	mov    0x8(%ebp),%eax
c010284d:	8b 50 3d             	mov    0x3d(%eax),%edx
c0102850:	50                   	push   %eax
c0102851:	50                   	push   %eax
    uint32_t num_pages = (size + PGSIZE - 1 ) / PGSIZE;
c0102852:	8b 45 0c             	mov    0xc(%ebp),%eax
    base = manager->allocPages(num_pages);
c0102855:	8b 0a                	mov    (%edx),%ecx
    uint32_t num_pages = (size + PGSIZE - 1 ) / PGSIZE;
c0102857:	05 ff 0f 00 00       	add    $0xfff,%eax
c010285c:	c1 e8 0c             	shr    $0xc,%eax
    base = manager->allocPages(num_pages);
c010285f:	50                   	push   %eax
c0102860:	52                   	push   %edx
c0102861:	ff 51 08             	call   *0x8(%ecx)
    assert(base != nullptr);
c0102864:	83 c4 10             	add    $0x10,%esp
c0102867:	85 c0                	test   %eax,%eax
c0102869:	0f 85 9e 00 00 00    	jne    c010290d <_ZN5PhyMM7kmallocEj+0x17b>
c010286f:	51                   	push   %ecx
c0102870:	51                   	push   %ecx
c0102871:	8d 93 15 83 fe ff    	lea    -0x17ceb(%ebx),%edx
c0102877:	52                   	push   %edx
c0102878:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c010287e:	56                   	push   %esi
c010287f:	89 85 b0 fd ff ff    	mov    %eax,-0x250(%ebp)
c0102885:	e8 c6 1d 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010288a:	8d 93 1f 83 fe ff    	lea    -0x17ce1(%ebx),%edx
c0102890:	5f                   	pop    %edi
c0102891:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c0102897:	58                   	pop    %eax
c0102898:	52                   	push   %edx
c0102899:	8d 95 b8 fd ff ff    	lea    -0x248(%ebp),%edx
c010289f:	52                   	push   %edx
c01028a0:	89 95 b4 fd ff ff    	mov    %edx,-0x24c(%ebp)
c01028a6:	e8 a5 1d 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01028ab:	8b 95 b4 fd ff ff    	mov    -0x24c(%ebp),%edx
c01028b1:	83 c4 0c             	add    $0xc,%esp
c01028b4:	56                   	push   %esi
c01028b5:	52                   	push   %edx
c01028b6:	57                   	push   %edi
c01028b7:	e8 aa f1 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c01028bc:	8b 95 b4 fd ff ff    	mov    -0x24c(%ebp),%edx
c01028c2:	89 14 24             	mov    %edx,(%esp)
c01028c5:	e8 a0 1d 00 00       	call   c010466a <_ZN6StringD1Ev>
c01028ca:	89 34 24             	mov    %esi,(%esp)
c01028cd:	e8 98 1d 00 00       	call   c010466a <_ZN6StringD1Ev>
c01028d2:	58                   	pop    %eax
c01028d3:	5a                   	pop    %edx
c01028d4:	8d 93 a2 84 fe ff    	lea    -0x17b5e(%ebx),%edx
c01028da:	52                   	push   %edx
c01028db:	56                   	push   %esi
c01028dc:	e8 6f 1d 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01028e1:	59                   	pop    %ecx
c01028e2:	58                   	pop    %eax
c01028e3:	56                   	push   %esi
c01028e4:	57                   	push   %edi
c01028e5:	e8 06 f3 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c01028ea:	89 34 24             	mov    %esi,(%esp)
c01028ed:	e8 78 1d 00 00       	call   c010466a <_ZN6StringD1Ev>
c01028f2:	89 3c 24             	mov    %edi,(%esp)
c01028f5:	e8 0a f2 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01028fa:	fa                   	cli    
    asm volatile ("hlt");
c01028fb:	f4                   	hlt    
c01028fc:	89 3c 24             	mov    %edi,(%esp)
c01028ff:	e8 42 f2 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c0102904:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c010290a:	83 c4 10             	add    $0x10,%esp
    ptr = (void *)pnodeToLAD(base);
c010290d:	52                   	push   %edx
c010290e:	52                   	push   %edx
c010290f:	50                   	push   %eax
c0102910:	ff 75 08             	pushl  0x8(%ebp)
c0102913:	e8 e6 fa ff ff       	call   c01023fe <_ZN5PhyMM10pnodeToLADEPN4ListIN3MMU4PageEE6DLNodeE>
c0102918:	83 c4 10             	add    $0x10,%esp
    return ptr;

}
c010291b:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010291e:	5b                   	pop    %ebx
c010291f:	5e                   	pop    %esi
c0102920:	5f                   	pop    %edi
c0102921:	5d                   	pop    %ebp
c0102922:	c3                   	ret    
c0102923:	90                   	nop

c0102924 <_ZN5PhyMM5kfreeEPvj>:

void PhyMM::kfree(void *ptr, uint32_t size) {
c0102924:	55                   	push   %ebp
c0102925:	89 e5                	mov    %esp,%ebp
c0102927:	57                   	push   %edi
c0102928:	56                   	push   %esi
c0102929:	53                   	push   %ebx
c010292a:	81 ec 4c 02 00 00    	sub    $0x24c,%esp
    assert(size > 0 && size < 1024*0124);
c0102930:	8b 45 10             	mov    0x10(%ebp),%eax
c0102933:	e8 7d e2 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0102938:	81 c3 d8 9a 01 00    	add    $0x19ad8,%ebx
c010293e:	48                   	dec    %eax
c010293f:	3d fe 4f 01 00       	cmp    $0x14ffe,%eax
c0102944:	0f 86 92 00 00 00    	jbe    c01029dc <_ZN5PhyMM5kfreeEPvj+0xb8>
c010294a:	50                   	push   %eax
c010294b:	50                   	push   %eax
c010294c:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0102952:	50                   	push   %eax
c0102953:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c0102959:	56                   	push   %esi
c010295a:	e8 f1 1c 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010295f:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c0102965:	58                   	pop    %eax
c0102966:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c010296c:	5a                   	pop    %edx
c010296d:	50                   	push   %eax
c010296e:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c0102974:	50                   	push   %eax
c0102975:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c010297b:	e8 d0 1c 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102980:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0102986:	83 c4 0c             	add    $0xc,%esp
c0102989:	56                   	push   %esi
c010298a:	50                   	push   %eax
c010298b:	57                   	push   %edi
c010298c:	e8 d5 f0 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0102991:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0102997:	89 04 24             	mov    %eax,(%esp)
c010299a:	e8 cb 1c 00 00       	call   c010466a <_ZN6StringD1Ev>
c010299f:	89 34 24             	mov    %esi,(%esp)
c01029a2:	e8 c3 1c 00 00       	call   c010466a <_ZN6StringD1Ev>
c01029a7:	59                   	pop    %ecx
c01029a8:	58                   	pop    %eax
c01029a9:	8d 83 85 84 fe ff    	lea    -0x17b7b(%ebx),%eax
c01029af:	50                   	push   %eax
c01029b0:	56                   	push   %esi
c01029b1:	e8 9a 1c 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01029b6:	58                   	pop    %eax
c01029b7:	5a                   	pop    %edx
c01029b8:	56                   	push   %esi
c01029b9:	57                   	push   %edi
c01029ba:	e8 31 f2 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c01029bf:	89 34 24             	mov    %esi,(%esp)
c01029c2:	e8 a3 1c 00 00       	call   c010466a <_ZN6StringD1Ev>
c01029c7:	89 3c 24             	mov    %edi,(%esp)
c01029ca:	e8 35 f1 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01029cf:	fa                   	cli    
    asm volatile ("hlt");
c01029d0:	f4                   	hlt    
c01029d1:	89 3c 24             	mov    %edi,(%esp)
c01029d4:	e8 6d f1 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c01029d9:	83 c4 10             	add    $0x10,%esp
    assert(ptr != nullptr);
c01029dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01029e0:	0f 85 92 00 00 00    	jne    c0102a78 <_ZN5PhyMM5kfreeEPvj+0x154>
c01029e6:	56                   	push   %esi
c01029e7:	56                   	push   %esi
c01029e8:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c01029ee:	50                   	push   %eax
c01029ef:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c01029f5:	56                   	push   %esi
c01029f6:	e8 55 1c 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01029fb:	5f                   	pop    %edi
c01029fc:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c0102a02:	58                   	pop    %eax
c0102a03:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c0102a09:	50                   	push   %eax
c0102a0a:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c0102a10:	50                   	push   %eax
c0102a11:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c0102a17:	e8 34 1c 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102a1c:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0102a22:	83 c4 0c             	add    $0xc,%esp
c0102a25:	56                   	push   %esi
c0102a26:	50                   	push   %eax
c0102a27:	57                   	push   %edi
c0102a28:	e8 39 f0 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0102a2d:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0102a33:	89 04 24             	mov    %eax,(%esp)
c0102a36:	e8 2f 1c 00 00       	call   c010466a <_ZN6StringD1Ev>
c0102a3b:	89 34 24             	mov    %esi,(%esp)
c0102a3e:	e8 27 1c 00 00       	call   c010466a <_ZN6StringD1Ev>
c0102a43:	58                   	pop    %eax
c0102a44:	8d 83 b2 84 fe ff    	lea    -0x17b4e(%ebx),%eax
c0102a4a:	5a                   	pop    %edx
c0102a4b:	50                   	push   %eax
c0102a4c:	56                   	push   %esi
c0102a4d:	e8 fe 1b 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102a52:	59                   	pop    %ecx
c0102a53:	58                   	pop    %eax
c0102a54:	56                   	push   %esi
c0102a55:	57                   	push   %edi
c0102a56:	e8 95 f1 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0102a5b:	89 34 24             	mov    %esi,(%esp)
c0102a5e:	e8 07 1c 00 00       	call   c010466a <_ZN6StringD1Ev>
c0102a63:	89 3c 24             	mov    %edi,(%esp)
c0102a66:	e8 99 f0 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0102a6b:	fa                   	cli    
    asm volatile ("hlt");
c0102a6c:	f4                   	hlt    
c0102a6d:	89 3c 24             	mov    %edi,(%esp)
c0102a70:	e8 d1 f0 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c0102a75:	83 c4 10             	add    $0x10,%esp
    List<Page>::DLNode *base = nullptr;
    uint32_t num_pages = (size + PGSIZE - 1) / PGSIZE;
c0102a78:	8b 45 10             	mov    0x10(%ebp),%eax
c0102a7b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c0102a81:	8b 45 0c             	mov    0xc(%ebp),%eax
    uint32_t num_pages = (size + PGSIZE - 1) / PGSIZE;
c0102a84:	c1 eb 0c             	shr    $0xc,%ebx
    if (KERNEL_BASE <= kvAd && kvAd <= KERNEL_BASE + KERNEL_MEM_SIZE) {
c0102a87:	05 00 00 00 40       	add    $0x40000000,%eax
c0102a8c:	3d 00 00 00 38       	cmp    $0x38000000,%eax
c0102a91:	76 02                	jbe    c0102a95 <_ZN5PhyMM5kfreeEPvj+0x171>
    return 0;
c0102a93:	31 c0                	xor    %eax,%eax
    base = phyADtoPage(vToPhyAD((uptr32_t)ptr));
    manager->freePages(base, num_pages);
c0102a95:	8b 4d 08             	mov    0x8(%ebp),%ecx
    uint32_t pIndex = pAd >> PGSHIFT;       // get pages-No
c0102a98:	c1 e8 0c             	shr    $0xc,%eax
    return &(pNodeArr[pIndex]);
c0102a9b:	8b 7d 08             	mov    0x8(%ebp),%edi
c0102a9e:	6b c0 11             	imul   $0x11,%eax,%eax
    manager->freePages(base, num_pages);
c0102aa1:	8b 51 3d             	mov    0x3d(%ecx),%edx
c0102aa4:	51                   	push   %ecx
    return &(pNodeArr[pIndex]);
c0102aa5:	03 47 41             	add    0x41(%edi),%eax
    manager->freePages(base, num_pages);
c0102aa8:	8b 0a                	mov    (%edx),%ecx
c0102aaa:	53                   	push   %ebx
c0102aab:	50                   	push   %eax
c0102aac:	52                   	push   %edx
c0102aad:	ff 51 0c             	call   *0xc(%ecx)
}
c0102ab0:	83 c4 10             	add    $0x10,%esp
c0102ab3:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102ab6:	5b                   	pop    %ebx
c0102ab7:	5e                   	pop    %esi
c0102ab8:	5f                   	pop    %edi
c0102ab9:	5d                   	pop    %ebp
c0102aba:	c3                   	ret    
c0102abb:	90                   	nop

c0102abc <_ZN5PhyMM12numFreePagesEv>:

uint32_t PhyMM::numFreePages() {
c0102abc:	55                   	push   %ebp
c0102abd:	89 e5                	mov    %esp,%ebp
c0102abf:	57                   	push   %edi
c0102ac0:	56                   	push   %esi
c0102ac1:	53                   	push   %ebx
c0102ac2:	e8 ee e0 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0102ac7:	81 c3 49 99 01 00    	add    $0x19949,%ebx
c0102acd:	81 ec 54 02 00 00    	sub    $0x254,%esp
    DEBUGPRINT("numFreePages");
c0102ad3:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c0102ad9:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c0102adf:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0102ae5:	50                   	push   %eax
c0102ae6:	56                   	push   %esi
c0102ae7:	e8 64 1b 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102aec:	58                   	pop    %eax
c0102aed:	8d 83 c1 84 fe ff    	lea    -0x17b3f(%ebx),%eax
c0102af3:	5a                   	pop    %edx
c0102af4:	50                   	push   %eax
c0102af5:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c0102afb:	50                   	push   %eax
c0102afc:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c0102b02:	e8 49 1b 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102b07:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0102b0d:	83 c4 0c             	add    $0xc,%esp
c0102b10:	56                   	push   %esi
c0102b11:	50                   	push   %eax
c0102b12:	57                   	push   %edi
c0102b13:	e8 4e ef ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0102b18:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0102b1e:	89 04 24             	mov    %eax,(%esp)
c0102b21:	e8 44 1b 00 00       	call   c010466a <_ZN6StringD1Ev>
c0102b26:	89 34 24             	mov    %esi,(%esp)
c0102b29:	e8 3c 1b 00 00       	call   c010466a <_ZN6StringD1Ev>
c0102b2e:	59                   	pop    %ecx
c0102b2f:	58                   	pop    %eax
c0102b30:	8d 83 d1 84 fe ff    	lea    -0x17b2f(%ebx),%eax
c0102b36:	50                   	push   %eax
c0102b37:	56                   	push   %esi
c0102b38:	e8 13 1b 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102b3d:	58                   	pop    %eax
c0102b3e:	5a                   	pop    %edx
c0102b3f:	56                   	push   %esi
c0102b40:	57                   	push   %edi
c0102b41:	e8 aa f0 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0102b46:	89 34 24             	mov    %esi,(%esp)
c0102b49:	e8 1c 1b 00 00       	call   c010466a <_ZN6StringD1Ev>
c0102b4e:	89 3c 24             	mov    %edi,(%esp)
c0102b51:	e8 ae ef ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
c0102b56:	89 3c 24             	mov    %edi,(%esp)
c0102b59:	e8 e8 ef ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102b5e:	9c                   	pushf  
c0102b5f:	58                   	pop    %eax
c0102b60:	31 db                	xor    %ebx,%ebx
#include <x86.h>
#include <flags.h>

static inline bool
__intr_save(void) {
    if (readEflags() & FL_IF) {
c0102b62:	83 c4 10             	add    $0x10,%esp
c0102b65:	0f ba e0 09          	bt     $0x9,%eax
c0102b69:	73 03                	jae    c0102b6e <_ZN5PhyMM12numFreePagesEv+0xb2>
    asm volatile ("cli");
c0102b6b:	fa                   	cli    
        cli();                  // clear interrupt
        return 1;
c0102b6c:	b3 01                	mov    $0x1,%bl
    uint32_t ret;
    bool intr_flag;
    local_intr_save(intr_flag); 
    {
        ret = manager->numFreePages();
c0102b6e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b71:	83 ec 0c             	sub    $0xc,%esp
c0102b74:	8b 40 3d             	mov    0x3d(%eax),%eax
c0102b77:	8b 10                	mov    (%eax),%edx
c0102b79:	50                   	push   %eax
c0102b7a:	ff 52 10             	call   *0x10(%edx)
    return 0;
}

static inline void
__intr_restore(bool flag) {
    if (flag) {
c0102b7d:	83 c4 10             	add    $0x10,%esp
c0102b80:	84 db                	test   %bl,%bl
c0102b82:	74 01                	je     c0102b85 <_ZN5PhyMM12numFreePagesEv+0xc9>
    asm volatile ("sti");
c0102b84:	fb                   	sti    
    }
    local_intr_restore(intr_flag);
    return ret;
c0102b85:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102b88:	5b                   	pop    %ebx
c0102b89:	5e                   	pop    %esi
c0102b8a:	5f                   	pop    %edi
c0102b8b:	5d                   	pop    %ebp
c0102b8c:	c3                   	ret    
c0102b8d:	90                   	nop

c0102b8e <_ZN4FFMA4initEv>:
#include <FFMA.h>
#include <mmu.h>
#include <ostream.h>
#include <kdebug.h>

void FFMA::init() {
c0102b8e:	55                   	push   %ebp
c0102b8f:	89 e5                	mov    %esp,%ebp
    //name = "First-Fit Memory Allocation (FFMA) Algorithm";
}
c0102b91:	5d                   	pop    %ebp
c0102b92:	c3                   	ret    
c0102b93:	90                   	nop

c0102b94 <_ZN4FFMA12numFreePagesEv>:
    } else {
        freeArea.insertLNode(pnode->pre, pnArr);
    }
}

uint32_t FFMA::numFreePages() {
c0102b94:	55                   	push   %ebp
c0102b95:	89 e5                	mov    %esp,%ebp
c0102b97:	57                   	push   %edi
c0102b98:	56                   	push   %esi
c0102b99:	53                   	push   %ebx
c0102b9a:	e8 16 e0 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0102b9f:	81 c3 71 98 01 00    	add    $0x19871,%ebx
c0102ba5:	81 ec 54 02 00 00    	sub    $0x254,%esp
    DEBUGPRINT("FFMA::numFreePages");
c0102bab:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c0102bb1:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c0102bb7:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0102bbd:	50                   	push   %eax
c0102bbe:	56                   	push   %esi
c0102bbf:	e8 8c 1a 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102bc4:	58                   	pop    %eax
c0102bc5:	8d 83 c1 84 fe ff    	lea    -0x17b3f(%ebx),%eax
c0102bcb:	5a                   	pop    %edx
c0102bcc:	50                   	push   %eax
c0102bcd:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c0102bd3:	50                   	push   %eax
c0102bd4:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c0102bda:	e8 71 1a 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102bdf:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0102be5:	83 c4 0c             	add    $0xc,%esp
c0102be8:	56                   	push   %esi
c0102be9:	50                   	push   %eax
c0102bea:	57                   	push   %edi
c0102beb:	e8 76 ee ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0102bf0:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0102bf6:	89 04 24             	mov    %eax,(%esp)
c0102bf9:	e8 6c 1a 00 00       	call   c010466a <_ZN6StringD1Ev>
c0102bfe:	89 34 24             	mov    %esi,(%esp)
c0102c01:	e8 64 1a 00 00       	call   c010466a <_ZN6StringD1Ev>
c0102c06:	59                   	pop    %ecx
c0102c07:	58                   	pop    %eax
c0102c08:	8d 83 cb 84 fe ff    	lea    -0x17b35(%ebx),%eax
c0102c0e:	50                   	push   %eax
c0102c0f:	56                   	push   %esi
c0102c10:	e8 3b 1a 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102c15:	58                   	pop    %eax
c0102c16:	5a                   	pop    %edx
c0102c17:	56                   	push   %esi
c0102c18:	57                   	push   %edi
c0102c19:	e8 d2 ef ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0102c1e:	89 34 24             	mov    %esi,(%esp)
c0102c21:	e8 44 1a 00 00       	call   c010466a <_ZN6StringD1Ev>
c0102c26:	89 3c 24             	mov    %edi,(%esp)
c0102c29:	e8 d6 ee ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
c0102c2e:	89 3c 24             	mov    %edi,(%esp)
c0102c31:	e8 10 ef ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
    return nfp;
c0102c36:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c39:	8b 40 19             	mov    0x19(%eax),%eax
}
c0102c3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102c3f:	5b                   	pop    %ebx
c0102c40:	5e                   	pop    %esi
c0102c41:	5f                   	pop    %edi
c0102c42:	5d                   	pop    %ebp
c0102c43:	c3                   	ret    

c0102c44 <_ZN4FFMA10initMemMapEPN4ListIN3MMU4PageEE6DLNodeEj>:
void FFMA::initMemMap(List<MMU::Page>::DLNode *pArr, uint32_t num) {
c0102c44:	55                   	push   %ebp
c0102c45:	89 e5                	mov    %esp,%ebp
c0102c47:	57                   	push   %edi
c0102c48:	56                   	push   %esi
c0102c49:	53                   	push   %ebx
c0102c4a:	e8 66 df ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0102c4f:	81 c3 c1 97 01 00    	add    $0x197c1,%ebx
c0102c55:	81 ec 64 02 00 00    	sub    $0x264,%esp
    OStream out("\n\ninitMemMap:\n\n firstAd = ", "red");
c0102c5b:	8d b5 bc fd ff ff    	lea    -0x244(%ebp),%esi
c0102c61:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0102c67:	50                   	push   %eax
c0102c68:	56                   	push   %esi
c0102c69:	e8 e2 19 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102c6e:	8d 83 de 84 fe ff    	lea    -0x17b22(%ebx),%eax
c0102c74:	59                   	pop    %ecx
c0102c75:	5f                   	pop    %edi
c0102c76:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c0102c7c:	50                   	push   %eax
c0102c7d:	8d 85 b7 fd ff ff    	lea    -0x249(%ebp),%eax
c0102c83:	50                   	push   %eax
c0102c84:	89 85 a4 fd ff ff    	mov    %eax,-0x25c(%ebp)
c0102c8a:	e8 c1 19 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102c8f:	8b 85 a4 fd ff ff    	mov    -0x25c(%ebp),%eax
c0102c95:	83 c4 0c             	add    $0xc,%esp
c0102c98:	56                   	push   %esi
c0102c99:	50                   	push   %eax
c0102c9a:	57                   	push   %edi
c0102c9b:	e8 c6 ed ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0102ca0:	8b 85 a4 fd ff ff    	mov    -0x25c(%ebp),%eax
c0102ca6:	89 04 24             	mov    %eax,(%esp)
c0102ca9:	e8 bc 19 00 00       	call   c010466a <_ZN6StringD1Ev>
c0102cae:	89 34 24             	mov    %esi,(%esp)
c0102cb1:	e8 b4 19 00 00       	call   c010466a <_ZN6StringD1Ev>
    out.writeValue((uint32_t)pArr);
c0102cb6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102cb9:	89 85 a4 fd ff ff    	mov    %eax,-0x25c(%ebp)
c0102cbf:	89 85 bc fd ff ff    	mov    %eax,-0x244(%ebp)
c0102cc5:	58                   	pop    %eax
c0102cc6:	5a                   	pop    %edx
c0102cc7:	56                   	push   %esi
c0102cc8:	57                   	push   %edi
c0102cc9:	e8 66 ef ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
    out.write("\n num = ");
c0102cce:	8d 93 f9 84 fe ff    	lea    -0x17b07(%ebx),%edx
c0102cd4:	59                   	pop    %ecx
c0102cd5:	58                   	pop    %eax
c0102cd6:	52                   	push   %edx
c0102cd7:	56                   	push   %esi
c0102cd8:	e8 73 19 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102cdd:	58                   	pop    %eax
c0102cde:	5a                   	pop    %edx
c0102cdf:	56                   	push   %esi
c0102ce0:	57                   	push   %edi
c0102ce1:	e8 0a ef ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0102ce6:	89 34 24             	mov    %esi,(%esp)
c0102ce9:	e8 7c 19 00 00       	call   c010466a <_ZN6StringD1Ev>
    out.writeValue(num);
c0102cee:	8d 55 10             	lea    0x10(%ebp),%edx
c0102cf1:	59                   	pop    %ecx
c0102cf2:	58                   	pop    %eax
c0102cf3:	52                   	push   %edx
c0102cf4:	57                   	push   %edi
c0102cf5:	e8 3a ef ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
    out.write("\n");
c0102cfa:	58                   	pop    %eax
c0102cfb:	5a                   	pop    %edx
c0102cfc:	8d 93 13 83 fe ff    	lea    -0x17ced(%ebx),%edx
c0102d02:	52                   	push   %edx
c0102d03:	56                   	push   %esi
c0102d04:	e8 47 19 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0102d09:	59                   	pop    %ecx
c0102d0a:	58                   	pop    %eax
c0102d0b:	56                   	push   %esi
c0102d0c:	57                   	push   %edi
c0102d0d:	e8 de ee ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0102d12:	89 34 24             	mov    %esi,(%esp)
c0102d15:	e8 50 19 00 00       	call   c010466a <_ZN6StringD1Ev>
    out.flush();
c0102d1a:	89 3c 24             	mov    %edi,(%esp)
c0102d1d:	e8 e2 ed ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    for (uint32_t i = 0; i < num; i++) {    // init Page struct for the mem-area
c0102d22:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0102d25:	83 c4 10             	add    $0x10,%esp
c0102d28:	8b 85 a4 fd ff ff    	mov    -0x25c(%ebp),%eax
c0102d2e:	6b d1 11             	imul   $0x11,%ecx,%edx
c0102d31:	03 55 0c             	add    0xc(%ebp),%edx
c0102d34:	39 d0                	cmp    %edx,%eax
c0102d36:	74 16                	je     c0102d4e <_ZN4FFMA10initMemMapEPN4ListIN3MMU4PageEE6DLNodeEj+0x10a>
        pArr[i].data.ref = 0;
c0102d38:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
c0102d3e:	83 c0 11             	add    $0x11,%eax
        pArr[i].data.status = 0;
c0102d41:	c6 40 f3 00          	movb   $0x0,-0xd(%eax)
        pArr[i].data.property = 0;
c0102d45:	c7 40 f4 00 00 00 00 	movl   $0x0,-0xc(%eax)
    for (uint32_t i = 0; i < num; i++) {    // init Page struct for the mem-area
c0102d4c:	eb e6                	jmp    c0102d34 <_ZN4FFMA10initMemMapEPN4ListIN3MMU4PageEE6DLNodeEj+0xf0>
    pArr[0].data.property = num;
c0102d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
    MMU::setPageProperty(pArr[0].data);
c0102d51:	83 ec 0c             	sub    $0xc,%esp
    pArr[0].data.property = num;
c0102d54:	89 48 05             	mov    %ecx,0x5(%eax)
    MMU::setPageProperty(pArr[0].data);
c0102d57:	50                   	push   %eax
c0102d58:	e8 2d 17 00 00       	call   c010448a <_ZN3MMU15setPagePropertyERNS_4PageE>
    nfp += num;
c0102d5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0102d60:	8b 45 10             	mov    0x10(%ebp),%eax
c0102d63:	01 41 19             	add    %eax,0x19(%ecx)
    freeArea.addLNode(*pArr);
c0102d66:	58                   	pop    %eax
c0102d67:	89 c8                	mov    %ecx,%eax
c0102d69:	83 c0 09             	add    $0x9,%eax
c0102d6c:	5a                   	pop    %edx
c0102d6d:	ff 75 0c             	pushl  0xc(%ebp)
c0102d70:	50                   	push   %eax
c0102d71:	e8 f4 01 00 00       	call   c0102f6a <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE>
    OStream out("\n\ninitMemMap:\n\n firstAd = ", "red");
c0102d76:	89 3c 24             	mov    %edi,(%esp)
c0102d79:	e8 c8 ed ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
}
c0102d7e:	83 c4 10             	add    $0x10,%esp
c0102d81:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102d84:	5b                   	pop    %ebx
c0102d85:	5e                   	pop    %esi
c0102d86:	5f                   	pop    %edi
c0102d87:	5d                   	pop    %ebp
c0102d88:	c3                   	ret    
c0102d89:	90                   	nop

c0102d8a <_ZN4FFMA10allocPagesEj>:
List<MMU::Page>::DLNode * FFMA::allocPages(uint32_t n) {
c0102d8a:	55                   	push   %ebp
c0102d8b:	89 e5                	mov    %esp,%ebp
c0102d8d:	57                   	push   %edi
c0102d8e:	56                   	push   %esi
c0102d8f:	53                   	push   %ebx
c0102d90:	83 ec 1c             	sub    $0x1c,%esp
c0102d93:	8b 7d 08             	mov    0x8(%ebp),%edi
    if (n > nfp) {                                 // if n great than  number of free-page
c0102d96:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102d99:	e8 17 de ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0102d9e:	81 c3 72 96 01 00    	add    $0x19672,%ebx
c0102da4:	39 47 19             	cmp    %eax,0x19(%edi)
c0102da7:	73 04                	jae    c0102dad <_ZN4FFMA10allocPagesEj+0x23>
        return nullptr;
c0102da9:	31 f6                	xor    %esi,%esi
c0102dab:	eb 6b                	jmp    c0102e18 <_ZN4FFMA10allocPagesEj+0x8e>
    return p->data;
}

template <typename Object>
typename List<Object>::NodeIterator List<Object>::getNodeIterator() {
    it.setCurrentNode(headNode.first);
c0102dad:	8b 77 0d             	mov    0xd(%edi),%esi
                    currentNode = node;
c0102db0:	89 77 09             	mov    %esi,0x9(%edi)
                    if (!hasNext()) {
c0102db3:	85 f6                	test   %esi,%esi
c0102db5:	74 f2                	je     c0102da9 <_ZN4FFMA10allocPagesEj+0x1f>
        if (pnode->data.property >= n) {            // current continuous area[page num] is Ok
c0102db7:	8b 4e 05             	mov    0x5(%esi),%ecx
c0102dba:	3b 4d 0c             	cmp    0xc(%ebp),%ecx
                    currentNode = currentNode->next;
c0102dbd:	8b 56 0d             	mov    0xd(%esi),%edx
c0102dc0:	73 04                	jae    c0102dc6 <_ZN4FFMA10allocPagesEj+0x3c>
c0102dc2:	89 d6                	mov    %edx,%esi
c0102dc4:	eb ed                	jmp    c0102db3 <_ZN4FFMA10allocPagesEj+0x29>
        if (pnode->data.property > n) {             // need resolve continuous area ?
c0102dc6:	3b 4d 0c             	cmp    0xc(%ebp),%ecx
    auto it = freeArea.getNodeIterator();
c0102dc9:	8d 47 09             	lea    0x9(%edi),%eax
c0102dcc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (pnode->data.property > n) {             // need resolve continuous area ?
c0102dcf:	76 2b                	jbe    c0102dfc <_ZN4FFMA10allocPagesEj+0x72>
            List<MMU::Page>::DLNode *newNode = pnode + n;
c0102dd1:	6b 55 0c 11          	imul   $0x11,0xc(%ebp),%edx
            MMU::setPageProperty(newNode->data);
c0102dd5:	83 ec 0c             	sub    $0xc,%esp
            newNode->data.property = pnode->data.property - n;
c0102dd8:	2b 4d 0c             	sub    0xc(%ebp),%ecx
            List<MMU::Page>::DLNode *newNode = pnode + n;
c0102ddb:	01 f2                	add    %esi,%edx
            newNode->data.property = pnode->data.property - n;
c0102ddd:	89 4a 05             	mov    %ecx,0x5(%edx)
            MMU::setPageProperty(newNode->data);
c0102de0:	52                   	push   %edx
c0102de1:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0102de4:	e8 a1 16 00 00       	call   c010448a <_ZN3MMU15setPagePropertyERNS_4PageE>
            freeArea.insertLNode(pnode, newNode);   // insert new pageNode
c0102de9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102dec:	83 c4 0c             	add    $0xc,%esp
c0102def:	52                   	push   %edx
c0102df0:	56                   	push   %esi
c0102df1:	ff 75 e4             	pushl  -0x1c(%ebp)
c0102df4:	e8 b7 01 00 00       	call   c0102fb0 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_>
c0102df9:	83 c4 10             	add    $0x10,%esp
        freeArea.deleteLNode(pnode);
c0102dfc:	50                   	push   %eax
c0102dfd:	50                   	push   %eax
c0102dfe:	56                   	push   %esi
c0102dff:	ff 75 e4             	pushl  -0x1c(%ebp)
c0102e02:	e8 e5 01 00 00       	call   c0102fec <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE>
        nfp -= n;
c0102e07:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102e0a:	29 47 19             	sub    %eax,0x19(%edi)
        MMU::clearPageProperty(pnode->data);
c0102e0d:	89 34 24             	mov    %esi,(%esp)
c0102e10:	e8 81 16 00 00       	call   c0104496 <_ZN3MMU17clearPagePropertyERNS_4PageE>
c0102e15:	83 c4 10             	add    $0x10,%esp
}
c0102e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102e1b:	89 f0                	mov    %esi,%eax
c0102e1d:	5b                   	pop    %ebx
c0102e1e:	5e                   	pop    %esi
c0102e1f:	5f                   	pop    %edi
c0102e20:	5d                   	pop    %ebp
c0102e21:	c3                   	ret    

c0102e22 <_ZN4FFMA9freePagesEPvj>:
c0102e22:	55                   	push   %ebp
c0102e23:	89 e5                	mov    %esp,%ebp
c0102e25:	57                   	push   %edi
c0102e26:	56                   	push   %esi
c0102e27:	53                   	push   %ebx
c0102e28:	83 ec 1c             	sub    $0x1c,%esp
c0102e2b:	8b 7d 10             	mov    0x10(%ebp),%edi
c0102e2e:	e8 82 dd ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0102e33:	81 c3 dd 95 01 00    	add    $0x195dd,%ebx
c0102e39:	8b 75 0c             	mov    0xc(%ebp),%esi
c0102e3c:	8b 55 08             	mov    0x8(%ebp),%edx
c0102e3f:	6b cf 11             	imul   $0x11,%edi,%ecx
c0102e42:	89 f0                	mov    %esi,%eax
c0102e44:	01 f1                	add    %esi,%ecx
c0102e46:	39 c8                	cmp    %ecx,%eax
c0102e48:	74 10                	je     c0102e5a <_ZN4FFMA9freePagesEPvj+0x38>
c0102e4a:	c6 40 04 00          	movb   $0x0,0x4(%eax)
c0102e4e:	83 c0 11             	add    $0x11,%eax
c0102e51:	c7 40 ef 00 00 00 00 	movl   $0x0,-0x11(%eax)
c0102e58:	eb ec                	jmp    c0102e46 <_ZN4FFMA9freePagesEPvj+0x24>
c0102e5a:	83 ec 0c             	sub    $0xc,%esp
c0102e5d:	89 7e 05             	mov    %edi,0x5(%esi)
c0102e60:	56                   	push   %esi
c0102e61:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0102e64:	e8 21 16 00 00       	call   c010448a <_ZN3MMU15setPagePropertyERNS_4PageE>
c0102e69:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102e6c:	83 c4 10             	add    $0x10,%esp
c0102e6f:	8b 7a 0d             	mov    0xd(%edx),%edi
c0102e72:	8d 42 09             	lea    0x9(%edx),%eax
c0102e75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0102e78:	89 7a 09             	mov    %edi,0x9(%edx)
c0102e7b:	85 ff                	test   %edi,%edi
c0102e7d:	74 77                	je     c0102ef6 <_ZN4FFMA9freePagesEPvj+0xd4>
c0102e7f:	8b 47 0d             	mov    0xd(%edi),%eax
c0102e82:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102e85:	8b 47 05             	mov    0x5(%edi),%eax
c0102e88:	6b c8 11             	imul   $0x11,%eax,%ecx
c0102e8b:	01 f9                	add    %edi,%ecx
c0102e8d:	39 f1                	cmp    %esi,%ecx
c0102e8f:	75 27                	jne    c0102eb8 <_ZN4FFMA9freePagesEPvj+0x96>
c0102e91:	03 46 05             	add    0x5(%esi),%eax
c0102e94:	83 ec 0c             	sub    $0xc,%esp
c0102e97:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0102e9a:	89 47 05             	mov    %eax,0x5(%edi)
c0102e9d:	56                   	push   %esi
c0102e9e:	89 fe                	mov    %edi,%esi
c0102ea0:	e8 f1 15 00 00       	call   c0104496 <_ZN3MMU17clearPagePropertyERNS_4PageE>
c0102ea5:	59                   	pop    %ecx
c0102ea6:	5b                   	pop    %ebx
c0102ea7:	57                   	push   %edi
c0102ea8:	ff 75 e4             	pushl  -0x1c(%ebp)
c0102eab:	e8 3c 01 00 00       	call   c0102fec <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE>
c0102eb0:	83 c4 10             	add    $0x10,%esp
c0102eb3:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102eb6:	eb 3e                	jmp    c0102ef6 <_ZN4FFMA9freePagesEPvj+0xd4>
c0102eb8:	8b 4e 05             	mov    0x5(%esi),%ecx
c0102ebb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
c0102ebe:	6b c9 11             	imul   $0x11,%ecx,%ecx
c0102ec1:	01 f1                	add    %esi,%ecx
c0102ec3:	39 f9                	cmp    %edi,%ecx
c0102ec5:	74 05                	je     c0102ecc <_ZN4FFMA9freePagesEPvj+0xaa>
c0102ec7:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0102eca:	eb af                	jmp    c0102e7b <_ZN4FFMA9freePagesEPvj+0x59>
c0102ecc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c0102ecf:	83 ec 0c             	sub    $0xc,%esp
c0102ed2:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0102ed5:	01 c1                	add    %eax,%ecx
c0102ed7:	89 4e 05             	mov    %ecx,0x5(%esi)
c0102eda:	57                   	push   %edi
c0102edb:	e8 b6 15 00 00       	call   c0104496 <_ZN3MMU17clearPagePropertyERNS_4PageE>
c0102ee0:	58                   	pop    %eax
c0102ee1:	5a                   	pop    %edx
c0102ee2:	57                   	push   %edi
c0102ee3:	ff 75 e4             	pushl  -0x1c(%ebp)
c0102ee6:	e8 01 01 00 00       	call   c0102fec <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE>
c0102eeb:	83 c4 10             	add    $0x10,%esp
c0102eee:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0102ef1:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102ef4:	eb 85                	jmp    c0102e7b <_ZN4FFMA9freePagesEPvj+0x59>
c0102ef6:	8b 4a 0d             	mov    0xd(%edx),%ecx
c0102ef9:	89 4a 09             	mov    %ecx,0x9(%edx)
c0102efc:	89 c8                	mov    %ecx,%eax
c0102efe:	85 c0                	test   %eax,%eax
c0102f00:	74 0b                	je     c0102f0d <_ZN4FFMA9freePagesEPvj+0xeb>
c0102f02:	39 f0                	cmp    %esi,%eax
c0102f04:	8b 58 0d             	mov    0xd(%eax),%ebx
c0102f07:	73 42                	jae    c0102f4b <_ZN4FFMA9freePagesEPvj+0x129>
c0102f09:	89 d8                	mov    %ebx,%eax
c0102f0b:	eb f1                	jmp    c0102efe <_ZN4FFMA9freePagesEPvj+0xdc>
c0102f0d:	8b 42 15             	mov    0x15(%edx),%eax
c0102f10:	85 c0                	test   %eax,%eax
c0102f12:	75 06                	jne    c0102f1a <_ZN4FFMA9freePagesEPvj+0xf8>
c0102f14:	83 7a 11 00          	cmpl   $0x0,0x11(%edx)
c0102f18:	74 1c                	je     c0102f36 <_ZN4FFMA9freePagesEPvj+0x114>
c0102f1a:	40                   	inc    %eax
c0102f1b:	c7 46 09 00 00 00 00 	movl   $0x0,0x9(%esi)
c0102f22:	89 4e 0d             	mov    %ecx,0xd(%esi)
c0102f25:	89 71 09             	mov    %esi,0x9(%ecx)
c0102f28:	89 72 0d             	mov    %esi,0xd(%edx)
c0102f2b:	89 42 15             	mov    %eax,0x15(%edx)
c0102f2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102f31:	5b                   	pop    %ebx
c0102f32:	5e                   	pop    %esi
c0102f33:	5f                   	pop    %edi
c0102f34:	5d                   	pop    %ebp
c0102f35:	c3                   	ret    
c0102f36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102f39:	89 75 0c             	mov    %esi,0xc(%ebp)
c0102f3c:	89 45 08             	mov    %eax,0x8(%ebp)
c0102f3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102f42:	5b                   	pop    %ebx
c0102f43:	5e                   	pop    %esi
c0102f44:	5f                   	pop    %edi
c0102f45:	5d                   	pop    %ebp
c0102f46:	e9 1f 00 00 00       	jmp    c0102f6a <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE>
c0102f4b:	8b 40 09             	mov    0x9(%eax),%eax
c0102f4e:	85 c0                	test   %eax,%eax
c0102f50:	74 bb                	je     c0102f0d <_ZN4FFMA9freePagesEPvj+0xeb>
c0102f52:	89 45 0c             	mov    %eax,0xc(%ebp)
c0102f55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102f58:	89 75 10             	mov    %esi,0x10(%ebp)
c0102f5b:	89 45 08             	mov    %eax,0x8(%ebp)
c0102f5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0102f61:	5b                   	pop    %ebx
c0102f62:	5e                   	pop    %esi
c0102f63:	5f                   	pop    %edi
c0102f64:	5d                   	pop    %ebp
c0102f65:	e9 46 00 00 00       	jmp    c0102fb0 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_>

c0102f6a <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE>:
void List<Object>::addLNode(DLNode &node) {
c0102f6a:	55                   	push   %ebp
c0102f6b:	89 e5                	mov    %esp,%ebp
c0102f6d:	8b 55 08             	mov    0x8(%ebp),%edx
c0102f70:	53                   	push   %ebx
c0102f71:	8b 45 0c             	mov    0xc(%ebp),%eax
    return (headNode.eNum == 0 && headNode.last == nullptr);
c0102f74:	8b 4a 0c             	mov    0xc(%edx),%ecx
c0102f77:	8b 5a 08             	mov    0x8(%edx),%ebx
c0102f7a:	85 c9                	test   %ecx,%ecx
c0102f7c:	75 1a                	jne    c0102f98 <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE+0x2e>
c0102f7e:	85 db                	test   %ebx,%ebx
c0102f80:	75 16                	jne    c0102f98 <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE+0x2e>
        headNode.last = &node;
c0102f82:	89 42 08             	mov    %eax,0x8(%edx)
        headNode.first = &node;
c0102f85:	89 42 04             	mov    %eax,0x4(%edx)
        node.pre = nullptr;
c0102f88:	c7 40 09 00 00 00 00 	movl   $0x0,0x9(%eax)
        node.next = nullptr;
c0102f8f:	c7 40 0d 00 00 00 00 	movl   $0x0,0xd(%eax)
c0102f96:	eb 10                	jmp    c0102fa8 <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE+0x3e>
        p->next = &node;
c0102f98:	89 43 0d             	mov    %eax,0xd(%ebx)
        node.pre = p;
c0102f9b:	89 58 09             	mov    %ebx,0x9(%eax)
        node.next = nullptr;
c0102f9e:	c7 40 0d 00 00 00 00 	movl   $0x0,0xd(%eax)
        headNode.last = &node;           // update 
c0102fa5:	89 42 08             	mov    %eax,0x8(%edx)
    headNode.eNum++;
c0102fa8:	41                   	inc    %ecx
c0102fa9:	89 4a 0c             	mov    %ecx,0xc(%edx)
}
c0102fac:	5b                   	pop    %ebx
c0102fad:	5d                   	pop    %ebp
c0102fae:	c3                   	ret    
c0102faf:	90                   	nop

c0102fb0 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_>:
void List<Object>::insertLNode(DLNode *node1, DLNode *node2) {
c0102fb0:	55                   	push   %ebp
c0102fb1:	89 e5                	mov    %esp,%ebp
c0102fb3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102fb6:	53                   	push   %ebx
c0102fb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0102fba:	8b 55 10             	mov    0x10(%ebp),%edx
    if (node1 == nullptr) {
c0102fbd:	85 c0                	test   %eax,%eax
c0102fbf:	74 27                	je     c0102fe8 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_+0x38>
    if (node1->next == nullptr) {
c0102fc1:	8b 58 0d             	mov    0xd(%eax),%ebx
c0102fc4:	85 db                	test   %ebx,%ebx
c0102fc6:	75 0a                	jne    c0102fd2 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_+0x22>
}
c0102fc8:	5b                   	pop    %ebx
        addLNode(*node2);
c0102fc9:	89 55 0c             	mov    %edx,0xc(%ebp)
}
c0102fcc:	5d                   	pop    %ebp
        addLNode(*node2);
c0102fcd:	e9 98 ff ff ff       	jmp    c0102f6a <_ZN4ListIN3MMU4PageEE8addLNodeERNS2_6DLNodeE>
        node2->next = node1->next;
c0102fd2:	89 5a 0d             	mov    %ebx,0xd(%edx)
        if (node1->next != nullptr) {
c0102fd5:	8b 58 0d             	mov    0xd(%eax),%ebx
        node2->pre = node1;
c0102fd8:	89 42 09             	mov    %eax,0x9(%edx)
        if (node1->next != nullptr) {
c0102fdb:	85 db                	test   %ebx,%ebx
c0102fdd:	74 03                	je     c0102fe2 <_ZN4ListIN3MMU4PageEE11insertLNodeEPNS2_6DLNodeES4_+0x32>
            node1->next->pre = node2;
c0102fdf:	89 53 09             	mov    %edx,0x9(%ebx)
        node1->next = node2;
c0102fe2:	89 50 0d             	mov    %edx,0xd(%eax)
        headNode.eNum++;
c0102fe5:	ff 41 0c             	incl   0xc(%ecx)
}
c0102fe8:	5b                   	pop    %ebx
c0102fe9:	5d                   	pop    %ebp
c0102fea:	c3                   	ret    
c0102feb:	90                   	nop

c0102fec <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE>:
void List<Object>::deleteLNode(DLNode *node) {
c0102fec:	55                   	push   %ebp
c0102fed:	89 e5                	mov    %esp,%ebp
c0102fef:	8b 55 08             	mov    0x8(%ebp),%edx
c0102ff2:	53                   	push   %ebx
c0102ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
    if (headNode.first == node) {       // is first Node
c0102ff6:	39 42 04             	cmp    %eax,0x4(%edx)
c0102ff9:	75 1c                	jne    c0103017 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x2b>
        headNode.first = node->next;
c0102ffb:	8b 48 0d             	mov    0xd(%eax),%ecx
        if (headNode.first == nullptr) {
c0102ffe:	85 c9                	test   %ecx,%ecx
        headNode.first = node->next;
c0103000:	89 4a 04             	mov    %ecx,0x4(%edx)
        if (headNode.first == nullptr) {
c0103003:	75 09                	jne    c010300e <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x22>
            headNode.last = nullptr;
c0103005:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
c010300c:	eb 29                	jmp    c0103037 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x4b>
            headNode.first->pre = nullptr;
c010300e:	c7 41 09 00 00 00 00 	movl   $0x0,0x9(%ecx)
c0103015:	eb 20                	jmp    c0103037 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x4b>
    } else if (headNode.last == node) { // is trail Node[can't only a node]
c0103017:	39 42 08             	cmp    %eax,0x8(%edx)
c010301a:	8b 48 09             	mov    0x9(%eax),%ecx
c010301d:	75 0c                	jne    c010302b <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x3f>
        headNode.last = node->pre;
c010301f:	89 4a 08             	mov    %ecx,0x8(%edx)
        headNode.last->next = nullptr;
c0103022:	c7 41 0d 00 00 00 00 	movl   $0x0,0xd(%ecx)
c0103029:	eb 0c                	jmp    c0103037 <_ZN4ListIN3MMU4PageEE11deleteLNodeEPNS2_6DLNodeE+0x4b>
        node->next->pre = node->pre;
c010302b:	8b 58 0d             	mov    0xd(%eax),%ebx
c010302e:	89 4b 09             	mov    %ecx,0x9(%ebx)
        node->pre->next = node->next;
c0103031:	8b 48 09             	mov    0x9(%eax),%ecx
c0103034:	89 59 0d             	mov    %ebx,0xd(%ecx)
    node->next = node->pre = nullptr;
c0103037:	c7 40 09 00 00 00 00 	movl   $0x0,0x9(%eax)
c010303e:	c7 40 0d 00 00 00 00 	movl   $0x0,0xd(%eax)
    headNode.eNum--;
c0103045:	ff 4a 0c             	decl   0xc(%edx)
}
c0103048:	5b                   	pop    %ebx
c0103049:	5d                   	pop    %ebp
c010304a:	c3                   	ret    
c010304b:	90                   	nop

c010304c <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>:
void VMM::vmmInit() {
    DEBUGPRINT("vmmInit");
    checkVmm();
}

List<VMM::VMA>::DLNode * VMM::findVma(List<MM>::DLNode *mm, uptr32_t addr) {
c010304c:	55                   	push   %ebp
c010304d:	89 e5                	mov    %esp,%ebp
c010304f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103052:	53                   	push   %ebx
c0103053:	8b 4d 10             	mov    0x10(%ebp),%ecx

    List<VMA>::DLNode *vma = nullptr;
    if (mm != nullptr) {
c0103056:	85 d2                	test   %edx,%edx
c0103058:	75 04                	jne    c010305e <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x12>
    List<VMA>::DLNode *vma = nullptr;
c010305a:	31 c0                	xor    %eax,%eax
c010305c:	eb 2e                	jmp    c010308c <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x40>
        vma = mm->data.mmap_cache;
c010305e:	8b 42 10             	mov    0x10(%edx),%eax
        if (!(vma != nullptr && vma->data.vm_start <= addr && vma->data.vm_end > addr)) {
c0103061:	85 c0                	test   %eax,%eax
c0103063:	74 0a                	je     c010306f <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x23>
c0103065:	39 48 04             	cmp    %ecx,0x4(%eax)
c0103068:	77 05                	ja     c010306f <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x23>
c010306a:	39 48 08             	cmp    %ecx,0x8(%eax)
c010306d:	77 1a                	ja     c0103089 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x3d>
    it.setCurrentNode(headNode.first);
c010306f:	8b 42 04             	mov    0x4(%edx),%eax
                    currentNode = node;
c0103072:	89 02                	mov    %eax,(%edx)
                    if (!hasNext()) {
c0103074:	85 c0                	test   %eax,%eax
c0103076:	74 e2                	je     c010305a <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0xe>
                bool found = 0;
                auto it = mm->data.vmaList.getNodeIterator();
                while ((vma = it.nextLNode()) != nullptr) {
                    if (vma->data.vm_start <= addr && addr < vma->data.vm_end) {
c0103078:	39 48 04             	cmp    %ecx,0x4(%eax)
                    currentNode = currentNode->next;
c010307b:	8b 58 14             	mov    0x14(%eax),%ebx
c010307e:	76 04                	jbe    c0103084 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x38>
List<VMM::VMA>::DLNode * VMM::findVma(List<MM>::DLNode *mm, uptr32_t addr) {
c0103080:	89 d8                	mov    %ebx,%eax
c0103082:	eb f0                	jmp    c0103074 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x28>
                    if (vma->data.vm_start <= addr && addr < vma->data.vm_end) {
c0103084:	39 48 08             	cmp    %ecx,0x8(%eax)
c0103087:	76 f7                	jbe    c0103080 <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj+0x34>
                if (!found) {
                    vma = nullptr;
                }
        }
        if (vma != nullptr) {
            mm->data.mmap_cache = vma;
c0103089:	89 42 10             	mov    %eax,0x10(%edx)
        }
    }
    return vma;

}
c010308c:	5b                   	pop    %ebx
c010308d:	5d                   	pop    %ebp
c010308e:	c3                   	ret    
c010308f:	90                   	nop

c0103090 <_ZN3VMM9vmaCreateEjjj>:

List<VMM::VMA>::DLNode * VMM::vmaCreate(uptr32_t vmStart, uptr32_t vmEnd, uint32_t vmFlags) {
c0103090:	55                   	push   %ebp
c0103091:	89 e5                	mov    %esp,%ebp
c0103093:	53                   	push   %ebx
c0103094:	e8 1c db ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c0103099:	81 c3 77 93 01 00    	add    $0x19377,%ebx
c010309f:	83 ec 0c             	sub    $0xc,%esp
    auto vma = (List<VMA>::DLNode *)(kernel::pmm.kmalloc(sizeof(List<VMA>::DLNode)));
c01030a2:	6a 18                	push   $0x18
c01030a4:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
c01030aa:	e8 e3 f6 ff ff       	call   c0102792 <_ZN5PhyMM7kmallocEj>

    if (vma != nullptr) {
c01030af:	83 c4 10             	add    $0x10,%esp
c01030b2:	85 c0                	test   %eax,%eax
c01030b4:	74 12                	je     c01030c8 <_ZN3VMM9vmaCreateEjjj+0x38>
        vma->data.vm_start = vmStart;
c01030b6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01030b9:	89 50 04             	mov    %edx,0x4(%eax)
        vma->data.vm_end = vmEnd;
c01030bc:	8b 55 10             	mov    0x10(%ebp),%edx
c01030bf:	89 50 08             	mov    %edx,0x8(%eax)
        vma->data.vm_flags = vmFlags;
c01030c2:	8b 55 14             	mov    0x14(%ebp),%edx
c01030c5:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    
    return vma;
}
c01030c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01030cb:	c9                   	leave  
c01030cc:	c3                   	ret    
c01030cd:	90                   	nop

c01030ce <_ZN3VMM8mmCreateEv>:
    } else {
        mm->data.vmaList.insertLNode(preVma, vma);
    }
}

List<VMM::MM>::DLNode * VMM::mmCreate() {
c01030ce:	55                   	push   %ebp
c01030cf:	89 e5                	mov    %esp,%ebp
c01030d1:	53                   	push   %ebx
c01030d2:	e8 de da ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c01030d7:	81 c3 39 93 01 00    	add    $0x19339,%ebx
c01030dd:	83 ec 0c             	sub    $0xc,%esp
    auto mm = (List<MM>::DLNode *)(kernel::pmm.kmalloc(sizeof(List<MM>::DLNode)));
c01030e0:	6a 24                	push   $0x24
c01030e2:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
c01030e8:	e8 a5 f6 ff ff       	call   c0102792 <_ZN5PhyMM7kmallocEj>

    if (mm != nullptr) {
c01030ed:	83 c4 10             	add    $0x10,%esp
c01030f0:	85 c0                	test   %eax,%eax
c01030f2:	74 23                	je     c0103117 <_ZN3VMM8mmCreateEv+0x49>
        mm->next = mm->pre = nullptr;
c01030f4:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
c01030fb:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)
        mm->data.mmap_cache = nullptr;
c0103102:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        mm->data.pgdir = nullptr;
c0103109:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        //mm->data.map_count = 0;

        if (false) while(1);//swap_init_mm(mm);
        else mm->data.sm_priv = nullptr;
c0103110:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
    }
    return mm;
}
c0103117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010311a:	c9                   	leave  
c010311b:	c3                   	ret    

c010311c <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE>:

void VMM::mmDestroy(List<MM>::DLNode *mm) {
c010311c:	55                   	push   %ebp
c010311d:	89 e5                	mov    %esp,%ebp
c010311f:	57                   	push   %edi
c0103120:	56                   	push   %esi
c0103121:	53                   	push   %ebx
c0103122:	83 ec 1c             	sub    $0x1c,%esp
c0103125:	e8 8b da ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c010312a:	81 c3 e6 92 01 00    	add    $0x192e6,%ebx
c0103130:	8b 75 0c             	mov    0xc(%ebp),%esi
    it.setCurrentNode(headNode.first);
c0103133:	8b 46 04             	mov    0x4(%esi),%eax
c0103136:	c7 c2 20 f0 11 c0    	mov    $0xc011f020,%edx
                    currentNode = node;
c010313c:	89 06                	mov    %eax,(%esi)
                    if (!hasNext()) {
c010313e:	85 c0                	test   %eax,%eax
c0103140:	75 12                	jne    c0103154 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x38>
    List<VMA>::DLNode *vma;
    while ((vma = it.nextLNode()) != nullptr) {
        mm->data.vmaList.deleteLNode(vma);
        kernel::pmm.kfree(vma, sizeof(List<VMA>::DLNode));  //kfree vma        
    }
    kernel::pmm.kfree(mm, sizeof(List<MM>::DLNode));        //kfree mm
c0103142:	57                   	push   %edi
c0103143:	6a 24                	push   $0x24
c0103145:	56                   	push   %esi
c0103146:	52                   	push   %edx
c0103147:	e8 d8 f7 ff ff       	call   c0102924 <_ZN5PhyMM5kfreeEPvj>
    mm = nullptr;
}
c010314c:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010314f:	5b                   	pop    %ebx
c0103150:	5e                   	pop    %esi
c0103151:	5f                   	pop    %edi
c0103152:	5d                   	pop    %ebp
c0103153:	c3                   	ret    
    if (headNode.first == node) {       // is first Node
c0103154:	3b 46 04             	cmp    0x4(%esi),%eax
                    currentNode = currentNode->next;
c0103157:	8b 78 14             	mov    0x14(%eax),%edi
    if (headNode.first == node) {       // is first Node
c010315a:	75 19                	jne    c0103175 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x59>
        if (headNode.first == nullptr) {
c010315c:	85 ff                	test   %edi,%edi
        headNode.first = node->next;
c010315e:	89 7e 04             	mov    %edi,0x4(%esi)
        if (headNode.first == nullptr) {
c0103161:	75 09                	jne    c010316c <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x50>
            headNode.last = nullptr;
c0103163:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
c010316a:	eb 26                	jmp    c0103192 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x76>
            headNode.first->pre = nullptr;
c010316c:	c7 47 10 00 00 00 00 	movl   $0x0,0x10(%edi)
c0103173:	eb 1d                	jmp    c0103192 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x76>
    } else if (headNode.last == node) { // is trail Node[can't only a node]
c0103175:	3b 46 08             	cmp    0x8(%esi),%eax
c0103178:	8b 48 10             	mov    0x10(%eax),%ecx
c010317b:	75 0c                	jne    c0103189 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x6d>
        headNode.last = node->pre;
c010317d:	89 4e 08             	mov    %ecx,0x8(%esi)
        headNode.last->next = nullptr;
c0103180:	c7 41 14 00 00 00 00 	movl   $0x0,0x14(%ecx)
c0103187:	eb 09                	jmp    c0103192 <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x76>
        node->next->pre = node->pre;
c0103189:	89 4f 10             	mov    %ecx,0x10(%edi)
        node->pre->next = node->next;
c010318c:	8b 48 10             	mov    0x10(%eax),%ecx
c010318f:	89 79 14             	mov    %edi,0x14(%ecx)
    node->next = node->pre = nullptr;
c0103192:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
c0103199:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    headNode.eNum--;
c01031a0:	ff 4e 0c             	decl   0xc(%esi)
        kernel::pmm.kfree(vma, sizeof(List<VMA>::DLNode));  //kfree vma        
c01031a3:	51                   	push   %ecx
c01031a4:	6a 18                	push   $0x18
c01031a6:	50                   	push   %eax
c01031a7:	52                   	push   %edx
c01031a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01031ab:	e8 74 f7 ff ff       	call   c0102924 <_ZN5PhyMM5kfreeEPvj>
    while ((vma = it.nextLNode()) != nullptr) {
c01031b0:	83 c4 10             	add    $0x10,%esp
                    currentNode = currentNode->next;
c01031b3:	89 f8                	mov    %edi,%eax
c01031b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01031b8:	eb 84                	jmp    c010313e <_ZN3VMM9mmDestroyEPN4ListINS_2MMEE6DLNodeE+0x22>

c01031ba <_ZN3VMM11doPageFaultEPN4ListINS_2MMEE6DLNodeEjj>:

uint32_t VMM::doPageFault(List<MM>::DLNode *mm, uint32_t errorCode, uptr32_t addr) {
c01031ba:	55                   	push   %ebp
    return 0;
}
c01031bb:	31 c0                	xor    %eax,%eax
uint32_t VMM::doPageFault(List<MM>::DLNode *mm, uint32_t errorCode, uptr32_t addr) {
c01031bd:	89 e5                	mov    %esp,%ebp
}
c01031bf:	5d                   	pop    %ebp
c01031c0:	c3                   	ret    
c01031c1:	90                   	nop

c01031c2 <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_>:

    out.write("check_vma_struct() succeeded!\n");
}

// check if vma1 overlaps vma2 ?
void VMM::checkVamOverlap(List<VMA>::DLNode *prev, List<VMA>::DLNode *next) {
c01031c2:	55                   	push   %ebp
c01031c3:	89 e5                	mov    %esp,%ebp
c01031c5:	57                   	push   %edi
c01031c6:	56                   	push   %esi
c01031c7:	53                   	push   %ebx
c01031c8:	81 ec 4c 02 00 00    	sub    $0x24c,%esp
c01031ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01031d1:	e8 df d9 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c01031d6:	81 c3 3a 92 01 00    	add    $0x1923a,%ebx
    assert(prev->data.vm_start < prev->data.vm_end);
c01031dc:	8b 48 08             	mov    0x8(%eax),%ecx
c01031df:	39 48 04             	cmp    %ecx,0x4(%eax)
c01031e2:	0f 82 9e 00 00 00    	jb     c0103286 <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_+0xc4>
c01031e8:	51                   	push   %ecx
c01031e9:	51                   	push   %ecx
c01031ea:	8d 93 15 83 fe ff    	lea    -0x17ceb(%ebx),%edx
c01031f0:	52                   	push   %edx
c01031f1:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c01031f7:	56                   	push   %esi
c01031f8:	89 85 b0 fd ff ff    	mov    %eax,-0x250(%ebp)
c01031fe:	e8 4d 14 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103203:	8d 93 1f 83 fe ff    	lea    -0x17ce1(%ebx),%edx
c0103209:	5f                   	pop    %edi
c010320a:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c0103210:	58                   	pop    %eax
c0103211:	52                   	push   %edx
c0103212:	8d 95 b8 fd ff ff    	lea    -0x248(%ebp),%edx
c0103218:	52                   	push   %edx
c0103219:	89 95 b4 fd ff ff    	mov    %edx,-0x24c(%ebp)
c010321f:	e8 2c 14 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103224:	8b 95 b4 fd ff ff    	mov    -0x24c(%ebp),%edx
c010322a:	83 c4 0c             	add    $0xc,%esp
c010322d:	56                   	push   %esi
c010322e:	52                   	push   %edx
c010322f:	57                   	push   %edi
c0103230:	e8 31 e8 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0103235:	8b 95 b4 fd ff ff    	mov    -0x24c(%ebp),%edx
c010323b:	89 14 24             	mov    %edx,(%esp)
c010323e:	e8 27 14 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103243:	89 34 24             	mov    %esi,(%esp)
c0103246:	e8 1f 14 00 00       	call   c010466a <_ZN6StringD1Ev>
c010324b:	58                   	pop    %eax
c010324c:	5a                   	pop    %edx
c010324d:	8d 93 02 85 fe ff    	lea    -0x17afe(%ebx),%edx
c0103253:	52                   	push   %edx
c0103254:	56                   	push   %esi
c0103255:	e8 f6 13 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010325a:	59                   	pop    %ecx
c010325b:	58                   	pop    %eax
c010325c:	56                   	push   %esi
c010325d:	57                   	push   %edi
c010325e:	e8 8d e9 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0103263:	89 34 24             	mov    %esi,(%esp)
c0103266:	e8 ff 13 00 00       	call   c010466a <_ZN6StringD1Ev>
c010326b:	89 3c 24             	mov    %edi,(%esp)
c010326e:	e8 91 e8 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103273:	fa                   	cli    
    asm volatile ("hlt");
c0103274:	f4                   	hlt    
c0103275:	89 3c 24             	mov    %edi,(%esp)
c0103278:	e8 c9 e8 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c010327d:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c0103283:	83 c4 10             	add    $0x10,%esp
    assert(prev->data.vm_end <= next->data.vm_start);
c0103286:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0103289:	8b 49 04             	mov    0x4(%ecx),%ecx
c010328c:	39 48 08             	cmp    %ecx,0x8(%eax)
c010328f:	0f 86 92 00 00 00    	jbe    c0103327 <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_+0x165>
c0103295:	50                   	push   %eax
c0103296:	50                   	push   %eax
c0103297:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c010329d:	50                   	push   %eax
c010329e:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c01032a4:	56                   	push   %esi
c01032a5:	e8 a6 13 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01032aa:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c01032b0:	58                   	pop    %eax
c01032b1:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c01032b7:	5a                   	pop    %edx
c01032b8:	50                   	push   %eax
c01032b9:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c01032bf:	50                   	push   %eax
c01032c0:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c01032c6:	e8 85 13 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01032cb:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c01032d1:	83 c4 0c             	add    $0xc,%esp
c01032d4:	56                   	push   %esi
c01032d5:	50                   	push   %eax
c01032d6:	57                   	push   %edi
c01032d7:	e8 8a e7 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c01032dc:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c01032e2:	89 04 24             	mov    %eax,(%esp)
c01032e5:	e8 80 13 00 00       	call   c010466a <_ZN6StringD1Ev>
c01032ea:	89 34 24             	mov    %esi,(%esp)
c01032ed:	e8 78 13 00 00       	call   c010466a <_ZN6StringD1Ev>
c01032f2:	59                   	pop    %ecx
c01032f3:	58                   	pop    %eax
c01032f4:	8d 83 2a 85 fe ff    	lea    -0x17ad6(%ebx),%eax
c01032fa:	50                   	push   %eax
c01032fb:	56                   	push   %esi
c01032fc:	e8 4f 13 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103301:	58                   	pop    %eax
c0103302:	5a                   	pop    %edx
c0103303:	56                   	push   %esi
c0103304:	57                   	push   %edi
c0103305:	e8 e6 e8 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c010330a:	89 34 24             	mov    %esi,(%esp)
c010330d:	e8 58 13 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103312:	89 3c 24             	mov    %edi,(%esp)
c0103315:	e8 ea e7 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c010331a:	fa                   	cli    
    asm volatile ("hlt");
c010331b:	f4                   	hlt    
c010331c:	89 3c 24             	mov    %edi,(%esp)
c010331f:	e8 22 e8 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c0103324:	83 c4 10             	add    $0x10,%esp
    assert(next->data.vm_start < next->data.vm_end);
c0103327:	8b 45 10             	mov    0x10(%ebp),%eax
c010332a:	8b 48 08             	mov    0x8(%eax),%ecx
c010332d:	39 48 04             	cmp    %ecx,0x4(%eax)
c0103330:	0f 82 92 00 00 00    	jb     c01033c8 <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_+0x206>
c0103336:	50                   	push   %eax
c0103337:	50                   	push   %eax
c0103338:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c010333e:	50                   	push   %eax
c010333f:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c0103345:	56                   	push   %esi
c0103346:	e8 05 13 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010334b:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c0103351:	5a                   	pop    %edx
c0103352:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c0103358:	59                   	pop    %ecx
c0103359:	50                   	push   %eax
c010335a:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c0103360:	50                   	push   %eax
c0103361:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c0103367:	e8 e4 12 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010336c:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0103372:	83 c4 0c             	add    $0xc,%esp
c0103375:	56                   	push   %esi
c0103376:	50                   	push   %eax
c0103377:	57                   	push   %edi
c0103378:	e8 e9 e6 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c010337d:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0103383:	89 04 24             	mov    %eax,(%esp)
c0103386:	e8 df 12 00 00       	call   c010466a <_ZN6StringD1Ev>
c010338b:	89 34 24             	mov    %esi,(%esp)
c010338e:	e8 d7 12 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103393:	58                   	pop    %eax
c0103394:	8d 83 53 85 fe ff    	lea    -0x17aad(%ebx),%eax
c010339a:	5a                   	pop    %edx
c010339b:	50                   	push   %eax
c010339c:	56                   	push   %esi
c010339d:	e8 ae 12 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01033a2:	59                   	pop    %ecx
c01033a3:	58                   	pop    %eax
c01033a4:	56                   	push   %esi
c01033a5:	57                   	push   %edi
c01033a6:	e8 45 e8 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c01033ab:	89 34 24             	mov    %esi,(%esp)
c01033ae:	e8 b7 12 00 00       	call   c010466a <_ZN6StringD1Ev>
c01033b3:	89 3c 24             	mov    %edi,(%esp)
c01033b6:	e8 49 e7 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01033bb:	fa                   	cli    
    asm volatile ("hlt");
c01033bc:	f4                   	hlt    
c01033bd:	89 3c 24             	mov    %edi,(%esp)
c01033c0:	e8 81 e7 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c01033c5:	83 c4 10             	add    $0x10,%esp
c01033c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01033cb:	5b                   	pop    %ebx
c01033cc:	5e                   	pop    %esi
c01033cd:	5f                   	pop    %edi
c01033ce:	5d                   	pop    %ebp
c01033cf:	c3                   	ret    

c01033d0 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE>:
void VMM::insertVma(List<MM>::DLNode *mm, List<VMA>::DLNode *vma) {
c01033d0:	55                   	push   %ebp
c01033d1:	89 e5                	mov    %esp,%ebp
c01033d3:	57                   	push   %edi
c01033d4:	56                   	push   %esi
c01033d5:	53                   	push   %ebx
c01033d6:	81 ec 4c 02 00 00    	sub    $0x24c,%esp
c01033dc:	8b 45 10             	mov    0x10(%ebp),%eax
c01033df:	e8 d1 d7 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c01033e4:	81 c3 2c 90 01 00    	add    $0x1902c,%ebx
c01033ea:	8b 7d 0c             	mov    0xc(%ebp),%edi
    assert(vma->data.vm_start < vma->data.vm_end);
c01033ed:	8b 50 08             	mov    0x8(%eax),%edx
c01033f0:	39 50 04             	cmp    %edx,0x4(%eax)
c01033f3:	0f 82 b7 00 00 00    	jb     c01034b0 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0xe0>
c01033f9:	51                   	push   %ecx
c01033fa:	51                   	push   %ecx
c01033fb:	8d 8b 15 83 fe ff    	lea    -0x17ceb(%ebx),%ecx
c0103401:	51                   	push   %ecx
c0103402:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c0103408:	56                   	push   %esi
c0103409:	89 85 ac fd ff ff    	mov    %eax,-0x254(%ebp)
c010340f:	e8 3c 12 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103414:	8d 8b 1f 83 fe ff    	lea    -0x17ce1(%ebx),%ecx
c010341a:	58                   	pop    %eax
c010341b:	5a                   	pop    %edx
c010341c:	51                   	push   %ecx
c010341d:	8d 8d b8 fd ff ff    	lea    -0x248(%ebp),%ecx
c0103423:	51                   	push   %ecx
c0103424:	89 8d b4 fd ff ff    	mov    %ecx,-0x24c(%ebp)
c010342a:	e8 21 12 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010342f:	8b 8d b4 fd ff ff    	mov    -0x24c(%ebp),%ecx
c0103435:	83 c4 0c             	add    $0xc,%esp
c0103438:	56                   	push   %esi
c0103439:	8d 85 c2 fd ff ff    	lea    -0x23e(%ebp),%eax
c010343f:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c0103445:	51                   	push   %ecx
c0103446:	50                   	push   %eax
c0103447:	89 8d b0 fd ff ff    	mov    %ecx,-0x250(%ebp)
c010344d:	e8 14 e6 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0103452:	8b 8d b0 fd ff ff    	mov    -0x250(%ebp),%ecx
c0103458:	89 0c 24             	mov    %ecx,(%esp)
c010345b:	e8 0a 12 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103460:	89 34 24             	mov    %esi,(%esp)
c0103463:	e8 02 12 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103468:	59                   	pop    %ecx
c0103469:	8d 8b 7b 85 fe ff    	lea    -0x17a85(%ebx),%ecx
c010346f:	58                   	pop    %eax
c0103470:	51                   	push   %ecx
c0103471:	56                   	push   %esi
c0103472:	e8 d9 11 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103477:	58                   	pop    %eax
c0103478:	5a                   	pop    %edx
c0103479:	56                   	push   %esi
c010347a:	ff b5 b4 fd ff ff    	pushl  -0x24c(%ebp)
c0103480:	e8 6b e7 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0103485:	89 34 24             	mov    %esi,(%esp)
c0103488:	e8 dd 11 00 00       	call   c010466a <_ZN6StringD1Ev>
c010348d:	59                   	pop    %ecx
c010348e:	ff b5 b4 fd ff ff    	pushl  -0x24c(%ebp)
c0103494:	e8 6b e6 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103499:	fa                   	cli    
    asm volatile ("hlt");
c010349a:	f4                   	hlt    
c010349b:	5e                   	pop    %esi
c010349c:	ff b5 b4 fd ff ff    	pushl  -0x24c(%ebp)
c01034a2:	e8 9f e6 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c01034a7:	8b 85 ac fd ff ff    	mov    -0x254(%ebp),%eax
c01034ad:	83 c4 10             	add    $0x10,%esp
    it.setCurrentNode(headNode.first);
c01034b0:	8b 5f 04             	mov    0x4(%edi),%ebx
    decltype(vma) vmaNode, preVma = nullptr;
c01034b3:	31 f6                	xor    %esi,%esi
                    currentNode = node;
c01034b5:	89 1f                	mov    %ebx,(%edi)
                    if (!hasNext()) {
c01034b7:	85 db                	test   %ebx,%ebx
c01034b9:	0f 84 94 00 00 00    	je     c0103553 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x183>
        if (vmaNode->data.vm_start > vma->data.vm_start) {
c01034bf:	8b 50 04             	mov    0x4(%eax),%edx
c01034c2:	39 53 04             	cmp    %edx,0x4(%ebx)
                    currentNode = currentNode->next;
c01034c5:	8b 4b 14             	mov    0x14(%ebx),%ecx
c01034c8:	77 06                	ja     c01034d0 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x100>
c01034ca:	89 de                	mov    %ebx,%esi
c01034cc:	89 cb                	mov    %ecx,%ebx
c01034ce:	eb e7                	jmp    c01034b7 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0xe7>
    if (preVma != nullptr) {    // pre-note
c01034d0:	85 f6                	test   %esi,%esi
c01034d2:	74 1a                	je     c01034ee <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x11e>
        checkVamOverlap(preVma, vma);
c01034d4:	52                   	push   %edx
c01034d5:	50                   	push   %eax
c01034d6:	56                   	push   %esi
c01034d7:	ff 75 08             	pushl  0x8(%ebp)
c01034da:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c01034e0:	e8 dd fc ff ff       	call   c01031c2 <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_>
c01034e5:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c01034eb:	83 c4 10             	add    $0x10,%esp
        checkVamOverlap(vma, vmaNode);
c01034ee:	51                   	push   %ecx
c01034ef:	53                   	push   %ebx
c01034f0:	50                   	push   %eax
c01034f1:	ff 75 08             	pushl  0x8(%ebp)
c01034f4:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c01034fa:	e8 c3 fc ff ff       	call   c01031c2 <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_>
    vma->data.vm_mm = mm;       // pointer father-MM
c01034ff:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
    if (preVma != nullptr) {
c0103505:	83 c4 10             	add    $0x10,%esp
c0103508:	85 f6                	test   %esi,%esi
    vma->data.vm_mm = mm;       // pointer father-MM
c010350a:	89 38                	mov    %edi,(%eax)
    if (preVma != nullptr) {
c010350c:	74 6b                	je     c0103579 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x1a9>
    return (headNode.eNum == 0 && headNode.last == nullptr);
c010350e:	8b 4f 0c             	mov    0xc(%edi),%ecx
c0103511:	85 c9                	test   %ecx,%ecx
c0103513:	8d 59 01             	lea    0x1(%ecx),%ebx
c0103516:	75 06                	jne    c010351e <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x14e>
c0103518:	83 7f 08 00          	cmpl   $0x0,0x8(%edi)
c010351c:	74 18                	je     c0103536 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x166>
        node->next = headNode.first;
c010351e:	8b 4f 04             	mov    0x4(%edi),%ecx
        node->pre = nullptr;
c0103521:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        node->next = headNode.first;
c0103528:	89 48 14             	mov    %ecx,0x14(%eax)
        headNode.first->pre = node;
c010352b:	89 41 10             	mov    %eax,0x10(%ecx)
        headNode.first = node;
c010352e:	89 47 04             	mov    %eax,0x4(%edi)
        headNode.eNum++;
c0103531:	89 5f 0c             	mov    %ebx,0xc(%edi)
c0103534:	eb 43                	jmp    c0103579 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x1a9>
        headNode.last = &node;
c0103536:	89 47 08             	mov    %eax,0x8(%edi)
        headNode.first = &node;
c0103539:	89 47 04             	mov    %eax,0x4(%edi)
        node.pre = nullptr;
c010353c:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        node.next = nullptr;
c0103543:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    headNode.eNum++;
c010354a:	c7 47 0c 01 00 00 00 	movl   $0x1,0xc(%edi)
}
c0103551:	eb 26                	jmp    c0103579 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x1a9>
    if (preVma != nullptr) {    // pre-note
c0103553:	85 f6                	test   %esi,%esi
c0103555:	75 04                	jne    c010355b <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x18b>
    vma->data.vm_mm = mm;       // pointer father-MM
c0103557:	89 38                	mov    %edi,(%eax)
c0103559:	eb 1e                	jmp    c0103579 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x1a9>
        checkVamOverlap(preVma, vma);
c010355b:	52                   	push   %edx
c010355c:	50                   	push   %eax
c010355d:	56                   	push   %esi
c010355e:	ff 75 08             	pushl  0x8(%ebp)
c0103561:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c0103567:	e8 56 fc ff ff       	call   c01031c2 <_ZN3VMM15checkVamOverlapEPN4ListINS_3VMAEE6DLNodeES4_>
    vma->data.vm_mm = mm;       // pointer father-MM
c010356c:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0103572:	83 c4 10             	add    $0x10,%esp
c0103575:	89 38                	mov    %edi,(%eax)
c0103577:	eb 95                	jmp    c010350e <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE+0x13e>
}
c0103579:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010357c:	5b                   	pop    %ebx
c010357d:	5e                   	pop    %esi
c010357e:	5f                   	pop    %edi
c010357f:	5d                   	pop    %ebp
c0103580:	c3                   	ret    
c0103581:	90                   	nop

c0103582 <_ZN3VMM8checkVmaEv>:
void VMM::checkVma() {
c0103582:	55                   	push   %ebp
c0103583:	89 e5                	mov    %esp,%ebp
c0103585:	57                   	push   %edi
c0103586:	56                   	push   %esi
c0103587:	53                   	push   %ebx
c0103588:	e8 28 d6 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c010358d:	81 c3 83 8e 01 00    	add    $0x18e83,%ebx
c0103593:	81 ec 88 04 00 00    	sub    $0x488,%esp
    uint32_t nr_free_pages_store = kernel::pmm.numFreePages();
c0103599:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
c010359f:	e8 18 f5 ff ff       	call   c0102abc <_ZN5PhyMM12numFreePagesEv>
    auto *mm = mmCreate();
c01035a4:	59                   	pop    %ecx
c01035a5:	ff 75 08             	pushl  0x8(%ebp)
c01035a8:	e8 21 fb ff ff       	call   c01030ce <_ZN3VMM8mmCreateEv>
    assert(mm != nullptr);
c01035ad:	83 c4 10             	add    $0x10,%esp
c01035b0:	85 c0                	test   %eax,%eax
    auto *mm = mmCreate();
c01035b2:	89 85 84 fb ff ff    	mov    %eax,-0x47c(%ebp)
    assert(mm != nullptr);
c01035b8:	0f 85 92 00 00 00    	jne    c0103650 <_ZN3VMM8checkVmaEv+0xce>
c01035be:	50                   	push   %eax
c01035bf:	50                   	push   %eax
c01035c0:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c01035c6:	50                   	push   %eax
c01035c7:	8d b5 9a fb ff ff    	lea    -0x466(%ebp),%esi
c01035cd:	56                   	push   %esi
c01035ce:	e8 7d 10 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01035d3:	8d bd c0 fd ff ff    	lea    -0x240(%ebp),%edi
c01035d9:	58                   	pop    %eax
c01035da:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c01035e0:	5a                   	pop    %edx
c01035e1:	50                   	push   %eax
c01035e2:	8d 85 95 fb ff ff    	lea    -0x46b(%ebp),%eax
c01035e8:	50                   	push   %eax
c01035e9:	89 85 80 fb ff ff    	mov    %eax,-0x480(%ebp)
c01035ef:	e8 5c 10 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01035f4:	8b 85 80 fb ff ff    	mov    -0x480(%ebp),%eax
c01035fa:	83 c4 0c             	add    $0xc,%esp
c01035fd:	56                   	push   %esi
c01035fe:	50                   	push   %eax
c01035ff:	57                   	push   %edi
c0103600:	e8 61 e4 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0103605:	8b 85 80 fb ff ff    	mov    -0x480(%ebp),%eax
c010360b:	89 04 24             	mov    %eax,(%esp)
c010360e:	e8 57 10 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103613:	89 34 24             	mov    %esi,(%esp)
c0103616:	e8 4f 10 00 00       	call   c010466a <_ZN6StringD1Ev>
c010361b:	59                   	pop    %ecx
c010361c:	58                   	pop    %eax
c010361d:	8d 83 a1 85 fe ff    	lea    -0x17a5f(%ebx),%eax
c0103623:	50                   	push   %eax
c0103624:	56                   	push   %esi
c0103625:	e8 26 10 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010362a:	58                   	pop    %eax
c010362b:	5a                   	pop    %edx
c010362c:	56                   	push   %esi
c010362d:	57                   	push   %edi
c010362e:	e8 bd e5 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0103633:	89 34 24             	mov    %esi,(%esp)
c0103636:	e8 2f 10 00 00       	call   c010466a <_ZN6StringD1Ev>
c010363b:	89 3c 24             	mov    %edi,(%esp)
c010363e:	e8 c1 e4 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103643:	fa                   	cli    
    asm volatile ("hlt");
c0103644:	f4                   	hlt    
c0103645:	89 3c 24             	mov    %edi,(%esp)
c0103648:	e8 f9 e4 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c010364d:	83 c4 10             	add    $0x10,%esp
    for (i = step1; i >= 1; i --) {
c0103650:	c7 85 8c fb ff ff 0a 	movl   $0xa,-0x474(%ebp)
c0103657:	00 00 00 
c010365a:	8b 85 8c fb ff ff    	mov    -0x474(%ebp),%eax
c0103660:	85 c0                	test   %eax,%eax
c0103662:	0f 84 d9 00 00 00    	je     c0103741 <_ZN3VMM8checkVmaEv+0x1bf>
        auto *vma = vmaCreate(i * 5, i * 5 + 2, 0);
c0103668:	8d 04 80             	lea    (%eax,%eax,4),%eax
c010366b:	6a 00                	push   $0x0
c010366d:	8d 50 02             	lea    0x2(%eax),%edx
c0103670:	52                   	push   %edx
c0103671:	50                   	push   %eax
c0103672:	ff 75 08             	pushl  0x8(%ebp)
c0103675:	e8 16 fa ff ff       	call   c0103090 <_ZN3VMM9vmaCreateEjjj>
        assert(vma != nullptr);
c010367a:	83 c4 10             	add    $0x10,%esp
c010367d:	85 c0                	test   %eax,%eax
c010367f:	0f 85 9e 00 00 00    	jne    c0103723 <_ZN3VMM8checkVmaEv+0x1a1>
c0103685:	51                   	push   %ecx
c0103686:	51                   	push   %ecx
c0103687:	8d 93 15 83 fe ff    	lea    -0x17ceb(%ebx),%edx
c010368d:	52                   	push   %edx
c010368e:	8d b5 9a fb ff ff    	lea    -0x466(%ebp),%esi
c0103694:	56                   	push   %esi
c0103695:	89 85 7c fb ff ff    	mov    %eax,-0x484(%ebp)
c010369b:	e8 b0 0f 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01036a0:	8d 93 1f 83 fe ff    	lea    -0x17ce1(%ebx),%edx
c01036a6:	5f                   	pop    %edi
c01036a7:	8d bd c0 fd ff ff    	lea    -0x240(%ebp),%edi
c01036ad:	58                   	pop    %eax
c01036ae:	52                   	push   %edx
c01036af:	8d 95 95 fb ff ff    	lea    -0x46b(%ebp),%edx
c01036b5:	52                   	push   %edx
c01036b6:	89 95 80 fb ff ff    	mov    %edx,-0x480(%ebp)
c01036bc:	e8 8f 0f 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01036c1:	8b 95 80 fb ff ff    	mov    -0x480(%ebp),%edx
c01036c7:	83 c4 0c             	add    $0xc,%esp
c01036ca:	56                   	push   %esi
c01036cb:	52                   	push   %edx
c01036cc:	57                   	push   %edi
c01036cd:	e8 94 e3 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c01036d2:	8b 95 80 fb ff ff    	mov    -0x480(%ebp),%edx
c01036d8:	89 14 24             	mov    %edx,(%esp)
c01036db:	e8 8a 0f 00 00       	call   c010466a <_ZN6StringD1Ev>
c01036e0:	89 34 24             	mov    %esi,(%esp)
c01036e3:	e8 82 0f 00 00       	call   c010466a <_ZN6StringD1Ev>
c01036e8:	58                   	pop    %eax
c01036e9:	5a                   	pop    %edx
c01036ea:	8d 93 af 85 fe ff    	lea    -0x17a51(%ebx),%edx
c01036f0:	52                   	push   %edx
c01036f1:	56                   	push   %esi
c01036f2:	e8 59 0f 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01036f7:	59                   	pop    %ecx
c01036f8:	58                   	pop    %eax
c01036f9:	56                   	push   %esi
c01036fa:	57                   	push   %edi
c01036fb:	e8 f0 e4 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0103700:	89 34 24             	mov    %esi,(%esp)
c0103703:	e8 62 0f 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103708:	89 3c 24             	mov    %edi,(%esp)
c010370b:	e8 f4 e3 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103710:	fa                   	cli    
    asm volatile ("hlt");
c0103711:	f4                   	hlt    
c0103712:	89 3c 24             	mov    %edi,(%esp)
c0103715:	e8 2c e4 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c010371a:	8b 85 7c fb ff ff    	mov    -0x484(%ebp),%eax
c0103720:	83 c4 10             	add    $0x10,%esp
        insertVma(mm, vma);
c0103723:	52                   	push   %edx
c0103724:	50                   	push   %eax
c0103725:	ff b5 84 fb ff ff    	pushl  -0x47c(%ebp)
c010372b:	ff 75 08             	pushl  0x8(%ebp)
c010372e:	e8 9d fc ff ff       	call   c01033d0 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE>
    for (i = step1; i >= 1; i --) {
c0103733:	83 c4 10             	add    $0x10,%esp
c0103736:	ff 8d 8c fb ff ff    	decl   -0x474(%ebp)
c010373c:	e9 19 ff ff ff       	jmp    c010365a <_ZN3VMM8checkVmaEv+0xd8>
    for (i = step1 + 1; i <= step2; i ++) {
c0103741:	c7 85 8c fb ff ff 0b 	movl   $0xb,-0x474(%ebp)
c0103748:	00 00 00 
c010374b:	8b 85 8c fb ff ff    	mov    -0x474(%ebp),%eax
c0103751:	83 f8 64             	cmp    $0x64,%eax
c0103754:	0f 87 d9 00 00 00    	ja     c0103833 <_ZN3VMM8checkVmaEv+0x2b1>
        auto *vma = vmaCreate(i * 5, i * 5 + 2, 0);
c010375a:	8d 04 80             	lea    (%eax,%eax,4),%eax
c010375d:	6a 00                	push   $0x0
c010375f:	8d 50 02             	lea    0x2(%eax),%edx
c0103762:	52                   	push   %edx
c0103763:	50                   	push   %eax
c0103764:	ff 75 08             	pushl  0x8(%ebp)
c0103767:	e8 24 f9 ff ff       	call   c0103090 <_ZN3VMM9vmaCreateEjjj>
        assert(vma != nullptr);
c010376c:	83 c4 10             	add    $0x10,%esp
c010376f:	85 c0                	test   %eax,%eax
c0103771:	0f 85 9e 00 00 00    	jne    c0103815 <_ZN3VMM8checkVmaEv+0x293>
c0103777:	56                   	push   %esi
c0103778:	56                   	push   %esi
c0103779:	8d 93 15 83 fe ff    	lea    -0x17ceb(%ebx),%edx
c010377f:	52                   	push   %edx
c0103780:	8d b5 9a fb ff ff    	lea    -0x466(%ebp),%esi
c0103786:	56                   	push   %esi
c0103787:	89 85 7c fb ff ff    	mov    %eax,-0x484(%ebp)
c010378d:	e8 be 0e 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103792:	8d 93 1f 83 fe ff    	lea    -0x17ce1(%ebx),%edx
c0103798:	5f                   	pop    %edi
c0103799:	8d bd c0 fd ff ff    	lea    -0x240(%ebp),%edi
c010379f:	58                   	pop    %eax
c01037a0:	52                   	push   %edx
c01037a1:	8d 95 95 fb ff ff    	lea    -0x46b(%ebp),%edx
c01037a7:	52                   	push   %edx
c01037a8:	89 95 80 fb ff ff    	mov    %edx,-0x480(%ebp)
c01037ae:	e8 9d 0e 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01037b3:	8b 95 80 fb ff ff    	mov    -0x480(%ebp),%edx
c01037b9:	83 c4 0c             	add    $0xc,%esp
c01037bc:	56                   	push   %esi
c01037bd:	52                   	push   %edx
c01037be:	57                   	push   %edi
c01037bf:	e8 a2 e2 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c01037c4:	8b 95 80 fb ff ff    	mov    -0x480(%ebp),%edx
c01037ca:	89 14 24             	mov    %edx,(%esp)
c01037cd:	e8 98 0e 00 00       	call   c010466a <_ZN6StringD1Ev>
c01037d2:	89 34 24             	mov    %esi,(%esp)
c01037d5:	e8 90 0e 00 00       	call   c010466a <_ZN6StringD1Ev>
c01037da:	58                   	pop    %eax
c01037db:	5a                   	pop    %edx
c01037dc:	8d 93 af 85 fe ff    	lea    -0x17a51(%ebx),%edx
c01037e2:	52                   	push   %edx
c01037e3:	56                   	push   %esi
c01037e4:	e8 67 0e 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01037e9:	59                   	pop    %ecx
c01037ea:	58                   	pop    %eax
c01037eb:	56                   	push   %esi
c01037ec:	57                   	push   %edi
c01037ed:	e8 fe e3 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c01037f2:	89 34 24             	mov    %esi,(%esp)
c01037f5:	e8 70 0e 00 00       	call   c010466a <_ZN6StringD1Ev>
c01037fa:	89 3c 24             	mov    %edi,(%esp)
c01037fd:	e8 02 e3 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103802:	fa                   	cli    
    asm volatile ("hlt");
c0103803:	f4                   	hlt    
c0103804:	89 3c 24             	mov    %edi,(%esp)
c0103807:	e8 3a e3 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c010380c:	8b 85 7c fb ff ff    	mov    -0x484(%ebp),%eax
c0103812:	83 c4 10             	add    $0x10,%esp
        insertVma(mm, vma);
c0103815:	51                   	push   %ecx
c0103816:	50                   	push   %eax
c0103817:	ff b5 84 fb ff ff    	pushl  -0x47c(%ebp)
c010381d:	ff 75 08             	pushl  0x8(%ebp)
c0103820:	e8 ab fb ff ff       	call   c01033d0 <_ZN3VMM9insertVmaEPN4ListINS_2MMEE6DLNodeEPNS0_INS_3VMAEE6DLNodeE>
    for (i = step1 + 1; i <= step2; i ++) {
c0103825:	83 c4 10             	add    $0x10,%esp
c0103828:	ff 85 8c fb ff ff    	incl   -0x474(%ebp)
c010382e:	e9 18 ff ff ff       	jmp    c010374b <_ZN3VMM8checkVmaEv+0x1c9>
    it.setCurrentNode(headNode.first);
c0103833:	8b 85 84 fb ff ff    	mov    -0x47c(%ebp),%eax
    return it;
c0103839:	31 d2                	xor    %edx,%edx
                    currentNode = node;
c010383b:	8b 8d 84 fb ff ff    	mov    -0x47c(%ebp),%ecx
    it.setCurrentNode(headNode.first);
c0103841:	8b 40 04             	mov    0x4(%eax),%eax
                    if (!hasNext()) {
c0103844:	85 c0                	test   %eax,%eax
                    currentNode = node;
c0103846:	89 01                	mov    %eax,(%ecx)
                    if (!hasNext()) {
c0103848:	74 03                	je     c010384d <_ZN3VMM8checkVmaEv+0x2cb>
                    currentNode = currentNode->next;
c010384a:	8b 50 14             	mov    0x14(%eax),%edx
    for (i = 1; i <= step2; i++) {
c010384d:	c7 85 8c fb ff ff 01 	movl   $0x1,-0x474(%ebp)
c0103854:	00 00 00 
c0103857:	83 bd 8c fb ff ff 64 	cmpl   $0x64,-0x474(%ebp)
c010385e:	0f 87 82 01 00 00    	ja     c01039e6 <_ZN3VMM8checkVmaEv+0x464>
        assert(vmaNode != nullptr);
c0103864:	85 c0                	test   %eax,%eax
c0103866:	0f 85 aa 00 00 00    	jne    c0103916 <_ZN3VMM8checkVmaEv+0x394>
c010386c:	89 85 7c fb ff ff    	mov    %eax,-0x484(%ebp)
c0103872:	8d 8b 15 83 fe ff    	lea    -0x17ceb(%ebx),%ecx
c0103878:	50                   	push   %eax
c0103879:	50                   	push   %eax
c010387a:	51                   	push   %ecx
c010387b:	8d b5 9a fb ff ff    	lea    -0x466(%ebp),%esi
c0103881:	56                   	push   %esi
c0103882:	8d bd c0 fd ff ff    	lea    -0x240(%ebp),%edi
c0103888:	89 95 78 fb ff ff    	mov    %edx,-0x488(%ebp)
c010388e:	e8 bd 0d 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103893:	8d 8b 1f 83 fe ff    	lea    -0x17ce1(%ebx),%ecx
c0103899:	58                   	pop    %eax
c010389a:	5a                   	pop    %edx
c010389b:	51                   	push   %ecx
c010389c:	8d 8d 95 fb ff ff    	lea    -0x46b(%ebp),%ecx
c01038a2:	51                   	push   %ecx
c01038a3:	89 8d 80 fb ff ff    	mov    %ecx,-0x480(%ebp)
c01038a9:	e8 a2 0d 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01038ae:	8b 8d 80 fb ff ff    	mov    -0x480(%ebp),%ecx
c01038b4:	83 c4 0c             	add    $0xc,%esp
c01038b7:	56                   	push   %esi
c01038b8:	51                   	push   %ecx
c01038b9:	57                   	push   %edi
c01038ba:	e8 a7 e1 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c01038bf:	8b 8d 80 fb ff ff    	mov    -0x480(%ebp),%ecx
c01038c5:	89 0c 24             	mov    %ecx,(%esp)
c01038c8:	e8 9d 0d 00 00       	call   c010466a <_ZN6StringD1Ev>
c01038cd:	89 34 24             	mov    %esi,(%esp)
c01038d0:	e8 95 0d 00 00       	call   c010466a <_ZN6StringD1Ev>
c01038d5:	59                   	pop    %ecx
c01038d6:	8d 8b be 85 fe ff    	lea    -0x17a42(%ebx),%ecx
c01038dc:	58                   	pop    %eax
c01038dd:	51                   	push   %ecx
c01038de:	56                   	push   %esi
c01038df:	e8 6c 0d 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01038e4:	58                   	pop    %eax
c01038e5:	5a                   	pop    %edx
c01038e6:	56                   	push   %esi
c01038e7:	57                   	push   %edi
c01038e8:	e8 03 e3 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c01038ed:	89 34 24             	mov    %esi,(%esp)
c01038f0:	e8 75 0d 00 00       	call   c010466a <_ZN6StringD1Ev>
c01038f5:	89 3c 24             	mov    %edi,(%esp)
c01038f8:	e8 07 e2 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01038fd:	fa                   	cli    
    asm volatile ("hlt");
c01038fe:	f4                   	hlt    
c01038ff:	89 3c 24             	mov    %edi,(%esp)
c0103902:	e8 3f e2 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c0103907:	8b 95 78 fb ff ff    	mov    -0x488(%ebp),%edx
c010390d:	83 c4 10             	add    $0x10,%esp
c0103910:	8b 85 7c fb ff ff    	mov    -0x484(%ebp),%eax
        assert(vmaNode->data.vm_start == i * 5 && vmaNode->data.vm_end == i * 5 + 2);
c0103916:	8b 48 04             	mov    0x4(%eax),%ecx
c0103919:	6b b5 8c fb ff ff 05 	imul   $0x5,-0x474(%ebp),%esi
c0103920:	39 f1                	cmp    %esi,%ecx
c0103922:	75 0c                	jne    c0103930 <_ZN3VMM8checkVmaEv+0x3ae>
c0103924:	83 c1 02             	add    $0x2,%ecx
c0103927:	39 48 08             	cmp    %ecx,0x8(%eax)
c010392a:	0f 84 9e 00 00 00    	je     c01039ce <_ZN3VMM8checkVmaEv+0x44c>
c0103930:	56                   	push   %esi
c0103931:	56                   	push   %esi
c0103932:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0103938:	50                   	push   %eax
c0103939:	8d b5 9a fb ff ff    	lea    -0x466(%ebp),%esi
c010393f:	56                   	push   %esi
c0103940:	89 95 7c fb ff ff    	mov    %edx,-0x484(%ebp)
c0103946:	e8 05 0d 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010394b:	5f                   	pop    %edi
c010394c:	8d bd c0 fd ff ff    	lea    -0x240(%ebp),%edi
c0103952:	58                   	pop    %eax
c0103953:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c0103959:	50                   	push   %eax
c010395a:	8d 85 95 fb ff ff    	lea    -0x46b(%ebp),%eax
c0103960:	50                   	push   %eax
c0103961:	89 85 80 fb ff ff    	mov    %eax,-0x480(%ebp)
c0103967:	e8 e4 0c 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010396c:	8b 85 80 fb ff ff    	mov    -0x480(%ebp),%eax
c0103972:	83 c4 0c             	add    $0xc,%esp
c0103975:	56                   	push   %esi
c0103976:	50                   	push   %eax
c0103977:	57                   	push   %edi
c0103978:	e8 e9 e0 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c010397d:	8b 85 80 fb ff ff    	mov    -0x480(%ebp),%eax
c0103983:	89 04 24             	mov    %eax,(%esp)
c0103986:	e8 df 0c 00 00       	call   c010466a <_ZN6StringD1Ev>
c010398b:	89 34 24             	mov    %esi,(%esp)
c010398e:	e8 d7 0c 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103993:	58                   	pop    %eax
c0103994:	8d 83 d1 85 fe ff    	lea    -0x17a2f(%ebx),%eax
c010399a:	5a                   	pop    %edx
c010399b:	50                   	push   %eax
c010399c:	56                   	push   %esi
c010399d:	e8 ae 0c 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01039a2:	59                   	pop    %ecx
c01039a3:	58                   	pop    %eax
c01039a4:	56                   	push   %esi
c01039a5:	57                   	push   %edi
c01039a6:	e8 45 e2 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c01039ab:	89 34 24             	mov    %esi,(%esp)
c01039ae:	e8 b7 0c 00 00       	call   c010466a <_ZN6StringD1Ev>
c01039b3:	89 3c 24             	mov    %edi,(%esp)
c01039b6:	e8 49 e1 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01039bb:	fa                   	cli    
    asm volatile ("hlt");
c01039bc:	f4                   	hlt    
c01039bd:	89 3c 24             	mov    %edi,(%esp)
c01039c0:	e8 81 e1 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c01039c5:	8b 95 7c fb ff ff    	mov    -0x484(%ebp),%edx
c01039cb:	83 c4 10             	add    $0x10,%esp
                    if (!hasNext()) {
c01039ce:	31 c9                	xor    %ecx,%ecx
c01039d0:	85 d2                	test   %edx,%edx
c01039d2:	74 03                	je     c01039d7 <_ZN3VMM8checkVmaEv+0x455>
                    currentNode = currentNode->next;
c01039d4:	8b 4a 14             	mov    0x14(%edx),%ecx
    for (i = 1; i <= step2; i++) {
c01039d7:	89 d0                	mov    %edx,%eax
c01039d9:	89 ca                	mov    %ecx,%edx
c01039db:	ff 85 8c fb ff ff    	incl   -0x474(%ebp)
c01039e1:	e9 71 fe ff ff       	jmp    c0103857 <_ZN3VMM8checkVmaEv+0x2d5>
    for (i = 5; i <= 5 * step2; i +=5) {
c01039e6:	c7 85 8c fb ff ff 05 	movl   $0x5,-0x474(%ebp)
c01039ed:	00 00 00 
c01039f0:	8b 85 8c fb ff ff    	mov    -0x474(%ebp),%eax
c01039f6:	3d f4 01 00 00       	cmp    $0x1f4,%eax
c01039fb:	0f 87 05 05 00 00    	ja     c0103f06 <_ZN3VMM8checkVmaEv+0x984>
        auto *vma1 = findVma(mm, i);
c0103a01:	51                   	push   %ecx
c0103a02:	50                   	push   %eax
c0103a03:	ff b5 84 fb ff ff    	pushl  -0x47c(%ebp)
c0103a09:	ff 75 08             	pushl  0x8(%ebp)
c0103a0c:	e8 3b f6 ff ff       	call   c010304c <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma1 != nullptr);
c0103a11:	83 c4 10             	add    $0x10,%esp
c0103a14:	85 c0                	test   %eax,%eax
        auto *vma1 = findVma(mm, i);
c0103a16:	89 85 80 fb ff ff    	mov    %eax,-0x480(%ebp)
        assert(vma1 != nullptr);
c0103a1c:	0f 85 92 00 00 00    	jne    c0103ab4 <_ZN3VMM8checkVmaEv+0x532>
c0103a22:	50                   	push   %eax
c0103a23:	50                   	push   %eax
c0103a24:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0103a2a:	50                   	push   %eax
c0103a2b:	8d b5 9a fb ff ff    	lea    -0x466(%ebp),%esi
c0103a31:	56                   	push   %esi
c0103a32:	e8 19 0c 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103a37:	8d bd c0 fd ff ff    	lea    -0x240(%ebp),%edi
c0103a3d:	58                   	pop    %eax
c0103a3e:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c0103a44:	5a                   	pop    %edx
c0103a45:	50                   	push   %eax
c0103a46:	8d 85 95 fb ff ff    	lea    -0x46b(%ebp),%eax
c0103a4c:	50                   	push   %eax
c0103a4d:	89 85 7c fb ff ff    	mov    %eax,-0x484(%ebp)
c0103a53:	e8 f8 0b 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103a58:	8b 85 7c fb ff ff    	mov    -0x484(%ebp),%eax
c0103a5e:	83 c4 0c             	add    $0xc,%esp
c0103a61:	56                   	push   %esi
c0103a62:	50                   	push   %eax
c0103a63:	57                   	push   %edi
c0103a64:	e8 fd df ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0103a69:	8b 85 7c fb ff ff    	mov    -0x484(%ebp),%eax
c0103a6f:	89 04 24             	mov    %eax,(%esp)
c0103a72:	e8 f3 0b 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103a77:	89 34 24             	mov    %esi,(%esp)
c0103a7a:	e8 eb 0b 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103a7f:	59                   	pop    %ecx
c0103a80:	58                   	pop    %eax
c0103a81:	8d 83 16 86 fe ff    	lea    -0x179ea(%ebx),%eax
c0103a87:	50                   	push   %eax
c0103a88:	56                   	push   %esi
c0103a89:	e8 c2 0b 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103a8e:	58                   	pop    %eax
c0103a8f:	5a                   	pop    %edx
c0103a90:	56                   	push   %esi
c0103a91:	57                   	push   %edi
c0103a92:	e8 59 e1 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0103a97:	89 34 24             	mov    %esi,(%esp)
c0103a9a:	e8 cb 0b 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103a9f:	89 3c 24             	mov    %edi,(%esp)
c0103aa2:	e8 5d e0 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103aa7:	fa                   	cli    
    asm volatile ("hlt");
c0103aa8:	f4                   	hlt    
c0103aa9:	89 3c 24             	mov    %edi,(%esp)
c0103aac:	e8 95 e0 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c0103ab1:	83 c4 10             	add    $0x10,%esp
        auto *vma2 = findVma(mm, i+1);
c0103ab4:	50                   	push   %eax
c0103ab5:	8b 85 8c fb ff ff    	mov    -0x474(%ebp),%eax
c0103abb:	40                   	inc    %eax
c0103abc:	50                   	push   %eax
c0103abd:	ff b5 84 fb ff ff    	pushl  -0x47c(%ebp)
c0103ac3:	ff 75 08             	pushl  0x8(%ebp)
c0103ac6:	e8 81 f5 ff ff       	call   c010304c <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma2 != nullptr);
c0103acb:	83 c4 10             	add    $0x10,%esp
c0103ace:	85 c0                	test   %eax,%eax
        auto *vma2 = findVma(mm, i+1);
c0103ad0:	89 85 7c fb ff ff    	mov    %eax,-0x484(%ebp)
        assert(vma2 != nullptr);
c0103ad6:	0f 85 92 00 00 00    	jne    c0103b6e <_ZN3VMM8checkVmaEv+0x5ec>
c0103adc:	56                   	push   %esi
c0103add:	56                   	push   %esi
c0103ade:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0103ae4:	50                   	push   %eax
c0103ae5:	8d b5 9a fb ff ff    	lea    -0x466(%ebp),%esi
c0103aeb:	56                   	push   %esi
c0103aec:	e8 5f 0b 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103af1:	5f                   	pop    %edi
c0103af2:	8d bd c0 fd ff ff    	lea    -0x240(%ebp),%edi
c0103af8:	58                   	pop    %eax
c0103af9:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c0103aff:	50                   	push   %eax
c0103b00:	8d 85 95 fb ff ff    	lea    -0x46b(%ebp),%eax
c0103b06:	50                   	push   %eax
c0103b07:	89 85 78 fb ff ff    	mov    %eax,-0x488(%ebp)
c0103b0d:	e8 3e 0b 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103b12:	8b 85 78 fb ff ff    	mov    -0x488(%ebp),%eax
c0103b18:	83 c4 0c             	add    $0xc,%esp
c0103b1b:	56                   	push   %esi
c0103b1c:	50                   	push   %eax
c0103b1d:	57                   	push   %edi
c0103b1e:	e8 43 df ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0103b23:	8b 85 78 fb ff ff    	mov    -0x488(%ebp),%eax
c0103b29:	89 04 24             	mov    %eax,(%esp)
c0103b2c:	e8 39 0b 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103b31:	89 34 24             	mov    %esi,(%esp)
c0103b34:	e8 31 0b 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103b39:	58                   	pop    %eax
c0103b3a:	8d 83 26 86 fe ff    	lea    -0x179da(%ebx),%eax
c0103b40:	5a                   	pop    %edx
c0103b41:	50                   	push   %eax
c0103b42:	56                   	push   %esi
c0103b43:	e8 08 0b 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103b48:	59                   	pop    %ecx
c0103b49:	58                   	pop    %eax
c0103b4a:	56                   	push   %esi
c0103b4b:	57                   	push   %edi
c0103b4c:	e8 9f e0 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0103b51:	89 34 24             	mov    %esi,(%esp)
c0103b54:	e8 11 0b 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103b59:	89 3c 24             	mov    %edi,(%esp)
c0103b5c:	e8 a3 df ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103b61:	fa                   	cli    
    asm volatile ("hlt");
c0103b62:	f4                   	hlt    
c0103b63:	89 3c 24             	mov    %edi,(%esp)
c0103b66:	e8 db df ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c0103b6b:	83 c4 10             	add    $0x10,%esp
        auto *vma3 = findVma(mm, i+2);
c0103b6e:	8b 85 8c fb ff ff    	mov    -0x474(%ebp),%eax
c0103b74:	51                   	push   %ecx
c0103b75:	83 c0 02             	add    $0x2,%eax
c0103b78:	50                   	push   %eax
c0103b79:	ff b5 84 fb ff ff    	pushl  -0x47c(%ebp)
c0103b7f:	ff 75 08             	pushl  0x8(%ebp)
c0103b82:	e8 c5 f4 ff ff       	call   c010304c <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma3 == nullptr);
c0103b87:	83 c4 10             	add    $0x10,%esp
c0103b8a:	85 c0                	test   %eax,%eax
c0103b8c:	0f 84 92 00 00 00    	je     c0103c24 <_ZN3VMM8checkVmaEv+0x6a2>
c0103b92:	50                   	push   %eax
c0103b93:	50                   	push   %eax
c0103b94:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0103b9a:	50                   	push   %eax
c0103b9b:	8d b5 9a fb ff ff    	lea    -0x466(%ebp),%esi
c0103ba1:	56                   	push   %esi
c0103ba2:	e8 a9 0a 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103ba7:	8d bd c0 fd ff ff    	lea    -0x240(%ebp),%edi
c0103bad:	58                   	pop    %eax
c0103bae:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c0103bb4:	5a                   	pop    %edx
c0103bb5:	50                   	push   %eax
c0103bb6:	8d 85 95 fb ff ff    	lea    -0x46b(%ebp),%eax
c0103bbc:	50                   	push   %eax
c0103bbd:	89 85 78 fb ff ff    	mov    %eax,-0x488(%ebp)
c0103bc3:	e8 88 0a 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103bc8:	8b 85 78 fb ff ff    	mov    -0x488(%ebp),%eax
c0103bce:	83 c4 0c             	add    $0xc,%esp
c0103bd1:	56                   	push   %esi
c0103bd2:	50                   	push   %eax
c0103bd3:	57                   	push   %edi
c0103bd4:	e8 8d de ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0103bd9:	8b 85 78 fb ff ff    	mov    -0x488(%ebp),%eax
c0103bdf:	89 04 24             	mov    %eax,(%esp)
c0103be2:	e8 83 0a 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103be7:	89 34 24             	mov    %esi,(%esp)
c0103bea:	e8 7b 0a 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103bef:	59                   	pop    %ecx
c0103bf0:	58                   	pop    %eax
c0103bf1:	8d 83 36 86 fe ff    	lea    -0x179ca(%ebx),%eax
c0103bf7:	50                   	push   %eax
c0103bf8:	56                   	push   %esi
c0103bf9:	e8 52 0a 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103bfe:	58                   	pop    %eax
c0103bff:	5a                   	pop    %edx
c0103c00:	56                   	push   %esi
c0103c01:	57                   	push   %edi
c0103c02:	e8 e9 df ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0103c07:	89 34 24             	mov    %esi,(%esp)
c0103c0a:	e8 5b 0a 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103c0f:	89 3c 24             	mov    %edi,(%esp)
c0103c12:	e8 ed de ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103c17:	fa                   	cli    
    asm volatile ("hlt");
c0103c18:	f4                   	hlt    
c0103c19:	89 3c 24             	mov    %edi,(%esp)
c0103c1c:	e8 25 df ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c0103c21:	83 c4 10             	add    $0x10,%esp
        auto *vma4 = findVma(mm, i+3);
c0103c24:	50                   	push   %eax
c0103c25:	8b 85 8c fb ff ff    	mov    -0x474(%ebp),%eax
c0103c2b:	83 c0 03             	add    $0x3,%eax
c0103c2e:	50                   	push   %eax
c0103c2f:	ff b5 84 fb ff ff    	pushl  -0x47c(%ebp)
c0103c35:	ff 75 08             	pushl  0x8(%ebp)
c0103c38:	e8 0f f4 ff ff       	call   c010304c <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma4 == nullptr);
c0103c3d:	83 c4 10             	add    $0x10,%esp
c0103c40:	85 c0                	test   %eax,%eax
c0103c42:	0f 84 92 00 00 00    	je     c0103cda <_ZN3VMM8checkVmaEv+0x758>
c0103c48:	56                   	push   %esi
c0103c49:	56                   	push   %esi
c0103c4a:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0103c50:	50                   	push   %eax
c0103c51:	8d b5 9a fb ff ff    	lea    -0x466(%ebp),%esi
c0103c57:	56                   	push   %esi
c0103c58:	e8 f3 09 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103c5d:	5f                   	pop    %edi
c0103c5e:	8d bd c0 fd ff ff    	lea    -0x240(%ebp),%edi
c0103c64:	58                   	pop    %eax
c0103c65:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c0103c6b:	50                   	push   %eax
c0103c6c:	8d 85 95 fb ff ff    	lea    -0x46b(%ebp),%eax
c0103c72:	50                   	push   %eax
c0103c73:	89 85 78 fb ff ff    	mov    %eax,-0x488(%ebp)
c0103c79:	e8 d2 09 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103c7e:	8b 85 78 fb ff ff    	mov    -0x488(%ebp),%eax
c0103c84:	83 c4 0c             	add    $0xc,%esp
c0103c87:	56                   	push   %esi
c0103c88:	50                   	push   %eax
c0103c89:	57                   	push   %edi
c0103c8a:	e8 d7 dd ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0103c8f:	8b 85 78 fb ff ff    	mov    -0x488(%ebp),%eax
c0103c95:	89 04 24             	mov    %eax,(%esp)
c0103c98:	e8 cd 09 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103c9d:	89 34 24             	mov    %esi,(%esp)
c0103ca0:	e8 c5 09 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103ca5:	58                   	pop    %eax
c0103ca6:	8d 83 46 86 fe ff    	lea    -0x179ba(%ebx),%eax
c0103cac:	5a                   	pop    %edx
c0103cad:	50                   	push   %eax
c0103cae:	56                   	push   %esi
c0103caf:	e8 9c 09 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103cb4:	59                   	pop    %ecx
c0103cb5:	58                   	pop    %eax
c0103cb6:	56                   	push   %esi
c0103cb7:	57                   	push   %edi
c0103cb8:	e8 33 df ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0103cbd:	89 34 24             	mov    %esi,(%esp)
c0103cc0:	e8 a5 09 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103cc5:	89 3c 24             	mov    %edi,(%esp)
c0103cc8:	e8 37 de ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103ccd:	fa                   	cli    
    asm volatile ("hlt");
c0103cce:	f4                   	hlt    
c0103ccf:	89 3c 24             	mov    %edi,(%esp)
c0103cd2:	e8 6f de ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c0103cd7:	83 c4 10             	add    $0x10,%esp
        auto *vma5 = findVma(mm, i+4);
c0103cda:	8b 85 8c fb ff ff    	mov    -0x474(%ebp),%eax
c0103ce0:	51                   	push   %ecx
c0103ce1:	83 c0 04             	add    $0x4,%eax
c0103ce4:	50                   	push   %eax
c0103ce5:	ff b5 84 fb ff ff    	pushl  -0x47c(%ebp)
c0103ceb:	ff 75 08             	pushl  0x8(%ebp)
c0103cee:	e8 59 f3 ff ff       	call   c010304c <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        assert(vma5 == nullptr);
c0103cf3:	83 c4 10             	add    $0x10,%esp
c0103cf6:	85 c0                	test   %eax,%eax
c0103cf8:	0f 84 92 00 00 00    	je     c0103d90 <_ZN3VMM8checkVmaEv+0x80e>
c0103cfe:	50                   	push   %eax
c0103cff:	50                   	push   %eax
c0103d00:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0103d06:	50                   	push   %eax
c0103d07:	8d b5 9a fb ff ff    	lea    -0x466(%ebp),%esi
c0103d0d:	56                   	push   %esi
c0103d0e:	e8 3d 09 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103d13:	8d bd c0 fd ff ff    	lea    -0x240(%ebp),%edi
c0103d19:	58                   	pop    %eax
c0103d1a:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c0103d20:	5a                   	pop    %edx
c0103d21:	50                   	push   %eax
c0103d22:	8d 85 95 fb ff ff    	lea    -0x46b(%ebp),%eax
c0103d28:	50                   	push   %eax
c0103d29:	89 85 78 fb ff ff    	mov    %eax,-0x488(%ebp)
c0103d2f:	e8 1c 09 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103d34:	8b 85 78 fb ff ff    	mov    -0x488(%ebp),%eax
c0103d3a:	83 c4 0c             	add    $0xc,%esp
c0103d3d:	56                   	push   %esi
c0103d3e:	50                   	push   %eax
c0103d3f:	57                   	push   %edi
c0103d40:	e8 21 dd ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0103d45:	8b 85 78 fb ff ff    	mov    -0x488(%ebp),%eax
c0103d4b:	89 04 24             	mov    %eax,(%esp)
c0103d4e:	e8 17 09 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103d53:	89 34 24             	mov    %esi,(%esp)
c0103d56:	e8 0f 09 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103d5b:	59                   	pop    %ecx
c0103d5c:	58                   	pop    %eax
c0103d5d:	8d 83 56 86 fe ff    	lea    -0x179aa(%ebx),%eax
c0103d63:	50                   	push   %eax
c0103d64:	56                   	push   %esi
c0103d65:	e8 e6 08 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103d6a:	58                   	pop    %eax
c0103d6b:	5a                   	pop    %edx
c0103d6c:	56                   	push   %esi
c0103d6d:	57                   	push   %edi
c0103d6e:	e8 7d de ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0103d73:	89 34 24             	mov    %esi,(%esp)
c0103d76:	e8 ef 08 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103d7b:	89 3c 24             	mov    %edi,(%esp)
c0103d7e:	e8 81 dd ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103d83:	fa                   	cli    
    asm volatile ("hlt");
c0103d84:	f4                   	hlt    
c0103d85:	89 3c 24             	mov    %edi,(%esp)
c0103d88:	e8 b9 dd ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c0103d8d:	83 c4 10             	add    $0x10,%esp
        assert(vma1->data.vm_start == i  && vma1->data.vm_end == i  + 2);
c0103d90:	8b 85 80 fb ff ff    	mov    -0x480(%ebp),%eax
c0103d96:	8b 40 04             	mov    0x4(%eax),%eax
c0103d99:	3b 85 8c fb ff ff    	cmp    -0x474(%ebp),%eax
c0103d9f:	75 12                	jne    c0103db3 <_ZN3VMM8checkVmaEv+0x831>
c0103da1:	8b 8d 80 fb ff ff    	mov    -0x480(%ebp),%ecx
c0103da7:	83 c0 02             	add    $0x2,%eax
c0103daa:	39 41 08             	cmp    %eax,0x8(%ecx)
c0103dad:	0f 84 92 00 00 00    	je     c0103e45 <_ZN3VMM8checkVmaEv+0x8c3>
c0103db3:	51                   	push   %ecx
c0103db4:	51                   	push   %ecx
c0103db5:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0103dbb:	50                   	push   %eax
c0103dbc:	8d b5 9a fb ff ff    	lea    -0x466(%ebp),%esi
c0103dc2:	56                   	push   %esi
c0103dc3:	e8 88 08 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103dc8:	5f                   	pop    %edi
c0103dc9:	8d bd c0 fd ff ff    	lea    -0x240(%ebp),%edi
c0103dcf:	58                   	pop    %eax
c0103dd0:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c0103dd6:	50                   	push   %eax
c0103dd7:	8d 85 95 fb ff ff    	lea    -0x46b(%ebp),%eax
c0103ddd:	50                   	push   %eax
c0103dde:	89 85 80 fb ff ff    	mov    %eax,-0x480(%ebp)
c0103de4:	e8 67 08 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103de9:	8b 85 80 fb ff ff    	mov    -0x480(%ebp),%eax
c0103def:	83 c4 0c             	add    $0xc,%esp
c0103df2:	56                   	push   %esi
c0103df3:	50                   	push   %eax
c0103df4:	57                   	push   %edi
c0103df5:	e8 6c dc ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0103dfa:	8b 85 80 fb ff ff    	mov    -0x480(%ebp),%eax
c0103e00:	89 04 24             	mov    %eax,(%esp)
c0103e03:	e8 62 08 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103e08:	89 34 24             	mov    %esi,(%esp)
c0103e0b:	e8 5a 08 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103e10:	58                   	pop    %eax
c0103e11:	8d 83 66 86 fe ff    	lea    -0x1799a(%ebx),%eax
c0103e17:	5a                   	pop    %edx
c0103e18:	50                   	push   %eax
c0103e19:	56                   	push   %esi
c0103e1a:	e8 31 08 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103e1f:	59                   	pop    %ecx
c0103e20:	58                   	pop    %eax
c0103e21:	56                   	push   %esi
c0103e22:	57                   	push   %edi
c0103e23:	e8 c8 dd ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0103e28:	89 34 24             	mov    %esi,(%esp)
c0103e2b:	e8 3a 08 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103e30:	89 3c 24             	mov    %edi,(%esp)
c0103e33:	e8 cc dc ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103e38:	fa                   	cli    
    asm volatile ("hlt");
c0103e39:	f4                   	hlt    
c0103e3a:	89 3c 24             	mov    %edi,(%esp)
c0103e3d:	e8 04 dd ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c0103e42:	83 c4 10             	add    $0x10,%esp
        assert(vma2->data.vm_start == i  && vma2->data.vm_end == i  + 2);
c0103e45:	8b 85 7c fb ff ff    	mov    -0x484(%ebp),%eax
c0103e4b:	8b 40 04             	mov    0x4(%eax),%eax
c0103e4e:	3b 85 8c fb ff ff    	cmp    -0x474(%ebp),%eax
c0103e54:	75 12                	jne    c0103e68 <_ZN3VMM8checkVmaEv+0x8e6>
c0103e56:	8b 8d 7c fb ff ff    	mov    -0x484(%ebp),%ecx
c0103e5c:	83 c0 02             	add    $0x2,%eax
c0103e5f:	39 41 08             	cmp    %eax,0x8(%ecx)
c0103e62:	0f 84 92 00 00 00    	je     c0103efa <_ZN3VMM8checkVmaEv+0x978>
c0103e68:	50                   	push   %eax
c0103e69:	50                   	push   %eax
c0103e6a:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0103e70:	50                   	push   %eax
c0103e71:	8d b5 9a fb ff ff    	lea    -0x466(%ebp),%esi
c0103e77:	56                   	push   %esi
c0103e78:	e8 d3 07 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103e7d:	8d bd c0 fd ff ff    	lea    -0x240(%ebp),%edi
c0103e83:	58                   	pop    %eax
c0103e84:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c0103e8a:	5a                   	pop    %edx
c0103e8b:	50                   	push   %eax
c0103e8c:	8d 85 95 fb ff ff    	lea    -0x46b(%ebp),%eax
c0103e92:	50                   	push   %eax
c0103e93:	89 85 80 fb ff ff    	mov    %eax,-0x480(%ebp)
c0103e99:	e8 b2 07 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103e9e:	8b 85 80 fb ff ff    	mov    -0x480(%ebp),%eax
c0103ea4:	83 c4 0c             	add    $0xc,%esp
c0103ea7:	56                   	push   %esi
c0103ea8:	50                   	push   %eax
c0103ea9:	57                   	push   %edi
c0103eaa:	e8 b7 db ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0103eaf:	8b 85 80 fb ff ff    	mov    -0x480(%ebp),%eax
c0103eb5:	89 04 24             	mov    %eax,(%esp)
c0103eb8:	e8 ad 07 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103ebd:	89 34 24             	mov    %esi,(%esp)
c0103ec0:	e8 a5 07 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103ec5:	59                   	pop    %ecx
c0103ec6:	58                   	pop    %eax
c0103ec7:	8d 83 9d 86 fe ff    	lea    -0x17963(%ebx),%eax
c0103ecd:	50                   	push   %eax
c0103ece:	56                   	push   %esi
c0103ecf:	e8 7c 07 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103ed4:	58                   	pop    %eax
c0103ed5:	5a                   	pop    %edx
c0103ed6:	56                   	push   %esi
c0103ed7:	57                   	push   %edi
c0103ed8:	e8 13 dd ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0103edd:	89 34 24             	mov    %esi,(%esp)
c0103ee0:	e8 85 07 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103ee5:	89 3c 24             	mov    %edi,(%esp)
c0103ee8:	e8 17 dc ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c0103eed:	fa                   	cli    
    asm volatile ("hlt");
c0103eee:	f4                   	hlt    
c0103eef:	89 3c 24             	mov    %edi,(%esp)
c0103ef2:	e8 4f dc ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c0103ef7:	83 c4 10             	add    $0x10,%esp
    for (i = 5; i <= 5 * step2; i +=5) {
c0103efa:	83 85 8c fb ff ff 05 	addl   $0x5,-0x474(%ebp)
c0103f01:	e9 ea fa ff ff       	jmp    c01039f0 <_ZN3VMM8checkVmaEv+0x46e>
    OStream out("\ncheckVma(): vmaBelow5 [i, start, end]\n", "blue");
c0103f06:	56                   	push   %esi
c0103f07:	56                   	push   %esi
c0103f08:	8d 83 fa 82 fe ff    	lea    -0x17d06(%ebx),%eax
c0103f0e:	50                   	push   %eax
c0103f0f:	8d b5 c0 fd ff ff    	lea    -0x240(%ebp),%esi
c0103f15:	56                   	push   %esi
c0103f16:	e8 35 07 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103f1b:	5f                   	pop    %edi
c0103f1c:	8d bd 95 fb ff ff    	lea    -0x46b(%ebp),%edi
c0103f22:	58                   	pop    %eax
c0103f23:	8d 83 d4 86 fe ff    	lea    -0x1792c(%ebx),%eax
c0103f29:	50                   	push   %eax
c0103f2a:	57                   	push   %edi
c0103f2b:	e8 20 07 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103f30:	83 c4 0c             	add    $0xc,%esp
c0103f33:	56                   	push   %esi
c0103f34:	57                   	push   %edi
c0103f35:	8d 85 9a fb ff ff    	lea    -0x466(%ebp),%eax
c0103f3b:	50                   	push   %eax
c0103f3c:	e8 25 db ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0103f41:	89 3c 24             	mov    %edi,(%esp)
c0103f44:	e8 21 07 00 00       	call   c010466a <_ZN6StringD1Ev>
c0103f49:	89 34 24             	mov    %esi,(%esp)
c0103f4c:	e8 19 07 00 00       	call   c010466a <_ZN6StringD1Ev>
    for (i =4; i>=0; i--) {
c0103f51:	83 c4 10             	add    $0x10,%esp
c0103f54:	c7 85 8c fb ff ff 04 	movl   $0x4,-0x474(%ebp)
c0103f5b:	00 00 00 
        auto *vma_below_5= findVma(mm,i);
c0103f5e:	51                   	push   %ecx
c0103f5f:	ff b5 8c fb ff ff    	pushl  -0x474(%ebp)
c0103f65:	ff b5 84 fb ff ff    	pushl  -0x47c(%ebp)
c0103f6b:	ff 75 08             	pushl  0x8(%ebp)
c0103f6e:	e8 d9 f0 ff ff       	call   c010304c <_ZN3VMM7findVmaEPN4ListINS_2MMEE6DLNodeEj>
        if (vma_below_5 != nullptr ) {
c0103f73:	83 c4 10             	add    $0x10,%esp
c0103f76:	85 c0                	test   %eax,%eax
c0103f78:	89 85 80 fb ff ff    	mov    %eax,-0x480(%ebp)
c0103f7e:	0f 84 45 01 00 00    	je     c01040c9 <_ZN3VMM8checkVmaEv+0xb47>
           out.writeValue(i);
c0103f84:	50                   	push   %eax
c0103f85:	50                   	push   %eax
c0103f86:	8d 95 8c fb ff ff    	lea    -0x474(%ebp),%edx
c0103f8c:	52                   	push   %edx
c0103f8d:	8d bd 9a fb ff ff    	lea    -0x466(%ebp),%edi
c0103f93:	57                   	push   %edi
c0103f94:	e8 9b dc ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
           out.write(", ");
c0103f99:	8d b5 c0 fd ff ff    	lea    -0x240(%ebp),%esi
c0103f9f:	5a                   	pop    %edx
c0103fa0:	8d 93 fc 86 fe ff    	lea    -0x17904(%ebx),%edx
c0103fa6:	59                   	pop    %ecx
c0103fa7:	89 95 7c fb ff ff    	mov    %edx,-0x484(%ebp)
c0103fad:	52                   	push   %edx
c0103fae:	56                   	push   %esi
c0103faf:	e8 9c 06 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103fb4:	58                   	pop    %eax
c0103fb5:	5a                   	pop    %edx
c0103fb6:	56                   	push   %esi
c0103fb7:	57                   	push   %edi
c0103fb8:	e8 33 dc ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0103fbd:	89 34 24             	mov    %esi,(%esp)
c0103fc0:	e8 a5 06 00 00       	call   c010466a <_ZN6StringD1Ev>
           out.writeValue(vma_below_5->data.vm_start);
c0103fc5:	8b 85 80 fb ff ff    	mov    -0x480(%ebp),%eax
c0103fcb:	8b 48 04             	mov    0x4(%eax),%ecx
c0103fce:	89 8d c0 fd ff ff    	mov    %ecx,-0x240(%ebp)
c0103fd4:	59                   	pop    %ecx
c0103fd5:	58                   	pop    %eax
c0103fd6:	56                   	push   %esi
c0103fd7:	57                   	push   %edi
c0103fd8:	e8 57 dc ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
           out.write(", ");
c0103fdd:	58                   	pop    %eax
c0103fde:	5a                   	pop    %edx
c0103fdf:	8b 95 7c fb ff ff    	mov    -0x484(%ebp),%edx
c0103fe5:	52                   	push   %edx
c0103fe6:	56                   	push   %esi
c0103fe7:	e8 64 06 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0103fec:	59                   	pop    %ecx
c0103fed:	58                   	pop    %eax
c0103fee:	56                   	push   %esi
c0103fef:	57                   	push   %edi
c0103ff0:	e8 fb db ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0103ff5:	89 34 24             	mov    %esi,(%esp)
c0103ff8:	e8 6d 06 00 00       	call   c010466a <_ZN6StringD1Ev>
           out.writeValue(vma_below_5->data.vm_end);
c0103ffd:	8b 85 80 fb ff ff    	mov    -0x480(%ebp),%eax
c0104003:	8b 40 08             	mov    0x8(%eax),%eax
c0104006:	89 85 c0 fd ff ff    	mov    %eax,-0x240(%ebp)
c010400c:	58                   	pop    %eax
c010400d:	5a                   	pop    %edx
c010400e:	56                   	push   %esi
c010400f:	57                   	push   %edi
c0104010:	e8 1f dc ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
           out.write("\n");
c0104015:	59                   	pop    %ecx
c0104016:	58                   	pop    %eax
c0104017:	8d 83 13 83 fe ff    	lea    -0x17ced(%ebx),%eax
c010401d:	50                   	push   %eax
c010401e:	56                   	push   %esi
c010401f:	e8 2c 06 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0104024:	58                   	pop    %eax
c0104025:	5a                   	pop    %edx
c0104026:	56                   	push   %esi
c0104027:	57                   	push   %edi
c0104028:	e8 c3 db ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c010402d:	89 34 24             	mov    %esi,(%esp)
c0104030:	e8 35 06 00 00       	call   c010466a <_ZN6StringD1Ev>
           out.flush();
c0104035:	89 3c 24             	mov    %edi,(%esp)
c0104038:	e8 c7 da ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
        assert(vma_below_5 == nullptr);
c010403d:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c0104043:	59                   	pop    %ecx
c0104044:	5f                   	pop    %edi
c0104045:	8d bd 95 fb ff ff    	lea    -0x46b(%ebp),%edi
c010404b:	50                   	push   %eax
c010404c:	57                   	push   %edi
c010404d:	e8 fe 05 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0104052:	58                   	pop    %eax
c0104053:	8d 83 1f 83 fe ff    	lea    -0x17ce1(%ebx),%eax
c0104059:	5a                   	pop    %edx
c010405a:	50                   	push   %eax
c010405b:	8d 85 90 fb ff ff    	lea    -0x470(%ebp),%eax
c0104061:	50                   	push   %eax
c0104062:	89 85 80 fb ff ff    	mov    %eax,-0x480(%ebp)
c0104068:	e8 e3 05 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010406d:	8b 85 80 fb ff ff    	mov    -0x480(%ebp),%eax
c0104073:	83 c4 0c             	add    $0xc,%esp
c0104076:	57                   	push   %edi
c0104077:	50                   	push   %eax
c0104078:	56                   	push   %esi
c0104079:	e8 e8 d9 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c010407e:	8b 85 80 fb ff ff    	mov    -0x480(%ebp),%eax
c0104084:	89 04 24             	mov    %eax,(%esp)
c0104087:	e8 de 05 00 00       	call   c010466a <_ZN6StringD1Ev>
c010408c:	89 3c 24             	mov    %edi,(%esp)
c010408f:	e8 d6 05 00 00       	call   c010466a <_ZN6StringD1Ev>
c0104094:	59                   	pop    %ecx
c0104095:	58                   	pop    %eax
c0104096:	8d 83 ff 86 fe ff    	lea    -0x17901(%ebx),%eax
c010409c:	50                   	push   %eax
c010409d:	57                   	push   %edi
c010409e:	e8 ad 05 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01040a3:	58                   	pop    %eax
c01040a4:	5a                   	pop    %edx
c01040a5:	57                   	push   %edi
c01040a6:	56                   	push   %esi
c01040a7:	e8 44 db ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c01040ac:	89 3c 24             	mov    %edi,(%esp)
c01040af:	e8 b6 05 00 00       	call   c010466a <_ZN6StringD1Ev>
c01040b4:	89 34 24             	mov    %esi,(%esp)
c01040b7:	e8 48 da ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    asm volatile ("cli");
c01040bc:	fa                   	cli    
    asm volatile ("hlt");
c01040bd:	f4                   	hlt    
c01040be:	89 34 24             	mov    %esi,(%esp)
c01040c1:	e8 80 da ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
c01040c6:	83 c4 10             	add    $0x10,%esp
    for (i =4; i>=0; i--) {
c01040c9:	ff 8d 8c fb ff ff    	decl   -0x474(%ebp)
    }
c01040cf:	e9 8a fe ff ff       	jmp    c0103f5e <_ZN3VMM8checkVmaEv+0x9dc>

c01040d4 <_ZN3VMM8checkVmmEv>:
void VMM::checkVmm() {
c01040d4:	55                   	push   %ebp
c01040d5:	89 e5                	mov    %esp,%ebp
c01040d7:	57                   	push   %edi
c01040d8:	56                   	push   %esi
c01040d9:	53                   	push   %ebx
c01040da:	e8 d6 ca ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c01040df:	81 c3 31 83 01 00    	add    $0x18331,%ebx
c01040e5:	81 ec 64 02 00 00    	sub    $0x264,%esp
    DEBUGPRINT("checkVmm");
c01040eb:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c01040f1:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c01040f7:	8d 93 15 83 fe ff    	lea    -0x17ceb(%ebx),%edx
c01040fd:	52                   	push   %edx
c01040fe:	56                   	push   %esi
c01040ff:	89 95 a0 fd ff ff    	mov    %edx,-0x260(%ebp)
c0104105:	e8 46 05 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010410a:	58                   	pop    %eax
c010410b:	8d 83 c1 84 fe ff    	lea    -0x17b3f(%ebx),%eax
c0104111:	5a                   	pop    %edx
c0104112:	50                   	push   %eax
c0104113:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c0104119:	50                   	push   %eax
c010411a:	89 85 a4 fd ff ff    	mov    %eax,-0x25c(%ebp)
c0104120:	e8 2b 05 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0104125:	83 c4 0c             	add    $0xc,%esp
c0104128:	56                   	push   %esi
c0104129:	ff b5 a4 fd ff ff    	pushl  -0x25c(%ebp)
c010412f:	57                   	push   %edi
c0104130:	e8 31 d9 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0104135:	59                   	pop    %ecx
c0104136:	ff b5 a4 fd ff ff    	pushl  -0x25c(%ebp)
c010413c:	e8 29 05 00 00       	call   c010466a <_ZN6StringD1Ev>
c0104141:	89 34 24             	mov    %esi,(%esp)
c0104144:	e8 21 05 00 00       	call   c010466a <_ZN6StringD1Ev>
c0104149:	58                   	pop    %eax
c010414a:	8d 83 16 87 fe ff    	lea    -0x178ea(%ebx),%eax
c0104150:	5a                   	pop    %edx
c0104151:	50                   	push   %eax
c0104152:	56                   	push   %esi
c0104153:	e8 f8 04 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0104158:	59                   	pop    %ecx
c0104159:	58                   	pop    %eax
c010415a:	56                   	push   %esi
c010415b:	57                   	push   %edi
c010415c:	e8 8f da ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c0104161:	89 34 24             	mov    %esi,(%esp)
c0104164:	e8 01 05 00 00       	call   c010466a <_ZN6StringD1Ev>
c0104169:	89 3c 24             	mov    %edi,(%esp)
c010416c:	e8 93 d9 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
c0104171:	89 3c 24             	mov    %edi,(%esp)
c0104174:	e8 cd d9 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
    uint32_t nr_free_pages_store = kernel::pmm.numFreePages();
c0104179:	58                   	pop    %eax
c010417a:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
c0104180:	e8 37 e9 ff ff       	call   c0102abc <_ZN5PhyMM12numFreePagesEv>
c0104185:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
    OStream out("\ncheckVMM : ", "red");
c010418b:	58                   	pop    %eax
c010418c:	5a                   	pop    %edx
c010418d:	8b 95 a0 fd ff ff    	mov    -0x260(%ebp),%edx
c0104193:	52                   	push   %edx
c0104194:	56                   	push   %esi
c0104195:	e8 b6 04 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010419a:	59                   	pop    %ecx
c010419b:	58                   	pop    %eax
c010419c:	8d 83 1f 87 fe ff    	lea    -0x178e1(%ebx),%eax
c01041a2:	50                   	push   %eax
c01041a3:	ff b5 a4 fd ff ff    	pushl  -0x25c(%ebp)
c01041a9:	e8 a2 04 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c01041ae:	83 c4 0c             	add    $0xc,%esp
c01041b1:	56                   	push   %esi
c01041b2:	ff b5 a4 fd ff ff    	pushl  -0x25c(%ebp)
c01041b8:	57                   	push   %edi
c01041b9:	e8 a8 d8 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c01041be:	58                   	pop    %eax
c01041bf:	ff b5 a4 fd ff ff    	pushl  -0x25c(%ebp)
c01041c5:	e8 a0 04 00 00       	call   c010466a <_ZN6StringD1Ev>
c01041ca:	89 34 24             	mov    %esi,(%esp)
c01041cd:	e8 98 04 00 00       	call   c010466a <_ZN6StringD1Ev>
    out.writeValue(nr_free_pages_store);
c01041d2:	58                   	pop    %eax
c01041d3:	8d 85 b4 fd ff ff    	lea    -0x24c(%ebp),%eax
c01041d9:	5a                   	pop    %edx
c01041da:	50                   	push   %eax
c01041db:	57                   	push   %edi
c01041dc:	e8 53 da ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
    out.flush();
c01041e1:	89 3c 24             	mov    %edi,(%esp)
c01041e4:	e8 1b d9 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
    checkVma();
c01041e9:	59                   	pop    %ecx
c01041ea:	ff 75 08             	pushl  0x8(%ebp)
c01041ed:	e8 90 f3 ff ff       	call   c0103582 <_ZN3VMM8checkVmaEv>

c01041f2 <_ZN3VMM7vmmInitEv>:
void VMM::vmmInit() {
c01041f2:	55                   	push   %ebp
c01041f3:	89 e5                	mov    %esp,%ebp
c01041f5:	57                   	push   %edi
c01041f6:	56                   	push   %esi
c01041f7:	53                   	push   %ebx
c01041f8:	e8 b8 c9 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c01041fd:	81 c3 13 82 01 00    	add    $0x18213,%ebx
c0104203:	81 ec 54 02 00 00    	sub    $0x254,%esp
    DEBUGPRINT("vmmInit");
c0104209:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c010420f:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
c0104215:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c010421b:	50                   	push   %eax
c010421c:	56                   	push   %esi
c010421d:	e8 2e 04 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0104222:	58                   	pop    %eax
c0104223:	8d 83 c1 84 fe ff    	lea    -0x17b3f(%ebx),%eax
c0104229:	5a                   	pop    %edx
c010422a:	50                   	push   %eax
c010422b:	8d 85 b8 fd ff ff    	lea    -0x248(%ebp),%eax
c0104231:	50                   	push   %eax
c0104232:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c0104238:	e8 13 04 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010423d:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0104243:	83 c4 0c             	add    $0xc,%esp
c0104246:	56                   	push   %esi
c0104247:	50                   	push   %eax
c0104248:	57                   	push   %edi
c0104249:	e8 18 d8 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c010424e:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0104254:	89 04 24             	mov    %eax,(%esp)
c0104257:	e8 0e 04 00 00       	call   c010466a <_ZN6StringD1Ev>
c010425c:	89 34 24             	mov    %esi,(%esp)
c010425f:	e8 06 04 00 00       	call   c010466a <_ZN6StringD1Ev>
c0104264:	59                   	pop    %ecx
c0104265:	58                   	pop    %eax
c0104266:	8d 83 2c 87 fe ff    	lea    -0x178d4(%ebx),%eax
c010426c:	50                   	push   %eax
c010426d:	56                   	push   %esi
c010426e:	e8 dd 03 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0104273:	58                   	pop    %eax
c0104274:	5a                   	pop    %edx
c0104275:	56                   	push   %esi
c0104276:	57                   	push   %edi
c0104277:	e8 74 d9 ff ff       	call   c0101bf0 <_ZN7OStream5writeERK6String>
c010427c:	89 34 24             	mov    %esi,(%esp)
c010427f:	e8 e6 03 00 00       	call   c010466a <_ZN6StringD1Ev>
c0104284:	89 3c 24             	mov    %edi,(%esp)
c0104287:	e8 78 d8 ff ff       	call   c0101b04 <_ZN7OStream5flushEv>
c010428c:	89 3c 24             	mov    %edi,(%esp)
c010428f:	e8 b2 d8 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
    checkVmm();
c0104294:	59                   	pop    %ecx
c0104295:	ff 75 08             	pushl  0x8(%ebp)
c0104298:	e8 37 fe ff ff       	call   c01040d4 <_ZN3VMM8checkVmmEv>
c010429d:	90                   	nop

c010429e <_ZN3MMUC1Ev>:
#include <mmu.h>
#include <ostream.h>

MMU::MMU() {
c010429e:	55                   	push   %ebp
c010429f:	89 e5                	mov    %esp,%ebp

}
c01042a1:	5d                   	pop    %ebp
c01042a2:	c3                   	ret    
c01042a3:	90                   	nop

c01042a4 <_ZN3MMU10setSegDescEjjjj>:

MMU::SegDesc MMU::setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
c01042a4:	55                   	push   %ebp
c01042a5:	89 e5                	mov    %esp,%ebp
c01042a7:	57                   	push   %edi
c01042a8:	56                   	push   %esi
c01042a9:	53                   	push   %ebx
c01042aa:	81 ec 54 02 00 00    	sub    $0x254,%esp
c01042b0:	8b 75 08             	mov    0x8(%ebp),%esi
    sd.sd_avl = 0;
    sd.sd_l = 0;
    sd.sd_db = 1;
    sd.sd_g = 1;
    sd.sd_base_31_24 = (uint16_t)(base >> 24);
    OStream out("\nsetGDT-->Desc type ", "red");
c01042b3:	8d bd c2 fd ff ff    	lea    -0x23e(%ebp),%edi
MMU::SegDesc MMU::setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
c01042b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
    sd.sd_lim_15_0 = lim & 0xffff;
c01042bc:	0f b7 45 14          	movzwl 0x14(%ebp),%eax
    sd.sd_type = type;
c01042c0:	8a 55 0c             	mov    0xc(%ebp),%dl
c01042c3:	e8 ed c8 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c01042c8:	81 c3 48 81 01 00    	add    $0x18148,%ebx
    sd.sd_lim_15_0 = lim & 0xffff;
c01042ce:	88 06                	mov    %al,(%esi)
c01042d0:	88 66 01             	mov    %ah,0x1(%esi)
    sd.sd_base_15_0 = (base) & 0xffff;
c01042d3:	0f b7 c1             	movzwl %cx,%eax
    sd.sd_type = type;
c01042d6:	80 e2 0f             	and    $0xf,%dl
    sd.sd_base_15_0 = (base) & 0xffff;
c01042d9:	88 46 02             	mov    %al,0x2(%esi)
c01042dc:	88 66 03             	mov    %ah,0x3(%esi)
    sd.sd_base_23_16 = ((base) >> 16) & 0xff;
c01042df:	89 c8                	mov    %ecx,%eax
c01042e1:	c1 e8 10             	shr    $0x10,%eax
c01042e4:	88 46 04             	mov    %al,0x4(%esi)
    sd.sd_type = type;
c01042e7:	8a 46 05             	mov    0x5(%esi),%al
    sd.sd_base_31_24 = (uint16_t)(base >> 24);
c01042ea:	c1 e9 18             	shr    $0x18,%ecx
c01042ed:	88 4e 07             	mov    %cl,0x7(%esi)
    sd.sd_type = type;
c01042f0:	24 f0                	and    $0xf0,%al
c01042f2:	08 d0                	or     %dl,%al
    sd.sd_dpl = dpl;
c01042f4:	8a 55 18             	mov    0x18(%ebp),%dl
    sd.sd_s = 1;
c01042f7:	0c 10                	or     $0x10,%al
    sd.sd_dpl = dpl;
c01042f9:	24 9f                	and    $0x9f,%al
c01042fb:	80 e2 03             	and    $0x3,%dl
c01042fe:	c0 e2 05             	shl    $0x5,%dl
c0104301:	08 d0                	or     %dl,%al
    sd.sd_p = 1;
c0104303:	0c 80                	or     $0x80,%al
c0104305:	88 46 05             	mov    %al,0x5(%esi)
    sd.sd_lim_19_16 = (uint16_t)(lim >> 16);
c0104308:	8b 45 14             	mov    0x14(%ebp),%eax
c010430b:	c1 e8 10             	shr    $0x10,%eax
c010430e:	24 0f                	and    $0xf,%al
    sd.sd_g = 1;
c0104310:	0c c0                	or     $0xc0,%al
c0104312:	88 46 06             	mov    %al,0x6(%esi)
    OStream out("\nsetGDT-->Desc type ", "red");
c0104315:	8d 83 15 83 fe ff    	lea    -0x17ceb(%ebx),%eax
c010431b:	50                   	push   %eax
c010431c:	8d 85 bd fd ff ff    	lea    -0x243(%ebp),%eax
c0104322:	50                   	push   %eax
c0104323:	89 85 b0 fd ff ff    	mov    %eax,-0x250(%ebp)
c0104329:	e8 22 03 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c010432e:	58                   	pop    %eax
c010432f:	5a                   	pop    %edx
c0104330:	8d 93 34 87 fe ff    	lea    -0x178cc(%ebx),%edx
c0104336:	52                   	push   %edx
c0104337:	8d 95 b8 fd ff ff    	lea    -0x248(%ebp),%edx
c010433d:	52                   	push   %edx
c010433e:	89 95 b4 fd ff ff    	mov    %edx,-0x24c(%ebp)
c0104344:	e8 07 03 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0104349:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c010434f:	83 c4 0c             	add    $0xc,%esp
c0104352:	8b 95 b4 fd ff ff    	mov    -0x24c(%ebp),%edx
c0104358:	50                   	push   %eax
c0104359:	52                   	push   %edx
c010435a:	57                   	push   %edi
c010435b:	e8 06 d7 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c0104360:	8b 95 b4 fd ff ff    	mov    -0x24c(%ebp),%edx
c0104366:	89 14 24             	mov    %edx,(%esp)
c0104369:	e8 fc 02 00 00       	call   c010466a <_ZN6StringD1Ev>
c010436e:	8b 85 b0 fd ff ff    	mov    -0x250(%ebp),%eax
c0104374:	89 04 24             	mov    %eax,(%esp)
c0104377:	e8 ee 02 00 00       	call   c010466a <_ZN6StringD1Ev>
    out.writeValue(type);
c010437c:	59                   	pop    %ecx
c010437d:	58                   	pop    %eax
c010437e:	8d 45 0c             	lea    0xc(%ebp),%eax
c0104381:	50                   	push   %eax
c0104382:	57                   	push   %edi
c0104383:	e8 ac d8 ff ff       	call   c0101c34 <_ZN7OStream10writeValueERKj>
    OStream out("\nsetGDT-->Desc type ", "red");
c0104388:	89 3c 24             	mov    %edi,(%esp)
c010438b:	e8 b6 d7 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
    return sd;
}
c0104390:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0104393:	89 f0                	mov    %esi,%eax
c0104395:	5b                   	pop    %ebx
c0104396:	5e                   	pop    %esi
c0104397:	5f                   	pop    %edi
c0104398:	5d                   	pop    %ebp
c0104399:	c2 04 00             	ret    $0x4

c010439c <_ZN3MMU10setTssDescEjjjj>:

MMU::SegDesc MMU::setTssDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
c010439c:	55                   	push   %ebp
c010439d:	89 e5                	mov    %esp,%ebp
c010439f:	8b 55 14             	mov    0x14(%ebp),%edx
c01043a2:	56                   	push   %esi
c01043a3:	8b 45 08             	mov    0x8(%ebp),%eax
c01043a6:	8b 75 10             	mov    0x10(%ebp),%esi
c01043a9:	53                   	push   %ebx
    td.sd_lim_15_0 = lim & 0xffff;
    td.sd_base_15_0 = (base) & 0xffff;
    td.sd_base_23_16 = ((base) >> 16) & 0xff;
    td.sd_type = type;
    td.sd_s = 0;
    td.sd_dpl = dpl;
c01043aa:	8a 5d 18             	mov    0x18(%ebp),%bl
    td.sd_lim_15_0 = lim & 0xffff;
c01043ad:	0f b7 ca             	movzwl %dx,%ecx
c01043b0:	88 08                	mov    %cl,(%eax)
    td.sd_p = 1;
    td.sd_lim_19_16 = (uint16_t)(lim >> 16);
c01043b2:	c1 ea 10             	shr    $0x10,%edx
    td.sd_lim_15_0 = lim & 0xffff;
c01043b5:	88 68 01             	mov    %ch,0x1(%eax)
    td.sd_base_15_0 = (base) & 0xffff;
c01043b8:	0f b7 ce             	movzwl %si,%ecx
    td.sd_lim_19_16 = (uint16_t)(lim >> 16);
c01043bb:	80 e2 0f             	and    $0xf,%dl
    td.sd_base_15_0 = (base) & 0xffff;
c01043be:	88 48 02             	mov    %cl,0x2(%eax)
    td.sd_dpl = dpl;
c01043c1:	80 e3 03             	and    $0x3,%bl
    td.sd_avl = 0;
    td.sd_l = 0;
    td.sd_db = 1;
    td.sd_g = 0;
c01043c4:	80 ca 40             	or     $0x40,%dl
    td.sd_base_15_0 = (base) & 0xffff;
c01043c7:	88 68 03             	mov    %ch,0x3(%eax)
    td.sd_base_23_16 = ((base) >> 16) & 0xff;
c01043ca:	89 f1                	mov    %esi,%ecx
c01043cc:	c1 e9 10             	shr    $0x10,%ecx
c01043cf:	88 48 04             	mov    %cl,0x4(%eax)
    td.sd_type = type;
c01043d2:	8a 4d 0c             	mov    0xc(%ebp),%cl
    td.sd_dpl = dpl;
c01043d5:	c0 e3 05             	shl    $0x5,%bl
    td.sd_base_31_24 = (uint16_t)(base >> 24);
c01043d8:	c1 ee 18             	shr    $0x18,%esi
    td.sd_g = 0;
c01043db:	88 50 06             	mov    %dl,0x6(%eax)
    td.sd_base_31_24 = (uint16_t)(base >> 24);
c01043de:	89 f2                	mov    %esi,%edx
c01043e0:	88 50 07             	mov    %dl,0x7(%eax)
    td.sd_type = type;
c01043e3:	80 e1 0f             	and    $0xf,%cl
    td.sd_dpl = dpl;
c01043e6:	08 d9                	or     %bl,%cl
    td.sd_p = 1;
c01043e8:	80 c9 80             	or     $0x80,%cl
c01043eb:	88 48 05             	mov    %cl,0x5(%eax)
    return td;                                      
}
c01043ee:	5b                   	pop    %ebx
c01043ef:	5e                   	pop    %esi
c01043f0:	5d                   	pop    %ebp
c01043f1:	c2 04 00             	ret    $0x4

c01043f4 <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>:

void MMU::setGateDesc(GateDesc &gate, uint32_t istrap, uint32_t sel, uint32_t off, uint32_t dpl) {
c01043f4:	55                   	push   %ebp
c01043f5:	89 e5                	mov    %esp,%ebp
c01043f7:	8b 55 14             	mov    0x14(%ebp),%edx
c01043fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01043fd:	53                   	push   %ebx
    gate.gd_ss = (sel);
    gate.gd_args = 0;                                    
    gate.gd_rsv1 = 0;                                    
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
    gate.gd_s = 0;                                    
    gate.gd_dpl = (dpl);                               
c01043fe:	8a 5d 18             	mov    0x18(%ebp),%bl
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c0104401:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
c0104405:	0f b7 ca             	movzwl %dx,%ecx
c0104408:	88 08                	mov    %cl,(%eax)
c010440a:	88 68 01             	mov    %ch,0x1(%eax)
    gate.gd_ss = (sel);
c010440d:	0f b7 4d 10          	movzwl 0x10(%ebp),%ecx
    gate.gd_args = 0;                                    
c0104411:	c6 40 04 00          	movb   $0x0,0x4(%eax)
    gate.gd_ss = (sel);
c0104415:	88 48 02             	mov    %cl,0x2(%eax)
c0104418:	88 68 03             	mov    %ch,0x3(%eax)
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c010441b:	0f 95 c1             	setne  %cl
    gate.gd_dpl = (dpl);                               
c010441e:	80 e3 03             	and    $0x3,%bl
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c0104421:	80 c1 0e             	add    $0xe,%cl
    gate.gd_dpl = (dpl);                               
c0104424:	c0 e3 05             	shl    $0x5,%bl
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c0104427:	80 e1 0f             	and    $0xf,%cl
    gate.gd_dpl = (dpl);                               
c010442a:	08 d9                	or     %bl,%cl
    gate.gd_p = 1;                                    
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;        
c010442c:	c1 ea 10             	shr    $0x10,%edx
    gate.gd_p = 1;                                    
c010442f:	80 c9 80             	or     $0x80,%cl
c0104432:	88 48 05             	mov    %cl,0x5(%eax)
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;        
c0104435:	88 50 06             	mov    %dl,0x6(%eax)
c0104438:	88 70 07             	mov    %dh,0x7(%eax)
}
c010443b:	5b                   	pop    %ebx
c010443c:	5d                   	pop    %ebp
c010443d:	c3                   	ret    

c010443e <_ZN3MMU11setCallGateERNS_8GateDescEjjj>:

void MMU::setCallGate(GateDesc &gate, uint32_t ss, uint32_t off, uint32_t dpl) {
c010443e:	55                   	push   %ebp
c010443f:	89 e5                	mov    %esp,%ebp
c0104441:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0104444:	8b 45 08             	mov    0x8(%ebp),%eax
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
c0104447:	0f b7 d1             	movzwl %cx,%edx
c010444a:	88 10                	mov    %dl,(%eax)
    gate.gd_rsv1 = 0;                                  
    gate.gd_type = STS_CG32;                          
    gate.gd_s = 0;                                   
    gate.gd_dpl = (dpl);                              
    gate.gd_p = 1;                                  
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;     
c010444c:	c1 e9 10             	shr    $0x10,%ecx
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
c010444f:	88 70 01             	mov    %dh,0x1(%eax)
    gate.gd_ss = (ss);                                
c0104452:	0f b7 55 0c          	movzwl 0xc(%ebp),%edx
    gate.gd_rsv1 = 0;                                  
c0104456:	c6 40 04 00          	movb   $0x0,0x4(%eax)
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;     
c010445a:	88 48 06             	mov    %cl,0x6(%eax)
c010445d:	88 68 07             	mov    %ch,0x7(%eax)
    gate.gd_ss = (ss);                                
c0104460:	88 50 02             	mov    %dl,0x2(%eax)
c0104463:	88 70 03             	mov    %dh,0x3(%eax)
    gate.gd_dpl = (dpl);                              
c0104466:	8a 55 14             	mov    0x14(%ebp),%dl
c0104469:	80 e2 03             	and    $0x3,%dl
c010446c:	c0 e2 05             	shl    $0x5,%dl
    gate.gd_p = 1;                                  
c010446f:	80 ca 8c             	or     $0x8c,%dl
c0104472:	88 50 05             	mov    %dl,0x5(%eax)
}
c0104475:	5d                   	pop    %ebp
c0104476:	c3                   	ret    
c0104477:	90                   	nop

c0104478 <_ZN3MMU6setTCBEv>:

void MMU::setTCB() {
c0104478:	55                   	push   %ebp
c0104479:	89 e5                	mov    %esp,%ebp

}
c010447b:	5d                   	pop    %ebp
c010447c:	c3                   	ret    
c010447d:	90                   	nop

c010447e <_ZN3MMU15setPageReservedERNS_4PageE>:

void MMU::setPageReserved(Page &p) {
c010447e:	55                   	push   %ebp
c010447f:	89 e5                	mov    %esp,%ebp
c0104481:	8b 45 08             	mov    0x8(%ebp),%eax
    p.status |= 0x1;
c0104484:	80 48 04 01          	orb    $0x1,0x4(%eax)
}
c0104488:	5d                   	pop    %ebp
c0104489:	c3                   	ret    

c010448a <_ZN3MMU15setPagePropertyERNS_4PageE>:

void MMU::setPageProperty(Page &p) {
c010448a:	55                   	push   %ebp
c010448b:	89 e5                	mov    %esp,%ebp
c010448d:	8b 45 08             	mov    0x8(%ebp),%eax
    p.status |= 0x2;
c0104490:	80 48 04 02          	orb    $0x2,0x4(%eax)
}
c0104494:	5d                   	pop    %ebp
c0104495:	c3                   	ret    

c0104496 <_ZN3MMU17clearPagePropertyERNS_4PageE>:

void MMU::clearPageProperty(Page &p) {
c0104496:	55                   	push   %ebp
c0104497:	89 e5                	mov    %esp,%ebp
c0104499:	8b 45 08             	mov    0x8(%ebp),%eax
    p.status &= ~(0x2);                 // clear 2-bits to 0
c010449c:	80 60 04 fd          	andb   $0xfd,0x4(%eax)
}
c01044a0:	5d                   	pop    %ebp
c01044a1:	c3                   	ret    

c01044a2 <_ZN3MMU3LADEj>:

MMU::LinearAD MMU::LAD(uptr32_t vAd) {
c01044a2:	55                   	push   %ebp
c01044a3:	89 e5                	mov    %esp,%ebp
c01044a5:	8b 55 10             	mov    0x10(%ebp),%edx
c01044a8:	53                   	push   %ebx
c01044a9:	8b 45 08             	mov    0x8(%ebp),%eax
    LinearAD lad;
    lad.OFF = vAd & 0xFFF;
c01044ac:	89 d1                	mov    %edx,%ecx
    lad.PTI = (vAd >> PGSHIFT) & 0x3FF;
c01044ae:	89 d3                	mov    %edx,%ebx
    lad.OFF = vAd & 0xFFF;
c01044b0:	c1 e9 08             	shr    $0x8,%ecx
    lad.PTI = (vAd >> PGSHIFT) & 0x3FF;
c01044b3:	c1 eb 0c             	shr    $0xc,%ebx
c01044b6:	80 e1 0f             	and    $0xf,%cl
c01044b9:	c0 e3 04             	shl    $0x4,%bl
c01044bc:	08 d9                	or     %bl,%cl
    lad.PDI = (vAd >> PTSHIFT) & 0x3FF;
c01044be:	89 d3                	mov    %edx,%ebx
    lad.PTI = (vAd >> PGSHIFT) & 0x3FF;
c01044c0:	88 48 01             	mov    %cl,0x1(%eax)
c01044c3:	89 d1                	mov    %edx,%ecx
c01044c5:	c1 e9 10             	shr    $0x10,%ecx
    lad.PDI = (vAd >> PTSHIFT) & 0x3FF;
c01044c8:	c1 eb 16             	shr    $0x16,%ebx
c01044cb:	80 e1 3f             	and    $0x3f,%cl
c01044ce:	c0 e3 06             	shl    $0x6,%bl
    lad.OFF = vAd & 0xFFF;
c01044d1:	88 10                	mov    %dl,(%eax)
    lad.PDI = (vAd >> PTSHIFT) & 0x3FF;
c01044d3:	08 d9                	or     %bl,%cl
c01044d5:	c1 ea 18             	shr    $0x18,%edx
c01044d8:	88 48 02             	mov    %cl,0x2(%eax)
c01044db:	88 50 03             	mov    %dl,0x3(%eax)
    return lad;
c01044de:	5b                   	pop    %ebx
c01044df:	5d                   	pop    %ebp
c01044e0:	c2 04 00             	ret    $0x4
c01044e3:	90                   	nop

c01044e4 <_ZN4Trap4trapEv>:
#include <trap.h>
#include <ostream.h>

void Trap::trap() {
c01044e4:	55                   	push   %ebp
c01044e5:	89 e5                	mov    %esp,%ebp
c01044e7:	57                   	push   %edi
c01044e8:	56                   	push   %esi
c01044e9:	53                   	push   %ebx
c01044ea:	e8 c6 c6 ff ff       	call   c0100bb5 <__x86.get_pc_thunk.bx>
c01044ef:	81 c3 21 7f 01 00    	add    $0x17f21,%ebx
c01044f5:	81 ec 54 02 00 00    	sub    $0x254,%esp
    OStream out("interrupt...\n", "blue");
c01044fb:	8d b5 bd fd ff ff    	lea    -0x243(%ebp),%esi
c0104501:	8d bd b8 fd ff ff    	lea    -0x248(%ebp),%edi
c0104507:	8d 83 fa 82 fe ff    	lea    -0x17d06(%ebx),%eax
c010450d:	50                   	push   %eax
c010450e:	56                   	push   %esi
c010450f:	e8 3c 01 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0104514:	58                   	pop    %eax
c0104515:	8d 83 49 87 fe ff    	lea    -0x178b7(%ebx),%eax
c010451b:	5a                   	pop    %edx
c010451c:	50                   	push   %eax
c010451d:	57                   	push   %edi
c010451e:	e8 2d 01 00 00       	call   c0104650 <_ZN6StringC1EPKc>
c0104523:	83 c4 0c             	add    $0xc,%esp
c0104526:	56                   	push   %esi
c0104527:	57                   	push   %edi
c0104528:	8d 85 c2 fd ff ff    	lea    -0x23e(%ebp),%eax
c010452e:	50                   	push   %eax
c010452f:	89 85 b4 fd ff ff    	mov    %eax,-0x24c(%ebp)
c0104535:	e8 2c d5 ff ff       	call   c0101a66 <_ZN7OStreamC1E6StringS0_>
c010453a:	89 3c 24             	mov    %edi,(%esp)
c010453d:	e8 28 01 00 00       	call   c010466a <_ZN6StringD1Ev>
c0104542:	89 34 24             	mov    %esi,(%esp)
c0104545:	e8 20 01 00 00       	call   c010466a <_ZN6StringD1Ev>
c010454a:	f4                   	hlt    
c010454b:	8b 85 b4 fd ff ff    	mov    -0x24c(%ebp),%eax
c0104551:	89 04 24             	mov    %eax,(%esp)
c0104554:	e8 ed d5 ff ff       	call   c0101b46 <_ZN7OStreamD1Ev>
    hlt();
c0104559:	83 c4 10             	add    $0x10,%esp
c010455c:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010455f:	5b                   	pop    %ebx
c0104560:	5e                   	pop    %esi
c0104561:	5f                   	pop    %edi
c0104562:	5d                   	pop    %ebp
c0104563:	c3                   	ret    

c0104564 <__cxa_pure_virtual>:
#include <icxxabi.h>


extern "C" {

    void __cxa_pure_virtual() {
c0104564:	55                   	push   %ebp
c0104565:	89 e5                	mov    %esp,%ebp
        // Do Nothing
    }
c0104567:	5d                   	pop    %ebp
c0104568:	c3                   	ret    

c0104569 <__cxa_atexit>:
    atexitFuncEntry_t __atexitFuncs[ATEXIT_FUNC_MAX];
    uarch_t __atexitFuncCount = 0;

    void *__dso_handle = 0;

    int __cxa_atexit(void (*f)(void *), void *objptr, void *dso){
c0104569:	e8 ee ca ff ff       	call   c010105c <__x86.get_pc_thunk.cx>
c010456e:	81 c1 a2 7e 01 00    	add    $0x17ea2,%ecx
        if(__atexitFuncCount >= ATEXIT_FUNC_MAX){
c0104574:	8b 91 34 36 00 00    	mov    0x3634(%ecx),%edx
c010457a:	83 fa 7f             	cmp    $0x7f,%edx
c010457d:	77 30                	ja     c01045af <__cxa_atexit+0x46>
    int __cxa_atexit(void (*f)(void *), void *objptr, void *dso){
c010457f:	55                   	push   %ebp
c0104580:	89 e5                	mov    %esp,%ebp
            return -1;
        }
        __atexitFuncs[__atexitFuncCount].destructorFunc = f;
c0104582:	6b c2 0c             	imul   $0xc,%edx,%eax
        __atexitFuncs[__atexitFuncCount].objPtr = objptr;
        __atexitFuncs[__atexitFuncCount].dsoHandle = dso;
        __atexitFuncCount++;
c0104585:	42                   	inc    %edx
    int __cxa_atexit(void (*f)(void *), void *objptr, void *dso){
c0104586:	53                   	push   %ebx
        __atexitFuncs[__atexitFuncCount].destructorFunc = f;
c0104587:	8b 5d 08             	mov    0x8(%ebp),%ebx
        __atexitFuncCount++;
c010458a:	89 91 34 36 00 00    	mov    %edx,0x3634(%ecx)
        __atexitFuncs[__atexitFuncCount].destructorFunc = f;
c0104590:	89 9c 01 50 36 00 00 	mov    %ebx,0x3650(%ecx,%eax,1)
        __atexitFuncs[__atexitFuncCount].objPtr = objptr;
c0104597:	8b 5d 0c             	mov    0xc(%ebp),%ebx
c010459a:	8d 84 01 50 36 00 00 	lea    0x3650(%ecx,%eax,1),%eax
c01045a1:	89 58 04             	mov    %ebx,0x4(%eax)
        __atexitFuncs[__atexitFuncCount].dsoHandle = dso;
c01045a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
c01045a7:	89 58 08             	mov    %ebx,0x8(%eax)
        return 0;
c01045aa:	31 c0                	xor    %eax,%eax
    }
c01045ac:	5b                   	pop    %ebx
c01045ad:	5d                   	pop    %ebp
c01045ae:	c3                   	ret    
c01045af:	83 c8 ff             	or     $0xffffffff,%eax
c01045b2:	c3                   	ret    

c01045b3 <__cxa_finalize>:

    void __cxa_finalize(void *f){
c01045b3:	55                   	push   %ebp
c01045b4:	89 e5                	mov    %esp,%ebp
c01045b6:	57                   	push   %edi
c01045b7:	56                   	push   %esi
c01045b8:	53                   	push   %ebx
c01045b9:	83 ec 1c             	sub    $0x1c,%esp
c01045bc:	e8 77 00 00 00       	call   c0104638 <__x86.get_pc_thunk.si>
c01045c1:	81 c6 4f 7e 01 00    	add    $0x17e4f,%esi
c01045c7:	8b 45 08             	mov    0x8(%ebp),%eax
        signed i = __atexitFuncCount;
        if(!f){
c01045ca:	85 c0                	test   %eax,%eax
        signed i = __atexitFuncCount;
c01045cc:	8b 9e 34 36 00 00    	mov    0x3634(%esi),%ebx
        if(!f){
c01045d2:	74 0e                	je     c01045e2 <__cxa_finalize+0x2f>
c01045d4:	6b d3 0c             	imul   $0xc,%ebx,%edx
c01045d7:	8d bc 16 50 36 00 00 	lea    0x3650(%esi,%edx,1),%edi
c01045de:	31 f6                	xor    %esi,%esi
c01045e0:	eb 4a                	jmp    c010462c <__cxa_finalize+0x79>
c01045e2:	6b db 0c             	imul   $0xc,%ebx,%ebx
            while(i--){
c01045e5:	85 db                	test   %ebx,%ebx
c01045e7:	74 47                	je     c0104630 <__cxa_finalize+0x7d>
                if(__atexitFuncs[i].destructorFunc){
c01045e9:	8b 84 33 44 36 00 00 	mov    0x3644(%ebx,%esi,1),%eax
c01045f0:	85 c0                	test   %eax,%eax
c01045f2:	75 05                	jne    c01045f9 <__cxa_finalize+0x46>
c01045f4:	83 eb 0c             	sub    $0xc,%ebx
c01045f7:	eb ec                	jmp    c01045e5 <__cxa_finalize+0x32>
                    (*__atexitFuncs[i].destructorFunc)(__atexitFuncs[i].objPtr);
c01045f9:	83 ec 0c             	sub    $0xc,%esp
c01045fc:	ff b4 33 48 36 00 00 	pushl  0x3648(%ebx,%esi,1)
c0104603:	ff d0                	call   *%eax
c0104605:	83 c4 10             	add    $0x10,%esp
c0104608:	eb ea                	jmp    c01045f4 <__cxa_finalize+0x41>
            }
            return;
        }

        for(; i >= 0; i--){
            if(__atexitFuncs[i].destructorFunc == f){
c010460a:	39 04 37             	cmp    %eax,(%edi,%esi,1)
c010460d:	75 19                	jne    c0104628 <__cxa_finalize+0x75>
                (*__atexitFuncs[i].destructorFunc)(__atexitFuncs[i].objPtr);
c010460f:	83 ec 0c             	sub    $0xc,%esp
c0104612:	ff 74 37 04          	pushl  0x4(%edi,%esi,1)
c0104616:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104619:	ff d0                	call   *%eax
c010461b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
                __atexitFuncs[i].destructorFunc = 0;
c010461e:	c7 04 37 00 00 00 00 	movl   $0x0,(%edi,%esi,1)
c0104625:	83 c4 10             	add    $0x10,%esp
        for(; i >= 0; i--){
c0104628:	4b                   	dec    %ebx
c0104629:	83 ee 0c             	sub    $0xc,%esi
c010462c:	85 db                	test   %ebx,%ebx
c010462e:	79 da                	jns    c010460a <__cxa_finalize+0x57>
            }
        }
    }
c0104630:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0104633:	5b                   	pop    %ebx
c0104634:	5e                   	pop    %esi
c0104635:	5f                   	pop    %edi
c0104636:	5d                   	pop    %ebp
c0104637:	c3                   	ret    

c0104638 <__x86.get_pc_thunk.si>:
c0104638:	8b 34 24             	mov    (%esp),%esi
c010463b:	c3                   	ret    

c010463c <_ZN6String7cStrLenEPKc>:
 * @Last Modified time: 2020-03-25 19:21:46 
 */

#include <string.h>

uint32_t String::cStrLen(ccstring cstr) {
c010463c:	55                   	push   %ebp
    uint32_t len = 0;
c010463d:	31 c0                	xor    %eax,%eax
uint32_t String::cStrLen(ccstring cstr) {
c010463f:	89 e5                	mov    %esp,%ebp
c0104641:	8b 55 0c             	mov    0xc(%ebp),%edx
    auto it = cstr;
    while(*it++ != '\0') {
c0104644:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
c0104648:	74 03                	je     c010464d <_ZN6String7cStrLenEPKc+0x11>
        len++;
c010464a:	40                   	inc    %eax
    while(*it++ != '\0') {
c010464b:	eb f7                	jmp    c0104644 <_ZN6String7cStrLenEPKc+0x8>
    }
    return len;
}
c010464d:	5d                   	pop    %ebp
c010464e:	c3                   	ret    
c010464f:	90                   	nop

c0104650 <_ZN6StringC1EPKc>:


String::String(ccstring cstr) {
c0104650:	55                   	push   %ebp
c0104651:	89 e5                	mov    %esp,%ebp
c0104653:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0104656:	8b 45 0c             	mov    0xc(%ebp),%eax
    str = (cstring)cstr;
c0104659:	89 01                	mov    %eax,(%ecx)
    length = cStrLen(cstr);
c010465b:	50                   	push   %eax
c010465c:	51                   	push   %ecx
c010465d:	e8 da ff ff ff       	call   c010463c <_ZN6String7cStrLenEPKc>
c0104662:	5a                   	pop    %edx
c0104663:	5a                   	pop    %edx
c0104664:	88 41 04             	mov    %al,0x4(%ecx)
}
c0104667:	c9                   	leave  
c0104668:	c3                   	ret    
c0104669:	90                   	nop

c010466a <_ZN6StringD1Ev>:


String::~String() {                                     //destructor
c010466a:	55                   	push   %ebp
c010466b:	89 e5                	mov    %esp,%ebp

}
c010466d:	5d                   	pop    %ebp
c010466e:	c3                   	ret    
c010466f:	90                   	nop

c0104670 <_ZN6StringaSEPKc>:


String & String::operator=(ccstring cstr) {             // copy assigment
c0104670:	55                   	push   %ebp
c0104671:	89 e5                	mov    %esp,%ebp
c0104673:	56                   	push   %esi
c0104674:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0104677:	53                   	push   %ebx
c0104678:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    length = cStrLen(cstr);
c010467b:	53                   	push   %ebx
c010467c:	51                   	push   %ecx
c010467d:	e8 ba ff ff ff       	call   c010463c <_ZN6String7cStrLenEPKc>
c0104682:	5a                   	pop    %edx
c0104683:	5e                   	pop    %esi
c0104684:	88 41 04             	mov    %al,0x4(%ecx)
    //delete [] str;
    //str = new char[length];
    for (uint32_t i = 0; i < length; i++) {
c0104687:	31 c0                	xor    %eax,%eax
c0104689:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
c010468d:	39 c2                	cmp    %eax,%edx
c010468f:	76 0b                	jbe    c010469c <_ZN6StringaSEPKc+0x2c>
        str[i] = cstr[i];
c0104691:	8a 14 03             	mov    (%ebx,%eax,1),%dl
c0104694:	8b 31                	mov    (%ecx),%esi
c0104696:	88 14 06             	mov    %dl,(%esi,%eax,1)
    for (uint32_t i = 0; i < length; i++) {
c0104699:	40                   	inc    %eax
c010469a:	eb ed                	jmp    c0104689 <_ZN6StringaSEPKc+0x19>
    }
    return *this;
}
c010469c:	8d 65 f8             	lea    -0x8(%ebp),%esp
c010469f:	89 c8                	mov    %ecx,%eax
c01046a1:	5b                   	pop    %ebx
c01046a2:	5e                   	pop    %esi
c01046a3:	5d                   	pop    %ebp
c01046a4:	c3                   	ret    
c01046a5:	90                   	nop

c01046a6 <_ZNK6String4cStrEv>:

ccstring String::cStr() const {
c01046a6:	55                   	push   %ebp
c01046a7:	89 e5                	mov    %esp,%ebp
    return str;
c01046a9:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01046ac:	5d                   	pop    %ebp
    return str;
c01046ad:	8b 00                	mov    (%eax),%eax
}
c01046af:	c3                   	ret    

c01046b0 <_ZNK6String9getLengthEv>:

uint8_t String::getLength() const {
c01046b0:	55                   	push   %ebp
c01046b1:	89 e5                	mov    %esp,%ebp
    return length;
c01046b3:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01046b6:	5d                   	pop    %ebp
    return length;
c01046b7:	8a 40 04             	mov    0x4(%eax),%al
}
c01046ba:	c3                   	ret    
c01046bb:	90                   	nop

c01046bc <_ZN6StringeqERKS_>:

bool String::operator==(const String &_str) {
c01046bc:	55                   	push   %ebp
    bool isEquals = false;
c01046bd:	31 c0                	xor    %eax,%eax
bool String::operator==(const String &_str) {
c01046bf:	89 e5                	mov    %esp,%ebp
c01046c1:	57                   	push   %edi
c01046c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
c01046c5:	56                   	push   %esi
c01046c6:	53                   	push   %ebx
c01046c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (_str.length == length) {
c01046ca:	8a 53 04             	mov    0x4(%ebx),%dl
c01046cd:	3a 51 04             	cmp    0x4(%ecx),%dl
c01046d0:	75 1e                	jne    c01046f0 <_ZN6StringeqERKS_+0x34>
        for (uint32_t i = 0; i < length; i++) {
c01046d2:	31 c0                	xor    %eax,%eax
c01046d4:	0f b6 fa             	movzbl %dl,%edi
c01046d7:	39 c7                	cmp    %eax,%edi
c01046d9:	76 0f                	jbe    c01046ea <_ZN6StringeqERKS_+0x2e>
            if (str[i] != (_str.str)[i]) {
c01046db:	8b 13                	mov    (%ebx),%edx
c01046dd:	8b 31                	mov    (%ecx),%esi
c01046df:	8a 14 02             	mov    (%edx,%eax,1),%dl
c01046e2:	38 14 06             	cmp    %dl,(%esi,%eax,1)
c01046e5:	75 07                	jne    c01046ee <_ZN6StringeqERKS_+0x32>
        for (uint32_t i = 0; i < length; i++) {
c01046e7:	40                   	inc    %eax
c01046e8:	eb ed                	jmp    c01046d7 <_ZN6StringeqERKS_+0x1b>
                return false;
            }
        }
        isEquals = true;
c01046ea:	b0 01                	mov    $0x1,%al
c01046ec:	eb 02                	jmp    c01046f0 <_ZN6StringeqERKS_+0x34>
    bool isEquals = false;
c01046ee:	31 c0                	xor    %eax,%eax
    }
    return isEquals;
}
c01046f0:	5b                   	pop    %ebx
c01046f1:	5e                   	pop    %esi
c01046f2:	5f                   	pop    %edi
c01046f3:	5d                   	pop    %ebp
c01046f4:	c3                   	ret    
c01046f5:	90                   	nop

c01046f6 <_ZN6StringixEj>:

// index accessor
char & String::operator[](const uint32_t index) {
c01046f6:	55                   	push   %ebp
c01046f7:	89 e5                	mov    %esp,%ebp
    return str[index];
c01046f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01046fc:	8b 00                	mov    (%eax),%eax
c01046fe:	03 45 0c             	add    0xc(%ebp),%eax
}
c0104701:	5d                   	pop    %ebp
c0104702:	c3                   	ret    
