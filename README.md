# TinyOS — Assembly-Only 32-bit x86 Educational Operating System

**Status:** Phase 1 starter is implemented; subsequent subsystems are planned, not implemented.  
**Course context:** Computer Organization & Assembly Language (COAL).  
**Implementation rule:** All target-side operating-system code must be **NASM x86 Assembly**. **No C/C++ or libc** in the kernel.  
**Host:** Ubuntu Linux. **Guest:** 32-bit x86 PC emulated by QEMU. **Boot:** GRUB 2 + Multiboot v1. **Build:** CMake orchestrating NASM, `i686-elf-ld`, GRUB tools, and QEMU.

## What the project is

TinyOS is an original, small, monolithic educational kernel—not a Linux distribution or a Bash replacement. Its long-term V1 objective is to boot through GRUB, initialize the essential x86 environment, output text, handle keyboard input, and expose a simple interactive Assembly-written shell with a small RAM-backed directory tree.

**Included right now:** a minimal, bootable (once the host dependencies are installed) two-object Assembly kernel that validates the Multiboot magic, sets its own stack, displays three lines through VGA text memory, then safely halts. CMake builds `kernel.elf` and `tinyos.iso` and can launch QEMU. **Not yet included:** functional interrupts, keyboard, shell, memory allocator, or RAMFS. Keep those features in milestones until they exist.

## First-time setup (Ubuntu)

```bash
./scripts/check-env.sh
cmake -S . -B build
cmake --build build --target verify
cmake --build build --target iso
cmake --build build --target run
```

The virtual CPU then halts (no keyboard response yet). Close QEMU using its window controls. **Do not run this ISO directly on your real laptop.**

## Project structure

```text
TinyOS_Assembly_Starter/
├── boot/boot.asm             # Multiboot header, stack, _start
├── src/kernel.asm            # Phase 1 VGA kernel
├── linker/linker.ld          # ELF32 memory layout
├── grub/grub.cfg             # GRUB menu entry
├── CMakeLists.txt            # Canonical build specification
├── Makefile                  # Optional make frontend for CMake
├── scripts/check-env.sh      # Dependency and environment check
├── docs/                     # Important things
└── .gitignore                # Ignore build products
```