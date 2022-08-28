;Program (RESTART.ASM) napisany przez M$(1998).
;Opis:
;
; Program powoduje restart komputera bez testu pamieci.

.Model Tiny
.Code
 Org 100h

 Begin:
  xor ax,ax
  mov es,ax                         ; es = 0
  mov word ptr es:[0472h],1234h     ; [0000h:0472h]=1234h - bez testu pamieci
  db 0eah,0f0h,0ffh,000h,0f0h       ; jmp far f000h:0fffh
 End Begin






