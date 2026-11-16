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

bits 32
EntryPoint:
    cli

    ; Set up stack at 0x90000 (16-byte aligned for 64-bit)
    mov esp, 0x90000

    ; Write 'A' to VGA text mode at 0xB8000
    mov byte [0xB8000], 'A'
    mov byte [0xB8001], 0x07

    ; ===== LONG MODE SWITCH =====

    ; Step 1: Load GDTR with 6-byte pseudo-descriptor
    lgdt [gdt_ptr]

    ; Write '1' to confirm GDT loaded
    mov byte [0xB8002], '1'
    mov byte [0xB8003], 0x07

    ; Step 2: Set up 4-level paging structures (identity-mapped)
    ; PML4 at 0x1000, PDP at 0x2000, PD at 0x3000
    mov dword [0x1000], 0x2007     ; PML4[0] → PDP (Present, RW)
    mov dword [0x1004], 0
    mov dword [0x2000], 0x3007     ; PDP[0] → PD (Present, RW)
    mov dword [0x2004], 0
    mov dword [0x3000], 0x00000083 ; PD[0] → 2MB huge page identity (Present, RW, Huge)
    mov dword [0x3004], 0

    ; Step 3: Load CR3 with PML4 physical address
    mov eax, 0x1000
    mov cr3, eax

    ; Step 4: Enable PAE in CR4
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Write '4' to confirm PAE enabled
    mov byte [0xB8004], '4'
    mov byte [0xB8005], 0x07

    ; Step 5: Enable Long Mode in EFER MSR
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Write '5' to confirm LME set
    mov byte [0xB8006], '5'
    mov byte [0xB8007], 0x07

    ; Step 6: Enable Paging in CR0 (this sets LMA=1 automatically)
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; Write '6' to confirm paging enabled
    mov byte [0xB8008], '6'
    mov byte [0xB8009], 0x07

    ; Step 7: Far jump to 64-bit long mode code segment
    ; GDT entry [5] selector = 5 * 8 = 0x28
    jmp 0x28:.long_mode_start

bits 64
.long_mode_start:
    ; We are now in 64-bit long mode!
    ; Write '7' to confirm we made it to long mode
    mov byte [0xB800A], '7'
    mov byte [0xB800B], 0x07

    ; Halt in 64-bit mode
    cli
    hlt
    jmp $