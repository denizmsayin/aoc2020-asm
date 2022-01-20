    .global getgrid

    .extern getc

    .text
# Get a grid of characters 'till EOF. Size not checked!!
# %rdi: Target array
# -> %rax: Num rows, %rdx: Num cols
getgrid:
    push %r12
    push %r13
    push %r14
    push %r15

    mov %rdi, %r12
    xor %r14, %r14
    xor %r15, %r15

.Lcont:
    call getc
    cmp $-1, %rax
    je .Ldone
    cmp $'\n', %rax
    jne .Lcontcol
    # Case of row being complete here
    inc %r14 # num rows
    mov %r15, %r13 # store num cols (every time!)
    xor %r15, %r15 # zero num cols
    jmp .Lcont
.Lcontcol:
    inc %r15 # num cols
    movb %al, (%r12) # put into array
    inc %r12 # incr. pointer
    jmp .Lcont

.Ldone:
    # Set number of rows and cols
    mov %r14, %rax
    mov %r13, %rdx

    pop %r15
    pop %r14
    pop %r13
    pop %r12

    ret
