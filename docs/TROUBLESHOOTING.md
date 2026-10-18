# Troubleshooting Reference

## `nvm is not compatible with the PREFIX environment variable`

**Cause:** previously exported `PREFIX` remains in current shell even if `.bashrc` now contains only PATH.

```bash
printf 'PREFIX=%s\n' "${PREFIX-}"
unset PREFIX
source ~/.bashrc
```

Remove any persistent `export PREFIX=...` from shell startup files. Keep only:

```bash
export PATH="$HOME/opt/cross/bin:$PATH"
```

## `i686-elf-ld: command not found`

```bash
ls -l "$HOME/opt/cross/bin/i686-elf-ld"
command -v i686-elf-ld
printf '%s\n' "$PATH"
```

If executable exists but isn't on PATH, add it using `~/.bashrc` per setup guide. If it does not exist, install GNU cross Binutils (not Linux userland GNU linker). After PATH changes, reconfigure CMake or delete its build cache.

## CMake says a required program is missing

```bash
./scripts/check-env.sh
cmake -E rm -rf build
cmake -S . -B build
```

`find_program` searches PATH while configuring and stores paths in `build/CMakeCache.txt`. Refresh the configuration after installing dependencies.

## `grub-mkrescue` fails / xorriso not found / platform modules missing

```bash
sudo apt install -y grub-common grub-pc-bin xorriso mtools
command -v grub-mkrescue
```

Use **BIOS/PC GRUB** modules, not an assumed UEFI-only boot path.

## `error: no multiboot header found`

Check:

```bash
grub-file --is-x86-multiboot build/kernel.elf; echo "$?"
readelf -S build/kernel.elf
readelf -l build/kernel.elf
```

Possible causes: magic/checksum wrong; `.multiboot` section omitted by linker; header beyond first 8 KiB in **file**; wrong ELF type/format; trying Multiboot2 detection with a v1 image. Do not “solve” it by using Linux `-kernel` boot, which bypasses the intended GRUB path.

## QEMU boots to a black screen

- Verify ISO was rebuilt: `cmake --build build --target iso`.
- Verify GRUB's `multiboot /boot/kernel.elf` matches staging path.
- Use BIOS-mode `qemu-system-i386` and default PC VGA display.
- Ensure GRUB hands off a compatible VGA text-mode payload (see `set gfxpayload=text`).
- Check control flow with QEMU+GDB if GRUB runs but the kernel does not print.
- Confirm color bytes / VGA target `0xB8000`, and that `kernel_main` was linked/called.

## QEMU resets immediately / triple fault

A likely CPU exception occurred without a usable IDT. Use `-no-reboot -no-shutdown` and GDB; inspect EIP/ESP and the last executed instruction. Do not enable IRQs with `sti` before IDT/handlers are installed.

## `undefined reference to kernel_main`

- Confirm `global kernel_main` in `src/kernel.asm`.
- Confirm `extern kernel_main` in `boot/boot.asm`.
- Confirm both objects appear in the CMake linker command.
- Confirm spelling and symbol case match exactly.

## `Exec format error` trying to run `kernel.elf`

Expected: this kernel is not a Linux userspace executable. Boot it via GRUB/QEMU instead of `./build/kernel.elf`.

## QEMU pauses forever in `debug` mode

Expected: `-S` leaves guest CPU stopped. Connect GDB to `127.0.0.1:1234` and issue `continue`.

## `Permission denied` for environment script

```bash
chmod +x scripts/check-env.sh
```

Alternatively `bash scripts/check-env.sh`.

## CMake and Make confusion

`make` in repository root uses our convenience wrapper; `cmake --build build --target ...` uses CMake's generated native build tool. We maintain only one canonical graph in `CMakeLists.txt`.
