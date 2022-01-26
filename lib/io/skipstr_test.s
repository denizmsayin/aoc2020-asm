    .global main
    
    .extern skipstr
    .extern putstr
    .extern getline

    .text
main:
    call skipstr
    
    lea buf(%rip), %rdi
    mov $512, %rsi
    call getline

    lea buf(%rip), %rdi
    call putstr
    lea newline(%rip), %rdi
    call putstr

    ret

newline: .string "\n"
    .data
buf: .fill 512
