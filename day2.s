    .global main

    .extern geti
    .extern getc
    .extern getstr
    .extern printi

main:
    
    xor %r12, %r12 # counter for correct passwords

.Llineloop:
    call geti # lower limit
    jc .Lnolines # no more lines left if carry flag is set
    mov %rax, %r13
    call getc # skip the dreaded minus
    call geti # upper limit
    mov %rax, %r14
    call skipwhite # skip whitespace
    call getc # target char
    mov %rax, %r15
    call getc # :
    lea buffer(%rip), %rdi
    mov $512, %rsi
    call getstr # the password

    # Loop through the password, counting target chars
    lea buffer(%rip), %rax
    xor %rsi, %rsi
    jmp .Lcheck
.Lloop:
    cmp %r15b, %dl
    jne .Lneq
    inc %rsi
.Lneq:
    inc %rax
.Lcheck:
    movb (%rax), %dl
    and %dl, %dl
    jne .Lloop

    # Right amount of target chars?
    cmp %r13, %rsi
    jl .Lnope
    cmp %r14, %rsi
    jg .Lnope
    inc %r12

.Lnope:
    jmp .Llineloop

.Lnolines:
    push %r12
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    ret

fmt: .string "@\n"

    .data
buffer: .fill 512
