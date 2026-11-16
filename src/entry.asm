; Multiboot v1 header for ELF - must be in first 8KB of kernel
section .multiboot align=4
header_start:
    dd 0x1BADB002                ; magic number
    dd 0x00000000                ; flags (no special requirements)
    dd -(0x1BADB002 + 0x00000000) ; checksum

section .text align=4
    global EntryPoint

EntryPoint:
    cli

    ; Write 'A' to VGA text mode at 0xB8000 (assume ES base=0 from GRUB)
    mov byte [0xB8000], 'A'
    mov byte [0xB8001], 0x07

    hlt
    jmp $
