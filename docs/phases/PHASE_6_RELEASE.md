# Phase 6 — Reproducibility, Testing, and COAL Presentation

**Goal:** deliver a truthful, stable teaching artifact rather than maximize line count.

## Tasks
- [ ] Build from scratch in a deleted/recreated `build/` directory.
- [ ] Have a collaborator follow `docs/SETUP_UBUNTU.md` on Ubuntu.
- [ ] Record exact environment versions and known limitations.
- [ ] Inspect ELF header, symbols, and `.multiboot` validation.
- [ ] Boot and run each *actually implemented* command in QEMU.
- [ ] Show one GDB breakpoint or register inspection of the Assembly entry.
- [ ] Exercise failure cases: empty input, long input, unknown command; no triple fault.
- [ ] Document features implemented vs planned; correct README/status table.
- [ ] Explain GRUB → `_start` → stack → kernel → IRQ → shell flow.
- [ ] Capture real screenshots/recording; don't fabricate results.
- [ ] Add final Git release/tag only after demo is repeatable.

## Presentation outline
1. Why Assembly-only and what 32-bit x86 features we used.
2. Toolchain, ELF/GRUB/Multiboot boot process.
3. VGA and hardware/interrupt architecture.
4. Live QEMU demonstration.
5. GDB register/stack inspection and challenges solved.
6. Future work vs features actually shipped.

## Definition of done
- Another person follows the setup and build guide successfully.
- The kernel remains stable through the demo path.
- Build outputs are not committed as source.
- A maintainer can explain each major Assembly file and interface.
