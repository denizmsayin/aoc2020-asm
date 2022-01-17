    .global main
    
    .extern getia
    .extern printi
    .extern part2set

    .text
main:
    call part2set
    jc .Lpart2

.Lpart1:
    # Read array
    lea array(%rip), %rdi
    mov $0x200, %rsi
    call getia
    mov %rax, %rsi # %rsi = N

    # Now, need to do a loop sum
    lea array(%rip), %rdi
    xor %r8, %r8
    jmp .Licheck 
.Liloop:
    lea 1(%r8), %r9 # j = i + 1
    lea (%rdi, %r8, 8), %rax
    mov (%rax), %r10 # %r10 = array[i]
    jmp .Ljcheck
.Ljloop:
    lea (%rdi, %r9, 8), %rax
    mov (%rax), %r11 # %r11 = array[j]
    lea (%r10, %r11), %r12 # %r12 = array[i] + array[j]
    cmp $2020, %r12
    jne .Ljincr # Continue looking, != 2020

    # Found pair, calculate product and print
    imul %r10, %r11
    push %r11
    lea result_fmt(%rip), %rdi
    call printi
    add $8, %rsp 
    ret

.Ljincr:
    inc %r9
.Ljcheck:
    cmp %rsi, %r9
    jl .Ljloop

    inc %r8
.Licheck:
    cmp %rsi, %r8
    jl .Liloop

    ret



.Lpart2:
    # Read array
    lea array(%rip), %rdi
    mov $0x200, %rsi
    call getia
    mov %rax, %rsi # %rsi = N

    # Now, need to do a loop sum
    lea array(%rip), %rdi
    xor %r8, %r8
    jmp .Licheck2 
.Liloop2:
    lea 1(%r8), %r9 # j = i + 1
    lea (%rdi, %r8, 8), %rax
    mov (%rax), %r11 # %r11 = array[i]
    jmp .Ljcheck2
.Ljloop2:
    lea 1(%r9), %r10 # k = j + 1
    lea (%rdi, %r9, 8), %rax
    mov (%rax), %r12 # %r12 = array[j]
    jmp .Lkcheck2
.Lkloop2:
    lea (%rdi, %r10, 8), %rax
    mov (%rax), %r13 # %r13 = array[k]
    lea (%r11, %r12), %r14 # %r14 = array[i] + array[j]
    add %r13, %r14

    cmp $2020, %r14
    jne .Lkincr2 # Continue looking, != 2020

    # Found pair, calculate product and print
    imul %r11, %r13
    imul %r12, %r13
    push %r13
    lea result_fmt(%rip), %rdi
    call printi
    add $8, %rsp 
    ret

.Lkincr2:
    inc %r10
.Lkcheck2:
    cmp %rsi, %r10
    jl .Lkloop2

    inc %r9
.Ljcheck2:
    cmp %rsi, %r9
    jl .Ljloop2

    inc %r8
.Licheck2:
    cmp %rsi, %r8
    jl .Liloop2

    ret
    
    .data
array: .fill 0x1000
result_fmt: .string "@\n"
