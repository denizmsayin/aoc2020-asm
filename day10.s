    .global main

    .extern getia
    .extern printi
    .extern part2set
    .extern quicksort_long

.set PREAMBLE_LEN, 25

    .text
main:
    xor %r12, %r12
    call part2set
    setc %r12b

    # get the joltage values
    # start from offset 1, with 0 as sentinel first value
    lea array(%rip), %rdi
    movq $0, (%rdi)
    add $8, %rdi
    mov $1024, %rsi
    call getia
    lea 1(%rax), %r13 # array size

    # sort them
    lea array(%rip), %rdi
    mov %r13, %rsi
    call quicksort_long 
   
    # part 1 is easy, just go through the values, and take care of the diffs
    xor %r8, %r8 # diff 1 count
    mov $1, %r9 # diff 3 count (+1 due to +3 jolter in bag)    

    lea array(%rip), %rdi
    lea -8(%rdi, %r13, 8), %rsi # end of array - 1
    jmp .Lck

.Lloop:
    mov (%rdi), %rax
    mov 8(%rdi), %rbx
    
    sub %rax, %rbx # check the diff
    cmp $3, %rbx
    jne .Lnot3
    inc %r9
    jmp .Lnot1
.Lnot3: 
    cmp $1, %rbx
    jne .Lnot1
    inc %r8
.Lnot1:
    add $8, %rdi
.Lck:
    cmp %rdi, %rsi
    jne .Lloop     

    imul %r8, %r9
    push %r9
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    ret
    
dbgfmt: .string "3-diffs: @, 1-diffs: @\n"

fmt: .string "@\n"

    .data
array: .fill 8192 
