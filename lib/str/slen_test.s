    .extern slen
    .extern printf
    .global main
    
    .text
test_str:
    # %rdi has string
    call slen
    mov %rdi, %rsi
    mov %rax, %rdx
    lea fmt(%rip), %rdi
    call printf
    ret

main:
    lea str0(%rip), %rdi
    call test_str
    lea str1(%rip), %rdi
    call test_str
    lea str2(%rip), %rdi
    call test_str
    lea str3(%rip), %rdi
    call test_str
    ret

fmt:
    .asciz "len '%s': %lu\n"

str0:
    .asciz ""
str1:
    .asciz "a"
str2:
    .asciz "hello"
str3:
    .asciz "another one"
