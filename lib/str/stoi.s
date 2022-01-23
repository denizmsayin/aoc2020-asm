    .global stoi

# %rdi: string to convert to long
# -> %rax converted value
stoi:
    xor %rax, %rax

    # Check if first char is -
    mov $1, %r9 # final multiplier
    cmpb $'-', (%rdi)
    jne .Lck
    inc %rdi
    mov $-1, %r9
    jmp .Lck

.Lloop:
    sub $'0', %r8
    imul $10, %rax
    add %r8, %rax
    inc %rdi
.Lck:
    xorq %r8, %r8
    movb (%rdi), %r8b
    cmpb $'0', %r8b
    jl .Ldone
    cmpb $'9', %r8b
    jle .Lloop

.Ldone:
    imul %r9, %rax

    ret
