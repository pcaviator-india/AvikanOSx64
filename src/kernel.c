/*------------------------------------------------------
  kernel.c - Main Kernel Entry Point (64-bit)
  ------------------------------------------------------*/
#include "terminal.h"
#include "gdt.h"

void kernel_main_64(void) {
    /* Placeholder for 64-bit mode (not yet working) */
    while (1) {
        __asm__ volatile ("hlt");
    }
}

/* Main kernel entry - called from entry.asm in 32-bit protected mode */
void kernel_main(void) {
    /* Write 'D' to VGA directly (test if C code runs) */
    volatile unsigned short *vga = (unsigned short *)0xB8000;
    vga[6] = 0x0700 | 'D';
    vga[7] = 0x0700 | 'E';
    vga[8] = 0x0700 | 'F';

    /* Initialize terminal */
    terminal_init();

    /* Print welcome message */
    terminal_print("AvikanOS-x64 v0.05\n");
    terminal_print("Phase 3: 32-bit Kernel Foundation\n");
    terminal_print("----------------------------------\n");

    /* Initialize GDT */
    terminal_print("Initializing GDT... ");
    gdt_init();
    terminal_print("OK\n");

    terminal_print("Running in 32-bit protected mode\n");
    terminal_print("Kernel ready. System running...\n");

    /* Halt forever */
    while (1) {
        __asm__ volatile ("hlt");
    }
}