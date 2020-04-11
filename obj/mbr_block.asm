
obj/mbr_block.o:     file format elf32-i386


Disassembly of section .startup:

00007c00 <start>:

.globl start
start:
.code16                                             # Assemble for 16-bit mode
    # init reg ss:sp and es
    movw %cs, %ax
    7c00:	8c c8                	mov    %cs,%eax
    movw %ax, %ss
    7c02:	8e d0                	mov    %eax,%ss
    movw %ax, %es
    7c04:	8e c0                	mov    %eax,%es
    movw $0x7C00, %sp
    7c06:	bc                   	.byte 0xbc
    7c07:	00                   	.byte 0x0
    7c08:	7c                   	.byte 0x7c

00007c09 <seta20>:
    
    # Enable A20 for access greater than 20bits of address
seta20:
    inb $0x92, %al                                   # south Bridge
    7c09:	e4 92                	in     $0x92,%al
    orb $SET_A20, %al
    7c0b:	0c 02                	or     $0x2,%al
    outb %al, $0x92
    7c0d:	e6 92                	out    %al,$0x92

    CLI                                              # close interrupt
    7c0f:	fa                   	cli    
    CLD                                              # String operations increment
    7c10:	fc                   	cld    

00007c11 <probe_memory>:
    
    # int 15 0xE820 -----> to Detect memory
probe_memory:
    movl $0, 0x8000
    7c11:	66 c7 06 00 80       	movw   $0x8000,(%esi)
    7c16:	00 00                	add    %al,(%eax)
    7c18:	00 00                	add    %al,(%eax)
    xorl %ebx, %ebx
    7c1a:	66 31 db             	xor    %bx,%bx
    movw $0x8004, %di
    7c1d:	bf                   	.byte 0xbf
    7c1e:	04 80                	add    $0x80,%al

00007c20 <start_probe>:
start_probe:
    movl $0xE820, %eax
    7c20:	66 b8 20 e8          	mov    $0xe820,%ax
    7c24:	00 00                	add    %al,(%eax)
    movl $20, %ecx
    7c26:	66 b9 14 00          	mov    $0x14,%cx
    7c2a:	00 00                	add    %al,(%eax)
    movl $SMAP, %edx
    7c2c:	66 ba 50 41          	mov    $0x4150,%dx
    7c30:	4d                   	dec    %ebp
    7c31:	53                   	push   %ebx
    int $0x15
    7c32:	cd 15                	int    $0x15
    jnc cont
    7c34:	73 08                	jae    7c3e <cont>
    movw $12345, 0x8000
    7c36:	c7 06 00 80 39 30    	movl   $0x30398000,(%esi)
    jmp finish_probe
    7c3c:	eb 0e                	jmp    7c4c <finish_probe>

00007c3e <cont>:
cont:
    addw $20, %di
    7c3e:	83 c7 14             	add    $0x14,%edi
    incl 0x8000
    7c41:	66 ff 06             	incw   (%esi)
    7c44:	00 80 66 83 fb 00    	add    %al,0xfb8366(%eax)
    cmpl $0, %ebx
    jnz start_probe
    7c4a:	75 d4                	jne    7c20 <start_probe>

00007c4c <finish_probe>:
finish_probe:

    # load gdt
    lgdt gdtdesc
    7c4c:	0f 01 16             	lgdtl  (%esi)
    7c4f:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    7c50:	7d 0f                	jge    7c61 <protcseg+0x1>

    # set PE bit into protected mode
    movl %cr0, %eax
    7c52:	20 c0                	and    %al,%al
    orl $SET_PE, %eax                               # set pe
    7c54:	66 83 c8 01          	or     $0x1,%ax
    movl %eax, %cr0 
    7c58:	0f 22 c0             	mov    %eax,%cr0

    ljmp $PROT_MODE_CSEG, $protcseg
    7c5b:	ea                   	.byte 0xea
    7c5c:	60                   	pusha  
    7c5d:	7c 08                	jl     7c67 <protcseg+0x7>
	...

00007c60 <protcseg>:

.code32                                             # Assemble for 32-bit mode
protcseg:
    # Set up the protected-mode data segment registers
    movw $PROT_MODE_DSEG, %ax                       # data segment selector
    7c60:	66 b8 10 00          	mov    $0x10,%ax
    movw %ax, %ds                                   # -> DS: Data Segment
    7c64:	8e d8                	mov    %eax,%ds
    movw %ax, %es                                   # -> ES: Extra Segment
    7c66:	8e c0                	mov    %eax,%es
    movw %ax, %fs                                   # -> FS
    7c68:	8e e0                	mov    %eax,%fs
    movw %ax, %gs                                   # -> GS
    7c6a:	8e e8                	mov    %eax,%gs
    movw %ax, %ss                                   # -> SS: Stack Segment
    7c6c:	8e d0                	mov    %eax,%ss

    # init stack segment --> 0x7c00 to 0
    movl $0x0, %ebp
    7c6e:	bd 00 00 00 00       	mov    $0x0,%ebp
    movl $0x7C00, %esp
    7c73:	bc 00 7c 00 00       	mov    $0x7c00,%esp
    call bootKernel
    7c78:	e8 6e 00 00 00       	call   7ceb <bootKernel>

Disassembly of section .text:

00007c7d <_ZL10readSectorjj>:
#define ELFHDR          ((Elf_Ehdr *)0x10000)
#define VMEMORY         ((uint16_t *)0xB8000)

static void
readSector(uptr32_t vaddr, uint32_t sec) {
    sec = (sec & 0x0FFFFFFF) | 0xE0000000;      // set LBA28 Mode 0xE(28 ~ 31)
    7c7d:	89 d1                	mov    %edx,%ecx
        : "memory", "cc");
}

static inline void
outb(uint8_t data, uint16_t port) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
    7c7f:	ba f2 01 00 00       	mov    $0x1f2,%edx
readSector(uptr32_t vaddr, uint32_t sec) {
    7c84:	55                   	push   %ebp
    sec = (sec & 0x0FFFFFFF) | 0xE0000000;      // set LBA28 Mode 0xE(28 ~ 31)
    7c85:	81 e1 ff ff ff 0f    	and    $0xfffffff,%ecx
readSector(uptr32_t vaddr, uint32_t sec) {
    7c8b:	89 e5                	mov    %esp,%ebp
    sec = (sec & 0x0FFFFFFF) | 0xE0000000;      // set LBA28 Mode 0xE(28 ~ 31)
    7c8d:	81 c9 00 00 00 e0    	or     $0xe0000000,%ecx
readSector(uptr32_t vaddr, uint32_t sec) {
    7c93:	53                   	push   %ebx
    7c94:	89 c3                	mov    %eax,%ebx
    7c96:	b0 01                	mov    $0x1,%al
    7c98:	ee                   	out    %al,(%dx)
    7c99:	ba f3 01 00 00       	mov    $0x1f3,%edx
    7c9e:	88 c8                	mov    %cl,%al
    7ca0:	ee                   	out    %al,(%dx)
    outb(1, 0x1F2);                             // count = 1
    
    for (uint32_t i = 0; i < 4; i++) {          // LAB28 Mode and LAB to prot
        outb(((sec >> (i * 8)) & 0xFF), 0x1F3 + i);
    7ca1:	89 c8                	mov    %ecx,%eax
    7ca3:	ba f4 01 00 00       	mov    $0x1f4,%edx
    7ca8:	c1 e8 08             	shr    $0x8,%eax
    7cab:	ee                   	out    %al,(%dx)
    7cac:	89 c8                	mov    %ecx,%eax
    7cae:	ba f5 01 00 00       	mov    $0x1f5,%edx
    7cb3:	c1 e8 10             	shr    $0x10,%eax
    7cb6:	ee                   	out    %al,(%dx)
    7cb7:	89 c8                	mov    %ecx,%eax
    7cb9:	ba f6 01 00 00       	mov    $0x1f6,%edx
    7cbe:	c1 e8 18             	shr    $0x18,%eax
    7cc1:	ee                   	out    %al,(%dx)
    7cc2:	b0 20                	mov    $0x20,%al
    7cc4:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7cc9:	ee                   	out    %al,(%dx)
     asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
    7cca:	ec                   	in     (%dx),%al
    }

    outb(0x20, 0x1F7);                          // cmd 0x20 - read sectors
    
    // check SBY and DRQ bit
    while ((inb(0x1F7) & 0x88) != 0x08);        // wait disk data and not busy
    7ccb:	24 88                	and    $0x88,%al
    7ccd:	3c 08                	cmp    $0x8,%al
    7ccf:	75 f9                	jne    7cca <_ZL10readSectorjj+0x4d>
    7cd1:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
    );
    7cd7:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7cdc:	50                   	push   %eax
    7cdd:	ed                   	in     (%dx),%eax
    7cde:	89 03                	mov    %eax,(%ebx)
    7ce0:	58                   	pop    %eax
    
    for (uint32_t i = 0; i < SECTSIZE / 4; i++) {    // read a sector
        inlToVAddr(0x1F0, vaddr);               //read 4byte from 0x1F0-Port to [vaddr]
        vaddr += 4;
    7ce1:	83 c3 04             	add    $0x4,%ebx
    for (uint32_t i = 0; i < SECTSIZE / 4; i++) {    // read a sector
    7ce4:	39 c3                	cmp    %eax,%ebx
    7ce6:	75 f4                	jne    7cdc <_ZL10readSectorjj+0x5f>
    }
}
    7ce8:	5b                   	pop    %ebx
    7ce9:	5d                   	pop    %ebp
    7cea:	c3                   	ret    

00007ceb <bootKernel>:
        readSector(vaddr, sec);
    }
}

extern "C" void     // extern "C" compiler by c-style, function name is not change.
bootKernel() {
    7ceb:	55                   	push   %ebp
    7cec:	89 e5                	mov    %esp,%ebp
    7cee:	57                   	push   %edi
    7cef:	56                   	push   %esi
    7cf0:	53                   	push   %ebx
    uint32_t sec = (offset / SECTSIZE) + 1;
    7cf1:	bb 01 00 00 00       	mov    $0x1,%ebx
bootKernel() {
    7cf6:	83 ec 1c             	sub    $0x1c,%esp
        readSector(vaddr, sec);
    7cf9:	8d 43 7f             	lea    0x7f(%ebx),%eax
    7cfc:	89 da                	mov    %ebx,%edx
    7cfe:	c1 e0 09             	shl    $0x9,%eax
    for (; vaddr < end_va; vaddr += SECTSIZE, sec++) {
    7d01:	43                   	inc    %ebx
        readSector(vaddr, sec);
    7d02:	e8 76 ff ff ff       	call   7c7d <_ZL10readSectorjj>
    for (; vaddr < end_va; vaddr += SECTSIZE, sec++) {
    7d07:	83 fb 09             	cmp    $0x9,%ebx
    7d0a:	75 ed                	jne    7cf9 <bootKernel+0xe>
    // read the 1st page off disk
    readSeg((uptr32_t)ELFHDR, SECTSIZE * 8, 0);

    // is this a valid ELF?
    if (ELFHDR->e_magic == ELF_MAGIC) {
    7d0c:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d13:	45 4c 46 
    7d16:	75 68                	jne    7d80 <bootKernel+0x95>
        
        Elf_Phdr *ph = nullptr;
        ph = (Elf_Phdr *)((uptr32_t)ELFHDR + ELFHDR->e_phoff);  // get program head table first address
    7d18:	a1 1c 00 01 00       	mov    0x1001c,%eax
        
        for (uint32_t i = 0; i < ELFHDR->e_phnum; i++, ph++) {  // laod segment of program
    7d1d:	31 ff                	xor    %edi,%edi
        ph = (Elf_Phdr *)((uptr32_t)ELFHDR + ELFHDR->e_phoff);  // get program head table first address
    7d1f:	05 00 00 01 00       	add    $0x10000,%eax
    7d24:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (uint32_t i = 0; i < ELFHDR->e_phnum; i++, ph++) {  // laod segment of program
    7d27:	0f b7 15 2c 00 01 00 	movzwl 0x1002c,%edx
    7d2e:	89 f8                	mov    %edi,%eax
    7d30:	c1 e0 05             	shl    $0x5,%eax
    7d33:	03 45 e4             	add    -0x1c(%ebp),%eax
    7d36:	39 fa                	cmp    %edi,%edx
    7d38:	76 3a                	jbe    7d74 <bootKernel+0x89>
            readSeg(ph->p_vaddr & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    7d3a:	8b 70 04             	mov    0x4(%eax),%esi
    7d3d:	8b 58 08             	mov    0x8(%eax),%ebx
    uptr32_t end_va = vaddr + count;
    7d40:	8b 48 14             	mov    0x14(%eax),%ecx
    vaddr -= offset % SECTSIZE;
    7d43:	89 f0                	mov    %esi,%eax
            readSeg(ph->p_vaddr & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    7d45:	81 e3 ff ff ff 00    	and    $0xffffff,%ebx
    vaddr -= offset % SECTSIZE;
    7d4b:	25 ff 01 00 00       	and    $0x1ff,%eax
    uptr32_t end_va = vaddr + count;
    7d50:	01 d9                	add    %ebx,%ecx
    vaddr -= offset % SECTSIZE;
    7d52:	29 c3                	sub    %eax,%ebx
    uptr32_t end_va = vaddr + count;
    7d54:	89 4d e0             	mov    %ecx,-0x20(%ebp)
    uint32_t sec = (offset / SECTSIZE) + 1;
    7d57:	c1 ee 09             	shr    $0x9,%esi
    7d5a:	46                   	inc    %esi
    for (; vaddr < end_va; vaddr += SECTSIZE, sec++) {
    7d5b:	39 5d e0             	cmp    %ebx,-0x20(%ebp)
    7d5e:	76 11                	jbe    7d71 <bootKernel+0x86>
        readSector(vaddr, sec);
    7d60:	89 d8                	mov    %ebx,%eax
    7d62:	89 f2                	mov    %esi,%edx
    7d64:	e8 14 ff ff ff       	call   7c7d <_ZL10readSectorjj>
    for (; vaddr < end_va; vaddr += SECTSIZE, sec++) {
    7d69:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7d6f:	eb e9                	jmp    7d5a <bootKernel+0x6f>
        for (uint32_t i = 0; i < ELFHDR->e_phnum; i++, ph++) {  // laod segment of program
    7d71:	47                   	inc    %edi
    7d72:	eb b3                	jmp    7d27 <bootKernel+0x3c>
        }
        // jmp kernel
        ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();
    7d74:	a1 18 00 01 00       	mov    0x10018,%eax
    7d79:	25 ff ff ff 00       	and    $0xffffff,%eax
    7d7e:	ff d0                	call   *%eax
    }

    // Error Info: E of red
    // byte: KRGB IRGB front : back 
    *VMEMORY = ((uint16_t)0b00000100 << 8) + 'E';
    7d80:	66 c7 05 00 80 0b 00 	movw   $0x445,0xb8000
    7d87:	45 04 
    7d89:	eb fe                	jmp    7d89 <bootKernel+0x9e>
