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

    ; ===== LONG MODE SWITCH =====

    ; Step 1: Load GDTR
    call gdt_flush

    ; Write '1' to confirm GDT loaded
    mov byte [0xB8002], '1'
    mov byte [0xB8003], 0x07

    ; Step 2: Set up 4-level paging structures
    ; PML4 at 0x1000, PDP at 0x2000, PD at 0x3000

    ; PML4 entry 0 → PDP (present, read/write, address 0x2000)
    mov dword [0x1000], 0x2007
    mov dword [0x1004], 0

    ; PDP entry 0 → PD (present, read/write, address 0x3000)
    mov dword [0x2000], 0x3007
    mov dword [0x2004], 0

    ; PD entry 0 → 2MB huge page identity mapped
    mov dword [0x3000], 0x00000083
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

    ; Step 6: Enable Paging in CR0
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; Write '6' to confirm paging enabled
    mov byte [0xB8008], '6'
    mov byte [0xB8009], 0x07

    ; Step 7: Call kernel_main in 32-bit mode with paging enabled
    ; Long mode (64-bit) far jump will be added in next phase
    call kernel_main

    ; If kernel_main returns, halt
    cli
    hlt
    jmp $
