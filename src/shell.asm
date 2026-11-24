[BITS 32]

VGA_BUFFER      EQU 0xB8000         ; Base address of 80x25 VGA color text buffer
VGA_END         EQU 0xB8FA0         ; End of VGA buffer (80 * 25 * 2 bytes)
VGA_LAST_ROW    EQU 0xB8F00         ; Start of row 24 (last row)
VGA_COLUMNS     EQU 80
VGA_ROWS        EQU 25

extern keyboard_line_buffer
extern timer_ticks
extern fs_write
extern fs_read
extern fs_delete
extern fs_get_entry_ptr

global shell_init
global shell_execute
global shell_prompt_end

section .text

; Initializes the shell by printing the first prompt
shell_init:
    call shell_print_prompt
    ret


; Prints "tinyos> " at EDI and saves the cursor boundary so Backspace cannot erase it
shell_print_prompt:
    push esi
    push eax

    mov esi, prompt_str
    mov ah, 0x0A                    ; Light green text on black background
    call shell_write_string

    mov [shell_prompt_end], edi     ; Store minimum allowed cursor address for Backspace

    pop eax
    pop esi
    ret


; Parses and executes the command string inside keyboard_line_buffer
; Updates EDI (current VGA cursor position)
shell_execute:
    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov esi, keyboard_line_buffer

    ; Skip leading whitespace
.skip_spaces:
    cmp byte [esi], ' '
    jne .check_empty
    inc esi
    jmp .skip_spaces

.check_empty:
    cmp byte [esi], 0
    je .prompt_and_exit

    ; Dispatch built-in shell commands
    mov ebx, cmd_help
    call shell_match_cmd
    jc .do_help

    mov ebx, cmd_clear
    call shell_match_cmd
    jc .do_clear

    mov ebx, cmd_ticks
    call shell_match_cmd
    jc .do_ticks

    mov ebx, cmd_ls
    call shell_match_cmd
    jc .do_ls

    mov ebx, cmd_cat
    call shell_match_cmd
    jc .do_cat

    mov ebx, cmd_touch
    call shell_match_cmd
    jc .do_touch

    mov ebx, cmd_rm
    call shell_match_cmd
    jc .do_rm

    mov ebx, cmd_panic
    call shell_match_cmd
    jc .do_panic

    ; Print error if command is not recognized
    mov esi, msg_unknown
    mov ah, 0x0C                    ; Light red on black
    call shell_write_string
    call shell_newline
    jmp .prompt_and_exit

; --- Command: help ---
.do_help:
    mov esi, msg_help
    mov ah, 0x0F                    ; White on black
    call shell_write_string
    call shell_newline
    jmp .prompt_and_exit

; --- Command: clear ---
.do_clear:
    call shell_clear_screen
    jmp .prompt_and_exit

; --- Command: ticks ---
.do_ticks:
    mov esi, msg_ticks
    mov ah, 0x0B                    ; Light cyan on black
    call shell_write_string
    mov eax, [timer_ticks]
    call shell_write_dec
    mov esi, msg_secs
    mov ah, 0x0B
    call shell_write_string
    mov eax, [timer_ticks]
    xor edx, edx
    mov ecx, 100                    ; PIT runs at 100 Hz (100 ticks = 1 second)
    div ecx
    call shell_write_dec
    mov al, 's'
    mov ah, 0x0B
    stosw
    call shell_newline
    jmp .prompt_and_exit

; --- Command: ls ---
; --- Command: ls ---
.do_ls:
    xor ecx, ecx
.ls_loop:
    cmp ecx, 16
    jae .prompt_and_exit

    mov eax, ecx
    call fs_get_entry_ptr
    cmp byte [eax + 20], 1          ; Check if slot is active
    jne .ls_next

    mov edx, eax                    ; Save slot base pointer in EDX before EAX gets clobbered

    ; Print filename
    mov esi, edx
    mov ah, 0x0E                    ; Yellow on black
    call shell_write_string

    mov esi, msg_ls_sep
    mov ah, 0x07
    call shell_write_string

    ; Print file size in bytes
    mov eax, [edx + 16]             ; Read size from preserved slot pointer EDX
    call shell_write_dec

    mov esi, msg_bytes
    mov ah, 0x07
    call shell_write_string
    call shell_newline

.ls_next:
    inc ecx
    jmp .ls_loop

; --- Command: cat <filename> ---
.do_cat:
    call shell_next_arg             ; Advance ESI past "cat" to filename
    cmp byte [esi], 0
    je .missing_arg

    call fs_read
    test eax, eax
    jz .file_not_found

    mov esi, eax
    mov ah, 0x0F
    call shell_write_string
    call shell_newline
    jmp .prompt_and_exit

; --- Command: touch <filename> <text> ---
.do_touch:
    call shell_next_arg             ; Advance ESI to filename
    cmp byte [esi], 0
    je .missing_arg

    mov edx, esi                    ; Save filename pointer in EDX
    ; Scan for space between filename and content text
.find_content:
    cmp byte [esi], 0
    je .no_content
    cmp byte [esi], ' '
    je .split_arg
    inc esi
    jmp .find_content

.split_arg:
    mov byte [esi], 0               ; Null-terminate filename in place
    inc esi                         ; ESI now points to file content
    jmp .write_now

.no_content:
    mov esi, empty_str

.write_now:
    push edi
    mov edi, esi                    ; EDI = content string
    mov esi, edx                    ; ESI = filename string
    call fs_write
    pop edi

    test eax, eax
    jnz .fs_full

    mov esi, msg_saved
    mov ah, 0x0A
    call shell_write_string
    call shell_newline
    jmp .prompt_and_exit

; --- Command: rm <filename> ---
.do_rm:
    call shell_next_arg
    cmp byte [esi], 0
    je .missing_arg

    call fs_delete
    test eax, eax
    jnz .file_not_found

    mov esi, msg_deleted
    mov ah, 0x0A
    call shell_write_string
    call shell_newline
    jmp .prompt_and_exit

; --- Command: panic ---
.do_panic:
    int 0                           ; Trigger vector 0 (Divide Error) to test IDT panic screen

.missing_arg:
    mov esi, msg_arg_err
    mov ah, 0x0C
    call shell_write_string
    call shell_newline
    jmp .prompt_and_exit

.file_not_found:
    mov esi, msg_not_found
    mov ah, 0x0C
    call shell_write_string
    call shell_newline
    jmp .prompt_and_exit

.fs_full:
    mov esi, msg_fs_full
    mov ah, 0x0C
    call shell_write_string
    call shell_newline

.prompt_and_exit:
    call shell_print_prompt

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret


; Compares command word at ESI against keyword at EBX
; Output: CF = 1 on exact match (followed by space or null), CF = 0 otherwise
shell_match_cmd:
    push eax
    push esi
    push ebx

.loop:
    mov al, [ebx]
    test al, al
    jz .end_of_kw

    cmp al, [esi]
    jne .no_match

    inc esi
    inc ebx
    jmp .loop

.end_of_kw:
    cmp byte [esi], 0
    je .match
    cmp byte [esi], ' '
    je .match

.no_match:
    pop ebx
    pop esi
    pop eax
    clc
    ret

.match:
    pop ebx
    pop esi
    pop eax
    stc
    ret


; Advances ESI past the current command word and any spaces to the next argument
shell_next_arg:
.skip_word:
    cmp byte [esi], 0
    je .done
    cmp byte [esi], ' '
    je .skip_ws
    inc esi
    jmp .skip_word
.skip_ws:
    cmp byte [esi], ' '
    jne .done
    inc esi
    jmp .skip_ws
.done:
    ret


; Writes null-terminated string ESI to VGA cursor EDI with color attribute AH
shell_write_string:
    cld
.next:
    lodsb
    test al, al
    jz .done
    stosw
    cmp edi, VGA_END
    jb .next
    call shell_scroll
    jmp .next
.done:
    ret


; Moves EDI to column 0 of the next row and scrolls if at bottom of screen
shell_newline:
    push eax
    push ecx
    push edx

    mov eax, edi
    sub eax, VGA_BUFFER
    xor edx, edx
    mov ecx, 160                    ; 80 columns * 2 bytes per cell
    div ecx

    inc eax
    imul eax, 160
    add eax, VGA_BUFFER
    mov edi, eax

    cmp edi, VGA_END
    jb .done
    call shell_scroll
.done:
    pop edx
    pop ecx
    pop eax
    ret


; Scrolls screen up by one row and clears the bottom row
shell_scroll:
    push eax
    push ecx
    push esi

    cld
    mov esi, VGA_BUFFER + 160
    mov edi, VGA_BUFFER
    mov ecx, VGA_COLUMNS * (VGA_ROWS - 1)
    rep movsw

    mov edi, VGA_LAST_ROW
    mov ax, 0x0F20
    mov ecx, VGA_COLUMNS
    rep stosw

    mov edi, VGA_LAST_ROW

    pop esi
    pop ecx
    pop eax
    ret


; Clears entire VGA screen and resets EDI to top-left
shell_clear_screen:
    push eax
    push ecx

    cld
    mov edi, VGA_BUFFER
    mov ax, 0x0F20
    mov ecx, 2000
    rep stosw
    mov edi, VGA_BUFFER

    pop ecx
    pop eax
    ret


; Prints unsigned 32-bit integer in EAX as decimal at EDI
shell_write_dec:
    push eax
    push ebx
    push ecx
    push edx

    mov ebx, 10
    xor ecx, ecx
    test eax, eax
    jnz .convert

    mov al, '0'
    mov ah, 0x0F
    stosw
    jmp .done

.convert:
    xor edx, edx
    div ebx
    push edx
    inc ecx
    test eax, eax
    jnz .convert

.print:
    pop eax
    add al, '0'
    mov ah, 0x0F
    stosw
    loop .print

.done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret


section .rodata
prompt_str      db "tinyos> ", 0
empty_str       db 0

cmd_help        db "help", 0
cmd_clear       db "clear", 0
cmd_ticks       db "ticks", 0
cmd_ls          db "ls", 0
cmd_cat         db "cat", 0
cmd_touch       db "touch", 0
cmd_rm          db "rm", 0
cmd_panic       db "panic", 0

msg_help        db "Commands: help, clear, ticks, ls, touch <file> <text>, cat <file>, rm <file>, panic", 0
msg_unknown     db "Unknown command. Type 'help'.", 0
msg_ticks       db "Ticks: ", 0
msg_secs        db " | Uptime: ", 0
msg_ls_sep      db "  (", 0
msg_bytes       db " bytes)", 0
msg_saved       db "File saved.", 0
msg_deleted     db "File deleted.", 0
msg_arg_err     db "Error: missing filename argument.", 0
msg_not_found   db "Error: file not found.", 0
msg_fs_full     db "Error: RAMFS full (max 16 files).", 0


section .bss
align 4
shell_prompt_end:
    resd 1
