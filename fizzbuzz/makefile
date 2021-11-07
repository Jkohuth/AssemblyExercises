#Assembly Makefile



.PHONY : start clean

all: a

a: fizzbuzz.o
	ld fizzbuzz.o

fizzbuzz.o: fizzbuzz.asm
	nasm -felf64 fizzbuzz.asm -o fizzbuzz.o


clean:
	rm -f *.o *.out
