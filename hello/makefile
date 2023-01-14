#Assembly Makefile



.PHONY : start clean

all: a

a: hello.o
	ld hello.o

hello.o: hello.asm
	nasm -felf64 hello.asm -o hello.o


clean:
	rm -f *.o *.out
