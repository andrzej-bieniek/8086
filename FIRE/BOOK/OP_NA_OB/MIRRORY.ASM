;*******************
;*** MIRRORY.ASM *** 
;*******************
MirrorY PROC
     mov  dx,0a000h      ;Bezpoûrednio na ekranie 
     mov  ds,dx 
     mov  si,0 
     mov  cx,200         ;Ile linii odbiç 
MirY: 
     push cx 
     mov  cx,160 
     mov  bx,319 
Przestaw: 
     mov  al,ds:[si] 
     mov  dl,ds:[si][bx] 
     mov  ds:[si],dl 
     mov  ds:[si][bx],al 
     sub  bx,2 
     inc  si 
     loop Przestaw 
     add  si,160 
     pop  cx 
     loop MirY 
     ret 
     ENDP
