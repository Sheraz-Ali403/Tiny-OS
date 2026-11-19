BITS 32

section .text

global gdt_install
gdt_install:
    push eax  ; eax already have magiv num so we presvere that by pushing in stack

    ; reads defined descriptor and load in gdtr 
    lgdt [gdt_descriptor]

    ; Reload CS with our code segment
    ; x08 = 00001000 at index 1 for kernel code selector
    ; x10 = at index 2 for kernel data selector
    ; 1B at index 3 for user code (scope is limited to kernel only so no user code and data selector)
    ; upto 2^13 selectors btw 
    jmp 0x08:.reload_cs

.reload_cs:
    mov ax, 0x10  ; kernel data segment

    ; Set the data segments
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    pop eax
    ret


section .rodata

align 8

gdt_start:
    ; 8 bytes 
    ; Null descriptor
    dq 0x0000000000000000

    ; Kernel code segment and selector x08
    dq 0x00CF9A000000FFFF

    ; Kernel data segment
    dq 0x00CF92000000FFFF
gdt_end:

; 6 bytes 
gdt_descriptor:
    dw gdt_end - gdt_start -1 ; bits 0-15 shows limit  
    dd gdt_start               ; 16-47 shows base
