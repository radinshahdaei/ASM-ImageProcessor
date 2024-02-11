%include "asm_io.inc"

segment .text
global asm_main


print_matrix:                       ; PRINT THE PRODUCT
    sub rsp, 8

    mov r12, 0
    loop0:
        mov rax, r12            ; calculate counter/n
        xor rdx, rdx            ; store counter/n in rax (index of row of product)
        mov rbx, qword [n]      ; store counter%n in rdx (index of column of product)
        idiv rbx

        mov r13, rdx

        mov edi, dword [product + r12 * 4]      ; print the correct index
        call print_float
        mov rdi, ' '
        call print_char

        add r13, 1                              ; print new line for readability
        cmp r13, qword [n]
        jne after0
        call print_nl

        after0:
        add r12, 1
        cmp r12, qword [nSquared]
        jl loop0

    add rsp, 8
    ret

input_first:                        ; INPUT FIRST MATRIX AS "A"
    sub rsp, 8


    mov r12, 0
    loop1:
        call read_float
        xor rbp, rbp
        mov ebp, eax

        
        mov rax, r12            ; calculate counter/n
        xor rdx, rdx            ; store counter/n in rax (index of row)
        mov rbx, qword [n]      ; store counter%n in rdx (index of column)
        idiv rbx

        imul rax, 8
        add rax, rdx

        mov dword [matrix1 + rax * 4], ebp

        add r12, 1
        cmp r12, qword [nSquared]
        jl loop1


    add rsp, 8
    ret

input_second:                       ; INPUT SECOND MATRIX AS "B-TRANSPOSED"
    sub rsp, 8                      ; saving the transpose makes calculations easier and code cleaner

    mov r12, 0
    loop2:
        call read_float
        xor rbp, rbp
        mov ebp, eax
        
        mov rax, r12            ; calculate counter/n
        xor rdx, rdx            ; store counter/n in rax (index of column)
        mov rbx, qword [n]      ; store counter%n in rdx (index of row)
        idiv rbx    

        imul rdx, 8
        add rdx, rax

        mov dword [matrix2 + rdx * 4], ebp

        add r12, 1
        cmp r12, qword [nSquared]
        jl loop2

    add rsp, 8
    ret

multiply_normal:                    ; MULTIPlY FUNCTION
    sub rsp, 8

    mov r12, 0
    loop3:
        xor rax, rax
        mov eax, dword [ZERO]
        mov dword [sum], eax
        
        mov rax, r12            ; calculate counter/n
        xor rdx, rdx            ; store counter/n in rax (index of row of product)
        mov rbx, qword [n]      ; store counter%n in rdx (index of column of product)
        idiv rbx

        imul rax, 8
        imul rdx, 8

        pxor xmm0, xmm0
        
        mov r13, 0               ; counter for iterating over columns and rows of input matrices
        loop4:                 
            movss xmm0, dword [matrix1 + rax * 4]
            mulss xmm0, dword [matrix2 + rdx * 4]
            addss xmm0, dword [sum]                     
            movss dword [sum], xmm0

            add rax, 1
            add rdx, 1

            add r13, 1
            cmp r13, qword [n]
            jl loop4

        xor rax, rax
        mov eax, dword [sum]
        mov dword [product + r12 * 4], eax      ; save sum in the correct location
        
        add r12, 1
        cmp r12, qword [nSquared]
        jl loop3

    add rsp, 8
    ret


asm_main:                           ; MAIN FUNCTION
	push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 8
    
    call read_int
    mov qword [n], rax
    imul rax, rax
    mov qword [nSquared], rax

    call input_first
    call input_second

    ; -------------------------  normal multiplication

    rdtsc
    mov dword [t1], eax     ; save lower bits in t1

    call multiply_normal    ; call main multiply function

    rdtsc  
    xor rdi, rdi          
    sub eax, dword [t1]     ; save difference of lower bits in eax  
    mov edi, eax 

    call print_int

    ; call print_matrix

    add rsp, 8

	pop r15
	pop r14
	pop r13
	pop r12
    pop rbx
    pop rbp

	ret


segment .data                       ; DATA SEGMENT
        matrix1: 
            times 64 dd 0.0
            align 16
        matrix2:    
            times 64 dd 0.0
            align 16

        product:
            times 64 dd 0.0
            align 16

        n: dq 0
        nSquared: dq 0
        temp: dq 0

        sum: dd 0.0
        ZERO: dd 0.0

        t1 : dd 0

        time_print: db "time: ", 0