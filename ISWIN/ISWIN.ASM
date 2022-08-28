;Program (ISWIN.ASM) napisany przez M$(1998).
;Opis:
;
; Program wykrywa czy zostal uruchomiony w srodowisku windows.

.Model tiny
.Data
 Info1 db 10,'I`m in windows 95 enviroment...',13,10,'$'
 Info2 db 10,'I`m not in windows 95 enviroment...',13,10,'$'

.Code
  Org 100h

  Begin:
   mov ax,1600h          ; wywolanie odpowiedniej funkcji przerwania 2fh
   int 2fh
   cmp al,4
   jb NoWin                 ; jezeli al>4 to nie ma windows'a
   mov dx,offset Info1
   jmp Text
  NoWin:
   mov dx,offset Info2
  Text:
   mov ah,09h               ; wypisz odpowiednia informacje
   int 21h
   xor ax,ax
   int 16h                       ; i poczekaj na klawisz...
   ret
  End Begin


