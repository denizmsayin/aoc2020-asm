
Is this suffering?

My own attempt at Advent of Code 2020 using x86_64 assembly, assembled with GAs.

For extra pain, I only use 64-bit Linux syscalls and disallow myself the use of the 
C standard library.

Executables contain both part 1 and part 2. 2 needs to be passed as the second argument to run 
part 2 of a day:
```bash
$ ./day2    # runs part 1
$ ./day2 1  # runs part 1
$ ./day2 2  # runs part 2
```

I did write some _code generators_ in other languages. So far:
- Used a mix of python and C to generate binary-search like comparison tables for hashing
    strings in day 7: the functions `get_adji` and `get_bagi`.
