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
   mov bx,109eh  ; ofset dla dos 5.00 - 6.22
   cmp ax,0500h
   jb NotWork
   cmp ax,0622h  ; sprawdzenie czy dos wyzszy niz 6.22
   jb ver622
   mov bx,0fb2h  ; ofset dla dos 7.xx
  ver622:
   push bx
   mov ah,52h
   int 21h       ; odczyt segmentu struktury Listy List
   pop bx
   cmp word ptr es:[bx],9090h ; sprawdzenie czy mozna zastosowac bezposrednie
   je ok
   cmp word ptr es:[bx],03ebh ; wywolanie
   jne NotWork
  ok:
   cmp byte ptr es:[bx+2],0e8h
   jne NotWork
   cmp word ptr es:[bx+5],0ff2eh
   jne NotWork
   cmp byte ptr es:[bx+7],02eh
   jne NotWork
   mov bx,word ptr es:[bx+8]    
   les bx,dword ptr es:[bx]   ; es:bx = adres oryginalnej procedury int 21h
   jmp Testowanie
  NotWork:
   mov ah,09h
   lea dx,msgNotWork      ; tuneling niemozliwy do zrealizowania
   int 21h   
   mov ax,4c01h           ; i zakonczenie dzialania programu
   int 21h

  Testowanie:
  
   mov word ptr Int21Addr[2],es     ; zapamietanie es:bx w zmiennej 
   mov word ptr Int21Addr,bx
 
   ; czyste wywolanie przerwania 21h

   mov ah,09h
   lea dx,tekst
   call Int21Addr
  
   mov ax,4c00h
   call Int21Addr
 
  end start


