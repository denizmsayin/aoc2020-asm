    .extern putstr
    .global main
    
    .text
main:
    lea str0(%rip), %rdi
    call putstr
    lea str1(%rip), %rdi
    call putstr
    lea str2(%rip), %rdi
    call putstr
    lea str3(%rip), %rdi
    call putstr
    ret

str0:
    .asciz "\n"
str1:
    .asciz "Hello\n"
str2:
    .asciz "A longer string\n"
str3:
    .asciz "ABCDEFGHIJKLMNOPQRSTUVWXYZ\n"
