
%define	BUFSIZE	1024

global _start

SYS_EXIT equ 60
SYS_OPEN equ 2
SYS_READ equ 0

O_RDONLY equ 000000q

section .data
	inbetween_number_found db 0
	sequence_found db 0
	chars_fitting db 0
	chars_read dq 0

section .rodata
	magic_number dd 68020
	max_number dd 2147483647
	sequence dd 6, 8, 0, 2, 0


section .bss
	fd resq 1
	input_buf resb BUFSIZE
	output_buf resb BUFSIZE

section .text

exit_error:
	mov rax, SYS_EXIT
	mov rdi, 1
	syscall

exit_ok:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall

_start:
	cmp qword [rsp], 2
	jne exit_error
	mov rdi, [rsp + 16]
	call open_file
	xor r12d, r12d					;will keep the sum of all numbers
	xor r13d, r13d					;will keep the counter of numbers fitting the sequence, can be small
	call read_file
	jmp exit_ok

open_file:
  mov rax, SYS_OPEN
  mov rsi, O_RDONLY
  syscall
  cmp rax, 0							;check if file opened successfully
	jl exit_error
  mov qword [fd], rax			;save file descriptor
  ret

read_file:
	mov rax, SYS_READ
	mov rdi, qword [fd]
	mov rsi, input_buf
	mov rdx, BUFSIZE
	syscall
	cmp rax, 0
	jl exit_error 					;check if file was read successfully
	je done_reading
	mov qword [chars_read], rax
	xor r15, r15
	call test_mov
	;call write
	cmp qword [chars_read], BUFSIZE
	jl done_reading
	call read_file
	ret

find_inbetween_number:
	cmp byte [inbetween_number_found], 1		;check if inbeetween number already found
	je increment
	cmp eax, dword [max_number]							;check if number is less than 2^31
	jge increment
	mov byte [inbetween_number_found], 1		;mark that inbetween number was found
	jmp increment

check_sequence:
	cmp byte [sequence_found], 1					;check if sequence already found
	je increment
	inc r13d															;mark that additional number fits the sequence
	cmp r13d, 5														;check if entire sequence found
	jl increment
	mov byte [sequence_found], 1					;mark that sequence was found
	jmp increment

test_mov:
	mov eax, dword [input_buf + r15]			;read next number in buffer
	bswap eax
	add r12d, eax													;update sum of all numbers
	cmp eax, dword [magic_number]					
	je exit_error													;if magic number found, exit with error
	jg find_inbetween_number

sequence_check:	
	cmp eax, dword [sequence + r13d*4]
	je check_sequence
	cmp r13d, 0
	je increment
	xor r13d, r13d											;number not fitting, reset counter to 0
	jmp sequence_check

increment:
	add r15, 4													;increment index of next number in buffer
	cmp r15, qword [chars_read]					;check if there's more to read
	jl test_mov
	ret

done_reading:
	mov rax, qword [chars_read]				;check if the file is correct
	cqo 															;rax -> rdx:rax
	mov rbx, 4
	div rbx
	cmp rdx, 0
	jne exit_error
	cmp r12d, dword [magic_number]					;sum of all numbers mod 2^32 equals magic number
	jne exit_error
	cmp byte [inbetween_number_found], 1	;file includes a number between magic number and 2^32
	jne exit_error
	cmp byte [sequence_found], 1
	jne exit_error
	ret