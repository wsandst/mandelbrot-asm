# Simple Mandelbrot written in x86_64 NASM Assembly
This project saves a smoothly colored Mandelbrot to a .ppm image file. It is written completely in x86_64 Assembly. Various settings can be adjusted in the file `settings.asm`, such as image resolution, viewport and coloring.
The program supports zooming up to double precision through adjusting the settings file.  

## Images
![Mandelbrot example 1](https://i.ibb.co/jV77QHV/example1.png)
![Mandelbrot example 2](https://i.ibb.co/F638MHk/example2.png)
![Mandelbrot example 3](https://i.ibb.co/Qn0bfP2/example3.png)

## Build instructions
In order to build this program, you need Linux with an x86_64 CPU.  
Compile the assembly using NASM and link with LD.  
`nasm -f elf64 mandelbrot.asm && ld -o mandelbrot.out mandelbrot.o`
