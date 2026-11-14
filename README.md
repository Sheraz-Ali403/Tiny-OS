# TinyOS — Assembly-Only 32-bit x86 Educational Operating System

**Status:** Phase 1 starter is implemented; subsequent subsystems are planned, not implemented.  
**Course context:** Computer Organization & Assembly Language (COAL).  
**Implementation rule:** All target-side operating-system code must be **NASM x86 Assembly**. **No C/C++ or libc** in the kernel.  
**Host:** Ubuntu Linux. **Guest:** 32-bit x86 PC emulated by QEMU. **Boot:** GRUB 2 + Multiboot v1. **Build:** CMake orchestrating NASM, `i686-elf-ld`, GRUB tools, and QEMU.

## What the project is

TinyOS is an original, small, monolithic educational kernel—not a Linux distribution or a Bash replacement. Its long-term V1 objective is to boot through GRUB, initialize the essential x86 environment, output text, handle keyboard input, and expose a simple interactive Assembly-written shell with a small RAM-backed directory tree.

**Included right now:** a minimal, bootable (once the host dependencies are installed) two-object Assembly kernel that validates the Multiboot magic, sets its own stack, displays three lines through VGA text memory, then safely halts. CMake builds `kernel.elf` and `tinyos.iso` and can launch QEMU. **Not yet included:** functional interrupts, keyboard, shell, memory allocator, or RAMFS. Keep those features in milestones until they exist.

## First-time setup (Ubuntu)

See **[docs/SETUP_UBUNTU.md](docs/SETUP_UBUNTU.md)**. For an already provisioned host:

```bash
./scripts/check-env.sh
cmake -S . -B build
cmake --build build --target verify
cmake --build build --target iso
cmake --build build --target run
```

Or use the convenience wrapper:

```bash
make run
```

The display should show:

```text
Welcome to TinyOS!
32-bit x86 Assembly kernel
GRUB -> NASM -> VGA: boot successful.
```

The virtual CPU then halts (no keyboard response yet). Close QEMU using its window controls. **Do not run this ISO directly on your real laptop.**

## Project structure

```text
TinyOS_Assembly_Starter/
├── boot/boot.asm             # Multiboot header, stack, _start
├── src/kernel.asm            # Phase 1 VGA kernel
├── linker/linker.ld          # ELF32 memory layout
├── grub/grub.cfg             # GRUB menu entry
├── CMakeLists.txt            # Canonical build specification
├── Makefile                  # Optional make frontend for CMake
├── scripts/check-env.sh      # Dependency and environment check
├── docs/                     # Architecture, learning, phases, testing, etc.
├── AGENTS.md                 # Instructions for AI coding assistants
├── CONTRIBUTING.md          # Contributor workflow
└── .gitignore                # Ignore build products
```

## Design principles

1. **Assembly-only kernel.** Build scripts, docs, and CMake aren't kernel languages.
2. **Explain the why.** Understand CPU state, instruction effects, ports, stack, and calling conventions.
3. **Ship vertical slices.** Boot → VGA → exceptions → keyboard → shell → simple RAMFS.
4. **No invented features.** Tests and README distinguish implemented versus planned behavior.
5. **Keep the scope viable.** Single core, no userspace, no Linux ABI, no storage or networking in V1.
6. **Reproducible host builds.** Build in `build/`; never commit generated binaries.

## Documentation index

| File | Why read it |
|---|---|
| [docs/START_HERE.md](docs/START_HERE.md) | First-day checklist and immediate tasks |
| [docs/SETUP_UBUNTU.md](docs/SETUP_UBUNTU.md) | From-clean-Ubuntu host setup and cross linker |
| [docs/BUILD_RUN_CMAKE.md](docs/BUILD_RUN_CMAKE.md) | CMake, ELF, ISO, QEMU and GDB commands |
| [docs/LEARNING_CONCEPTS.md](docs/LEARNING_CONCEPTS.md) | Small section-by-section list of required theory |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Components, boot flow, memory, interfaces |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Six-week plan and checkpoints |
| [docs/SCOPE_AND_REQUIREMENTS.md](docs/SCOPE_AND_REQUIREMENTS.md) | V1 scope, stretch goals, definition of done |
| [docs/IMPLEMENTATION_CONTRACTS.md](docs/IMPLEMENTATION_CONTRACTS.md) | Register, stack, IRQ, module coding contracts |
| [docs/SHELL_RAMFS.md](docs/SHELL_RAMFS.md) | Intended command dispatch and RAM directory model |
| [docs/TESTING_DEBUGGING.md](docs/TESTING_DEBUGGING.md) | Checklists, faults, GDB and milestones |
| [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Build and boot failures, including NVM `PREFIX` |
| [docs/RISKS_AND_SECURITY.md](docs/RISKS_AND_SECURITY.md) | Risk register and explicit security limitations |
| [docs/PRESENTATION.md](docs/PRESENTATION.md) | COAL demonstration and oral questions |
| [docs/REFERENCES.md](docs/REFERENCES.md) | Technical references |
| [docs/COAL_CONCEPT_TO_CODE_MAP.md](docs/COAL_CONCEPT_TO_CODE_MAP.md) | Course concepts mapped to specific instructions/modules |
| [docs/PROJECT_PROPOSAL.md](docs/PROJECT_PROPOSAL.md) | Faculty-ready project proposal |
| [docs/VALIDATION_STATUS.md](docs/VALIDATION_STATUS.md) | What was source-checked vs what still needs Ubuntu runtime testing |
| [docs/phases/](docs/phases/) | Per-week task breakdowns and acceptance criteria |

## Status and definition of success

See [docs/SCOPE_AND_REQUIREMENTS.md](docs/SCOPE_AND_REQUIREMENTS.md) for measurable graduation criteria. The first checkpoint is deliberately limited to displaying a boot message from NASM and halting without rebooting.
