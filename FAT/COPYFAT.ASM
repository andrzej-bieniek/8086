;Program (COPYFAT.ASM) napisany przez M$(1998).
;Opis:
; Program kopiujacy pierwsza tablice FAT do drugiej tablicy dyskietki 3,5"
; o pojemnosci 1,44MB.

.Model Tiny
.Data
 FAT_1 db 9*512 dup(0)

.Code
 Org 100h
 Start:
  mov ax,0209h
  mov cx,0002h
  xor dx,dx
  push ds
  pop es
  mov bx,Offset FAT_1
  int 13h
  mov ah,03h
  add cx,9h
  int 13h
  mov ah,4ch
  int 21h
 End Start




