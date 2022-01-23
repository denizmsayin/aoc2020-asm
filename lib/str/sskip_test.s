    .global main

    .extern sskip
    .extern printi

islower:
    cmp $'a', %rdi
    jl .Ldone
    cmp $'z', %rdi
    jg .Ldone
    mov $1, %rax
    ret
.Ldone:
    xor %rax, %rax
    ret

isspace:
    cmp $' ', %rdi
    je .Leq
    xor %rax, %rax
    ret
.Leq:
    mov $1, %rax
    ret

isany:
    mov $1, %rax
    ret

main:
    lea string(%rip), %rdi
    lea islower(%rip), %rsi
    call sskip
    
    lea string(%rip), %rdi
    mov %rax, %r12
    sub %rdi, %rax
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp
    
    mov %r12, %rdi
    lea isspace(%rip), %rsi
    call sskip
    
    lea string(%rip), %rdi
    mov %rax, %r12
    sub %rdi, %rax
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp
    
    mov %r12, %rdi
    lea isany(%rip), %rsi
    call sskip
    
    lea string(%rip), %rdi
    sub %rdi, %rax
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    ret

    
string: .string "hello world   sup\n"
fmt: .string "At index: @\n"
