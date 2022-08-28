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
   push bp
   mov bp,sp
   push bx
   mov bx,[bp+6]
   mov ax,bx

   pushf
   pop ax
   or ax,0100h
   mov bx,ax
   mov [bp+6],bx

   pop bx
   pop bp
   pop ax
   jmp dword ptr cs:[int21]
  trace21 EndP




 Begin:
  mov oldsp,sp
  mov oldss,ss
  mov ah,4ah
  mov bx,1b19h
  int 21h
  mov ax,0080h
  mov [pspo],ax
  mov [psps],ds
  mov ax,005Ch
  mov [fcb1o],ax
  mov [fcb1s],ds
  mov ax,006Ch
  mov [fcb2o],ax
  mov [fcb2s],ds


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

;  pushf
;  pop ax
;  or ax,0100h
;  push ax
;  push cs
;  push offset start
;  nop
;  iret

  lea dx,exec
  push ds
  pop es
  lea bx,tablica
  mov al,0
  mov ah,4bh
  int 21h




  mov ax,2521h
  mov dx,word ptr [int21]
  mov ds,word ptr [int21+2]
  int 21h


  mov sp,oldsp
  mov ss,oldss
  mov ah,4ch
  int 21h

 end start
