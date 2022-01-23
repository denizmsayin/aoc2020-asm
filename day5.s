    .global main

    .extern getline
    .extern printi
    .extern part2set

# %rdi: string holding binary search
# %rsi: lower limit
# %rdx: upper limit
# %rcx: lower char
# %r8: upper char
# -> %rax: value
findmid:
    dec %rdi

.Lloop:
    inc %rdi
    movb (%rdi), %r9b
    
    # compute mid
    lea (%rsi, %rdx), %rax
    shr $1, %rax    

    cmpb %r9b, %cl # lower character?
    jne .Lnotlower
    mov %rax, %rdx # lower half: upper = mid
    jmp .Lloop
.Lnotlower:
    cmpb %r9b, %r8b
    jne .Lneither
    lea 1(%rax), %rsi # upper half: lower = mid + 1
    jmp .Lloop   
 
.Lneither:
    ret # return the last mid

main:
    xor %r13, %r13 # holds max    
    lea seat_full(%rip), %r14 # holds existing seats array address
    xor %r15, %r15
    call part2set
    setc %r15b # r15 set if part2
 
.Lnextline:
    lea buf(%rip), %rdi
    mov $4096, %rsi
    call getline
    jc .Lnolinesleft

    lea buf(%rip), %rdi
    mov $0, %rsi
    mov $127, %rdx
    mov $'F', %rcx
    mov $'B', %r8
    call findmid
    mov %rax, %r12 # row ID in r12

    lea buf+7(%rip), %rdi
    mov $0, %rsi
    mov $7, %rdx
    mov $'L', %rcx
    mov $'R', %r8
    call findmid
    lea (%rax, %r12, 8), %rax # id = 8 * row ID + col ID

    # update max
    cmp %r13, %rax
    cmovg %rax, %r13

    # mark seat full
    lea (%r14, %rax), %r11
    movb $1, (%r11)

    jmp .Lnextline

.Lnolinesleft:
    # For part 1: print max
    test %r15b, %r15b
    je .Lend

    # For part 2, need to find 0 element; start from max and head back
    lea (%r14, %r13), %r11
    lea seat_full(%rip), %r10
    jmp .Lbackcheck

.Lbackloop:
    cmpb $0, (%r11) # current value unmarked?
    jne .Lnotfound
    mov %r11, %r13 # found value! r11 - r10 gives the current ID
    sub %r10, %r13
    jmp .Lend
.Lnotfound:
    dec %r11 # keep searching
.Lbackcheck:
    cmp %r10, %r11
    jne .Lbackloop

.Lend:
    push %r13
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    ret
    
fmt: .string "@\n"
    .data
buf: .fill 4096
seat_full: .fill 1024 # at most 1024 seats
