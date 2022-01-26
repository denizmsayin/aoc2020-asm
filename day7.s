	.global main

	.extern getstr
	.extern geti
	.extern printi
    .extern peekc
    .extern skipstr
    .extern skipwhite
    .extern blkset
    .extern part2set

# There are 18 adjectives and 33 colors.

# To simplify life, I need to map each of those strings
# to an index. I'm using my own kind of 'code generator' for that.
# See get_adji and get_bagi.

# Next: Each bag can have at most 4 other bags. So, I'll have
# an array of 2x5 pairs for each bag in the form (bag_index, count)
# Both will be shorts (2 bytes). bag_index will be equal to
# 65536 in case there are no more contained bags left.
# 20 * 594 = 11880 byte array in total.

# Something like:
# struct count { short bag, count; }
# struct bag { struct count bags[5]; }

.set NO_MORE_BAGS, 0xFFFF # all 1's, easy to set
.set TOTAL_BAGS, 594
.set SHINY_GOLD_ID, 40
.set BAG_BYTE_SIZE, 20
.set BAG_ARRAY_SIZE, TOTAL_BAGS * BAG_BYTE_SIZE
.set SBUF_SZ, 128
.set NUM_BAG_TYPES, 33

showi_fmt: .string "I: [@][@] = @ (+@)\n"
fmt: .string "@\n"

main:
    cmp $3, %rdi
    je .Lshowi
   
    # %r12 for part1/2
    xor %r12, %r12
    call part2set
    setc %r12b
 
    # Mark all bags empty to start off with.
    # NOTE: In the future, make 0 the empty value for simplicity.
    lea btable(%rip), %rdi
    mov $0xFF, %rsi
    mov $BAG_ARRAY_SIZE, %rdx
    call blkset

    # Read the bags
.Lmorebagstoread:
    call read_next_bag
    jnc .Lmorebagstoread

    test %r12, %r12
    jne .Lpart2

    # Good, now process!
    xor %r13, %r13
    xor %r14, %r14
    jmp .Lcountshinygoldcheck
    
.Lcountshinygoldloop:
    mov %r13, %rdi
    call contains_shiny_gold
    add %rax, %r14
    inc %r13
.Lcountshinygoldcheck:
    
    cmp $TOTAL_BAGS, %r13
    jl .Lcountshinygoldloop

    mov %r14, %rax
    jmp .Lprintresult

.Lpart2:
    mov $SHINY_GOLD_ID, %rdi
    call count_bags
    dec %rax # don't count the shiny gold bag itself!

.Lprintresult:    
    push %rax
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    ret

.Lshowi:
    call showi
    ret

# %rdi: Bag index
# -> %rax: 1 if contained, 0 otherwise
# Could memoize this, but not really important.
contains_shiny_gold:
#     mov %rdi, %r13
#     push %rdi
#     lea fmt(%rip), %rdi
#     call printi
#     add $8, %rsp
#     mov %r13, %rdi    

    # First, make sure this is not the shiny gold bag.
    cmp $SHINY_GOLD_ID, %rdi
    jne .Lnotgold
    xor %rax, %rax
    ret

.Lnotgold:

    # Load the bag:
    push %r12

    imul $BAG_BYTE_SIZE, %rdi
    lea btable(%rip), %r12
    add %rdi, %r12 
    jmp .Lbagcheck

    # Loop over its contents:
.Lbagloop:
    cmpw $SHINY_GOLD_ID, %ax # Return 1 if shiny gold.
    jne .Lnotdirectgold
    mov $1, %rax
    pop %r12
    ret
.Lnotdirectgold: # Not directly shiny gold... How about recursively?
    movw %ax, %di
    call contains_shiny_gold # Only r12 matters & is callee-saved
    test %rax, %rax
    je .Lnotrecursivegold
    pop %r12
    ret
.Lnotrecursivegold:
    add $4, %r12 # increment
.Lbagcheck:
    movw (%r12), %ax
    cmpw $NO_MORE_BAGS, %ax
    jne .Lbagloop
    
    xor %rax, %rax
    pop %r12
    ret

# %rdi: Bag index
# -> %rax: number of contained bags
# Once again, could memoize, but not necessary.
count_bags:
    # Need one register for the address, and another for the sum.
    push %r12
    push %r13

    mov $1, %r13 # sum

    imul $BAG_BYTE_SIZE, %rdi
    lea btable(%rip), %r12
    add %rdi, %r12
    jmp .Lcb_check

.Lcb_loop:
    movw %ax, %di # Setup recursive count
    call count_bags # rax now has count
    movw 2(%r12), %di # put multiplier in di
    imul %rdi, %rax # mult.
    add %rax, %r13 # add to count
    add $4, %r12 # advance in the array
.Lcb_check:
    movw (%r12), %ax
    cmpw $NO_MORE_BAGS, %ax
    jne .Lcb_loop

.Lcb_ret:
    mov %r13, %rax
    pop %r13
    pop %r12
    ret

# Read next bag from the input.
# Set carry flag if no more bags left.
read_next_bag:
    call get_next_bagi
    jnc .Lbagexists
    ret

.Lbagexists:
    # Have bag index in %rax. Gotta get the address!
    push %r12
    imul $BAG_BYTE_SIZE, %rax
    lea btable(%rip), %r12
    add %rax, %r12 # Ok, good!

    # skip 'bags' && 'contain'
    call skipstr
    call skipstr

    # First: Do we have a count or 'no'?
    call skipwhite
    call peekc
    cmpb $'n', %al
    jne .Lmorebags

    # Got 'no', skip 'no' 'other' 'bags'
    call skipstr
    call skipstr
    call skipstr
    jmp .Lnomorebags

.Lmorebags:
    # the loop for reading bags.
    call geti # Get & store bag count
    movw %ax, 2(%r12)
    
    call get_next_bagi # Get & store bag index
    movw %ax, (%r12)
    add $4, %r12

    # Skip 'bag'/'bags.,'
    call skipstr
    
    # Is the next character '\n' or -1? If not, we got more bags!
    call peekc
    cmpb $-1, %al
    je .Lnomorebags
    cmpb $'\n', %al
    jne .Lmorebags
    
    # No more bags! Store the end marker and return.
.Lnomorebags:
    movw $NO_MORE_BAGS, (%r12)

    clc
    pop %r12
    ret

# Get index of next bag in put (returned in %rax). 
# Set carry flag if no input is left.
# NOTE: Turns out shiny gold is [1][7] = 40.
get_next_bagi:
	lea sbuf(%rip), %rdi
	mov $SBUF_SZ, %rsi
	call getstr
    
    test %rax, %rax
    jne .Lgotone
    stc
    ret

.Lgotone:

	movw sbuf(%rip), %di
	call get_adji
	mov %rax, %r8
	
	lea sbuf(%rip), %rdi
	mov $SBUF_SZ, %rsi
	call getstr
	
	movl sbuf(%rip), %edi
	call get_bagi
	mov %rax, %r9

	mov %r8, %rax
	imul $NUM_BAG_TYPES, %rax
	add %r9, %rax

    clc
    ret

showi:	
    call get_next_bagi

    mov %rax, %r11
    imul $BAG_BYTE_SIZE, %r11
    push %r11
	push %rax
	push %r9
	push %r8
	lea showi_fmt(%rip), %rdi
    call printi
    add $32, %rsp

    ret

	

# For adjectives, we can decide by interpreting the first
# two bytes only; as a word. 
get_adji:
    cmpw $0x6c63, %di
    jl .Ladj0
    jg .Ladj1
    movw $0, %ax
    ret
.Ladj0:
    cmpw $0x6873, %di
    jl .Ladj00
    jg .Ladj01
    movw $1, %ax
    ret
.Ladj00:
    cmpw $0x6170, %di
    jl .Ladj000
    jg .Ladj001
    movw $2, %ax
    ret
.Ladj000:
    cmpw $0x6166, %di
    jl .Ladj0000
    movw $3, %ax
    ret
.Ladj0000:
    movw $4, %ax
    ret
.Ladj001:
    movw $5, %ax
    ret
.Ladj01:
    cmpw $0x696d, %di
    jl .Ladj010
    jg .Ladj011
    movw $6, %ax
    ret
.Ladj010:
    cmpw $0x696c, %di
    jl .Ladj0100
    movw $7, %ax
    ret
.Ladj0100:
    movw $8, %ax
    ret
.Ladj011:
    movw $9, %ax
    ret
.Ladj1:
    cmpw $0x7264, %di
    jl .Ladj10
    jg .Ladj11
    movw $10, %ax
    ret
.Ladj10:
    cmpw $0x6f70, %di
    jl .Ladj100
    jg .Ladj101
    movw $11, %ax
    ret
.Ladj100:
    cmpw $0x6f64, %di
    jl .Ladj1000
    movw $12, %ax
    ret
.Ladj1000:
    movw $13, %ax
    ret
.Ladj101:
    movw $14, %ax
    ret
.Ladj11:
    cmpw $0x7564, %di
    jl .Ladj110
    jg .Ladj111
    movw $15, %ax
    ret
.Ladj110:
    movw $16, %ax
    ret
.Ladj111:
    movw $17, %ax
    ret

# Bags are a bit more painful: 2 bytes are not enough to disambiguate, so I get 4.
# This is fine since the shortest bag names have 3 characters; I can treat the
# null char (0) as the 4th to complete a 4-byte value.
get_bagi:
    cmpl $0x6c6c6579, %edi
    jl .Lbag0
    jg .Lbag1
    movl $0, %eax
    ret
.Lbag0:
    cmpl $0x6567616d, %edi
    jl .Lbag00
    jg .Lbag01
    movl $1, %eax
    ret
.Lbag00:
    cmpl $0x61757161, %edi
    jl .Lbag000
    jg .Lbag001
    movl $2, %eax
    ret
.Lbag000:
    cmpl $0x616d6f74, %edi
    jl .Lbag0000
    jg .Lbag0001
    movl $3, %eax
    ret
.Lbag0000:
    cmpl $0x6e6174, %edi
    jl .Lbag00000
    movl $4, %eax
    ret
.Lbag00000:
    movl $5, %eax
    ret
.Lbag0001:
    movl $6, %eax
    ret
.Lbag001:
    cmpl $0x646c6f67, %edi
    jl .Lbag0010
    jg .Lbag0011
    movl $7, %eax
    ret
.Lbag0010:
    movl $8, %eax
    ret
.Lbag0011:
    movl $9, %eax
    ret
.Lbag01:
    cmpl $0x67696562, %edi
    jl .Lbag010
    jg .Lbag011
    movl $10, %eax
    ret
.Lbag010:
    cmpl $0x65756c62, %edi
    jl .Lbag0100
    jg .Lbag0101
    movl $11, %eax
    ret
.Lbag0100:
    movl $12, %eax
    ret
.Lbag0101:
    movl $13, %eax
    ret
.Lbag011:
    cmpl $0x69646e69, %edi
    jl .Lbag0110
    jg .Lbag0111
    movl $14, %eax
    ret
.Lbag0110:
    movl $15, %eax
    ret
.Lbag0111:
    movl $16, %eax
    ret
.Lbag1:
    cmpl $0x70727570, %edi
    jl .Lbag10
    jg .Lbag11
    movl $17, %eax
    ret
.Lbag10:
    cmpl $0x6e61726f, %edi
    jl .Lbag100
    jg .Lbag101
    movl $18, %eax
    ret
.Lbag100:
    cmpl $0x6d6c6173, %edi
    jl .Lbag1000
    jg .Lbag1001
    movl $19, %eax
    ret
.Lbag1000:
    cmpl $0x6d697263, %edi
    jl .Lbag10000
    movl $20, %eax
    ret
.Lbag10000:
    movl $21, %eax
    ret
.Lbag1001:
    movl $22, %eax
    ret
.Lbag101:
    cmpl $0x6e6f7262, %edi
    jl .Lbag1010
    jg .Lbag1011
    movl $23, %eax
    ret
.Lbag1010:
    movl $24, %eax
    ret
.Lbag1011:
    movl $25, %eax
    ret
.Lbag11:
    cmpl $0x76696c6f, %edi
    jl .Lbag110
    jg .Lbag111
    movl $26, %eax
    ret
.Lbag110:
    cmpl $0x72616863, %edi
    jl .Lbag1100
    jg .Lbag1101
    movl $27, %eax
    ret
.Lbag1100:
    movl $28, %eax
    ret
.Lbag1101:
    movl $29, %eax
    ret
.Lbag111:
    cmpl $0x776f7262, %edi
    jl .Lbag1110
    jg .Lbag1111
    movl $30, %eax
    ret
.Lbag1110:
    movl $31, %eax
    ret
.Lbag1111:
    movl $32, %eax
    ret

	.data
sbuf: .fill SBUF_SZ 
btable: .fill BAG_ARRAY_SIZE
