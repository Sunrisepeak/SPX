/*
 * @Author: SPeak Shen 
 * @Date: 2020-03-19 21:21:17 
 * @Last Modified by: SPeak Shen
 * @Last Modified time: 2020-04-03 19:25:53
 */

#include <asm.h>

#   defualt selector of in protected mode
.set PROT_MODE_CSEG,         0x8                     # kernel and bootloader CS selector
.set PROT_MODE_DSEG,         0x10                    # kernel and bootloader DS selector

.set SET_CR0_PE,             0x1                     # protected mode enable flag
.set SET_A20,                0x2                     # A20 Enable
.set SET_PE,                 0x1                     # set cr0 PE
.set SMAP,                   0x534d4150

.globl start
start:
.code16                                             # Assemble for 16-bit mode
    # init reg ss:sp and es
    movw %cs, %ax
    movw %ax, %ss
    movw %ax, %es
    movw $0x7C00, %sp
    
    # Enable A20 for access greater than 20bits of address
seta20:
    inb $0x92, %al                                   # south Bridge
    orb $SET_A20, %al
    outb %al, $0x92

    CLI                                              # close interrupt
    CLD                                              # String operations increment
    
    # int 15 0xE820 -----> to Detect memory
probe_memory:
    movl $0, 0x8000
    xorl %ebx, %ebx
    movw $0x8004, %di
start_probe:
    movl $0xE820, %eax
    movl $20, %ecx
    movl $SMAP, %edx
    int $0x15
    jnc cont
    movw $12345, 0x8000
    jmp finish_probe
cont:
    addw $20, %di
    incl 0x8000
    cmpl $0, %ebx
    jnz start_probe
finish_probe:

    # load gdt
    lgdt gdtdesc

    # set PE bit into protected mode
    movl %cr0, %eax
    orl $SET_PE, %eax                               # set pe
    movl %eax, %cr0 

    ljmp $PROT_MODE_CSEG, $protcseg

.code32                                             # Assemble for 32-bit mode
protcseg:
    # Set up the protected-mode data segment registers
    movw $PROT_MODE_DSEG, %ax                       # data segment selector
    movw %ax, %ds                                   # -> DS: Data Segment
    movw %ax, %es                                   # -> ES: Extra Segment
    movw %ax, %fs                                   # -> FS
    movw %ax, %gs                                   # -> GS
    movw %ax, %ss                                   # -> SS: Stack Segment

    # init stack segment --> 0x7c00 to 0
    movl $0x0, %ebp
    movl $0x7C00, %esp
    call bootKernel

.data
# Bootstrap GDT
.p2align 2                                          # force 4 byte alignment
gdt:
    SEG_DESC_NULL                                   # null seg(necessary)
    SEG_DESC(STA_E_R, 0x0, 0xFFFFF)                 # code seg for bootloader and kernel
    SEG_DESC(STA_RW, 0x0, 0xFFFFF)                  # data seg for bootloader and kernel

gdtdesc:
    .word 0x17                                      # sizeof(gdt) - 1
    .long gdt                                       # address gdt
