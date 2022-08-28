.model tiny
.data
 Int21Addr dd (0)
 tekst db 'Bezposrednie wywolanie przerwania 21h...$'
 msgNotWork db 'Tuneling przerwania 21h nie dziala...$'

.code
 org 100h
  start:
   mov ah,30h
   int 21h
   xchg al,ah
   mov bx,109eh
   cmp ax,0500h
   jb NotWork
   cmp ax,0622h
   jb ver622
   mov bx,0fb2h
  ver622:
   push bx
   mov ah,52h
   int 21h
   pop bx
   cmp word ptr es:[bx],9090h
   je ok
   cmp word ptr es:[bx],03ebh
   jne NotWork
  ok:
   cmp word ptr es:[bx+2],0e8h
   jne NotWork
   cmp word ptr es:[bx+5],0ff2eh
   jne NotWork
   cmp byte ptr es:[bx+7],02eh
   jne NotWork
   mov bx,word ptr es:[bx+8]
   les bx,dword ptr es:[bx]
  NotWork:
   mov ah,09h
   lea dx,msgNotWork





  
  mov ah,52h
  int 21h
  mov bx,0fb2h

  mov bx,word ptr es:[bx+8]
  les bx,dword ptr es:[bx]
  
  mov word ptr Int21Addr[2],es
  mov word ptr Int21Addr,bx
 
  mov ah,09h
  lea dx,tekst
  call Int21Addr
  
  mov ah,4ch
  call Int21Addr
 
 end start


