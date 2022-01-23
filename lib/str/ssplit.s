    .global ssplit
    .global ssplit_whitespace

    .extern sskip

local_iswhitespace:
    cmpb $' ', %dil
    je .Lyes
    cmpb $'\t', %dil
    je .Lyes
    xor %rax, %rax
    ret
.Lyes:
    mov $1, %rax
    ret

# %rdi: address of the string buffer (will be modified with inserted 0s!)
# %rsi: output array holding pointers to each part in the split
# -> %rax: size of the output array
ssplit_whitespace:
    mov %rsi, %rdx
    lea local_iswhitespace(%rip), %rsi
    # fall down to ssplit!

# %rdi: address of the string buffer (will be modified with inserted 0s!)
# %rsi: function int (*skip)(int) that determines whether to split on char (1 if split, else 0)
# %rdx: output array holding pointers to each part in the split
# -> %rax: size of the output array
ssplit:
    
    push %r12
    push %r13
    push %r14
    push %r15
 
    mov %rdi, %rax # string itr
    mov %rsi, %r13 # function
    mov %rsi, negatef(%rip) # ... and negation
    mov %rdx, %r14 # output array
    xor %r15, %r15 # output array size

.Lloop:
    # Skip split chars
    mov %rax, %rdi
    mov %r13, %rsi
    call sskip
    cmpb $0, (%rax)
    je .Ldone

    # Current start should be in output array
    mov %rax, (%r14)
    add $8, %r14
    inc %r15

    # Skip other chars
    mov %rax, %rdi
    lea negate(%rip), %rsi
    call sskip
    cmpb $0, (%rax)
    je .Ldone
    
    # Add null to end if not done
    movb $0, (%rax)
    inc %rax
    jmp .Lloop

.Ldone:
    mov %r15, %rax
    pop %r15
    pop %r14
    pop %r13
    pop %r12

    ret

# Useful for negating the provided skip function
# Takes the function from %r12
negate:
    call *negatef(%rip)
    xorq $1, %rax # negate the result: 1 -> 0, 0 -> 1
    ret

    .data
negatef: .quad 0
