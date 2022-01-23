VPATH=$(shell find lib -type d)

all: day1 day2 day3 day4 day5

day1: day1.o iolib.a

day2: day2.o iolib.a
	
day3: day3.o iolib.a

day4: day4.o iolib.a strlib.a

day5: day5.o iolib.a
