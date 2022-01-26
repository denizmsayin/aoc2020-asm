    .global main

    .extern printi
    .extern putstr
    
    .extern binsearch_long
    .extern binsearch_word
    .extern binsearch_short

.set SIZE, 2

main:
    lea array(%rip), %r12
    lea arrayend(%rip), %r13
    jmp .Lck

.Lloop:
    movw (%r12), %ax
    movsx %ax, %rax

    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp    

    add $SIZE, %r12
.Lck:
    cmp %r12, %r13
    jne .Lloop

    lea newline(%rip), %rdi
    call putstr

    # Search for values in the array
    lea searcharray(%rip), %r12
    lea searcharrayend(%rip), %r13
    jmp .Lck2

.Lloop2:
    movw (%r12), %ax
    movsx %ax, %rax
    push %rax

    mov %rax, %rdi
    lea array(%rip), %rsi
    mov $8, %rdx
    call binsearch_short

    push %rax
    lea fmtsearch(%rip), %rdi
    call printi
    add $16, %rsp    

    add $SIZE, %r12
.Lck2:
    cmp %r12, %r13
    jne .Lloop2

    ret

fmtsearch: .string "Got: @ when searching for: @\n"
fmt: .string "@ "
newline: .string "\n"

array:
    .word 3
    .word 7
    .word 28
    .word 45
    .word 48
    .word 72
    .word 101
    .word 108
arrayend:

searcharray:
    .word -5
    .word 0
    .word 3
    .word 7
    .word 9
    .word 28
    .word 45
    .word 46
    .word 48
    .word 72
    .word 101
    .word 102
    .word 108
    .word 1700
searcharrayend:
