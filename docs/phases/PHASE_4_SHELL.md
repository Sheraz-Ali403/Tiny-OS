# Phase 4 — Command Line and Built-in Shell (NASM)

**Goal:** Type a command at a prompt and have actual Assembly handlers execute.

## Learn
- Fixed-size line buffers with NUL termination.
- Split first token from remaining arguments; exact string match.
- Function pointer/handler table layout (symbol addresses in Assembly).
- Documented register clobbers and stack ABI.

## Tasks
- [ ] Render a prompt using console routines.
- [ ] Read line editor input from keyboard queue; Enter submits line.
- [ ] Backspace erases correctly without underflow.
- [ ] Define 128-byte input buffer with explicit overflow behavior.
- [ ] Implement `str_compare`, `str_length`, and bounded scanning as needed.
- [ ] Dispatch exact command names through table or carefully structured comparisons.
- [ ] Add `help`, `clear`, `echo`, `hostname`, and `uname`.
- [ ] Add `halt` only with a clear explanation of stopping QEMU guest execution.
- [ ] Test empty line, many spaces, unknown name, too-long input and extra arguments.

## Acceptance
- Multiple commands work consecutively, without memory or cursor corruption.
- Commands perform actual handler logic and return to next prompt (except `halt`).
- No reliance on Linux shell or DOS interrupts; this is a kernel-resident shell.
