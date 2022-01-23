    .global main

    .extern getline
    .extern ssplit_whitespace
    .extern printi

# %rdi: buffer pointing to kv pair
# -> %rax: 1 if k is a necessary field
isfield:
    cmpb $'c', (%rdi) # only cid starts with c
    je .Lun
    mov $1, %rax
    ret
.Lun:
    xor %rax, %rax
    ret
    

main:
    xor %r12, %r12 # valid passport counter
    xor %r13, %r13 # valid field counter
    xor %r15, %r15 # last line flag

.Lnextline:
    lea linebuf(%rip), %rdi
    mov $4096, %rsi
    call getline
    setc %r15b # CF set if last line

    # Check if empty line
    test %rax, %rax
    jne .Lprocessline
    # If so...
    cmp $7, %r13 # exactly 7 valid fields?
    jne .Linvalidpass
    inc %r12 # if so, add 1 to valid pass counter
.Linvalidpass:
    xor %r13, %r13 # zero counter
    test %r15, %r15 # Was this the final line?
    je .Lnextline # if not, continue
    # If so, print the number of valid passports and exit
    push %r12
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp
    ret

.Lprocessline:
    # Otherwise, split the line and count useful stuff
    lea linebuf(%rip), %rdi
    lea splitarr(%rip), %rsi
    call ssplit_whitespace
    lea splitarr(%rip), %rsi
    mov %rax, %r14

.Lnextfield:
    mov (%rsi), %rdi
    call isfield
    add %rax, %r13
    add $8, %rsi
    dec %r14
    jne .Lnextfield

    jmp .Lnextline
    
fmt: .string "@\n"

    .data
linebuf: .fill 4096
splitarr: .fill 4096
