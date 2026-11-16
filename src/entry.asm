; Multiboot v1 header for ELF - must be in first 8KB of kernel
section .multiboot align=4
header_start:
    dd 0x1BADB002                ; magic number
    dd 0x00000000                ; flags (no special requirements)
    dd -(0x1BADB002 + 0x00000000) ; checksum

section .text align=4
    global EntryPoint
    extern gdt_flush

EntryPoint:
    cli

    ; Set up stack at 0x90000
    mov esp, 0x90000

    ; Write 'A' to VGA text mode at 0xB8000
    mov byte [0xB8000], 'A'
    mov byte [0xB8001], 0x07

    ; ===== LONG MODE SWITCH (Minimal) =====

    ; Step 1: Load GDTR (loads our GDT with 64-bit code segment at 0x28)
    call gdt_flush

    ; Write '1' to confirm GDT loaded
    mov byte [0xB8002], '1'
    mov byte [0xB8003], 0x07

    ; Step 2: Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Write '4' to confirm PAE
    mov byte [0xB8004], '4'
    mov byte [0xB8005], 0x07

    ; Step 3: Enable Long Mode in EFER
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Write '5' to confirm LME
    mov byte [0xB8006], '5'
    mov byte [0xB8007], 0x07

    ; Step 4: Far jump to 64-bit code WITHOUT paging, without segment reloads
    db 0xEA
    dd .long_mode
    dw 0x28

bits 64
.long_mode:
    ; We are now in 64-bit long mode!
    ; Write '6' to confirm 64-bit mode
    mov byte [0xB8008], '6'
    mov byte [0xB8009], 0x07

    cli
    hlt
    jmp $
