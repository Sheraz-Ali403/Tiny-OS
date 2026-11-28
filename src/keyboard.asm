[BITS 32]

; for decoding the scancodes from port x60
; 0xE0 extended keys so we will check first whether its extended or not

global keyboard_init
global keyboard_handle_scancode
global keyboard_getchar
global keyboard_line_process
global keyboard_line_reset

global keyboard_line_buffer
global keyboard_line_length

%define LINE_IGNORED 0
%define LINE_CHARACTER 1
%define LINE_BACKSPACE 2
%define LINE_ENTER 3

%define BUFFER_MASK 127

%define KEY_PRESSED 1
%define KEY_RELEASED 2

section .text

keyboard_init:
    pushad

    mov byte [keyboard_read_index], 0
    mov byte [keyboard_write_index], 0
    mov byte [keyboard_extended_prefix], 0
    mov byte [keyboard_pause_bytes], 0

    mov byte [keyboard_last_code], 0
    mov byte [keyboard_last_extended], 0
    mov byte [keyboard_last_event], 0
    mov byte [keyboard_last_ascii], 0

    mov byte [keyboard_line_length], 0
    mov byte [keyboard_line_buffer], 0

    ; Clear key states.
    cld
    mov edi, keyboard_key_state
    mov ecx, 128
    xor eax, eax
    rep stosb   ;al to edi

    mov edi, keyboard_extended_key_state
    mov ecx, 128
    rep stosb

    popad
    ret


; al would have scancode from irq.asm
; Updates the keyboard event variables.

keyboard_handle_scancode:
    push eax
    push ebx

    ; Ignore remaining bytes of Pause key sequence.
    cmp byte [keyboard_pause_bytes], 0
    jne .skip_pause

    ; Check for extended scancode prefix.
    cmp al, 0xE0
    je .extended_prefix

    ; Ignore Pause key sequence.
    cmp al, 0xE1
    je .pause_prefix

    ; Preserve the incoming scancode.
    mov bl, al

    ; Check whether this is an extended key.
    cmp byte [keyboard_extended_prefix], 1
    jne .normal_key

    ; Extended key.
    mov byte [keyboard_extended_prefix], 0
    mov byte [keyboard_last_extended], 1
    jmp .decode_key

.normal_key:
    mov byte [keyboard_last_extended], 0

.decode_key:
    mov al, bl
    and al, 0x7F
    mov [keyboard_last_code], al

    ; Check bit 7 to identify make or break.
    test bl, 0x80
    jnz .key_released

.key_pressed:
    mov byte [keyboard_last_event], KEY_PRESSED

    movzx ebx, byte [keyboard_last_code]

    ; Track extended keys separately.
    cmp byte [keyboard_last_extended], 1
    je .extended_pressed

    mov byte [keyboard_key_state + ebx], 1

    ; Translate to ASCII.
    mov al, [keyboard_ascii_table + ebx]

    ; Ignore unmapped keys.
    test al, al
    jz .done

    mov [keyboard_last_ascii], al

    ; Add character to input buffer.
    call keyboard_buffer_push
    jmp .done

.extended_pressed:
    mov byte [keyboard_extended_key_state + ebx], 1
    jmp .done

.key_released:
    mov byte [keyboard_last_event], KEY_RELEASED

    movzx ebx, byte [keyboard_last_code]

    ; Update key state.
    cmp byte [keyboard_last_extended], 1
    je .extended_released

    mov byte [keyboard_key_state + ebx], 0
    jmp .done

.extended_released:
    mov byte [keyboard_extended_key_state + ebx], 0
    jmp .done

.extended_prefix:
    mov byte [keyboard_extended_prefix], 1
    jmp .done

.pause_prefix:
    mov byte [keyboard_extended_prefix], 0
    mov byte [keyboard_pause_bytes], 5
    jmp .done

.skip_pause:
    dec byte [keyboard_pause_bytes]
    jmp .done

.done:
    pop ebx
    pop eax
    ret


; Add one character to the circular buffer.

keyboard_buffer_push:
    push ebx
    push edx

    ; Calculate next write index.
    mov bl, [keyboard_write_index]
    inc bl
    and bl, BUFFER_MASK

    mov dl, bl

    ; Check full condition.
    cmp dl, [keyboard_read_index]
    je .buffer_full

    ; Store character.
    movzx ebx, byte [keyboard_write_index]
    mov [keyboard_buffer + ebx], al

    ; Publish new write index.
    mov [keyboard_write_index], dl

.buffer_full:
    pop edx
    pop ebx
    ret


; Retrieve one character
;
; Output:
; AL = character
; CF = 0 if successful
; CF = 1 if empty

keyboard_getchar:
    push ebx

    mov bl, [keyboard_read_index]

    ; Check empty condition.
    cmp bl, [keyboard_write_index]
    je .buffer_empty

    ; Read character.
    movzx ebx, bl
    mov al, [keyboard_buffer + ebx]

    ; Advance read index.
    inc bl
    and bl, BUFFER_MASK
    mov [keyboard_read_index], bl

    pop ebx
    clc
    ret

.buffer_empty:
    pop ebx
    stc
    ret


; Process one character for the current input line.
;
; Input:
; AL = character
;
; Output:
; AL = LINE_IGNORED, LINE_CHARACTER,
;      LINE_BACKSPACE or LINE_ENTER

keyboard_line_process:
    push ebx

    ; Check for Backspace.
    cmp al, 0x08
    je .backspace

    ; Check for Enter.
    cmp al, 0x0A
    je .enter

    ; Accept printable ASCII characters only.
    cmp al, 0x20
    jb .ignored

    cmp al, 0x7E
    ja .ignored

    ; Check maximum line length.
    mov bl, [keyboard_line_length]
    cmp bl, 79
    jae .ignored

    ; Add character to line buffer.
    movzx ebx, bl
    mov [keyboard_line_buffer + ebx], al

    inc byte [keyboard_line_length]

    ; Add null terminator.
    movzx ebx, byte [keyboard_line_length]
    mov byte [keyboard_line_buffer + ebx], 0

    mov al, LINE_CHARACTER
    jmp .done

.backspace:
    mov bl, [keyboard_line_length]

    ; Nothing to delete.
    test bl, bl
    jz .ignored

    dec bl
    mov [keyboard_line_length], bl

    ; Remove the last character.
    movzx ebx, bl
    mov byte [keyboard_line_buffer + ebx], 0

    mov al, LINE_BACKSPACE
    jmp .done

.enter:
    mov al, LINE_ENTER
    jmp .done

.ignored:
    mov al, LINE_IGNORED

.done:
    pop ebx
    ret


; Reset the current input line.

keyboard_line_reset:
    mov byte [keyboard_line_length], 0
    mov byte [keyboard_line_buffer], 0
    ret


section .rodata

; Set 1 scancode -> lowercase ASCII
; Table indexes correspond directly to scancodes.

keyboard_ascii_table:

    db 0                    ; 00
    db 0x1B                 ; 01 ESC

    db '1','2','3','4'      ; 02-05
    db '5','6','7','8'      ; 06-09
    db '9','0','-','='      ; 0A-0D

    db 0x08,0x09            ; 0E Backspace, 0F Tab

    db 'q','w','e','r'      ; 10-13
    db 't','y','u','i'      ; 14-17
    db 'o','p','[',']'      ; 18-1B

    db 0x0A,0               ; 1C Enter, 1D Ctrl

    db 'a','s','d','f'      ; 1E-21
    db 'g','h','j','k'      ; 22-25
    db 'l',';',0x27,0x60    ; 26-29

    db 0,0x5C               ; 2A Shift, 2B backslash

    db 'z','x','c','v'      ; 2C-2F
    db 'b','n','m',','      ; 30-33
    db '.','/'              ; 34-35

    db 0,'*',0,' '          ; 36-39

    times 128 - ($ - keyboard_ascii_table) db 0


section .bss

keyboard_extended_prefix     resb 1
keyboard_pause_bytes         resb 1

keyboard_last_code           resb 1
keyboard_last_extended       resb 1
keyboard_last_event          resb 1
keyboard_last_ascii          resb 1

keyboard_key_state           resb 128
keyboard_extended_key_state  resb 128

keyboard_buffer              resb 128
keyboard_read_index           resb 1
keyboard_write_index          resb 1

keyboard_line_buffer         resb 80
keyboard_line_length         resb 1
