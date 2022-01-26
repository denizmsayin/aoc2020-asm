    .global binsearch
    .global binsearch_long
    .global binsearch_word
    .global binsearch_short
   
# TODO: Generic version. 
# Perform binary search. Same signature as C's bsearch.
# %rdi: target key pointer
# %rsi: array to search in
# %rdx: number of elements
# %rcx: size of each element
# %r8: pointer to comparison function int (*cmp)(const void *, const void *)
   
# Various binary search functions for primitives. 
# %rdi: target key
# %rsi: array
# %rdx: number of elements 
# -> %rax: result index or -1

binsearch_long:
    xor %r8, %r8 # start
    jmp .Lbl_ck

.Lbl_loop:
    lea (%rdx, %r8), %rax # mid = start + end
    shr $1, %rax # mid >>= 1
    lea (%rsi, %rax, 8), %r10 # &array[mid]
    mov (%r10), %r10 # array[mid]
    cmp %rdi, %r10
    jl .Lbl_right # array[mid] < x, start = mid + 1
    jg .Lbl_left # x < array[mid], end = mid
    ret # Found!

.Lbl_right:
    lea 1(%rax), %r8
    jmp .Lbl_ck

.Lbl_left:
    mov %rax, %rdx

.Lbl_ck:
    cmp %rdx, %r8 # start < end?
    jl .Lbl_loop

    # Not found, return -1
    mov $-1, %rax
    ret

binsearch_word:
    xor %r8, %r8 # start
    jmp .Lbw_ck

.Lbw_loop:
    lea (%rdx, %r8), %rax # mid = start + end
    shr $1, %rax # mid >>= 1
    lea (%rsi, %rax, 4), %r10 # &array[mid]
    movl (%r10), %r10d # array[mid]
    cmpl %edi, %r10d
    jl .Lbw_right # array[mid] < x, start = mid + 1
    jg .Lbw_left # x < array[mid], end = mid
    ret # Found!

.Lbw_right:
    lea 1(%rax), %r8
    jmp .Lbw_ck

.Lbw_left:
    mov %rax, %rdx

.Lbw_ck:
    cmp %rdx, %r8 # start < end?
    jl .Lbw_loop

    # Not found, return -1
    mov $-1, %rax
    ret

binsearch_short:
    xor %r8, %r8 # start
    jmp .Lbs_ck

.Lbs_loop:
    lea (%rdx, %r8), %rax # mid = start + end
    shr $1, %rax # mid >>= 1
    lea (%rsi, %rax, 2), %r10 # &array[mid]
    movw (%r10), %r10w # array[mid]
    cmpw %di, %r10w
    jl .Lbs_right # array[mid] < x, start = mid + 1
    jg .Lbs_left # x < array[mid], end = mid
    ret # Found!

.Lbs_right:
    lea 1(%rax), %r8
    jmp .Lbs_ck

.Lbs_left:
    mov %rax, %rdx

.Lbs_ck:
    cmp %rdx, %r8 # start < end?
    jl .Lbs_loop

    # Not found, return -1
    mov $-1, %rax
    ret
