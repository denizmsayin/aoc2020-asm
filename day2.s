    .global main

    .extern geti
    .extern getc
    .extern getstr
    .extern printi
    .extern part2set

main:
    xor %r12, %r12 # counter for correct passwords
    xor %rbx, %rbx
    call part2set
    setc %bl # %rbx = 1 if part 2

.Llineloop:
    call geti # lower limit
    jc .Lnolines # no more lines left if carry flag is set
    mov %rax, %r13
    call getc # skip the dreaded minus
    call geti # upper limit
    mov %rax, %r14
    call skipwhite # skip whitespace
    call getc # target char
    mov %rax, %r15
    call getc # :
    lea buffer(%rip), %rdi
    mov $512, %rsi
    call getstr # the password


    # Load the buffer, zero the counter
    lea buffer(%rip), %rdx
    xor %rcx, %rcx

    # Part difference
    and %rbx, %rbx
    jne .Lpart2
    jmp .Lcheck

    # For Part1:
    # Loop through the password, counting target chars
.Lloop:
    cmp %r15b, %al
    jne .Lneq
    inc %rcx
.Lneq:
    inc %rdx
.Lcheck:
    movb (%rdx), %al
    and %al, %al
    jne .Lloop

    # Right amount of target chars?
    cmp %r13, %rcx
    jl .Lnope
    cmp %r14, %rcx
    jg .Lnope
    inc %r12
    jmp .Lnope # Skip part2 code

    # For Part2:
    # Check target positions for char.
.Lpart2:
    lea -1(%rdx, %r13), %r11
    movb (%r11), %al
    cmp %r15b, %al 
    jne .Lfirstnot
    inc %rcx
.Lfirstnot:
    lea -1(%rdx, %r14), %r11
    movb (%r11), %al
    cmp %r15b, %al
    jne .Lsecondnot
    inc %rcx
.Lsecondnot:
    cmp $1, %rcx # exactly one must matcch
    jne .Lnope
    inc %r12

.Lnope:
    jmp .Llineloop

.Lnolines:
    push %r12
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    ret



fmt: .string "@\n"

    .data
buffer: .fill 512
