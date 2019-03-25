global euron

extern get_value, put_value

section .bss

section .text


B:
  jmp increment

;pop value from stack
C:
  pop rax
  jmp increment

;duplicate top of stack
D:
  pop rax
  push rax
  push rax
  push rax
  jmp increment

E:
  jmp increment

G:
  jmp increment

P:
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
  jmp increment

euron:
  push rbp
  mov rbp, rsp
  xor r12, r12            ;will keep index of current char

process:
  mov dl, [rsi + r12]
  cmp dl, 0               ;check if word ended
  je finish

check_if_sign:
  cmp dl, "-"         ;biggest of signs
  jle choose_sign_command

check_if_number:
  cmp dl, "9"
  jle choose_number_command

check_if_letter:
  cmp dl, "Z"
  jle choose_letter_command

check_if_n:
  cmp dl, "n"

increment:
  add r12, 1
  jmp process


finish:
  pop r13
  mov rax, r13          ;return the first number on stack
  mov rsp, rbp
  pop rbp
  ret