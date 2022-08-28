;Program (CLEAR.ASM) napisany przez M$(1998).
;
;Opis:
; Program czysci dwie kopie fat dyskietki 3,5" 1,44MB.

.Model Tiny
.Data
 FAT_1   db 0F0h,0FFh,0FFh     ; Poczatek fat'u dyskietki
 Clear_1 db 4605 dup (00h)

 FAT_2   db 0F0h,0FFh,0FFh
 Clear_2 db 4605 dup (00h)
.Code
 Org 100h
 Start:
  mov ax,030Ch
  mov cx,0002h
  mov dx,0000h
  mov bx,Offset FAT_1
  int 13h
  mov ah,4ch
  int 21h
 End Start




