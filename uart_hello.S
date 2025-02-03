        .include "m328Pdef.inc"
        
        .section .vectors, "ax", @progbits
        .global _vectors
        .org 0
_vectors:
        ; vector table
        jmp _start      
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done
        jmp done

        .section .text
        .global _start

        .equ F_CPU,       16000000
        .equ BAUD,        9600
        ; Baud register value = (F_CPU / (16 * BAUD)) - 1
        .equ UBRR_VALUE, (F_CPU / (16 * BAUD)) - 1

        ;----------------------------------------------------------------------
        ; String data
        ;----------------------------------------------------------------------
        .section .rodata
msg:
        .ascii  "Hello World!\r\n"
        .byte   0   ; Null terminator

        ;----------------------------------------------------------------------
        ; Program entry point
        ;----------------------------------------------------------------------
        .section .text

_start:
        ;--------------------------------------------------
        ; COPY FLASH DATA TO RAM
        ;--------------------------------------------------
        ; load Z register with the address of the data in flash
        ldi r30, lo8(__data_load_start)
        ldi r31, hi8(__data_load_start)
        ; load X register with address of the data in ram
        ldi r26, lo8(__data_start)
        ldi r27, hi8(__data_start)
        ; load address of end of the data in ram
        ldi r24, lo8(__data_end)
        ldi r25, hi8(__data_end)
        rjmp .check_for_end_data

.copy_data:

        lpm r18, Z+ ; copy from Z into r18 and increment Z
        st X+, r18  ; store r18 at location X and increment X

.check_for_end_data:

        cp r26, r24
        cpc r27, r25 ; check and branch if we are at the end of data
        brne .copy_data

        ;--------------------------------------------------
        ; SET BSS TO ZERO
        ;--------------------------------------------------
        ; load X register with the beginning of bss section
        ldi r26, lo8(__bss_start)
        ldi r27, hi8(__bss_start)
        ; load end of the bss in registers
        ldi r24, lo8(__bss_end)
        ldi r25, hi8(__bss_end)
        ldi r18, 0x00
        rjmp .check_for_bss_end

.set_to_zero:

        st X+, r18

.check_for_bss_end:

        cp r26, r24
        cpc r27, r25 ; check and branch if we are at the end of bss
        brne .set_to_zero

        ;--------------------------------------------------
        ; Set the Baud Rate
        ; Use lo8(UBRR_VALUE) and hi8(UBRR_VALUE)
        ;--------------------------------------------------
        ldi     r16, hi8(UBRR_VALUE)
        sts     UBRR0H, r16
        ldi     r16, lo8(UBRR_VALUE)
        sts     UBRR0L, r16

        ; Enable TX
        ldi     r16, (1 << TXEN0)
        sts     UCSR0B, r16

        ; Frame format: 8 data bits, 1 stop bit, no parity
        ldi     r16, (1 << UCSZ01) | (1 << UCSZ00)
        sts     UCSR0C, r16

        ;--------------------------------------------------
        ; Transmit the string
        ;--------------------------------------------------
        ; Load address of msg into Z (r31:r30)
        ldi     r30, lo8(msg)
        ldi     r31, hi8(msg)

send_loop:
        ; Load next char
        ld      r16, Z+
        tst     r16
        breq    done   ; if zero terminator, jump to done

wait_udre:
        ;sbis    UCSR0A, UDRE0

        lds     r17, UCSR0A   ; load the UART status register into r17
        sbrs    r17, UDRE0    ; if the UDRE0 bit is set, skip the next instruction

        rjmp    wait_udre

        sts     UDR0, r16
        rjmp    send_loop

done:
        ; Loop forever
        rjmp    done
