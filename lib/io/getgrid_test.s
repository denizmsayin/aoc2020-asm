    .global main
    
    .extern getgrid
    .extern printi
    .extern putstr

    .text
main:
    lea gridbuf(%rip), %rdi
    call getgrid
    
    lea fmt(%rip), %rdi
    push %rdx
    push %rax
    call printi
    add $16, %rsp
    
    imul %rdx, %rax
    lea gridbuf(%rip), %rdi
    add %rax, %rdi
    movb $0, (%rdi)
    lea gridbuf(%rip), %rdi
    call putstr
    lea newline(%rip), %rdi
    call putstr

    ret    

fmt: .string "Rows: @, Cols: @\n"
newline: .string "\n"
    .data
gridbuf: .fill 1024
