[BITS 32]

; Fixed-slot in-memory file system (RAMFS) limits
%define FS_MAX_FILES        16
%define FS_NAME_LEN         16
%define FS_DATA_SIZE        512
; Entry layout (536 bytes per file slot):
;   [0..15]   filename (null-terminated, max 15 chars)
;   [16..19]  file size in bytes (dword)
;        in-use flag (1 = active, 0 = free)
;   [21..23]  alignment padding
;   [24..535] file content buffer (null-terminated, max 511 chars)
%define FS_ENTRY_SIZE       536

global fs_init
global fs_write
global fs_read
global fs_delete
global fs_get_entry_ptr

section .text

; Initializes the file table and creates a default readme.txt
fs_init:
    pushad

    ; Zero out all 16 file entries in RAM
    cld
    mov edi, fs_table
    mov ecx, (FS_MAX_FILES * FS_ENTRY_SIZE) / 4
    xor eax, eax
    rep stosd

    ; Create initial readme.txt file
    mov esi, default_file_name
    mov edi, default_file_data
    call fs_write

    popad
    ret


; Creates a new file or overwrites an existing file with the same name
; Input:  ESI -> null-terminated filename
;         EDI -> null-terminated content string
; Output: EAX = 0 on success, 1 if all 16 file slots are full
fs_write:
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov edx, edi                ; Preserve content pointer in EDX
    call fs_find_slot           ; Check if file already exists (returns slot in EBX)
    test ebx, ebx
    jnz .write_entry

    ; Otherwise allocate the first free slot
    call fs_find_free_slot
    test ebx, ebx
    jz .full

.write_entry:
    ; Mark slot as active
    mov byte [ebx + 20], 1

    ; Copy filename (up to 15 chars + null terminator)
    push edi
    mov edi, ebx
    mov ecx, FS_NAME_LEN - 1
.copy_name:
    lodsb
    stosb
    test al, al
    jz .name_done
    loop .copy_name
    mov byte [edi], 0
.name_done:
    pop edi

    ; Copy file data into offset +24 and count byte length
    mov esi, edx
    lea edi, [ebx + 24]
    xor ecx, ecx
.copy_data:
    cmp ecx, FS_DATA_SIZE - 1
    jae .data_done
    lodsb
    stosb
    test al, al
    jz .data_done
    inc ecx
    jmp .copy_data

.data_done:
    mov byte [edi], 0           ; Ensure null termination
    mov [ebx + 16], ecx         ; Store exact byte count
    xor eax, eax                ; Return 0 (success)
    jmp .done

.full:
    mov eax, 1                  ; Return 1 (filesystem full)

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret


; Looks up a file by name and returns a pointer to its content
; Input:  ESI -> null-terminated filename
; Output: EAX -> pointer to file content, or 0 if not found
fs_read:
    push ebx

    call fs_find_slot
    test ebx, ebx
    jz .not_found

    lea eax, [ebx + 24]         ; Content starts at byte offset 24
    jmp .done

.not_found:
    xor eax, eax

.done:
    pop ebx
    ret


; Deletes a file by name and frees its slot
; Input:  ESI -> null-terminated filename
; Output: EAX = 0 on success, 1 if file not found
fs_delete:
    push ebx

    call fs_find_slot
    test ebx, ebx
    jz .not_found

    mov byte [ebx + 20], 0      ; Clear in-use flag
    mov dword [ebx + 16], 0     ; Reset byte size
    mov byte [ebx], 0           ; Clear filename
    xor eax, eax
    jmp .done

.not_found:
    mov eax, 1

.done:
    pop ebx
    ret


; Returns the base address of slot index EAX (0..15) for directory listing
; Input:  EAX = slot index
; Output: EAX = pointer to FS_ENTRY_SIZE struct
fs_get_entry_ptr:
    imul eax, FS_ENTRY_SIZE
    add eax, fs_table
    ret


; Internal helper: searches active slots for filename in ESI
; Output: EBX = slot base pointer if found, or 0 if not found
fs_find_slot:
    push ecx
    push edx
    push esi
    push edi

    mov ebx, fs_table
    mov ecx, FS_MAX_FILES

.next_slot:
    cmp byte [ebx + 20], 1      ; Skip inactive slots
    jne .skip

    ; Compare ESI (target name) with EBX (slot name)
    push esi
    push edi
    mov edi, ebx
.cmp_loop:
    mov al, [esi]
    mov dl, [edi]
    cmp al, dl
    jne .mismatch
    test al, al
    jz .matched
    inc esi
    inc edi
    jmp .cmp_loop

.mismatch:
    pop edi
    pop esi

.skip:
    add ebx, FS_ENTRY_SIZE
    loop .next_slot

    xor ebx, ebx
    jmp .done

.matched:
    pop edi
    pop esi

.done:
    pop edi
    pop esi
    pop edx
    pop ecx
    ret


; Internal helper: finds first slot with in-use flag == 0
; Output: EBX = slot base pointer if available, or 0 if full
fs_find_free_slot:
    push ecx

    mov ebx, fs_table
    mov ecx, FS_MAX_FILES

.next:
    cmp byte [ebx + 20], 0
    je .found
    add ebx, FS_ENTRY_SIZE
    loop .next

    xor ebx, ebx

.found:
    pop ecx
    ret


section .rodata
default_file_name db "readme.txt", 0
default_file_data db "TinyOS RAMFS initialized. Type 'help' for commands.", 0


section .bss
align 4
fs_table:
    resb FS_MAX_FILES * FS_ENTRY_SIZE
