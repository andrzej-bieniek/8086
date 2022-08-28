model tiny
.code
 org 100h
 start:
;   pushf
;   pop ax
;   or ax,0100h
;   push ax
;   popf
;   nop

  mov ax,0e08h
  int 10h
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop

  mov ah,4ch
  int 21h

 end start
