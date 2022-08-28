;*******************
;*** MIRRORX.ASM *** 
;*******************
MirrorX PROC 
     mov  dx,0a000h      ;Bezpožrednio na ekranie 
     mov  ds,dx 
     mov  si,0 
     mov  cx,100 
     mov  bp,64000 
MirX: 
     push cx 
     mov  cx,320 
Zamien: 
     mov  al,ds:[si] 
     mov  dl,ds:[si][bp] 
     mov  ds:[si],dl 
     mov  ds:[si][bp],al 
     inc  si 
     loop Zamien 
     pop  cx 
     sub  bp,640 
     loop MirX 
     ret 
     ENDP 
