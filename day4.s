    .global main

    .extern getline
    .extern ssplit_whitespace
    .extern ssplit
    .extern sskip
    .extern printi
    .extern part2set

iscolon:
    xor %rax, %rax
    cmpb $':', %dil
    sete %al
    ret

isdigit:
    cmpb $'0', %dil
    jl .Lnotdig
    cmpb $'9', %dil
    jg .Lnotdig
    mov $1, %rax
    ret
.Lnotdig:
    xor %rax, %rax
    ret

ishexdigit:
    cmpb $'0', %dil
    jl .Lnotdecdig
    cmpb $'9', %dil
    jg .Lnotdecdig
    mov $1, %rax
    ret
.Lnotdecdig:
    cmpb $'a', %dil
    jl .Lnothex
    cmpb $'f', %dil
    jg .Lnothex
    mov $1, %rax
    ret
.Lnothex:
    xor %rax, %rax
    ret

# %rdi: buffer pointing to kv pair
# -> %rax: 1 if k is a necessary field
isfieldp2:
    xor %rax, %rax
    # First, check if cid
    cmpb $'c', (%rdi)
    jne .Luseful
    ret    

.Luseful:
    # split into key and value, stack will hold
    push %r12
    push %r13
    sub $16, %rsp
    lea iscolon(%rip), %rsi
    mov %rsp, %rdx
    call ssplit

    mov (%rsp), %r12     # key
    mov 8(%rsp), %rdi    # value

    cmpb $'b', (%r12) # birth year
    jne .Lnotbirth

    # Birth year: 1920 <= y <= 2002
    call stoi # rdi has value
    cmp $1920, %rax
    jl .Linvalid
    cmp $2002, %rax
    jg .Linvalid
    jmp .Lvalid

.Lnotbirth:
    cmpb $'i', (%r12) # issue year
    jne .Lnotissue

    # Issue year: 2010 <= y <= 2020
    call stoi
    cmp $2010, %rax
    jl .Linvalid
    cmp $2020, %rax
    jg .Linvalid
    jmp .Lvalid

.Lnotissue:
    cmpb $'p', (%r12) # passport id
    jne .Lnotpid

    # Passport id: nine digits of 0-9
    # Skip digits, then check if end of str && 9 skipped
    mov %rdi, %r13
    lea isdigit(%rip), %rsi
    call sskip
    
    cmpb $0, (%rax)
    jne .Linvalid
    sub %r13, %rax
    cmp $9, %rax
    jne .Linvalid
    jmp .Lvalid

.Lnotpid:
    cmpb $'e', (%r12) # check for e
    jne .Lnote

    # need to check second digit
    cmpb $'y', 1(%r12)
    jne .Leyecolor

    # Not eye color, must be expiration year: 2020 <= y <= 2030
    call stoi
    cmp $2020, %rax
    jl .Linvalid
    cmp $2030, %rax
    jg .Linvalid
    jmp .Lvalid

.Leyecolor:
    # one of amb blu brn gry grn hzl oth
    # three bytes + 0: load 4 bytes into register and compare
    movl (%rdi), %eax
    
    cmp $0x626d61, %eax # amb
    je .Lvalid
    cmp $0x756c62, %eax # blu
    je .Lvalid
    cmp $0x6e7262, %eax # brn
    je .Lvalid
    cmp $0x797267, %eax # gry
    je .Lvalid
    cmp $0x6e7267, %eax # grn
    je .Lvalid
    cmp $0x6c7a68, %eax # hzl
    je .Lvalid
    cmp $0x68746f, %eax # oth
    je .Lvalid
    jmp .Linvalid

.Lnote:
    # must be h now, check second char

    cmpb $'g', 1(%r12)
    jne .Lhaircolor

    # Height: either Xcm or Xin
    # Get value first
    mov %rdi, %r13
    call stoi
    mov %rax, %r12 # store value

    # Skip digits
    mov %r13, %rdi
    lea isdigit(%rip), %rsi
    call sskip
    
    # Now check!
    cmpb $0, 2(%rax) # must be of length 2
    jne .Linvalid

    # Now, the other two chars
    cmpw $0x6d63, (%rax) # cm
    jne .Lnotcm

    # cm case: must be 150 <= h <= 193
    cmp $150, %r12
    jl .Linvalid
    cmp $193, %r12
    jg .Linvalid
    jmp .Lvalid

.Lnotcm:
    cmpw $0x6e69, (%rax) # in
    jne .Linvalid
    
    # inch case: must be 59 <= h <= 76
    cmp $59, %r12
    jl .Linvalid
    cmp $76, %r12
    jg .Linvalid
    jmp .Lvalid

.Lhaircolor:
    # '#' followed by six digits between 0-9 or a-f
    cmpb $35, (%rdi)
    jne .Linvalid
    
    inc %rdi
    mov %rdi, %r13
    lea ishexdigit(%rip), %rsi
    call sskip

    cmpb $0, (%rax)
    jne .Linvalid
    sub %r13, %rax
    cmp $6, %rax
    jne .Linvalid
    # Valid!

.Lvalid:
    mov $1, %rax
    jmp .Ldone
.Linvalid:
    xor %rax, %rax

.Ldone:
    add $16, %rsp
    pop %r13
    pop %r12 
    
    ret

# %rdi: buffer pointing to kv pair
# -> %rax: 1 if k is a necessary field
isfieldp1:
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
    lea isfieldp1(%rip), %r15 # function for field checking
    lea isfieldp2(%rip), %r14 # same for part2

    call part2set # cmove part2 if we're at part2
    cmovc %r14, %r15

.Lnextline:
    lea linebuf(%rip), %rdi
    mov $4096, %rsi
    call getline
    setc %dil # CF set if last line

    # Check if empty line
    test %rax, %rax
    jne .Lprocessline
    # If so...
    cmp $7, %r13 # exactly 7 valid fields?
    jne .Linvalidpass
    inc %r12 # if so, add 1 to valid pass counter
.Linvalidpass:
    xor %r13, %r13 # zero counter
    test %dil, %dil # Was this the final line?
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
    lea splitarr(%rip), %rbx
    mov %rax, %r14

.Lnextfield:
    mov (%rbx), %rdi
    call *%r15
    add %rax, %r13
    add $8, %rbx
    dec %r14
    jne .Lnextfield

    jmp .Lnextline
    
fmt: .string "@\n"

    .data
linebuf: .fill 4096
splitarr: .fill 4096
