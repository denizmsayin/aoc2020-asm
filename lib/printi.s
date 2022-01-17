    .global fputstr
    .global putstr
    .global fprinti    
    .global printi
    .global main

    .text
slen:
    # String length.
    # %rdi has the string.
    mov %rdi, %rax
    mov (%rax), %r11
    jmp slen_check
slen_loop:
    add $1, %rax
    mov (%rax), %r11
slen_check:
    and %r11, %r11
    jne slen_loop
    
    

fputstr:
    # The most basic thing, for printing a string.
    # %rdi has fd, %rsi has zero terminated buffer.

putint:
    # Print a long int to the given file. fd in %rdi, value in %rsi
    and %rsi, %rsi
    jne putint_nonzero
    # Zero case, just write a zero
    lea zero_string(%rip), %rsi
    mov $1, %rax
    mov $1, %rdx
    syscall
    ret
putint_nonzero:
    # This is more of a problem... For performance, let's store the result in a buffer.
    # 20 digits + 1 minus: 

fprinti:
    # Use with format strings like "Count=@, Result=@", with @ as the placeholder.
    # There are no options, everything is assumed to be a long int.
    # For practicality, all format arguments are assumed to be on the stack and enough.

zero_string:
    .asciz "0"
