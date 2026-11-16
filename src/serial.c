/*------------------------------------------------------
  serial.c - Serial Port Output (COM1)
  ------------------------------------------------------*/
#include "serial.h"

#define COM1 0x3F8

static inline void outb(unsigned short port, unsigned char val) {
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static inline unsigned char inb(unsigned short port) {
    unsigned char val;
    __asm__ volatile ("inb %1, %0" : "=a"(val) : "Nd"(port));
    return val;
}

void serial_init(void) {
    outb(COM1 + 1, 0x00);    /* Disable all interrupts */
    outb(COM1 + 3, 0x80);    /* Enable DLAB (set baud rate divisor) */
    outb(COM1 + 0, 0x03);    /* Set divisor to 3 (lo byte) 38400 baud */
    outb(COM1 + 1, 0x00);    /*                  (hi byte) */
    outb(COM1 + 3, 0x03);    /* 8 bits, no parity, one stop bit */
    outb(COM1 + 2, 0xC7);    /* Enable FIFO, clear them, with 14-byte threshold */
    outb(COM1 + 4, 0x0B);    /* IRQs enabled, RTS/DSR set */
    outb(COM1 + 4, 0x1E);    /* Set in loopback mode, test the serial chip */
    outb(COM1 + 4, 0x0F);    /* Normal operation */
}

void serial_putchar(char c) {
    /* Wait for transmit buffer to be empty */
    while (!(inb(COM1 + 5) & 0x20));
    outb(COM1, c);
}

void serial_print(const char *str) {
    while (*str) {
        serial_putchar(*str++);
    }
}