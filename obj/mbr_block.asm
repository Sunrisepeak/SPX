
obj/mbr_block.o:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:

.globl start
start:
.code16                                             # Assemble for 16-bit mode
    # init reg ss:sp
    movw %cs, %ax
    7c00:	8c c8                	mov    %cs,%eax
    movw %ax, %ss
    7c02:	8e d0                	mov    %eax,%ss
    movw $0x7C00, %sp
    7c04:	bc 00 7c 0f 01       	mov    $0x10f7c00,%esp

    # load gdt
    lgdt gdtdesc
    7c09:	16                   	push   %ss
    7c0a:	58                   	pop    %eax
    7c0b:	7c                   	.byte 0x7c

00007c0c <seta20>:
    
    # Enable A20 for access greater than 20bits of address
seta20:
    inb $0x92, %al                                   # south Bridge
    7c0c:	e4 92                	in     $0x92,%al
    orb $SET_A20, %al
    7c0e:	0c 02                	or     $0x2,%al
    outb %al, $0x92
    7c10:	e6 92                	out    %al,$0x92

    CLI                                             # close interrupt
    7c12:	fa                   	cli    
    
    # set PE bit into protected mode
    movl %cr0, %eax
    7c13:	0f 20 c0             	mov    %cr0,%eax
    orl $SET_PE, %eax                              # set pe
    7c16:	66 83 c8 01          	or     $0x1,%ax
    movl %eax, %cr0 
    7c1a:	0f 22 c0             	mov    %eax,%cr0

    ljmp $PROT_MODE_CSEG, $protcseg
    7c1d:	ea                   	.byte 0xea
    7c1e:	22 7c 08 00          	and    0x0(%eax,%ecx,1),%bh

00007c22 <protcseg>:

.code32                                             # Assemble for 32-bit mode
protcseg:
    # Set up the protected-mode data segment registers
    movw $PROT_MODE_DSEG, %ax                      # data segment selector
    7c22:	66 b8 10 00          	mov    $0x10,%ax
    movw %ax, %ds                                   # -> DS: Data Segment
    7c26:	8e d8                	mov    %eax,%ds
    movw %ax, %es                                   # -> ES: Extra Segment
    7c28:	8e c0                	mov    %eax,%es
    movw %ax, %fs                                   # -> FS
    7c2a:	8e e0                	mov    %eax,%fs
    movw %ax, %gs                                   # -> GS
    7c2c:	8e e8                	mov    %eax,%gs
    movw %ax, %ss                                   # -> SS: Stack Segment
    7c2e:	8e d0                	mov    %eax,%ss

    # init stack segment --> 0x7c00 to 0
    movl $0x0, %ebp
    7c30:	bd 00 00 00 00       	mov    $0x0,%ebp
    movl $0x7C00, %esp
    7c35:	bc 00 7c 00 00       	mov    $0x7c00,%esp
    call bootKernel
    7c3a:	e8 8d 00 00 00       	call   7ccc <bootKernel>
    7c3f:	90                   	nop

00007c40 <gdt>:
	...
    7c48:	ff                   	(bad)  
    7c49:	ff 00                	incl   (%eax)
    7c4b:	00 00                	add    %al,(%eax)
    7c4d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c54:	00                   	.byte 0x0
    7c55:	92                   	xchg   %eax,%edx
    7c56:	cf                   	iret   
	...

00007c58 <gdtdesc>:
    7c58:	17                   	pop    %ss
    7c59:	00 40 7c             	add    %al,0x7c(%eax)
	...

00007c5e <_ZL10readSectorjj>:
#define ELFHDR          ((Elf_Ehdr *)0x10000)
#define VMEMORY         ((uint16_t *)0xB8000)

static void
readSector(uptr32_t vaddr, uint32_t sec) {
    sec = (sec & 0x0FFFFFFF) | 0xE0000000;      // set LBA28 Mode 0xE(28 ~ 31)
    7c5e:	89 d1                	mov    %edx,%ecx
    );
}

static inline void
outb(uint8_t data, uint16_t port) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
    7c60:	ba f2 01 00 00       	mov    $0x1f2,%edx
readSector(uptr32_t vaddr, uint32_t sec) {
    7c65:	55                   	push   %ebp
    sec = (sec & 0x0FFFFFFF) | 0xE0000000;      // set LBA28 Mode 0xE(28 ~ 31)
    7c66:	81 e1 ff ff ff 0f    	and    $0xfffffff,%ecx
readSector(uptr32_t vaddr, uint32_t sec) {
    7c6c:	89 e5                	mov    %esp,%ebp
    sec = (sec & 0x0FFFFFFF) | 0xE0000000;      // set LBA28 Mode 0xE(28 ~ 31)
    7c6e:	81 c9 00 00 00 e0    	or     $0xe0000000,%ecx
readSector(uptr32_t vaddr, uint32_t sec) {
    7c74:	53                   	push   %ebx
    7c75:	89 c3                	mov    %eax,%ebx
    7c77:	b0 01                	mov    $0x1,%al
    7c79:	ee                   	out    %al,(%dx)
    7c7a:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7c7f:	88 c8                	mov    %cl,%al
    7c81:	ee                   	out    %al,(%dx)
    outb(1, 0x1F2);                             // count = 1
    
    for (uint32_t i = 0; i < 4; i++) {          // LAB28 Mode and LAB to prot
        outb(((sec >> (i * 8)) & 0xFF), 0x1F3 + i);
    7c82:	89 c8                	mov    %ecx,%eax
    7c84:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7c89:	c1 e8 08             	shr    $0x8,%eax
    7c8c:	ee                   	out    %al,(%dx)
    7c8d:	89 c8                	mov    %ecx,%eax
    7c8f:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7c94:	c1 e8 10             	shr    $0x10,%eax
    7c97:	ee                   	out    %al,(%dx)
    7c98:	89 c8                	mov    %ecx,%eax
    7c9a:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7c9f:	c1 e8 18             	shr    $0x18,%eax
    7ca2:	ee                   	out    %al,(%dx)
    7ca3:	b0 20                	mov    $0x20,%al
    7ca5:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7caa:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
    7cab:	ec                   	in     (%dx),%al
    }

    outb(0x20, 0x1F7);                          // cmd 0x20 - read sectors
    
    // check SBY and DRQ bit
    while ((inb(0x1F7) & 0x88) != 0x08);        // wait disk data and not busy
    7cac:	24 88                	and    $0x88,%al
    7cae:	3c 08                	cmp    $0x8,%al
    7cb0:	75 f9                	jne    7cab <_ZL10readSectorjj+0x4d>
    7cb2:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
    );
    7cb8:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cbd:	50                   	push   %eax
    7cbe:	ed                   	in     (%dx),%eax
    7cbf:	89 03                	mov    %eax,(%ebx)
    7cc1:	58                   	pop    %eax
    
    for (uint32_t i = 0; i < SECTSIZE / 4; i++) {    // read a sector
        inlToVAddr(0x1F0, vaddr);               //read 4byte from 0x1F0-Port to [vaddr]
        vaddr += 4;
    7cc2:	83 c3 04             	add    $0x4,%ebx
    for (uint32_t i = 0; i < SECTSIZE / 4; i++) {    // read a sector
    7cc5:	39 c3                	cmp    %eax,%ebx
    7cc7:	75 f4                	jne    7cbd <_ZL10readSectorjj+0x5f>
    }
}
    7cc9:	5b                   	pop    %ebx
    7cca:	5d                   	pop    %ebp
    7ccb:	c3                   	ret    

00007ccc <bootKernel>:
        readSector(vaddr, sec);
    }
}

extern "C" void     // extern "C" compiler by c-style, function name is not change.
bootKernel() {
    7ccc:	55                   	push   %ebp
    7ccd:	89 e5                	mov    %esp,%ebp
    7ccf:	57                   	push   %edi
    7cd0:	56                   	push   %esi
    7cd1:	53                   	push   %ebx
    uint32_t sec = (offset / SECTSIZE) + 1;
    7cd2:	bb 01 00 00 00       	mov    $0x1,%ebx
bootKernel() {
    7cd7:	83 ec 1c             	sub    $0x1c,%esp
        readSector(vaddr, sec);
    7cda:	8d 43 7f             	lea    0x7f(%ebx),%eax
    7cdd:	89 da                	mov    %ebx,%edx
    7cdf:	c1 e0 09             	shl    $0x9,%eax
    for (; vaddr < end_va; vaddr += SECTSIZE, sec++) {
    7ce2:	43                   	inc    %ebx
        readSector(vaddr, sec);
    7ce3:	e8 76 ff ff ff       	call   7c5e <_ZL10readSectorjj>
    for (; vaddr < end_va; vaddr += SECTSIZE, sec++) {
    7ce8:	83 fb 09             	cmp    $0x9,%ebx
    7ceb:	75 ed                	jne    7cda <bootKernel+0xe>
    // read the 1st page off disk
    readSeg((uptr32_t)ELFHDR, SECTSIZE * 8, 0);

    // is this a valid ELF?
    if (ELFHDR->e_magic == ELF_MAGIC) {
    7ced:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7cf4:	45 4c 46 
    7cf7:	75 68                	jne    7d61 <bootKernel+0x95>
        
        Elf_Phdr *ph = nullptr;
        ph = (Elf_Phdr *)((uptr32_t)ELFHDR + ELFHDR->e_phoff);  // get program head table first address
    7cf9:	a1 1c 00 01 00       	mov    0x1001c,%eax
        
        for (uint32_t i = 0; i < ELFHDR->e_phnum; i++, ph++) {  // laod segment of program
    7cfe:	31 ff                	xor    %edi,%edi
        ph = (Elf_Phdr *)((uptr32_t)ELFHDR + ELFHDR->e_phoff);  // get program head table first address
    7d00:	05 00 00 01 00       	add    $0x10000,%eax
    7d05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (uint32_t i = 0; i < ELFHDR->e_phnum; i++, ph++) {  // laod segment of program
    7d08:	0f b7 15 2c 00 01 00 	movzwl 0x1002c,%edx
    7d0f:	89 f8                	mov    %edi,%eax
    7d11:	c1 e0 05             	shl    $0x5,%eax
    7d14:	03 45 e4             	add    -0x1c(%ebp),%eax
    7d17:	39 fa                	cmp    %edi,%edx
    7d19:	76 3a                	jbe    7d55 <bootKernel+0x89>
            readSeg(ph->p_vaddr & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    7d1b:	8b 70 04             	mov    0x4(%eax),%esi
    7d1e:	8b 58 08             	mov    0x8(%eax),%ebx
    uptr32_t end_va = vaddr + count;
    7d21:	8b 48 14             	mov    0x14(%eax),%ecx
    vaddr -= offset % SECTSIZE;
    7d24:	89 f0                	mov    %esi,%eax
            readSeg(ph->p_vaddr & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    7d26:	81 e3 ff ff ff 00    	and    $0xffffff,%ebx
    vaddr -= offset % SECTSIZE;
    7d2c:	25 ff 01 00 00       	and    $0x1ff,%eax
    uptr32_t end_va = vaddr + count;
    7d31:	01 d9                	add    %ebx,%ecx
    vaddr -= offset % SECTSIZE;
    7d33:	29 c3                	sub    %eax,%ebx
    uptr32_t end_va = vaddr + count;
    7d35:	89 4d e0             	mov    %ecx,-0x20(%ebp)
    uint32_t sec = (offset / SECTSIZE) + 1;
    7d38:	c1 ee 09             	shr    $0x9,%esi
    7d3b:	46                   	inc    %esi
    for (; vaddr < end_va; vaddr += SECTSIZE, sec++) {
    7d3c:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
    7d3f:	76 11                	jbe    7d52 <bootKernel+0x86>
        readSector(vaddr, sec);
    7d41:	89 d8                	mov    %ebx,%eax
    7d43:	89 f2                	mov    %esi,%edx
    7d45:	e8 14 ff ff ff       	call   7c5e <_ZL10readSectorjj>
    for (; vaddr < end_va; vaddr += SECTSIZE, sec++) {
    7d4a:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7d50:	eb e9                	jmp    7d3b <bootKernel+0x6f>
        for (uint32_t i = 0; i < ELFHDR->e_phnum; i++, ph++) {  // laod segment of program
    7d52:	47                   	inc    %edi
    7d53:	eb b3                	jmp    7d08 <bootKernel+0x3c>
        }
        // jmp kernel
        ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();
    7d55:	a1 18 00 01 00       	mov    0x10018,%eax
    7d5a:	25 ff ff ff 00       	and    $0xffffff,%eax
    7d5f:	ff d0                	call   *%eax
    }

    // Error Info: E of red
    // byte: KRGB IRGB front : back 
    *VMEMORY = ((uint16_t)0b00000100 << 8) + 'E';
    7d61:	66 c7 05 00 80 0b 00 	movw   $0x445,0xb8000
    7d68:	45 04 
    7d6a:	eb fe                	jmp    7d6a <bootKernel+0x9e>
