    .global main

    .extern getline
    .extern printi

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
 
.Lnextline:
    lea buf(%rip), %rdi
    mov $4096, %rsi
    call getline
    jc .Lend

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

    cmp %r13, %rax
    cmovg %rax, %r13
    jmp .Lnextline

.Lend:
    push %r13
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    ret
    
fmt: .string "@\n"
    .data
buf: .fill 4096
