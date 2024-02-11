%include "asm_io.inc"

segment .text
global asm_main

input_matrix:                              ; INPUT FUNCTION
    sub rsp, 8                                  ; stack alignment

    mov r12, 0                                  ; define counter for loop
    loop1:
        call read_float                             ; input the float value of each element
        mov dword [rbp + r12 * 4], eax
        
        add r12, 1
        cmp r12, qword [nSquared]                   ; condition for loop
        jl loop1

    add rsp, 8
    ret




input_pixels:                              ; INPUT FUNCTION
    sub rsp, 8                                  ; stack alignment
    mov r12, 0                                  ; define counter for loop
    loopInput:
        call read_float                             ; input the float value of each element
        mov dword [rbp + r12 * 4], eax
        
        add r12, 1
        cmp r12, qword [totalPixels]                 ; condition for loop
        jl loopInput

    add rsp, 8
    ret




normal_dot:                                ; MULTIPLY FUNCTION
    sub rsp, 8                                  ; stack alignment

    mov rbx, 0                                  ; define counter for loop
    loop2:
        pxor xmm0, xmm0

        movss xmm0, dword [matrix1 + rbx * 4]       ; store Aij in xmm0
        mulss xmm0, dword [matrix2 + rbx * 4]       ; store Aij * Bij in xmm0
        addss xmm0, dword [sum]                     ; add Aij * Bij to sum
        movss dword [sum], xmm0

        add rbx, 1
        cmp rbx, qword [nSquared]                   ; condition for loop
        jl loop2

    add rsp, 8
    ret



packed_dot:                                ; PACKED MULTIPLY FUNCTION
    sub rsp, 8                                  ; stack alignment

    mov rbx, 0                                  ; define counter for loop
    mov rsi, 0                                  ; define source index to point to the matrices

    loop3:
        pxor xmm0, xmm0                             ; clear the registers
        pxor xmm1, xmm1

        movaps xmm0, [matrix1 + rsi]                ; store 4 floats in each registers
        movaps xmm1, [matrix2 + rsi]

        dpps xmm0, xmm1, 0xF1                       ; dot the 2 vectors together

        addss xmm0, dword [sum]                     ; add dot product to sum
        movss dword [sum], xmm0

        add rsi, 16                                 ; update the source index

        add rbx, 1
        cmp rbx, qword [temp]                       ; condition for loop
        jl loop3

    add rsp, 8
    ret



correct_index:                             ; EDGE EXTENSION FUNCTION             
    sub rsp, 8

    mov rcx, qword [xSize]
    mov rdx, qword [ySize]

    dec rcx
    dec rdx

    mov rax, qword [iIndex]
    cmp rax, 0
    jge c1
    mov qword [iIndex], 0
    c1:
        cmp rax, rcx
        jle c2
        mov qword [iIndex], rcx
    c2:
        mov rax, qword [jIndex]
        cmp rax, 0
        jge c3
        mov qword [jIndex], 0
    c3:
        cmp rax, rdx
        jle c4
        mov qword [jIndex], rdx
    c4:
    add rsp, 8
    ret



convolution:                               ; CONVOLUTION FUNCTION
    sub rsp, 8

    mov rax, qword [n]
    xor rdx, rdx
    mov rbx, 2
    idiv rbx

    mov rbp, rax    ; store n/2 in rbp

    mov r12, 0      ; define counter, main counter for loop

    mainLoop:
        mov rax, r12
        xor rdx, rdx
        mov rbx, qword [xSize]
        idiv rbx

        mov qword [iMain], rax  ; by dividing by xSize, we get x coordinates as counter/xSize
        mov qword [jMain], rdx  ; by dividing by xSize, we get y coordinates as counter%xSize


        mov r15, 0  ; counter for putting in second matrix

        mov r13, 0  ; counter for x for big matrix

        loop01:
            mov rax, qword [iMain]
            add rax, r13
            sub rax, rbp
            mov qword [iIndex], rax     ; store x coordinates of big matrix

            
            mov r14, 0  ; counter for y for big matrix

            loop02:
                mov rax, qword [jMain]
                add rax, r14
                sub rax, rbp
                mov qword [jIndex], rax     ; store y coordinates of big matrix 

                call correct_index          ; correct index for edge extension


                mov rsi, qword [iIndex]
                imul rsi, qword [xSize]
                add rsi, qword [jIndex]     ; rax has correct position saved for big matrix

                mov ebx, dword [info + rsi * 4]         ; info saves big matrix

                mov dword [matrix2 + r15 * 4], ebx      ; store in matrix2 for calculating dot product


                inc r15

                inc r14
                cmp r14, qword [n]  ; check condition for loop
                jl loop02

            inc r13
            cmp r13, qword [n]  ; check condition for loop
            jl loop01

        mov eax, dword [ZERO]
        mov dword [sum], eax
        call normal_dot

        pxor xmm0, xmm0
        movss xmm0, dword [sum]

        cvtss2si edi, xmm0  ; convert to integer for pixel values

        cmp rdi, 256
        jl correct_value
        mov rdi, 0

    correct_value:
        call print_int
        call print_nl

        add r12, 1
        cmp r12, qword [totalPixels]
        jl mainLoop

    add rsp,8
    ret



asm_main:                                  ; MAIN FUNCTION
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8

    ; -------------------------

    call read_int               ; input size of matrix n, which is saved in rax

    mov qword [n], rax          ; n is used to save the number of rows and columns
    
    imul rax, rax
    mov qword [nSquared], rax   ; nSquared is used to save n^2

    mov rax, qword [nSquared]                   ; store n^2/4 as number of iterations to temp
    xor rdx, rdx                                ; each xmm register has 128 bits
    mov rbx, 4                                  ; which can store 4 floats
    idiv rbx
    add rax, 1
    mov qword [temp], rax                                

    xor rax, rax

    mov rbp, matrix1            ; rbp is pointer to the matrices
    call input_matrix           ; input the first matrix

    call read_int
    mov qword [xSize], rax      ; save xSize

    call read_int
    mov qword [ySize], rax      ; save ySize

    imul rax, qword [xSize]
    mov qword [totalPixels], rax

    mov rbp, info
    call input_pixels           ; input big matrix

    mov rdi, qword [xSize]
    call print_int
    call print_nl
    mov rdi, qword [ySize]
    call print_int
    call print_nl

    call convolution

    ;--------------------------

    add rsp, 8

	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


segment .data                              ; DATA SEGMENT

    matrix1: 
        times 30 dd 0.0
        align 16
    matrix2:    
        times 30 dd 0.0
        align 16

    info: times 1000000 dd 0.0

    temp: dq 0
    n: dq 0
    nSquared: dq 0


    xSize: dq 0
    ySize: dq 0
    totalPixels: dq 0

    sum: dd 0.0
    ZERO: dd 0.0

            section .bss
    iIndex resq 1
    jIndex resq 1

    iMain resq 1
    jMain resq 1
