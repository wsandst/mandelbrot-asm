; Settings file
; In order to change resolution you also have to change in imageheader
WIDTH equ 1000
HEIGHT equ 1000

MAX_ITERATIONS equ 30
COLOR_ITERATION_LOOP equ 30

section   .data
    ; Change here for resolution   *********
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