    .global main

    .extern ssplit_whitespace
    .extern printi
    .extern putstr

isspace:
    cmp $' ', %rdi
    jne .Ldone
    mov $1, %rax
    ret
.Ldone:
    xor %rax, %rax
    ret

main:
    lea string(%rip), %rdi
    lea splitarr(%rip), %rsi
    call ssplit_whitespace

    push %rax
    mov %rax, %r12
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    lea splitarr(%rip), %r13
    jmp .Lck

.Lloop:
    movq (%r13), %rdi
    call putstr
    dec %r12
    add $8, %r13
    lea newline(%rip), %rdi
    call putstr
.Lck:
    and %r12, %r12
    jne .Lloop

    ret

    
fmt: .string "Split into: @\n"
newline: .string "\n"
    
    .data
string: .string "hello world   sup  a            b"
splitarr: .fill 4096
