    .extern getc
    .extern peekc
    .extern putstr

    .global main

    .text
main:
    jmp .Lprogress
.Lloop:
    movb %al, string(%rip)
    lea string(%rip), %rdi
    call putstr
.Lprogress:
    call getc
    and %rax, %rax
    jge .Lloop

    ret

    .data
string:
    .string " "
