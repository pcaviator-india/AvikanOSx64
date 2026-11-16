/*------------------------------------------------------
  kernel.c - Main Kernel Entry Point
  ------------------------------------------------------*/
void kernel_main(void) {
    /* Write 'K' to VGA text mode at (0,1) */
    volatile unsigned short *vga = (volatile unsigned short *)0xB8000;
    vga[1] = 0x0700 | 'K';
    
    /* Halt forever */
    while (1) {
        __asm__ volatile ("hlt");
    }
}