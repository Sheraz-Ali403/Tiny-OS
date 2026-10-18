# Ubuntu Host Setup (New Contributor Guide)

This guide is for a fresh **Ubuntu x86-64 (22.04 or newer recommended)** installation. TinyOS runs **in QEMU**, not on the host machine. The `i686-elf` cross toolchain belongs to the **host**; the resulting kernel targets 32-bit x86.

## 1. Install host build/run tools

```bash
sudo apt update
sudo apt install -y \
  build-essential cmake make nasm git \
  grub-common grub-pc-bin xorriso mtools \
  qemu-system-x86 gdb-multiarch \
  binutils wget bison flex texinfo \
  libgmp-dev libmpc-dev libmpfr-dev
```

Why these packages?

| Tool/package | Reason |
|---|---|
| `nasm` | Assemble `-f elf32` from x86 NASM source |
| `cmake`, `make` | Configure and execute the build graph |
| `grub-common`, `grub-pc-bin` | `grub-file`, GRUB image modules, and rescue ISO support |
| `xorriso`, `mtools` | Used by `grub-mkrescue` to produce bootable ISO |
| `qemu-system-x86` | Provides `qemu-system-i386` |
| `gdb-multiarch` | Debug i386 guest kernel over QEMU's GDB stub |
| `binutils` | Inspect ELF files using `readelf`, `objdump`, etc. |
| `wget`, build libs, `bison`, `flex`, `texinfo` | Build GNU Binutils from source if the cross linker isn't present |

If your distribution's package names differ, check the equivalent package. This project is tested conceptually against Ubuntu-style tooling, **not** Windows-native toolchains.

## 2. Install the `i686-elf` cross-linker (if missing)

Check first:

```bash
command -v i686-elf-ld
command -v i686-elf-as
```

**If present, skip to step 3.** Your existing `i686-elf-gcc` may stay installed, but **it is not used by TinyOS**.

For missing tools, build GNU Binutils for a bare-metal `i686-elf` target. The version below is a **known release example**, not a claim that it is the newest available.

```bash
mkdir -p "$HOME/src" "$HOME/opt/cross"
cd "$HOME/src"
wget https://ftp.gnu.org/gnu/binutils/binutils-2.44.tar.xz
tar -xf binutils-2.44.tar.xz
mkdir -p build-binutils
cd build-binutils

../binutils-2.44/configure \
  --target=i686-elf \
  --prefix="$HOME/opt/cross" \
  --with-sysroot \
  --disable-nls \
  --disable-werror

make -j"$(nproc)"
make install
```

> This can take time and requires internet to download GNU Binutils. It creates `i686-elf-ld` and other cross Binutils under `~/opt/cross/bin/`. **You do not need to compile GCC** for an Assembly-only kernel. Do not install bare-metal components with `sudo make install` into system directories when targeting your home directory.

## 3. Set PATH permanently without breaking NVM

Put **only this** at the end of `~/.bashrc`:

```bash
export PATH="$HOME/opt/cross/bin:$PATH"
```

**Do not permanently export `PREFIX`**; NVM may refuse to load while `PREFIX` is set. Likewise, `TARGET` is not required after installation.

To correct an existing interactive shell:

```bash
unset PREFIX
unset TARGET
source ~/.bashrc
```

Verify:

```bash
command -v i686-elf-ld
command -v nasm
command -v grub-mkrescue
command -v qemu-system-i386
```

Expected cross-linker path when following this guide: `$HOME/opt/cross/bin/i686-elf-ld`.

If using a non-Bash shell, configure that shell's startup file rather than assuming `.bashrc` will load.

## 4. Clone and inspect

```bash
git clone <REPOSITORY_URL> TinyOS
cd TinyOS
chmod +x scripts/check-env.sh  # Usually preserved by Git.
./scripts/check-env.sh
```

Replace `<REPOSITORY_URL>` with the repository URL provided by your teammate. When using a downloaded ZIP rather than Git, unpack it and `cd` into its extracted root.

## 5. Build and boot

```bash
cmake -S . -B build
cmake --build build --target verify
cmake --build build --target iso
cmake --build build --target run
```

**Tip:** CMake's first command configures where the tools and rules are. Repeat that step when changing CMake settings or starting a fresh build directory. For ordinary `.asm` edits, running only `cmake --build build --target run` triggers incremental compilation.

## 6. Debugger setup (optional)

Terminal 1:

```bash
cmake --build build --target debug
```

Terminal 2:

```bash
gdb-multiarch build/kernel.elf
```

At the `(gdb)` prompt:

```text
set architecture i386
target remote 127.0.0.1:1234
break _start
continue
```

GRUB starts first. GDB may step through firmware/GRUB or stop when the `_start` breakpoint is reached. See `TESTING_DEBUGGING.md`.

## 7. Common pitfalls

- `i686-elf-ld: command not found`: cross Binutils missing or PATH not exported.
- `nvm is not compatible with PREFIX`: run `unset PREFIX` and remove the `export PREFIX` line from startup files (if present).
- `grub-mkrescue` fails: make sure `grub-pc-bin`, `xorriso`, and `mtools` are installed.
- Run QEMU **without** `-kernel` for this starter. We intentionally test the actual GRUB/ISO path.
- Use the standard PC/BIOS virtual machine; UEFI-only firmware is not the target.

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed diagnostics.
