    .global main

    .text
main:
    mov $1, %rax
    mov $1, %rdi
    lea string(%rip), %rsi
    mov $13, %rdx
    syscall
    ret

string:
    .asciz "Hello world!\n"
