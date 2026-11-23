[BITS 32]
; Not implimenting 
;PIT -> PIC -> CPU-> check in IDT -> IRQ0 handler (index 32) -> timer dirver(timer.asm)

%define PIT_COMMAND 0x43   ; command port
%define PIT_CHANNEL0 0x40   ; ch 0 command

%define PIT_DIVISOR 11932
%define TIMER_HZ 100

global timer_init
global timer_get_ticks
global timer_get_seconds
global timer_delay_ticks
global timer_delay_ms
global timer_ticks

section .text

; Configure PIT channel 0
timer_init:
    pushad

    mov al, 0x36
    out PIT_COMMAND, al

    mov ax, PIT_DIVISOR
    out PIT_CHANNEL0, al

    mov al, ah
    out PIT_CHANNEL0, al

    popad
    ret


; Return current tick count in EAX
timer_get_ticks:
    mov eax, [timer_ticks]
    ret


; Return time in seconds timer_ticks/100
timer_get_seconds:
    mov eax, [timer_ticks]
    xor edx, edx
    mov ecx, TIMER_HZ
    div ecx
    ret

; Sleep
; Wait for a specified number of ticks
; Input: EAX = number of ticks
timer_delay_ticks:
    push ebx
    push ecx

    mov ebx, eax
    mov ecx, [timer_ticks]

.wait:
    mov eax, [timer_ticks]
    sub eax, ecx

    cmp eax, ebx
    jae .done

    pause
    jmp .wait

.done:
    pop ecx
    pop ebx
    ret


; Wait for approximately the specified milliseconds
; Input: EAX = milliseconds
timer_delay_ms:
    push ebx

    ; Convert milliseconds to 10 ms ticks.
    ; Round upward so nonzero delays get at least one tick.
    add eax, 9
    xor edx, edx
    mov ebx, 10
    div ebx

    call timer_delay_ticks

    pop ebx
    ret


section .bss

align 4

timer_ticks:
    resd 1
