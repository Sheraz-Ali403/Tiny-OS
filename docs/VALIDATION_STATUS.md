# Validation Status for the Generated Starter

This file distinguishes checks performed during starter packaging from checks that **must** be performed on the contributor's configured Ubuntu machine.

## Completed during preparation

- [x] Checked the project file tree, relative document links and intended file ownership.
- [x] Verified `CMakeLists.txt` **configures and generates a build graph** with CMake 3.31 when dummy executable paths are passed for missing host-specific tools. This checks CMake syntax/target structure **only**, not a real build.
- [x] Validated `scripts/check-env.sh` shell syntax using `bash -n`.
- [x] Audited all kernel sources for target-language restrictions: only `.asm` used, no C/C++.
- [x] Ensured Multiboot v1 header constants, ELF32 linker format, bootloader entry symbols and GRUB config agree by source inspection.

## Not validated in the artifact-generation environment

- [ ] Actual NASM ELF32 assembly and `i686-elf-ld` link (required tools not available there).
- [ ] `grub-file` positive detection of built ELF, real `grub-mkrescue` ISO generation.
- [ ] BIOS GRUB/QEMU boot and VGA display.
- [ ] QEMU+GDB breakpoint/stack inspection.

## Required acceptance on Ubuntu

```bash
./scripts/check-env.sh
cmake -S . -B build
cmake --build build --target verify
cmake --build build --target iso
cmake --build build --target run
```

If any step fails, follow `TROUBLESHOOTING.md` and report exact output. **Do not mark the first runtime milestone complete until it has actually run.**
