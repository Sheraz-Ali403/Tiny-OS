[BITS 32]

; PIC_1 is Master PIC  ; Masters IRQs starts form 0-7
; PIC_2 is  Slave PIC

%define PIC1_COMMAND  0x20   ; PIC_1 com port num
%define PIC1_DATA     0x21     ;PIC_1 data port num 
%define PIC2_COMMAND  0xA0     ; PIC_2 com port num
%define PIC2_DATA     0xA1     ;PIC_1 data port num 

; Remaping each to start at index 32 instead of 0 (0-31 already set for isp_hanlders)
; 0010 0000 -> points to ind 0 + 0010 0000 -> now points to ind 32 for Slave PIC
; same for the Slave PIC ind must starts from 40
%define PIC1_OFFSET   0x20
%define PIC2_OFFSET   0x28

; Old way of sleep so that hardware processes the commads easily witout losing the next commands
%macro io_wait 0
    ;mov al, 0
    xor al, al 
    out 0x80, al    ;0x80 is unused hardware port so we send dummy signal here which has no effect but cause dealy
%endmacro

global pic_init

section .text
pic_init:
    cli
    pushad

    ; Initialization both PICs via command 0x11
    mov dx, PIC1_COMMAND
    mov al, 0x11         ;0x11 initialization command ICW1
    out dx, al
    io_wait              ;wait so it complete commands easily

    mov dx, PIC2_COMMAND
    mov al, 0x11
    out dx, al
    io_wait

    ; Remap interrupt vector offsets
    mov dx, PIC1_DATA
    mov al, PIC1_OFFSET
    out dx, al
    io_wait

    mov dx, PIC2_DATA
    mov al, PIC2_OFFSET
    out dx, al
    io_wait

    ; Configure master and slave cascade relation cz only PCI_1 is connected to CPU while PCI_2 (slave) is not.
    ; so PIC_2 can pass intrupts throught PCI_1 to CPU
    mov dx, PIC1_DATA
    mov al, 0x04    ;Slave PIC is connected on IRQ_2 (Bit mask 00000100)
    out dx, al
    io_wait

    ;slave doesnot use BitMask to show IRQ_2 as 00000100, instead it directly says 00000010
    mov dx, PIC2_DATA
    mov al, 0x02       ;Master PIC is connected on IRQ_2
    out dx, al
    io_wait

    ; Set both PICs to 8086 mode ( 32-bit and 64-bit x86 processors)
    ; Bit 0 (1=8086 CPU, 0=8085)
    ; bit 1 EOI (end of intrupt) is disable unitl we set the intrupts
    mov dx, PIC1_DATA
    mov al, 0x01
    out dx, al
    io_wait

    mov dx, PIC2_DATA
    mov al, 0x01
    out dx, al
    io_wait

    ; Mask all IRQs until their handlers are ready
    ; IMR registor 11111111 for MASK and 00000000 for UnMASK
    ; later unmask the IRQ_0 and 1 cz these wil be used here
    mov dx, PIC1_DATA
    mov al, 0xFF
    out dx, al

    mov dx, PIC2_DATA
    mov al, 0xFF
    out dx, al

    popad
    ret
