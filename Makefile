VPATH=$(shell find lib -type d)

all: day1

day1: day1.o iolib.a
