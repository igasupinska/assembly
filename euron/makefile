euron: euronmain.c euron.o functions.o
	gcc -o euron euronmain.c euron.o functions.o -no-pie -pthread

%.o: %.asm
	nasm -DN=2 -f elf64 -F dwarf -g $<

%.o: %.c
	gcc -c  $< -o $@