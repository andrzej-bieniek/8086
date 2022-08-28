;*****************
;*** FILL2.ASM *** 
;*****************
Xf   dw ? ;Wsp¢’rz‘dna X punktu pocz†tkowego 
Yf   dw ? ;Wsp¢’rz‘dna Y punktu pocz†tkowego 
Cf   db ? ;Kolor wype’niania 
Sfc  db ? ;Kolor ramki obiektu wype’nianego 

Fill PROC 
     mov  dx,0a000h      ;Wype’nianie bezpožrednio na ekranie 
     mov  ds,dx 
     mov  dx,DFILL 
     mov  es,dx 
     mov  ax,Yf 
     mov  cx,320 
     mul  cx 
     add  ax,Xf 
     mov  si,ax 
     mov  bx,0 
Paint: 
     call Oko 
     cmp  bx,0 
     je   End_of_fill 
     mov  bp,bx 
     shl  bp,1 
     mov  si,es:[bp] 
     dec  bx 
     dec  si 
     call Oko 
     add  si,2 
     call Oko 
     sub  si,321 
     call Oko 
     add  si,640 
     jmp  Paint 
End_of_fill: 
     ret 
     ENDP 
Oko PROC 
     mov  al,ds:[si] 
     cmp  al,Sfc 
     je   Wyskok 
     cmp  al,Cf 
     je   Wyskok 
     mov  al,Cf 
     mov  ds:[si],al 
     inc  bx 
     mov  bp,bx 
     shl  bp,1 
     mov  es:[bp],si 
Wyskok: 
     ret 
     ENDP
DFILL SEGMENT 
Tab  dw 32000 dup(0)          ;Obszar roboczy procedury FILL 
DFILL ENDS 
