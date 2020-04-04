
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <entryKernel>:

.text
.globl entryKernel
entryKernel:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 00 11 00       	mov    $0x110000,%eax
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
c0100020:	a3 00 00 11 c0       	mov    %eax,0xc0110000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 f0 10 c0       	mov    $0xc010f000,%esp
    # now kernel stack is ready , call the first C++ function
    call initKernel
c010002f:	e8 94 0a 00 00       	call   c0100ac8 <initKernel>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0100036:	1e                   	push   %ds
    pushl %es
c0100037:	06                   	push   %es
    pushl %fs
c0100038:	0f a0                	push   %fs
    pushl %gs
c010003a:	0f a8                	push   %gs
    pushal
c010003c:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c010003d:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0100042:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0100044:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0100046:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call _ZN4Trap4trapEv
c0100047:	e8 34 19 00 00       	call   c0101980 <_ZN4Trap4trapEv>

    # pop the pushed stack pointer
    popl %esp
c010004c:	5c                   	pop    %esp

c010004d <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c010004d:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c010004e:	0f a9                	pop    %gs
    popl %fs
c0100050:	0f a1                	pop    %fs
    popl %es
c0100052:	07                   	pop    %es
    popl %ds
c0100053:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0100054:	83 c4 08             	add    $0x8,%esp
    iret
c0100057:	cf                   	iret   

c0100058 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0100058:	6a 00                	push   $0x0
  pushl $0
c010005a:	6a 00                	push   $0x0
  jmp __alltraps
c010005c:	e9 d5 ff ff ff       	jmp    c0100036 <__alltraps>

c0100061 <vector1>:
.globl vector1
vector1:
  pushl $0
c0100061:	6a 00                	push   $0x0
  pushl $1
c0100063:	6a 01                	push   $0x1
  jmp __alltraps
c0100065:	e9 cc ff ff ff       	jmp    c0100036 <__alltraps>

c010006a <vector2>:
.globl vector2
vector2:
  pushl $0
c010006a:	6a 00                	push   $0x0
  pushl $2
c010006c:	6a 02                	push   $0x2
  jmp __alltraps
c010006e:	e9 c3 ff ff ff       	jmp    c0100036 <__alltraps>

c0100073 <vector3>:
.globl vector3
vector3:
  pushl $0
c0100073:	6a 00                	push   $0x0
  pushl $3
c0100075:	6a 03                	push   $0x3
  jmp __alltraps
c0100077:	e9 ba ff ff ff       	jmp    c0100036 <__alltraps>

c010007c <vector4>:
.globl vector4
vector4:
  pushl $0
c010007c:	6a 00                	push   $0x0
  pushl $4
c010007e:	6a 04                	push   $0x4
  jmp __alltraps
c0100080:	e9 b1 ff ff ff       	jmp    c0100036 <__alltraps>

c0100085 <vector5>:
.globl vector5
vector5:
  pushl $0
c0100085:	6a 00                	push   $0x0
  pushl $5
c0100087:	6a 05                	push   $0x5
  jmp __alltraps
c0100089:	e9 a8 ff ff ff       	jmp    c0100036 <__alltraps>

c010008e <vector6>:
.globl vector6
vector6:
  pushl $0
c010008e:	6a 00                	push   $0x0
  pushl $6
c0100090:	6a 06                	push   $0x6
  jmp __alltraps
c0100092:	e9 9f ff ff ff       	jmp    c0100036 <__alltraps>

c0100097 <vector7>:
.globl vector7
vector7:
  pushl $0
c0100097:	6a 00                	push   $0x0
  pushl $7
c0100099:	6a 07                	push   $0x7
  jmp __alltraps
c010009b:	e9 96 ff ff ff       	jmp    c0100036 <__alltraps>

c01000a0 <vector8>:
.globl vector8
vector8:
  pushl $8
c01000a0:	6a 08                	push   $0x8
  jmp __alltraps
c01000a2:	e9 8f ff ff ff       	jmp    c0100036 <__alltraps>

c01000a7 <vector9>:
.globl vector9
vector9:
  pushl $9
c01000a7:	6a 09                	push   $0x9
  jmp __alltraps
c01000a9:	e9 88 ff ff ff       	jmp    c0100036 <__alltraps>

c01000ae <vector10>:
.globl vector10
vector10:
  pushl $10
c01000ae:	6a 0a                	push   $0xa
  jmp __alltraps
c01000b0:	e9 81 ff ff ff       	jmp    c0100036 <__alltraps>

c01000b5 <vector11>:
.globl vector11
vector11:
  pushl $11
c01000b5:	6a 0b                	push   $0xb
  jmp __alltraps
c01000b7:	e9 7a ff ff ff       	jmp    c0100036 <__alltraps>

c01000bc <vector12>:
.globl vector12
vector12:
  pushl $12
c01000bc:	6a 0c                	push   $0xc
  jmp __alltraps
c01000be:	e9 73 ff ff ff       	jmp    c0100036 <__alltraps>

c01000c3 <vector13>:
.globl vector13
vector13:
  pushl $13
c01000c3:	6a 0d                	push   $0xd
  jmp __alltraps
c01000c5:	e9 6c ff ff ff       	jmp    c0100036 <__alltraps>

c01000ca <vector14>:
.globl vector14
vector14:
  pushl $14
c01000ca:	6a 0e                	push   $0xe
  jmp __alltraps
c01000cc:	e9 65 ff ff ff       	jmp    c0100036 <__alltraps>

c01000d1 <vector15>:
.globl vector15
vector15:
  pushl $0
c01000d1:	6a 00                	push   $0x0
  pushl $15
c01000d3:	6a 0f                	push   $0xf
  jmp __alltraps
c01000d5:	e9 5c ff ff ff       	jmp    c0100036 <__alltraps>

c01000da <vector16>:
.globl vector16
vector16:
  pushl $0
c01000da:	6a 00                	push   $0x0
  pushl $16
c01000dc:	6a 10                	push   $0x10
  jmp __alltraps
c01000de:	e9 53 ff ff ff       	jmp    c0100036 <__alltraps>

c01000e3 <vector17>:
.globl vector17
vector17:
  pushl $17
c01000e3:	6a 11                	push   $0x11
  jmp __alltraps
c01000e5:	e9 4c ff ff ff       	jmp    c0100036 <__alltraps>

c01000ea <vector18>:
.globl vector18
vector18:
  pushl $0
c01000ea:	6a 00                	push   $0x0
  pushl $18
c01000ec:	6a 12                	push   $0x12
  jmp __alltraps
c01000ee:	e9 43 ff ff ff       	jmp    c0100036 <__alltraps>

c01000f3 <vector19>:
.globl vector19
vector19:
  pushl $0
c01000f3:	6a 00                	push   $0x0
  pushl $19
c01000f5:	6a 13                	push   $0x13
  jmp __alltraps
c01000f7:	e9 3a ff ff ff       	jmp    c0100036 <__alltraps>

c01000fc <vector20>:
.globl vector20
vector20:
  pushl $0
c01000fc:	6a 00                	push   $0x0
  pushl $20
c01000fe:	6a 14                	push   $0x14
  jmp __alltraps
c0100100:	e9 31 ff ff ff       	jmp    c0100036 <__alltraps>

c0100105 <vector21>:
.globl vector21
vector21:
  pushl $0
c0100105:	6a 00                	push   $0x0
  pushl $21
c0100107:	6a 15                	push   $0x15
  jmp __alltraps
c0100109:	e9 28 ff ff ff       	jmp    c0100036 <__alltraps>

c010010e <vector22>:
.globl vector22
vector22:
  pushl $0
c010010e:	6a 00                	push   $0x0
  pushl $22
c0100110:	6a 16                	push   $0x16
  jmp __alltraps
c0100112:	e9 1f ff ff ff       	jmp    c0100036 <__alltraps>

c0100117 <vector23>:
.globl vector23
vector23:
  pushl $0
c0100117:	6a 00                	push   $0x0
  pushl $23
c0100119:	6a 17                	push   $0x17
  jmp __alltraps
c010011b:	e9 16 ff ff ff       	jmp    c0100036 <__alltraps>

c0100120 <vector24>:
.globl vector24
vector24:
  pushl $0
c0100120:	6a 00                	push   $0x0
  pushl $24
c0100122:	6a 18                	push   $0x18
  jmp __alltraps
c0100124:	e9 0d ff ff ff       	jmp    c0100036 <__alltraps>

c0100129 <vector25>:
.globl vector25
vector25:
  pushl $0
c0100129:	6a 00                	push   $0x0
  pushl $25
c010012b:	6a 19                	push   $0x19
  jmp __alltraps
c010012d:	e9 04 ff ff ff       	jmp    c0100036 <__alltraps>

c0100132 <vector26>:
.globl vector26
vector26:
  pushl $0
c0100132:	6a 00                	push   $0x0
  pushl $26
c0100134:	6a 1a                	push   $0x1a
  jmp __alltraps
c0100136:	e9 fb fe ff ff       	jmp    c0100036 <__alltraps>

c010013b <vector27>:
.globl vector27
vector27:
  pushl $0
c010013b:	6a 00                	push   $0x0
  pushl $27
c010013d:	6a 1b                	push   $0x1b
  jmp __alltraps
c010013f:	e9 f2 fe ff ff       	jmp    c0100036 <__alltraps>

c0100144 <vector28>:
.globl vector28
vector28:
  pushl $0
c0100144:	6a 00                	push   $0x0
  pushl $28
c0100146:	6a 1c                	push   $0x1c
  jmp __alltraps
c0100148:	e9 e9 fe ff ff       	jmp    c0100036 <__alltraps>

c010014d <vector29>:
.globl vector29
vector29:
  pushl $0
c010014d:	6a 00                	push   $0x0
  pushl $29
c010014f:	6a 1d                	push   $0x1d
  jmp __alltraps
c0100151:	e9 e0 fe ff ff       	jmp    c0100036 <__alltraps>

c0100156 <vector30>:
.globl vector30
vector30:
  pushl $0
c0100156:	6a 00                	push   $0x0
  pushl $30
c0100158:	6a 1e                	push   $0x1e
  jmp __alltraps
c010015a:	e9 d7 fe ff ff       	jmp    c0100036 <__alltraps>

c010015f <vector31>:
.globl vector31
vector31:
  pushl $0
c010015f:	6a 00                	push   $0x0
  pushl $31
c0100161:	6a 1f                	push   $0x1f
  jmp __alltraps
c0100163:	e9 ce fe ff ff       	jmp    c0100036 <__alltraps>

c0100168 <vector32>:
.globl vector32
vector32:
  pushl $0
c0100168:	6a 00                	push   $0x0
  pushl $32
c010016a:	6a 20                	push   $0x20
  jmp __alltraps
c010016c:	e9 c5 fe ff ff       	jmp    c0100036 <__alltraps>

c0100171 <vector33>:
.globl vector33
vector33:
  pushl $0
c0100171:	6a 00                	push   $0x0
  pushl $33
c0100173:	6a 21                	push   $0x21
  jmp __alltraps
c0100175:	e9 bc fe ff ff       	jmp    c0100036 <__alltraps>

c010017a <vector34>:
.globl vector34
vector34:
  pushl $0
c010017a:	6a 00                	push   $0x0
  pushl $34
c010017c:	6a 22                	push   $0x22
  jmp __alltraps
c010017e:	e9 b3 fe ff ff       	jmp    c0100036 <__alltraps>

c0100183 <vector35>:
.globl vector35
vector35:
  pushl $0
c0100183:	6a 00                	push   $0x0
  pushl $35
c0100185:	6a 23                	push   $0x23
  jmp __alltraps
c0100187:	e9 aa fe ff ff       	jmp    c0100036 <__alltraps>

c010018c <vector36>:
.globl vector36
vector36:
  pushl $0
c010018c:	6a 00                	push   $0x0
  pushl $36
c010018e:	6a 24                	push   $0x24
  jmp __alltraps
c0100190:	e9 a1 fe ff ff       	jmp    c0100036 <__alltraps>

c0100195 <vector37>:
.globl vector37
vector37:
  pushl $0
c0100195:	6a 00                	push   $0x0
  pushl $37
c0100197:	6a 25                	push   $0x25
  jmp __alltraps
c0100199:	e9 98 fe ff ff       	jmp    c0100036 <__alltraps>

c010019e <vector38>:
.globl vector38
vector38:
  pushl $0
c010019e:	6a 00                	push   $0x0
  pushl $38
c01001a0:	6a 26                	push   $0x26
  jmp __alltraps
c01001a2:	e9 8f fe ff ff       	jmp    c0100036 <__alltraps>

c01001a7 <vector39>:
.globl vector39
vector39:
  pushl $0
c01001a7:	6a 00                	push   $0x0
  pushl $39
c01001a9:	6a 27                	push   $0x27
  jmp __alltraps
c01001ab:	e9 86 fe ff ff       	jmp    c0100036 <__alltraps>

c01001b0 <vector40>:
.globl vector40
vector40:
  pushl $0
c01001b0:	6a 00                	push   $0x0
  pushl $40
c01001b2:	6a 28                	push   $0x28
  jmp __alltraps
c01001b4:	e9 7d fe ff ff       	jmp    c0100036 <__alltraps>

c01001b9 <vector41>:
.globl vector41
vector41:
  pushl $0
c01001b9:	6a 00                	push   $0x0
  pushl $41
c01001bb:	6a 29                	push   $0x29
  jmp __alltraps
c01001bd:	e9 74 fe ff ff       	jmp    c0100036 <__alltraps>

c01001c2 <vector42>:
.globl vector42
vector42:
  pushl $0
c01001c2:	6a 00                	push   $0x0
  pushl $42
c01001c4:	6a 2a                	push   $0x2a
  jmp __alltraps
c01001c6:	e9 6b fe ff ff       	jmp    c0100036 <__alltraps>

c01001cb <vector43>:
.globl vector43
vector43:
  pushl $0
c01001cb:	6a 00                	push   $0x0
  pushl $43
c01001cd:	6a 2b                	push   $0x2b
  jmp __alltraps
c01001cf:	e9 62 fe ff ff       	jmp    c0100036 <__alltraps>

c01001d4 <vector44>:
.globl vector44
vector44:
  pushl $0
c01001d4:	6a 00                	push   $0x0
  pushl $44
c01001d6:	6a 2c                	push   $0x2c
  jmp __alltraps
c01001d8:	e9 59 fe ff ff       	jmp    c0100036 <__alltraps>

c01001dd <vector45>:
.globl vector45
vector45:
  pushl $0
c01001dd:	6a 00                	push   $0x0
  pushl $45
c01001df:	6a 2d                	push   $0x2d
  jmp __alltraps
c01001e1:	e9 50 fe ff ff       	jmp    c0100036 <__alltraps>

c01001e6 <vector46>:
.globl vector46
vector46:
  pushl $0
c01001e6:	6a 00                	push   $0x0
  pushl $46
c01001e8:	6a 2e                	push   $0x2e
  jmp __alltraps
c01001ea:	e9 47 fe ff ff       	jmp    c0100036 <__alltraps>

c01001ef <vector47>:
.globl vector47
vector47:
  pushl $0
c01001ef:	6a 00                	push   $0x0
  pushl $47
c01001f1:	6a 2f                	push   $0x2f
  jmp __alltraps
c01001f3:	e9 3e fe ff ff       	jmp    c0100036 <__alltraps>

c01001f8 <vector48>:
.globl vector48
vector48:
  pushl $0
c01001f8:	6a 00                	push   $0x0
  pushl $48
c01001fa:	6a 30                	push   $0x30
  jmp __alltraps
c01001fc:	e9 35 fe ff ff       	jmp    c0100036 <__alltraps>

c0100201 <vector49>:
.globl vector49
vector49:
  pushl $0
c0100201:	6a 00                	push   $0x0
  pushl $49
c0100203:	6a 31                	push   $0x31
  jmp __alltraps
c0100205:	e9 2c fe ff ff       	jmp    c0100036 <__alltraps>

c010020a <vector50>:
.globl vector50
vector50:
  pushl $0
c010020a:	6a 00                	push   $0x0
  pushl $50
c010020c:	6a 32                	push   $0x32
  jmp __alltraps
c010020e:	e9 23 fe ff ff       	jmp    c0100036 <__alltraps>

c0100213 <vector51>:
.globl vector51
vector51:
  pushl $0
c0100213:	6a 00                	push   $0x0
  pushl $51
c0100215:	6a 33                	push   $0x33
  jmp __alltraps
c0100217:	e9 1a fe ff ff       	jmp    c0100036 <__alltraps>

c010021c <vector52>:
.globl vector52
vector52:
  pushl $0
c010021c:	6a 00                	push   $0x0
  pushl $52
c010021e:	6a 34                	push   $0x34
  jmp __alltraps
c0100220:	e9 11 fe ff ff       	jmp    c0100036 <__alltraps>

c0100225 <vector53>:
.globl vector53
vector53:
  pushl $0
c0100225:	6a 00                	push   $0x0
  pushl $53
c0100227:	6a 35                	push   $0x35
  jmp __alltraps
c0100229:	e9 08 fe ff ff       	jmp    c0100036 <__alltraps>

c010022e <vector54>:
.globl vector54
vector54:
  pushl $0
c010022e:	6a 00                	push   $0x0
  pushl $54
c0100230:	6a 36                	push   $0x36
  jmp __alltraps
c0100232:	e9 ff fd ff ff       	jmp    c0100036 <__alltraps>

c0100237 <vector55>:
.globl vector55
vector55:
  pushl $0
c0100237:	6a 00                	push   $0x0
  pushl $55
c0100239:	6a 37                	push   $0x37
  jmp __alltraps
c010023b:	e9 f6 fd ff ff       	jmp    c0100036 <__alltraps>

c0100240 <vector56>:
.globl vector56
vector56:
  pushl $0
c0100240:	6a 00                	push   $0x0
  pushl $56
c0100242:	6a 38                	push   $0x38
  jmp __alltraps
c0100244:	e9 ed fd ff ff       	jmp    c0100036 <__alltraps>

c0100249 <vector57>:
.globl vector57
vector57:
  pushl $0
c0100249:	6a 00                	push   $0x0
  pushl $57
c010024b:	6a 39                	push   $0x39
  jmp __alltraps
c010024d:	e9 e4 fd ff ff       	jmp    c0100036 <__alltraps>

c0100252 <vector58>:
.globl vector58
vector58:
  pushl $0
c0100252:	6a 00                	push   $0x0
  pushl $58
c0100254:	6a 3a                	push   $0x3a
  jmp __alltraps
c0100256:	e9 db fd ff ff       	jmp    c0100036 <__alltraps>

c010025b <vector59>:
.globl vector59
vector59:
  pushl $0
c010025b:	6a 00                	push   $0x0
  pushl $59
c010025d:	6a 3b                	push   $0x3b
  jmp __alltraps
c010025f:	e9 d2 fd ff ff       	jmp    c0100036 <__alltraps>

c0100264 <vector60>:
.globl vector60
vector60:
  pushl $0
c0100264:	6a 00                	push   $0x0
  pushl $60
c0100266:	6a 3c                	push   $0x3c
  jmp __alltraps
c0100268:	e9 c9 fd ff ff       	jmp    c0100036 <__alltraps>

c010026d <vector61>:
.globl vector61
vector61:
  pushl $0
c010026d:	6a 00                	push   $0x0
  pushl $61
c010026f:	6a 3d                	push   $0x3d
  jmp __alltraps
c0100271:	e9 c0 fd ff ff       	jmp    c0100036 <__alltraps>

c0100276 <vector62>:
.globl vector62
vector62:
  pushl $0
c0100276:	6a 00                	push   $0x0
  pushl $62
c0100278:	6a 3e                	push   $0x3e
  jmp __alltraps
c010027a:	e9 b7 fd ff ff       	jmp    c0100036 <__alltraps>

c010027f <vector63>:
.globl vector63
vector63:
  pushl $0
c010027f:	6a 00                	push   $0x0
  pushl $63
c0100281:	6a 3f                	push   $0x3f
  jmp __alltraps
c0100283:	e9 ae fd ff ff       	jmp    c0100036 <__alltraps>

c0100288 <vector64>:
.globl vector64
vector64:
  pushl $0
c0100288:	6a 00                	push   $0x0
  pushl $64
c010028a:	6a 40                	push   $0x40
  jmp __alltraps
c010028c:	e9 a5 fd ff ff       	jmp    c0100036 <__alltraps>

c0100291 <vector65>:
.globl vector65
vector65:
  pushl $0
c0100291:	6a 00                	push   $0x0
  pushl $65
c0100293:	6a 41                	push   $0x41
  jmp __alltraps
c0100295:	e9 9c fd ff ff       	jmp    c0100036 <__alltraps>

c010029a <vector66>:
.globl vector66
vector66:
  pushl $0
c010029a:	6a 00                	push   $0x0
  pushl $66
c010029c:	6a 42                	push   $0x42
  jmp __alltraps
c010029e:	e9 93 fd ff ff       	jmp    c0100036 <__alltraps>

c01002a3 <vector67>:
.globl vector67
vector67:
  pushl $0
c01002a3:	6a 00                	push   $0x0
  pushl $67
c01002a5:	6a 43                	push   $0x43
  jmp __alltraps
c01002a7:	e9 8a fd ff ff       	jmp    c0100036 <__alltraps>

c01002ac <vector68>:
.globl vector68
vector68:
  pushl $0
c01002ac:	6a 00                	push   $0x0
  pushl $68
c01002ae:	6a 44                	push   $0x44
  jmp __alltraps
c01002b0:	e9 81 fd ff ff       	jmp    c0100036 <__alltraps>

c01002b5 <vector69>:
.globl vector69
vector69:
  pushl $0
c01002b5:	6a 00                	push   $0x0
  pushl $69
c01002b7:	6a 45                	push   $0x45
  jmp __alltraps
c01002b9:	e9 78 fd ff ff       	jmp    c0100036 <__alltraps>

c01002be <vector70>:
.globl vector70
vector70:
  pushl $0
c01002be:	6a 00                	push   $0x0
  pushl $70
c01002c0:	6a 46                	push   $0x46
  jmp __alltraps
c01002c2:	e9 6f fd ff ff       	jmp    c0100036 <__alltraps>

c01002c7 <vector71>:
.globl vector71
vector71:
  pushl $0
c01002c7:	6a 00                	push   $0x0
  pushl $71
c01002c9:	6a 47                	push   $0x47
  jmp __alltraps
c01002cb:	e9 66 fd ff ff       	jmp    c0100036 <__alltraps>

c01002d0 <vector72>:
.globl vector72
vector72:
  pushl $0
c01002d0:	6a 00                	push   $0x0
  pushl $72
c01002d2:	6a 48                	push   $0x48
  jmp __alltraps
c01002d4:	e9 5d fd ff ff       	jmp    c0100036 <__alltraps>

c01002d9 <vector73>:
.globl vector73
vector73:
  pushl $0
c01002d9:	6a 00                	push   $0x0
  pushl $73
c01002db:	6a 49                	push   $0x49
  jmp __alltraps
c01002dd:	e9 54 fd ff ff       	jmp    c0100036 <__alltraps>

c01002e2 <vector74>:
.globl vector74
vector74:
  pushl $0
c01002e2:	6a 00                	push   $0x0
  pushl $74
c01002e4:	6a 4a                	push   $0x4a
  jmp __alltraps
c01002e6:	e9 4b fd ff ff       	jmp    c0100036 <__alltraps>

c01002eb <vector75>:
.globl vector75
vector75:
  pushl $0
c01002eb:	6a 00                	push   $0x0
  pushl $75
c01002ed:	6a 4b                	push   $0x4b
  jmp __alltraps
c01002ef:	e9 42 fd ff ff       	jmp    c0100036 <__alltraps>

c01002f4 <vector76>:
.globl vector76
vector76:
  pushl $0
c01002f4:	6a 00                	push   $0x0
  pushl $76
c01002f6:	6a 4c                	push   $0x4c
  jmp __alltraps
c01002f8:	e9 39 fd ff ff       	jmp    c0100036 <__alltraps>

c01002fd <vector77>:
.globl vector77
vector77:
  pushl $0
c01002fd:	6a 00                	push   $0x0
  pushl $77
c01002ff:	6a 4d                	push   $0x4d
  jmp __alltraps
c0100301:	e9 30 fd ff ff       	jmp    c0100036 <__alltraps>

c0100306 <vector78>:
.globl vector78
vector78:
  pushl $0
c0100306:	6a 00                	push   $0x0
  pushl $78
c0100308:	6a 4e                	push   $0x4e
  jmp __alltraps
c010030a:	e9 27 fd ff ff       	jmp    c0100036 <__alltraps>

c010030f <vector79>:
.globl vector79
vector79:
  pushl $0
c010030f:	6a 00                	push   $0x0
  pushl $79
c0100311:	6a 4f                	push   $0x4f
  jmp __alltraps
c0100313:	e9 1e fd ff ff       	jmp    c0100036 <__alltraps>

c0100318 <vector80>:
.globl vector80
vector80:
  pushl $0
c0100318:	6a 00                	push   $0x0
  pushl $80
c010031a:	6a 50                	push   $0x50
  jmp __alltraps
c010031c:	e9 15 fd ff ff       	jmp    c0100036 <__alltraps>

c0100321 <vector81>:
.globl vector81
vector81:
  pushl $0
c0100321:	6a 00                	push   $0x0
  pushl $81
c0100323:	6a 51                	push   $0x51
  jmp __alltraps
c0100325:	e9 0c fd ff ff       	jmp    c0100036 <__alltraps>

c010032a <vector82>:
.globl vector82
vector82:
  pushl $0
c010032a:	6a 00                	push   $0x0
  pushl $82
c010032c:	6a 52                	push   $0x52
  jmp __alltraps
c010032e:	e9 03 fd ff ff       	jmp    c0100036 <__alltraps>

c0100333 <vector83>:
.globl vector83
vector83:
  pushl $0
c0100333:	6a 00                	push   $0x0
  pushl $83
c0100335:	6a 53                	push   $0x53
  jmp __alltraps
c0100337:	e9 fa fc ff ff       	jmp    c0100036 <__alltraps>

c010033c <vector84>:
.globl vector84
vector84:
  pushl $0
c010033c:	6a 00                	push   $0x0
  pushl $84
c010033e:	6a 54                	push   $0x54
  jmp __alltraps
c0100340:	e9 f1 fc ff ff       	jmp    c0100036 <__alltraps>

c0100345 <vector85>:
.globl vector85
vector85:
  pushl $0
c0100345:	6a 00                	push   $0x0
  pushl $85
c0100347:	6a 55                	push   $0x55
  jmp __alltraps
c0100349:	e9 e8 fc ff ff       	jmp    c0100036 <__alltraps>

c010034e <vector86>:
.globl vector86
vector86:
  pushl $0
c010034e:	6a 00                	push   $0x0
  pushl $86
c0100350:	6a 56                	push   $0x56
  jmp __alltraps
c0100352:	e9 df fc ff ff       	jmp    c0100036 <__alltraps>

c0100357 <vector87>:
.globl vector87
vector87:
  pushl $0
c0100357:	6a 00                	push   $0x0
  pushl $87
c0100359:	6a 57                	push   $0x57
  jmp __alltraps
c010035b:	e9 d6 fc ff ff       	jmp    c0100036 <__alltraps>

c0100360 <vector88>:
.globl vector88
vector88:
  pushl $0
c0100360:	6a 00                	push   $0x0
  pushl $88
c0100362:	6a 58                	push   $0x58
  jmp __alltraps
c0100364:	e9 cd fc ff ff       	jmp    c0100036 <__alltraps>

c0100369 <vector89>:
.globl vector89
vector89:
  pushl $0
c0100369:	6a 00                	push   $0x0
  pushl $89
c010036b:	6a 59                	push   $0x59
  jmp __alltraps
c010036d:	e9 c4 fc ff ff       	jmp    c0100036 <__alltraps>

c0100372 <vector90>:
.globl vector90
vector90:
  pushl $0
c0100372:	6a 00                	push   $0x0
  pushl $90
c0100374:	6a 5a                	push   $0x5a
  jmp __alltraps
c0100376:	e9 bb fc ff ff       	jmp    c0100036 <__alltraps>

c010037b <vector91>:
.globl vector91
vector91:
  pushl $0
c010037b:	6a 00                	push   $0x0
  pushl $91
c010037d:	6a 5b                	push   $0x5b
  jmp __alltraps
c010037f:	e9 b2 fc ff ff       	jmp    c0100036 <__alltraps>

c0100384 <vector92>:
.globl vector92
vector92:
  pushl $0
c0100384:	6a 00                	push   $0x0
  pushl $92
c0100386:	6a 5c                	push   $0x5c
  jmp __alltraps
c0100388:	e9 a9 fc ff ff       	jmp    c0100036 <__alltraps>

c010038d <vector93>:
.globl vector93
vector93:
  pushl $0
c010038d:	6a 00                	push   $0x0
  pushl $93
c010038f:	6a 5d                	push   $0x5d
  jmp __alltraps
c0100391:	e9 a0 fc ff ff       	jmp    c0100036 <__alltraps>

c0100396 <vector94>:
.globl vector94
vector94:
  pushl $0
c0100396:	6a 00                	push   $0x0
  pushl $94
c0100398:	6a 5e                	push   $0x5e
  jmp __alltraps
c010039a:	e9 97 fc ff ff       	jmp    c0100036 <__alltraps>

c010039f <vector95>:
.globl vector95
vector95:
  pushl $0
c010039f:	6a 00                	push   $0x0
  pushl $95
c01003a1:	6a 5f                	push   $0x5f
  jmp __alltraps
c01003a3:	e9 8e fc ff ff       	jmp    c0100036 <__alltraps>

c01003a8 <vector96>:
.globl vector96
vector96:
  pushl $0
c01003a8:	6a 00                	push   $0x0
  pushl $96
c01003aa:	6a 60                	push   $0x60
  jmp __alltraps
c01003ac:	e9 85 fc ff ff       	jmp    c0100036 <__alltraps>

c01003b1 <vector97>:
.globl vector97
vector97:
  pushl $0
c01003b1:	6a 00                	push   $0x0
  pushl $97
c01003b3:	6a 61                	push   $0x61
  jmp __alltraps
c01003b5:	e9 7c fc ff ff       	jmp    c0100036 <__alltraps>

c01003ba <vector98>:
.globl vector98
vector98:
  pushl $0
c01003ba:	6a 00                	push   $0x0
  pushl $98
c01003bc:	6a 62                	push   $0x62
  jmp __alltraps
c01003be:	e9 73 fc ff ff       	jmp    c0100036 <__alltraps>

c01003c3 <vector99>:
.globl vector99
vector99:
  pushl $0
c01003c3:	6a 00                	push   $0x0
  pushl $99
c01003c5:	6a 63                	push   $0x63
  jmp __alltraps
c01003c7:	e9 6a fc ff ff       	jmp    c0100036 <__alltraps>

c01003cc <vector100>:
.globl vector100
vector100:
  pushl $0
c01003cc:	6a 00                	push   $0x0
  pushl $100
c01003ce:	6a 64                	push   $0x64
  jmp __alltraps
c01003d0:	e9 61 fc ff ff       	jmp    c0100036 <__alltraps>

c01003d5 <vector101>:
.globl vector101
vector101:
  pushl $0
c01003d5:	6a 00                	push   $0x0
  pushl $101
c01003d7:	6a 65                	push   $0x65
  jmp __alltraps
c01003d9:	e9 58 fc ff ff       	jmp    c0100036 <__alltraps>

c01003de <vector102>:
.globl vector102
vector102:
  pushl $0
c01003de:	6a 00                	push   $0x0
  pushl $102
c01003e0:	6a 66                	push   $0x66
  jmp __alltraps
c01003e2:	e9 4f fc ff ff       	jmp    c0100036 <__alltraps>

c01003e7 <vector103>:
.globl vector103
vector103:
  pushl $0
c01003e7:	6a 00                	push   $0x0
  pushl $103
c01003e9:	6a 67                	push   $0x67
  jmp __alltraps
c01003eb:	e9 46 fc ff ff       	jmp    c0100036 <__alltraps>

c01003f0 <vector104>:
.globl vector104
vector104:
  pushl $0
c01003f0:	6a 00                	push   $0x0
  pushl $104
c01003f2:	6a 68                	push   $0x68
  jmp __alltraps
c01003f4:	e9 3d fc ff ff       	jmp    c0100036 <__alltraps>

c01003f9 <vector105>:
.globl vector105
vector105:
  pushl $0
c01003f9:	6a 00                	push   $0x0
  pushl $105
c01003fb:	6a 69                	push   $0x69
  jmp __alltraps
c01003fd:	e9 34 fc ff ff       	jmp    c0100036 <__alltraps>

c0100402 <vector106>:
.globl vector106
vector106:
  pushl $0
c0100402:	6a 00                	push   $0x0
  pushl $106
c0100404:	6a 6a                	push   $0x6a
  jmp __alltraps
c0100406:	e9 2b fc ff ff       	jmp    c0100036 <__alltraps>

c010040b <vector107>:
.globl vector107
vector107:
  pushl $0
c010040b:	6a 00                	push   $0x0
  pushl $107
c010040d:	6a 6b                	push   $0x6b
  jmp __alltraps
c010040f:	e9 22 fc ff ff       	jmp    c0100036 <__alltraps>

c0100414 <vector108>:
.globl vector108
vector108:
  pushl $0
c0100414:	6a 00                	push   $0x0
  pushl $108
c0100416:	6a 6c                	push   $0x6c
  jmp __alltraps
c0100418:	e9 19 fc ff ff       	jmp    c0100036 <__alltraps>

c010041d <vector109>:
.globl vector109
vector109:
  pushl $0
c010041d:	6a 00                	push   $0x0
  pushl $109
c010041f:	6a 6d                	push   $0x6d
  jmp __alltraps
c0100421:	e9 10 fc ff ff       	jmp    c0100036 <__alltraps>

c0100426 <vector110>:
.globl vector110
vector110:
  pushl $0
c0100426:	6a 00                	push   $0x0
  pushl $110
c0100428:	6a 6e                	push   $0x6e
  jmp __alltraps
c010042a:	e9 07 fc ff ff       	jmp    c0100036 <__alltraps>

c010042f <vector111>:
.globl vector111
vector111:
  pushl $0
c010042f:	6a 00                	push   $0x0
  pushl $111
c0100431:	6a 6f                	push   $0x6f
  jmp __alltraps
c0100433:	e9 fe fb ff ff       	jmp    c0100036 <__alltraps>

c0100438 <vector112>:
.globl vector112
vector112:
  pushl $0
c0100438:	6a 00                	push   $0x0
  pushl $112
c010043a:	6a 70                	push   $0x70
  jmp __alltraps
c010043c:	e9 f5 fb ff ff       	jmp    c0100036 <__alltraps>

c0100441 <vector113>:
.globl vector113
vector113:
  pushl $0
c0100441:	6a 00                	push   $0x0
  pushl $113
c0100443:	6a 71                	push   $0x71
  jmp __alltraps
c0100445:	e9 ec fb ff ff       	jmp    c0100036 <__alltraps>

c010044a <vector114>:
.globl vector114
vector114:
  pushl $0
c010044a:	6a 00                	push   $0x0
  pushl $114
c010044c:	6a 72                	push   $0x72
  jmp __alltraps
c010044e:	e9 e3 fb ff ff       	jmp    c0100036 <__alltraps>

c0100453 <vector115>:
.globl vector115
vector115:
  pushl $0
c0100453:	6a 00                	push   $0x0
  pushl $115
c0100455:	6a 73                	push   $0x73
  jmp __alltraps
c0100457:	e9 da fb ff ff       	jmp    c0100036 <__alltraps>

c010045c <vector116>:
.globl vector116
vector116:
  pushl $0
c010045c:	6a 00                	push   $0x0
  pushl $116
c010045e:	6a 74                	push   $0x74
  jmp __alltraps
c0100460:	e9 d1 fb ff ff       	jmp    c0100036 <__alltraps>

c0100465 <vector117>:
.globl vector117
vector117:
  pushl $0
c0100465:	6a 00                	push   $0x0
  pushl $117
c0100467:	6a 75                	push   $0x75
  jmp __alltraps
c0100469:	e9 c8 fb ff ff       	jmp    c0100036 <__alltraps>

c010046e <vector118>:
.globl vector118
vector118:
  pushl $0
c010046e:	6a 00                	push   $0x0
  pushl $118
c0100470:	6a 76                	push   $0x76
  jmp __alltraps
c0100472:	e9 bf fb ff ff       	jmp    c0100036 <__alltraps>

c0100477 <vector119>:
.globl vector119
vector119:
  pushl $0
c0100477:	6a 00                	push   $0x0
  pushl $119
c0100479:	6a 77                	push   $0x77
  jmp __alltraps
c010047b:	e9 b6 fb ff ff       	jmp    c0100036 <__alltraps>

c0100480 <vector120>:
.globl vector120
vector120:
  pushl $0
c0100480:	6a 00                	push   $0x0
  pushl $120
c0100482:	6a 78                	push   $0x78
  jmp __alltraps
c0100484:	e9 ad fb ff ff       	jmp    c0100036 <__alltraps>

c0100489 <vector121>:
.globl vector121
vector121:
  pushl $0
c0100489:	6a 00                	push   $0x0
  pushl $121
c010048b:	6a 79                	push   $0x79
  jmp __alltraps
c010048d:	e9 a4 fb ff ff       	jmp    c0100036 <__alltraps>

c0100492 <vector122>:
.globl vector122
vector122:
  pushl $0
c0100492:	6a 00                	push   $0x0
  pushl $122
c0100494:	6a 7a                	push   $0x7a
  jmp __alltraps
c0100496:	e9 9b fb ff ff       	jmp    c0100036 <__alltraps>

c010049b <vector123>:
.globl vector123
vector123:
  pushl $0
c010049b:	6a 00                	push   $0x0
  pushl $123
c010049d:	6a 7b                	push   $0x7b
  jmp __alltraps
c010049f:	e9 92 fb ff ff       	jmp    c0100036 <__alltraps>

c01004a4 <vector124>:
.globl vector124
vector124:
  pushl $0
c01004a4:	6a 00                	push   $0x0
  pushl $124
c01004a6:	6a 7c                	push   $0x7c
  jmp __alltraps
c01004a8:	e9 89 fb ff ff       	jmp    c0100036 <__alltraps>

c01004ad <vector125>:
.globl vector125
vector125:
  pushl $0
c01004ad:	6a 00                	push   $0x0
  pushl $125
c01004af:	6a 7d                	push   $0x7d
  jmp __alltraps
c01004b1:	e9 80 fb ff ff       	jmp    c0100036 <__alltraps>

c01004b6 <vector126>:
.globl vector126
vector126:
  pushl $0
c01004b6:	6a 00                	push   $0x0
  pushl $126
c01004b8:	6a 7e                	push   $0x7e
  jmp __alltraps
c01004ba:	e9 77 fb ff ff       	jmp    c0100036 <__alltraps>

c01004bf <vector127>:
.globl vector127
vector127:
  pushl $0
c01004bf:	6a 00                	push   $0x0
  pushl $127
c01004c1:	6a 7f                	push   $0x7f
  jmp __alltraps
c01004c3:	e9 6e fb ff ff       	jmp    c0100036 <__alltraps>

c01004c8 <vector128>:
.globl vector128
vector128:
  pushl $0
c01004c8:	6a 00                	push   $0x0
  pushl $128
c01004ca:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c01004cf:	e9 62 fb ff ff       	jmp    c0100036 <__alltraps>

c01004d4 <vector129>:
.globl vector129
vector129:
  pushl $0
c01004d4:	6a 00                	push   $0x0
  pushl $129
c01004d6:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c01004db:	e9 56 fb ff ff       	jmp    c0100036 <__alltraps>

c01004e0 <vector130>:
.globl vector130
vector130:
  pushl $0
c01004e0:	6a 00                	push   $0x0
  pushl $130
c01004e2:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c01004e7:	e9 4a fb ff ff       	jmp    c0100036 <__alltraps>

c01004ec <vector131>:
.globl vector131
vector131:
  pushl $0
c01004ec:	6a 00                	push   $0x0
  pushl $131
c01004ee:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01004f3:	e9 3e fb ff ff       	jmp    c0100036 <__alltraps>

c01004f8 <vector132>:
.globl vector132
vector132:
  pushl $0
c01004f8:	6a 00                	push   $0x0
  pushl $132
c01004fa:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01004ff:	e9 32 fb ff ff       	jmp    c0100036 <__alltraps>

c0100504 <vector133>:
.globl vector133
vector133:
  pushl $0
c0100504:	6a 00                	push   $0x0
  pushl $133
c0100506:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c010050b:	e9 26 fb ff ff       	jmp    c0100036 <__alltraps>

c0100510 <vector134>:
.globl vector134
vector134:
  pushl $0
c0100510:	6a 00                	push   $0x0
  pushl $134
c0100512:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0100517:	e9 1a fb ff ff       	jmp    c0100036 <__alltraps>

c010051c <vector135>:
.globl vector135
vector135:
  pushl $0
c010051c:	6a 00                	push   $0x0
  pushl $135
c010051e:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0100523:	e9 0e fb ff ff       	jmp    c0100036 <__alltraps>

c0100528 <vector136>:
.globl vector136
vector136:
  pushl $0
c0100528:	6a 00                	push   $0x0
  pushl $136
c010052a:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c010052f:	e9 02 fb ff ff       	jmp    c0100036 <__alltraps>

c0100534 <vector137>:
.globl vector137
vector137:
  pushl $0
c0100534:	6a 00                	push   $0x0
  pushl $137
c0100536:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c010053b:	e9 f6 fa ff ff       	jmp    c0100036 <__alltraps>

c0100540 <vector138>:
.globl vector138
vector138:
  pushl $0
c0100540:	6a 00                	push   $0x0
  pushl $138
c0100542:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0100547:	e9 ea fa ff ff       	jmp    c0100036 <__alltraps>

c010054c <vector139>:
.globl vector139
vector139:
  pushl $0
c010054c:	6a 00                	push   $0x0
  pushl $139
c010054e:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0100553:	e9 de fa ff ff       	jmp    c0100036 <__alltraps>

c0100558 <vector140>:
.globl vector140
vector140:
  pushl $0
c0100558:	6a 00                	push   $0x0
  pushl $140
c010055a:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c010055f:	e9 d2 fa ff ff       	jmp    c0100036 <__alltraps>

c0100564 <vector141>:
.globl vector141
vector141:
  pushl $0
c0100564:	6a 00                	push   $0x0
  pushl $141
c0100566:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c010056b:	e9 c6 fa ff ff       	jmp    c0100036 <__alltraps>

c0100570 <vector142>:
.globl vector142
vector142:
  pushl $0
c0100570:	6a 00                	push   $0x0
  pushl $142
c0100572:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0100577:	e9 ba fa ff ff       	jmp    c0100036 <__alltraps>

c010057c <vector143>:
.globl vector143
vector143:
  pushl $0
c010057c:	6a 00                	push   $0x0
  pushl $143
c010057e:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0100583:	e9 ae fa ff ff       	jmp    c0100036 <__alltraps>

c0100588 <vector144>:
.globl vector144
vector144:
  pushl $0
c0100588:	6a 00                	push   $0x0
  pushl $144
c010058a:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c010058f:	e9 a2 fa ff ff       	jmp    c0100036 <__alltraps>

c0100594 <vector145>:
.globl vector145
vector145:
  pushl $0
c0100594:	6a 00                	push   $0x0
  pushl $145
c0100596:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c010059b:	e9 96 fa ff ff       	jmp    c0100036 <__alltraps>

c01005a0 <vector146>:
.globl vector146
vector146:
  pushl $0
c01005a0:	6a 00                	push   $0x0
  pushl $146
c01005a2:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01005a7:	e9 8a fa ff ff       	jmp    c0100036 <__alltraps>

c01005ac <vector147>:
.globl vector147
vector147:
  pushl $0
c01005ac:	6a 00                	push   $0x0
  pushl $147
c01005ae:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01005b3:	e9 7e fa ff ff       	jmp    c0100036 <__alltraps>

c01005b8 <vector148>:
.globl vector148
vector148:
  pushl $0
c01005b8:	6a 00                	push   $0x0
  pushl $148
c01005ba:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01005bf:	e9 72 fa ff ff       	jmp    c0100036 <__alltraps>

c01005c4 <vector149>:
.globl vector149
vector149:
  pushl $0
c01005c4:	6a 00                	push   $0x0
  pushl $149
c01005c6:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c01005cb:	e9 66 fa ff ff       	jmp    c0100036 <__alltraps>

c01005d0 <vector150>:
.globl vector150
vector150:
  pushl $0
c01005d0:	6a 00                	push   $0x0
  pushl $150
c01005d2:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c01005d7:	e9 5a fa ff ff       	jmp    c0100036 <__alltraps>

c01005dc <vector151>:
.globl vector151
vector151:
  pushl $0
c01005dc:	6a 00                	push   $0x0
  pushl $151
c01005de:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c01005e3:	e9 4e fa ff ff       	jmp    c0100036 <__alltraps>

c01005e8 <vector152>:
.globl vector152
vector152:
  pushl $0
c01005e8:	6a 00                	push   $0x0
  pushl $152
c01005ea:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01005ef:	e9 42 fa ff ff       	jmp    c0100036 <__alltraps>

c01005f4 <vector153>:
.globl vector153
vector153:
  pushl $0
c01005f4:	6a 00                	push   $0x0
  pushl $153
c01005f6:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01005fb:	e9 36 fa ff ff       	jmp    c0100036 <__alltraps>

c0100600 <vector154>:
.globl vector154
vector154:
  pushl $0
c0100600:	6a 00                	push   $0x0
  pushl $154
c0100602:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0100607:	e9 2a fa ff ff       	jmp    c0100036 <__alltraps>

c010060c <vector155>:
.globl vector155
vector155:
  pushl $0
c010060c:	6a 00                	push   $0x0
  pushl $155
c010060e:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0100613:	e9 1e fa ff ff       	jmp    c0100036 <__alltraps>

c0100618 <vector156>:
.globl vector156
vector156:
  pushl $0
c0100618:	6a 00                	push   $0x0
  pushl $156
c010061a:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c010061f:	e9 12 fa ff ff       	jmp    c0100036 <__alltraps>

c0100624 <vector157>:
.globl vector157
vector157:
  pushl $0
c0100624:	6a 00                	push   $0x0
  pushl $157
c0100626:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c010062b:	e9 06 fa ff ff       	jmp    c0100036 <__alltraps>

c0100630 <vector158>:
.globl vector158
vector158:
  pushl $0
c0100630:	6a 00                	push   $0x0
  pushl $158
c0100632:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0100637:	e9 fa f9 ff ff       	jmp    c0100036 <__alltraps>

c010063c <vector159>:
.globl vector159
vector159:
  pushl $0
c010063c:	6a 00                	push   $0x0
  pushl $159
c010063e:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0100643:	e9 ee f9 ff ff       	jmp    c0100036 <__alltraps>

c0100648 <vector160>:
.globl vector160
vector160:
  pushl $0
c0100648:	6a 00                	push   $0x0
  pushl $160
c010064a:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c010064f:	e9 e2 f9 ff ff       	jmp    c0100036 <__alltraps>

c0100654 <vector161>:
.globl vector161
vector161:
  pushl $0
c0100654:	6a 00                	push   $0x0
  pushl $161
c0100656:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c010065b:	e9 d6 f9 ff ff       	jmp    c0100036 <__alltraps>

c0100660 <vector162>:
.globl vector162
vector162:
  pushl $0
c0100660:	6a 00                	push   $0x0
  pushl $162
c0100662:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0100667:	e9 ca f9 ff ff       	jmp    c0100036 <__alltraps>

c010066c <vector163>:
.globl vector163
vector163:
  pushl $0
c010066c:	6a 00                	push   $0x0
  pushl $163
c010066e:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0100673:	e9 be f9 ff ff       	jmp    c0100036 <__alltraps>

c0100678 <vector164>:
.globl vector164
vector164:
  pushl $0
c0100678:	6a 00                	push   $0x0
  pushl $164
c010067a:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010067f:	e9 b2 f9 ff ff       	jmp    c0100036 <__alltraps>

c0100684 <vector165>:
.globl vector165
vector165:
  pushl $0
c0100684:	6a 00                	push   $0x0
  pushl $165
c0100686:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c010068b:	e9 a6 f9 ff ff       	jmp    c0100036 <__alltraps>

c0100690 <vector166>:
.globl vector166
vector166:
  pushl $0
c0100690:	6a 00                	push   $0x0
  pushl $166
c0100692:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0100697:	e9 9a f9 ff ff       	jmp    c0100036 <__alltraps>

c010069c <vector167>:
.globl vector167
vector167:
  pushl $0
c010069c:	6a 00                	push   $0x0
  pushl $167
c010069e:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01006a3:	e9 8e f9 ff ff       	jmp    c0100036 <__alltraps>

c01006a8 <vector168>:
.globl vector168
vector168:
  pushl $0
c01006a8:	6a 00                	push   $0x0
  pushl $168
c01006aa:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01006af:	e9 82 f9 ff ff       	jmp    c0100036 <__alltraps>

c01006b4 <vector169>:
.globl vector169
vector169:
  pushl $0
c01006b4:	6a 00                	push   $0x0
  pushl $169
c01006b6:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01006bb:	e9 76 f9 ff ff       	jmp    c0100036 <__alltraps>

c01006c0 <vector170>:
.globl vector170
vector170:
  pushl $0
c01006c0:	6a 00                	push   $0x0
  pushl $170
c01006c2:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01006c7:	e9 6a f9 ff ff       	jmp    c0100036 <__alltraps>

c01006cc <vector171>:
.globl vector171
vector171:
  pushl $0
c01006cc:	6a 00                	push   $0x0
  pushl $171
c01006ce:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c01006d3:	e9 5e f9 ff ff       	jmp    c0100036 <__alltraps>

c01006d8 <vector172>:
.globl vector172
vector172:
  pushl $0
c01006d8:	6a 00                	push   $0x0
  pushl $172
c01006da:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c01006df:	e9 52 f9 ff ff       	jmp    c0100036 <__alltraps>

c01006e4 <vector173>:
.globl vector173
vector173:
  pushl $0
c01006e4:	6a 00                	push   $0x0
  pushl $173
c01006e6:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01006eb:	e9 46 f9 ff ff       	jmp    c0100036 <__alltraps>

c01006f0 <vector174>:
.globl vector174
vector174:
  pushl $0
c01006f0:	6a 00                	push   $0x0
  pushl $174
c01006f2:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01006f7:	e9 3a f9 ff ff       	jmp    c0100036 <__alltraps>

c01006fc <vector175>:
.globl vector175
vector175:
  pushl $0
c01006fc:	6a 00                	push   $0x0
  pushl $175
c01006fe:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0100703:	e9 2e f9 ff ff       	jmp    c0100036 <__alltraps>

c0100708 <vector176>:
.globl vector176
vector176:
  pushl $0
c0100708:	6a 00                	push   $0x0
  pushl $176
c010070a:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010070f:	e9 22 f9 ff ff       	jmp    c0100036 <__alltraps>

c0100714 <vector177>:
.globl vector177
vector177:
  pushl $0
c0100714:	6a 00                	push   $0x0
  pushl $177
c0100716:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c010071b:	e9 16 f9 ff ff       	jmp    c0100036 <__alltraps>

c0100720 <vector178>:
.globl vector178
vector178:
  pushl $0
c0100720:	6a 00                	push   $0x0
  pushl $178
c0100722:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0100727:	e9 0a f9 ff ff       	jmp    c0100036 <__alltraps>

c010072c <vector179>:
.globl vector179
vector179:
  pushl $0
c010072c:	6a 00                	push   $0x0
  pushl $179
c010072e:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0100733:	e9 fe f8 ff ff       	jmp    c0100036 <__alltraps>

c0100738 <vector180>:
.globl vector180
vector180:
  pushl $0
c0100738:	6a 00                	push   $0x0
  pushl $180
c010073a:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c010073f:	e9 f2 f8 ff ff       	jmp    c0100036 <__alltraps>

c0100744 <vector181>:
.globl vector181
vector181:
  pushl $0
c0100744:	6a 00                	push   $0x0
  pushl $181
c0100746:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c010074b:	e9 e6 f8 ff ff       	jmp    c0100036 <__alltraps>

c0100750 <vector182>:
.globl vector182
vector182:
  pushl $0
c0100750:	6a 00                	push   $0x0
  pushl $182
c0100752:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0100757:	e9 da f8 ff ff       	jmp    c0100036 <__alltraps>

c010075c <vector183>:
.globl vector183
vector183:
  pushl $0
c010075c:	6a 00                	push   $0x0
  pushl $183
c010075e:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0100763:	e9 ce f8 ff ff       	jmp    c0100036 <__alltraps>

c0100768 <vector184>:
.globl vector184
vector184:
  pushl $0
c0100768:	6a 00                	push   $0x0
  pushl $184
c010076a:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c010076f:	e9 c2 f8 ff ff       	jmp    c0100036 <__alltraps>

c0100774 <vector185>:
.globl vector185
vector185:
  pushl $0
c0100774:	6a 00                	push   $0x0
  pushl $185
c0100776:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c010077b:	e9 b6 f8 ff ff       	jmp    c0100036 <__alltraps>

c0100780 <vector186>:
.globl vector186
vector186:
  pushl $0
c0100780:	6a 00                	push   $0x0
  pushl $186
c0100782:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0100787:	e9 aa f8 ff ff       	jmp    c0100036 <__alltraps>

c010078c <vector187>:
.globl vector187
vector187:
  pushl $0
c010078c:	6a 00                	push   $0x0
  pushl $187
c010078e:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0100793:	e9 9e f8 ff ff       	jmp    c0100036 <__alltraps>

c0100798 <vector188>:
.globl vector188
vector188:
  pushl $0
c0100798:	6a 00                	push   $0x0
  pushl $188
c010079a:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c010079f:	e9 92 f8 ff ff       	jmp    c0100036 <__alltraps>

c01007a4 <vector189>:
.globl vector189
vector189:
  pushl $0
c01007a4:	6a 00                	push   $0x0
  pushl $189
c01007a6:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01007ab:	e9 86 f8 ff ff       	jmp    c0100036 <__alltraps>

c01007b0 <vector190>:
.globl vector190
vector190:
  pushl $0
c01007b0:	6a 00                	push   $0x0
  pushl $190
c01007b2:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01007b7:	e9 7a f8 ff ff       	jmp    c0100036 <__alltraps>

c01007bc <vector191>:
.globl vector191
vector191:
  pushl $0
c01007bc:	6a 00                	push   $0x0
  pushl $191
c01007be:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01007c3:	e9 6e f8 ff ff       	jmp    c0100036 <__alltraps>

c01007c8 <vector192>:
.globl vector192
vector192:
  pushl $0
c01007c8:	6a 00                	push   $0x0
  pushl $192
c01007ca:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c01007cf:	e9 62 f8 ff ff       	jmp    c0100036 <__alltraps>

c01007d4 <vector193>:
.globl vector193
vector193:
  pushl $0
c01007d4:	6a 00                	push   $0x0
  pushl $193
c01007d6:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c01007db:	e9 56 f8 ff ff       	jmp    c0100036 <__alltraps>

c01007e0 <vector194>:
.globl vector194
vector194:
  pushl $0
c01007e0:	6a 00                	push   $0x0
  pushl $194
c01007e2:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c01007e7:	e9 4a f8 ff ff       	jmp    c0100036 <__alltraps>

c01007ec <vector195>:
.globl vector195
vector195:
  pushl $0
c01007ec:	6a 00                	push   $0x0
  pushl $195
c01007ee:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01007f3:	e9 3e f8 ff ff       	jmp    c0100036 <__alltraps>

c01007f8 <vector196>:
.globl vector196
vector196:
  pushl $0
c01007f8:	6a 00                	push   $0x0
  pushl $196
c01007fa:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01007ff:	e9 32 f8 ff ff       	jmp    c0100036 <__alltraps>

c0100804 <vector197>:
.globl vector197
vector197:
  pushl $0
c0100804:	6a 00                	push   $0x0
  pushl $197
c0100806:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c010080b:	e9 26 f8 ff ff       	jmp    c0100036 <__alltraps>

c0100810 <vector198>:
.globl vector198
vector198:
  pushl $0
c0100810:	6a 00                	push   $0x0
  pushl $198
c0100812:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0100817:	e9 1a f8 ff ff       	jmp    c0100036 <__alltraps>

c010081c <vector199>:
.globl vector199
vector199:
  pushl $0
c010081c:	6a 00                	push   $0x0
  pushl $199
c010081e:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0100823:	e9 0e f8 ff ff       	jmp    c0100036 <__alltraps>

c0100828 <vector200>:
.globl vector200
vector200:
  pushl $0
c0100828:	6a 00                	push   $0x0
  pushl $200
c010082a:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c010082f:	e9 02 f8 ff ff       	jmp    c0100036 <__alltraps>

c0100834 <vector201>:
.globl vector201
vector201:
  pushl $0
c0100834:	6a 00                	push   $0x0
  pushl $201
c0100836:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c010083b:	e9 f6 f7 ff ff       	jmp    c0100036 <__alltraps>

c0100840 <vector202>:
.globl vector202
vector202:
  pushl $0
c0100840:	6a 00                	push   $0x0
  pushl $202
c0100842:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0100847:	e9 ea f7 ff ff       	jmp    c0100036 <__alltraps>

c010084c <vector203>:
.globl vector203
vector203:
  pushl $0
c010084c:	6a 00                	push   $0x0
  pushl $203
c010084e:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0100853:	e9 de f7 ff ff       	jmp    c0100036 <__alltraps>

c0100858 <vector204>:
.globl vector204
vector204:
  pushl $0
c0100858:	6a 00                	push   $0x0
  pushl $204
c010085a:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c010085f:	e9 d2 f7 ff ff       	jmp    c0100036 <__alltraps>

c0100864 <vector205>:
.globl vector205
vector205:
  pushl $0
c0100864:	6a 00                	push   $0x0
  pushl $205
c0100866:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c010086b:	e9 c6 f7 ff ff       	jmp    c0100036 <__alltraps>

c0100870 <vector206>:
.globl vector206
vector206:
  pushl $0
c0100870:	6a 00                	push   $0x0
  pushl $206
c0100872:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0100877:	e9 ba f7 ff ff       	jmp    c0100036 <__alltraps>

c010087c <vector207>:
.globl vector207
vector207:
  pushl $0
c010087c:	6a 00                	push   $0x0
  pushl $207
c010087e:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0100883:	e9 ae f7 ff ff       	jmp    c0100036 <__alltraps>

c0100888 <vector208>:
.globl vector208
vector208:
  pushl $0
c0100888:	6a 00                	push   $0x0
  pushl $208
c010088a:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c010088f:	e9 a2 f7 ff ff       	jmp    c0100036 <__alltraps>

c0100894 <vector209>:
.globl vector209
vector209:
  pushl $0
c0100894:	6a 00                	push   $0x0
  pushl $209
c0100896:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c010089b:	e9 96 f7 ff ff       	jmp    c0100036 <__alltraps>

c01008a0 <vector210>:
.globl vector210
vector210:
  pushl $0
c01008a0:	6a 00                	push   $0x0
  pushl $210
c01008a2:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01008a7:	e9 8a f7 ff ff       	jmp    c0100036 <__alltraps>

c01008ac <vector211>:
.globl vector211
vector211:
  pushl $0
c01008ac:	6a 00                	push   $0x0
  pushl $211
c01008ae:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01008b3:	e9 7e f7 ff ff       	jmp    c0100036 <__alltraps>

c01008b8 <vector212>:
.globl vector212
vector212:
  pushl $0
c01008b8:	6a 00                	push   $0x0
  pushl $212
c01008ba:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01008bf:	e9 72 f7 ff ff       	jmp    c0100036 <__alltraps>

c01008c4 <vector213>:
.globl vector213
vector213:
  pushl $0
c01008c4:	6a 00                	push   $0x0
  pushl $213
c01008c6:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c01008cb:	e9 66 f7 ff ff       	jmp    c0100036 <__alltraps>

c01008d0 <vector214>:
.globl vector214
vector214:
  pushl $0
c01008d0:	6a 00                	push   $0x0
  pushl $214
c01008d2:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c01008d7:	e9 5a f7 ff ff       	jmp    c0100036 <__alltraps>

c01008dc <vector215>:
.globl vector215
vector215:
  pushl $0
c01008dc:	6a 00                	push   $0x0
  pushl $215
c01008de:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c01008e3:	e9 4e f7 ff ff       	jmp    c0100036 <__alltraps>

c01008e8 <vector216>:
.globl vector216
vector216:
  pushl $0
c01008e8:	6a 00                	push   $0x0
  pushl $216
c01008ea:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01008ef:	e9 42 f7 ff ff       	jmp    c0100036 <__alltraps>

c01008f4 <vector217>:
.globl vector217
vector217:
  pushl $0
c01008f4:	6a 00                	push   $0x0
  pushl $217
c01008f6:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01008fb:	e9 36 f7 ff ff       	jmp    c0100036 <__alltraps>

c0100900 <vector218>:
.globl vector218
vector218:
  pushl $0
c0100900:	6a 00                	push   $0x0
  pushl $218
c0100902:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0100907:	e9 2a f7 ff ff       	jmp    c0100036 <__alltraps>

c010090c <vector219>:
.globl vector219
vector219:
  pushl $0
c010090c:	6a 00                	push   $0x0
  pushl $219
c010090e:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0100913:	e9 1e f7 ff ff       	jmp    c0100036 <__alltraps>

c0100918 <vector220>:
.globl vector220
vector220:
  pushl $0
c0100918:	6a 00                	push   $0x0
  pushl $220
c010091a:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c010091f:	e9 12 f7 ff ff       	jmp    c0100036 <__alltraps>

c0100924 <vector221>:
.globl vector221
vector221:
  pushl $0
c0100924:	6a 00                	push   $0x0
  pushl $221
c0100926:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c010092b:	e9 06 f7 ff ff       	jmp    c0100036 <__alltraps>

c0100930 <vector222>:
.globl vector222
vector222:
  pushl $0
c0100930:	6a 00                	push   $0x0
  pushl $222
c0100932:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0100937:	e9 fa f6 ff ff       	jmp    c0100036 <__alltraps>

c010093c <vector223>:
.globl vector223
vector223:
  pushl $0
c010093c:	6a 00                	push   $0x0
  pushl $223
c010093e:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0100943:	e9 ee f6 ff ff       	jmp    c0100036 <__alltraps>

c0100948 <vector224>:
.globl vector224
vector224:
  pushl $0
c0100948:	6a 00                	push   $0x0
  pushl $224
c010094a:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010094f:	e9 e2 f6 ff ff       	jmp    c0100036 <__alltraps>

c0100954 <vector225>:
.globl vector225
vector225:
  pushl $0
c0100954:	6a 00                	push   $0x0
  pushl $225
c0100956:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c010095b:	e9 d6 f6 ff ff       	jmp    c0100036 <__alltraps>

c0100960 <vector226>:
.globl vector226
vector226:
  pushl $0
c0100960:	6a 00                	push   $0x0
  pushl $226
c0100962:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0100967:	e9 ca f6 ff ff       	jmp    c0100036 <__alltraps>

c010096c <vector227>:
.globl vector227
vector227:
  pushl $0
c010096c:	6a 00                	push   $0x0
  pushl $227
c010096e:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0100973:	e9 be f6 ff ff       	jmp    c0100036 <__alltraps>

c0100978 <vector228>:
.globl vector228
vector228:
  pushl $0
c0100978:	6a 00                	push   $0x0
  pushl $228
c010097a:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010097f:	e9 b2 f6 ff ff       	jmp    c0100036 <__alltraps>

c0100984 <vector229>:
.globl vector229
vector229:
  pushl $0
c0100984:	6a 00                	push   $0x0
  pushl $229
c0100986:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c010098b:	e9 a6 f6 ff ff       	jmp    c0100036 <__alltraps>

c0100990 <vector230>:
.globl vector230
vector230:
  pushl $0
c0100990:	6a 00                	push   $0x0
  pushl $230
c0100992:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0100997:	e9 9a f6 ff ff       	jmp    c0100036 <__alltraps>

c010099c <vector231>:
.globl vector231
vector231:
  pushl $0
c010099c:	6a 00                	push   $0x0
  pushl $231
c010099e:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01009a3:	e9 8e f6 ff ff       	jmp    c0100036 <__alltraps>

c01009a8 <vector232>:
.globl vector232
vector232:
  pushl $0
c01009a8:	6a 00                	push   $0x0
  pushl $232
c01009aa:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c01009af:	e9 82 f6 ff ff       	jmp    c0100036 <__alltraps>

c01009b4 <vector233>:
.globl vector233
vector233:
  pushl $0
c01009b4:	6a 00                	push   $0x0
  pushl $233
c01009b6:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c01009bb:	e9 76 f6 ff ff       	jmp    c0100036 <__alltraps>

c01009c0 <vector234>:
.globl vector234
vector234:
  pushl $0
c01009c0:	6a 00                	push   $0x0
  pushl $234
c01009c2:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01009c7:	e9 6a f6 ff ff       	jmp    c0100036 <__alltraps>

c01009cc <vector235>:
.globl vector235
vector235:
  pushl $0
c01009cc:	6a 00                	push   $0x0
  pushl $235
c01009ce:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01009d3:	e9 5e f6 ff ff       	jmp    c0100036 <__alltraps>

c01009d8 <vector236>:
.globl vector236
vector236:
  pushl $0
c01009d8:	6a 00                	push   $0x0
  pushl $236
c01009da:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01009df:	e9 52 f6 ff ff       	jmp    c0100036 <__alltraps>

c01009e4 <vector237>:
.globl vector237
vector237:
  pushl $0
c01009e4:	6a 00                	push   $0x0
  pushl $237
c01009e6:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01009eb:	e9 46 f6 ff ff       	jmp    c0100036 <__alltraps>

c01009f0 <vector238>:
.globl vector238
vector238:
  pushl $0
c01009f0:	6a 00                	push   $0x0
  pushl $238
c01009f2:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01009f7:	e9 3a f6 ff ff       	jmp    c0100036 <__alltraps>

c01009fc <vector239>:
.globl vector239
vector239:
  pushl $0
c01009fc:	6a 00                	push   $0x0
  pushl $239
c01009fe:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0100a03:	e9 2e f6 ff ff       	jmp    c0100036 <__alltraps>

c0100a08 <vector240>:
.globl vector240
vector240:
  pushl $0
c0100a08:	6a 00                	push   $0x0
  pushl $240
c0100a0a:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0100a0f:	e9 22 f6 ff ff       	jmp    c0100036 <__alltraps>

c0100a14 <vector241>:
.globl vector241
vector241:
  pushl $0
c0100a14:	6a 00                	push   $0x0
  pushl $241
c0100a16:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0100a1b:	e9 16 f6 ff ff       	jmp    c0100036 <__alltraps>

c0100a20 <vector242>:
.globl vector242
vector242:
  pushl $0
c0100a20:	6a 00                	push   $0x0
  pushl $242
c0100a22:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0100a27:	e9 0a f6 ff ff       	jmp    c0100036 <__alltraps>

c0100a2c <vector243>:
.globl vector243
vector243:
  pushl $0
c0100a2c:	6a 00                	push   $0x0
  pushl $243
c0100a2e:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0100a33:	e9 fe f5 ff ff       	jmp    c0100036 <__alltraps>

c0100a38 <vector244>:
.globl vector244
vector244:
  pushl $0
c0100a38:	6a 00                	push   $0x0
  pushl $244
c0100a3a:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0100a3f:	e9 f2 f5 ff ff       	jmp    c0100036 <__alltraps>

c0100a44 <vector245>:
.globl vector245
vector245:
  pushl $0
c0100a44:	6a 00                	push   $0x0
  pushl $245
c0100a46:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0100a4b:	e9 e6 f5 ff ff       	jmp    c0100036 <__alltraps>

c0100a50 <vector246>:
.globl vector246
vector246:
  pushl $0
c0100a50:	6a 00                	push   $0x0
  pushl $246
c0100a52:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0100a57:	e9 da f5 ff ff       	jmp    c0100036 <__alltraps>

c0100a5c <vector247>:
.globl vector247
vector247:
  pushl $0
c0100a5c:	6a 00                	push   $0x0
  pushl $247
c0100a5e:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0100a63:	e9 ce f5 ff ff       	jmp    c0100036 <__alltraps>

c0100a68 <vector248>:
.globl vector248
vector248:
  pushl $0
c0100a68:	6a 00                	push   $0x0
  pushl $248
c0100a6a:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0100a6f:	e9 c2 f5 ff ff       	jmp    c0100036 <__alltraps>

c0100a74 <vector249>:
.globl vector249
vector249:
  pushl $0
c0100a74:	6a 00                	push   $0x0
  pushl $249
c0100a76:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0100a7b:	e9 b6 f5 ff ff       	jmp    c0100036 <__alltraps>

c0100a80 <vector250>:
.globl vector250
vector250:
  pushl $0
c0100a80:	6a 00                	push   $0x0
  pushl $250
c0100a82:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0100a87:	e9 aa f5 ff ff       	jmp    c0100036 <__alltraps>

c0100a8c <vector251>:
.globl vector251
vector251:
  pushl $0
c0100a8c:	6a 00                	push   $0x0
  pushl $251
c0100a8e:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0100a93:	e9 9e f5 ff ff       	jmp    c0100036 <__alltraps>

c0100a98 <vector252>:
.globl vector252
vector252:
  pushl $0
c0100a98:	6a 00                	push   $0x0
  pushl $252
c0100a9a:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0100a9f:	e9 92 f5 ff ff       	jmp    c0100036 <__alltraps>

c0100aa4 <vector253>:
.globl vector253
vector253:
  pushl $0
c0100aa4:	6a 00                	push   $0x0
  pushl $253
c0100aa6:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0100aab:	e9 86 f5 ff ff       	jmp    c0100036 <__alltraps>

c0100ab0 <vector254>:
.globl vector254
vector254:
  pushl $0
c0100ab0:	6a 00                	push   $0x0
  pushl $254
c0100ab2:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0100ab7:	e9 7a f5 ff ff       	jmp    c0100036 <__alltraps>

c0100abc <vector255>:
.globl vector255
vector255:
  pushl $0
c0100abc:	6a 00                	push   $0x0
  pushl $255
c0100abe:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0100ac3:	e9 6e f5 ff ff       	jmp    c0100036 <__alltraps>

c0100ac8 <initKernel>:
#include <phymm.h>
#include <list.hpp>
#include <gstatic.h>   

/*  kernel entry point  */
extern "C" void initKernel() {
c0100ac8:	55                   	push   %ebp
c0100ac9:	89 e5                	mov    %esp,%ebp
c0100acb:	57                   	push   %edi
c0100acc:	56                   	push   %esi
c0100acd:	53                   	push   %ebx
c0100ace:	e8 ba 00 00 00       	call   c0100b8d <__x86.get_pc_thunk.bx>
c0100ad3:	81 c3 35 e9 00 00    	add    $0xe935,%ebx
c0100ad9:	81 ec 38 03 00 00    	sub    $0x338,%esp
    Console cons;
c0100adf:	8d b5 e4 fc ff ff    	lea    -0x31c(%ebp),%esi
c0100ae5:	56                   	push   %esi
    cons.init();
    cons.setBackground("white");
c0100ae6:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
    Console cons;
c0100aec:	e8 a1 00 00 00       	call   c0100b92 <_ZN7ConsoleC1Ev>
    cons.init();
c0100af1:	89 34 24             	mov    %esi,(%esp)
c0100af4:	e8 d5 02 00 00       	call   c0100dce <_ZN7Console4initEv>
    cons.setBackground("white");
c0100af9:	58                   	pop    %eax
c0100afa:	8d 83 45 26 ff ff    	lea    -0xd9bb(%ebx),%eax
c0100b00:	5a                   	pop    %edx
c0100b01:	50                   	push   %eax
c0100b02:	57                   	push   %edi
c0100b03:	e8 92 0e 00 00       	call   c010199a <_ZN6StringC1EPKc>
c0100b08:	59                   	pop    %ecx
c0100b09:	58                   	pop    %eax
c0100b0a:	57                   	push   %edi
c0100b0b:	56                   	push   %esi
c0100b0c:	e8 b5 01 00 00       	call   c0100cc6 <_ZN7Console13setBackgroundE6String>
    OStream os("Welcome SPX OS.....\n\n", "blue");
c0100b11:	8d b5 20 fd ff ff    	lea    -0x2e0(%ebp),%esi
    cons.setBackground("white");
c0100b17:	89 3c 24             	mov    %edi,(%esp)
c0100b1a:	e8 95 0e 00 00       	call   c01019b4 <_ZN6StringD1Ev>
    OStream os("Welcome SPX OS.....\n\n", "blue");
c0100b1f:	58                   	pop    %eax
c0100b20:	8d 83 4b 26 ff ff    	lea    -0xd9b5(%ebx),%eax
c0100b26:	5a                   	pop    %edx
c0100b27:	50                   	push   %eax
c0100b28:	56                   	push   %esi
c0100b29:	e8 6c 0e 00 00       	call   c010199a <_ZN6StringC1EPKc>
c0100b2e:	59                   	pop    %ecx
c0100b2f:	58                   	pop    %eax
c0100b30:	8d 83 50 26 ff ff    	lea    -0xd9b0(%ebx),%eax
c0100b36:	50                   	push   %eax
c0100b37:	8d 85 dc fc ff ff    	lea    -0x324(%ebp),%eax
c0100b3d:	50                   	push   %eax
c0100b3e:	89 85 d4 fc ff ff    	mov    %eax,-0x32c(%ebp)
c0100b44:	e8 51 0e 00 00       	call   c010199a <_ZN6StringC1EPKc>
c0100b49:	8b 85 d4 fc ff ff    	mov    -0x32c(%ebp),%eax
c0100b4f:	83 c4 0c             	add    $0xc,%esp
c0100b52:	56                   	push   %esi
c0100b53:	50                   	push   %eax
c0100b54:	57                   	push   %edi
c0100b55:	e8 d2 06 00 00       	call   c010122c <_ZN7OStreamC1E6StringS0_>
c0100b5a:	8b 85 d4 fc ff ff    	mov    -0x32c(%ebp),%eax
c0100b60:	89 04 24             	mov    %eax,(%esp)
c0100b63:	e8 4c 0e 00 00       	call   c01019b4 <_ZN6StringD1Ev>
c0100b68:	89 34 24             	mov    %esi,(%esp)
c0100b6b:	e8 44 0e 00 00       	call   c01019b4 <_ZN6StringD1Ev>
    os.flush();
c0100b70:	89 3c 24             	mov    %edi,(%esp)
c0100b73:	e8 52 07 00 00       	call   c01012ca <_ZN7OStream5flushEv>
#include <mmu.h>
#include <flags.h>

/*      physical Memory management      */

class PhyMM : public MMU {
c0100b78:	89 34 24             	mov    %esi,(%esp)
c0100b7b:	e8 02 0d 00 00       	call   c0101882 <_ZN3MMUC1Ev>
    PhyMM pm;
    pm.init();
c0100b80:	89 34 24             	mov    %esi,(%esp)
c0100b83:	e8 da 0c 00 00       	call   c0101862 <_ZN5PhyMM4initEv>
c0100b88:	83 c4 10             	add    $0x10,%esp
c0100b8b:	eb fe                	jmp    c0100b8b <initKernel+0xc3>

c0100b8d <__x86.get_pc_thunk.bx>:
c0100b8d:	8b 1c 24             	mov    (%esp),%ebx
c0100b90:	c3                   	ret    
c0100b91:	90                   	nop

c0100b92 <_ZN7ConsoleC1Ev>:
 * @Last Modified time: 2020-04-03 20:16:23
 */

#include <console.h>

Console::Console() {
c0100b92:	55                   	push   %ebp
c0100b93:	89 e5                	mov    %esp,%ebp
c0100b95:	56                   	push   %esi
c0100b96:	8b 75 08             	mov    0x8(%ebp),%esi
c0100b99:	53                   	push   %ebx
c0100b9a:	e8 ee ff ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c0100b9f:	81 c3 69 e8 00 00    	add    $0xe869,%ebx
c0100ba5:	83 ec 0c             	sub    $0xc,%esp
c0100ba8:	56                   	push   %esi
c0100ba9:	e8 f6 05 00 00       	call   c01011a4 <_ZN11VideoMemoryC1Ev>
c0100bae:	58                   	pop    %eax
c0100baf:	8d 83 66 26 ff ff    	lea    -0xd99a(%ebx),%eax
c0100bb5:	5a                   	pop    %edx
c0100bb6:	50                   	push   %eax
c0100bb7:	8d 46 08             	lea    0x8(%esi),%eax
c0100bba:	50                   	push   %eax
c0100bbb:	e8 da 0d 00 00       	call   c010199a <_ZN6StringC1EPKc>
c0100bc0:	59                   	pop    %ecx
c0100bc1:	58                   	pop    %eax
c0100bc2:	8d 83 6a 26 ff ff    	lea    -0xd996(%ebx),%eax
c0100bc8:	50                   	push   %eax
c0100bc9:	8d 46 10             	lea    0x10(%esi),%eax
c0100bcc:	50                   	push   %eax
c0100bcd:	e8 c8 0d 00 00       	call   c010199a <_ZN6StringC1EPKc>
c0100bd2:	58                   	pop    %eax
c0100bd3:	8d 83 45 26 ff ff    	lea    -0xd9bb(%ebx),%eax
c0100bd9:	5a                   	pop    %edx
c0100bda:	50                   	push   %eax
c0100bdb:	8d 46 18             	lea    0x18(%esi),%eax
c0100bde:	50                   	push   %eax
c0100bdf:	e8 b6 0d 00 00       	call   c010199a <_ZN6StringC1EPKc>
c0100be4:	59                   	pop    %ecx
c0100be5:	58                   	pop    %eax
c0100be6:	8d 83 4b 26 ff ff    	lea    -0xd9b5(%ebx),%eax
c0100bec:	50                   	push   %eax
c0100bed:	8d 46 20             	lea    0x20(%esi),%eax
c0100bf0:	50                   	push   %eax
c0100bf1:	e8 a4 0d 00 00       	call   c010199a <_ZN6StringC1EPKc>
    // set l and w
    length = 80;
    wide = 25;
    
    // get Video Memory buffer
    screen = (Char *)(VideoMemory::vmBuffer);
c0100bf6:	8b 06                	mov    (%esi),%eax
Console::Console() {
c0100bf8:	c7 46 28 04 00 07 01 	movl   $0x1070004,0x28(%esi)
    length = 80;
c0100bff:	c7 46 30 50 00 00 00 	movl   $0x50,0x30(%esi)
    wide = 25;
c0100c06:	c7 46 34 19 00 00 00 	movl   $0x19,0x34(%esi)
    screen = (Char *)(VideoMemory::vmBuffer);
c0100c0d:	89 46 2c             	mov    %eax,0x2c(%esi)

    // get cursor position
    cPos.x = VideoMemory::getCursorPos() / length;
c0100c10:	89 34 24             	mov    %esi,(%esp)
c0100c13:	e8 b8 05 00 00       	call   c01011d0 <_ZN11VideoMemory12getCursorPosEv>
c0100c18:	31 d2                	xor    %edx,%edx
c0100c1a:	0f b7 c0             	movzwl %ax,%eax
c0100c1d:	f7 76 30             	divl   0x30(%esi)
c0100c20:	88 46 38             	mov    %al,0x38(%esi)
    cPos.y = VideoMemory::getCursorPos() % length;
c0100c23:	89 34 24             	mov    %esi,(%esp)
c0100c26:	e8 a5 05 00 00       	call   c01011d0 <_ZN11VideoMemory12getCursorPosEv>
c0100c2b:	31 d2                	xor    %edx,%edx

    // set cursor status
    cursorStatus.c = 'S';
    cursorStatus.attri = 0b10101010;        // light green and flash
}
c0100c2d:	83 c4 10             	add    $0x10,%esp
    cursorStatus.c = 'S';
c0100c30:	66 c7 46 3a 53 aa    	movw   $0xaa53,0x3a(%esi)
    cPos.y = VideoMemory::getCursorPos() % length;
c0100c36:	0f b7 c0             	movzwl %ax,%eax
c0100c39:	f7 76 30             	divl   0x30(%esi)
c0100c3c:	88 56 39             	mov    %dl,0x39(%esi)
}
c0100c3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0100c42:	5b                   	pop    %ebx
c0100c43:	5e                   	pop    %esi
c0100c44:	5d                   	pop    %ebp
c0100c45:	c3                   	ret    

c0100c46 <_ZN7Console5clearEv>:

void Console::clear() {
c0100c46:	55                   	push   %ebp
c0100c47:	89 e5                	mov    %esp,%ebp
c0100c49:	53                   	push   %ebx
c0100c4a:	e8 3e ff ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c0100c4f:	81 c3 b9 e7 00 00    	add    $0xe7b9,%ebx
c0100c55:	83 ec 10             	sub    $0x10,%esp
    VideoMemory::initVmBuff();
c0100c58:	ff 75 08             	pushl  0x8(%ebp)
c0100c5b:	e8 58 05 00 00       	call   c01011b8 <_ZN11VideoMemory10initVmBuffEv>
}
c0100c60:	83 c4 10             	add    $0x10,%esp
c0100c63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100c66:	c9                   	leave  
c0100c67:	c3                   	ret    

c0100c68 <_ZN7Console8setColorE6String>:
void Console::init() {
    VideoMemory::initVmBuff();
    setCursorPos(0, 0);
}

void Console::setColor(String str) {
c0100c68:	55                   	push   %ebp
c0100c69:	89 e5                	mov    %esp,%ebp
c0100c6b:	57                   	push   %edi
c0100c6c:	56                   	push   %esi
    uint32_t index;
    for (index = 0; index < COLOR_NUM; index++) {
c0100c6d:	31 f6                	xor    %esi,%esi
void Console::setColor(String str) {
c0100c6f:	53                   	push   %ebx
c0100c70:	83 ec 1c             	sub    $0x1c,%esp
c0100c73:	e8 15 ff ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c0100c78:	81 c3 90 e7 00 00    	add    $0xe790,%ebx
c0100c7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c81:	8d 78 08             	lea    0x8(%eax),%edi
c0100c84:	8d 46 01             	lea    0x1(%esi),%eax
c0100c87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (str == color[index]) {
c0100c8a:	50                   	push   %eax
c0100c8b:	50                   	push   %eax
c0100c8c:	57                   	push   %edi
c0100c8d:	ff 75 0c             	pushl  0xc(%ebp)
c0100c90:	e8 71 0d 00 00       	call   c0101a06 <_ZN6StringeqERKS_>
c0100c95:	83 c4 10             	add    $0x10,%esp
c0100c98:	84 c0                	test   %al,%al
c0100c9a:	75 0d                	jne    c0100ca9 <_ZN7Console8setColorE6String+0x41>
c0100c9c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c0100c9f:	83 c7 08             	add    $0x8,%edi
    for (index = 0; index < COLOR_NUM; index++) {
c0100ca2:	83 fe 04             	cmp    $0x4,%esi
c0100ca5:	75 dd                	jne    c0100c84 <_ZN7Console8setColorE6String+0x1c>
c0100ca7:	eb 15                	jmp    c0100cbe <_ZN7Console8setColorE6String+0x56>
            break;
        }
    }
    if (index < COLOR_NUM) {
        charEctype.attri = (charEctype.attri & 0xF0) | colorTable[index];
c0100ca9:	c7 c2 21 28 11 c0    	mov    $0xc0112821,%edx
c0100caf:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0100cb2:	8a 42 01             	mov    0x1(%edx),%al
c0100cb5:	24 f0                	and    $0xf0,%al
c0100cb7:	0a 44 31 28          	or     0x28(%ecx,%esi,1),%al
c0100cbb:	88 42 01             	mov    %al,0x1(%edx)
    }
}
c0100cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100cc1:	5b                   	pop    %ebx
c0100cc2:	5e                   	pop    %esi
c0100cc3:	5f                   	pop    %edi
c0100cc4:	5d                   	pop    %ebp
c0100cc5:	c3                   	ret    

c0100cc6 <_ZN7Console13setBackgroundE6String>:

void Console::setBackground(String str) {
c0100cc6:	55                   	push   %ebp
c0100cc7:	89 e5                	mov    %esp,%ebp
c0100cc9:	57                   	push   %edi
    uint32_t index = 1;                             // default black
    for (uint32_t i = 0; i < COLOR_NUM; i++) {
c0100cca:	31 ff                	xor    %edi,%edi
void Console::setBackground(String str) {
c0100ccc:	56                   	push   %esi
c0100ccd:	53                   	push   %ebx
c0100cce:	83 ec 1c             	sub    $0x1c,%esp
c0100cd1:	e8 b7 fe ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c0100cd6:	81 c3 32 e7 00 00    	add    $0xe732,%ebx
c0100cdc:	8b 75 08             	mov    0x8(%ebp),%esi
c0100cdf:	8d 56 08             	lea    0x8(%esi),%edx
c0100ce2:	8d 47 01             	lea    0x1(%edi),%eax
c0100ce5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (str == color[i]) {
c0100ce8:	50                   	push   %eax
c0100ce9:	50                   	push   %eax
c0100cea:	52                   	push   %edx
c0100ceb:	ff 75 0c             	pushl  0xc(%ebp)
c0100cee:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0100cf1:	e8 10 0d 00 00       	call   c0101a06 <_ZN6StringeqERKS_>
c0100cf6:	83 c4 10             	add    $0x10,%esp
c0100cf9:	84 c0                	test   %al,%al
c0100cfb:	75 13                	jne    c0100d10 <_ZN7Console13setBackgroundE6String+0x4a>
c0100cfd:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100d00:	8b 7d e4             	mov    -0x1c(%ebp),%edi
c0100d03:	83 c2 08             	add    $0x8,%edx
    for (uint32_t i = 0; i < COLOR_NUM; i++) {
c0100d06:	83 ff 04             	cmp    $0x4,%edi
c0100d09:	75 d7                	jne    c0100ce2 <_ZN7Console13setBackgroundE6String+0x1c>
    uint32_t index = 1;                             // default black
c0100d0b:	bf 01 00 00 00       	mov    $0x1,%edi
            index = i;
            break;
        }
    }
    charEctype.attri = (charEctype.attri & 0x0F) | ((colorTable[index]) << 4);
c0100d10:	c7 c3 21 28 11 c0    	mov    $0xc0112821,%ebx
c0100d16:	0f b6 54 3e 28       	movzbl 0x28(%esi,%edi,1),%edx
    for (uint32_t row = 0; row < wide; row++) {
c0100d1b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    charEctype.attri = (charEctype.attri & 0x0F) | ((colorTable[index]) << 4);
c0100d22:	8a 43 01             	mov    0x1(%ebx),%al
c0100d25:	c1 e2 04             	shl    $0x4,%edx
c0100d28:	24 0f                	and    $0xf,%al
c0100d2a:	08 d0                	or     %dl,%al
c0100d2c:	88 43 01             	mov    %al,0x1(%ebx)
    for (uint32_t row = 0; row < wide; row++) {
c0100d2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100d32:	39 46 34             	cmp    %eax,0x34(%esi)
c0100d35:	76 32                	jbe    c0100d69 <_ZN7Console13setBackgroundE6String+0xa3>
        for (uint32_t col = 0; col < length; col++) {
c0100d37:	31 c9                	xor    %ecx,%ecx
c0100d39:	8b 46 30             	mov    0x30(%esi),%eax
c0100d3c:	39 c8                	cmp    %ecx,%eax
c0100d3e:	76 24                	jbe    c0100d64 <_ZN7Console13setBackgroundE6String+0x9e>
            if (cPos.x != row || cPos.y != col) {
c0100d40:	0f b6 7e 38          	movzbl 0x38(%esi),%edi
c0100d44:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
c0100d47:	75 08                	jne    c0100d51 <_ZN7Console13setBackgroundE6String+0x8b>
c0100d49:	0f b6 7e 39          	movzbl 0x39(%esi),%edi
c0100d4d:	39 cf                	cmp    %ecx,%edi
c0100d4f:	74 10                	je     c0100d61 <_ZN7Console13setBackgroundE6String+0x9b>
                screen[row * length + col].attri = charEctype.attri;
c0100d51:	0f af 45 e4          	imul   -0x1c(%ebp),%eax
c0100d55:	8b 7e 2c             	mov    0x2c(%esi),%edi
c0100d58:	8a 53 01             	mov    0x1(%ebx),%dl
c0100d5b:	01 c8                	add    %ecx,%eax
c0100d5d:	88 54 47 01          	mov    %dl,0x1(%edi,%eax,2)
        for (uint32_t col = 0; col < length; col++) {
c0100d61:	41                   	inc    %ecx
c0100d62:	eb d5                	jmp    c0100d39 <_ZN7Console13setBackgroundE6String+0x73>
    for (uint32_t row = 0; row < wide; row++) {
c0100d64:	ff 45 e4             	incl   -0x1c(%ebp)
c0100d67:	eb c6                	jmp    c0100d2f <_ZN7Console13setBackgroundE6String+0x69>
            }
        }
    }
}
c0100d69:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100d6c:	5b                   	pop    %ebx
c0100d6d:	5e                   	pop    %esi
c0100d6e:	5f                   	pop    %edi
c0100d6f:	5d                   	pop    %ebp
c0100d70:	c3                   	ret    
c0100d71:	90                   	nop

c0100d72 <_ZN7Console12setCursorPosEhh>:

void Console::setCursorPos(uint8_t x = 0, uint8_t y = 0) {
c0100d72:	55                   	push   %ebp
c0100d73:	89 e5                	mov    %esp,%ebp
c0100d75:	56                   	push   %esi
c0100d76:	53                   	push   %ebx
c0100d77:	83 ec 18             	sub    $0x18,%esp
c0100d7a:	8b 75 08             	mov    0x8(%ebp),%esi
c0100d7d:	0f b6 45 0c          	movzbl 0xc(%ebp),%eax
c0100d81:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0100d84:	e8 04 fe ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c0100d89:	81 c3 7f e6 00 00    	add    $0xe67f,%ebx
    cPos.x = x;
c0100d8f:	88 46 38             	mov    %al,0x38(%esi)
void Console::setCursorPos(uint8_t x = 0, uint8_t y = 0) {
c0100d92:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100d95:	0f b6 d1             	movzbl %cl,%edx
    cPos.y = y;
    // set cursor status
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100d98:	0f af 46 30          	imul   0x30(%esi),%eax
    cPos.y = y;
c0100d9c:	88 4e 39             	mov    %cl,0x39(%esi)
    screen[cPos.x * length + cPos.y] = cursorStatus;
c0100d9f:	66 8b 4e 3a          	mov    0x3a(%esi),%cx
c0100da3:	01 c2                	add    %eax,%edx
c0100da5:	8b 46 2c             	mov    0x2c(%esi),%eax
c0100da8:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
    VideoMemory::setCursorPos(cPos.x * length + cPos.y);
c0100dac:	0f b6 46 38          	movzbl 0x38(%esi),%eax
c0100db0:	0f b6 56 39          	movzbl 0x39(%esi),%edx
c0100db4:	0f af 46 30          	imul   0x30(%esi),%eax
c0100db8:	01 d0                	add    %edx,%eax
c0100dba:	0f b7 c0             	movzwl %ax,%eax
c0100dbd:	50                   	push   %eax
c0100dbe:	56                   	push   %esi
c0100dbf:	e8 3a 04 00 00       	call   c01011fe <_ZN11VideoMemory12setCursorPosEt>
}
c0100dc4:	83 c4 10             	add    $0x10,%esp
c0100dc7:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0100dca:	5b                   	pop    %ebx
c0100dcb:	5e                   	pop    %esi
c0100dcc:	5d                   	pop    %ebp
c0100dcd:	c3                   	ret    

c0100dce <_ZN7Console4initEv>:
void Console::init() {
c0100dce:	55                   	push   %ebp
c0100dcf:	89 e5                	mov    %esp,%ebp
c0100dd1:	56                   	push   %esi
c0100dd2:	8b 75 08             	mov    0x8(%ebp),%esi
c0100dd5:	53                   	push   %ebx
c0100dd6:	e8 b2 fd ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c0100ddb:	81 c3 2d e6 00 00    	add    $0xe62d,%ebx
    VideoMemory::initVmBuff();
c0100de1:	83 ec 0c             	sub    $0xc,%esp
c0100de4:	56                   	push   %esi
c0100de5:	e8 ce 03 00 00       	call   c01011b8 <_ZN11VideoMemory10initVmBuffEv>
    setCursorPos(0, 0);
c0100dea:	83 c4 0c             	add    $0xc,%esp
c0100ded:	6a 00                	push   $0x0
c0100def:	6a 00                	push   $0x0
c0100df1:	56                   	push   %esi
c0100df2:	e8 7b ff ff ff       	call   c0100d72 <_ZN7Console12setCursorPosEhh>
}
c0100df7:	83 c4 10             	add    $0x10,%esp
c0100dfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0100dfd:	5b                   	pop    %ebx
c0100dfe:	5e                   	pop    %esi
c0100dff:	5d                   	pop    %ebp
c0100e00:	c3                   	ret    
c0100e01:	90                   	nop

c0100e02 <_ZN7Console12getCursorPosEv>:

const Console::CursorPos & Console::getCursorPos() {
c0100e02:	55                   	push   %ebp
c0100e03:	89 e5                	mov    %esp,%ebp
c0100e05:	56                   	push   %esi
c0100e06:	8b 75 08             	mov    0x8(%ebp),%esi
c0100e09:	53                   	push   %ebx
c0100e0a:	e8 7e fd ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c0100e0f:	81 c3 f9 e5 00 00    	add    $0xe5f9,%ebx
    cPos.x = VideoMemory::getCursorPos() / length;
c0100e15:	83 ec 0c             	sub    $0xc,%esp
c0100e18:	56                   	push   %esi
c0100e19:	e8 b2 03 00 00       	call   c01011d0 <_ZN11VideoMemory12getCursorPosEv>
c0100e1e:	31 d2                	xor    %edx,%edx
c0100e20:	0f b7 c0             	movzwl %ax,%eax
c0100e23:	f7 76 30             	divl   0x30(%esi)
c0100e26:	88 46 38             	mov    %al,0x38(%esi)
    cPos.y = VideoMemory::getCursorPos() % length;
c0100e29:	89 34 24             	mov    %esi,(%esp)
c0100e2c:	e8 9f 03 00 00       	call   c01011d0 <_ZN11VideoMemory12getCursorPosEv>
c0100e31:	31 d2                	xor    %edx,%edx
c0100e33:	0f b7 c0             	movzwl %ax,%eax
c0100e36:	f7 76 30             	divl   0x30(%esi)
    return cPos;
c0100e39:	8d 46 38             	lea    0x38(%esi),%eax
    cPos.y = VideoMemory::getCursorPos() % length;
c0100e3c:	88 56 39             	mov    %dl,0x39(%esi)
}
c0100e3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0100e42:	5b                   	pop    %ebx
c0100e43:	5e                   	pop    %esi
c0100e44:	5d                   	pop    %ebp
c0100e45:	c3                   	ret    

c0100e46 <_ZN7Console4readEv>:
    for (uint32_t i = 0; i < len; i++) {
        wirte(cArry[i]);
    }
}

char Console::read() {
c0100e46:	55                   	push   %ebp
c0100e47:	89 e5                	mov    %esp,%ebp
    return screen[0].c;
c0100e49:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0100e4c:	5d                   	pop    %ebp
    return screen[0].c;
c0100e4d:	8b 40 2c             	mov    0x2c(%eax),%eax
c0100e50:	8a 00                	mov    (%eax),%al
}
c0100e52:	c3                   	ret    
c0100e53:	90                   	nop

c0100e54 <_ZN7Console4readEPcRKt>:

void Console::read(char *cArry, const uint16_t &len) {
c0100e54:	55                   	push   %ebp
c0100e55:	89 e5                	mov    %esp,%ebp
   
}
c0100e57:	5d                   	pop    %ebp
c0100e58:	c3                   	ret    
c0100e59:	90                   	nop

c0100e5a <_ZN7Console12scrollScreenEv>:
    } else {
        setCursorPos(cPos.x + 1, 0);
    }
}

void Console::scrollScreen() {
c0100e5a:	e8 6b 01 00 00       	call   c0100fca <__x86.get_pc_thunk.ax>
c0100e5f:	05 a9 e5 00 00       	add    $0xe5a9,%eax
c0100e64:	55                   	push   %ebp
c0100e65:	89 e5                	mov    %esp,%ebp
c0100e67:	57                   	push   %edi
c0100e68:	56                   	push   %esi
c0100e69:	53                   	push   %ebx
c0100e6a:	83 ec 1c             	sub    $0x1c,%esp
    charEctype.c = ' ';
c0100e6d:	c7 c3 21 28 11 c0    	mov    $0xc0112821,%ebx
    for (uint32_t i = 0; i < length * wide; i++) {
c0100e73:	31 c0                	xor    %eax,%eax
void Console::scrollScreen() {
c0100e75:	8b 4d 08             	mov    0x8(%ebp),%ecx
    charEctype.c = ' ';
c0100e78:	c6 03 20             	movb   $0x20,(%ebx)
    for (uint32_t i = 0; i < length * wide; i++) {
c0100e7b:	8b 79 30             	mov    0x30(%ecx),%edi
c0100e7e:	8b 51 34             	mov    0x34(%ecx),%edx
c0100e81:	89 fe                	mov    %edi,%esi
c0100e83:	0f af f2             	imul   %edx,%esi
c0100e86:	89 7d e4             	mov    %edi,-0x1c(%ebp)
c0100e89:	39 c6                	cmp    %eax,%esi
c0100e8b:	76 23                	jbe    c0100eb0 <_ZN7Console12scrollScreenEv+0x56>
c0100e8d:	8b 79 2c             	mov    0x2c(%ecx),%edi
c0100e90:	8d 14 00             	lea    (%eax,%eax,1),%edx
        if (i < length * (wide - 1)) {
c0100e93:	2b 75 e4             	sub    -0x1c(%ebp),%esi
c0100e96:	01 fa                	add    %edi,%edx
c0100e98:	39 c6                	cmp    %eax,%esi
c0100e9a:	76 0b                	jbe    c0100ea7 <_ZN7Console12scrollScreenEv+0x4d>
            screen[i] = screen[length + i];
c0100e9c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
c0100e9f:	01 c6                	add    %eax,%esi
c0100ea1:	66 8b 34 77          	mov    (%edi,%esi,2),%si
c0100ea5:	eb 03                	jmp    c0100eaa <_ZN7Console12scrollScreenEv+0x50>
        } else {
            screen[i] = charEctype;
c0100ea7:	66 8b 33             	mov    (%ebx),%si
c0100eaa:	66 89 32             	mov    %si,(%edx)
    for (uint32_t i = 0; i < length * wide; i++) {
c0100ead:	40                   	inc    %eax
c0100eae:	eb cb                	jmp    c0100e7b <_ZN7Console12scrollScreenEv+0x21>
        }
    }
    setCursorPos(wide - 1, 0);
c0100eb0:	fe ca                	dec    %dl
c0100eb2:	50                   	push   %eax
c0100eb3:	0f b6 d2             	movzbl %dl,%edx
c0100eb6:	6a 00                	push   $0x0
c0100eb8:	52                   	push   %edx
c0100eb9:	51                   	push   %ecx
c0100eba:	e8 b3 fe ff ff       	call   c0100d72 <_ZN7Console12setCursorPosEhh>
}
c0100ebf:	83 c4 10             	add    $0x10,%esp
c0100ec2:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0100ec5:	5b                   	pop    %ebx
c0100ec6:	5e                   	pop    %esi
c0100ec7:	5f                   	pop    %edi
c0100ec8:	5d                   	pop    %ebp
c0100ec9:	c3                   	ret    

c0100eca <_ZN7Console4nextEv>:
void Console::next() {
c0100eca:	55                   	push   %ebp
c0100ecb:	89 e5                	mov    %esp,%ebp
c0100ecd:	53                   	push   %ebx
c0100ece:	52                   	push   %edx
    cPos.y = (cPos.y + 1) % length;
c0100ecf:	31 d2                	xor    %edx,%edx
void Console::next() {
c0100ed1:	8b 5d 08             	mov    0x8(%ebp),%ebx
    cPos.y = (cPos.y + 1) % length;
c0100ed4:	0f b6 43 39          	movzbl 0x39(%ebx),%eax
c0100ed8:	40                   	inc    %eax
c0100ed9:	f7 73 30             	divl   0x30(%ebx)
    if (cPos.y == 0) {
c0100edc:	84 d2                	test   %dl,%dl
    cPos.y = (cPos.y + 1) % length;
c0100ede:	89 d1                	mov    %edx,%ecx
c0100ee0:	88 53 39             	mov    %dl,0x39(%ebx)
    if (cPos.y == 0) {
c0100ee3:	75 0d                	jne    c0100ef2 <_ZN7Console4nextEv+0x28>
        cPos.x = (cPos.x + 1) % wide;
c0100ee5:	0f b6 43 38          	movzbl 0x38(%ebx),%eax
c0100ee9:	31 d2                	xor    %edx,%edx
c0100eeb:	40                   	inc    %eax
c0100eec:	f7 73 34             	divl   0x34(%ebx)
c0100eef:	88 53 38             	mov    %dl,0x38(%ebx)
    if (cPos.y == 0 && cPos.x == 0) {   // jugde scroll screen
c0100ef2:	66 83 7b 38 00       	cmpw   $0x0,0x38(%ebx)
c0100ef7:	75 0c                	jne    c0100f05 <_ZN7Console4nextEv+0x3b>
        scrollScreen();
c0100ef9:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
c0100efc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100eff:	c9                   	leave  
        scrollScreen();
c0100f00:	e9 55 ff ff ff       	jmp    c0100e5a <_ZN7Console12scrollScreenEv>
        setCursorPos(cPos.x, cPos.y);
c0100f05:	0f b6 c9             	movzbl %cl,%ecx
c0100f08:	50                   	push   %eax
c0100f09:	51                   	push   %ecx
c0100f0a:	0f b6 43 38          	movzbl 0x38(%ebx),%eax
c0100f0e:	50                   	push   %eax
c0100f0f:	53                   	push   %ebx
c0100f10:	e8 5d fe ff ff       	call   c0100d72 <_ZN7Console12setCursorPosEhh>
c0100f15:	83 c4 10             	add    $0x10,%esp
}
c0100f18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100f1b:	c9                   	leave  
c0100f1c:	c3                   	ret    
c0100f1d:	90                   	nop

c0100f1e <_ZN7Console8lineFeedEv>:
void Console::lineFeed() {
c0100f1e:	55                   	push   %ebp
c0100f1f:	89 e5                	mov    %esp,%ebp
c0100f21:	83 ec 08             	sub    $0x8,%esp
c0100f24:	8b 55 08             	mov    0x8(%ebp),%edx
    if ((uint32_t)(cPos.x + 1) >= wide) {
c0100f27:	0f b6 42 38          	movzbl 0x38(%edx),%eax
c0100f2b:	40                   	inc    %eax
c0100f2c:	3b 42 34             	cmp    0x34(%edx),%eax
c0100f2f:	72 06                	jb     c0100f37 <_ZN7Console8lineFeedEv+0x19>
}
c0100f31:	c9                   	leave  
        scrollScreen();
c0100f32:	e9 23 ff ff ff       	jmp    c0100e5a <_ZN7Console12scrollScreenEv>
        setCursorPos(cPos.x + 1, 0);
c0100f37:	51                   	push   %ecx
c0100f38:	0f b6 c0             	movzbl %al,%eax
c0100f3b:	6a 00                	push   $0x0
c0100f3d:	50                   	push   %eax
c0100f3e:	52                   	push   %edx
c0100f3f:	e8 2e fe ff ff       	call   c0100d72 <_ZN7Console12setCursorPosEhh>
c0100f44:	83 c4 10             	add    $0x10,%esp
}
c0100f47:	c9                   	leave  
c0100f48:	c3                   	ret    
c0100f49:	90                   	nop

c0100f4a <_ZN7Console5wirteERKc>:
void Console::wirte(const char &c) {
c0100f4a:	55                   	push   %ebp
c0100f4b:	89 e5                	mov    %esp,%ebp
c0100f4d:	56                   	push   %esi
    if (c == '\n') {
c0100f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
void Console::wirte(const char &c) {
c0100f51:	53                   	push   %ebx
c0100f52:	8b 5d 08             	mov    0x8(%ebp),%ebx
c0100f55:	e8 74 00 00 00       	call   c0100fce <__x86.get_pc_thunk.cx>
c0100f5a:	81 c1 ae e4 00 00    	add    $0xe4ae,%ecx
    if (c == '\n') {
c0100f60:	8a 10                	mov    (%eax),%dl
c0100f62:	0f b6 43 38          	movzbl 0x38(%ebx),%eax
c0100f66:	0f b6 73 39          	movzbl 0x39(%ebx),%esi
c0100f6a:	0f af 43 30          	imul   0x30(%ebx),%eax
c0100f6e:	c7 c1 21 28 11 c0    	mov    $0xc0112821,%ecx
c0100f74:	01 f0                	add    %esi,%eax
c0100f76:	01 c0                	add    %eax,%eax
c0100f78:	03 43 2c             	add    0x2c(%ebx),%eax
c0100f7b:	80 fa 0a             	cmp    $0xa,%dl
c0100f7e:	75 0e                	jne    c0100f8e <_ZN7Console5wirteERKc+0x44>
        charEctype.c = ' ';
c0100f80:	c6 01 20             	movb   $0x20,(%ecx)
        screen[cPos.x * length + cPos.y] = charEctype;
c0100f83:	66 8b 11             	mov    (%ecx),%dx
c0100f86:	66 89 10             	mov    %dx,(%eax)
}
c0100f89:	5b                   	pop    %ebx
c0100f8a:	5e                   	pop    %esi
c0100f8b:	5d                   	pop    %ebp
        lineFeed();
c0100f8c:	eb 90                	jmp    c0100f1e <_ZN7Console8lineFeedEv>
        charEctype.c = c;
c0100f8e:	88 11                	mov    %dl,(%ecx)
        screen[cPos.x * length + cPos.y] = charEctype;
c0100f90:	66 8b 11             	mov    (%ecx),%dx
c0100f93:	66 89 10             	mov    %dx,(%eax)
}
c0100f96:	5b                   	pop    %ebx
c0100f97:	5e                   	pop    %esi
c0100f98:	5d                   	pop    %ebp
        next();
c0100f99:	e9 2c ff ff ff       	jmp    c0100eca <_ZN7Console4nextEv>

c0100f9e <_ZN7Console5wirteEPcRKt>:
void Console::wirte(char *cArry, const uint16_t &len) {
c0100f9e:	55                   	push   %ebp
c0100f9f:	89 e5                	mov    %esp,%ebp
c0100fa1:	53                   	push   %ebx
    for (uint32_t i = 0; i < len; i++) {
c0100fa2:	31 db                	xor    %ebx,%ebx
void Console::wirte(char *cArry, const uint16_t &len) {
c0100fa4:	52                   	push   %edx
    for (uint32_t i = 0; i < len; i++) {
c0100fa5:	8b 45 10             	mov    0x10(%ebp),%eax
c0100fa8:	0f b7 00             	movzwl (%eax),%eax
c0100fab:	39 d8                	cmp    %ebx,%eax
c0100fad:	76 16                	jbe    c0100fc5 <_ZN7Console5wirteEPcRKt+0x27>
        wirte(cArry[i]);
c0100faf:	50                   	push   %eax
c0100fb0:	50                   	push   %eax
c0100fb1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100fb4:	01 d8                	add    %ebx,%eax
    for (uint32_t i = 0; i < len; i++) {
c0100fb6:	43                   	inc    %ebx
        wirte(cArry[i]);
c0100fb7:	50                   	push   %eax
c0100fb8:	ff 75 08             	pushl  0x8(%ebp)
c0100fbb:	e8 8a ff ff ff       	call   c0100f4a <_ZN7Console5wirteERKc>
    for (uint32_t i = 0; i < len; i++) {
c0100fc0:	83 c4 10             	add    $0x10,%esp
c0100fc3:	eb e0                	jmp    c0100fa5 <_ZN7Console5wirteEPcRKt+0x7>
}
c0100fc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100fc8:	c9                   	leave  
c0100fc9:	c3                   	ret    

c0100fca <__x86.get_pc_thunk.ax>:
c0100fca:	8b 04 24             	mov    (%esp),%eax
c0100fcd:	c3                   	ret    

c0100fce <__x86.get_pc_thunk.cx>:
c0100fce:	8b 0c 24             	mov    (%esp),%ecx
c0100fd1:	c3                   	ret    

c0100fd2 <_ZN9InterruptC1Ev>:
#include <interrupt.h>

Interrupt::Interrupt() {
c0100fd2:	55                   	push   %ebp
c0100fd3:	89 e5                	mov    %esp,%ebp
    
}
c0100fd5:	5d                   	pop    %ebp
c0100fd6:	c3                   	ret    
c0100fd7:	90                   	nop

c0100fd8 <_ZN9Interrupt7initIDTEv>:
    enableIRQ(2);                                   // set master IR2, because of slave connection to IR2
    
    enableIRQ(8);                                   // set slave IR1, clock interrupt of RTC
}

void Interrupt::initIDT() {
c0100fd8:	55                   	push   %ebp
c0100fd9:	89 e5                	mov    %esp,%ebp
c0100fdb:	57                   	push   %edi
c0100fdc:	56                   	push   %esi
    extern uptr32_t __vectors[];
    for (uint32_t i = 0; i < sizeof(idt) / sizeof(MMU::GateDesc); i++) {
c0100fdd:	31 f6                	xor    %esi,%esi
void Interrupt::initIDT() {
c0100fdf:	53                   	push   %ebx
c0100fe0:	e8 a8 fb ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c0100fe5:	81 c3 23 e4 00 00    	add    $0xe423,%ebx
c0100feb:	83 ec 1c             	sub    $0x1c,%esp
        MMU::setGateDesc(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0100fee:	c7 c0 00 f0 10 c0    	mov    $0xc010f000,%eax
c0100ff4:	c7 c7 20 20 11 c0    	mov    $0xc0112020,%edi
c0100ffa:	83 ec 0c             	sub    $0xc,%esp
c0100ffd:	6a 00                	push   $0x0
c0100fff:	ff 34 b0             	pushl  (%eax,%esi,4)
c0101002:	8d 14 f7             	lea    (%edi,%esi,8),%edx
    for (uint32_t i = 0; i < sizeof(idt) / sizeof(MMU::GateDesc); i++) {
c0101005:	46                   	inc    %esi
        MMU::setGateDesc(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0101006:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0101009:	6a 08                	push   $0x8
c010100b:	6a 00                	push   $0x0
c010100d:	52                   	push   %edx
c010100e:	e8 d7 08 00 00       	call   c01018ea <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>
    for (uint32_t i = 0; i < sizeof(idt) / sizeof(MMU::GateDesc); i++) {
c0101013:	83 c4 20             	add    $0x20,%esp
c0101016:	81 fe 00 01 00 00    	cmp    $0x100,%esi
c010101c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010101f:	75 d9                	jne    c0100ffa <_ZN9Interrupt7initIDTEv+0x22>
    }
	// set for switch from user to kernel
    MMU::setGateDesc(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c0101021:	83 ec 0c             	sub    $0xc,%esp
c0101024:	6a 03                	push   $0x3
c0101026:	ff b0 e4 01 00 00    	pushl  0x1e4(%eax)
c010102c:	8d 87 c8 03 00 00    	lea    0x3c8(%edi),%eax
c0101032:	6a 08                	push   $0x8
c0101034:	6a 00                	push   $0x0
c0101036:	50                   	push   %eax
c0101037:	e8 ae 08 00 00       	call   c01018ea <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>
    uint32_t pd_base;       // Base address
}__attribute__ ((packed));  // rule size

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
c010103c:	c7 c0 14 f4 10 c0    	mov    $0xc010f414,%eax
c0101042:	0f 01 18             	lidtl  (%eax)
	// load the IDT
    lidt(&pdIdt);
}
c0101045:	83 c4 20             	add    $0x20,%esp
c0101048:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010104b:	5b                   	pop    %ebx
c010104c:	5e                   	pop    %esi
c010104d:	5f                   	pop    %edi
c010104e:	5d                   	pop    %ebp
c010104f:	c3                   	ret    

c0101050 <_ZN9Interrupt4initEv>:
void Interrupt::init() {
c0101050:	55                   	push   %ebp
c0101051:	89 e5                	mov    %esp,%ebp
c0101053:	56                   	push   %esi
c0101054:	8b 75 08             	mov    0x8(%ebp),%esi
c0101057:	53                   	push   %ebx
c0101058:	e8 30 fb ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c010105d:	81 c3 ab e3 00 00    	add    $0xe3ab,%ebx
    initIDT();
c0101063:	83 ec 0c             	sub    $0xc,%esp
c0101066:	56                   	push   %esi
c0101067:	e8 6c ff ff ff       	call   c0100fd8 <_ZN9Interrupt7initIDTEv>
    initPIC();
c010106c:	89 34 24             	mov    %esi,(%esp)
c010106f:	e8 32 00 00 00       	call   c01010a6 <_ZN3PIC7initPICEv>
    initClock();
c0101074:	89 34 24             	mov    %esi,(%esp)
c0101077:	e8 fe 00 00 00       	call   c010117a <_ZN3RTC9initClockEv>
    enableIRQ(2);                                   // set master IR2, because of slave connection to IR2
c010107c:	58                   	pop    %eax
c010107d:	5a                   	pop    %edx
c010107e:	6a 02                	push   $0x2
c0101080:	56                   	push   %esi
c0101081:	e8 7a 00 00 00       	call   c0101100 <_ZN3PIC9enableIRQEj>
    enableIRQ(8);                                   // set slave IR1, clock interrupt of RTC
c0101086:	59                   	pop    %ecx
c0101087:	58                   	pop    %eax
c0101088:	6a 08                	push   $0x8
c010108a:	56                   	push   %esi
c010108b:	e8 70 00 00 00       	call   c0101100 <_ZN3PIC9enableIRQEj>
}
c0101090:	83 c4 10             	add    $0x10,%esp
c0101093:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101096:	5b                   	pop    %ebx
c0101097:	5e                   	pop    %esi
c0101098:	5d                   	pop    %ebp
c0101099:	c3                   	ret    

c010109a <_ZN9Interrupt6enableEv>:

void Interrupt::enable() {
c010109a:	55                   	push   %ebp
c010109b:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c010109d:	fb                   	sti    
    sti();
}
c010109e:	5d                   	pop    %ebp
c010109f:	c3                   	ret    

c01010a0 <_ZN9Interrupt7disableEv>:

void Interrupt::disable() {
c01010a0:	55                   	push   %ebp
c01010a1:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli");
c01010a3:	fa                   	cli    
    cli();
}
c01010a4:	5d                   	pop    %ebp
c01010a5:	c3                   	ret    

c01010a6 <_ZN3PIC7initPICEv>:
#include <pic.h>

void PIC::initPIC() {
c01010a6:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c01010a7:	b0 ff                	mov    $0xff,%al
c01010a9:	89 e5                	mov    %esp,%ebp
c01010ab:	57                   	push   %edi
c01010ac:	56                   	push   %esi
c01010ad:	be 21 00 00 00       	mov    $0x21,%esi
c01010b2:	53                   	push   %ebx
c01010b3:	89 f2                	mov    %esi,%edx
c01010b5:	e8 a7 00 00 00       	call   c0101161 <__x86.get_pc_thunk.di>
c01010ba:	81 c7 4e e3 00 00    	add    $0xe34e,%edi
c01010c0:	ee                   	out    %al,(%dx)
c01010c1:	bb a1 00 00 00       	mov    $0xa1,%ebx
c01010c6:	89 da                	mov    %ebx,%edx
c01010c8:	ee                   	out    %al,(%dx)
c01010c9:	b1 11                	mov    $0x11,%cl
c01010cb:	ba 20 00 00 00       	mov    $0x20,%edx
c01010d0:	88 c8                	mov    %cl,%al
c01010d2:	ee                   	out    %al,(%dx)
c01010d3:	b0 20                	mov    $0x20,%al
c01010d5:	89 f2                	mov    %esi,%edx
c01010d7:	ee                   	out    %al,(%dx)
c01010d8:	b0 04                	mov    $0x4,%al
c01010da:	ee                   	out    %al,(%dx)
c01010db:	b0 01                	mov    $0x1,%al
c01010dd:	ee                   	out    %al,(%dx)
c01010de:	ba a0 00 00 00       	mov    $0xa0,%edx
c01010e3:	88 c8                	mov    %cl,%al
c01010e5:	ee                   	out    %al,(%dx)
c01010e6:	b0 70                	mov    $0x70,%al
c01010e8:	89 da                	mov    %ebx,%edx
c01010ea:	ee                   	out    %al,(%dx)
c01010eb:	b0 04                	mov    $0x4,%al
c01010ed:	ee                   	out    %al,(%dx)
c01010ee:	b0 01                	mov    $0x1,%al
c01010f0:	ee                   	out    %al,(%dx)
    outb(ICW1_ICW4, IO1_8259PIC2);                  // ICW1: edge-tri / cascade
    outb(0x70, IO2_8259PIC2);                       // ICW2: set first vectors of interrupt
    outb(0x04, IO2_8259PIC2);                       // ICW3: second chip is link to IR2 of first chip
    outb(0x01, IO2_8259PIC2);                       // ICW4; normal EOI

    didInit = true;                                 // 
c01010f1:	c7 c0 20 28 11 c0    	mov    $0xc0112820,%eax
c01010f7:	c6 00 01             	movb   $0x1,(%eax)
}
c01010fa:	5b                   	pop    %ebx
c01010fb:	5e                   	pop    %esi
c01010fc:	5f                   	pop    %edi
c01010fd:	5d                   	pop    %ebp
c01010fe:	c3                   	ret    
c01010ff:	90                   	nop

c0101100 <_ZN3PIC9enableIRQEj>:

void PIC::enableIRQ(uint32_t irq) {                 // enable irq
c0101100:	e8 58 00 00 00       	call   c010115d <__x86.get_pc_thunk.dx>
c0101105:	81 c2 03 e3 00 00    	add    $0xe303,%edx
    irqMask &= ~(1 << irq);
c010110b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
void PIC::enableIRQ(uint32_t irq) {                 // enable irq
c0101110:	55                   	push   %ebp
c0101111:	89 e5                	mov    %esp,%ebp
    irqMask &= ~(1 << irq);
c0101113:	8b 4d 0c             	mov    0xc(%ebp),%ecx
void PIC::enableIRQ(uint32_t irq) {                 // enable irq
c0101116:	53                   	push   %ebx
    irqMask &= ~(1 << irq);
c0101117:	c7 c3 00 f4 10 c0    	mov    $0xc010f400,%ebx
c010111d:	d3 c0                	rol    %cl,%eax
    if (didInit) {
c010111f:	c7 c2 20 28 11 c0    	mov    $0xc0112820,%edx
    irqMask &= ~(1 << irq);
c0101125:	66 8b 0b             	mov    (%ebx),%cx
c0101128:	21 c8                	and    %ecx,%eax
    if (didInit) {
c010112a:	80 3a 00             	cmpb   $0x0,(%edx)
    irqMask &= ~(1 << irq);
c010112d:	98                   	cwtl   
c010112e:	0f b7 c8             	movzwl %ax,%ecx
c0101131:	66 89 0b             	mov    %cx,(%ebx)
    if (didInit) {
c0101134:	74 11                	je     c0101147 <_ZN3PIC9enableIRQEj+0x47>
c0101136:	ba 21 00 00 00       	mov    $0x21,%edx
c010113b:	ee                   	out    %al,(%dx)
        outb(irqMask & 0xFF, IO2_8259PIC1);         // master chip
        outb((irqMask >> 8) & 0xFF, IO2_8259PIC2);  // slave chip
c010113c:	89 c8                	mov    %ecx,%eax
c010113e:	ba a1 00 00 00       	mov    $0xa1,%edx
c0101143:	c1 e8 08             	shr    $0x8,%eax
c0101146:	ee                   	out    %al,(%dx)
    }
}
c0101147:	5b                   	pop    %ebx
c0101148:	5d                   	pop    %ebp
c0101149:	c3                   	ret    

c010114a <_ZN3PIC7sendEOIEv>:

void PIC::sendEOI() {
c010114a:	55                   	push   %ebp
c010114b:	b0 20                	mov    $0x20,%al
c010114d:	89 e5                	mov    %esp,%ebp
c010114f:	ba a0 00 00 00       	mov    $0xa0,%edx
c0101154:	ee                   	out    %al,(%dx)
c0101155:	ba 20 00 00 00       	mov    $0x20,%edx
c010115a:	ee                   	out    %al,(%dx)
    outb(EOI_CMD, IO1_8259PIC2);                    // send EOI cmd for slave
    outb(EOI_CMD, IO1_8259PIC1);                    // send EOI cmd for master
c010115b:	5d                   	pop    %ebp
c010115c:	c3                   	ret    

c010115d <__x86.get_pc_thunk.dx>:
c010115d:	8b 14 24             	mov    (%esp),%edx
c0101160:	c3                   	ret    

c0101161 <__x86.get_pc_thunk.di>:
c0101161:	8b 3c 24             	mov    (%esp),%edi
c0101164:	c3                   	ret    
c0101165:	90                   	nop

c0101166 <_ZN3RTC12clInteStatusEv>:
    outb(regA, RTC_DATA_PORT1);                     // write A

    clInteStatus();                                 // clear Interrupt status
}

void RTC::clInteStatus() {
c0101166:	55                   	push   %ebp
c0101167:	b0 0c                	mov    $0xc,%al
c0101169:	89 e5                	mov    %esp,%ebp
c010116b:	ba 70 00 00 00       	mov    $0x70,%edx
c0101170:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c0101171:	ba 71 00 00 00       	mov    $0x71,%edx
c0101176:	ec                   	in     (%dx),%al
    outb(RTC_REG_C, RTC_INDEX_PORT1);               // choice reg C
    inb(RTC_DATA_PORT1);                            // read regC to clear interrupt status
c0101177:	5d                   	pop    %ebp
c0101178:	c3                   	ret    
c0101179:	90                   	nop

c010117a <_ZN3RTC9initClockEv>:
void RTC::initClock() {
c010117a:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c010117b:	b0 8b                	mov    $0x8b,%al
c010117d:	89 e5                	mov    %esp,%ebp
c010117f:	53                   	push   %ebx
c0101180:	bb 70 00 00 00       	mov    $0x70,%ebx
c0101185:	89 da                	mov    %ebx,%edx
c0101187:	ee                   	out    %al,(%dx)
c0101188:	b9 71 00 00 00       	mov    $0x71,%ecx
c010118d:	b0 42                	mov    $0x42,%al
c010118f:	89 ca                	mov    %ecx,%edx
c0101191:	ee                   	out    %al,(%dx)
c0101192:	b0 0a                	mov    $0xa,%al
c0101194:	89 da                	mov    %ebx,%edx
c0101196:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c0101197:	89 ca                	mov    %ecx,%edx
c0101199:	ec                   	in     (%dx),%al
    regA = (regA & 0xF0) | 0x2;                     // 7.8125ms
c010119a:	24 f0                	and    $0xf0,%al
c010119c:	0c 02                	or     $0x2,%al
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c010119e:	ee                   	out    %al,(%dx)
}
c010119f:	5b                   	pop    %ebx
c01011a0:	5d                   	pop    %ebp
    clInteStatus();                                 // clear Interrupt status
c01011a1:	eb c3                	jmp    c0101166 <_ZN3RTC12clInteStatusEv>
c01011a3:	90                   	nop

c01011a4 <_ZN11VideoMemoryC1Ev>:
#include <vdieomemory.h>

VideoMemory::VideoMemory() {
c01011a4:	55                   	push   %ebp
c01011a5:	89 e5                	mov    %esp,%ebp
c01011a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01011aa:	c7 00 00 80 0b c0    	movl   $0xc00b8000,(%eax)
c01011b0:	66 c7 40 04 a0 0f    	movw   $0xfa0,0x4(%eax)

}
c01011b6:	5d                   	pop    %ebp
c01011b7:	c3                   	ret    

c01011b8 <_ZN11VideoMemory10initVmBuffEv>:

void VideoMemory::initVmBuff() {
c01011b8:	55                   	push   %ebp
    for (uint32_t i = 0; i < VGA_BUFF_SIZE; i++) {
c01011b9:	31 c0                	xor    %eax,%eax
void VideoMemory::initVmBuff() {
c01011bb:	89 e5                	mov    %esp,%ebp
c01011bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
        vmBuffer[i] = 0;
c01011c0:	8b 11                	mov    (%ecx),%edx
c01011c2:	c6 04 02 00          	movb   $0x0,(%edx,%eax,1)
    for (uint32_t i = 0; i < VGA_BUFF_SIZE; i++) {
c01011c6:	40                   	inc    %eax
c01011c7:	3d a0 0f 00 00       	cmp    $0xfa0,%eax
c01011cc:	75 f2                	jne    c01011c0 <_ZN11VideoMemory10initVmBuffEv+0x8>
    }
}
c01011ce:	5d                   	pop    %ebp
c01011cf:	c3                   	ret    

c01011d0 <_ZN11VideoMemory12getCursorPosEv>:

uint16_t VideoMemory::getCursorPos() {
c01011d0:	55                   	push   %ebp
c01011d1:	b0 0f                	mov    $0xf,%al
c01011d3:	89 e5                	mov    %esp,%ebp
c01011d5:	56                   	push   %esi
c01011d6:	be d4 03 00 00       	mov    $0x3d4,%esi
c01011db:	53                   	push   %ebx
c01011dc:	89 f2                	mov    %esi,%edx
c01011de:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c01011df:	bb d5 03 00 00       	mov    $0x3d5,%ebx
c01011e4:	89 da                	mov    %ebx,%edx
c01011e6:	ec                   	in     (%dx),%al
c01011e7:	0f b6 c8             	movzbl %al,%ecx
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c01011ea:	89 f2                	mov    %esi,%edx
c01011ec:	b0 0e                	mov    $0xe,%al
c01011ee:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
c01011ef:	89 da                	mov    %ebx,%edx
c01011f1:	ec                   	in     (%dx),%al
    outb(VGA_CURSOR_PORT_D, VGA_INDEX_PORT);
    uint8_t low = inb(VGA_DATA_PORT);
    outb(VGA_CURSOR_PORT_H, VGA_INDEX_PORT);
    uint16_t pos = inb(VGA_DATA_PORT);
    return (pos << 8) + low;
}
c01011f2:	5b                   	pop    %ebx
    uint16_t pos = inb(VGA_DATA_PORT);
c01011f3:	0f b6 c0             	movzbl %al,%eax
    return (pos << 8) + low;
c01011f6:	c1 e0 08             	shl    $0x8,%eax
}
c01011f9:	5e                   	pop    %esi
    return (pos << 8) + low;
c01011fa:	01 c8                	add    %ecx,%eax
}
c01011fc:	5d                   	pop    %ebp
c01011fd:	c3                   	ret    

c01011fe <_ZN11VideoMemory12setCursorPosEt>:

void VideoMemory::setCursorPos(uint16_t pos) {
c01011fe:	55                   	push   %ebp
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
c01011ff:	b0 0f                	mov    $0xf,%al
c0101201:	89 e5                	mov    %esp,%ebp
c0101203:	56                   	push   %esi
c0101204:	be d4 03 00 00       	mov    $0x3d4,%esi
c0101209:	0f b7 4d 0c          	movzwl 0xc(%ebp),%ecx
c010120d:	53                   	push   %ebx
c010120e:	89 f2                	mov    %esi,%edx
c0101210:	ee                   	out    %al,(%dx)
c0101211:	bb d5 03 00 00       	mov    $0x3d5,%ebx
c0101216:	88 c8                	mov    %cl,%al
c0101218:	89 da                	mov    %ebx,%edx
c010121a:	ee                   	out    %al,(%dx)
c010121b:	b0 0e                	mov    $0xe,%al
c010121d:	89 f2                	mov    %esi,%edx
c010121f:	ee                   	out    %al,(%dx)
    outb(VGA_CURSOR_PORT_D, VGA_INDEX_PORT);
    outb((pos & 0xFF), VGA_DATA_PORT);
    outb(VGA_CURSOR_PORT_H, VGA_INDEX_PORT);
    outb(((pos >> 8) & 0xFF), VGA_DATA_PORT);
c0101220:	89 c8                	mov    %ecx,%eax
c0101222:	89 da                	mov    %ebx,%edx
c0101224:	c1 e8 08             	shr    $0x8,%eax
c0101227:	ee                   	out    %al,(%dx)
c0101228:	5b                   	pop    %ebx
c0101229:	5e                   	pop    %esi
c010122a:	5d                   	pop    %ebp
c010122b:	c3                   	ret    

c010122c <_ZN7OStreamC1E6StringS0_>:
 * @Last Modified time: 2020-03-25 22:00:55
 */

#include <ostream.h>

OStream::OStream(String str, String col) {
c010122c:	55                   	push   %ebp
c010122d:	89 e5                	mov    %esp,%ebp
c010122f:	57                   	push   %edi
c0101230:	56                   	push   %esi
c0101231:	53                   	push   %ebx
c0101232:	83 ec 28             	sub    $0x28,%esp
c0101235:	e8 53 f9 ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c010123a:	81 c3 ce e1 00 00    	add    $0xe1ce,%ebx
c0101240:	8b 75 08             	mov    0x8(%ebp),%esi
c0101243:	8b 7d 10             	mov    0x10(%ebp),%edi
c0101246:	56                   	push   %esi
c0101247:	e8 46 f9 ff ff       	call   c0100b92 <_ZN7ConsoleC1Ev>
    cons.setColor(col);
c010124c:	8b 07                	mov    (%edi),%eax
OStream::OStream(String str, String col) {
c010124e:	c7 86 40 02 00 00 00 	movl   $0x200,0x240(%esi)
c0101255:	02 00 00 
    cons.setColor(col);
c0101258:	5a                   	pop    %edx
c0101259:	59                   	pop    %ecx
c010125a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010125d:	8b 47 04             	mov    0x4(%edi),%eax
c0101260:	8d 7d e0             	lea    -0x20(%ebp),%edi
c0101263:	57                   	push   %edi
c0101264:	56                   	push   %esi
c0101265:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0101268:	e8 fb f9 ff ff       	call   c0100c68 <_ZN7Console8setColorE6String>
c010126d:	89 3c 24             	mov    %edi,(%esp)
c0101270:	e8 3f 07 00 00       	call   c01019b4 <_ZN6StringD1Ev>
    buffPointer = 0;
c0101275:	c7 86 3c 02 00 00 00 	movl   $0x0,0x23c(%esi)
c010127c:	00 00 00 
c010127f:	83 c4 10             	add    $0x10,%esp
    for (; buffPointer < str.getLength(); buffPointer++) {
c0101282:	8b be 3c 02 00 00    	mov    0x23c(%esi),%edi
c0101288:	83 ec 0c             	sub    $0xc,%esp
c010128b:	ff 75 0c             	pushl  0xc(%ebp)
c010128e:	e8 67 07 00 00       	call   c01019fa <_ZNK6String9getLengthEv>
c0101293:	83 c4 10             	add    $0x10,%esp
c0101296:	0f b6 c0             	movzbl %al,%eax
c0101299:	39 c7                	cmp    %eax,%edi
c010129b:	73 25                	jae    c01012c2 <_ZN7OStreamC1E6StringS0_+0x96>
        buffer[buffPointer] = str[buffPointer];
c010129d:	50                   	push   %eax
c010129e:	50                   	push   %eax
c010129f:	ff b6 3c 02 00 00    	pushl  0x23c(%esi)
c01012a5:	ff 75 0c             	pushl  0xc(%ebp)
c01012a8:	e8 93 07 00 00       	call   c0101a40 <_ZN6StringixEj>
c01012ad:	8b 8e 3c 02 00 00    	mov    0x23c(%esi),%ecx
c01012b3:	8a 00                	mov    (%eax),%al
c01012b5:	88 44 0e 3c          	mov    %al,0x3c(%esi,%ecx,1)
    for (; buffPointer < str.getLength(); buffPointer++) {
c01012b9:	41                   	inc    %ecx
c01012ba:	89 8e 3c 02 00 00    	mov    %ecx,0x23c(%esi)
c01012c0:	eb bd                	jmp    c010127f <_ZN7OStreamC1E6StringS0_+0x53>
    }
}
c01012c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
c01012c5:	5b                   	pop    %ebx
c01012c6:	5e                   	pop    %esi
c01012c7:	5f                   	pop    %edi
c01012c8:	5d                   	pop    %ebp
c01012c9:	c3                   	ret    

c01012ca <_ZN7OStream5flushEv>:

OStream::~OStream() {
    flush();
}

void OStream::flush() {
c01012ca:	55                   	push   %ebp
c01012cb:	89 e5                	mov    %esp,%ebp
c01012cd:	56                   	push   %esi
c01012ce:	53                   	push   %ebx
c01012cf:	83 ec 14             	sub    $0x14,%esp
c01012d2:	8b 75 08             	mov    0x8(%ebp),%esi
c01012d5:	e8 b3 f8 ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c01012da:	81 c3 2e e1 00 00    	add    $0xe12e,%ebx
    cons.wirte(buffer, buffPointer);
c01012e0:	8b 86 3c 02 00 00    	mov    0x23c(%esi),%eax
c01012e6:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c01012ea:	8d 45 f6             	lea    -0xa(%ebp),%eax
c01012ed:	50                   	push   %eax
c01012ee:	8d 46 3c             	lea    0x3c(%esi),%eax
c01012f1:	50                   	push   %eax
c01012f2:	56                   	push   %esi
c01012f3:	e8 a6 fc ff ff       	call   c0100f9e <_ZN7Console5wirteEPcRKt>
    buffPointer = 0;
}
c01012f8:	83 c4 10             	add    $0x10,%esp
    buffPointer = 0;
c01012fb:	c7 86 3c 02 00 00 00 	movl   $0x0,0x23c(%esi)
c0101302:	00 00 00 
}
c0101305:	8d 65 f8             	lea    -0x8(%ebp),%esp
c0101308:	5b                   	pop    %ebx
c0101309:	5e                   	pop    %esi
c010130a:	5d                   	pop    %ebp
c010130b:	c3                   	ret    

c010130c <_ZN7OStreamD1Ev>:
OStream::~OStream() {
c010130c:	55                   	push   %ebp
c010130d:	89 e5                	mov    %esp,%ebp
c010130f:	57                   	push   %edi
c0101310:	56                   	push   %esi
c0101311:	53                   	push   %ebx
c0101312:	83 ec 18             	sub    $0x18,%esp
c0101315:	8b 75 08             	mov    0x8(%ebp),%esi
c0101318:	e8 70 f8 ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c010131d:	81 c3 eb e0 00 00    	add    $0xe0eb,%ebx
    flush();
c0101323:	56                   	push   %esi
c0101324:	e8 a1 ff ff ff       	call   c01012ca <_ZN7OStream5flushEv>
#include <vdieomemory.h>
#include <string.h>

#define COLOR_NUM       4

class Console : public VideoMemory {
c0101329:	8d 7e 08             	lea    0x8(%esi),%edi
c010132c:	83 c6 28             	add    $0x28,%esi
c010132f:	83 c4 10             	add    $0x10,%esp
c0101332:	39 f7                	cmp    %esi,%edi
c0101334:	74 0e                	je     c0101344 <_ZN7OStreamD1Ev+0x38>
c0101336:	83 ee 08             	sub    $0x8,%esi
c0101339:	83 ec 0c             	sub    $0xc,%esp
c010133c:	56                   	push   %esi
c010133d:	e8 72 06 00 00       	call   c01019b4 <_ZN6StringD1Ev>
c0101342:	eb eb                	jmp    c010132f <_ZN7OStreamD1Ev+0x23>
}
c0101344:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101347:	5b                   	pop    %ebx
c0101348:	5e                   	pop    %esi
c0101349:	5f                   	pop    %edi
c010134a:	5d                   	pop    %ebp
c010134b:	c3                   	ret    

c010134c <_ZN7OStream5writeERKc>:

void OStream::write(const char &c) {
c010134c:	55                   	push   %ebp
c010134d:	89 e5                	mov    %esp,%ebp
c010134f:	53                   	push   %ebx
c0101350:	50                   	push   %eax
c0101351:	8b 5d 08             	mov    0x8(%ebp),%ebx
    if (buffPointer + 1 > BUFFER_MAX) {
c0101354:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
c010135a:	40                   	inc    %eax
c010135b:	3b 83 40 02 00 00    	cmp    0x240(%ebx),%eax
c0101361:	76 0c                	jbe    c010136f <_ZN7OStream5writeERKc+0x23>
        flush();
c0101363:	83 ec 0c             	sub    $0xc,%esp
c0101366:	53                   	push   %ebx
c0101367:	e8 5e ff ff ff       	call   c01012ca <_ZN7OStream5flushEv>
c010136c:	83 c4 10             	add    $0x10,%esp
    }
    buffer[buffPointer++] = c;
c010136f:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
c0101375:	8d 50 01             	lea    0x1(%eax),%edx
c0101378:	89 93 3c 02 00 00    	mov    %edx,0x23c(%ebx)
c010137e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101381:	8a 12                	mov    (%edx),%dl
c0101383:	88 54 03 3c          	mov    %dl,0x3c(%ebx,%eax,1)
}
c0101387:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c010138a:	c9                   	leave  
c010138b:	c3                   	ret    

c010138c <_ZN7OStream5writeEPKcRKj>:

void OStream::write(const char *arr, const uint32_t &len) {
c010138c:	55                   	push   %ebp
c010138d:	89 e5                	mov    %esp,%ebp
c010138f:	53                   	push   %ebx
    for (uint32_t i = 0; i < len; i++) {
c0101390:	31 db                	xor    %ebx,%ebx
void OStream::write(const char *arr, const uint32_t &len) {
c0101392:	52                   	push   %edx
    for (uint32_t i = 0; i < len; i++) {
c0101393:	8b 45 10             	mov    0x10(%ebp),%eax
c0101396:	39 18                	cmp    %ebx,(%eax)
c0101398:	76 16                	jbe    c01013b0 <_ZN7OStream5writeEPKcRKj+0x24>
        write(arr[i]);
c010139a:	50                   	push   %eax
c010139b:	50                   	push   %eax
c010139c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010139f:	01 d8                	add    %ebx,%eax
    for (uint32_t i = 0; i < len; i++) {
c01013a1:	43                   	inc    %ebx
        write(arr[i]);
c01013a2:	50                   	push   %eax
c01013a3:	ff 75 08             	pushl  0x8(%ebp)
c01013a6:	e8 a1 ff ff ff       	call   c010134c <_ZN7OStream5writeERKc>
    for (uint32_t i = 0; i < len; i++) {
c01013ab:	83 c4 10             	add    $0x10,%esp
c01013ae:	eb e3                	jmp    c0101393 <_ZN7OStream5writeEPKcRKj+0x7>
    }
}
c01013b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01013b3:	c9                   	leave  
c01013b4:	c3                   	ret    
c01013b5:	90                   	nop

c01013b6 <_ZN7OStream5writeERK6String>:

void OStream::write(const String &str) {
c01013b6:	55                   	push   %ebp
c01013b7:	89 e5                	mov    %esp,%ebp
c01013b9:	56                   	push   %esi
c01013ba:	53                   	push   %ebx
c01013bb:	83 ec 1c             	sub    $0x1c,%esp
c01013be:	e8 ca f7 ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c01013c3:	81 c3 45 e0 00 00    	add    $0xe045,%ebx
c01013c9:	8b 75 0c             	mov    0xc(%ebp),%esi
    write(str.cStr(), str.getLength());
c01013cc:	56                   	push   %esi
c01013cd:	e8 28 06 00 00       	call   c01019fa <_ZNK6String9getLengthEv>
c01013d2:	89 34 24             	mov    %esi,(%esp)
c01013d5:	0f b6 c0             	movzbl %al,%eax
c01013d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013db:	e8 10 06 00 00       	call   c01019f0 <_ZNK6String4cStrEv>
c01013e0:	83 c4 0c             	add    $0xc,%esp
c01013e3:	8d 55 f4             	lea    -0xc(%ebp),%edx
c01013e6:	52                   	push   %edx
c01013e7:	50                   	push   %eax
c01013e8:	ff 75 08             	pushl  0x8(%ebp)
c01013eb:	e8 9c ff ff ff       	call   c010138c <_ZN7OStream5writeEPKcRKj>
}
c01013f0:	83 c4 10             	add    $0x10,%esp
c01013f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01013f6:	5b                   	pop    %ebx
c01013f7:	5e                   	pop    %esi
c01013f8:	5d                   	pop    %ebp
c01013f9:	c3                   	ret    

c01013fa <_ZN7OStream10writeValueERKj>:

void OStream::writeValue(const uint32_t &val) {
c01013fa:	55                   	push   %ebp
c01013fb:	89 e5                	mov    %esp,%ebp
c01013fd:	57                   	push   %edi
c01013fe:	56                   	push   %esi
c01013ff:	53                   	push   %ebx
c0101400:	83 ec 3c             	sub    $0x3c,%esp
    if (val < 10) {
c0101403:	8b 45 0c             	mov    0xc(%ebp),%eax
void OStream::writeValue(const uint32_t &val) {
c0101406:	8b 75 08             	mov    0x8(%ebp),%esi
    if (val < 10) {
c0101409:	8b 00                	mov    (%eax),%eax
c010140b:	83 f8 09             	cmp    $0x9,%eax
c010140e:	77 16                	ja     c0101426 <_ZN7OStream10writeValueERKj+0x2c>
        write(val + '0');
c0101410:	04 30                	add    $0x30,%al
c0101412:	52                   	push   %edx
c0101413:	52                   	push   %edx
c0101414:	88 45 c5             	mov    %al,-0x3b(%ebp)
c0101417:	8d 45 c5             	lea    -0x3b(%ebp),%eax
c010141a:	50                   	push   %eax
c010141b:	56                   	push   %esi
c010141c:	e8 2b ff ff ff       	call   c010134c <_ZN7OStream5writeERKc>
c0101421:	83 c4 10             	add    $0x10,%esp
c0101424:	eb 30                	jmp    c0101456 <_ZN7OStream10writeValueERKj+0x5c>
c0101426:	31 db                	xor    %ebx,%ebx
c0101428:	8d 7d c4             	lea    -0x3c(%ebp),%edi
    } else {
        uint8_t s[35];
        uint32_t temp = val, pos = 0;
        while (temp) {
            s[pos++] = temp % 10;
c010142b:	31 d2                	xor    %edx,%edx
c010142d:	b9 0a 00 00 00       	mov    $0xa,%ecx
c0101432:	f7 f1                	div    %ecx
c0101434:	43                   	inc    %ebx
        while (temp) {
c0101435:	85 c0                	test   %eax,%eax
            s[pos++] = temp % 10;
c0101437:	88 14 1f             	mov    %dl,(%edi,%ebx,1)
        while (temp) {
c010143a:	75 ef                	jne    c010142b <_ZN7OStream10writeValueERKj+0x31>
            temp /= 10;
        }
        while (pos) {
            write(s[--pos] + '0');
c010143c:	4b                   	dec    %ebx
c010143d:	8a 44 1d c5          	mov    -0x3b(%ebp,%ebx,1),%al
c0101441:	04 30                	add    $0x30,%al
c0101443:	88 45 c4             	mov    %al,-0x3c(%ebp)
c0101446:	50                   	push   %eax
c0101447:	50                   	push   %eax
c0101448:	57                   	push   %edi
c0101449:	56                   	push   %esi
c010144a:	e8 fd fe ff ff       	call   c010134c <_ZN7OStream5writeERKc>
        while (pos) {
c010144f:	83 c4 10             	add    $0x10,%esp
c0101452:	85 db                	test   %ebx,%ebx
c0101454:	75 e6                	jne    c010143c <_ZN7OStream10writeValueERKj+0x42>
        }
    }
c0101456:	8d 65 f4             	lea    -0xc(%ebp),%esp
c0101459:	5b                   	pop    %ebx
c010145a:	5e                   	pop    %esi
c010145b:	5f                   	pop    %edi
c010145c:	5d                   	pop    %ebp
c010145d:	c3                   	ret    

c010145e <_ZN5PhyMM14initPmmManagerEv>:

    /*     wait --- 2020.4.4      */

}

void PhyMM::initPmmManager() {
c010145e:	55                   	push   %ebp
c010145f:	89 e5                	mov    %esp,%ebp
   
}
c0101461:	5d                   	pop    %ebp
c0101462:	c3                   	ret    
c0101463:	90                   	nop

c0101464 <_ZN5PhyMM8vToPhyADEj>:

uptr32_t PhyMM::vToPhyAD(uptr32_t kvAd) {
c0101464:	55                   	push   %ebp
c0101465:	89 e5                	mov    %esp,%ebp
    return kvAd - KERNEL_BASE;
c0101467:	8b 45 0c             	mov    0xc(%ebp),%eax
}
c010146a:	5d                   	pop    %ebp
    return kvAd - KERNEL_BASE;
c010146b:	05 00 00 00 40       	add    $0x40000000,%eax
}
c0101470:	c3                   	ret    
c0101471:	90                   	nop

c0101472 <_ZN5PhyMM8pToVirADEj>:

uptr32_t PhyMM::pToVirAD(uptr32_t pAd) {
c0101472:	55                   	push   %ebp
c0101473:	89 e5                	mov    %esp,%ebp
    return pAd + KERNEL_BASE;
c0101475:	8b 45 0c             	mov    0xc(%ebp),%eax
}
c0101478:	5d                   	pop    %ebp
    return pAd + KERNEL_BASE;
c0101479:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c010147e:	c3                   	ret    
c010147f:	90                   	nop

c0101480 <_ZN5PhyMM7roundUpEjj>:

uint32_t PhyMM::roundUp(uint32_t a, uint32_t n) {
c0101480:	55                   	push   %ebp
c0101481:	31 d2                	xor    %edx,%edx
c0101483:	89 e5                	mov    %esp,%ebp
c0101485:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0101488:	89 c8                	mov    %ecx,%eax
c010148a:	f7 75 10             	divl   0x10(%ebp)
    a = (a % n == 0) ? a : (a / n + 1) * n;
c010148d:	85 d2                	test   %edx,%edx
c010148f:	74 07                	je     c0101498 <_ZN5PhyMM7roundUpEjj+0x18>
c0101491:	8d 48 01             	lea    0x1(%eax),%ecx
c0101494:	0f af 4d 10          	imul   0x10(%ebp),%ecx
    return a;
}
c0101498:	89 c8                	mov    %ecx,%eax
c010149a:	5d                   	pop    %ebp
c010149b:	c3                   	ret    

c010149c <_ZN5PhyMM8initPageEv>:
void PhyMM::initPage() {
c010149c:	55                   	push   %ebp
c010149d:	89 e5                	mov    %esp,%ebp
c010149f:	57                   	push   %edi
c01014a0:	56                   	push   %esi
c01014a1:	53                   	push   %ebx
c01014a2:	e8 e6 f6 ff ff       	call   c0100b8d <__x86.get_pc_thunk.bx>
c01014a7:	81 c3 61 df 00 00    	add    $0xdf61,%ebx
c01014ad:	81 ec a4 02 00 00    	sub    $0x2a4,%esp
    OStream out("Memmory Map [E820Map] begin...\n", "blue");
c01014b3:	8d b5 9c fd ff ff    	lea    -0x264(%ebp),%esi
c01014b9:	8d 83 4b 26 ff ff    	lea    -0xd9b5(%ebx),%eax
c01014bf:	50                   	push   %eax
c01014c0:	56                   	push   %esi
c01014c1:	e8 d4 04 00 00       	call   c010199a <_ZN6StringC1EPKc>
c01014c6:	8d 83 70 26 ff ff    	lea    -0xd990(%ebx),%eax
c01014cc:	59                   	pop    %ecx
c01014cd:	5f                   	pop    %edi
c01014ce:	8d bd 94 fd ff ff    	lea    -0x26c(%ebp),%edi
c01014d4:	50                   	push   %eax
c01014d5:	57                   	push   %edi
c01014d6:	e8 bf 04 00 00       	call   c010199a <_ZN6StringC1EPKc>
c01014db:	83 c4 0c             	add    $0xc,%esp
c01014de:	56                   	push   %esi
c01014df:	57                   	push   %edi
c01014e0:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
c01014e6:	50                   	push   %eax
c01014e7:	e8 40 fd ff ff       	call   c010122c <_ZN7OStreamC1E6StringS0_>
c01014ec:	89 3c 24             	mov    %edi,(%esp)
c01014ef:	e8 c0 04 00 00       	call   c01019b4 <_ZN6StringD1Ev>
c01014f4:	89 34 24             	mov    %esi,(%esp)
c01014f7:	e8 b8 04 00 00       	call   c01019b4 <_ZN6StringD1Ev>
c01014fc:	83 c4 10             	add    $0x10,%esp
    uint64_t maxpa = 0;                                                             // size of all mem-block
c01014ff:	31 c9                	xor    %ecx,%ecx
    for (uint32_t i = 0; i < memMap->numARDS; i++) {                               // scan all of free memory block
c0101501:	c7 85 70 fd ff ff 00 	movl   $0x0,-0x290(%ebp)
c0101508:	00 00 00 
    uint64_t maxpa = 0;                                                             // size of all mem-block
c010150b:	c7 85 74 fd ff ff 00 	movl   $0x0,-0x28c(%ebp)
c0101512:	00 00 00 
    for (uint32_t i = 0; i < memMap->numARDS; i++) {                               // scan all of free memory block
c0101515:	8b 85 70 fd ff ff    	mov    -0x290(%ebp),%eax
c010151b:	39 05 00 80 00 c0    	cmp    %eax,0xc0008000
c0101521:	0f 86 d9 01 00 00    	jbe    c0101700 <_ZN5PhyMM8initPageEv+0x264>
c0101527:	6b c0 14             	imul   $0x14,%eax,%eax
c010152a:	89 8d 64 fd ff ff    	mov    %ecx,-0x29c(%ebp)
        uint64_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c0101530:	8b b0 04 80 00 c0    	mov    -0x3fff7ffc(%eax),%esi
c0101536:	8d 90 00 80 00 c0    	lea    -0x3fff8000(%eax),%edx
c010153c:	8b b8 08 80 00 c0    	mov    -0x3fff7ff8(%eax),%edi
c0101542:	89 85 68 fd ff ff    	mov    %eax,-0x298(%ebp)
c0101548:	89 95 6c fd ff ff    	mov    %edx,-0x294(%ebp)
c010154e:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
c0101554:	03 b0 0c 80 00 c0    	add    -0x3fff7ff4(%eax),%esi
c010155a:	89 bd 84 fd ff ff    	mov    %edi,-0x27c(%ebp)
c0101560:	13 b8 10 80 00 c0    	adc    -0x3fff7ff0(%eax),%edi
        out.write(" >> size = ");
c0101566:	50                   	push   %eax
c0101567:	50                   	push   %eax
        uint64_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c0101568:	89 b5 78 fd ff ff    	mov    %esi,-0x288(%ebp)
        out.write(" >> size = ");
c010156e:	8d b3 90 26 ff ff    	lea    -0xd970(%ebx),%esi
c0101574:	56                   	push   %esi
c0101575:	8d b5 9c fd ff ff    	lea    -0x264(%ebp),%esi
c010157b:	56                   	push   %esi
        uint64_t begin = memMap->ARDS[i].addr, end = begin + memMap->ARDS[i].size;
c010157c:	89 bd 7c fd ff ff    	mov    %edi,-0x284(%ebp)
        out.write(" >> size = ");
c0101582:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
c0101588:	e8 0d 04 00 00       	call   c010199a <_ZN6StringC1EPKc>
c010158d:	58                   	pop    %eax
c010158e:	5a                   	pop    %edx
c010158f:	56                   	push   %esi
c0101590:	57                   	push   %edi
c0101591:	e8 20 fe ff ff       	call   c01013b6 <_ZN7OStream5writeERK6String>
c0101596:	89 34 24             	mov    %esi,(%esp)
c0101599:	e8 16 04 00 00       	call   c01019b4 <_ZN6StringD1Ev>
        out.writeValue(memMap->ARDS[i].size);
c010159e:	8b 95 6c fd ff ff    	mov    -0x294(%ebp),%edx
c01015a4:	59                   	pop    %ecx
c01015a5:	58                   	pop    %eax
c01015a6:	8b 52 0c             	mov    0xc(%edx),%edx
c01015a9:	56                   	push   %esi
c01015aa:	57                   	push   %edi
c01015ab:	89 95 9c fd ff ff    	mov    %edx,-0x264(%ebp)
c01015b1:	e8 44 fe ff ff       	call   c01013fa <_ZN7OStream10writeValueERKj>
        out.write(" range: ");
c01015b6:	58                   	pop    %eax
c01015b7:	5a                   	pop    %edx
c01015b8:	8d 93 9c 26 ff ff    	lea    -0xd964(%ebx),%edx
c01015be:	52                   	push   %edx
c01015bf:	56                   	push   %esi
c01015c0:	e8 d5 03 00 00       	call   c010199a <_ZN6StringC1EPKc>
c01015c5:	59                   	pop    %ecx
c01015c6:	58                   	pop    %eax
c01015c7:	56                   	push   %esi
c01015c8:	57                   	push   %edi
c01015c9:	e8 e8 fd ff ff       	call   c01013b6 <_ZN7OStream5writeERK6String>
c01015ce:	89 34 24             	mov    %esi,(%esp)
c01015d1:	e8 de 03 00 00       	call   c01019b4 <_ZN6StringD1Ev>
        out.writeValue(begin);
c01015d6:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
c01015dc:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
c01015e2:	58                   	pop    %eax
c01015e3:	5a                   	pop    %edx
c01015e4:	56                   	push   %esi
c01015e5:	57                   	push   %edi
c01015e6:	e8 0f fe ff ff       	call   c01013fa <_ZN7OStream10writeValueERKj>
        out.write(" ~ ");
c01015eb:	8d 93 a5 26 ff ff    	lea    -0xd95b(%ebx),%edx
c01015f1:	59                   	pop    %ecx
c01015f2:	58                   	pop    %eax
c01015f3:	52                   	push   %edx
c01015f4:	56                   	push   %esi
c01015f5:	e8 a0 03 00 00       	call   c010199a <_ZN6StringC1EPKc>
c01015fa:	58                   	pop    %eax
c01015fb:	5a                   	pop    %edx
c01015fc:	56                   	push   %esi
c01015fd:	57                   	push   %edi
c01015fe:	e8 b3 fd ff ff       	call   c01013b6 <_ZN7OStream5writeERK6String>
c0101603:	89 34 24             	mov    %esi,(%esp)
c0101606:	e8 a9 03 00 00       	call   c01019b4 <_ZN6StringD1Ev>
        out.writeValue(end - 1);
c010160b:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
c0101611:	59                   	pop    %ecx
c0101612:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101615:	58                   	pop    %eax
c0101616:	89 95 9c fd ff ff    	mov    %edx,-0x264(%ebp)
c010161c:	56                   	push   %esi
c010161d:	57                   	push   %edi
c010161e:	e8 d7 fd ff ff       	call   c01013fa <_ZN7OStream10writeValueERKj>
        out.write(" type = ");
c0101623:	58                   	pop    %eax
c0101624:	5a                   	pop    %edx
c0101625:	8d 93 a9 26 ff ff    	lea    -0xd957(%ebx),%edx
c010162b:	52                   	push   %edx
c010162c:	56                   	push   %esi
c010162d:	e8 68 03 00 00       	call   c010199a <_ZN6StringC1EPKc>
c0101632:	59                   	pop    %ecx
c0101633:	58                   	pop    %eax
c0101634:	56                   	push   %esi
c0101635:	57                   	push   %edi
c0101636:	e8 7b fd ff ff       	call   c01013b6 <_ZN7OStream5writeERK6String>
c010163b:	89 34 24             	mov    %esi,(%esp)
c010163e:	e8 71 03 00 00       	call   c01019b4 <_ZN6StringD1Ev>
        out.writeValue(memMap->ARDS[i].type);
c0101643:	8b 85 68 fd ff ff    	mov    -0x298(%ebp),%eax
c0101649:	8b 90 14 80 00 c0    	mov    -0x3fff7fec(%eax),%edx
c010164f:	89 85 6c fd ff ff    	mov    %eax,-0x294(%ebp)
c0101655:	58                   	pop    %eax
c0101656:	89 95 9c fd ff ff    	mov    %edx,-0x264(%ebp)
c010165c:	5a                   	pop    %edx
c010165d:	56                   	push   %esi
c010165e:	57                   	push   %edi
c010165f:	e8 96 fd ff ff       	call   c01013fa <_ZN7OStream10writeValueERKj>
        if (memMap->ARDS[i].type == E820_ARM) {                                    // is ARM Area
c0101664:	8b 85 6c fd ff ff    	mov    -0x294(%ebp),%eax
c010166a:	83 c4 10             	add    $0x10,%esp
c010166d:	8b 8d 64 fd ff ff    	mov    -0x29c(%ebp),%ecx
c0101673:	83 b8 14 80 00 c0 01 	cmpl   $0x1,-0x3fff7fec(%eax)
c010167a:	75 45                	jne    c01016c1 <_ZN5PhyMM8initPageEv+0x225>
            if (maxpa < end && begin < KERNEL_MEM_SIZE) {
c010167c:	8b 95 7c fd ff ff    	mov    -0x284(%ebp),%edx
c0101682:	39 95 74 fd ff ff    	cmp    %edx,-0x28c(%ebp)
c0101688:	72 0a                	jb     c0101694 <_ZN5PhyMM8initPageEv+0x1f8>
c010168a:	77 35                	ja     c01016c1 <_ZN5PhyMM8initPageEv+0x225>
c010168c:	3b 8d 78 fd ff ff    	cmp    -0x288(%ebp),%ecx
c0101692:	73 2d                	jae    c01016c1 <_ZN5PhyMM8initPageEv+0x225>
c0101694:	83 bd 84 fd ff ff 00 	cmpl   $0x0,-0x27c(%ebp)
c010169b:	77 24                	ja     c01016c1 <_ZN5PhyMM8initPageEv+0x225>
c010169d:	81 bd 80 fd ff ff ff 	cmpl   $0x37ffffff,-0x280(%ebp)
c01016a4:	ff ff 37 
c01016a7:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
c01016ad:	0f 47 85 74 fd ff ff 	cmova  -0x28c(%ebp),%eax
c01016b4:	0f 46 8d 78 fd ff ff 	cmovbe -0x288(%ebp),%ecx
c01016bb:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
        out.write("\n", true);
c01016c1:	50                   	push   %eax
c01016c2:	8d 85 9c fd ff ff    	lea    -0x264(%ebp),%eax
c01016c8:	50                   	push   %eax
c01016c9:	8d 83 64 26 ff ff    	lea    -0xd99c(%ebx),%eax
c01016cf:	50                   	push   %eax
c01016d0:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
c01016d6:	50                   	push   %eax
c01016d7:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
c01016dd:	c7 85 9c fd ff ff 01 	movl   $0x1,-0x264(%ebp)
c01016e4:	00 00 00 
c01016e7:	e8 a0 fc ff ff       	call   c010138c <_ZN7OStream5writeEPKcRKj>
    for (uint32_t i = 0; i < memMap->numARDS; i++) {                               // scan all of free memory block
c01016ec:	83 c4 10             	add    $0x10,%esp
c01016ef:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
c01016f5:	ff 85 70 fd ff ff    	incl   -0x290(%ebp)
c01016fb:	e9 15 fe ff ff       	jmp    c0101515 <_ZN5PhyMM8initPageEv+0x79>
    numPage = maxpa / PGSIZE;          // get number of page
c0101700:	8b bd 74 fd ff ff    	mov    -0x28c(%ebp),%edi
c0101706:	89 ce                	mov    %ecx,%esi
c0101708:	83 ff 00             	cmp    $0x0,%edi
c010170b:	77 08                	ja     c0101715 <_ZN5PhyMM8initPageEv+0x279>
c010170d:	81 f9 00 00 00 38    	cmp    $0x38000000,%ecx
c0101713:	76 07                	jbe    c010171c <_ZN5PhyMM8initPageEv+0x280>
c0101715:	be 00 00 00 38       	mov    $0x38000000,%esi
c010171a:	31 ff                	xor    %edi,%edi
c010171c:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010171f:	89 f0                	mov    %esi,%eax
c0101721:	0f ac f8 0c          	shrd   $0xc,%edi,%eax
    out.write("\n numPage = ");
c0101725:	8d b5 9c fd ff ff    	lea    -0x264(%ebp),%esi
    numPage = maxpa / PGSIZE;          // get number of page
c010172b:	89 41 78             	mov    %eax,0x78(%ecx)
    out.write("\n numPage = ");
c010172e:	8d 83 b2 26 ff ff    	lea    -0xd94e(%ebx),%eax
c0101734:	57                   	push   %edi
c0101735:	57                   	push   %edi
c0101736:	50                   	push   %eax
c0101737:	56                   	push   %esi
c0101738:	e8 5d 02 00 00       	call   c010199a <_ZN6StringC1EPKc>
c010173d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
c0101743:	58                   	pop    %eax
c0101744:	5a                   	pop    %edx
c0101745:	56                   	push   %esi
c0101746:	57                   	push   %edi
c0101747:	e8 6a fc ff ff       	call   c01013b6 <_ZN7OStream5writeERK6String>
c010174c:	89 34 24             	mov    %esi,(%esp)
c010174f:	e8 60 02 00 00       	call   c01019b4 <_ZN6StringD1Ev>
    out.writeValue(numPage);
c0101754:	59                   	pop    %ecx
c0101755:	58                   	pop    %eax
c0101756:	8b 45 08             	mov    0x8(%ebp),%eax
c0101759:	83 c0 78             	add    $0x78,%eax
c010175c:	50                   	push   %eax
c010175d:	57                   	push   %edi
c010175e:	e8 97 fc ff ff       	call   c01013fa <_ZN7OStream10writeValueERKj>
    pages = (Page *)roundUp((uint32_t)end, PGSIZE);
c0101763:	83 c4 0c             	add    $0xc,%esp
c0101766:	68 00 10 00 00       	push   $0x1000
c010176b:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
c0101771:	ff 75 08             	pushl  0x8(%ebp)
c0101774:	e8 07 fd ff ff       	call   c0101480 <_ZN5PhyMM7roundUpEjj>
c0101779:	5a                   	pop    %edx
c010177a:	59                   	pop    %ecx
c010177b:	8b 4d 08             	mov    0x8(%ebp),%ecx
c010177e:	89 81 80 00 00 00    	mov    %eax,0x80(%ecx)
    out.write("\n pages = ");
c0101784:	8d 83 bf 26 ff ff    	lea    -0xd941(%ebx),%eax
c010178a:	50                   	push   %eax
c010178b:	56                   	push   %esi
c010178c:	e8 09 02 00 00       	call   c010199a <_ZN6StringC1EPKc>
c0101791:	58                   	pop    %eax
c0101792:	5a                   	pop    %edx
c0101793:	56                   	push   %esi
c0101794:	57                   	push   %edi
c0101795:	e8 1c fc ff ff       	call   c01013b6 <_ZN7OStream5writeERK6String>
c010179a:	89 34 24             	mov    %esi,(%esp)
c010179d:	e8 12 02 00 00       	call   c01019b4 <_ZN6StringD1Ev>
    out.writeValue((uint32_t)pages);
c01017a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01017a5:	59                   	pop    %ecx
c01017a6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
c01017ac:	89 85 9c fd ff ff    	mov    %eax,-0x264(%ebp)
c01017b2:	58                   	pop    %eax
c01017b3:	56                   	push   %esi
c01017b4:	57                   	push   %edi
c01017b5:	e8 40 fc ff ff       	call   c01013fa <_ZN7OStream10writeValueERKj>
c01017ba:	83 c4 10             	add    $0x10,%esp
    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c01017bd:	31 c0                	xor    %eax,%eax
c01017bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
c01017c2:	8b 79 78             	mov    0x78(%ecx),%edi
c01017c5:	8b 91 80 00 00 00    	mov    0x80(%ecx),%edx
c01017cb:	39 c7                	cmp    %eax,%edi
c01017cd:	76 22                	jbe    c01017f1 <_ZN5PhyMM8initPageEv+0x355>
        SetPageReserved(pages + i);
c01017cf:	51                   	push   %ecx
c01017d0:	51                   	push   %ecx
c01017d1:	8d 0c c0             	lea    (%eax,%eax,8),%ecx
c01017d4:	01 ca                	add    %ecx,%edx
c01017d6:	52                   	push   %edx
c01017d7:	ff 75 08             	pushl  0x8(%ebp)
c01017da:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
c01017e0:	e8 8f 01 00 00       	call   c0101974 <_ZN3MMU15SetPageReservedEPNS_4PageE>
    for (uint32_t i = 0; i < numPage; i++) {   // init reserved for all of page 
c01017e5:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
c01017eb:	83 c4 10             	add    $0x10,%esp
c01017ee:	40                   	inc    %eax
c01017ef:	eb ce                	jmp    c01017bf <_ZN5PhyMM8initPageEv+0x323>
    out.write("\n freeMem = ");
c01017f1:	50                   	push   %eax
c01017f2:	50                   	push   %eax
c01017f3:	8d 83 ca 26 ff ff    	lea    -0xd936(%ebx),%eax
c01017f9:	50                   	push   %eax
c01017fa:	56                   	push   %esi
    uptr32_t freeMem = vToPhyAD((uptr32_t)(pages + numPage));
c01017fb:	8d 3c ff             	lea    (%edi,%edi,8),%edi
c01017fe:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
    out.write("\n freeMem = ");
c0101804:	e8 91 01 00 00       	call   c010199a <_ZN6StringC1EPKc>
c0101809:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
c010180f:	5a                   	pop    %edx
c0101810:	89 85 80 fd ff ff    	mov    %eax,-0x280(%ebp)
c0101816:	59                   	pop    %ecx
c0101817:	56                   	push   %esi
c0101818:	50                   	push   %eax
c0101819:	e8 98 fb ff ff       	call   c01013b6 <_ZN7OStream5writeERK6String>
c010181e:	89 34 24             	mov    %esi,(%esp)
c0101821:	e8 8e 01 00 00       	call   c01019b4 <_ZN6StringD1Ev>
    return kvAd - KERNEL_BASE;
c0101826:	8b 95 78 fd ff ff    	mov    -0x288(%ebp),%edx
c010182c:	8d 94 3a 00 00 00 40 	lea    0x40000000(%edx,%edi,1),%edx
    out.writeValue((uint32_t)freeMem);
c0101833:	5f                   	pop    %edi
    return kvAd - KERNEL_BASE;
c0101834:	89 95 9c fd ff ff    	mov    %edx,-0x264(%ebp)
    out.writeValue((uint32_t)freeMem);
c010183a:	58                   	pop    %eax
c010183b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
c0101841:	56                   	push   %esi
c0101842:	50                   	push   %eax
c0101843:	e8 b2 fb ff ff       	call   c01013fa <_ZN7OStream10writeValueERKj>
    OStream out("Memmory Map [E820Map] begin...\n", "blue");
c0101848:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
c010184e:	89 04 24             	mov    %eax,(%esp)
c0101851:	e8 b6 fa ff ff       	call   c010130c <_ZN7OStreamD1Ev>
}
c0101856:	83 c4 10             	add    $0x10,%esp
c0101859:	8d 65 f4             	lea    -0xc(%ebp),%esp
c010185c:	5b                   	pop    %ebx
c010185d:	5e                   	pop    %esi
c010185e:	5f                   	pop    %edi
c010185f:	5d                   	pop    %ebp
c0101860:	c3                   	ret    
c0101861:	90                   	nop

c0101862 <_ZN5PhyMM4initEv>:
void PhyMM::init() {
c0101862:	e8 63 f7 ff ff       	call   c0100fca <__x86.get_pc_thunk.ax>
c0101867:	05 a1 db 00 00       	add    $0xdba1,%eax
c010186c:	55                   	push   %ebp
c010186d:	89 e5                	mov    %esp,%ebp
    bootCR3 = 1;
c010186f:	c7 c0 00 20 11 c0    	mov    $0xc0112000,%eax
c0101875:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
}
c010187b:	5d                   	pop    %ebp
    initPage();
c010187c:	e9 1b fc ff ff       	jmp    c010149c <_ZN5PhyMM8initPageEv>
c0101881:	90                   	nop

c0101882 <_ZN3MMUC1Ev>:
#include <mmu.h>

MMU::MMU() {
c0101882:	55                   	push   %ebp
c0101883:	89 e5                	mov    %esp,%ebp

}
c0101885:	5d                   	pop    %ebp
c0101886:	c3                   	ret    
c0101887:	90                   	nop

c0101888 <_ZN3MMU10setSegDescEjjjj>:

void MMU::setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
c0101888:	55                   	push   %ebp
c0101889:	89 e5                	mov    %esp,%ebp
c010188b:	8b 45 08             	mov    0x8(%ebp),%eax
c010188e:	53                   	push   %ebx
    segdesc.sd_lim_15_0 = lim & 0xffff;
c010188f:	0f b7 55 14          	movzwl 0x14(%ebp),%edx
void MMU::setSegDesc(uint32_t type,uint32_t base, uint32_t lim, uint32_t dpl) {
c0101893:	8b 5d 10             	mov    0x10(%ebp),%ebx
    segdesc.sd_base_15_0 = (base) & 0xffff;
    segdesc.sd_base_23_16 =((base) >> 16) & 0xff;
    segdesc.sd_type = type;
c0101896:	8a 4d 0c             	mov    0xc(%ebp),%cl
    segdesc.sd_lim_15_0 = lim & 0xffff;
c0101899:	88 10                	mov    %dl,(%eax)
c010189b:	88 70 01             	mov    %dh,0x1(%eax)
    segdesc.sd_base_15_0 = (base) & 0xffff;
c010189e:	0f b7 d3             	movzwl %bx,%edx
c01018a1:	88 50 02             	mov    %dl,0x2(%eax)
    segdesc.sd_type = type;
c01018a4:	80 e1 0f             	and    $0xf,%cl
    segdesc.sd_base_15_0 = (base) & 0xffff;
c01018a7:	88 70 03             	mov    %dh,0x3(%eax)
    segdesc.sd_base_23_16 =((base) >> 16) & 0xff;
c01018aa:	89 da                	mov    %ebx,%edx
c01018ac:	c1 ea 10             	shr    $0x10,%edx
c01018af:	88 50 04             	mov    %dl,0x4(%eax)
    segdesc.sd_type = type;
c01018b2:	8a 50 05             	mov    0x5(%eax),%dl
    segdesc.sd_lim_19_16 = (uint16_t)(lim >> 16);
    segdesc.sd_avl = 0;
    segdesc.sd_l = 0;
    segdesc.sd_db = 1;
    segdesc.sd_g = 1;
    segdesc.sd_base_31_24 = (uint16_t)(base >> 24);
c01018b5:	c1 eb 18             	shr    $0x18,%ebx
c01018b8:	88 58 07             	mov    %bl,0x7(%eax)
    segdesc.sd_type = type;
c01018bb:	80 e2 f0             	and    $0xf0,%dl
c01018be:	08 ca                	or     %cl,%dl
    segdesc.sd_dpl = dpl;
c01018c0:	8a 4d 18             	mov    0x18(%ebp),%cl
    segdesc.sd_s = 1;
c01018c3:	80 ca 10             	or     $0x10,%dl
    segdesc.sd_dpl = dpl;
c01018c6:	80 e2 9f             	and    $0x9f,%dl
c01018c9:	80 e1 03             	and    $0x3,%cl
c01018cc:	c0 e1 05             	shl    $0x5,%cl
c01018cf:	08 ca                	or     %cl,%dl
    segdesc.sd_p = 1;
c01018d1:	80 ca 80             	or     $0x80,%dl
c01018d4:	88 50 05             	mov    %dl,0x5(%eax)
    segdesc.sd_lim_19_16 = (uint16_t)(lim >> 16);
c01018d7:	8b 55 14             	mov    0x14(%ebp),%edx
c01018da:	c1 ea 10             	shr    $0x10,%edx
c01018dd:	80 e2 0f             	and    $0xf,%dl
    segdesc.sd_g = 1;
c01018e0:	80 ca c0             	or     $0xc0,%dl
c01018e3:	88 50 06             	mov    %dl,0x6(%eax)
}
c01018e6:	5b                   	pop    %ebx
c01018e7:	5d                   	pop    %ebp
c01018e8:	c3                   	ret    
c01018e9:	90                   	nop

c01018ea <_ZN3MMU11setGateDescERNS_8GateDescEjjjj>:

void MMU::setGateDesc(GateDesc &gate, uint32_t istrap, uint32_t sel, uint32_t off, uint32_t dpl) {
c01018ea:	55                   	push   %ebp
c01018eb:	89 e5                	mov    %esp,%ebp
c01018ed:	8b 55 14             	mov    0x14(%ebp),%edx
c01018f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01018f3:	53                   	push   %ebx
    gate.gd_ss = (sel);
    gate.gd_args = 0;                                    
    gate.gd_rsv1 = 0;                                    
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
    gate.gd_s = 0;                                    
    gate.gd_dpl = (dpl);                               
c01018f4:	8a 5d 18             	mov    0x18(%ebp),%bl
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c01018f7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
c01018fb:	0f b7 ca             	movzwl %dx,%ecx
c01018fe:	88 08                	mov    %cl,(%eax)
c0101900:	88 68 01             	mov    %ch,0x1(%eax)
    gate.gd_ss = (sel);
c0101903:	0f b7 4d 10          	movzwl 0x10(%ebp),%ecx
    gate.gd_args = 0;                                    
c0101907:	c6 40 04 00          	movb   $0x0,0x4(%eax)
    gate.gd_ss = (sel);
c010190b:	88 48 02             	mov    %cl,0x2(%eax)
c010190e:	88 68 03             	mov    %ch,0x3(%eax)
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c0101911:	0f 95 c1             	setne  %cl
    gate.gd_dpl = (dpl);                               
c0101914:	80 e3 03             	and    $0x3,%bl
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c0101917:	80 c1 0e             	add    $0xe,%cl
    gate.gd_dpl = (dpl);                               
c010191a:	c0 e3 05             	shl    $0x5,%bl
    gate.gd_type = (istrap) ? STS_TG32 : STS_IG32;    
c010191d:	80 e1 0f             	and    $0xf,%cl
    gate.gd_dpl = (dpl);                               
c0101920:	08 d9                	or     %bl,%cl
    gate.gd_p = 1;                                    
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;        
c0101922:	c1 ea 10             	shr    $0x10,%edx
    gate.gd_p = 1;                                    
c0101925:	80 c9 80             	or     $0x80,%cl
c0101928:	88 48 05             	mov    %cl,0x5(%eax)
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;        
c010192b:	88 50 06             	mov    %dl,0x6(%eax)
c010192e:	88 70 07             	mov    %dh,0x7(%eax)
}
c0101931:	5b                   	pop    %ebx
c0101932:	5d                   	pop    %ebp
c0101933:	c3                   	ret    

c0101934 <_ZN3MMU11setCallGateERNS_8GateDescEjjj>:

void MMU::setCallGate(GateDesc &gate, uint32_t ss, uint32_t off, uint32_t dpl) {
c0101934:	55                   	push   %ebp
c0101935:	89 e5                	mov    %esp,%ebp
c0101937:	8b 4d 10             	mov    0x10(%ebp),%ecx
c010193a:	8b 45 08             	mov    0x8(%ebp),%eax
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
c010193d:	0f b7 d1             	movzwl %cx,%edx
c0101940:	88 10                	mov    %dl,(%eax)
    gate.gd_rsv1 = 0;                                  
    gate.gd_type = STS_CG32;                          
    gate.gd_s = 0;                                   
    gate.gd_dpl = (dpl);                              
    gate.gd_p = 1;                                  
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;     
c0101942:	c1 e9 10             	shr    $0x10,%ecx
    gate.gd_off_15_0 = (uint32_t)(off) & 0xffff;        
c0101945:	88 70 01             	mov    %dh,0x1(%eax)
    gate.gd_ss = (ss);                                
c0101948:	0f b7 55 0c          	movzwl 0xc(%ebp),%edx
    gate.gd_rsv1 = 0;                                  
c010194c:	c6 40 04 00          	movb   $0x0,0x4(%eax)
    gate.gd_off_31_16 = (uint32_t)(off) >> 16;     
c0101950:	88 48 06             	mov    %cl,0x6(%eax)
c0101953:	88 68 07             	mov    %ch,0x7(%eax)
    gate.gd_ss = (ss);                                
c0101956:	88 50 02             	mov    %dl,0x2(%eax)
c0101959:	88 70 03             	mov    %dh,0x3(%eax)
    gate.gd_dpl = (dpl);                              
c010195c:	8a 55 14             	mov    0x14(%ebp),%dl
c010195f:	80 e2 03             	and    $0x3,%dl
c0101962:	c0 e2 05             	shl    $0x5,%dl
    gate.gd_p = 1;                                  
c0101965:	80 ca 8c             	or     $0x8c,%dl
c0101968:	88 50 05             	mov    %dl,0x5(%eax)
}
c010196b:	5d                   	pop    %ebp
c010196c:	c3                   	ret    
c010196d:	90                   	nop

c010196e <_ZN3MMU6setTCBEv>:

void MMU::setTCB() {
c010196e:	55                   	push   %ebp
c010196f:	89 e5                	mov    %esp,%ebp

}
c0101971:	5d                   	pop    %ebp
c0101972:	c3                   	ret    
c0101973:	90                   	nop

c0101974 <_ZN3MMU15SetPageReservedEPNS_4PageE>:

void MMU::SetPageReserved(Page *p) {
c0101974:	55                   	push   %ebp
c0101975:	89 e5                	mov    %esp,%ebp
c0101977:	8b 45 0c             	mov    0xc(%ebp),%eax
    p->status |= 0x1;
c010197a:	80 48 04 01          	orb    $0x1,0x4(%eax)
c010197e:	5d                   	pop    %ebp
c010197f:	c3                   	ret    

c0101980 <_ZN4Trap4trapEv>:
#include <trap.h>

void Trap::trap() {
c0101980:	55                   	push   %ebp
c0101981:	89 e5                	mov    %esp,%ebp

c0101983:	5d                   	pop    %ebp
c0101984:	c3                   	ret    
c0101985:	90                   	nop

c0101986 <_ZN6String7cStrLenEPKc>:
 * @Last Modified time: 2020-03-25 19:21:46 
 */

#include <string.h>

uint32_t String::cStrLen(ccstring cstr) {
c0101986:	55                   	push   %ebp
    uint32_t len = 0;
c0101987:	31 c0                	xor    %eax,%eax
uint32_t String::cStrLen(ccstring cstr) {
c0101989:	89 e5                	mov    %esp,%ebp
c010198b:	8b 55 0c             	mov    0xc(%ebp),%edx
    auto it = cstr;
    while(*it++ != '\0') {
c010198e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
c0101992:	74 03                	je     c0101997 <_ZN6String7cStrLenEPKc+0x11>
        len++;
c0101994:	40                   	inc    %eax
    while(*it++ != '\0') {
c0101995:	eb f7                	jmp    c010198e <_ZN6String7cStrLenEPKc+0x8>
    }
    return len;
}
c0101997:	5d                   	pop    %ebp
c0101998:	c3                   	ret    
c0101999:	90                   	nop

c010199a <_ZN6StringC1EPKc>:


String::String(ccstring cstr) {
c010199a:	55                   	push   %ebp
c010199b:	89 e5                	mov    %esp,%ebp
c010199d:	8b 4d 08             	mov    0x8(%ebp),%ecx
c01019a0:	8b 45 0c             	mov    0xc(%ebp),%eax
    str = (cstring)cstr;
c01019a3:	89 01                	mov    %eax,(%ecx)
    length = cStrLen(cstr);
c01019a5:	50                   	push   %eax
c01019a6:	51                   	push   %ecx
c01019a7:	e8 da ff ff ff       	call   c0101986 <_ZN6String7cStrLenEPKc>
c01019ac:	5a                   	pop    %edx
c01019ad:	5a                   	pop    %edx
c01019ae:	88 41 04             	mov    %al,0x4(%ecx)
}
c01019b1:	c9                   	leave  
c01019b2:	c3                   	ret    
c01019b3:	90                   	nop

c01019b4 <_ZN6StringD1Ev>:


String::~String() {                                     //destructor
c01019b4:	55                   	push   %ebp
c01019b5:	89 e5                	mov    %esp,%ebp

}
c01019b7:	5d                   	pop    %ebp
c01019b8:	c3                   	ret    
c01019b9:	90                   	nop

c01019ba <_ZN6StringaSEPKc>:


String & String::operator=(ccstring cstr) {             // copy assigment
c01019ba:	55                   	push   %ebp
c01019bb:	89 e5                	mov    %esp,%ebp
c01019bd:	56                   	push   %esi
c01019be:	8b 4d 08             	mov    0x8(%ebp),%ecx
c01019c1:	53                   	push   %ebx
c01019c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    length = cStrLen(cstr);
c01019c5:	53                   	push   %ebx
c01019c6:	51                   	push   %ecx
c01019c7:	e8 ba ff ff ff       	call   c0101986 <_ZN6String7cStrLenEPKc>
c01019cc:	5a                   	pop    %edx
c01019cd:	5e                   	pop    %esi
c01019ce:	88 41 04             	mov    %al,0x4(%ecx)
    //delete [] str;
    //str = new char[length];
    for (uint32_t i = 0; i < length; i++) {
c01019d1:	31 c0                	xor    %eax,%eax
c01019d3:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
c01019d7:	39 c2                	cmp    %eax,%edx
c01019d9:	76 0b                	jbe    c01019e6 <_ZN6StringaSEPKc+0x2c>
        str[i] = cstr[i];
c01019db:	8a 14 03             	mov    (%ebx,%eax,1),%dl
c01019de:	8b 31                	mov    (%ecx),%esi
c01019e0:	88 14 06             	mov    %dl,(%esi,%eax,1)
    for (uint32_t i = 0; i < length; i++) {
c01019e3:	40                   	inc    %eax
c01019e4:	eb ed                	jmp    c01019d3 <_ZN6StringaSEPKc+0x19>
    }
    return *this;
}
c01019e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
c01019e9:	89 c8                	mov    %ecx,%eax
c01019eb:	5b                   	pop    %ebx
c01019ec:	5e                   	pop    %esi
c01019ed:	5d                   	pop    %ebp
c01019ee:	c3                   	ret    
c01019ef:	90                   	nop

c01019f0 <_ZNK6String4cStrEv>:

ccstring String::cStr() const {
c01019f0:	55                   	push   %ebp
c01019f1:	89 e5                	mov    %esp,%ebp
    return str;
c01019f3:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01019f6:	5d                   	pop    %ebp
    return str;
c01019f7:	8b 00                	mov    (%eax),%eax
}
c01019f9:	c3                   	ret    

c01019fa <_ZNK6String9getLengthEv>:

uint8_t String::getLength() const {
c01019fa:	55                   	push   %ebp
c01019fb:	89 e5                	mov    %esp,%ebp
    return length;
c01019fd:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0101a00:	5d                   	pop    %ebp
    return length;
c0101a01:	8a 40 04             	mov    0x4(%eax),%al
}
c0101a04:	c3                   	ret    
c0101a05:	90                   	nop

c0101a06 <_ZN6StringeqERKS_>:

bool String::operator==(const String &_str) {
c0101a06:	55                   	push   %ebp
    bool isEquals = false;
c0101a07:	31 c0                	xor    %eax,%eax
bool String::operator==(const String &_str) {
c0101a09:	89 e5                	mov    %esp,%ebp
c0101a0b:	57                   	push   %edi
c0101a0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0101a0f:	56                   	push   %esi
c0101a10:	53                   	push   %ebx
c0101a11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
    if (_str.length == length) {
c0101a14:	8a 53 04             	mov    0x4(%ebx),%dl
c0101a17:	3a 51 04             	cmp    0x4(%ecx),%dl
c0101a1a:	75 1e                	jne    c0101a3a <_ZN6StringeqERKS_+0x34>
        for (uint32_t i = 0; i < length; i++) {
c0101a1c:	31 c0                	xor    %eax,%eax
c0101a1e:	0f b6 fa             	movzbl %dl,%edi
c0101a21:	39 c7                	cmp    %eax,%edi
c0101a23:	76 0f                	jbe    c0101a34 <_ZN6StringeqERKS_+0x2e>
            if (str[i] != (_str.str)[i]) {
c0101a25:	8b 13                	mov    (%ebx),%edx
c0101a27:	8b 31                	mov    (%ecx),%esi
c0101a29:	8a 14 02             	mov    (%edx,%eax,1),%dl
c0101a2c:	38 14 06             	cmp    %dl,(%esi,%eax,1)
c0101a2f:	75 07                	jne    c0101a38 <_ZN6StringeqERKS_+0x32>
        for (uint32_t i = 0; i < length; i++) {
c0101a31:	40                   	inc    %eax
c0101a32:	eb ed                	jmp    c0101a21 <_ZN6StringeqERKS_+0x1b>
                return false;
            }
        }
        isEquals = true;
c0101a34:	b0 01                	mov    $0x1,%al
c0101a36:	eb 02                	jmp    c0101a3a <_ZN6StringeqERKS_+0x34>
    bool isEquals = false;
c0101a38:	31 c0                	xor    %eax,%eax
    }
    return isEquals;
}
c0101a3a:	5b                   	pop    %ebx
c0101a3b:	5e                   	pop    %esi
c0101a3c:	5f                   	pop    %edi
c0101a3d:	5d                   	pop    %ebp
c0101a3e:	c3                   	ret    
c0101a3f:	90                   	nop

c0101a40 <_ZN6StringixEj>:

// index accessor
char & String::operator[](const uint32_t index) {
c0101a40:	55                   	push   %ebp
c0101a41:	89 e5                	mov    %esp,%ebp
    return str[index];
c0101a43:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a46:	8b 00                	mov    (%eax),%eax
c0101a48:	03 45 0c             	add    0xc(%ebp),%eax
}
c0101a4b:	5d                   	pop    %ebp
c0101a4c:	c3                   	ret    
