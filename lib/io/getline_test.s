    .global main
    
    .extern getline
    .extern putstr

    .text
main:
    jmp .Lcheck

.Lloop:
    push %rax
    lea buf(%rip), %rdi
    call putstr
    lea newline(%rip), %rdi
    call putstr
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp
.Lcheck:
    lea buf(%rip), %rdi
    mov $512, %rsi
    call getline
    jnc .Lloop
    ret

newline: .string "\n"
fmt: .string "Length: @\n"
    .data
buf: .fill 512
