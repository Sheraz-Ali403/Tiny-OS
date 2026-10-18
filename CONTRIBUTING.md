# Contributing to TinyOS

Thank you for helping. This is a **COAL educational operating system**, with a strict **Assembly-only kernel** constraint.

## Get started

1. Read `README.md`, `docs/SETUP_UBUNTU.md`, and `docs/IMPLEMENTATION_CONTRACTS.md`.
2. Run `./scripts/check-env.sh` and build with CMake.
3. Run and understand the Phase 1 boot milestone before changing interrupt code.
4. Create a feature branch named `feat/<topic>` or `fix/<topic>`.
5. Keep changes small enough to explain instruction-by-instruction.

## Contribution standards

- All guest/target runtime routines must be in NASM Assembly. No C/C++ kernel source.
- CMake, shell host scripts, and Markdown are fine for development infrastructure.
- Prefer one `.asm` file per hardware/service area once a subsystem exists.
- Document routine input, output, clobbered registers and side effects.
- Ensure buffers have explicit capacities and error paths.
- Include the exact build/run/test steps used. Do not claim QEMU tests from static inspection alone.
- Update README/roadmap feature status with actual implementation state.
- Do not add generated object files, ISOs, map files, or `build/` output to Git.

## Pull request checklist

- [ ] No target C or C++ introduced.
- [ ] All files assemble and link with `cmake --build build --target kernel`.
- [ ] `cmake --build build --target verify` succeeds.
- [ ] ISO boots in QEMU and previous milestone still works.
- [ ] Inputs are bounded; stack/register conventions are met.
- [ ] Docs and test cases reflect this change.

## Bug reports

Provide Ubuntu version, relevant tool versions, exact failing command, complete output, expected behavior, and minimum reproduction steps. For guest faults include `info registers` and disassembly if possible.
