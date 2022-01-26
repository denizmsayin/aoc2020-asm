    .global main

    .extern getstr
    .extern geti
    .extern printi

# To be able to 'run' the program, I need an internal representation.
# A 4-byte struct for each instruction: { short cmd_id, value; }
# At most 1024 instructions.

.set BYTES_PER_INSTR, 4
.set MAX_INSTRS, 1024
.set PROG_SIZE, BYTES_PER_INSTR * MAX_INSTRS
.set SBUF_SZ, 128

.set NOP_CODE, 0
.set JMP_CODE, 1
.set ACC_CODE, 2

fmt: .string "@\n"

main:

    # Read the program    
    lea program-4(%rip), %r13
.Lmoreinstrs:
    add $4, %r13
    mov %r13, %rdi
    call read_instr
    jnc .Lmoreinstrs

    # Execute the program while tracking executed instructions
    xor %r13, %r13
    xor %r14, %r14 # accumulator   
    xor %rax, %rax

.Lnext:
    # Check if current instruction is marked
    lea instr_execd(%rip), %rsi
    add %r13, %rsi
    cmpb $0, (%rsi) # Leave if marked
    jne .Lrepeated
    movb $1, (%rsi) # Mark otherwise

    # Interpret the instruction
    lea program(%rip), %rsi
    lea (%rsi, %r13, 4), %rsi
    movw (%rsi), %ax
    cmpw $NOP_CODE, %ax
    je .Lcont
    cmpw $JMP_CODE, %ax
    jne .Lacc
    # add offset to %r13
    movw 2(%rsi), %ax
    movsx %ax, %rax
    add %rax, %r13
    jmp .Lnext
.Lacc:
    movw 2(%rsi), %ax
    movsx %ax, %rax
    add %rax, %r14
.Lcont: 
    inc %r13
    jmp .Lnext

.Lrepeated:
    push %r14
    lea fmt(%rip), %rdi
    call printi
    add $8, %rsp

    ret

# %rdi: Address to read instruction into.
# Carry flag set if no more instructions left.
read_instr:
    push %r12 
    
    mov %rdi, %r12
    lea sbuf(%rip), %rdi
    mov $SBUF_SZ, %rsi
    call getstr

    test %rax, %rax # No line?
    jne .Lnotfin    
    stc
    pop %r12
    ret
.Lnotfin:
    movb sbuf(%rip), %al    
    cmpb $'n', %al
    jne .Lnotnop
    movw $NOP_CODE, (%r12)
    jmp .Linstrfound
.Lnotnop:
    cmpb $'j', %al
    jne .Lnotjmp
    movw $JMP_CODE, (%r12)
    jmp .Linstrfound
.Lnotjmp:
    movw $ACC_CODE, (%r12)

.Linstrfound:
    call geti
    movw %ax, 2(%r12)

    pop %r12
    clc
    ret

    .data
sbuf: .fill SBUF_SZ
program: .fill PROG_SIZE
instr_execd: .fill MAX_INSTRS
