AVR UART Hello World in assembly
================================

**This example outputs string "Hello World" to UART. The target chip is Atmega328P, used in Arduino Uno/Nano dev boards and their knockoffs.**

If you have **[Zig](http://ziglang.org)** installed, you can compile the program using

`zig cc -target avr-freestanding -mcpu=avr5 -mmcu=atmega328p -c uart_hello.S -o uart_hello.o`

..then link the program to create the final *.elf file:

`zig cc -target avr-freestanding -mcpu=avr5 -mmcu=atmega328p -nostdlib -s -T linker.ld .\uart_hello.o -o .\uart_hello.elf`

To test the binary in emulator, you can use **[Qemu](https://www.qemu.org/download/)** for AVR target:

`qemu-system-avr.exe -machine uno -nographic -device loader,file=.\uart_hello.elf`

(to terminate qemu running in console, press `Ctrl + A` followed by `X`)


...or flash the binary to the real hardware using your favourite programmer.

---

*If you don't have zig installed, you can still compile the program using **[llvm](https://releases.llvm.org/download.html)**:*

    clang --target=avr -mmcu=atmega328p -c uart_hello.S -o uart_hello.o
    clang --target=avr -mmcu=atmega328p -nostdlib -fuse-ld=lld -Wl,-T,linker.ld -Wl,-s .\uart_hello. -o .\uart_hello.elf