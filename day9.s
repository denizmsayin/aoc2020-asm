    .global main

    .extern getia
    .extern printi

.set PREAMBLE_LEN, 25

fmt: .string "@\n"

main:
    lea array(%rip), %rdi
    mov $1024, %rsi
    call getia
    mov %rax, %r13 # array size
    mov $PREAMBLE_LEN, %r14 # current index

    jmp .Lck

.Lgood:
    # Found a match, move on to the next value
    inc %r14
.Lloop:
    # Check if sum of previous
    lea array(%rip), %rdi
    lea (%rdi, %r14, 8), %rdi
    mov (%rdi), %rax # array[k]
    mov %r14, %r8
    sub $PREAMBLE_LEN, %r8 # i = k - 25
    jmp .Lcki

.Lloopi:
    lea 1(%r8), %r9 # j = i + 1
    lea array(%rip), %rdi
    lea (%rdi, %r8, 8), %rdi
    mov (%rdi), %r10 # array[i]
    jmp .Lckj

.Lloopj:
    lea array(%rip), %rdi
    lea (%rdi, %r9, 8), %rdi
    mov (%rdi), %r11 # array[j]
    add %r10, %r11 # array[i] + array[j]
    cmp %r11, %rax # array[i] + array[j] == array[k] ?
    je .Lgood
    inc %r9
.Lckj:
    cmp %r14, %r9
    jl .Lloopj

    inc %r8
.Lcki:
    cmp %r14, %r8
    jl .Lloopi    

    # Fell down, could not find a match
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp
    jmp .Lepi

    inc %r14
.Lck:
    cmp %r13, %r14
    jl .Lloop
    
.Lepi:    

    ret

    .data
array: .fill 8192 
