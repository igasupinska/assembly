euron: euronmain.c euron.o
	gcc -o euron euronmain.c euron.o -pthread

%.o: %.asm
	nasm -DN=XXX -f elf64 -F dwarf -g $<