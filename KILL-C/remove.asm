model tiny

.data
 bufor db 512 dup (0)
 nul db 8 dup (0)


.code
 org 100h
 
  begin:   
   jmp start

   obraz db 4096 dup (0)


  start:
   mov ax,440dh
   mov bx,0180h
   mov cx,084bh
   mov dx,offset nul
   int 21h            

   mov ax, 0201h                 
   mov bx, offset bufor
   mov cx, 0001h
   mov dx, 0080h
   int 13h

   cmp byte ptr [bufor + 1c2h], 00h
   jz endcode

  write:                            
   mov ax, 0301h
   mov cx, 0005h                     
   int 13h

   mov byte ptr [bufor + 1c2h], 00h    
   mov ax, 0301h
   mov cx, 0001h                     
   int 13h

  endcode:
    ret
 
 end begin





