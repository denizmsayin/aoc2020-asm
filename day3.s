    .global main
    
    .extern getgrid
    .extern part2set

    .text
main:
    xor %r14, %r14
    call part2set
    setc %r14b

    lea gridbuf(%rip), %rdi
    call getgrid
    # %rax -> nrows, %rdx -> ncols

    # We'll need %rax and %rdx for division,
    # so store nrows, ncols somewhere else
    mov %rax, %r12
    mov %rdx, %r13

    mov %r12, %rdi
    mov %r13, %rsi
    mov $1, %rdx
    mov $3, %rcx
    call count_trees
   
    andq %r14, %r14 # set if part2
    je .Lskipp2

    # Part 2 requires a few more calls
    mov %rax, %r15

    mov %r12, %rdi
    mov %r13, %rsi
    mov $1, %rdx
    mov $1, %rcx
    call count_trees
    imul %rax, %r15

    mov %r12, %rdi
    mov %r13, %rsi
    mov $1, %rdx
    mov $5, %rcx
    call count_trees
    imul %rax, %r15

    mov %r12, %rdi
    mov %r13, %rsi
    mov $1, %rdx
    mov $7, %rcx
    call count_trees
    imul %rax, %r15

    mov %r12, %rdi
    mov %r13, %rsi
    mov $2, %rdx
    mov $1, %rcx
    call count_trees
    
    imul %r15, %rax

.Lskipp2:
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    ret

# Count trees with different slopes
# %rdi: nrows
# %rsi: ncols
# %rdx: i increment
# %rcx: j increment
# -> %rax: trees encountered
count_trees:

    push %r12
    push %r13

    # Need to loop and count trees
    lea gridbuf(%rip), %rbx
    # %rax and %rdx are necessary for div'ing (ugh!)
    # so need to store those somewhere else.
    mov %rdx, %r10 # i increment
    xor %r11, %r11 # tree counter
    # %r12 and %r13 for i, j
    mov %r10, %r12
    mov %rcx, %r13
    # Let the loop begin!
    jmp .Lcheck

.Lloop:
    # Need to access gridbuf[i][j] somehow...
    # Corresponds to *(gridbuf + i * ncols + j)
    # Can make this more efficient by pre-calculating 
    # jincr * ncols + iincr and adding it to a pointer, but let's
    # keep it straightforward this time.
    lea (%rbx, %r13), %r8 # gridbuf + j
    mov %r12, %r9
    imul %rsi, %r9 # i * ncols
    add %r9, %r8 # gridbuf + i * ncols + j
    movb (%r8), %al # gridbuf[i][j]
    cmp $35, %al # compare with '#'
    jne .Lnottree
    inc %r11
.Lnottree:
    add %r10, %r12 # i += i_incr
    # j += j_incr does not cut it!
    # We need j = (j + j_incr) % ncols
    lea (%r13, %rcx), %rax # rax = j + j_incr
    xor %rdx, %rdx # rdx = 0
    div %rsi # divide by ncols
    mov %rdx, %r13 # move remainder to j
 
.Lcheck:
    cmp %rdi, %r12 # i < nrows ?
    jl .Lloop

    # Move result to rax
    mov %r11, %rax  
 
    pop %r13
    pop %r12

    ret

fmt: .string "@\n"
    .data
gridbuf: .fill 65536
