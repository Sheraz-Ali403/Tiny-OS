# Phase 1 — GRUB, Multiboot, NASM, VGA

**Goal:** See output from our own 32-bit Assembly kernel inside QEMU. **Current state:** Starter source/build files included; actual QEMU runtime verification must be performed on a host with dependencies.

## Understand first
- GRUB and Multiboot v1 header (`0x1BADB002`, checksum, first 8192 file bytes).
- EAX/EBX entry state; 32-bit protected mode, stack pointer and `CALL`.
- NASM ELF32 objects; `global`/`extern` and linker sections.
- VGA text memory and attribute byte.

## Build tasks
- [ ] Install/verify dependencies with `./scripts/check-env.sh`.
- [ ] Review `boot/boot.asm` and `src/kernel.asm` line-by-line.
- [ ] Configure CMake and build target `kernel`.
- [ ] Validate with `grub-file`/`readelf`.
- [ ] Build `iso` and boot `run`.
- [ ] Alter a string, rebuild and verify incremental build.
- [ ] Debug `_start` and `kernel_main` with GDB once.
- [ ] Commit Phase 1 and record the real test result.

## Acceptance
- GRUB launches TinyOS and all three lines render correctly.
- CPU halts stably, no unexplained restart.
- No C or C++ code compiled; NASM and `i686-elf-ld` are responsible.
- Separate `boot.o` and `kernel.o` are linked into one ELF32.

## Pitfalls
- Confusing Multiboot *header magic* (`0x1BADB002`) with GRUB *entry magic* (`0x2BADB002`).
- Treating a `.o` file like a bootable ISO.
- Forgetting `-f elf32` or putting the header too far into the linked ELF file.
