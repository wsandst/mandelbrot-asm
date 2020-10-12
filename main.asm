; ----------------------------------------------------------------------------------------
; Calculate a fibonaci number iteratively
;
; ----------------------------------------------------------------------------------------


section   .data
        msg:  db        "Generating mandelbrot"      ; note the newline at the end
        msglen:  equ $-msg
        newline: db 10

section .bss
        numberDigits resq 64

section   .text
        global    _main

        ; Print "Fibonnaci:"
main:   
        mov       rsi, msg                ; address of string to output
        mov       rdx, msglen             ; number of bytes
        call _print

        ; Print newline
        mov       rsi, newline            ; address of string to output
        mov       rdx, 1                  ; number of bytes
        call _print

        ; Exit
        mov       rax, 60                 ; system call for exit
        xor       rdi, rdi                ; exit code 0
        syscall                           ; invoke operating system to exit

_print: ; Print a message to stdout, using the register msg pointer rsi and length rdx
        mov       rax, 1                  ; system call for write
        mov       rdi, 1                  ; file handle 1 is stdout
        syscall                           ; invoke operating system to do the write
        ret

_printInt: ; Prints the value of RAX as a base 10 number
    mov r8, numberDigits
    mov r10, numberDigits ; Start of digit pointer
    isolateDigitsLoop:
        ; rax = rax / 10. rdx is the remainder
        mov rcx, 10
        xor rdx,rdx             ; clear rdx for correct remainder output
        div rcx 

        ; move the remainder rdx into the digit array
        add rdx, '0'            ; Add char '0' to get the integer in ASCII
        mov [r8], rdx
        inc r8                  ; Increment the digit pointer

        cmp rax, 0
        jne isolateDigitsLoop   ; Keep looping while there still are digits to process

    printDigits:
        ; Print the value of the r8 pointer
        mov rsi, r8     ; Give the address of the number pointer
        mov rdx, 1
        mov rax, 1      ; system call for write
        mov rdi, 1      ; file handle 1 is stdout
        syscall

        dec r8          ; Decrement pointer pos

        cmp r8, r10
        jge printDigits
    ret