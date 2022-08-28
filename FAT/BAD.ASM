;Program (BAD.ASM) napisany przez M$(1998).
;
;Opis:
; Program na podstawie ofsetow z tablicy BadSec wpisuje do tablicy alokacji
; plikow dyskietki 3,5" 1,44MB dane o badsektorach.
; Efektem tego jest pomniejszenie pojemnosci dyskietki o 18412 bajtow oraz
; napis BAD utworzony przez badsektory, ktory mozna zobaczyc w dos scandisk'u.

.Model Tiny
.Data

 BadSec  dw 3h,0Ch,12h,1Bh,3Fh,5Dh,66h,6Ch,75h,150h,16Eh,186h,195h,1AAh,1C8h,0FFFh
         dw 9Ah,0A3h,0A9h,0B2h,0C7h,0E5h,0F4h,112h,1E4h,0FFFh
         dw 2h,11h,1Ah,20h,29h,2Fh,3Eh,5Ch,12Eh,137h,13Dh,146h,15Bh,179h,188h,191h,197h,1A0h,0FFFh
 Buffer  db 512 dup (0)
 Bad = 0FF7h

.Code

 Org 100h
 Start:

  xor si,si
  mov al,01h
  xor dx,dx
  mov cx,0002h
  mov bx,Offset Buffer

 Read:
  mov ah,02h
  int 13h

 ChangeData:
  mov di,BadSec[si]
  mov word ptr es:[bx+di],Bad
  inc si
  cmp BadSec[si],0FFFh
  jne ChangeData
  mov ah,03h
  int 13h
  inc cx
  cmp cx,5
  jne Read
  mov ah,4ch
  int 21h
 End Start



