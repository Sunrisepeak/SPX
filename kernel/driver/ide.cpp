#include <ide.h>
#include <x86.h>
#include <assert.h>
#include <flags.h>
#include <pic.h>
#include <trap.h>
#include <fs.h>
#include <string.h>
#include <ostream.h>

void IDE::init() {
    static_assert((SECTSIZE % 4) == 0);
    uint16_t ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno++) {
        /* assume that no device here */
        ideDevs[ideno].valid = 0;

        iobase = IO_BASE(ideno);

        /* wait device ready */
        waitReady(iobase);

        /* step1: select drive */
        outb(0xE0 | ((ideno & 1) << 4), iobase + ISA_SDH);
        waitReady(iobase);

        /* step2: send ATA identify command */
        outb(IDE_CMD_IDENTIFY, iobase + ISA_COMMAND);
        waitReady(iobase);

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || waitReady(iobase, true) != 0) {
            DEBUGPRINT("ide fail...");
            continue ;
        }

        /* device is ok */
        ideDevs[ideno].valid = 1;

        /* read identification space of the device */
        uint32_t buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));

        uchar8_t *ident = (uint8_t *)buffer;
        uint32_t sectors;
        uint32_t cmdsets = *(uint32_t *)(ident + IDE_IDENT_CMDSETS);
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
            sectors = *(uint32_t *)(ident + IDE_IDENT_MAX_LBA_EXT);
        }
        else {
            sectors = *(uint32_t *)(ident + IDE_IDENT_MAX_LBA);
        }
        ideDevs[ideno].sets = cmdsets;
        ideDevs[ideno].size = sectors;

        /* check if supports LBA */
        assert((*(uint16_t *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        uchar8_t *model = ideDevs[ideno].model, *data = ident + IDE_IDENT_MODEL;
        uint32_t i, length = 40;
        for (i = 0; i < length; i += 2) {
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
        } while (i -- > 0 && model[i] == ' ');

        OStream out("\nide", "blue");
        out.writeValue(ideno);
        out.write(": ");
        out.writeValue(ideDevs[ideno].size);
        out.write(", model: ");

        String temp((ccstring)(ideDevs[ideno].model)); 
        out.write(temp);

    }

    // enable ide interrupt
    PIC::enableIRQ(IRQ_IDE1);
    PIC::enableIRQ(IRQ_IDE2);
}

bool IDE::isValid(uint32_t ideno) {
    return ((ideno) >= 0) && ((ideno) < MAX_IDE) && (ideDevs[ideno].valid);
}

uint32_t IDE::waitReady(uint16_t iobase, bool check) {
    uint32_t r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
        /* nothing */;
    if (check && (r & (IDE_DF | IDE_ERR)) != 0) {
        return -1;
    }
    return 0;
}

uint32_t IDE::readSecs(uint16_t ideno, uint32_t secno, uptr32_t dst, uint32_t nsecs) {
    assert(nsecs <= MAX_NSECS && isValid(ideno));
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
    uint16_t iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);

    waitReady(iobase, 0);

    // generate interrupt
    outb(0, ioctrl + ISA_CTRL);
    outb(nsecs, iobase + ISA_SECCNT);
    outb(secno & 0xFF, iobase + ISA_SECTOR);
    outb((secno >> 8) & 0xFF, iobase + ISA_CYL_LO);
    outb((secno >> 16) & 0xFF, iobase + ISA_CYL_HI);
    outb(0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF), iobase + ISA_SDH);
    outb(IDE_CMD_READ, iobase + ISA_COMMAND);

    int ret = 0;
    for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
        if ((ret = waitReady(iobase, true)) != 0) {
            BREAKPOINT("Disk I/O: Read");
            break;
        }
        insl(iobase, (void *)dst, SECTSIZE / sizeof(uint32_t));
    }

    return ret;
}

uint32_t IDE::writeSecs(uint16_t ideno, uint32_t secno, uptr32_t src, uint32_t nsecs) {
    assert(nsecs <= MAX_NSECS && isValid(ideno));
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
    uint16_t iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);

    waitReady(iobase);

    // generate interrupt
    outb(0, ioctrl + ISA_CTRL);
    outb(nsecs, iobase + ISA_SECCNT);
    outb(secno & 0xFF, iobase + ISA_SECTOR);
    outb((secno >> 8) & 0xFF, iobase + ISA_CYL_LO);
    outb((secno >> 16) & 0xFF, iobase + ISA_CYL_HI);
    outb(0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF), iobase + ISA_SDH);
    outb(IDE_CMD_WRITE, iobase + ISA_COMMAND);

    int ret = 0;
    for (; nsecs > 0; nsecs--, src += SECTSIZE) {
        if ((ret = waitReady(iobase, true)) != 0) {
            BREAKPOINT("Disk I/O: Write");
            break;
        }
        outsl(iobase, (void *)src, SECTSIZE / sizeof(uint32_t));
    }

    return ret;
}

uint32_t IDE::devSize(uint16_t ideno) {
    if (isValid(ideno)) {
        return ideDevs[ideno].size;
    }
    return 0;
}



