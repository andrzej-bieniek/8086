.model tiny
.code
  org 100h
  start:
   cli
   xor ax,ax
   mov ss,ax
   mov sp,7BFCh
   mov ax,9000h
   mov es,ax
   mov bx,0100h
   mov ax,0202h
   mov ch,0
   mov cl,2
   mov dh,0
   mov dl,0
   push es
   push bx
   sti
   int 13h
   retf

  end start



