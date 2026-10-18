# Learning Checklist — What to Understand, by Subsystem

You already know basic x86 registers, instructions, stack operations, and NASM. This list focuses on **new** OS and hardware concepts. Each section is short; learn it before implementing its corresponding phase. `Know` means be able to explain and demonstrate it without copying a full solution.

## 0. General OS foundations (before Phase 1)

- [ ] Host vs guest: Ubuntu builds the files; QEMU emulates the computer running TinyOS.
- [ ] Kernel vs bootloader: GRUB loads the kernel; TinyOS controls the machine after handoff.
- [ ] 32-bit protected mode vs 16-bit real mode; what GRUB prepares for Multiboot.
- [ ] Privileged instructions; why DOS `int 0x21` / Linux `int 0x80` don't give us OS services.
- [ ] Bare metal/freestanding program: no libc, no standard C entry point, no userspace services.

## 1. Build chain and executable formats (Phase 1)

- [ ] NASM `-f elf32`: produces a relocatable **object**, not a bootable disk by itself.
- [ ] `global` vs `extern`: exporting and resolving symbols across `.asm` modules.
- [ ] Linker: resolves references and places sections/addresses; linker script sets `_start`.
- [ ] ELF32: ELF header, entry point, sections vs program headers, `readelf` and `objdump`.
- [ ] GRUB/Multiboot v1: header magic, checksum, 4-byte alignment, first 8 KiB.
- [ ] Entry-state registers: `EAX=0x2BADB002`, `EBX=Multiboot information pointer`.
- [ ] `ESP`, 16-byte alignment, `CALL`/`RET` and a consistent handoff ABI.
- [ ] CMake configure vs build; object → ELF → ISO → QEMU.

## 2. Display and debug devices (Phase 1–2)

- [ ] VGA text mode: `0xB8000`, each cell = ASCII byte + attribute byte.
- [ ] 80×25 character grid; row offsets = row × 80 × 2; scrolling and cursor state.
- [ ] Memory-mapped I/O vs CPU I/O-port instructions (`in`/`out`).
- [ ] Port-mapped serial COM1 (`0x3F8` base) and UART transmit-ready status.
- [ ] What a fault/triple fault looks like in QEMU; why serial logs help when VGA breaks.

## 3. CPU tables and exceptions (Phase 2)

- [ ] GDT: descriptors, code/data selectors, segmented addresses in 32-bit protected mode.
- [ ] IDT: gate descriptors and vector-to-handler mapping.
- [ ] CPU exceptions vs external hardware interrupts; vectors 0–31 convention.
- [ ] Exception stack frame; which faults push an error code; `iret` and EFLAGS.
- [ ] Assembly entry stubs saving/restoring registers; returning from an exception safely.
- [ ] `cli`/`sti`: interrupt flag; why interrupts must remain disabled until IDT/PIC ready.

## 4. Timer and keyboard (Phase 3)

- [ ] PIC 8259 master/slave, IRQ numbers, remapping, masks, EOIs.
- [ ] IRQ0 timer / IRQ1 keyboard, IDT offsets after PIC remapping.
- [ ] Port `0x60` scancode data and port `0x64` status/controller behavior.
- [ ] PS/2 set-1 translated make/break codes, shift state, ASCII mapping.
- [ ] Ring/fixed queue and producer (ISR) vs consumer (shell) shared-state rules.
- [ ] Do not do long parsing/printing in an ISR; acknowledge interrupt correctly.

## 5. Memory (Phase 4 or optional)

- [ ] Physical vs virtual addresses; paging disabled initially.
- [ ] Multiboot memory map; what is RAM, reserved, or used by kernel/GRUB.
- [ ] `.bss`, preallocated buffers and alignment.
- [ ] Basic bump allocation; limitations (no individual free).
- [ ] Pointer validity, buffer boundaries, overflow, data-layout diagrams.

## 6. Shell and text handling (Phase 4–5)

- [ ] Zero-terminated strings, lengths, bounded copies, null termination.
- [ ] Line editing: Enter, Backspace, printable characters; fixed input buffer.
- [ ] Tokenizer: trim whitespace, split command + arguments, handle empty input.
- [ ] Command table: names → handler addresses; exact matching.
- [ ] Assembly calling convention: argument locations, clobbered registers, stack cleanup.
- [ ] Command failure paths: unknown command, invalid args, too-long input.

## 7. RAM-backed filesystem (stretch / Phase 5)

- [ ] In-memory filesystem is volatile; reboot loses runtime changes.
- [ ] Tree nodes: name, type, parent, children, optional data pointer and length.
- [ ] Absolute vs relative paths; path normalization (`.`, `..`, multiple `/`).
- [ ] Directory enumeration and file reading; bounds-check node traversal.
- [ ] `pwd` reflects current directory; `ls` enumerates real children, not hard-coded text.

## 8. Debugging and engineering (all phases)

- [ ] `grub-file --is-x86-multiboot` and reading linker output.
- [ ] GDB via QEMU GDB stub; `info registers`, `x/i`, breakpoints, stack inspection.
- [ ] Static tests vs hardware-in-QEMU tests; don't claim a guest test unless run.
- [ ] Use git commits per working stage, no generated `build/` commits.
- [ ] Minimal reproducible bug reports with command, version, output, and expected behavior.

## How to use this list

For each phase: read only that phase's bullets; sketch the data flow; write a tiny Assembly experiment; implement one subsystem; test it; explain it in your own words. A checked box must mean understanding demonstrated, not merely reading an article.
