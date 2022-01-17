    .extern slen
    .global fputstr
    .global putstr

    .text
# The most basic thing, for printing a string to a fd.
# %rdi has fd, %rsi has zero terminated buffer.
fputstr:
    mov %rdi, %r8
    mov %rsi, %rdi
    call slen
    mov %rax, %rdx
    mov %rdi, %rsi
    mov %r8, %rdi
    mov $1, %rax
    syscall
    ret

# Print a string to stdout.
# %rdi has the string
putstr:
    mov %rdi, %rsi
    mov $1, %rdi
    call fputstr
    ret

