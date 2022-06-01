VPATH=$(shell find .. -type d)

all: algolib.a binsearch_test quicksort_test

algolib.a: binsearch.o quicksort.o
	ar rcs $@ $^

binsearch_test: binsearch_test.o binsearch.o iolib.a

quicksort_test: quicksort_test.o quicksort.o iolib.a

clean:
	rm -f *.o *_test
