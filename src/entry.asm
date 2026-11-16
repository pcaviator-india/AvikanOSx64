; Multiboot v1 header for ELF - must be in first 8KB of kernel
section .multiboot align=4
header_start:
    dd 0x1BADB002                ; magic number
    dd 0x00000000                ; flags (no special requirements)
    dd -(0x1BADB002 + 0x00000000) ; checksum

section .text align=4
    global EntryPoint
    extern kernel_main
    extern gdt_flush

EntryPoint:
    cli

    ; Set up stack at 0x90000
    mov esp, 0x90000

    ; Write 'A' to VGA text mode at 0xB8000
    mov byte [0xB8000], 'A'
    mov byte [0xB8001], 0x07

    ; Load GDTR (just lgdt, no segment reload yet - GRUB's segments still valid)
    call gdt_flush

    ; Call kernel_main with GRUB's segments
    call kernel_main

    ; If kernel_main returns, halt
    cli
    hlt
    jmp $
