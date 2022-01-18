    .global getstr
    
    .extern getc

    .text
# Read string into buffer. Skip whitespace, and stop on whitespace.
# %rdi: Pointer to target buffer
# %rsi: Size limit
# -> %rax: Size of read string. 0 would imply nothing is left.
getstr:
    xor %rax, %rax

    push %r12
    push %r13
    push %r14

    mov %rdi, %r12
    mov %rsi, %r13
    xor %r14, %r14

    # First, skip all whitespace.
.Lskip_loop:
    call getc
    cmp $-1, %rax # Need to check -1, tab, newline and space
    je .Ldone
    cmp $' ', %rax
    je .Lskip_loop
    cmp $'\t', %rax
    je .Lskip_loop
    cmp $'\n', %rax
    je .Lskip_loop
    
    jmp .Lput

    # Now, put things that are not whitespace in the buffer
.Lcont:
    call getc
    cmp $-1, %rax # Need to check -1, tab, newline and space
    je .Ldone
    cmp $' ', %rax
    je .Ldone
    cmp $'\t', %rax
    je .Ldone
    cmp $'\n', %rax
    je .Ldone
.Lput:
    movb %al, (%r12)
    inc %r12
    inc %r14
    cmp %r13, %r14
    jne .Lcont

.Ldone:
    movb $0, (%r12) # add a finishing null
    mov %r14, %rax

    pop %r14
    pop %r13
    pop %r12
    ret
