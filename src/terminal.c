/*------------------------------------------------------
  terminal.c - VGA Text Terminal Output
  ------------------------------------------------------*/
#include "terminal.h"

/* VGA text mode buffer */
volatile unsigned short *vga_buffer = (unsigned short *)0xB8000;

/* Terminal cursor position */
static int cursor_x = 0;
static int cursor_y = 0;

/* Initialize terminal (called from kernel) */
void terminal_init(void) {
    /* Clear screen */
    for (int i = 0; i < 80 * 25; i++) {
        vga_buffer[i] = 0x0700 | ' ';
    }
    cursor_x = 0;
    cursor_y = 0;
}

/* Print a single character */
void terminal_putchar(char c) {
    /* Handle newline */
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
        return;
    }
    
    /* Handle carriage return */
    if (c == '\r') {
        cursor_x = 0;
        return;
    }
    
    /* Write character to VGA buffer with attribute byte */
    vga_buffer[cursor_y * 80 + cursor_x] = 0x0700 | c;
    
    /* Advance cursor */
    cursor_x++;
    if (cursor_x >= 80) {
        cursor_x = 0;
        cursor_y++;
    }
    if (cursor_y >= 25) {
        /* Scroll up */
        for (int i = 0; i < 24 * 80; i++) {
            vga_buffer[i] = vga_buffer[i + 80];
        }
        for (int i = 24 * 80; i < 80 * 25; i++) {
            vga_buffer[i] = 0x0700 | ' ';
        }
        cursor_y = 24;
    }
}

/* Print a null-terminated string */
void terminal_print(const char *str) {
    int i = 0;
    while (str[i] != '\0') {
        terminal_putchar(str[i]);
        i++;
    }
}