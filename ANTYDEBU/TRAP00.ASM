;Anty Debuger (TRAP00.ASM) napisany przez M$(1998).
;
;Opis :
; Zastawienie pulapki na pulapke.
; Po wykonaniu zmian w tablicy wektorow przerwan (zamaina wektorow przerwania
; 3h na przerwanie 19h), kazde zastawienie pulapki spowoduje reset komputera.


.model tiny
.code
org 100h
Start:

 xor dx,dx           ; kilka prostych operacji i pulapka wpadnie w pulapke(?)
 mov es,dx
 cli
 mov ax,es:64h
 mov word ptr es:0ch,ax
 mov ax,es:64h+2
 mov word ptr es:0ch+2,ax
 sti
 nop  ; jak postawisz pulapke na nopie to po tobie !!!
      ; a jak nie to wszystko bedzie ok...


 mov ah,4ch
 int 21h
End Start



