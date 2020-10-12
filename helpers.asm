section .bss
        numberDigits resq 64
        
; Macros
; Exit the program
%macro exit 1
        mov       rax, SYS_EXIT           ; system call for exit
        xor       rdi, %1                 ; exit code %1
        syscall                           ; invoke operating system to exit
%endmacro

; Print a message to stdout, using the register msg pointer rsi and length rdx
%macro print 2
        mov       rsi, %1                 ; address of string to output
        mov       rdx, %2                 ; number of bytes
        mov       rax, SYS_WRITE          ; system call for write
        mov       rdi, STDOUT             ; file handle 1 is stdout
        syscall                           ; invoke operating system to do the write
%endmacro

%macro printInt 1
; Prints the value of RAX as a base 10 number
    mov rax, %1
    mov r8, numberDigits
    mov r10, numberDigits ; Start of digit pointer
    %%isolateDigitsLoop:
        ; rax = rax / 10. rdx is the remainder
        mov rcx, 10
        xor rdx,rdx             ; clear rdx for correct remainder output
        div rcx 

        ; move the remainder rdx into the digit array
        add rdx, '0'            ; Add char '0' to get the integer in ASCII
        mov [r8], rdx
        inc r8                  ; Increment the digit pointer

        cmp rax, 0
        jne %%isolateDigitsLoop   ; Keep looping while there still are digits to process

    %%printDigits:
        ; Print the value of the r8 pointer
        mov rsi, r8             ; Give the address of the number pointer
        mov rdx, 1
        mov rax, SYS_WRITE      ; system call for write
        mov rdi, STDOUT         ; file handle stdout
        syscall

        dec r8          ; Decrement pointer pos

        cmp r8, r10
        jge %%printDigits
%endmacro

%macro write 3:
        mov       rax, SYS_WRITE
        mov       rdi, %1
        mov       rsi, %2
        mov       rdx, %3
        syscall
%endmacro

STDIN equ 0
STDOUT equ 1

SYS_READ equ 0
SYS_WRITE equ 1
SYS_OPEN equ 2
SYS_EXIT equ 60