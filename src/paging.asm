[BITS 32]

; Page table entry flags
; Bit 0: Present (1 = page is mapped in physical RAM)
; Bit 1: Read/Write (2 = writable, 0 = read-only)
; Bit 2: User/Supervisor (0 = Ring 0 kernel only)
%define PAGE_PRESENT    0x001
%define PAGE_RW         0x002
%define PAGE_FLAGS      (PAGE_PRESENT | PAGE_RW)

global paging_init

section .text

; Initializes identity-mapped paging for the first 4 MB (0x00000000 - 0x003FFFFF)
; Keeps kernel code, stack, and VGA memory (0xB8000) at their exact physical addresses
paging_init:
    pushad

    ; Zero out the entire page directory (1024 entries * 4 bytes = 4096 bytes)
    cld
    mov edi, page_directory
    mov ecx, 1024
    xor eax, eax
    rep stosd

    ; Populate first page table (1024 pages * 4 KB = 4 MB)
    mov edi, first_page_table
    mov eax, 0x00000000 | PAGE_FLAGS    ; Physical address 0x00000000 + Present/RW flags
    mov ecx, 1024

.fill_table:
    mov [edi], eax
    add eax, 0x1000                     ; Advance by 4 KB (4096 bytes) per page
    add edi, 4                          ; Advance to next 32-bit page table entry
    loop .fill_table

    ; Link Page Directory Entry 0 (covers 0x00000000 - 0x003FFFFF) to first_page_table
    mov eax, first_page_table
    or eax, PAGE_FLAGS
    mov [page_directory], eax

    ; Load Page Directory base address into CR3
    mov eax, page_directory
    mov cr3, eax

    ; Enable Paging by setting Bit 31 (PG) in CR0
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    popad
    ret


section .bss
; Both tables MUST be 4096-byte (4 KB) aligned for x86 hardware paging
align 4096

page_directory:
    resd 1024

first_page_table:
    resd 1024
