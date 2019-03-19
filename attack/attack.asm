
%define	BUFSIZE	1024

global _start

SYS_EXIT equ 60
SYS_OPEN equ 2
SYS_READ equ 0

O_RDONLY equ 000000q

section .data
	found_inbetween_number db 0
	sequence_found db 0
	sum dd 0
	chars_read dq 0

section .rodata
	msg2 db 'Found in-between number'
	magic_number dd 68020
	max_number dd 2147483647
	sequence dd 6, 8, 0, 2, 0
	;tu najlepiej trzymać sekwencję


section .bss
	fd resb 1
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
	call read_file
	mov rdi, 0
	xor r8d, r8d
	call test_mov
	call done_reading
	jmp exit_ok

;uważać, jakby plik się źle otworzył
open_file:
  mov rax, SYS_OPEN
  mov rsi, O_RDONLY         ;for read only access
  syscall
  cmp rax, 0
	jl exit_error 					;sprawdzanie, czy otwarcie pliku nie zakończyło się błędem
  mov [fd], rax
  ret

read_file:
	mov rax, SYS_READ
	mov rdi, [fd]
	mov rsi, input_buf
	mov rdx, BUFSIZE
	syscall
	cmp rax, 0
	jl exit_error
	mov qword [chars_read], rax
	ret

between:
	cmp byte [found_inbetween_number], 1
	je between_ret
	cmp eax, dword [max_number]
	jge between_ret
	mov byte [found_inbetween_number], 1
between_ret:
	ret


test_mov:
	mov eax, dword [input_buf + rdi]
	bswap eax
	add r8d, eax 
	cmp eax, dword [magic_number]
	je exit_error												;if magic number found, exit with error
	jl increment
	call between
increment:
	add rdi, 4
	cmp rdi, qword [chars_read]
	jle test_mov
	ret

done_reading:
	cmp r8d, dword [magic_number]					;sum of all numbers mod 2^32 equals magic number
	jne exit_error
	cmp byte [found_inbetween_number], 1	;file includes a number between magic number and 2^32
	jne exit_error
	ret