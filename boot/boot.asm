; TinyOS - Multiboot v1 entry (NASM, 32-bit only).
; GRUB enters with EAX = 0x2BADB002 and EBX -> Multiboot info.



BITS 32      ; tells NASM to assemble instructions using 32-bit

; just defined not initialized
MAGIC_NUM equ 0x1BADB002   ; Multiboot v1 magic number verifies by grub
FLAGS equ 0x00000003             ; Flags are for retrieve info from bootloader here request Align boot modules at bit0, request memory info at bit1.
CHECKSUM equ -(MB_MAGIC + MB_FLAGS) ; all three must equals to 0 cz grub gets satisfied and complete handshake here

; section where our multiboot headers are store and initialized for GRUB to recognize
section .multiboot progbits alloc align=4     ;make sure every address is divisible by 4, starts exactly at 4 multipler
    dd MAGIC_NUM
    dd FLAGS
    dd CHECKSUM

; uninitialize the variables segment
section .bss  ;
    align 16

    stack_bottom:
        resb 16384     ; reserve bytes for stack 
    stack_top:


;code segment in masm it is .code
section .text
    global _start   ;showing _start label to linker
    extern kernel_main   ;kernel_main present outside of boot.asm in /src/kernel.asm

    _start:         ;imp in linker will add this label as start entry point This tells the linker which address should be recorded as the kernel's entry address.
                    ;cpu frist exe the entery addresses
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
        add esp, 16                    ; Remove two arguments + alignment padding for getting esp to starting of the stack
        ;can also do ret 16 in kernel main

    .halt:
        hlt
        jmp .halt


