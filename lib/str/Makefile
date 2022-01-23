VPATH=$(shell find .. -type d)

all: strlib.a slen_test sskip_test ssplit_test stoi_test

strlib.a: ssplit.o sskip.o stoi.o slen.o
	ar rcs $@ $^

slen_test: slen_test.o slen.o

sskip_test: sskip_test.o sskip.o iolib.a

ssplit.o: sskip.o

ssplit_test: ssplit.o sskip.o iolib.a ssplit_test.o

stoi_test: stoi.o iolib.a

clean:
	rm -f *.o *_test
