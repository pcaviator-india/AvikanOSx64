/*------------------------------------------------------
  pic.c - Programmable Interrupt Controller (PIC)
  ------------------------------------------------------*/
#include "pic.h"

/* PIC I/O ports */
#define PIC1_COMMAND 0x20    /* Master PIC command port */
#define PIC1_DATA    0x21    /* Master PIC data port */
#define PIC2_COMMAND 0xA0    /* Slave PIC command port */
#define PIC2_DATA    0xA1    /* Slave PIC data port */

/* ICW1: Start initialization */
#define ICW1_INIT 0x10       /* Bit 4: ICW1 needed */
/* ICW4: Mode */
#define ICW4_8086 0x01       /* Bit 0: 8086/88 mode */

/* Port I/O */
static inline void outb(unsigned short port, unsigned char val) {
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline unsigned char inb(unsigned short port) {
    unsigned char val;
    __asm__ volatile ("inb %1, %0" : "=a"(val) : "Nd"(port));
    return val;
}

/* Remap PIC interrupts to start at 0x20 */
void pic_init(void) {
    unsigned char mask1, mask2;

    /* Save current interrupt masks */
    mask1 = inb(PIC1_DATA);
    mask2 = inb(PIC2_DATA);

    /* Start initialization sequence */
    outb(PIC1_COMMAND, ICW1_INIT);
    outb(PIC2_COMMAND, ICW1_INIT);

    /* Set vector offsets: IRQ0-7 -> INT 0x20-0x27, IRQ8-15 -> INT 0x28-0x2F */
    outb(PIC1_DATA, 0x20);
    outb(PIC2_DATA, 0x28);

    /* Configure cascade identity */
    outb(PIC1_DATA, 0x04);   /* Master has slave at IRQ2 */
    outb(PIC2_DATA, 0x02);   /* Slave's cascade identity */

    /* Set 8086 mode */
    outb(PIC1_DATA, ICW4_8086);
    outb(PIC2_DATA, ICW4_8086);

    /* Restore saved masks (mask all interrupts initially) */
    outb(PIC1_DATA, mask1);
    outb(PIC2_DATA, mask2);
}

/* Send EOI to PIC */
void pic_eoi(unsigned char irq) {
    /* If IRQ is from slave (8-15), send EOI to slave first */
    if (irq >= 8) {
        outb(PIC2_COMMAND, 0x20);
    }
    /* Always send EOI to master */
    outb(PIC1_COMMAND, 0x20);
}