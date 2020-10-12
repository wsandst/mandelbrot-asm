; ----------------------------------------------------------------------------------------
; Calculate a fibonaci number iteratively
;
; ----------------------------------------------------------------------------------------

; Include helper file
%include "helpers.asm"

; Main program
section   .data
        msg:  db        "Generating mandelbrot"      ; note the newline at the end
        msglen:  equ $-msg
        newline: db 10
        imageheader: db "Hello, world!"
        outputfilename: db "output.ppm", 0
        outputfilenamelen: equ $-outputfilename

section .bss
        imageArray resb 64*64*3
        filehandle resq 1

section   .text
        global    _main

main:   
        print msg, msglen

        print newline, 1

        printInt 10

        print newline, 1

        exit 0

_openfile:
        mov rax, 2 ; system call for open
        mov rdi, outputfilename
        mov rsi, 577 ; flags
        mov rdx, 0644o ; mode. read and write
        syscall
        mov [filehandle], rax

_writeheader:
        mov rax, 4         ;syscall 4 - write()