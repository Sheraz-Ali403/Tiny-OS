# Start Here: Your First Two Sessions

## Session A — Understand the boot/build sequence

- [ ] Explain why QEMU (virtual PC), GRUB (bootloader), NASM (assembler), `i686-elf-ld` (linker), and CMake (build orchestrator) are separate tools.
- [ ] Understand that CMake **does not compile kernel code** and no C/C++ source is part of this project.
- [ ] Read Multiboot v1 header requirements: correct magic, checksum, 4-byte alignment, first 8192 bytes of kernel file.
- [ ] Identify `EAX=0x2BADB002`, `EBX=Multiboot info address`, and stack initialization at `_start`.
- [ ] Understand why VGA text memory is at `0xB8000` in the initial QEMU PC configuration.
- [ ] Read `boot/boot.asm`, `src/kernel.asm`, `linker/linker.ld` line by line.

## Session B — Build and inspect the real artifact

- [ ] Follow `docs/SETUP_UBUNTU.md` and run `./scripts/check-env.sh`.
- [ ] Run `cmake -S . -B build`.
- [ ] Run `cmake --build build --target verify`.
- [ ] Run `cmake --build build --target iso`.
- [ ] Inspect `readelf -h build/kernel.elf` (ELF32, Intel 80386, entry point).
- [ ] Inspect `i686-elf-objdump -d build/kernel.elf` if installed (or `objdump -d`).
- [ ] Run `cmake --build build --target run`.
- [ ] Explain how the CPU went from `_start` to `kernel_main`, then returned to the halt loop.
- [ ] Change only the text in `src/kernel.asm`; rebuild and confirm the change.
- [ ] Commit a reproducibly working Phase 1 milestone to Git.

## Do **not** start yet

Do not mix keyboard polling, IDT, PIC, RAMFS, process management, or paging into the initial boot milestone. Read the milestone-specific checklist before adding any hardware subsystem.

## First milestone acceptance

- The ISO boots using BIOS-mode QEMU and GRUB.
- VGA shows the three expected lines.
- Kernel does not reset or triple-fault.
- `grub-file --is-x86-multiboot build/kernel.elf` succeeds.
- No C/C++ compilation occurs.
