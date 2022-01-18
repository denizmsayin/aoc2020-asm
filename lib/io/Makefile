all: iolib.a slen_test putstr_test printi_test reader_test geti_test part2set_test getstr_test

iolib.a: getstr.o part2set.o getia.o geti.o printi.o reader.o putstr.o slen.o skipwhite.o
	ar rcs $@ $^

slen_test: slen_test.o slen.o

putstr.o: slen.o

putstr_test: putstr_test.o putstr.o slen.o

printi.o: putstr.o slen.o

printi_test: printi_test.o printi.o putstr.o slen.o

reader_test: reader_test.o reader.o printi.o putstr.o slen.o

geti.o: reader.o

geti_test: geti_test.o geti.o reader.o printi.o putstr.o slen.o

part2set_test: part2set_test.o part2set.o putstr.o slen.o

getstr.o: reader.o

getstr_test: getstr_test.o getstr.o reader.o printi.o putstr.o slen.o

skipwhite.o: reader.o

clean:
	rm -f *.o *_test
