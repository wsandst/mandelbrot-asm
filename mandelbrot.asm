; ----------------------------------------------------------------------------------------
; Generate a colored Mandelbrot image as a .ppm image.
; Various settings can be adjusted below, such as viewport and coloring
; Does smooth coloring, but every color cycle has a sharp cut-off
; author - wsandst
; ----------------------------------------------------------------------------------------

; Include helper file
%include "helpers.asm"

; Settings
WIDTH equ 1000
HEIGHT equ 1000

MAX_ITERATIONS equ 30
COLOR_ITERATION_LOOP equ 30

section   .data
        ; More settings
        ; File settings. Resolution has to be set in the imageheader str as well (!!!)
        ; This part                *******
        imageheader: db "P6", 10, "1000 1000", 10, "255", 10
        imageheaderlen: equ $-imageheader
        outputfilename: db "output.ppm", 0
        outputfilenamelen: equ $-outputfilename

        ; Viewport settings
        view_x: dq -2.25
        view_width: dq 3.0
        view_y: dq -1.5
        view_height: dq 3.0

        ; Color settings
        ; Color 1
        color1_red: dq 39.0
        color1_green: dq 160.0
        color1_blue: dq 245.0

        ; Color 2
        color2_red: dq 0.0
        color2_green: dq 0.0
        color2_blue: dq 10.0

        ; Other constants
        msg:  db        "Mandelbrot generation complete.", 10
        msglen: equ $-msg
        newline: db 10

        image_array_ptr: dq 0
        ; Intermediaries
        pixel_red: db 0
        pixel_green: db 0
        pixel_blue: db 0

        image_widthf: dq 0
        image_heightf: dq 0
        color_iteration_loopf: dq 0.0

        y: dq 0
        x: dq 0
        u: dq 0
        v: dq 0
        u2: dq 0.0
        v2: dq 0.0
        i: dq 0
        log_res: dq 0

        ; Constant floats
        c16: dq 16.0
        c2: dq 2.0
        c0: dq 0.0
        c1: dq 1.0

section .bss
        image_array resb WIDTH*HEIGHT*3
        filehandle resq 1

section   .text
        global    _start

; Main program
_start:   
        ; generate a mandelbrot image
        call _generate_image

        ; write a ppm image to file, with the image_array values
        openfile outputfilename, filehandle
        mov [filehandle], rax

        write [filehandle], imageheader, imageheaderlen
        write [filehandle], image_array, WIDTH*HEIGHT*3

        print "Mandelbrot generation complete.", msglen
        print msg, msglen

        exit 0

_generate_image:
        ; Set up image_widthf, image_heightf and color_iteration_loopf
        mov rax, WIDTH
        cvtsi2sd xmm0, eax
        movsd [image_widthf], xmm0
        mov rax, HEIGHT
        cvtsi2sd xmm0, eax
        movsd [image_heightf], xmm0
        mov rax, COLOR_ITERATION_LOOP
        cvtsi2sd xmm0, eax
        movsd [color_iteration_loopf], xmm0

        mov r12, 0 ; r12 = x
        mov r13, -1 ; r13 = y
        xor rax, rax
        mov rax, image_array ; Image array pointer
        mov [image_array_ptr], rax
        loopY:
                mov r12, 0
                inc r13 ; y++
                cmp r13, HEIGHT
                jge loopEnd ; stop if y >= HEIGHT
                jmp loopX
        loopX:
                ; Iterate mandelbrot for this point
                call _calculate_pos
                call _iterate_mandelbrot

                ; Set pixel color in array
                mov rax, [image_array_ptr]
                mov bl, [pixel_red]
                mov byte [rax], bl
                inc rax ; array ptr ++
                mov bl, [pixel_green]
                mov byte [rax], bl
                inc rax ; array ptr ++
                mov bl, [pixel_blue]
                mov byte [rax], bl
                inc rax ; array ptr ++
                mov [image_array_ptr], rax

                inc r12 ; x++
                cmp r12, WIDTH ; stop if x >= WIDTH
                jge loopY
                jmp loopX
        loopEnd:
        ret

_calculate_pos: ; Convert x = r12, y = 13, into the proper mandelbrot range point
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
                
; Set the pixel values. input (red, green, blue)
%macro setcolor 3
        mov bl, %1
        mov [pixel_red], bl
        mov bl, %2
        mov [pixel_green], bl
        mov bl, %3
        mov [pixel_blue], bl
%endmacro

; Convert a smoothed float i into a color
%macro color_interpolate 1
        ; color = i / max_i * color1 +  1 - (i / maxi) * color2
        movsd xmm0, %1
        divsd xmm0, [color_iteration_loopf] ; i = i / maxi
        movsd xmm2, xmm0
        movsd xmm1, [c1]
        subsd xmm1, xmm2 ; 1 - i

        ; red
        movsd xmm2, xmm0 ; xmm2 = i
        movsd xmm3, xmm1 ; xmm3 = 1 - i
        mulsd xmm2, [color1_red] ; i * color
        mulsd xmm3, [color2_red] ; (i - 1) * color
        addsd xmm2, xmm3 ; add the interpolated colors
        cvttsd2si rax, xmm2 ; convert to integer
        mov byte [pixel_red], al ; move into the pixel color byte

        ; green
        movsd xmm2, xmm0 ; xmm2 = i
        movsd xmm3, xmm1 ; xmm3 = 1 - i
        mulsd xmm2, [color1_green] ; i * color
        mulsd xmm3, [color2_green] ; (i - 1) * color
        addsd xmm2, xmm3 ; add the interpolated colors
        cvttsd2si rax, xmm2 ; convert to integer
        mov byte [pixel_green], al ; move into the pixel color byte

        ; blue
        movsd xmm2, xmm0 ; xmm2 = i
        movsd xmm3, xmm1 ; xmm3 = 1 - i
        mulsd xmm2, [color1_blue] ; i * color
        mulsd xmm3, [color2_blue] ; (i - 1) * color
        addsd xmm2, xmm3 ; add the interpolated colors
        cvttsd2si rax, xmm2 ; convert to integer
        mov byte [pixel_blue], al ; move into the pixel color byte
%endmacro

; Iterate mandelbrot for the point [x], [y]
_iterate_mandelbrot:
        ; Setup the variables needed
        mov r11, 0
        pxor xmm0, xmm0
        movsd [v], xmm0
        movsd [u], xmm0
        movsd [u2], xmm0
        movsd [v2], xmm0
        ; Iteration loop
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
                mulsd xmm0, xmm0 ; u^2 = u * u
                movsd [u2], xmm0

                ; v^2
                movsd xmm0, [v]
                mulsd xmm0, xmm0 ; v^2 = v * v
                movsd [v2], xmm0

                ; 16 cutoff allows for smoother coloring
                ; is u2 + v2 > 16? Then stop
                pxor xmm0, xmm0 ; xmm0 = 0
                addsd xmm0, [u2] ; + u2
                addsd xmm0, [v2] ; + v2
                movsd xmm1, [c16]   
                comisd xmm0, xmm1 ; Stop if cutoff reached. Outside set
                jae isoutside

                cmp r11, MAX_ITERATIONS ; Stop if iteration count >= MAX_ITERATIONS. Inside set
                jge isinside

                jmp iterateloop ; Keep looping
        isinside:
                setcolor 0, 0, 0 ; black
                ret
        isoutside:
                ; i = i % color_iteration_loop
                mov rax, r11
                mov rcx, COLOR_ITERATION_LOOP
                xor rdx,rdx ; clear rdx for correct remainder output
                div rcx 

                ; calculate smooth i
                ; smooth_i = i + 1 - log2(ln(sqrt(u2 + v2)))
                mov rax, rdx ; rax = i
                inc rax ; i++
                inc rax;
                mov [i], rax

                ; calculate log2(ln(sqrt(u2 + v2)))
                movsd xmm0, [u2] ; u2
                addsd xmm0, [v2] ; + v2
                sqrtsd xmm0, xmm0 ; sqrt
                movsd [log_res], xmm0

                ; calculate ln using x87
                fldln2 ; st: log2(e)
                fld qword [log_res]
                fyl2x ; st: ln(num)
                fstp qword [log_res] ; store to out and pop

                ; calculate log2 using x87
                fld1
                fld qword [log_res]
                fyl2x 
                fstp qword [log_res]

                mov rax, [i]
                cvtsi2sd xmm0, eax ; convert i to float
                movsd xmm1, [log_res]
                subsd xmm0, xmm1
                movsd [i], xmm0

                color_interpolate [i] ; interpolate with i % color_iteration_loop

                ; setcolor 255, 0, 255
                ret