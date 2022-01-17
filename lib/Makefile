all: slen_test putstr_test printi_test

slen_test: slen_test.s slen.o

putstr.o: slen.o

putstr_test: putstr_test.s putstr.o slen.o

printi.o : putstr.o slen.o

printi_test: printi_test.s printi.o putstr.o slen.o
