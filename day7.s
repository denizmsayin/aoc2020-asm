	.global main

	.extern getstr
	.extern geti
	.extern printi
    .extern peekc
    .extern skipstr
    .extern skipwhite
    .extern blkset
    .extern part2set
    .extern binsearch_word
    .extern binsearch_short
    
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
.set SHINY_GOLD_ID, 138
.set BAG_BYTE_SIZE, 20
.set BAG_ARRAY_SIZE, TOTAL_BAGS * BAG_BYTE_SIZE
.set SBUF_SZ, 128
.set NUM_ADJ_TYPES, 18
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

    push %r12

	movw sbuf(%rip), %di
	call get_adji
	mov %rax, %r12

	lea sbuf(%rip), %rdi
	mov $SBUF_SZ, %rsi
	call getstr

	movl sbuf(%rip), %edi
	call get_bagi
	mov %rax, %r9

	mov %r12, %rax
    mov %r12, %rdx
	imul $NUM_BAG_TYPES, %rax
	add %r9, %rax

    pop %r12
    clc
    ret

showi:	
    call get_next_bagi

    mov %rax, %r11
    imul $BAG_BYTE_SIZE, %r11
    push %r11
	push %rax
	push %r9
	push %rdx
	lea showi_fmt(%rip), %rdi
    call printi
    add $32, %rsp

    ret

# For adjectives, we can decide by interpreting the first
# two bytes only; as a word. 
get_adji:
    lea adj_values(%rip), %rsi
    mov $NUM_ADJ_TYPES, %rdx
    call binsearch_short
    ret

# Bags are a bit more painful: 2 bytes are not enough to disambiguate, so I get 4.
# This is fine since the shortest bag names have 3 characters; I can treat the
# null char (0) as the 4th to complete a 4-byte value.
get_bagi:
    lea bag_values(%rip), %rsi
    mov $NUM_BAG_TYPES, %rdx
    call binsearch_word
    ret

	.data
sbuf: .fill SBUF_SZ 
btable: .fill BAG_ARRAY_SIZE

adj_values:
    .word 0x6164
    .word 0x6166
    .word 0x6170
    .word 0x6177
    .word 0x6873
    .word 0x6964
    .word 0x696c
    .word 0x696d
    .word 0x6976
    .word 0x6c63
    .word 0x6c70
    .word 0x6f64
    .word 0x6f70
    .word 0x7262
    .word 0x7264
    .word 0x7473
    .word 0x7564
    .word 0x756d

bag_values:
    .long 0x00646572
    .long 0x006e6174
    .long 0x616d6f74
    .long 0x61726f63
    .long 0x61757161
    .long 0x63616c62
    .long 0x646c6f67
    .long 0x65657267
    .long 0x6567616d
    .long 0x656d696c
    .long 0x65756c62
    .long 0x6576616c
    .long 0x67696562
    .long 0x68637566
    .long 0x69646e69
    .long 0x6c616574
    .long 0x6c6c6579
    .long 0x6c6f6976
    .long 0x6d697263
    .long 0x6d6c6173
    .long 0x6d756c70
    .long 0x6e61726f
    .long 0x6e617963
    .long 0x6e6f7262
    .long 0x6f72616d
    .long 0x70727570
    .long 0x71727574
    .long 0x72616863
    .long 0x74696877
    .long 0x76696c6f
    .long 0x766c6973
    .long 0x776f7262
    .long 0x79617267

