# Six-Week Roadmap — 100% NASM Assembly

**Schedule:** six focused development weeks, with study and development time adjusted to coursework; reduce scope rather than hiding missed work. The weeks are **phases**, not guaranteed dates. Do not start a later phase until the previous phase's acceptance checks pass.

| Week | Primary outcome | Must demonstrate | Stretch |
|---|---|---|---|
| 1 | Boot chain and first VGA text | GRUB loads Multiboot ELF, text visible, clean halt | Color, second row |
| 2 | Console + exceptions | Clear, newline, scrolling, IDT and one safe exception demo | UART serial |
| 3 | IRQ/PIC + keyboard | IRQ1 scancodes read and translated, bounded buffer | Shift/caps behavior |
| 4 | Shell input and dispatch | Prompt; `help`, `clear`, `echo`, `hostname`, `uname` work | Backspace/history polish |
| 5 | Robustness + optional RAMFS | Stable shell, tested parser; optionally `ls`, `pwd`, `cd`, `cat` on tree | RAM memory info |
| 6 | Testing, documentation and presentation | Clean build on new host; reproducible QEMU demo | Extra commands/allocator |

## Week 1 — Boot and toolchain

Read [phases/PHASE_1_BOOT.md](phases/PHASE_1_BOOT.md).

- [ ] Understand header, ELF sections, entry point, stack and VGA.
- [ ] Verify host environment, configure CMake, build ELF, check Multiboot header.
- [ ] Build GRUB ISO; boot in QEMU and observe initial text.
- [ ] Make one controlled source edit, rebuild, re-test.
- [ ] Capture a verified screenshot/terminal transcript and commit.

## Week 2 — Console and CPU exception safety

Read [phases/PHASE_2_CONSOLE_EXCEPTIONS.md](phases/PHASE_2_CONSOLE_EXCEPTIONS.md).

- [ ] Extract VGA printing to independent Assembly module with a clear ABI.
- [ ] Implement bounded print, newline, scroll and `clear` with tests.
- [ ] Add diagnostic output (serial if feasible).
- [ ] Construct IDT and ISRs; handle one deliberate, isolated divide-by-zero test.
- [ ] Ensure exception tests terminate in a controlled manner.

## Week 3 — Hardware IRQ and keyboard

Read [phases/PHASE_3_KEYBOARD.md](phases/PHASE_3_KEYBOARD.md).

- [ ] Explain PIC ports, offsets, masks, IRQ1, `iret` and EOI.
- [ ] Safely initialize PIC/IDT; don't enable interrupts before handler readiness.
- [ ] Receive keyboard IRQ1 and decode a small documented subset.
- [ ] Queue input events in fixed-size storage; verify overflow handling.
- [ ] Test Enter, Backspace, ordinary letters, and key-release filtering.

## Week 4 — Shell

Read [phases/PHASE_4_SHELL.md](phases/PHASE_4_SHELL.md).

- [ ] Build a simple line editor and prompt.
- [ ] Implement bounded tokenization and command dispatch.
- [ ] Implement `help`, `clear`, `echo`, `hostname`, `uname` in Assembly.
- [ ] Test unknown commands, empty input and maximum line length.

## Week 5 — Filesystem optional; consolidation mandatory

Read [phases/PHASE_5_RAMFS.md](phases/PHASE_5_RAMFS.md).

- [ ] Fix bugs found in shell/input/conventions and add regression tests.
- [ ] **Only if stable:** create static directory tree and implement real `ls`, `pwd`, `cd`.
- [ ] Optional `cat` of built-in text and memory info.
- [ ] If schedule is tight, omit RAMFS and spend time on correct keyboard/shell behavior.

## Week 6 — QA and demo

Read [phases/PHASE_6_RELEASE.md](phases/PHASE_6_RELEASE.md).

- [ ] Clean-build with setup guide from a fresh clone/build directory.
- [ ] Confirm actual-feature table; remove premature check marks.
- [ ] Document boot sequence and CPU state with graphics or annotated code.
- [ ] Do one end-to-end QEMU demo and one GDB inspection.
- [ ] Produce 2–3 minute walkthrough and a concise presentation.

## Stop/go quality gates

1. Can't boot? No IDT yet.
2. VGA unstable? No more drivers.
3. Exception recovery broken? No `sti`.
4. IRQ1 unreliable? No shell input yet.
5. Input not bounded? No command parser yet.
6. Shell not robust? RAMFS is optional, not blocking graduation.

## Work tracking

Keep each phase task as a small GitHub issue or `TODO.md` checkbox. Commit only after its associated test. Do not commit a fabricated screenshot or claim tests you couldn't perform.
