; TinyOS - first Assembly-only kernel milestone.
; No libc, no Linux syscalls, and no C runtime.
BITS 32

; readonly data section
section .rodata   
line1 db 'Welcome to TinyOS!', 0
line2 db '32-bit x86 Assembly kernel', 0
line3 db 'GRUB -> NASM -> VGA: boot successful.', 0
error_line db 'ERROR: Invalid Multiboot magic.', 0

section .text
global kernel_main


;In C it is kernel_main(uint32 boot_magic, uint32 multiboot_info_ptr)
; [esp+4] = boot_magic (eax), [esp+8] = info pointer (not used yet) (ebx).
kernel_main:
    cmp dword [esp + 4], 0x2BADB002
    jne .bad_boot

    mov edi, 0xB8000               ; VGA text buffer, first character.
    mov esi, line1
    mov ah, 0x0F                   ; White-on-black text attribute.
    call vga_print_zero_terminated

    mov edi, 0xB8000 + 160         ; Next row: 80 columns * 2 bytes.
    mov esi, line2
    mov ah, 0x0F
    call vga_print_zero_terminated

    mov edi, 0xB8000 + 320         ; Row three.
    mov esi, line3
    mov ah, 0x0A                   ; Light-green-on-black attribute.
    call vga_print_zero_terminated
    ret

.bad_boot:
    mov edi, 0xB8000
    mov esi, error_line
    mov ah, 0x4F                   ; Bright-white text on red.
    call vga_print_zero_terminated
    ret

; INPUT: ESI -> zero-terminated string, EDI -> VGA destination, AH -> color.
; CLOBBERS: EAX, ESI, EDI. This is not a general-purpose console yet.
vga_print_zero_terminated:
    cld
.next:
    lodsb                          ; AL <- [ESI], then ESI++.
    test al, al
    jz .done
    stosw                          ; [EDI] <- AX (character + attribute).
    jmp .next
.done:
    ret
