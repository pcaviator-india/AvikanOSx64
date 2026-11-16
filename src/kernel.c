/*------------------------------------------------------
  kernel.c - Main Kernel Entry Point (64-bit)
  ------------------------------------------------------*/
#include "terminal.h"
#include "gdt.h"

void kernel_main_64(void) {
    /* Initialize terminal */
    terminal_init();

    /* Print welcome message */
    terminal_print("AvikanOS-x64 v0.05\n");
    terminal_print("Phase 5: 64-bit Kernel\n");
    terminal_print("----------------------\n");

    /* Initialize GDT */
    terminal_print("Initializing GDT... ");
    gdt_init();
    terminal_print("OK\n");

    terminal_print("Running in 64-bit long mode\n");
    terminal_print("Kernel ready. System running...\n");

    /* Halt forever */
    while (1) {
        __asm__ volatile ("hlt");
    }
}