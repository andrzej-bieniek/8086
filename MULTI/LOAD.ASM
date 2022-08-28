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
   mov ax,0203h
   mov ch,32
   mov cl,13
   mov dh,0
   mov dl,0
   push es
   push bx
   sti
   int 13h
   retf
   
  end start



