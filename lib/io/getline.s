    .global getline
    
    .extern getc

    .text
# Read string into buffer. Skip whitespace, and stop on whitespace.
# %rdi: Pointer to target buffer
# %rsi: Size limit
# -> %rax: Size of read string. 0 would imply nothing is left.
# Carry register set if ended on EOF, else cleared.
getline:
    xor %rax, %rax

    push %r12
    push %r13
    push %r14

    mov %rdi, %r12
    mov %rsi, %r13
    xor %r14, %r14
    
    # Now, put things that are not whitespace in the buffer
.Lcont:
    call getc
    cmp $-1, %rax # Need to check -1, and newline
    je .Leof
    cmp $'\n', %rax
    je .Leol
.Lput:
    movb %al, (%r12)
    inc %r12
    inc %r14
    cmp %r13, %r14
    jne .Lcont

.Leof:
    stc
    jmp .Lend
.Leol:
    clc
.Lend:
    movb $0, (%r12) # add a finishing null
    mov %r14, %rax

    pop %r14
    pop %r13
    pop %r12
    ret
