cmake_minimum_required(VERSION 3.20)

project(TinyOS VERSION 0.1.0 LANGUAGES NONE)

find_program(NASM_EXECUTABLE NAMES nasm REQUIRED)
find_program(I686_ELF_LD_EXECUTABLE NAMES i686-elf-ld REQUIRED)
find_program(GRUB_MKRESCUE_EXECUTABLE NAMES grub-mkrescue REQUIRED)
find_program(GRUB_FILE_EXECUTABLE NAMES grub-file REQUIRED)
find_program(QEMU_EXECUTABLE NAMES qemu-system-i386 REQUIRED)

set(BOOT_OBJECT "${CMAKE_CURRENT_BINARY_DIR}/boot.o")
set(KERNEL_ELF "${CMAKE_CURRENT_BINARY_DIR}/kernel.elf")
set(KERNEL_MAP "${CMAKE_CURRENT_BINARY_DIR}/kernel.map")
set(KERNEL_ISO "${CMAKE_CURRENT_BINARY_DIR}/tinyos.iso")
set(ISO_ROOT "${CMAKE_CURRENT_BINARY_DIR}/iso-root")
set(LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/linker/linker.ld")
set(GRUB_CONFIG "${CMAKE_CURRENT_SOURCE_DIR}/grub/grub.cfg")

# 1. Assemble boot.asm
add_custom_command(
    OUTPUT "${BOOT_OBJECT}"
    COMMAND "${NASM_EXECUTABLE}" -f elf32 -g -F dwarf
            "${CMAKE_CURRENT_SOURCE_DIR}/boot/boot.asm" -o "${BOOT_OBJECT}"
    DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/boot/boot.asm"
    COMMENT "Assembling Multiboot entry (ELF32)"
    VERBATIM
)

# 2. Automatically find and assemble every .asm file in src/ (excluding timer.asm)
file(GLOB SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.asm")
list(REMOVE_ITEM SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/timer.asm")

set(ALL_OBJECTS "${BOOT_OBJECT}")

foreach(SRC_FILE ${SRC_FILES})
    get_filename_component(FILE_NAME "${SRC_FILE}" NAME_WE)
    set(OBJ_FILE "${CMAKE_CURRENT_BINARY_DIR}/${FILE_NAME}.o")

    add_custom_command(
        OUTPUT "${OBJ_FILE}"
        COMMAND "${NASM_EXECUTABLE}" -f elf32 -g -F dwarf
                "${SRC_FILE}" -o "${OBJ_FILE}"
        DEPENDS "${SRC_FILE}"
        COMMENT "Assembling ${FILE_NAME}.asm (ELF32)"
        VERBATIM
    )

    list(APPEND ALL_OBJECTS "${OBJ_FILE}")
endforeach()

# 3. Link everything into kernel.elf
add_custom_command(
    OUTPUT "${KERNEL_ELF}"
    BYPRODUCTS "${KERNEL_MAP}"
    COMMAND "${I686_ELF_LD_EXECUTABLE}" -T "${LINKER_SCRIPT}"
            "-Map=${KERNEL_MAP}" -o "${KERNEL_ELF}"
            ${ALL_OBJECTS}
    DEPENDS ${ALL_OBJECTS} "${LINKER_SCRIPT}"
    COMMENT "Linking freestanding i686 kernel ELF"
    VERBATIM
)

add_custom_target(kernel ALL DEPENDS "${KERNEL_ELF}")

add_custom_target(verify
    COMMAND "${GRUB_FILE_EXECUTABLE}" --is-x86-multiboot "${KERNEL_ELF}"
    COMMAND "${CMAKE_COMMAND}" -E echo "Valid Multiboot v1 kernel: ${KERNEL_ELF}"
    DEPENDS kernel
    COMMENT "Checking kernel Multiboot header"
    VERBATIM
)

add_custom_command(
    OUTPUT "${KERNEL_ISO}"
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${ISO_ROOT}/boot/grub"
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${KERNEL_ELF}" "${ISO_ROOT}/boot/kernel.elf"
    COMMAND "${CMAKE_COMMAND}" -E copy_if_different
            "${GRUB_CONFIG}" "${ISO_ROOT}/boot/grub/grub.cfg"
    COMMAND "${GRUB_FILE_EXECUTABLE}" --is-x86-multiboot "${KERNEL_ELF}"
    COMMAND "${GRUB_MKRESCUE_EXECUTABLE}" -o "${KERNEL_ISO}" "${ISO_ROOT}"
    DEPENDS "${KERNEL_ELF}" "${GRUB_CONFIG}"
    COMMENT "Creating bootable GRUB ISO"
    VERBATIM
)

add_custom_target(iso DEPENDS "${KERNEL_ISO}")

add_custom_target(run
    COMMAND "${QEMU_EXECUTABLE}" -display sdl -m 128M -cdrom "${KERNEL_ISO}"
            -boot d -no-reboot -no-shutdown
    DEPENDS iso
    USES_TERMINAL
    COMMENT "Booting TinyOS in QEMU"
    VERBATIM
)

add_custom_target(debug
    COMMAND "${QEMU_EXECUTABLE}" -m 128M -cdrom "${KERNEL_ISO}"
            -boot d -no-reboot -no-shutdown
            -gdb tcp:127.0.0.1:1234 -S
    DEPENDS iso
    USES_TERMINAL
    COMMENT "Launching QEMU paused with GDB stub on 127.0.0.1:1234"
    VERBATIM
)
