# Implementation Contracts: Rules for Safe Modular Assembly

These contracts keep separate NASM modules interoperable. They are **internal project agreements**, not Linux/Windows calling conventions.

## 1. Kernel entry from GRUB

- Protocol: Multiboot v1 (not Multiboot2).
- At `_start`: 32-bit protected mode, `EAX` bootloader magic (`0x2BADB002`), `EBX` Multiboot information pointer.
- `_start` configures the private stack and disables interrupts before calling any routines.
- We must **not** assume the Multiboot info pointer is safe without validating magic/structure/data ranges.
- GRUB has initialized some CPU state; don't rely on its GDT remaining a permanent part of TinyOS once we customize hardware setup.

## 2. Assembly routine ABI

For **future new routines** we propose a small cdecl-like stack ABI:

- Arguments pushed **right to left**; caller pops them after return.
- Return value: `EAX` (32-bit). For a 64-bit return, document both halves explicitly.
- Callee preserves: `EBX`, `ESI`, `EDI`, `EBP`, `ESP` (balanced stack).
- Caller assumes `EAX`, `ECX`, `EDX`, and status flags may be clobbered.
- Maintain **16-byte stack alignment at cross-module call sites** as a project convention; document any exceptions, particularly ISR entry.
- Never assume high-level language library helpers exist; avoid unbounded copies/loops.

**Current Phase 1 exception:** the file-local `vga_print_zero_terminated` routine explicitly takes `ESI`, `EDI`, `AH`, and clobbers `EAX/ESI/EDI`. Its contract is local and documented in its source. Refactor it to conform to the general ABI when exporting it across modules. The two-entry call between `boot.asm` and `kernel.asm` is documented as `kernel_main(magic, info_ptr)` with arguments on stack.

## 3. Symbol naming and file ownership

- Export an externally callable symbol with `global symbol_name`; import via `extern symbol_name`.
- Use descriptive names (`vga_write`, `pic_send_eoi`, `shell_dispatch`) rather than generic `init` or `print`.
- Document inputs, outputs, clobbered registers and failure semantics above each exported function.
- Keep device port constants in one authoritative module or shared NASM include file once such a need arises.

## 4. Stack and reentrancy

- 16-KiB initial kernel stack is finite. Avoid recursive parser algorithms and huge temporary arrays on stack.
- Interrupt routines must save the appropriate CPU/general registers and restore state before `iretd`.
- CPU exceptions differ: some provide an error code. ISR stubs must normalize stack frames appropriately, rather than always guessing the same offsets.
- Keyboard ISR should be short; enqueue a byte/event and return. Heavy parsing belongs in non-ISR code.
- Use `cli`/`sti` carefully around ISR-shared structures; don't leave interrupts permanently disabled after keyboard initialization.

## 5. Memory buffer and string rules

- All line buffers have a declared **capacity**. Input functions return length and/or status; do not silently truncate without signaling.
- Check buffer space before writing the new character and terminating NUL byte.
- Treat keyboard scancodes as non-text until decoded; key releases and modifiers need explicit state.
- When comparing command names, require exact token length; don't match `ls` with `lshalts`.
- Do not copy bootloader-provided memory structures without validating lengths and boundaries.

## 6. Hardware initialization order

1. Create stable stack and text diagnostics.
2. Install IDT and known-safe exception stubs.
3. Remap/mask PIC correctly, populate the IRQ vectors, and unmask only implemented IRQs.
4. Initialize PS/2 driver buffers and state.
5. Enable maskable interrupts only after all required handlers are valid.
6. Send correct EOI after handling IRQs.

## 7. Errors and kernel halt

- A fatal CPU exception displays a concise vector/error diagnostic if available and enters a safe halt loop (no blind `iret` into a continuing fault).
- The Phase 1 boot loop uses `cli; hlt` behavior (interrupts disabled at `_start`).
- Command errors report a bounded human-readable failure; they must not corrupt other kernel state.

## 8. Code review checklist

- [ ] Every memory write is within intended memory or device range.
- [ ] Stack balance across calls and ISR exits is correct.
- [ ] Register clobbers are documented.
- [ ] Strings and command buffer access are bounded.
- [ ] Input/output assumptions and initialized hardware state are explicit.
- [ ] ELF still passes Multiboot verification; QEMU boot regression still passes.
