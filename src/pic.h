#ifndef AVIKAN_PIC_H
#define AVIKAN_PIC_H

/* Initialize the Programmable Interrupt Controller (PIC) */
/* Remaps IRQs to start at 0x20 to avoid CPU exception conflicts */
void pic_init(void);

/* Send End-Of-Interrupt to PIC */
void pic_eoi(unsigned char irq);

#endif /* AVIKAN_PIC_H */