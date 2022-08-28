;******************
;*** RANDOM.ASM *** 
;******************
ASSUME cs:CODE 

CODE SEGMENT 

Seed      dw 1111h       ;Zmienna pomocnicza do generatora 
RndHi     dw ?           ;G¢rny zakres generowanych liczb 
RndLo     dw ?           ;Dolny zakres generowanych liczb 

Start: 
     mov  ax,13h 
     int  10h 
     mov  cx,32000       ;Iloûç losowa§ 
     mov  dx,0a000h 
     mov  es,dx 
     mov  RndHi,32000 
     mov  RndLo,0 
Set: 
     call Random 
     mov  di,ax 
     mov  byte ptr es:[di],63h 
     loop Set 
     mov  ah,08h 
     int  21h 
     mov  ax,3h 
     int  10h 
     mov  ax,4c01h 
     int  21h 
;************************************************
;*** Procedura generujÜca liczbë pseudolosowÜ *** 
;************************************************ 
Random PROC 
     mov  bx,seed 
     add  bx,9248h 
     ror  bx,1 
     ror  bx,1 
     ror  bx,1 
     mov  seed,bx 
     mov  ax,rndhi 
     sub  ax,rndlo 
     mul  bx 
     mov  ax,dx 
     add  ax,rndlo 
     ret 
     ENDP 
CODE ENDS 
END Start 
