; ----------------------------------------------------------------------------------------
; Calculate a fibonaci number iteratively
;
; ----------------------------------------------------------------------------------------

; Include helper file
%include "helpers.asm"

; Settings
WIDTH equ 300
HEIGHT equ 300

MAX_ITERATIONS equ 30

; Main program
section   .data
        msg:  db        "Generated mandelbrot", 10
        msglen: equ $-msg
        newline: db 10
        imageheader: db "P6", 10, "300 300", 10, "255", 10
        imageheaderlen: equ $-imageheader
        outputfilename: db "output.ppm", 0
        outputfilenamelen: equ $-outputfilename

        image_array: TIMES WIDTH*HEIGHT*3 db 0
        image_array_ptr: dq 0
        image_value: db 0
        placeholder: db 255

        image_widthf: dq 300.0
        image_heightf: dq 300.0
        view_x: dq -2.25
        view_width: dq 3.0
        view_y: dq -1.5
        view_height: dq 3.0

        y: dq 0
        x: dq 0
        u: dq 0
        v: dq 0
        u2: dq 0.0
        v2: dq 0.0
        c16: dq 16.0
        c2: dq 2.0
        c0: dq 0.0

section .bss
        imageArray resb 64*64*3
        filehandle resq 1


section   .text
        global    _main

main:   
        ; generate a mandelbrot image
        call _generate_image

        ; write a ppm image to file, with the image_array values
        openfile outputfilename, filehandle
        mov [filehandle], rax

        write [filehandle], imageheader, imageheaderlen
        write [filehandle], image_array, WIDTH*HEIGHT*3

        print msg, msglen

        exit 0

_generate_image:
        mov r12, 0 ; r12 = x
        mov r13, -1 ; r13 = y
        xor rax, rax
        mov rax, image_array ; Image array pointer
        mov [image_array_ptr], rax
        loopY:
                mov r12, 0
                inc r13 ; y++
                cmp r13, WIDTH
                jge loopEnd
                jmp loopX
        loopX:
                call _calculate_pos
                call _iterate_mandelbrot

                ; Add color
                mov rax, [image_array_ptr]
                mov bl, [image_value]
                mov byte [rax], bl
                inc rax;
                mov byte [rax], bl
                inc rax;
                mov byte [rax], bl
                inc rax;
                mov [image_array_ptr], rax

                inc r12 ; x++
                cmp r12, HEIGHT
                jge loopY
                jmp loopX
        loopEnd:
        ret

_calculate_pos: ; Convert x = r12, y = 13, into the proper mandelbrot range

        ; x = float(x) / image_widthf * view_height + view_x
        cvtsi2sd xmm0, r12d ; convert x to float
        movsd [x], xmm0
        divsd xmm0, [image_widthf] ; / image_widthf
        mulsd xmm0, [view_width]  ; * view_width
        addsd xmm0, [view_x] ; + view_x
        movsd [x], xmm0

        ; y = float(y) / image_heightf * view_height + view_y
        pxor xmm0, xmm0
        cvtsi2sd xmm0, r13d ; convert y to float
        divsd xmm0, [image_heightf] ; / image_heightf
        mulsd xmm0, [view_height]  ; * view_height
        addsd xmm0, [view_y] ; + view_y
        movsd [y], xmm0

        ret
                

_iterate_mandelbrot:
        ; need floating point
        ; u, v, u2, v2, x, y
        mov r11, 0
        pxor xmm0, xmm0
        movsd [v], xmm0
        movsd [u], xmm0
        movsd [u2], xmm0
        movsd [v2], xmm0
        iterateloop:

                inc r11 ; i++

                ; v = 2 * u * v + y;
                pxor xmm0, xmm0 ; xmm0 = 0
                movsd xmm0, [v] ; v
                mulsd xmm0, [c2] ; * 2
                mulsd xmm0, [u] ; * u
                addsd xmm0, [y] ; + y
                movsd [v], xmm0

                ; u = u^2 - v^2 + x;
                pxor xmm0, xmm0 ; xmm0 = 0
                movsd xmm0, [u2] ; u2
                subsd xmm0, [v2] ; - v2
                addsd xmm0, [x] ; + x
                movsd [u], xmm0
                ; u^2
                movsd xmm0, [u]
                mulsd xmm0, xmm0 ; u^2 = u * u
                movsd [u2], xmm0

                ; v^2
                movsd xmm0, [v]
                mulsd xmm0, xmm0 ; v^2 = v * v
                movsd [v2], xmm0

                ; is u2 + v2 > 16? Then stop
                pxor xmm0, xmm0 ; xmm0 = 0
                addsd xmm0, [u2] ; + u2
                addsd xmm0, [v2] ; + v2
                movsd xmm1, [c16]   
                comisd xmm0, xmm1   
                jae isoutside

                cmp r11, MAX_ITERATIONS ; is the iteration count above MAX_ITERATIONS? Then stop
                jge isinside

                jmp iterateloop
        isinside:
                mov rax, 0
                mov [image_value], rax
                ret
        isoutside:
                mov rax, 255
                mov [image_value], rax
                ret