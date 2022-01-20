    .global main
    
    .extern getgrid

    .text
main:
    lea gridbuf(%rip), %rdi
    call getgrid
    # %rax -> nrows, %rdx -> ncols

    # We'll need %rax and %rdx for division,
    # so store nrows, ncols somewhere else
    mov %rax, %r13
    mov %rdx, %rcx

    # Need to loop and count trees
    lea gridbuf(%rip), %rdi
    mov $1, %r8 # i
    mov $3, %r9 # j
    xor %r15, %r15 # tree counter
    jmp .Lcheck

.Lloop:
    # Need to access gridbuf[i][j] somehow...
    # Corresponds to *(gridbuf + i * ncols + j)
    # Can make this more efficient by pre-calculating 
    # 3 * ncols + 1 and adding it to a pointer, but let's
    # keep it straightforward this time.
    lea (%rdi, %r9), %r10 # gridbuf + j
    mov %r8, %r11
    imul %rcx, %r11 # i * ncols
    add %r11, %r10 # gridbuf + i * ncols + j
    movb (%r10), %r12b # gridbuf[i][j]
    cmp $35, %r12b # compare with #
    jne .Lnottree
    inc %r15
.Lnottree:
    add $1, %r8
    # j += 3 does not cut it!
    # We need j = (j + 3) % ncols
    lea 3(%r9), %rax
    xor %rdx, %rdx
    div %rcx # divide by ncols
    mov %rdx, %r9 # move remainder to r9
 
.Lcheck:
    cmp %r8, %r13 # reached the end
    jne .Lloop
    
    # Loop complete, print number of trees
    lea fmt(%rip), %rdi
    push %r15
    call printi
    add $8, %rsp

    ret

fmt: .string "@\n"
    .data
gridbuf: .fill 65536
