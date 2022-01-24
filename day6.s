    .global main

    .extern getline
    .extern printi

main:
    xor %r14, %r14 # last line marker
    xor %r15, %r15 # total counter    

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
    jmp .Lcountcheck

.Lcountloop:
    movb (%rdi), %al # add to counter
    add %rax, %r15
    movb $0, (%rdi)  # zero array
    inc %rdi
.Lcountcheck:
    cmp %rdi, %rsi
    jne .Lcountloop
    
    testb %r14b, %r14b # was last line?
    je .Lnextline # get next line if not
    jmp .Lnolinesleft

.Lgroupcont:
    lea linebuf(%rip), %rdi
    lea letter_used(%rip), %rsi # letter used address
    xor %rax, %rax
    jmp .Lnullcheck

.Lcharloop:
    subb $'a', %al # i = *buf - '0'
    lea (%rsi, %rax), %rdx 
    movb $1, (%rdx) # letter_used[i] = 1
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
