# AvikanOS-x64 Build System
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
	@echo ENTRY(EntryPoint) > link.ld
	@echo SECTIONS { >> link.ld
	@echo . = 1M; >> link.ld
	@echo .text : { >> link.ld
	@echo *(.text) >> link.ld
	@echo } >> link.ld
	@echo .rodata : { >> link.ld
	@echo *(.rodata) >> link.ld
	@echo } >> link.ld
	@echo .data : { >> link.ld
	@echo *(.data) >> link.ld
	@echo } >> link.ld
	@echo .bss  : { >> link.ld
	@echo *(.bss) >> link.ld
	@echo } >> link.ld
	@echo } >> link.ld

# Compile assembly/s
src/entry.o: src/entry.asm
	$(AS) $< -o $@

# Compile C sources
src/kernel.o: src/kernel.c
	$(CC) $(CFLAGS) -c $< -o $@
src/terminal.o: src/terminal.c
	$(CC) $(CFLAGS) -c $< -o $@
src/gdt.o: src/gdt.c
	$(CC) $(CFLAGS) -c $< -o $@
src/idt.o: src/idt.c
	$(CC) $(CFLAGS) -c $< -o $@
src/timer.o: src/timer.c
	$(CC) $(CFLAGS) -c $< -o $@

# Link
$(TARGET): $(SOURCES:.c=.o) $(SOURCES:.asm=.o) link.ld
	$(LD) $(LDFLAGS) -o $@ $(SOURCES:.c=.o) $(SOURCES:.asm=.o)

# Clean
clean:
	rm -f src/*.o link.ld $(TARGET)

# Run with QEMU
run: $(TARGET)
	qemu-system-x86_64 -bios ./OVMF.fd -kernel $(TARGET) -serial stdio

# Debug target
debug: $(TARGET)
	qemu-system-x86_64 -bios ./OVMF.fd -kernel $(TARGET) -s -S &

.PHONY: all clean run debug

