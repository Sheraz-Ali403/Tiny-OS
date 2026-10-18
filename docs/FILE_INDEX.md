# File Index

## Working kernel/build files

- `boot/boot.asm` — Multiboot header, x86 entry, stack, handoff.
- `src/kernel.asm` — initial Assembly kernel and direct VGA text writer.
- `linker/linker.ld` — ELF sections and entry point.
- `grub/grub.cfg` — bootloader menu configuration.
- `CMakeLists.txt` — authoritative NASM/link/verify/ISO/run/debug build rules.
- `Makefile` — convenience wrapper delegating to CMake.
- `scripts/check-env.sh` — host tool availability and NVM PREFIX warning.
- `.gitignore`, `.gitattributes` — keep artifacts out of Git and LF line endings.

## Read in order

1. `README.md` — intent, scope and quick start.
2. `docs/START_HERE.md` — first two sessions.
3. `docs/SETUP_UBUNTU.md` — host installation.
4. `docs/BUILD_RUN_CMAKE.md` — build and debugger commands.
5. `docs/LEARNING_CONCEPTS.md` — sectionwise learning checklist.
6. `docs/ARCHITECTURE.md` — boot and module architecture.
7. `docs/SCOPE_AND_REQUIREMENTS.md` — requirements and status.
8. `docs/ROADMAP.md` — six weeks and stopping gates.
9. `docs/phases/*.md` — hands-on milestone steps.
10. `docs/IMPLEMENTATION_CONTRACTS.md` — register/stack/ISR contracts.
11. `docs/SHELL_RAMFS.md` — later commands and in-RAM tree.
12. `docs/TESTING_DEBUGGING.md` — verification strategy.
13. `docs/TROUBLESHOOTING.md` — solutions for common failures.
14. `docs/RISKS_AND_SECURITY.md` — safety and limitations.
15. `docs/PRESENTATION.md` — COAL viva and demo.
16. `docs/REFERENCES.md` — primary specs and manuals.
17. `docs/COAL_CONCEPT_TO_CODE_MAP.md` — topics explicitly linked to instructions/modules.
18. `docs/PROJECT_PROPOSAL.md` — proposal text for faculty review.
19. `docs/VALIDATION_STATUS.md` — real validation boundary and remaining runtime checks.

## Team process

- `CONTRIBUTING.md` — PR and issue hygiene.
- `AGENTS.md` — AI assistant boundaries; explain-before-code style.
- `TODO.md` — top-level progress checklist.
