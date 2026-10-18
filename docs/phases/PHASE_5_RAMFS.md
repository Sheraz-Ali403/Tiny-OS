# Phase 5 — Consolidation and Optional Static RAM Filesystem

**Priority:** stability first. RAMFS is **optional** if earlier modules still have faults.

## Learn
- Tree data structures implemented with explicit 32-bit pointers.
- Parent/child/sibling representation in static data.
- Resolving absolute and relative paths; `.` and `..`.
- Bounded pathname processing; file versus directory nodes.

## Mandatory consolidation
- [ ] Regression test boot → keyboard → shell.
- [ ] Fix line input overflow, early-return stack errors, and command mismatch cases.
- [ ] Check every exported routine's clobber contract and calling convention.

## Optional RAMFS tasks
- [ ] Define statically allocated root, `etc/`, `home/`, `kernel/` nodes.
- [ ] Add node/path resolver with clear return status.
- [ ] Track current working directory node pointer.
- [ ] Implement `ls`, `pwd`, `cd` using actual tree traversal.
- [ ] Optionally implement `cat` using `data_ptr` and `data_len` of a text file.
- [ ] Test malformed/overlength paths and root-parent navigation.

## Acceptance if RAMFS is attempted
- `ls` enumerates nodes from data, not a fixed message.
- `pwd` reflects a successful `cd` and navigates back correctly.
- Invalid paths fail cleanly without overwriting unrelated memory.
