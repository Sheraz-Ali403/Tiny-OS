; TinyOS kernel_main
BITS 32
VGA_BUFFER EQU 0xB8000                    ;VGA text buffer for showing things to screen
VGA_END   EQU 0xB8FA0
VGA_LAST_ROW EQU 0xB8F00
VGA_COLUMNS EQU 80 
VGA_ROWS EQU 25
VGA_END EQU 0xB8FA0


; readonly data section
section .rodata   
    line1 db 'Welcome to TinyOS!', 0
    line2 db '32-bit x86 Assembly kernel', 0
    AutherLine db 'By Sheraz Ali' , 0
    line3 db 'GRUB -> NASM -> VGA: boot successful.', 0
    error_line db 'ERROR: Invalid Multiboot magic.', 0

section .data
    vga_attribute_wOb db 0x0F      ; White texts on black screen


; code section
section .text
global kernel_main


;In C it is kernel_main(uint32 boot_magic, uint32 multiboot_info_ptr)
; [esp+4] = boot_magic (eax), [esp+8] = info pointer (not used yet) (ebx).
kernel_main:
    cmp dword [esp + 4], 0x2BADB002
    jne .bad_boot

    mov edi, VGA_BUFFER
    call clrf

    mov esi, line1
    mov ah, 0x0F                   ; Text Colors: white on black text attribute.
    call WriteString
    call clrf

    ;Auther name Row 2
    mov esi, AutherLine
    mov ah, 0x0E                    ; Text Colors: Yellow on black 
    call WriteString
    call clrf

    ; Row Three 
    mov esi, line2
    mov ah, 0x0F
    call WriteString
    call clrf

    ; Row three.
    mov esi, line3
    mov ah, 0x0A                   ; Light green on black attribute.
    call WriteString
    call clrf

    mov al, 'H'
    mov ah, 0x0F
    call WriteChar
    call newLine

    mov al, 'E'
    mov ah, 0x0F
    call WriteChar
    call newLine

    mov al, 'L'
    mov ah, 0x0F
    call WriteChar
    call newLine

    mov al, 'L'
    mov ah, 0x0F
    call WriteChar
    call newLine

    mov al, 'O'
    mov ah, 0x0F
    call WriteChar
    call newLine

    ;call ClearScreen   ; for test and worked
   ; call ScrollScreen   ; for test and worked
    ;call ScrollScreen   ;for test and worked

    mov al, 'O'
    mov ah, 0x0F
    call WriteChar
    call newLine



    ret                            ; imp for not going flow to label/funcs






.bad_boot:
    mov edi, VGA_BUFFER
    mov esi, error_line
    mov ah, 0x4F                   ; Bright-white text on red.
    call WriteString
    ret

; INPUT: ESI -> zero-terminated string, EDI -> VGA destination, AH -> color.
; CLOBBERS: EAX, ESI, EDI. This is not a general-purpose console yet.


;;;;;;;;; ;;;;;;;;;;;;;; PROCEDURESSSSS HEREEEE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; print string proc
; OFFSET in esi
WriteString:
    cld                            ; clears the dir flag means esi increments
    ;push ecx
    ;mov ecx, 0                     ; ecx here used for clearing the buffer of VGA after printing the line
.next:
    lodsb                          ; AL <- [ESI], then ESI++
    test al, al
    jz .done
    stosw                          ; [EDI] <- AX (character + attribute) writes AX into VGA mem
    ;inc ecx
    jmp .next
.done:
    ;sub edi, ecx
    ;sub edi, ecx
    ;pop ecx
    ret

; NewLine 
; perfect for strings only (not for others (manually edi set to start is required))
clrf:                           
    push eax
    push ecx
    push edx

    mov eax, edi
    sub eax, 0xB8000

    xor edx, edx
    mov ecx, 160
    div ecx                          ; (edx:eax)/ecx ->  edx reminder(col/offset), eax Quotient (row Number)

    inc eax
    imul eax, 160
    add eax, 0xB8000

    mov edi, eax

    pop edx
    pop ecx
    pop eax

    ret

; After previous edi new line
newLine:
    add edi, 160                   ; every call add 160 to print next in new row instead of doing manually
    ret

; print character proc
; character must be in al before call
WriteChar:
    stosw
    ret
    



; clear proc
ClearScreen:
    push eax
    push ecx

    cld
    mov edi, VGA_BUFFER
    mov al, ' '
    mov ah, [vga_attribute_wOb]

    mov ecx, 2000   ; all cells 80 col *25 rows
    rep stosw

    mov edi, VGA_BUFFER

    pop ecx
    pop eax
    ret


; Scrolling up (making row2 to row 1 and so on till row25 ro row24)
ScrollScreen:
    push eax
    push ecx
    push esi

    cld

    mov esi, VGA_BUFFER + 160             ; src: beginning of row 1
    mov edi, VGA_BUFFER                           ; dest: beginning of row 0

    mov ecx, VGA_COLUMNS * (VGA_ROWS - 1)        ; Copy 24 rows (24 * 80 character cells)
    rep movsw

    ; clear the last row
    mov edi, VGA_LAST_ROW
    mov al, ' '
    mov ah, [vga_attribute_wOb]
    mov ecx, VGA_COLUMNS
    rep stosw

    ; cursor at the start of last row
    mov edi, VGA_LAST_ROW

    pop esi
    pop ecx
    pop eax
    ret


WriteDec:
    push ebx
    push ecx
    push edx

    mov ebx, 10
    xor ecx, ecx

    test eax, eax
    jnz .convert

    ; Special case: zero then direct print 0
    mov al, '0'
    mov ah, [vga_attribute_wOb]
    call WriteChar
    jmp .done

.convert:
    xor edx, edx
    div ebx

    ; save remainder (next decimal digit)
    push edx
    inc ecx

    test eax, eax
    jnz .convert

; Print each digit pushed in stack in .convert loop
.print:
    pop eax
    add al, '0'
    mov ah, [vga_attribute_wOb]
    call WriteChar

    loop .print

.done:
    mov ah, [vga_attribute_wOb]

    pop edx
    pop ecx
    pop ebx
    ret


; if rows ended or not cmp and then scroll
CheckScroll:
    cmp edi, VGA_END
    jb .done

    call ScrollScreen
.done:
    ret

; Backspace Procc
Backspace:
    cmp edi, VGA_BASE
    jbe .done

    ; mov to previous character cell
    sub edi, 2

    mov al, ' '
    mov ah, [vga_attribute_wOb]
    stosw

    ; cursor would be at erased position
    sub edi, 2
.done:
    ret


