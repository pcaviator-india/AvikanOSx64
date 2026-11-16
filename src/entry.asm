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

    ; ===== LONG MODE SWITCH =====

    ; Step 1: Load GDTR
    call gdt_flush

    ; Reload data segments with new GDT selectors
    mov ax, 0x10                   ; Kernel data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Write '1' to confirm GDT loaded + segments reloaded
    mov byte [0xB8002], '1'
    mov byte [0xB8003], 0x07

    ; Step 2: Set up 4-level paging structures
    mov dword [0x1000], 0x2007     ; PML4[0] → PDP
    mov dword [0x1004], 0
    mov dword [0x2000], 0x3007     ; PDP[0] → PD
    mov dword [0x2004], 0
    mov dword [0x3000], 0x00000083 ; PD[0] → 2MB huge page (identity)
    mov dword [0x3004], 0

    ; Step 3: Load CR3
    mov eax, 0x1000
    mov cr3, eax

    ; Step 4: Enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; Write '4' to confirm PAE
    mov byte [0xB8004], '4'
    mov byte [0xB8005], 0x07

    ; Step 5: Enable Long Mode in EFER
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; Write '5' to confirm LME
    mov byte [0xB8006], '5'
    mov byte [0xB8007], 0x07

    ; Step 6: Enable Paging
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; Write '6' to confirm paging
    mov byte [0xB8008], '6'
    mov byte [0xB8009], 0x07

    ; Step 7: Far jump to 64-bit code
    jmp 0x28:.long_mode

bits 64
.long_mode:
    ; Write '7' to confirm 64-bit mode
    mov byte [0xB800A], '7'
    mov byte [0xB800B], 0x07

    cli
    hlt
    jmp $
