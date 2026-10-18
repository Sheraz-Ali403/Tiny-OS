# Risks, Limitations, and Scope Controls

## Engineering risks

| Risk | Likely symptom | Mitigation |
|---|---|---|
| Cross toolchain/PATH mismatch | CMake cannot find cross linker | `check-env.sh`, isolated build, NVM-safe PATH |
| Malformed Multiboot header | GRUB refuses kernel | `grub-file` verification in CMake ISO rule |
| Wrong stack/register state | Blank display, crash | explicit ABI, GDB state inspection |
| Invalid IDT/interrupt frame | triple fault, instant reset | exception-only milestone, no premature `sti` |
| PIC EOI/mask mistake | keyboard stops or IRQ storms | IRQ-focused QEMU tests; document registers |
| Keyboard buffer overflow | memory corruption | bounded ring/line buffers and overflow tests |
| RAMFS scope creep | project misses deadline | treat RAMFS as stretch; prioritize reliable shell |
| Fake confidence from static checks | guest cannot boot | separate format verification from QEMU runtime |
| Assembly integration regressions | unrelated features break | one subsystem and regression test at a time |

## Security profile of V1

This is a **teaching kernel**, not a secure OS. It initially has no memory protection between code/modules, no userspace boundary, no privilege isolation, no storage integrity, no secure boot, and no networking. Every kernel module runs with the highest privilege.

- **Run in QEMU only** while learning; don't install the ISO to a real drive.
- Keep the QEMU GDB listener bound to **127.0.0.1**, not a public interface.
- Don't map host directories or guest-network access unless a deliberate later task requires it.
- Use finite buffer capacities and validated pointer/length pairs.
- Understand that a faulty kernel routine or optional linked-in module can crash the entire guest.
- Treat user-entered command lines and filesystem paths as untrusted data, even in a classroom demo.

## Scope guardrails

1. No 64-bit mode migration mid-project.
2. No custom bootloader; GRUB is part of the design.
3. No C helper code disguised as a library.
4. No Linux Bash or Linux syscall dependency.
5. No networking/disk GUI until V1 goals pass.
6. Architecture-changing features (paging, ring 3, dynamic modules) are separate V2 proposals.
