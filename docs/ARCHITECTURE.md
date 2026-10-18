# TinyOS Architecture (Design, Not an Implementation Claim)

## System boundary

```text
Ubuntu host
  CMake -> NASM ELF32 objects -> i686-elf-ld -> kernel.elf
       -> GRUB ISO -> QEMU system-i386
                                     |
                                  BIOS / GRUB
                                     |
                              Multiboot v1 handoff
                                     |
                               boot/boot.asm
                          set stack, call kernel_main
                                     |
                               src/kernel.asm
                          VGA print, return, HLT

Future kernel modules (not yet present):
  CPU/exception stubs -> PIC/IRQ -> PS/2 input -> shell -> RAMFS
```

## Target CPU and privileged state

- Architecture: **Intel-compatible IA-32/i686**, 32-bit protected mode.
- GRUB's Multiboot v1 entry contract provides a working 32-bit execution environment; however, we still initialize **our own stack**. We may later install our own GDT.
- Start with **paging disabled**, no process scheduler, no ring-3 userspace, and no syscalls.
- Single-core virtual machine, deterministic fixed-size buffers before any heap allocator exists.
- Current first implementation does **not** enable interrupts (`cli`).

## Current boot entry contract

1. GRUB locates the 12-byte Multiboot header in `kernel.elf`.
2. GRUB loads segments according to ELF program headers, not source-file order alone.
3. GRUB enters `_start`; `EAX` contains the Multiboot loader magic, `EBX` points to Multiboot info.
4. `boot.asm` disables maskable IRQ handling and installs a private 16-KiB stack.
5. `_start` pushes `(info_ptr, magic)` to call the Assembly function `kernel_main(magic, info_ptr)`.
6. `kernel_main` validates the magic and writes directly to three VGA text rows.
7. Control returns to `_start`, which executes an `HLT` loop with interrupts disabled.

The Multiboot information pointer must not be dereferenced until a structure definition and validation are implemented.

## Module boundaries for later milestones

| Planned module | Input | Output / responsibility | Prerequisite |
|---|---|---|---|
| Console | characters, attributes | VGA text buffer writes, scrolling | Boot + VGA |
| Serial logger | bytes | UART COM1 diagnostics | I/O port knowledge |
| CPU/GDT | GDT descriptors | `lgdt`, valid selectors | Boot |
| IDT/exception stubs | vector, CPU stack frame | Valid handler dispatch, diagnostics | Console/serial |
| PIC/IRQ | IRQ mask/remap | Hardware interrupt routing/EOI | IDT |
| PS/2 driver | port data/scancode | decoded key events into queue | PIC/IRQ |
| Input line editor | decoded key events | bounded NUL-terminated line | Console + keyboard |
| Shell | input line | handler dispatch, prompt | Line editor |
| RAMFS | path / directory node | genuine listing, cwd, file reads | String helpers + shell |
| Allocator (stretch) | allocation size/alignment | kernel-only memory region | memory-map validation |

## Proposed module tree as project grows

```text
boot/
  boot.asm                       # already exists
src/
  kernel.asm                     # already exists; grows into orchestration
  arch/x86/gdt.asm               # future
  arch/x86/idt.asm               # future
  arch/x86/isr_stubs.asm         # future
  arch/x86/pic.asm               # future
  drivers/vga.asm                # future
  drivers/serial.asm             # future
  drivers/ps2_keyboard.asm      # future
  lib/string.asm                 # future
  shell/input.asm                # future
  shell/dispatch.asm             # future
  shell/commands.asm             # future
  fs/ramfs.asm                   # future
```

**Don't create these future `.asm` files just to look complete.** Create files when a tested feature needs them.

## RAM and address assumptions

- Kernel link base: 1 MiB via linker script. This is not a universal memory-map guarantee; verify against boot information as features evolve.
- Stack: 16 KiB reserved in `.bss`; no guard page, no overflow protection in Phase 1.
- VGA: `0xB8000` physical address with initial flat segmentation and paging off; valid for the chosen VGA/BIOS path, not for arbitrary hardware or graphics modes.
- No kernel heap at initial boot; use bounded static buffers.

## Design decisions

- **Monolithic but modular:** all kernel modules are linked together into one ELF32 image.
- **GRUB over custom boot sector:** kernel-focused COAL scope and reliable Multiboot handoff.
- **Multiboot v1:** simple, well-documented, compatible with the selected GRUB flow; **not** Multiboot2.
- **32-bit over 64-bit:** matches course focus and small-kernel instructional examples.
- **CMake over manual commands:** builds are repeatable while keeping complete visibility into each tool.
- **No C or C++:** strict course requirement; host scripting/build metadata is not target kernel code.
- **VGA then serial:** show visible proof early, add robust diagnostics before IRQ complexity.
- **Static RAMFS before disk drivers:** real directory traversal without block-device complexity.

## Where architecture changes need review

- Adding paging changes address calculations and device-memory mapping.
- Enabling interrupts requires valid IDT, IRQ stubs, PIC masks/remap and EOI behavior.
- General-purpose calling conventions require documented saved/clobbered registers.
- Adding disk I/O, process scheduling or userspace changes the entire scope; treat as V2.
