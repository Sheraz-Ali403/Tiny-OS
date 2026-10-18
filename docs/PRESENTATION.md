# COAL Demonstration and Viva Preparation

## 3-minute project story

**Problem:** Assembly/COAL concepts are abstract when studied as isolated instructions.  
**Solution:** TinyOS boots a real 32-bit x86 guest from a GRUB ISO and executes only our Assembly kernel.  
**Evidence:** Show `boot.asm`, `readelf`, `grub-file`, then QEMU screen and later (if implemented) an actual keyboard-driven shell.  
**Takeaway:** Know who initializes the CPU, where the stack comes from, what the linker does, how hardware output works, and how an IRQ becomes an Assembly handler.

## Recommended slides

1. Project goal and strict Assembly-only course constraint.
2. Host build chain (CMake/NASM/linker/GRUB/QEMU).
3. Multiboot v1 contract (`_start`, `EAX`, `EBX`, stack).
4. ELF sections and VGA text memory.
5. Interrupt architecture (planned or implemented label required).
6. Live demo (only existing features).
7. Lessons, bugs fixed, limitations, next release.

## Common professor questions

**Why not use `int 0x21`?** It is a DOS service interface. DOS isn't running beneath TinyOS.

**Why not Linux `int 0x80`?** A Linux system-call handler is not present in our kernel.

**Why GRUB?** It handles boot loading and enters the standardized Multiboot contract; we focus on writing the operating system.

**Why ELF32?** It supports linked sections, symbols, and loader-readable program headers at i686 target width.

**What exactly is CMake doing?** Invoking NASM, linker, GRUB and QEMU in the correct dependency order. It is not translating source into machine code itself.

**What makes the result an OS?** It is standalone privileged kernel code run directly on a virtual machine; as more modules are added it handles its own console, CPU exceptions and device input. The first boot milestone is a tiny kernel, not yet a full-featured OS.

**How is the shell different from Bash?** Built-in command dispatcher in kernel mode; no Linux processes, userspace or POSIX ABI.

**What happens on a divide-by-zero?** CPU raises an exception; once an IDT handler is installed it records a diagnostic and halts. Without an exception handler, the guest may reset/triple-fault.

**Why no Linux kernel modules?** There is no Linux kernel here; TinyOS components are statically linked, not Linux ABI-compatible LKMs.

## Evidence checklist

- [ ] Fresh clean-build output.
- [ ] `readelf`/`grub-file` validation.
- [ ] Real QEMU boot demonstration.
- [ ] Actual GDB register values or disassembly.
- [ ] At least one end-to-end user interaction once keyboard/shell exists.
- [ ] Honest list of implemented, planned, and excluded features.
