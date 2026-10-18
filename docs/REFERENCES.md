# References and Reading Order

Prefer primary specifications/manuals first; tutorials are useful explanations, not substitutes for a design review.

1. **GNU Multiboot Specification v0.6.96 (Multiboot v1)** — https://www.gnu.org/software/grub/manual/multiboot/multiboot.html  
   Mandatory for header fields, entry magic, boot information, CPU entry contract.
2. **OSDev Wiki: Bare Bones** — https://wiki.osdev.org/Bare_Bones  
   Educational reference for 32-bit ELF/GRUB boot path; note that many examples use GCC/C, whereas this project is Assembly-only.
3. **NASM documentation** — https://www.nasm.us/docs.php  
   Sections, `global`, `extern`, directives and `elf32` output.
4. **CMake `add_custom_command` reference** — https://cmake.org/cmake/help/latest/command/add_custom_command.html  
   Dependency-based execution of assembler/linker/ISO commands.
5. **CMake `add_custom_target` reference** — https://cmake.org/cmake/help/latest/command/add_custom_target.html  
   `kernel`, `iso`, `verify`, `run`, `debug` targets.
6. **GNU ld linker scripts** — https://sourceware.org/binutils/docs/ld/Scripts.html  
   Understanding memory layout and entry-point selection.
7. **GNU GRUB manual** — https://www.gnu.org/software/grub/manual/grub/grub.html  
   GRUB configuration, `multiboot` command, BIOS boot.
8. **QEMU documentation** — https://www.qemu.org/docs/master/system/  
   System emulation, x86 options, GDB stub.
9. **GDB manual** — https://sourceware.org/gdb/current/onlinedocs/gdb.html  
   Remote debugging, breakpoints and register inspection.
10. **OSDev Wiki: Interrupt Descriptor Table** — https://wiki.osdev.org/Interrupt_Descriptor_Table  
    IDT entry structure and exception conventions; read during Phase 2.
11. **OSDev Wiki: PIC** — https://wiki.osdev.org/8259_PIC  
    Legacy PIC remapping, IRQ masking and EOI, for Phase 3.
12. **OSDev Wiki: PS/2 Keyboard** — https://wiki.osdev.org/PS/2_Keyboard  
    Scancodes and controller behavior, for Phase 3.

## Reading strategy

**Week 1:** Multiboot spec, NASM, ELF, linker scripts, CMake.  
**Week 2:** VGA, IDT and exceptions.  
**Week 3:** PIC, PS/2 keyboard.  
**Week 4:** Assembly calling conventions, bounded strings and shell parsing.  
**Week 5:** Tree traversal and path resolution if RAMFS is attempted.  
**Week 6:** Testing and presentation.

Always distinguish a protocol requirement from a tutorial's personal implementation choices.
