# AvikanOS-x64: Detailed Development Plan

## Project Overview
This project aims to create an x86-64 (64-bit) operating system based on the MikanOS framework, originally implemented in V language by lemoncmd (VikanOS). The original MikanOS is a 32-bit x86 OS taught in "Zero OS Development from Scratch" by uchan. This project will port the concepts and structure to 64-bit architecture.

## Architecture Differences: x86 vs x86-64

### Key Changes Required:
1. **IA-32e Mode (Long Mode)**: Transition from 32-bit protected mode to 64-bit mode
2. **MSR (Model Specific Registers)**: Additional MSRs for 64-bit mode control
3. **Extended Registers**: 8 additional general-purpose registers (R8-R15)
64-bit virtual address space (2^64 vs 2^32)
4. **Paging**: 4-level paging (PML4 -> PDP -> PD -> PT) vs 2-level (PD -> PT)
5. **Compatibility**: Can run 32-bit code in IA-32e mode via legacy mode

## Development Phases

### Phase 1: Foundation & Bootloader
- [x] Set up UEFI development environment (preferred over BIOS for x64)
- [x] Write UEFI bootloader in C/Assembly
- [x] Configure GDT/LDT for x64 (Global Descriptor Table)
- [x] Set up IDT (Interrupt Descriptor Table)
- [ ] Enable PAE (Physical Address Extension) and long mode
- [ ] Enable NX (No-Execute) bit

### Phase 2: Core Kernel
- [x] Kernel entry point (KernelMain)
- [ ] Basic memory management (paging initialization)
- [x] Console/terminal output (VGA text mode)
- [x] Interrupt handling (IRQs, exceptions)
- [x] Timer (PIT/HPET)
- [ ] CPU information and features detection

### Phase 3: System Features
- [ ] Framebuffer graphics support
- [ ] Keyboard input
- [ ] PCI enumeration
- [ ] ACPI table parsing
- [ ] Multi-core support (APIC)

### Phase 4: Advanced Features
- [ ] File system ( simple FAT support)
- [ ] Network stack (optional, initial)
- [ ] Shell/CLI
- [ ] Memory allocator (buddy system or slabs)

## Technical Requirements

### Toolchain
- GCC cross-compiler (i686-elf and x86_64-elf)
- NASM or FASM for assembly
- Make build system
- QEMU for testing (x86_64 target)
- OVMF (UEFI firmware) for UEFI testing

### Assembly Structure (Entry.asm)
```
; 64-bit entry point
EntryPoint:
    cli              ; Clear interrupts
    xor eax, eax     ; Clear registers
    mov with, eax
    
    ; Set up identity paging first
    ; Enable long mode
    ; Enable paging
    ; Jump to C kernel main
```

### C Kernel Structure (kernel.c)
```c
void kernel_main(const struct smp_info *bsp) {
    // Initialize terminal
    // Set up paging
    // Enable interrupts
    // Print welcome message
    // Initialize hardware
}
```

### Memory Management
- Identity mapping for first 1GB (4KB pages)
- Higher half kernel mapping (0xFFFF_8000_0000_0000)
- Physical memory bitmap or buddy allocator

### Key Differences from MikanOS (x86)
| Feature | MikanOS (x86) | AvikanOS-x64 (x64) |
|---------|---------------|---------------------|
| Mode | Protected Mode | Long Mode (IA-32e) |
| Paging | 2-level (PGDIR + PGTBL) | 4-level (PML4 + PDP + PD + PT) |
| Max Memory | 4GB | Virtually unlimited (2^64) |
| Long Mode MSR | N/A | MSR_FFXSR, MSR_LSTAR, MSR_CSTAR, etc. |
| Mode Switch | GDT setup + CR0.PE + CR0.PG | GDT + MSR setup + CR4 + EFER.SCE + CR0 + CR4 + PG |
| Registers | 8 general-purpose | 16 general-purpose (R8-R15) |

## Milestone Plan

### Milestone 1: "Hello World" (Week 1-2) - COMPLETE
- [x] Boot UEFI application (code written, compiles)
- [x] Print "Hello from x64!" to screen (VGA text mode)
- [x] Basic GDT setup
- [ ] Switch to long mode (entry.asm sets up stack, long mode switch pending)

### Milestone 2: Kernel Foundation (Week 3-4) - IN PROGRESS
- [x] C kernel entry point
- [ ] Paging initialization (4-level)
- [ ] Identity mapping
- [ ] Basic memory allocator

### Milestone 3: Hardware Support (Week 5-6) - PLANNED
- [ ] Keyboard input
- [x] Timer interrupt (PIT at 100Hz)
- [ ] Framebuffer output
- [ ] ACPI table parsing

### Milestone 4: User Features (Week 7-8) - PLANNED
- [ ] Shell implementation
- [ ] File system support (FAT)
- [ ] Multi-core initialization

### Milestone 5: Refinement (Week 9+) - PLANNED
- [ ] Documentation
- [ ] Example tutorials
- [ ] Build system automation
- [ ] QEMU testing suite

## References & Inspiration
- Original MikanOS: https://github.com/uchan-nos/mikanos
- VikanOS (V language port): https://github.com/lemoncmd/VikanOS
- OSDev Wiki: https://wiki.osdev.org/
- JamesM OSDev tutorials
- James Hughes "Writing a Simple Operating System From Scratch"

## Build Commands

### Building (Windows batch with WSL toolchain)
```cmd
build.bat
```
This builds kernel.elf and creates avikan.iso for VirtualBox.

### Testing in VirtualBox
1. Open VirtualBox Manager
2. Click "New" to create a VM:
   - Name: AvikanOS-x64
   - Type: Linux
   - Version: Other Linux (64-bit)
   - Memory: At least 1024 MB
   - Create virtual hard disk now (VDI, dynamically allocated, 10 GB)
3. VM Settings → System → Enable EFI (check box)
4. VM Settings → Storage → Add optical drive → Choose avikan.iso
5. Start the VM

### Building and Testing in one step
```cmd
build.bat
# Then boot avikan.iso in VirtualBox
```

## Project Structure
- `src/entry.asm` - x86-64 assembly entry point (with Multiboot2 header)
- `src/kernel.c` - Main C kernel
- `src/terminal.c/h` - VGA text mode output
- `src/gdt.c/h` - Global Descriptor Table
- `src/idt.c/h` - Interrupt Descriptor Table
- `src/timer.c/h` - Programmable Interval Timer
- `build.bat` - Build script (Windows + WSL)
- `avikan.iso` - Bootable ISO for VirtualBox
- `PLAN.md` - This document