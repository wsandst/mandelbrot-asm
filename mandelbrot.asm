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
        imageheader: db "P6", 10, "2 2", 10, "255", 10
        imageheaderlen: equ $-imageheader
        outputfilename: db "output.ppm", 0
        outputfilenamelen: equ $-outputfilename

        imagetest: db 255,0,0,0,255,0,255,255,0,0,0,255
        imagetestlen: equ $-imagetest

section .bss
        imageArray resb 64*64*3
        filehandle resq 1

section   .text
        global    _main

main:   
        print msg, msglen

        print newline, 1

        call _openfile
        mov [filehandle], rax

        write [filehandle], imageheader, imageheaderlen

        write [filehandle], imagetest, imagetestlen

        print newline, 1

        exit 0

_openfile:
        mov rax, SYS_OPEN ; system call for open
        mov rdi, outputfilename
        mov rsi, 577 ; flags
        mov rdx, 0644o ; mode. read and write
        syscall
        ret