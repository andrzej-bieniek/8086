model tiny
.data
 exec db '02.COM',0
 tablica:
  Otoczenie dw 0
  pspo dw 0
  psps dw 0
  fcb1o dw 0
  fcb1s dw 0
  fcb2o dw 0
  fcb2s dw 0
  oldss dw 0
  oldsp dw 0
  int21 dd 0

.code
 org 100h
 start:
 jmp Begin


  trace proc
   push bp
   mov bp,sp
   push ds
   push bx
   mov ds,[bp+4]
   mov bx,[bp+2]
   cmp [bx],0b0e8h
   jne dalej
;   mov word ptr [bx],9090h
;   mov byte ptr [bx+2],90h
   dalej:

   push ax
   mov ax,0e45h
   int 10h
   pop ax

   pop bx
   pop ds
   pop bp
   iret
  trace EndP

  trace21 proc
   push ax
   pushf
   pop ax
   or ax,0100h
   push ax
   popf
   pop ax
   nop
   jmp dword ptr cs:[int21]
  trace21 EndP




 Begin:

  mov dx,offset trace
  push cs
  pop ds
  mov ax,2501h
  int 21h


  mov ax,3521h
  int 21h
  mov word ptr [int21],bx
  mov word ptr [int21+2],es

  mov ax,2521h
  push cs
  pop ds
  mov dx,offset trace21
  int 21h

   pushf
   pop ax
   or ax,0100h
   push ax
   popf
   nop

   nop
   nop

   mov ax,30h
   int 21h

   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop

  mov ax,2521h
  mov dx,word ptr [int21]
  mov ds,word ptr [int21+2]
  int 21h

  mov ah,4ch
  int 21h

 end start
