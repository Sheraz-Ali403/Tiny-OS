# Instructions for AI Coding Assistants Working on TinyOS

## Context

This is a COAL university project: **32-bit x86, NASM Assembly-only kernel**, GRUB 2, Multiboot v1, ELF32, `i686-elf-ld`, CMake build, QEMU runtime. It is an educational minimal monolithic OS, not Linux or a production system.

## Mandatory rules

1. **Never introduce C, C++, Rust, libc, Linux syscalls, DOS APIs, or system APIs in target code.** Host setup shell scripts and CMake are allowed.
2. **Do not generate a whole new OS** when asked to explain or fix a small milestone. Preserve known working assembly and fix the smallest scope.
3. Make the build use only NASM + `i686-elf-ld` for target executable artifacts.
4. Preserve Multiboot v1 metadata, the entry point and linker constraints. Verify with `grub-file`.
5. Do not set `PREFIX` permanently in contributor shell startup instructions (NVM conflict).
6. Never pretend features exist: the checked-in starter has boot/VGA output only.
7. Follow `docs/IMPLEMENTATION_CONTRACTS.md` before adding ABI-exposed routines or IRQs.
8. Separate CPU exceptions, PIC interrupts, keyboard ISR and shell input clearly; enable interrupts only when safe.
9. Always account for valid memory ranges, data widths, bounds, stack balance and register clobbers.
10. Be explicit about tool validation: state what was actually tested versus inferred by review.

## Teaching-first interaction

Explain the relevant CPU/hardware state, expected instructions, meaning of constants, and control flow before presenting new implementation. Encourage the student to author and understand the code. Show incremental diffs and short test cases; never treat automatic code generation as proof of understanding.

## Initial commands

```bash
./scripts/check-env.sh
cmake -S . -B build
cmake --build build --target verify
cmake --build build --target iso
cmake --build build --target run
```

## Change checklist

- Does it meet the current phase's acceptance criteria?
- Is it pure NASM target code?
- Can a classmate follow the updated setup and test documentation?
- Is the claim of runtime correctness backed by a real QEMU run?
