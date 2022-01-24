    .global main

    .extern blkset
    .extern printi

main:

    lea blk(%rip), %rdi
    mov $0xFF, %rsi
    mov $32, %rdx
    call blkset

    lea blk(%rip), %r12
    lea blk+32(%rip), %r13
    jmp .Lck

.Lloop:
    movq (%r12), %rax
    
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp
    
    add $8, %r12
.Lck:
    cmp %r12, %r13
    jne .Lloop

    ret

fmt: .string "Value: @\n"
    .data
blk: .fill 32
