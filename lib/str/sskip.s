    .global sskip

# %rdi: address of the buffer
# %rsi: function int (*skip)(int) that determines whether to skip next char (1 if skip, 0 else)
# -> %rax: address after skipping all conforming chars, can also point to the null char
sskip:
    
    push %r12
    push %r13
    
    mov %rdi, %r12
    mov %rsi, %r13
    jmp .Lck

.Lloop:
    inc %r12
.Lck:
    xorq %rdi, %rdi
    movb (%r12), %dil
    andb %dil, %dil # check if and of string
    je .Ldone # end of string
    callq *%r13 # check if should skip
    andq %rax, %rax
    jne .Lloop
 
.Ldone:
    mov %r12, %rax

    pop %r13
    pop %r12

    ret
