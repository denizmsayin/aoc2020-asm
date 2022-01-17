    .global fprinti    
    .global printi
    
    .extern fputstr

    .text

# Format a long int to the given array. 
# %rax: Value to be formatted
# %r8: Array start 
putint:
    and %rax, %rax
    jne .Lputint_nonzero
    # Zero case, just write a zero
    movb $'0', (%r8)
    ret
.Lputint_nonzero: # add - to the array and negate
    jg .Lputint_positive # Positive
    movb $'-', (%r8)
    inc %r8
    neg %rax
.Lputint_positive: 
    # Now, we will do standard divmod 10 loop. But this generates
    # the digits in reverse! So, first a little loop until we find
    # how many digits the number is. We will increment the target
    # pointer by this much, and then decrement it in the next loop.
    mov $10, %r9
    jmp .Lputint_size_check
.Lputint_size_loop:
    inc %r8
    imul $10, %r9
.Lputint_size_check:
    cmp %r9, %rax
    jge .Lputint_size_loop
    lea 1(%r8), %r11 # save the end of the buffer for progress
    mov $10, %r9 # for division

.Lputint_divloop:
    # loop, div by 10 and add remainder (ascii'd) to %r8
    xor %rdx, %rdx
    div %r9
    add $'0', %rdx 
    movb %dl, (%r8)
    dec %r8
    and %rax, %rax
    jne .Lputint_divloop
    mov %r11, %r8 # restore r8 to end of the buffer
    ret

# Use with format strings like "Count=@, Result=@", with @ as the placeholder.
# There are no options, everything is assumed to be a long int.
# For practicality, all format arguments are assumed to be on the stack and enough.
# %rdi: fp
# %rsi: format string
# Stack: integers to print
# Clobbered: %r8, %r9, %r10, %r11
fprinti:
    push %rbp               # classic prologue
    mov %rsp, %rbp          # save rsp into rbp
    mov %rsp, %r8           # 512-byte array as a buffer
    sub $0x200, %r8
    add $16, %rsp           # move rsp up to avoid return address while popping
    mov %r8, %r10           # Save the start of the buffer
    jmp .Lfprinti_check
.Lfprinti_loop:
    cmpb $64, %r11b         # compare with @
    je .Lfprinti_placeholder  # go to putint

    # Just add the character to the buffer
    movb %r11b, (%r8)
    inc %r8
    jmp .Lfprinti_incr

.Lfprinti_placeholder:
    pop %rax                # Get value from the stack for putint
    call putint             # increments r8 as much as necessary

.Lfprinti_incr:
    inc %rsi
.Lfprinti_check: 
    movb (%rsi), %r11b      # put char in reg
    and %r11b, %r11b
    jne .Lfprinti_loop

    mov %rbp, %rsp          # Restore rsp, the main work is done
    pop %rbp                # Necessary to prevent stack clobbering by fputstr's ret addr.
    
    # Almost done, just need a last zero and a print
    movb $0, (%r8)
    mov %r10, %rsi
    call fputstr

    ret

# %rdi: Format string
# Clobbered: %r8, %r9
printi:
    mov %rdi, %rsi
    mov $1, %rdi
    jmp fprinti # Tail call to not disrupt the stack!
