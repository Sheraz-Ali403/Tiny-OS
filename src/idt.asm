BITS 32

section .text

global idt_init

; tells linked that irq0 and 1 exist outside of this file
extern irq0_stub
extern irq1_stub

; define all macros first
; Create an IDT gate for a vector, it write the address of isr_X into the idt_table array in RAM
%macro SET_IDT_GATE 2
    mov eax, %1
    shl eax, 3    ; eax holds entry isr_index(vector)* 8

    mov edx, %2   ; edx has address of handler

    mov [idt_table + eax], dx
    mov word [idt_table + eax + 2], 0x08
    mov byte [idt_table + eax + 4], 0
    mov byte [idt_table + eax + 5], 0x8E

    shr edx, 16
    mov [idt_table + eax + 6], dx
%endmacro

;T hese macro makes labels of all isr_x 
; Exceptions without an error code
%macro ISR_NOERR_CODE 1
isr_%1:
    push dword 0    ; it doesnot have any error code so no error code pushed in stack so we pushed dummy value to set the stack otherwise isr_common reads wrong stack values
    push dword %1
    jmp isr_common
%endmacro


; Exceptions with an error code, auto pushed the error code in stack
%macro ISR_ERR_CODE 1
isr_%1:
    push dword %1
    jmp isr_common
%endmacro




idt_init:
    pushad
    cli

    ;mov the defualt handler address first
    mov eax, isr_default
    mov ebx, eax
    shr ebx, 16            ; ax holds lower base addr, bx holds higher base addr

    mov edi, idt_table
    mov ecx, 256           ; 256 vectors entries total in table
    
;fills each entry of 8 bytes accordingly
.fill_idt:
    mov [edi], ax
    mov word [edi +2], 0x08
    mov byte [edi +4], 0
    mov byte [edi +5], 0x8E
    mov [edi + 6], bx

    add edi, 8
    loop .fill_idt

    ; Set up the CPU exception handlers
    SET_IDT_GATE 0, isr_0
    SET_IDT_GATE 1, isr_1
    SET_IDT_GATE 2, isr_2
    SET_IDT_GATE 3, isr_3
    SET_IDT_GATE 4, isr_4
    SET_IDT_GATE 5, isr_5
    SET_IDT_GATE 6, isr_6
    SET_IDT_GATE 7, isr_7
    SET_IDT_GATE 8, isr_8
    SET_IDT_GATE 9, isr_9
    SET_IDT_GATE 10, isr_10
    SET_IDT_GATE 11, isr_11
    SET_IDT_GATE 12, isr_12
    SET_IDT_GATE 13, isr_13
    SET_IDT_GATE 14, isr_14
    SET_IDT_GATE 15, isr_15
    SET_IDT_GATE 16, isr_16
    SET_IDT_GATE 17, isr_17
    SET_IDT_GATE 18, isr_18
    SET_IDT_GATE 19, isr_19
    SET_IDT_GATE 20, isr_20
    SET_IDT_GATE 21, isr_21
    SET_IDT_GATE 22, isr_22
    SET_IDT_GATE 23, isr_23
    SET_IDT_GATE 24, isr_24
    SET_IDT_GATE 25, isr_25
    SET_IDT_GATE 26, isr_26
    SET_IDT_GATE 27, isr_27
    SET_IDT_GATE 28, isr_28
    SET_IDT_GATE 29, isr_29
    SET_IDT_GATE 30, isr_30
    SET_IDT_GATE 31, isr_31

    ; Set up hardware IRQ handlers timer and keyboard
    SET_IDT_GATE 32, irq0_stub
    SET_IDT_GATE 33, irq1_stub

    ; Load the IDT
    lidt [idt_descriptor]

    popad
    ret

; Handle an unexpected interrupt
isr_default:
    push dword 0
    push dword 255
    jmp isr_common


; Exceptions without an error code
ISR_NOERR_CODE 0
ISR_NOERR_CODE 1
ISR_NOERR_CODE 2
ISR_NOERR_CODE 3
ISR_NOERR_CODE 4
ISR_NOERR_CODE 5
ISR_NOERR_CODE 6
ISR_NOERR_CODE 7
ISR_ERR_CODE   8
ISR_NOERR_CODE 9
ISR_ERR_CODE   10
ISR_ERR_CODE   11
ISR_ERR_CODE   12
ISR_ERR_CODE   13
ISR_ERR_CODE   14
ISR_NOERR_CODE 15
ISR_NOERR_CODE 16
ISR_ERR_CODE   17
ISR_NOERR_CODE 18
ISR_NOERR_CODE 19
ISR_ERR_CODE   20
ISR_ERR_CODE   21
ISR_NOERR_CODE 22
ISR_NOERR_CODE 23
ISR_NOERR_CODE 24
ISR_NOERR_CODE 25
ISR_NOERR_CODE 26
ISR_NOERR_CODE 27
ISR_NOERR_CODE 28
ISR_ERR_CODE   29
ISR_ERR_CODE   30
ISR_NOERR_CODE 31


; Handle exceptions no extra defined exception handling just showing the kernel panic screen
isr_common:
    cli
    pushad

    ; Save the exception details
    ; on 32 stack has index num (isr_num), 36 has error code, 40 has the eip just before the exception occurred
    mov eax,[esp + 32]
    mov [last_exception_vector], eax

    mov eax,[esp + 36]
    mov [last_exception_error], eax

    mov eax,[esp + 40]
    mov [last_exception_eip], eax

    ; display panic screen instead of just halt/freezing
    call panic_screen

;;; KERNELL PACINCCC
.halt:
    hlt
    jmp .halt


; display kernal panic vga proc designed by GPT


panic_screen:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    cld

    ; Clear the screen
    mov edi, 0xB8000
    mov ax, 0x0720
    mov ecx, 2000
    rep stosw

    ; Fill the top bar
    mov edi, 0xB8000
    mov ax, 0x4F20
    mov ecx, 80
    rep stosw

    ; Fill the bottom bar
    mov edi, 0xB8F00
    mov ax, 0x4F20
    mov ecx, 80
    rep stosw

    ; Header
    mov edi, 0xB8006
    mov esi, panic_title
    mov bl, 0x4F
    call panic_print_string

    ; Main error message - row 2
    mov edi, 0xB8148
    mov esi, panic_message
    mov bl, 0x0C
    call panic_print_string

    ; System status - row 4
    mov edi, 0xB8288
    mov esi, panic_status
    mov bl, 0x0C
    call panic_print_string

    ; Diagnostic heading - row 6
    mov edi, 0xB83C8
    mov esi, panic_details
    mov bl, 0x0B
    call panic_print_string

    ; Exception name - row 8
    mov edi, 0xB8508
    mov esi, panic_cause
    mov bl, 0x0F
    call panic_print_string

    call panic_select_name
    mov bl, 0x0C
    call panic_print_string

    ; Exception vector - row 9
    mov edi, 0xB85A8
    mov esi, panic_vector
    mov bl, 0x0F
    call panic_print_string

    mov eax, [last_exception_vector]
    mov bl, 0x0E
    call panic_print_hex32

    ; Error code - row 10
    mov edi, 0xB8648
    mov esi, panic_error
    mov bl, 0x0F
    call panic_print_string

    mov eax, [last_exception_error]
    mov bl, 0x0E
    call panic_print_hex32

    ; Faulting instruction address - row 11
    mov edi, 0xB86E8
    mov esi, panic_eip
    mov bl, 0x0F
    call panic_print_string

    mov eax, [last_exception_eip]
    mov bl, 0x0E
    call panic_print_hex32

    ; Developer messages - row 15
    mov edi, 0xB8968
    mov esi, panic_congratulations
    mov bl, 0x0E
    call panic_print_string

    ; Row 17
    mov edi, 0xB8A48
    mov esi, panic_left
    mov bl, 0x0F
    call panic_print_string

    ; Row 18
    mov edi, 0xB8AE8
    mov esi, panic_on_your_own
    mov bl, 0x0F
    call panic_print_string

    ; Row 20
    mov edi, 0xB8C28
    mov esi, panic_good_luck
    mov bl, 0x07
    call panic_print_string

    ; Bottom bar text
    mov edi, 0xB8F06
    mov esi, panic_footer
    mov bl, 0x4F
    call panic_print_string

.stop:
    cli
    hlt
    jmp .stop


; Print a null-terminated string
panic_print_string:
.next:
    lodsb
    test al, al
    jz .done

    mov ah, bl
    stosw
    jmp .next

.done:
    ret


; Print a 32-bit value in hexadecimal
panic_print_hex32:
    mov ecx, 8

.next:
    rol eax, 4

    mov dl, al
    and dl, 0x0F

    cmp dl, 9
    jbe .digit

    add dl, 'A' - 10
    jmp .write

.digit:
    add dl, '0'

.write:
    mov al, dl
    mov ah, bl
    stosw

    loop .next
    ret


; Select the exception name
panic_select_name:
    mov esi, panic_unknown

    cmp dword [last_exception_vector], 0
    je .divide

    cmp dword [last_exception_vector], 6
    je .invalid_opcode

    cmp dword [last_exception_vector], 8
    je .double_fault

    cmp dword [last_exception_vector], 13
    je .general_protection

    cmp dword [last_exception_vector], 14
    je .page_fault

    ret

.divide:
    mov esi, panic_divide
    ret

.invalid_opcode:
    mov esi, panic_invalid_opcode
    ret

.double_fault:
    mov esi, panic_double_fault
    ret

.general_protection:
    mov esi, panic_general_protection
    ret

.page_fault:
    mov esi, panic_page_fault
    ret




section .rodata

idt_descriptor:
    dw 2048 - 1
    dd idt_table

; panic_texts
panic_not_supposed:
    db "Well, that wasn't supposed to happen.", 0

panic_congratulations:
    db "Congratulations! You maybe broke your kernel.", 0

panic_left:
    db "The kernel has left the conversation.", 0

panic_on_your_own:
    db "We are out. You're on your own now.", 0

panic_good_luck:
    db "The CPU is halted. Good luck, developer.", 0

;

section .rodata

panic_title:
    db "TINYOS // CORE PANIC", 0

panic_message:
    db "Well, that wasn't supposed to happen.", 0

panic_status:
    db "SYSTEM HALTED - FATAL CPU EXCEPTION", 0

panic_details:
    db "EXCEPTION DETAILS", 0

panic_cause:
    db "Exception : ", 0

panic_vector:
    db "Vector    : ", 0

panic_error:
    db "Error Code: ", 0

panic_eip:
    db "EIP       : ", 0

panic_footer:
    db "TINYOS // NO RECOVERY ATTEMPTED", 0

panic_divide:
    db "DIVIDE ERROR", 0

panic_invalid_opcode:
    db "INVALID OPCODE", 0

panic_double_fault:
    db "DOUBLE FAULT", 0

panic_general_protection:
    db "GENERAL PROTECTION FAULT", 0

panic_page_fault:
    db "PAGE FAULT", 0

panic_unknown:
    db "UNKNOWN CPU EXCEPTION", 0



; for reserving spaces for idt table and 
section .bss
align 8

idt_table:
    resb 256 * 8

last_exception_vector:
    resd 1

last_exception_error:
    resd 1

last_exception_eip:
    resd 1
