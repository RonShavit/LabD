zero: task0.asm
	nasm -f elf32 task0.asm -o task0.o
	gcc  -m32 -Wall -o task0 task0.o -lm -lc -dynamic-linker /lib/ld-linux.so.2



multi: 
	nasm -f elf32 multi.s -o multi.o
	gcc -m32 -Wall multi.o -o multi -lc -dynamic-linker /lib/ld-linux.so.2

clean:
	rm multi multi.o