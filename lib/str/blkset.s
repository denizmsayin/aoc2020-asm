    .global blkset

# Same as memset in C. Highly unoptimized,
# will be optimized in case it becomes necessary.
# %rdi: target block pointer
# %rsi: %sil should hold byte to write
# %rdx: length of the block
blkset:
    jmp .Lck

.Lloop:
    movb %sil, (%rdi)
    inc %rdi
.Lck:
    dec %rdx
    jge .Lloop 

    ret
