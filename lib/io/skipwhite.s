    .global skipwhite

    .extern getc

    .text
# Skip whitespace from stdin.
skipwhite:
    jmp .Lskip_check

.Lskip_loop: 
    call advc
.Lskip_check:
    call peekc
    cmp $-1, %rax # Need to check -1, tab, newline and space
    je .Ldone
    cmp $' ', %rax
    je .Lskip_loop
    cmp $'\t', %rax
    je .Lskip_loop
    cmp $'\n', %rax
    je .Lskip_loop

.Ldone:
    ret 
