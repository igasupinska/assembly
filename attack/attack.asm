
%define	BUFSIZE	1024

global _start

SYS_EXIT equ 60
SYS_OPEN equ 2
SYS_READ equ 0

O_RDONLY equ 000000q

section .data
	found_inbetween_number db 0
	sequence_found db 0
	chars_fitting db 0
	sum dd 0
	chars_read dq 0

section .rodata
	msg2 db 'Found sequence!'
	magic_number dd 68020
	max_number dd 2147483647
	sequence dd 6, 8, 0, 2, 0
	;tu najlepiej trzymać sekwencję


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

	; call test_mov
	; call done_reading
	jmp exit_ok

;uważać, jakby plik się źle otworzył
open_file:
  mov rax, SYS_OPEN
  mov rsi, O_RDONLY         ;for read only access
  syscall
  cmp rax, 0
	jl exit_error 					;sprawdzanie, czy otwarcie pliku nie zakończyło się błędem
  mov qword [fd], rax
  ret

read_file:
	mov rax, SYS_READ
	mov rdi, qword [fd]
	mov rsi, input_buf
	mov rdx, BUFSIZE
	syscall
	cmp rax, 0
	jl exit_error
	je done_reading
	mov qword [chars_read], rax
	xor rdi, rdi
	call test_mov
	;call write
	call read_file
	ret

between:
	cmp byte [found_inbetween_number], 1
	je between_ret
	cmp eax, dword [max_number]
	jge between_ret
	mov byte [found_inbetween_number], 1
between_ret:
	jmp increment

check_sequence:
	cmp byte [sequence_found], 1
	je check_ret
	inc r13d
	cmp r13d, 5
	jl check_ret
	mov byte [sequence_found], 1
	call write
check_ret:
	jmp increment

test_mov:
	mov eax, dword [input_buf + rdi]
	bswap eax
	add r12d, eax 
	cmp eax, dword [magic_number]
	je exit_error												;if magic number found, exit with error
	jl sequence_check
	call between
sequence_check:	
	cmp eax, dword [sequence + r13d*4]
	je check_sequence
	xor r13d, r13d											;number not fitting, reset counter to 0
increment:
	add rdi, 4
	cmp rdi, qword [chars_read]
	jle test_mov
	ret

done_reading:
	cmp r12d, dword [magic_number]					;sum of all numbers mod 2^32 equals magic number
	jne exit_error
	cmp byte [found_inbetween_number], 1	;file includes a number between magic number and 2^32
	jne exit_error
	cmp byte [sequence_found], 1
	jne exit_error
	ret

write:
	mov rax, 1
	mov rdi, 1
	mov rsi, msg2
	mov rdx, 15
	syscall
	ret
