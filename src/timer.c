/*------------------------------------------------------
  timer.c - Programmable Interval Timer (PIT)
  ------------------------------------------------------*/
#include "timer.h"
#include "idt.h"

/* PIT channel 0 data port is at 0x40 */
#define PIT_CHANNEL0 0x40

/* PIT frequency - 1193180 Hz (1.19 MHz) */
#define PIT_FREQ 1193180

/* Counter for timer ticks */
static volatile int timer_ticks = 0;

/* Port I/O */
static inline void outb(unsigned short port, unsigned char val) {
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

/* Handle IRQ0 (timer interrupt) - called from assembly wrapper */
void irq0_handler_c(void) {
    timer_ticks++;
    /* Send EOI to PIC */
    outb(0x20, 0x20);
}

/* Forward declaration - ISR wrapper defined in entry.asm */
extern void irq0_wrapper(void);

/* Forward declaration */
void idt_set_gate(unsigned char num, unsigned long long base, unsigned short selector, unsigned char flags);

/* Initialize the PIT to generate interrupts at 100Hz */
void timer_init(void) {
    /* Calculate divisor for 100Hz (10ms ticks) */
    unsigned long divisor = PIT_FREQ / 100;

    /* Send the divisor to PIT channel 0 */
    /* Low byte first, then high byte */
    outb(PIT_CHANNEL0, (unsigned char)(divisor & 0xFF));
    outb(PIT_CHANNEL0, (unsigned char)((divisor >> 8) & 0xFF));

    /* Set gate in IDT for IRQ0 - use assembly wrapper, not C function directly */
    idt_set_gate(0x20, (unsigned long long)irq0_wrapper, 0x08, 0x8E);
}