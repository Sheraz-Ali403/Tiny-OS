
[BITS 32]

; PIC ports
%define PIC1_COMMAND    0x20
%define PIC1_DATA       0x21
%define PIC2_DATA       0xA1

; PIT ports
%define PIT_COMMAND     0x43
%define PIT_CHANNEL0    0x40

; IRQ vector identifiers
%define IRQ_TIMER       0
%define IRQ_KEYBOARD    1

; PIT configuration  for setting the ticks
%define PIT_DIVISOR     11932

global irq0_stub
global irq1_stub
global pit_init
global pic_enable_irq01

global timer_ticks
global keyboard_scancode


section .text
irq0_stub:
    push dword IRQ_TIMER
    jmp irq_common

irq1_stub:
    push dword IRQ_KEYBOARD
    jmp irq_common

irq_common:
    pushad

    ; Save segment registers
    push ds
    push es
    push fs
    push gs

    ; Load kernel data segments
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    cld

    ; Identify IRQ
    mov eax, [esp + 48]

    ; check whether its IRQ0 or IRQ1 (we pushed 0 and 1)
    cmp eax, IRQ_TIMER
    je .timer_irq

    cmp eax, IRQ_KEYBOARD
    je .keyboard_irq

    jmp .send_eoi


.timer_irq:
    inc dword [timer_ticks]
    jmp .send_eoi


.keyboard_irq:
    in al, 0x60
    mov [keyboard_scancode], al


.send_eoi:
    ; Acknowledge master PIC
    mov al, 0x20
    out PIC1_COMMAND, al

    ; Restore segment registers
    pop gs
    pop fs
    pop es
    pop ds

    popad

    ; Remove IRQ identifier
    add esp, 4

    iretd


pit_init:
    pushad

    ; Configure channel 0, mode 3
    mov al, 0x36
    out PIT_COMMAND, al

    ; Set approximately 100 Hz
    mov ax, PIT_DIVISOR

    ; Send divisor low byte
    out PIT_CHANNEL0, al

    ; Send divisor high byte
    mov al, ah
    out PIT_CHANNEL0, al

    popad
    ret

pic_enable_irq01:
    push ax
    push dx

    ; Unmask master IRQ0 and IRQ1
    mov dx, PIC1_DATA
    mov al, 0xFC
    out dx, al

    ; Keep all slave IRQs masked
    mov dx, PIC2_DATA
    mov al, 0xFF
    out dx, al

    pop dx
    pop ax
    ret


section .bss

align 4

; Number of timer interrupts received
timer_ticks:
    resd 1

; Most recently received keyboard scancode
keyboard_scancode:
    resb 1
