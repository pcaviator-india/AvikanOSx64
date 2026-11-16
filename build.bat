@echo off
setlocal enabledelayedexpansion

REM AvikanOS-x64 Build Script (WSL Ubuntu + VirtualBox ISO)
REM ======================================================

echo [1/4] Creating directory structure...
if not exist iso mkdir iso
if not exist iso\boot mkdir iso\boot
if not exist iso\boot\grub mkdir iso\boot\grub

echo [2/4] Cleaning previous build...
del kernel.elf 2>nul
del *.o 2>nul
del src\*.o 2>nul
del avikan.iso 2>nul
del iso\boot\kernel.elf 2>nul
del iso\boot\grub\grub.cfg 2>nul

echo [3/4] Compiling assembly and C sources...
REM Compile entry.asm to ELF object
wsl -e bash -c "nasm -f elf32 /mnt/c/PersonalProjects/Avikan-OS-x64/src/entry.asm -o /mnt/c/PersonalProjects/Avikan-OS-x64/src/entry.o"

REM Compile C sources
wsl -e bash -c "gcc -m32 -ffreestanding -nostdinc -nostdlib -fno-builtin -fno-pie -no-pie -Wall -Wextra -I/mnt/c/PersonalProjects/Avikan-OS-x64/src -c /mnt/c/PersonalProjects/Avikan-OS-x64/src/kernel.c -o /mnt/c/PersonalProjects/Avikan-OS-x64/src/kernel.o"
wsl -e bash -c "gcc -m32 -ffreestanding -nostdinc -nostdlib -fno-builtin -fno-pie -no-pie -Wall -Wextra -I/mnt/c/PersonalProjects/Avikan-OS-x64/src -c /mnt/c/PersonalProjects/Avikan-OS-x64/src/terminal.c -o /mnt/c/PersonalProjects/Avikan-OS-x64/src/terminal.o"
wsl -e bash -c "gcc -m32 -ffreestanding -nostdinc -nostdlib -fno-builtin -fno-pie -no-pie -Wall -Wextra -I/mnt/c/PersonalProjects/Avikan-OS-x64/src -c /mnt/c/PersonalProjects/Avikan-OS-x64/src/gdt.c -o /mnt/c/PersonalProjects/Avikan-OS-x64/src/gdt.o"

if not exist src\entry.o (
    echo ERROR: entry.o was not created!
    pause
    exit /b 1
)

echo [4/4] Linking kernel.elf and building ISO...
wsl -e bash -c "ld -m elf_i386 -T /mnt/c/PersonalProjects/Avikan-OS-x64/link.ld -o /mnt/c/PersonalProjects/Avikan-OS-x64/kernel.elf /mnt/c/PersonalProjects/Avikan-OS-x64/src/entry.o /mnt/c/PersonalProjects/Avikan-OS-x64/src/kernel.o /mnt/c/PersonalProjects/Avikan-OS-x64/src/terminal.o /mnt/c/PersonalProjects/Avikan-OS-x64/src/gdt.o"

if not exist kernel.elf (
    echo ERROR: kernel.elf was not created!
    pause
    exit /b 1
)

copy kernel.elf iso\boot\kernel.elf >nul

REM Write grub.cfg
echo menuentry "AvikanOS-x64" { > iso\boot\grub\grub.cfg
echo     multiboot /boot/kernel.elf >> iso\boot\grub\grub.cfg
echo     boot >> iso\boot\grub\grub.cfg
echo } >> iso\boot\grub\grub.cfg

wsl -e bash -c "grub-mkrescue -o /mnt/c/PersonalProjects/Avikan-OS-x64/avikan.iso /mnt/c/PersonalProjects/Avikan-OS-x64/iso"

if exist avikan.iso (
    echo.
    echo Build complete: avikan.iso created successfully!
) else (
    echo ERROR: avikan.iso was not created!
    pause
    exit /b 1
)