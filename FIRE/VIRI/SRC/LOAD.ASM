.model tiny
.code
  org 100h
  start:
;   cli
;   xor ax,ax
;   mov ss,ax
;   mov sp,7BFCh
;   sti

  repeat:
   mov ax,9000h
   mov es,ax
   mov bx,0100h
   mov ah,02h
   mov al,18
   mov ch,80
   mov cl,1
   mov dh,0
   mov dl,0
   int 13h
   jc repeat

   mov ax,cs
   mov es,ax
   lea bx,koniec 
   push es
   push bx

   mov ax,9000h
   mov es,ax
   mov bx,0100h
   push es
   push bx
   retf
  koniec:
   mov ah,4ch
   int 21h
  end start



