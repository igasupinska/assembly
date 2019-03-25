global euron

section .bss

extern get_value        ;uint64_t get_value(uint64_t n);
extern put_value        ;void put_value(uint64_t n, uint64_t w);

section .text

;pop one value, if 0 on top
B:
  pop rax
  pop rbx
  cmp rbx, 0
  jne increment
  sub r12, rbx
  jmp process           ;no incrementation takes place

;pop value from stack
C:
  pop rax
  jmp increment

;duplicate top of stack
D:
  pop rax
  push rax
  push rax
  jmp increment

;change order of two top elements
E:
  pop rax
  pop rbx
  push rax
  push rbx
  jmp increment

G:
  mov rdi, r13
  call get_value
  push rax
  jmp increment

P:
  mov rdi, r13      ;euron id as 1st arg
  pop rsi           ;top of stack as 2nd arg
  call put_value
  jmp increment

S:
  jmp increment

multiply:
  pop rax
  pop rbx
  mul rbx             ;multiplies rax times rbx
  push rax
  jmp increment

sum:
  pop rax
  pop rbx
  add rax, rbx
  push rax
  jmp increment

negate:
  pop rax
  not rax
  add rax, 1
  push rax
  jmp increment

put_number:
  push r13
  jmp increment


choose_sign_command:
  cmp dl, "*"
  je multiply
  cmp dl, "+"
  je sum
  cmp dl, "-"
  je negate

choose_number_command:
  movzx rax, dl
  sub rax, 48              ;convert char to digit
  push rax
  jmp increment


choose_letter_command:
  cmp dl, "B"
  je B
  cmp dl, "C"
  je C
  cmp dl, "D"
  je D
  cmp dl, "E"
  je E
  cmp dl, "G"
  je G
  cmp dl, "P"
  je P
  cmp dl, "S"
  je S
  jmp increment

euron:
  push rbp
  mov rbp, rsp
  xor r12, r12            ;will keep index of current char
  mov r13, rdi            ;will store euron number
  mov r15, rsi

process:
  mov dl, byte [r15 + r12]
  cmp dl, 0               ;check if word ended
  je finish

check_if_sign:
  cmp dl, "-"             ;biggest of signs
  jle choose_sign_command

check_if_number:
  cmp dl, "9"
  jle choose_number_command

check_if_letter:
  cmp dl, "Z"
  jle choose_letter_command

check_if_n:
  cmp dl, "n"
  je put_number

increment:
  add r12, 1
  jmp process


finish:
  pop r14
  mov rax, r14          ;return the first number on stack
  mov rsp, rbp
  pop rbp
  ret