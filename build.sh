#!/bin/bash
set -e
PROJECT=/mnt/c/PersonalProjects/Avikan-OS-x64
rm -rf "$PROJECT/iso" "$PROJECT/kernel.bin" "$PROJECT/avikan.iso"
mkdir -p "$PROJECT/iso/boot/grub"
nasm -f bin "$PROJECT/src/entry.asm" -o "$PROJECT/kernel.bin"
cp "$PROJECT/kernel.bin" "$PROJECT/iso/boot/"
printf 'menuentry "AvikanOS-x64" {\n    multiboot /boot/kernel.bin\n    boot\n}' > "$PROJECT/iso/boot/grub/grub.cfg"
grub-mkrescue -o "$PROJECT/avikan.iso" "$PROJECT/iso"
echo "Build complete: $PROJECT/avikan.iso"