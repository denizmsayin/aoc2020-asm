    .global main

    .extern getia
    .extern printi
    .extern part2set

.set PREAMBLE_LEN, 25

fmt: .string "@\n"

main:
    xor %r12, %r12
    call part2set
    setc %r12b

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
    
    # Test if part1. If so, print and leave.
    # Otherwise, move on to part2.
    test %r12, %r12
    je .Lprintresult
    jmp .Lpart2

    inc %r14
.Lck:
    cmp %r13, %r14
    jl .Lloop
    
.Lpart2:
    # Alright... Now, %rax has the target value.
    # Need to find a subsequence which sums to this
    # thing. Since all values are positive; I 
    # can grow/shrink based on the current sum.
    
    lea array(%rip), %rdi # i pointer
    mov %rdi, %rsi # j pointer
    xor %rdx, %rdx # sum of subsequence

.Lgrow:
    addq (%rsi), %rdx
    add $8, %rsi
    jmp .Ldecision
.Lshrink:
    subq (%rdi), %rdx
    add $8, %rdi
.Ldecision:
    cmp %rax, %rdx # compare value with current sum
    jl .Lgrow
    jg .Lshrink

    # Otherwise, equal. Subsequence found!
    # Now just gotta find the min and max.
    mov (%rdi), %r8 # min
    mov %r8, %r9 # max
    jmp .Lminmaxcheck

.Lminmaxloop:
    mov (%rdi), %r10
    cmp %r8, %r10 # update if value < min
    cmovl %r10, %r8
    cmp %r9, %r10 # update if value > max
    cmovg %r10, %r9
.Lminmaxcheck:
    add $8, %rdi
    cmp %rdi, %rsi
    jne .Lminmaxloop    

    lea (%r8, %r9), %rax
.Lprintresult:
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    ret

dbgfmt: .string "min:@ max:@ sum:@\n"

    .data
array: .fill 8192 
