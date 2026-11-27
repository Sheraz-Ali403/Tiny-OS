# TinyOS — 32-bit x86 Assembly Operating System

TinyOS is a small educational operating system kernel written entirely in **32-bit NASM Assembly**. It is developed as a Computer Organization and Assembly Language (COAL) project to explore low-level x86 architecture, protected mode, interrupt handling, hardware interaction, and basic operating system components.

The kernel boots through **GRUB 2 using the Multiboot v1 specification** and runs as a 32-bit x86 system in QEMU.

## Project Overview

TinyOS began as a minimal bootable kernel and was gradually extended with CPU tables, hardware interrupt handling, keyboard input, paging, a basic shell, and an in-memory filesystem.

The project focuses on understanding how an operating system interacts directly with the processor and hardware without relying on a high-level language or an existing operating system kernel.

**Implementation language:** NASM x86 Assembly  
**Architecture:** 32-bit x86 (i686)  
**Bootloader:** GRUB 2  
**Boot protocol:** Multiboot v1  
**Build system:** CMake  
**Linker:** i686-elf-ld  
**Emulator:** QEMU  
**Development environment:** Ubuntu Linux

All target-side kernel components are implemented in Assembly. No C or C++ source files are used in the kernel.

## Features

### 1. Boot Process

- GRUB Multiboot v1 boot support.
- Multiboot header and checksum.
- Custom 16 KiB kernel stack.
- Kernel entry point and bootloader information handling.
- ELF32 kernel linking.
- GRUB bootable ISO generation.

### 2. Global Descriptor Table (GDT)

- GDT initialization and loading using `LGDT`.
- Null descriptor.
- Kernel code and data segment descriptors.
- Flat 32-bit memory segmentation.
- Kernel code and data selectors.
- Segment register initialization and code segment reload.

### 3. Interrupt Descriptor Table (IDT)

- 256-entry IDT.
- CPU exception handlers for vectors 0–31.
- Default handler for unexpected interrupt vectors.
- Interrupt gate configuration.
- Hardware interrupt entries for timer and keyboard.
- Exception information collection.
- Custom VGA kernel panic screen displaying exception details.

### 4. Programmable Interrupt Controller (PIC)

- Master and slave 8259-compatible PIC initialization.
- Interrupt vector remapping.
- Master PIC offset: `0x20`.
- Slave PIC offset: `0x28`.
- IRQ masking and unmasking.
- End-of-interrupt (EOI) signaling.

### 5. Programmable Interval Timer (PIT)

- PIT channel 0 configuration.
- Approximately 100 Hz timer frequency.
- Timer interrupt handling through IRQ0.
- Global timer tick counter.
- Timer information used by the shell.

### 6. Keyboard Input

- PS/2 keyboard interrupt handling through IRQ1.
- Keyboard data read from I/O port `0x60`.
- Set 1 scancode decoding.
- Key press and release detection.
- Extended scancode prefix handling.
- Pause-key sequence handling.
- Lowercase ASCII translation.
- Separate tracking of normal and extended key states.
- 128-byte circular input buffer.
- Keyboard character retrieval routine.
- Line input processing with Backspace and Enter support.
- Input line buffer with a maximum of 79 printable characters.

Shift-based uppercase translation and Caps Lock support are not currently implemented.

### 7. VGA Text Mode

- Direct access to VGA text memory at `0xB8000`.
- 80-column by 25-row text display.
- Character and string output.
- Text color attributes.
- Screen clearing.
- Newline and cursor positioning.
- Basic scrolling.
- Decimal number output.
- Keyboard input display.

### 8. Paging

- 32-bit paging initialization.
- Page directory and page table creation.
- Identity mapping of the first 4 MiB of memory.
- Page table alignment.
- Page directory loading through CR3.
- Paging activation through the PG bit in CR0.

The current implementation maps the first 4 MiB; it is not a complete virtual memory manager.

### 9. RAM-Based Filesystem

TinyOS includes a simple fixed-slot in-memory filesystem (RAMFS).

Current design limits:

- Maximum files: 16.
- Maximum filename length: 15 characters.
- Maximum file content: 511 bytes.
- File metadata and content stored in kernel memory.
- File creation, reading, overwriting, and deletion.

This filesystem is volatile. Its contents are not saved to a disk or persistent storage device.

### 10. Basic Command Shell

The Assembly-written shell includes the following commands:

| Command | Description |
|---|---|
| `help` | Displays available commands. |
| `clear` | Clears the VGA screen. |
| `ticks` | Displays timer ticks and uptime. |
| `ls` | Lists files in RAMFS. |
| `cat <file>` | Displays file contents. |
| `touch <file> <text>` | Creates or updates a file. |
| `rm <file>` | Deletes a file. |
| `panic` | Triggers an exception to test the panic handler. |

The shell reads input through the keyboard driver and uses the RAMFS routines for file operations.

## Project Structure

```text
Tiny-OS/
├── boot/
│   └── boot.asm
│
├── src/
│   ├── kernel.asm
│   ├── gdt.asm
│   ├── idt.asm
│   ├── pic.asm
│   ├── irq.asm
│   ├── keyboard.asm
│   ├── paging.asm
│   ├── ramfs.asm
│   ├── shell.asm
│   └── timer.asm
│
├── linker/
│   └── linker.ld
│
├── grub/
│   └── grub.cfg
│
├── scripts/
│   └── check-env.sh
│
├── docs/
│
├── CMakeLists.txt
├── TODO.md
└── i686-elf-tools.sh
```

**Note:** `timer.asm` is currently excluded from the CMake build. The active PIT configuration and timer interrupt counter are implemented in `irq.asm`.

## Build Requirements

The following tools are required:

- Ubuntu Linux or a compatible Linux environment.
- NASM.
- CMake 3.20 or later.
- `i686-elf-ld`.
- GRUB utilities (`grub-file` and `grub-mkrescue`).
- QEMU (`qemu-system-i386`).
- ISO creation support, such as `xorriso`, for GRUB ISO generation.

Run the environment checker:

```bash
./scripts/check-env.sh
```

Make sure all required tools are installed and available in your system PATH.

## Building and Running

Clone the repository:

```bash
git clone https://github.com/Sheraz-Ali403/Tiny-OS.git
cd Tiny-OS
```

Configure the project:

```bash
cmake -S . -B build
```

Build the kernel:

```bash
cmake --build build
```

Verify the Multiboot header:

```bash
cmake --build build --target verify
```

Generate the bootable ISO:

```bash
cmake --build build --target iso
```

Run TinyOS in QEMU:

```bash
cmake --build build --target run
```

The generated ISO is located at:

```text
build/tinyos.iso
```

## Available CMake Targets

| Target | Purpose |
|---|---|
| `kernel` | Assemble and link the kernel ELF. |
| `verify` | Verify the Multiboot header. |
| `iso` | Generate the bootable ISO. |
| `run` | Launch TinyOS in QEMU. |
| `debug` | Launch QEMU paused with a GDB remote debugging port. |

The debug target exposes a GDB stub on `127.0.0.1:1234`.

## Current Limitations

TinyOS is an educational kernel and is not intended for production use.

Current limitations include:

- No user-mode applications or privilege separation.
- No process management or multitasking scheduler.
- No general-purpose kernel memory allocator.
- Paging currently covers only the first 4 MiB.
- No disk driver or persistent filesystem.
- RAMFS contents are lost when the system restarts.
- Keyboard modifiers such as Shift and Caps Lock are not implemented.
- Hardware support is limited to the currently implemented components.
- Runtime testing on physical hardware has not been established.

Some later subsystems are present in the source code but should receive further integration and regression testing.

## Learning Objectives

The project explores several important systems programming concepts:

- x86 protected mode and segmentation.
- GDT and IDT architecture.
- CPU exceptions and interrupt handling.
- PIC remapping and hardware IRQs.
- PIT timer configuration.
- Keyboard scancode decoding.
- Direct memory and I/O port access.
- VGA text-mode output.
- 32-bit paging and address translation.
- Circular buffers and line input.
- Basic command parsing and RAM-based file management.
- Assembly-level modular programming and linking.

## Contributors

- Sheraz Ali
- Ahmed Shaikh
- Hamza Raza

## Disclaimer

TinyOS is an academic and educational project created to explore operating system fundamentals and low-level x86 Assembly programming.

It is not a replacement for a general-purpose operating system.

---

**Repository:** https://github.com/Sheraz-Ali403/Tiny-OS

**License:** Refer to the repository for licensing information.
