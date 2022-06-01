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
    lea array(%rip), %r15 # array address for easy access
    # start from offset 1, with 0 as sentinel first value
    movq $0, (%r15)
    lea 8(%r15), %rdi
    mov $1023, %rsi
    call getia
    lea 1(%rax), %r13 # save the length so far

    # sort
    lea array(%rip), %rdi
    mov %r13, %rsi
    call quicksort_long 
    
    # Now, want to add final + 3 as another sentinel value
    lea -8(%r15, %r13, 8), %rdi # acquire the last value
    mov (%rdi), %r8
    add $3, %r8 # +3 and store as sentinel
    mov %r8, 8(%rdi)
    add $1, %r13 # add one more to length
   
    # part 1 is easy, just go through the values, and take care of the diffs
    xor %r8, %r8 # diff 1 count
    xor %r9, %r9 # diff 3 count

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
array: .fill 1024,8
counts: .fill 1024,8 
