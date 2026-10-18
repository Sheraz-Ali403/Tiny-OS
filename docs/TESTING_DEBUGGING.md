# Testing and Debugging Strategy

## Distinguish validation layers

1. **Host setup:** binaries exist and can be invoked.
2. **Assembler/linker:** NASM emits valid ELF32 objects, cross linker resolves symbols.
3. **Image format:** `readelf` reports ELF32 i386, `grub-file --is-x86-multiboot` succeeds.
4. **ISO package:** `grub-mkrescue` generates ISO and GRUB can locate `/boot/kernel.elf`.
5. **Guest runtime:** QEMU visibly boots and prints correct message without resets.
6. **Feature behavior:** independent functional tests for keyboard, shell, commands and RAMFS as those exist.

Passing a format check does **not** prove the kernel boots. Creating an ISO does **not** prove keyboard input works.

## Phase 1 commands

```bash
./scripts/check-env.sh
cmake -S . -B build
cmake --build build --target verify
cmake --build build --target iso
file build/kernel.elf
readelf -h build/kernel.elf
grub-file --is-x86-multiboot build/kernel.elf
cmake --build build --target run
```

Expected runtime proof: three VGA text lines and no crash/reboot. Close QEMU to terminate the test.

## GDB walkthrough

Terminal A:

```bash
cmake --build build --target debug
```

Terminal B:

```bash
gdb-multiarch build/kernel.elf
```

GDB:

```text
set architecture i386
target remote 127.0.0.1:1234
break _start
continue
info registers
x/10i $eip
break kernel_main
continue
x/8wx $esp
x/24bx 0xB8000
```

At `_start`, inspect GRUB-provided `EAX` and `EBX`. At `kernel_main`, inspect the stack-passed magic at `$esp+4`. Text mode VGA memory can be inspected as raw bytes, two per character cell. GDB can also read kernel symbols in the ELF.

## Suggested manual test matrix

| Stage | Positive case | Negative/boundary case |
|---|---|---|
| Boot | Text visible | Corrupt header (in disposable copy) must be rejected by `grub-file` |
| VGA console | Print to multiple rows | At row/column boundaries, scrolling |
| IDT | An intentional diagnostic exception | Unexpected vector and controlled halt |
| PIC/IRQ | Recognized keyboard IRQ | Other IRQ masked or safely handled |
| Keyboard | Ordinary press, Enter, Backspace | Key release, repeated keys, overflow |
| Shell | Known command | Empty input, unknown command, long line |
| RAMFS | Navigate root and nested path | Missing path, `..` at root, invalid type |

## Regression rules

- Every new module must preserve previous successful QEMU startup.
- Test with a clean build directory before labeling a phase complete.
- For hardware handlers, exercise both normal and failure paths.
- Never trigger exception tests without a controlled end state; unexpected reboot indicates a likely triple fault.
- Keep test evidence separate from planned examples. Record versions and real output when debugging.

## Troubleshooting information to collect

Include: exact command, entire error output, `nasm -v`, `i686-elf-ld --version`, `cmake --version`, `grub-mkrescue --version`, `qemu-system-i386 --version`, and latest source change. For assembly faults, include a GDB register snapshot and relevant disassembly.
