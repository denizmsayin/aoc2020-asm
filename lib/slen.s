    .global slen
    
    .text
# String length.
# %rdi has the string.
# %r11 is clobbered.
slen:
    mov %rdi, %rax
    movb (%rax), %r11b
    jmp slen_check
slen_loop:
    add $1, %rax
    movb (%rax), %r11b
slen_check:
    andb %r11b, %r11b
    jne slen_loop
    sub %rdi, %rax
    ret
