euron: euronmain.c euron.o functions.o
	gcc -o euron euronmain.c euron.o functions.o -pthread

%.o: %.asm
	nasm -DN=XXX -f elf64 -F dwarf -g $<

%.o: %.c
	gcc -c  $< -o $@