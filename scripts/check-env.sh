#!/usr/bin/env bash
set -u

required=(nasm i686-elf-ld cmake grub-file grub-mkrescue qemu-system-i386)
missing=0
printf 'TinyOS host-environment check\n\n'
for tool in "${required[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        printf '[OK] %-20s %s\n' "$tool" "$(command -v "$tool")"
    else
        printf '[MISSING] %s\n' "$tool"
        missing=1
    fi
done
for tool in gdb-multiarch readelf git; do
    if command -v "$tool" >/dev/null 2>&1; then
        printf '[OPTIONAL OK] %-12s %s\n' "$tool" "$(command -v "$tool")"
    else
        printf '[OPTIONAL] %s not found\n' "$tool"
    fi
done
if [[ -n "${PREFIX:-}" ]]; then
    printf '\n[WARN] PREFIX is set to %s; NVM may reject this variable.\n' "$PREFIX"
    printf '       Run: unset PREFIX\n'
fi
if (( missing )); then
    printf '\nSome required tools are missing. Read docs/SETUP_UBUNTU.md\n'
    exit 1
fi
printf '\nReady for: cmake -S . -B build\n'
