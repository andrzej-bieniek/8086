model tiny
.data
 exec db 'MASZ.EXE',0
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

.code
 org 100h
 start:
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

  lea dx,exec
  push ds
  pop es
  lea bx,tablica
  mov al,0
  mov ah,4bh
  int 21h
  mov sp,oldsp
  mov ss,oldss
  mov ah,4ch
  int 21h
 end start
