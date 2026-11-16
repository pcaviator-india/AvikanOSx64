; Multiboot v1 header for ELF - must be in first 8KB of kernel
section .multiboot align=4
header_start:
    dd 0x1BADB002                ; magic number
    dd 0x00000000                ; flags (no special requirements)
    dd -(0x1BADB002 + 0x00000000) ; checksum

section .text align=4

;==============================================================================
; GDT Entries (in .text section - identity-mapped range, below 2MB)
;==============================================================================
align 8
global gdt_start
gdt_start:
    dq 0                              ; Entry 0: Null descriptor

    ; Entry 1: Code segment (32-bit, kernel, ring 0)
    ; Access=0x9A, Granularity=0xCF (G=1, D=1, L=0)
    dw 0xFFFF                         ; Limit low
    dw 0x0000                         ; Base low
    db 0x00                           ; Base middle
    db 0x9A                           ; Access
    db 0xCF                           ; Granularity
    db 0x00                           ; Base high

    ; Entry 2: Data segment (32-bit, kernel, ring 0)
    ; Access=0x92, Granularity=0xCF
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x92
    db 0xCF
    db 0x00

    ; Entry 3: Code segment (32-bit, user, ring 3)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0xFA                           ; Access (Present, Ring3, Exec, Read)
    db 0xCF
    db 0x00

    ; Entry 4: Data segment (32-bit, user, ring 3)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0xF2                           ; Access (Present, Ring3, Write, Read)
    db 0xCF
    db 0x00

    ; Entry 5: Code segment (64-bit long mode, kernel, ring 0)
    ; Access=0x9A, Granularity=0xA0 (G=1, D=0, L=1)
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 0x9A
    db 0xA0
    db 0x00

gdt_end:

; GDT Pointer - 6 bytes for 32-bit lgbt instruction
align 2
global gdt_ptr
gdt_ptr:
    dw gdt_end - gdt_start - 1        ; Limit (16-bit)
    dd gdt_start                      ; Base (32-bit address)

;==============================================================================
section .text align=4
    global EntryPoint
    extern kernel_main

bits 32
EntryPoint:
    cli

    ; Set up stack at 0x90000
    mov esp, 0x90000

    ; Write 'A' to VGA text mode at 0xB8000 (sanity check)
    mov byte [0xB8000], 'A'
    mov byte [0xB8001], 0x07

    ; Write 'B' before calling kernel_main
    mov byte [0xB8002], 'B'
    mov byte [0xB8003], 0x07

    ; Call kernel_main (runs in 32-bit protected mode)
    call kernel_main

    ; Write 'C' if kernel_main returns
    mov byte [0xB8004], 'C'
    mov byte [0xB8005], 0x07

    ; If kernel_main returns, halt forever
    cli
    hlt
    jmp $