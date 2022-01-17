    .global getc
    .global peekc
    .global advc

    .text
advc:
    mov bufferpos(%rip), %rax
    inc %rax
    movq %rax, bufferpos(%rip)
    ret

peekc:
    call ensurebuffer
.Lpeekc_ensure_ret:
    lea buffer(%rip), %r11
    add bufferpos(%rip), %r11
    xor %rax, %rax
    movb (%r11), %al
    ret

getc:
    call ensurebuffer
.Lc_ensure_ret:
    lea buffer(%rip), %r11
    mov bufferpos(%rip), %rax
    inc %rax
    movq %rax, bufferpos(%rip)
    dec %rax
    add %rax, %r11
    xor %rax, %rax
    movb (%r11), %al
    ret

ensurebuffer:
    mov bufferpos(%rip), %rax
    mov bufferlim(%rip), %rdi
    cmp %rdi, %rax
    jl .Lensurebuffer_done
    movq $0, bufferpos(%rip)
    xor %rax, %rax # make a read call to fill the buffer
    xor %rdi, %rdi
    lea buffer(%rip), %rsi
    mov $4096, %rdx
    syscall # read(0, buffer, 4096)
    
    movq %rax, bufferlim(%rip) # Move limit to bufferlim
    and %rax, %rax
    jne .Lensurebuffer_done
    # Nothing left... Return -1 to the original caller.
    # Have to bypass getc/peekc's call though.
    add $8, %rsp
    mov $-1, %rax
    ret
.Lensurebuffer_done:
    ret
    
    .data
buffer:
    .fill 4096
    .set buffer_size, .-buffer
bufferpos:
    .quad 4096
bufferlim:
    .quad 4096
