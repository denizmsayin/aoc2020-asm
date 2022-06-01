    .global quicksort_long

# TODO: Generic version. 
# Perform quick sort (3-way with median-of-3 for simplicity). Same signature as C's qsort.
# %rdi: array to sort
# %rsi: number of elements
# %rdx: size of each element
# %rcx: comparison function pointer int(*cmp)(const void *, const void *)

# Various binary search functions for primitives. 
# %rdi: array to sort
# %rsi: number of elements
quicksort_long:
    lea -8(%rdi, %rsi, 8), %rsi
    jmp qsort_long_rec
   
# %rdi: first pointer
# %rsi: last pointer
# puts median of three inside the last pointer
median_of_3_long:
    # use first + (last - first) / 2 to avoid overflow
    mov %rsi, %rcx
    sub %rdi, %rcx
    shr $1, %rcx
    add %rdi, %rcx # %rcx has mid now

    # load values lo, mid, hi
    
    mov (%rdi), %r8
    mov (%rcx), %r9
    # don't swap if A[mid] >= A[lo]
    cmp %r8, %r9
    jge .Lmidlo_l
    # swap A[lo] and A[mid]
    mov %r9, (%rdi) # A[lo] = midval
    mov %r8, (%rcx) # A[mid] = loval

.Lmidlo_l:
    mov (%rdi), %r8
    mov (%rsi), %r10
    # don't swap if A[hi] >= A[lo]
    cmp %r8, %r10
    jge .Lhilo_l
    # swap A[lo] and A[hi]
    mov %r10, (%rdi)
    mov %r8, (%rsi)

.Lhilo_l:
    mov (%rcx), %r9
    mov (%rsi), %r10
    # don't swap if A[mid] >= A[hi]
    cmp %r10, %r9
    jge .Lmidhi_l
    mov %r9, (%rsi)
    mov %r10, (%rcx)

.Lmidhi_l:
    ret
 
# %rdi: start pointer
# %rsi: end pointer
# -> %rax: start of equal region
# -> %rdx: start of greater region
partition3_long:
    call median_of_3_long

    mov (%rsi), %r8 # pivot value
    # use rdi as l
    mov %rdi, %rax # m
    mov %rsi, %rdx # r
    jmp .Lck_l

.Lloop_l:
    cmp %r8, (%rdi)
    jge .Lge_l 
    # *l < pivot, swap l and m and increment both
    mov (%rdi), %r9
    mov (%rax), %r10
    mov %r10, (%rdi)
    mov %r9, (%rax)
    add $8, %rdi
    add $8, %rax
    jmp .Lck_l
.Lge_l:
    je .Le_l
    # *l > pivot, swap l and r, decrement r
    mov (%rdi), %r9
    mov (%rdx), %r10
    mov %r10, (%rdi)
    mov %r9, (%rdx)
    sub $8, %rdx
    jmp .Lck_l
.Le_l:
    # *l == pivot, just increment l
    add $8, %rdi
.Lck_l:
    cmp %rdx, %rdi # while l <= r
    jle .Lloop_l

    # inc rdx by one before return
    add $8, %rdx
    ret

# %rdi: first pointer (f)
# %rsi: last pointer (l)
qsort_long_rec:
    cmp %rdi, %rsi
    jl .Lret_l # return if l < f
    lea 8(%rdi), %r8
    cmp %rsi, %r8 # continue if l != f + 1
    jne .Lcont_l
    # l == f + 1, special case for 2 elements
    mov (%rdi), %r8
    mov (%rsi), %r9
    cmp %r8, %r9
    jge .Lret_l # do nothing if *l >= *f
    # swap otherwise
    mov %r8, (%rsi)
    mov %r9, (%rdi)
.Lret_l:
    ret

.Lcont_l:
    # Main case with length > 2
    push %rdi
    push %rsi
    call partition3_long
    pop %rsi
    pop %rdi

    # %rdi = f, %rsi = l, %rax = e, %rdx = g
    push %rsi # save l and g for 2nd recursive call
    push %rdx
    lea -8(%rax), %rsi
    call qsort_long_rec # (f, e-1)
    pop %rdi
    pop %rsi
    jmp qsort_long_rec # (g, l) via tail call

