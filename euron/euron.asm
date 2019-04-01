global euron
global semaphores
global euron_top 

extern get_value          ;uint64_t get_value(uint64_t n);
extern put_value          ;void put_value(uint64_t n, uint64_t w);

section .bss
  semaphores  resb  N*N   ;0 - euron needs to wait, 1 - euron can proceed
  alignb 8
  euron_top   resq  N     ;keeps euron top value when synchronization happens

section .text
  align 8

;pop one value, if top != 0 change index in string
B:
  pop rax
  mov rbx, [rsp]          ;top of stack
  cmp rbx, 0
  je increment            ;0 on top, continue
  add r12, rax            ;update index in string to desired index - 1
  jmp increment           ;process the next char

;pop value from stack
C:
  pop rax
  jmp increment

;duplicate top of stack
D:
  mov rax, [rsp]          ;top of stack
  push rax                ;push top duplicate
  jmp increment           ;process the next char

;change order of two top elements
E:
  pop rax                 ;first on top
  pop rbx                 ;second on top
  push rax                ;push first
  push rbx                ;push second
  jmp increment           ;process next char

;invoke get_value and push result on top of stack
G:
  mov rdi, r13            ;put euron id into 1st arg register
  mov rbx, rsp
  and rsp, -16
  call get_value          ;invoke external function
  mov rsp, rbx
  push rax                ;push result
  jmp increment           ;process next char

;invoke push_value
P:
  mov rdi, r13            ;put euron id into 1st arg register
  pop rsi                 ;put popped value as 2nd arg
  mov rbx, rsp
  and rsp, -16
  call put_value          ;invoke external function
  mov rsp, rbx
  jmp increment           ;process next char

;synchronize with given euron
S:
  pop rax                  ;id of euron to synchronize with
  cmp rax, r13             ;synchronize with oneself
  je increment
  pop rcx                                   ;pop top of stack
  mov qword [euron_top + 8*r13], rcx        ;put popped value in array at index corresponding to euron id
  mov byte [semaphores + rax*N + r13], 1    ;let euron with id rax proceed
spin_lock:
  xor bl, bl
  xchg bl, byte [semaphores + r13*N + rax]  ;atomically exchange values of bl and current euron semaphore`
  test bl, bl
  jz spin_lock                              ;semaphore value was 0, wait
  push qword [euron_top + 8*rax]            ;push other euron's value
  xor bl, bl
  xchg bl, byte [semaphores + r13*N + rax]  ;mark that semaphore is closed
  jmp increment                             ;process next char

;pop two values, multiply them and push result
multiply:
  pop rax
  pop rbx
  mul rbx             ;multiply rax times rbx
  push rax            ;push result
  jmp increment

;pop two values, add them and push result
sum:
  pop rax
  pop rbx
  add rax, rbx        ;add rbx to rax
  push rax            ;push result
  jmp increment

;negate value on top of stack
negate:
  pop rax
  not rax
  add rax, 1
  push rax
  jmp increment

;push euron id
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
  movzx rax, dl            ;put dl in rax, converting byte to quadword with zero-extension
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
  push rbx
  push r12
  push r13
  push r14
  push r15
  xor r12, r12            ;will keep index of current char
  mov r13, rdi            ;will store euron number
  mov r15, rsi            ;will store pointer to input string

process:
  mov dl, byte [r15 + r12]  ;put next char to process in dl
  cmp dl, 0               ;check if word has ended
  je finish

check_if_sign:
  cmp dl, "-"             ;"-" is the sign with biggest ASCII code
  jle choose_sign_command

check_if_number:          ;"9" is the number with biggest ASCII code
  cmp dl, "9"
  jle choose_number_command

check_if_letter:
  cmp dl, "Z"             ;"Z" is the letter with biggest ASCII code
  jle choose_letter_command

check_if_n:
  cmp dl, "n"
  je put_number

increment:
  inc r12               ;increment index of char in string              
  jmp process           ;process next char

finish:
  pop r14
  mov rax, r14          ;return the first number on stack
  mov rsp, rbp
  sub rsp, 40           ;move stack pointer
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret