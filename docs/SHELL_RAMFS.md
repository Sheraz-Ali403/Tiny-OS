# Shell and RAMFS Design — Future Milestones

**Status:** Proposed design only. No interactive shell or filesystem is implemented in the initial bootable starter.

## Shell flow

```text
PS/2 IRQ1 -> ISR reads scancode -> event queue
  -> scancode-to-character decoding -> line editor
  -> bounded NUL-terminated command line
  -> tokenizer -> exact command lookup -> Assembly command handler
  -> VGA output -> next prompt
```

## Initial shell rules

- Prompt: `tinyos:/$ ` (display-only; not a Linux user account).
- Maximum input line: **128 bytes including NUL**; configurable constant; reject further text on overflow.
- Command tokens: first token = command, remaining input used according to command-specific syntax.
- Unknown command reports an error and returns to prompt, not a kernel halt.
- No background processes, pipes, redirects, external binaries, scripting engine, environment variables, or Bash expansion.

## Initial command specification

| Command | Correct semantics | Dependency |
|---|---|---|
| `help` | Display implemented commands | console + command table |
| `clear` | Clear VGA screen and reset cursor | console |
| `echo <text>` | Print argument text | tokenizer |
| `hostname` | Print TinyOS static hostname | console |
| `uname` | Print TinyOS version and `i686` | console |
| `halt` | Disable interrupts and halt CPU | correct privileged halt routine |

**Stretch filesystem commands:**

| Command | Real functionality (not hardcoded output) |
|---|---|
| `pwd` | Walk the parent links from current directory to root and produce its path |
| `ls [path]` | Look up directory and enumerate its actual children |
| `cd <path>` | Validate directory and change `cwd` |
| `cat <file>` | Resolve path and print stored text content |

## RAMFS V1 model

Do not build a production VFS. A small compile-time tree with mutable `cwd` is sufficient:

```text
/
├── etc/
│   └── hostname    (file: "tinyos")
├── home/
│   └── user/
│       └── readme.txt
└── kernel/
    └── version
```

Possible node fields: `name_ptr`, `type`, `parent_ptr`, `first_child_ptr`, `next_sibling_ptr`, `data_ptr`, `data_len`. Each is a 32-bit field in the initial 32-bit design. Node arrays are static and limited in size; do not store unbounded recursive copies of strings.

## Path handling test cases

- `/` and empty path; root has no parent.
- `.` current directory; `..` parent (at root remains root).
- Repeated separators: `//home///user` (either normalize or reject consistently).
- Nonexistent components; file where directory required; directory passed to `cat`.
- Max path length and buffer overflow; NUL termination.
- Relative vs absolute paths; `ls` never presents static prewritten listing unrelated to directory children.

## Example shell output (aspirational)

```text
TinyOS v0.1 - Assembly-only

tinyos:/$ help
help clear echo hostname uname halt ls pwd cd cat

tinyos:/$ ls /
etc home kernel

tinyos:/$ cd /home/user
tinyos:/home/user$ pwd
/home/user
```

This is a **target**, not a claim that the starter already runs these commands.
