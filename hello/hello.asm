section .text
global _start
_start:
  mov edx,len
  mov ecx,msg
  mov ebx,1

  mov eax,4
  int 0x80

  xor ebx,ebx
  mov eax,1
  int 0x80

section .rodata

msg db 'Hello, World', 0xa

len   equ $ - msg

