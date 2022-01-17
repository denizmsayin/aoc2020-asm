    .extern putstr

    .global main
    .text

main:
    lea string(%rip), %rdi
    call putstr
    xor %rax, %rax
    ret

string:
    .string "Hello world!\n"
