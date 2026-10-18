# Scope, Requirements, and Definition of Done

## Hard requirements

- [ ] **Assembly-only target code**: all kernel/driver/shell implementation written in NASM x86 Assembly; no C/C++/Rust kernel modules.
- [ ] Bootable 32-bit ELF kernel using GRUB 2 and Multiboot v1 in QEMU BIOS mode.
- [ ] Build managed by CMake; separate out-of-tree build directory.
- [ ] Clean setup reproducible on a new Ubuntu host following project documentation.
- [ ] Meaningful COAL concepts used: registers, stack, memory layout, protected mode, CPU exceptions/interrupts, and port I/O.
- [ ] Working and demonstrated functionality, not prewritten fake command output.

## Must deliver (V1 core)

| Feature | Done means | Initial status |
|---|---|---|
| GRUB boot + kernel ELF32 | Multiboot-verified boot in QEMU | **Source included; runtime test pending** |
| VGA console | Safe text writes, clear, newline/scroll | Initial fixed-line output only |
| Exception handling | IDT installed; selected errors print diagnostics | Planned |
| Keyboard driver | Key press events reach bounded input | Planned |
| Minimal shell | Prompt, `help`, `clear`, `echo`, `hostname`, `uname` | Planned |
| Robust build and docs | Setup, run, troubleshooting, testing, roadmap | Included |

## Target V1 stretch features (only after core passes)

- [ ] Simple in-memory directory tree / RAMFS with real `ls`, `pwd`, and `cd`.
- [ ] `cat` for a few text files stored in RAM.
- [ ] `meminfo` from validated bootloader memory data.
- [ ] Timer/uptime counter if IRQ0 is handled correctly.
- [ ] Minimal bump allocator for kernel-owned memory.

The previous C+Assembly plan included full VFS/memory/serial features. Under the strict Assembly-only constraint, these are stretch goals, not promises. A full VFS abstraction is unnecessary for a small educational RAMFS.

## Explicitly out of V1 scope

USB, networking, Ethernet/Wi-Fi, GPU GUI, user processes, ring 3, scheduling, ELF userspace loading, POSIX syscalls, Linux Bash, real-disk filesystem, SMP, dynamic kernel modules, security hardening, and real hardware installation.

## Success criteria for each milestone

- A new teammate can reproduce the build without asking for undocumented steps.
- All new Assembly symbols resolve; no undefined references or architecture mismatch.
- The guest boots after the change; no regression of earlier command behavior.
- Unit-like pure routines (e.g., string compare/parser) have defined input/output contracts and edge-case tests.
- Each subsystem can be explained with a short CPU/hardware flow diagram.
- Feature claims in documentation match what was actually demonstrated in QEMU.

## Suggested COAL project evaluation evidence

Record: (1) actual NASM `.asm` and disassembly, (2) bootable QEMU run, (3) CPU/register/interrupt flow explanation, (4) source commits, (5) an honest feature/status table, and (6) a brief live shell demo only after it works.
