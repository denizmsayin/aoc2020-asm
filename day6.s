    .global main

    .extern getline
    .extern printi
    .extern part2set

main:
    mov $1, %rbx # Holds 1, for cmov
    xor %r12, %r12 # number of people in each group
    xor %r13, %r13 # set if part2
    xor %r14, %r14 # last line marker
    xor %r15, %r15 # total counter    
    call part2set
    setc %r13b

.Lnextline:
    lea linebuf(%rip), %rdi
    mov $128, %rsi
    call getline
    setc %r14b

    test %rax, %rax # empty line?
    jne .Lgroupcont

    # Group done! Time to count set values in the array.
    lea letter_used(%rip), %rdi # letter used address
    lea letter_used+26(%rip), %rsi
    xor %rax, %rax
    # Part1: Don't increment if cnt < 1
    # Part2: Don't increment if cnt < group size
    # : Thus, set %r12 which holds group size to 1 (in r11) if part 1
    test %r13, %r13
    cmove %rbx, %r12
    
    jmp .Lcountcheck

.Lcountloop:
    movb (%rdi), %al # add to counter
    cmpb %r12b, %al
    jl .Ltoosmall
    inc %r15
.Ltoosmall:
    movb $0, (%rdi)  # zero array
    inc %rdi
.Lcountcheck:
    cmp %rdi, %rsi
    jne .Lcountloop

    xor %r12, %r12 # zero group size counter   
 
    testb %r14b, %r14b # was last line?
    je .Lnextline # get next line if not
    jmp .Lnolinesleft

.Lgroupcont:
    lea linebuf(%rip), %rdi
    lea letter_used(%rip), %rsi # letter used address
    xor %rax, %rax
    inc %r12 # number of people in the group
    jmp .Lnullcheck

.Lcharloop:
    subb $'a', %al # i = *buf - '0'
    lea (%rsi, %rax), %rdx 
    addb $1, (%rdx) # letter_used[i] += 1
    inc %rdi
.Lnullcheck:
    movb (%rdi), %al
    testb %al, %al
    jne .Lcharloop
    jmp .Lnextline

.Lnolinesleft:
    push %r15
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    ret

fmt: .string "@\n"
    .data
linebuf: .fill 128
letter_used: .fill 32
