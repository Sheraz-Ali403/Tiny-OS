# COAL Concept → Where It Appears in TinyOS

Use this as a study/viva cheat sheet. Some components are **planned**, so don't claim their source files exist yet.

| Course concept | Location / future area | What it demonstrates |
|---|---|---|
| Data declarations (`dd`, `db`, `resb`) | `boot/boot.asm`, `src/kernel.asm` | Multiboot header words, strings, uninitialized stack |
| CPU registers (`EAX`, `EBX`, `ESP`) | `boot/boot.asm` | Bootloader handoff, saved Multiboot values and stack |
| Instructions `CALL`, `RET` | `boot/boot.asm` / `src/kernel.asm` | Real routine handoff and stack return address |
| Memory addressing | `src/kernel.asm` | Reading `[esp+4]` and direct VGA memory writes |
| String instructions (`LODSB`, `STOSW`) | `src/kernel.asm` | Byte iteration, char+color VGA cells, direction flag |
| Sections and symbols | `linker/linker.ld` / NASM source | Text/rodata/bss layout, `global` and `extern` linking |
| `CLI` and `HLT` | `boot/boot.asm` | Privileged CPU interrupt state and halt loop |
| Protected mode / GDT | future `arch/x86/gdt.asm` | Segment descriptor layout and selector loading |
| IDT and CPU exceptions | future `arch/x86/idt.asm` | Processor-driven vectors and handler gates |
| Hardware I/O `IN`, `OUT` | future PIC/keyboard modules | Reading/writing hardware controller ports |
| PIC interrupts and `IRETD` | future `arch/x86/pic.asm` / stubs | IRQ path, register save, EOI, interrupt return |
| Bitwise operations | future scancode and PIC code | Masks, flag checks, bitfield extraction |
| Static arrays/buffers | future keyboard/shell modules | Bounded queue, command-line storage |
| String comparison/parsing | future `lib/string.asm` / shell | Command parsing and exact lookup |
| Pointers/linked records | future RAMFS node tables | Parent/child/sibling directory traversal |
| Binary/ELF/linking | CMake and linker docs | `.asm` → `.o` → `.elf` → `.iso` toolchain |

## Questions worth practicing

- After GRUB transfers control, which registers carry the Multiboot data and what does TinyOS do with them?
- Where exactly are `boot.o` and `kernel.o` combined?
- Why can't TinyOS call Linux `printf`?
- Why is `AH` loaded with a VGA attribute before `STOSW`?
- What goes wrong if you enable interrupts before installing an IDT?
- How will the keyboard ISR and shell thread-of-control share input safely without a scheduler?
