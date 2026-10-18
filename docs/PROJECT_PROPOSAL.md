# Academic Project Proposal — TinyOS (Assembly-Only)

## Title

**TinyOS: An Educational 32-bit x86 Operating System Kernel Implemented Entirely in Assembly**

## Abstract

TinyOS is a small, bare-metal monolithic operating-system kernel for a 32-bit x86 virtual computer. The system will be developed in NASM Assembly with GRUB/Multiboot v1 for bootstrapping, GNU Binutils for ELF32 linking, CMake for repeatable builds, and QEMU/GDB for emulation and debugging. The first milestone provides a working protected-mode Assembly entry, private stack and VGA text output. Subsequent milestones target exception handling, hardware IRQs, PS/2 keyboard input, and a command-driven kernel shell. An in-memory directory model is optional if time permits.

## Motivation

The project applies concepts typically taught separately in COAL: instruction execution, calling conventions, address spaces, memory-mapped devices, I/O ports, privilege, interrupts, executable formats and low-level debugging.

## Objectives

1. Produce a bootable standalone Assembly kernel, without any C or operating-system runtime.
2. Explain and implement the GRUB-to-kernel transition and ELF32 memory layout.
3. Print through VGA memory and build basic console services.
4. Implement exception/interrupt and keyboard handling.
5. Provide an interactive shell with implemented built-in commands.
6. Demonstrate repeatable builds, QEMU operation and GDB debugging.

## Tools and technologies

Ubuntu, NASM, `i686-elf-ld`, CMake, GNU Make (optional wrapper), GRUB 2, `grub-mkrescue`, QEMU system-i386, GDB multiarch, Git.

## Methodology

Build a vertical slice at a time, test each in QEMU, validate ELF/Multiboot compliance, and only begin dependent subsystems after previous acceptance criteria pass. Architecture is monolithic with separate `.asm` modules and documented register/stack contracts.

## Scope and outcomes

Required result: reproducible bootable kernel, VGA console, diagnostic exceptions, keyboard input, and minimal commands. Optional result: RAM-backed directory tree (`ls`, `pwd`, `cd`, `cat`). Out of scope: GUI, network, disk drivers, multitasking, userspace and Linux compatibility.

## Evaluation

Source review (Assembly only), bootability, behavior demonstrated in QEMU, robustness of input/interrupt handling, conceptual explanation, documentation and reproducible build.
