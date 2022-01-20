VPATH=$(shell find lib -type d)

all: day1 day2 day3

day1: day1.o iolib.a

day2: day2.o iolib.a
	
day3: day3.o iolib.a
