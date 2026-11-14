

First install all required packeges (Imp for making iso and run that)
     which checks and tells you what you missing or you are good to go
    ./script/check-env.sh
    Install the missing packages

After that create build (every build has setup from complie to run the QEMU and boot)
    cmake -S . -B build
    cmake --build build --target verify   -> verifies the boot.asm etc
    cmake --build build --target iso
    cmake --build build --target run
    all targets are set check in cmake.txt


For grub 
    install these
    sudo apt install grub-common grub-pc-bin xorriso mtools