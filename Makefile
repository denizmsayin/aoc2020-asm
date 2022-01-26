VPATH=$(shell find lib -type d)

all: day1 day2 day3 day4 day5 day6 day7 day8

day1: day1.o iolib.a

day2: day2.o iolib.a
	
day3: day3.o iolib.a

day4: day4.o iolib.a strlib.a

day5: day5.o iolib.a

day6: day6.o iolib.a strlib.a

day7: day7.o iolib.a strlib.a

day8: day8.o iolib.a
