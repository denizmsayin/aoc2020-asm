    .global part2set

    .text
# Depends on command line arguments. Call as first thing from main!
# 2 as single argument: Part 2
# Otherwise: Part 1
# Sets carry flag if part2!
part2set:
    cmp $2, %rdi
    jne .Lnope
    
    lea 8(%rsi), %rax # &argv[1]
    mov (%rax), %rax # argv[1]
    movb (%rax), %al # argv[1][0]
    cmp $'2', %al
    jne .Lnope
    stc
    ret

.Lnope:
    clc
    ret
