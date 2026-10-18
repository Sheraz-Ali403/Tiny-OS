/* 32-bit freestanding ELF kernel linked for a conventional 1 MiB load base. */
OUTPUT_FORMAT(elf32-i386)
ENTRY(_start)

SECTIONS
{
    . = 1M;

    /* Keep this first: Multiboot v1 header must be within first 8192 file bytes. */
    .multiboot ALIGN(4) : { KEEP(*(.multiboot)) }
    .text ALIGN(4096) : { *(.text*) }
    .rodata ALIGN(4096) : { *(.rodata*) }
    .data ALIGN(4096) : { *(.data*) }
    .bss ALIGN(4096) : { *(COMMON) *(.bss*) }

    /DISCARD/ : { *(.comment) *(.note*) *(.eh_frame*) }
}
