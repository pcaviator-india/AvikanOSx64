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
del kernel.o 2>nul
del avikan.iso 2>nul
del iso\boot\kernel.elf 2>nul
del iso\boot\grub\grub.cfg 2>nul

echo [3/4] Compiling entry.asm to ELF object...
wsl -e bash -c "nasm -f elf32 /mnt/c/PersonalProjects/Avikan-OS-x64/src/entry.asm -o /mnt/c/PersonalProjects/Avikan-OS-x64/kernel.o"

if not exist kernel.o (
    echo ERROR: kernel.o was not created!
    pause
    exit /b 1
)

echo [4/4] Linking kernel.elf and building ISO...
wsl -e bash -c "ld -m elf_i386 -T /mnt/c/PersonalProjects/Avikan-OS-x64/link.ld -o /mnt/c/PersonalProjects/Avikan-OS-x64/kernel.elf /mnt/c/PersonalProjects/Avikan-OS-x64/kernel.o"

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