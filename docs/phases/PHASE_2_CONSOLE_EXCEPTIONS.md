# Phase 2 — VGA Console, Serial Diagnostics, CPU Exceptions

**Goal:** Move beyond hardcoded lines and make CPU failures diagnosable.

## Learn
- VGA 80×25 text cells, row/column index, scroll/cursor state.
- CPU exception vectors; 32-bit IDT gates; `lidt`; `iret/iretd`.
- Some exception types push an error code, others don't.
- Optional UART COM1 port I/O and line status bits.

## Tasks
- [ ] Extract `vga_write`/`vga_clear` into `src/drivers/vga.asm`.
- [ ] Add handling for `\n`, overflow, scrolling and bounded strings.
- [ ] Implement `console_write` with a documented register/stack ABI.
- [ ] Add 256-entry IDT or a correctly sized table for the subset with safe fallback handlers.
- [ ] Add exception stubs that normalize error-code/no-error-code frames.
- [ ] Log or display vector code before a safe halt.
- [ ] Test deliberate divide-by-zero in an isolated debug build, not ordinary startup.
- [ ] Optional: initialize serial and emit log tags.

## Acceptance
- Console can repeatedly print lines without screen corruption.
- At least one deliberate CPU exception reaches the intended handler and fails gracefully.
- All IDT entry pointers/selectors and saved registers are reviewed before IRQs are enabled.

## Pitfalls
- Returning into the same faulting divide instruction causes endless faults.
- Using the same stack offsets for all exception types is wrong.
- Enabling `sti` without a ready IDT can cause guest reset/triple fault.
