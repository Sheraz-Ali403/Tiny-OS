; TinyOS - Multiboot v1 entry (NASM, 32-bit only).
; GRUB enters with EAX = 0x2BADB002 and EBX -> Multiboot info.
BITS 32

MB_MAGIC equ 0x1BADB002
MB_FLAGS equ 0x00000003             ; Align boot modules, request memory info.
MB_CHECKSUM equ -(MB_MAGIC + MB_FLAGS)

section .multiboot progbits alloc align=4
    dd MB_MAGIC
    dd MB_FLAGS
    dd MB_CHECKSUM

section .text
global _start
extern kernel_main

_start:
    cli                            ; No IDT/IRQ handlers exist yet.
    cld                            ; String operations advance forwards.
    mov esp, stack_top             ; Use our own 16 KiB kernel stack.
    and esp, 0xFFFFFFF0            ; 16-byte stack alignment.

    ; Leave ESP aligned to 16 bytes at the CALL instruction.
    sub esp, 8
    ; Arguments are pushed right-to-left: kernel_main(magic, info_ptr).
    push ebx                       ; Second argument: Multiboot info pointer.
    push eax                       ; First argument: bootloader magic.
    call kernel_main
    add esp, 16                    ; Remove two arguments + alignment padding.

.halt:
    hlt
    jmp .halt

section .bss
align 16
stack_bottom:
    resb 16384
stack_top:
