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

    ; Step 1: Load GDTR (we keep GRUB's segments for now)
    call gdt_flush

    ; Step 2: Set up 4-level paging structures
    ; PML4 at 0x1000, PDP at 0x2000, PD at 0x3000, PT at 0x4000
    
    ; PML4 entry 0 → PDP (present, read/write, address 0x2000)
    mov dword [0x1000], 0x2007   ; Low 32 bits: addr 0x2000 | flags 0x7
    mov dword [0x1004], 0        ; High 32 bits: 0

    ; PDP entry 0 → PD (present, read/write, address 0x3000)
    mov dword [0x2000], 0x3007   ; Low 32 bits: addr 0x3000 | flags 0x7
    mov dword [0x2004], 0        ; High 32 bits: 0

    ; PD entry 0 → 2MB huge page identity mapped (present, read/write, 2MB page)
    ; Address 0x000000, flags: Present(1) | RW(1) | User(0) | PWT(0) | PCD(0) | A(0) | D(0) | PS(1) | G(0)
    ; For 2MB huge page: bits 21-31 = physical address bits 21-31, bit 7 = PS (page size)
    mov dword [0x3000], 0x00000083  ; Low 32 bits: addr 0 | flags 0x83 (Present+RW+PS)
    mov dword [0x3004], 0           ; High 32 bits: 0

    ; Step 3: Load CR3 with PML4 physical address
    mov eax, 0x1000
    mov cr3, eax

    ; Step 4: Enable PAE (Physical Address Extension) in CR4
    mov eax, cr4
    or eax, 1 << 5               ; Set PAE bit (bit 5)
    mov cr4, eax

    ; Step 5: Enable Long Mode in EFER MSR (0xC0000080)
    mov ecx, 0xC0000080          ; EFER MSR
    rdmsr                        ; Read EFER
    or eax, 1 << 8               ; Set LME bit (bit 8) - Long Mode Enable
    wrmsr                        ; Write EFER

    ; Step 6: Enable Paging in CR0
    mov eax, cr0
    or eax, 1 << 31              ; Set PG bit (bit 31)
    mov cr0, eax

    ; Step 7: Far jump to 64-bit code segment
    ; We need a 64-bit code segment descriptor in GDT first
    ; For now, just call kernel_main in 32-bit mode with paging enabled
    call kernel_main

    ; If kernel_main returns, halt
    cli
    hlt
    jmp $
