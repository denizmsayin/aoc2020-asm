    .global geti

    .extern peekc
    .extern advc

    .text
# Read int from stdin, return in %rax.
# Set CF if there are no more ints left.
geti:
    xor %r8, %r8 # use as accumulator
    clc # clear CF, used to signal no more input
    jmp .Lskipnext
 
    # First of all, skip stuff that is not digits or a minus sign
.Lskiploop:
    call advc
.Lskipnext:
    call peekc
    cmp $-1, %rax # No ints here!
    jne .Lnotend
    stc # set CF and return, no more input
    ret
.Lnotend:
    cmp $'-', %rax
    je .Lskipdone
    cmp $'+', %rax
    je .Lskipdone
    cmp $'0', %rax
    jl .Lskiploop    
    cmp $'9', %rax
    jg .Lskiploop
.Lskipdone:

    # Continue with a sign check
.Lexists:
    mov $1, %r9 # multiplier for final value
    cmp $'+', %rax
    je .Lsign
    cmp $'-', %rax
    jne .Lcheck
.Lnotminus:
    mov $-1, %r9
.Lsign:
    call advc
    jmp .Lnext

    # Loop for accumulating
.Lloop:
    imul $10, %r8
    sub $'0', %rax
    add %rax, %r8
    call advc # advance the pointer
.Lnext:
    call peekc # something like '0' <= c && c <= '9'
.Lcheck:    
    cmp $'0', %rax
    jl .Lout
    cmp $'9', %rax
    jg .Lout
    jmp .Lloop

.Lout:
    imul %r9, %r8 # sign multiplier
    mov %r8, %rax
    clc
    ret
