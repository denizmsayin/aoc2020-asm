    .global main

    .extern part2set
    .extern putstr

main:
    call part2set
    jc .Lpart2
    lea no(%rip), %rdi
    jmp .Lcont
.Lpart2:
    lea yes(%rip), %rdi
.Lcont:
    call putstr
    ret

yes: .string "PART 2\n"
no: .string "PART 1\n"
