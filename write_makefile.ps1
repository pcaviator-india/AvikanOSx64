# AvikanOS-x64 Makefile generator
$tab = "`t"

# Build Makefile content using single-quoted strings to prevent PowerShell variable expansion
$makefile_content = '# AvikanOS-x64 Build System
# ---------------------------------

# Compiler settings
CC      = x86_64-elf-gcc
AS      = nasm
LD      = ld

# Flags
ASFLAGS = -f elf64
CFLAGS  = -m64 -ffreestanding -nostdinc -nostdlib -fno-pie -no-pie -Wall -Wextra
LDFLAGS = -m elf_x86_64 -T link.ld --nologo

# Source files
ASOURCES = src/entry.asm
CSOURCES = src/kernel.c src/terminal.c src/gdt.c src/idt.c src/timer.c
SOURCES   = $(ASOURCES) $(CSOURCES)

# Output
TARGET = kernel.elf

# Default target
all: $(TARGET)

# Linker script
link.ld:
' + $tab + '@echo ENTRY(EntryPoint) > link.ld
' + $tab + '@echo SECTIONS { >> link.ld
' + $tab + '@echo . = 1M; >> link.ld
' + $tab + '@echo .text : { >> link.ld
' + $tab + '@echo *(.text) >> link.ld
' + $tab + '@echo } >> link.ld
' + $tab + '@echo .rodata : { >> link.ld
' + $tab + '@echo *(.rodata) >> link.ld
' + $tab + '@echo } >> link.ld
' + $tab + '@echo .data : { >> link.ld
' + $tab + '@echo *(.data) >> link.ld
' + $tab + '@echo } >> link.ld
' + $tab + '@echo .bss  : { >> link.ld
' + $tab + '@echo *(.bss) >> link.ld
' + $tab + '@echo } >> link.ld
' + $tab + '@echo } >> link.ld

# Compile assembly/s
src/entry.o: src/entry.asm
' + $tab + '$(AS) $< -o $@

# Compile C sources
src/kernel.o: src/kernel.c
' + $tab + '$(CC) $(CFLAGS) -c $< -o $@
src/terminal.o: src/terminal.c
' + $tab + '$(CC) $(CFLAGS) -c $< -o $@
src/gdt.o: src/gdt.c
' + $tab + '$(CC) $(CFLAGS) -c $< -o $@
src/idt.o: src/idt.c
' + $tab + '$(CC) $(CFLAGS) -c $< -o $@
src/timer.o: src/timer.c
' + $tab + '$(CC) $(CFLAGS) -c $< -o $@

# Link
$(TARGET): $(SOURCES:.c=.o) $(SOURCES:.asm=.o) link.ld
' + $tab + '$(LD) $(LDFLAGS) -o $@ $(SOURCES:.c=.o) $(SOURCES:.asm=.o)

# Clean
clean:
' + $tab + 'rm -f src/*.o link.ld $(TARGET)

# Run with QEMU
run: $(TARGET)
' + $tab + 'qemu-system-x86_64 -bios ./OVMF.fd -kernel $(TARGET) -serial stdio

# Debug target
debug: $(TARGET)
' + $tab + 'qemu-system-x86_64 -bios ./OVMF.fd -kernel $(TARGET) -s -S &

.PHONY: all clean run debug
'

Set-Content -Path 'c:\PersonalProjects\Avikan-OS-x64\Makefile' -Value $makefile_content -Encoding utf8
Write-Host "Makefile written successfully"