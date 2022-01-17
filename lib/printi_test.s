    .extern printi
    .global main
    
    .text
main:
    lea str0(%rip), %rdi
    call printi

    lea str1(%rip), %rdi
    push $3000
    call printi
    add $8, %rsp

    lea str2(%rip), %rdi
    push $-1587
    call printi
    add $8, %rsp

    lea str3(%rip), %rdi
    push $1234567891
    push $300
    push $20
    call printi
    add $0x18, %rsp

    ret

str0:
    .asciz "Hello!\n"
str1:
    .asciz "x=@\n"
str2:
    .asciz "Negative: @\n"
str3:
    .asciz "Three values @ @ @\n"
