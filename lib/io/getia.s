    .global getia

    .extern geti

    .text
# Get an array of ints (8-byte), somehow!
# %rdi: Target array
# %rsi: Size limit
# -> %rax: Number of values read
getia:
    push %r12
    push %r13
    push %r14

    mov %rdi, %r12
    mov %rsi, %r13
    xor %r14, %r14

.Lcont:
    call geti
    jc .Ldone
    mov %rax, (%r12)
    add $8, %r12
    inc %r14
    cmp %r13, %r14
    jne .Lcont

.Ldone:
    mov %r14, %rax
    pop %r14
    pop %r13
    pop %r12

    ret
