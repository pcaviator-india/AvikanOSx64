/*------------------------------------------------------
  kernel.c - Main Kernel Entry Point
  ------------------------------------------------------*/
#include "terminal.h"
#include "gdt.h"

void kernel_main(void) {
    /* Initialize terminal */
    terminal_init();

    /* Print welcome message */
    terminal_print("AvikanOS-x64 v0.04\n");
    terminal_print("Phase 4: Long Mode (x86-64)\n");
    terminal_print("---------------------------\n");

    /* Initialize GDT */
    terminal_print("Initializing GDT... ");
    gdt_init();
    terminal_print("OK\n");

    terminal_print("Paging enabled (PAE + LME + PG)\n");
    terminal_print("Running in 32-bit compatibility mode\n");
    terminal_print("Long mode far jump: TODO\n");
    terminal_print("Kernel ready. System running...\n");

    /* Halt forever */
    while (1) {
        __asm__ volatile ("hlt");
    }
}