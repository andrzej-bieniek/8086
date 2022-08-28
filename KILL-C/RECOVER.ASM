model tiny

.data
 bufor db 512 dup (' ')

.code
 org 100h
 
  begin:   

 
   mov ax,440dh
   mov bx,0180h
   mov cx,084bh
   mov dx,offset Nul
   int 21h            

   xor cx,cx
   mov es,cx
   mov ax,word ptr es:[0Ch]
   mov word ptr es:04h,ax

   mov ax, 0201h                 
   mov bx, offset bufor
   mov cx, 0005h
   mov dx, 0080h
   int 13h
   jc endcode

   cmp byte ptr [bufor + 1c2h], 00h
   jz endcode

  write:                            
   mov ax, 0301h
   mov cx, 0001h                     
   int 13h

  endcode:
    ret
 
 end begin





