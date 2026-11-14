# TinyOS Working Checklist

Use these markers honestly: `[x]` means file/implementation is present; **not** automatically tested in the guest.

## Starter files authored

- [x] NASM Multiboot v1 entry and stack (`boot/boot.asm`).
- [x] Simple Assembly VGA messages (`src/kernel.asm`).
- [x] ELF32 linker script.
- [x] GRUB ISO configuration.
- [x] CMake kernel/verify/iso/run/debug targets.
- [x] Optional Make frontend, host environment check.
- [x] Contributor setup, build, learning and roadmap documentation.

## Host/runtime verification (must be completed by contributor)

- [ ] Run `./scripts/check-env.sh` on Ubuntu with full dependencies.
- [ ] `cmake -S . -B build` succeeds.
- [ ] `cmake --build build --target verify` passes.
- [ ] Build ISO and boot QEMU successfully.
- [ ] Verify entry and function via GDB.

## Follow-up phases

- [ ] Phase 2 console module, IDT/exception safety.
- [ ] Phase 3 PIC and PS/2 keyboard.
- [ ] Phase 4 shell and commands.
- [ ] Phase 5 consolidation; RAMFS if time permits.
- [ ] Phase 6 regression/reproducible demo.

Detailed tasks live in `docs/phases/`.
