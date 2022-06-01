    .global main

    .extern printi
    .extern putstr

    .extern quicksort_long    

    .text
main:
    lea array(%rip), %rdi
    mov %rdi, %r12
    mov $1024, %rsi
    call getia
    mov %rax, %r13

    mov %r12, %rdi
    mov %rax, %rsi
    call quicksort_long

    lea (%r12, %r13, 8), %r13
    jmp .Lck

.Lloop:
    mov (%r12), %rax
    
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    add $8, %r12
.Lck:
    cmp %r12, %r13
    jne .Lloop

    lea newline(%rip), %rdi
    call putstr

    ret

fmt: .string "@ "
newline: .string "\n"

    .data
array: .fill 8192
