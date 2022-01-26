VPATH=$(shell find .. -type d)

all: algolib.a binsearch_test

algolib.a: binsearch.o
	ar rcs $@ $^

binsearch_test: binsearch_test.o binsearch.o iolib.a

clean:
	rm -f *.o *_test
