[BITS 32]

; for decoding the scancodes from pott x60
; 0xE0 extened keys so we will check first whether its extented or not

global keyboard_handle_scancode
global keyboard_last_code
global keyboard_last_extended
global keyboard_last_event

%define KEY_PRESSED  1    ; bit7 0
%define KEY_RELEASED 2    ; bit7 1

section .text


; al would have scancode from irq.asm
; Updates the keyboard event variables.

keyboard_handle_scancode:
    push eax
    push ebx

    ; Check for extended scancode prefix.
    cmp al, 0xE0
    je .extended_prefix      ; not process any other thing, (actual) word will come 

    ; Preserve the incoming scancode.
    mov bl, al

    ; Check whether this is an extended key.
    cmp byte [keyboard_extended_prefix], 1
    jne .normal_key

    ; extended key 
    mov byte [keyboard_extended_prefix], 0
    mov byte [keyboard_last_extended], 1
    jmp .decode_key

.normal_key:
    mov byte [keyboard_last_extended], 0

.decode_key:
    mov al, bl
    and al, 0x7F      ; for getting the value only regardless or make or break
    mov [keyboard_last_code], al

    ; make or break. 
    ; checks bit 7 (Pressed 0, Release 1)
    test bl, 0x80
    jnz .key_released

.key_pressed:
    mov byte [keyboard_last_event], KEY_PRESSED
    jmp .done

.key_released:
    mov byte [keyboard_last_event], KEY_RELEASED
    jmp .done

.extended_prefix:
    mov byte [keyboard_extended_prefix], 1

.done:
    pop ebx
    pop eax
    ret


section .bss

keyboard_extended_prefix resb 1
keyboard_last_code       resb 1
keyboard_last_extended   resb 1
keyboard_last_event      resb 1

