#!/bin/bash
set -e

echo "=== Starting QEMU test ==="
timeout 8 qemu-system-x86_64 \
    -bios /usr/share/seabios/bios.bin \
    -kernel /mnt/c/PersonalProjects/Avikan-OS-x64/kernel.elf \
    -serial stdio \
    -d int,cpu_reset \
    -D /tmp/qemu_debug.log \
    -m 2048 \
    -nographic \
    -no-reboot 2>&1 || true

echo "=== QEMU exited ==="
echo "=== Debug log ==="
cat /tmp/qemu_debug.log 2>&1 || echo "No debug log"
echo "=== End ==="