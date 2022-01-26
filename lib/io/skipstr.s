    .global skipstr
    
    .extern getc
    .extern peekc
    .extern advc

    .text
# Skip next string in the input. Skip whitespace, and stop on whitespace.
skipstr:
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

    jmp .Ladv

    # Then, skip all non-whitespace
.Lcont:
    call peekc
    cmp $-1, %rax # Need to check -1, tab, newline and space
    je .Ldone
    cmp $' ', %rax
    je .Ldone
    cmp $'\t', %rax
    je .Ldone
    cmp $'\n', %rax
    je .Ldone
.Ladv:
    call advc
    jmp .Lcont

.Ldone:
    ret
