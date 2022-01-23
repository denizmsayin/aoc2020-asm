    .global main

    .extern stoi
    .extern printi

main:
    lea s1(%rip), %rdi
    call stoi
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp
    
    lea s2(%rip), %rdi
    call stoi
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp
    
    lea s3(%rip), %rdi
    call stoi
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp
    
    lea s4(%rip), %rdi
    call stoi
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp
    
    lea s5(%rip), %rdi
    call stoi
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    ret

s1: .string "1234"
s2: .string "-987"
s3: .string "0"
s4: .string "6"
s5: .string "6748888asdf888"
fmt: .string "Value: @\n"

