    .global main
    
    .extern geti
    .extern printi

    .text
main:
    jmp .Lcheck

.Lloop:
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp
.Lcheck:
    call geti
    jnc .Lloop
    ret

fmt:
    .string "Got: @\n"
