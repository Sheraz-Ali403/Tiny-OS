# Phase 3 — PIC, IRQ and PS/2 Keyboard Input

**Goal:** Convert real (emulated) keyboard IRQs into buffered input characters.

## Learn
- Programmable Interrupt Controller: master/slave PIC, IRQ masks and remapping.
- `in`/`out`, port `0x60`, keyboard status port `0x64`.
- Interrupt acknowledgements (EOI), ISR stack save/restore and `iretd`.
- Scancode make/break events and a basic US keyboard mapping.

## Tasks
- [ ] Remap PIC to a safe offset away from CPU exception vectors.
- [ ] Mask unhandled IRQs; enable only required lines after handlers are installed.
- [ ] Build IRQ1 Assembly stub and handler; verify stack-frame correctness.
- [ ] Read scancodes safely and handle key releases.
- [ ] Decode letters/digits/space/Enter/Backspace for a documented layout.
- [ ] Enqueue characters/events into a bounded buffer.
- [ ] Avoid doing full shell parsing or unbounded VGA printing inside ISR.
- [ ] Send required EOI(s), then return via `iretd`.
- [ ] Test repeated keystrokes, input bursts, queue full behavior and modifiers.

## Acceptance
- QEMU key presses are received consistently without lockup.
- No buffer overflow; nonprinting scancodes are not treated as ASCII.
- IRQ handler and EOI behavior verified using a small trace/debug approach.
