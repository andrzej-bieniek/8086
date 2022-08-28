;****************
;*** SOFT.ASM *** 
;****************
ASSUME cs:CODE 

CODE SEGMENT 
Seed      dw 1111h 
RndHi     dw ? 
RndLo     dw ? 

Start: 
     mov  ax,13h 
     int  10h 
     mov  bl,0
     call Set_pal 
     mov  cx,16000 
     mov  dx,0a000h 
     mov  es,dx 
     mov  rndhi,64000 
     mov  rndlo,0 
Set: 
     call Random 
     mov  di,ax 
     mov  byte ptr es:[di],50 
     loop Set 
     mov  cx,5 
S: 
     push cx 
     call Soft_screen
     pop  cx 
     loop S 
     mov  bl,0 
Rotuj: 
     push bx 
     call Set_pal 
     call Opoz 
     pop  bx 
     inc  bl 
     mov  ah,01h 
     int  16h 
     jz   Rotuj 
     mov  ax,3h 
     int  10h 
     mov  ax,4c01h 
     int  21h 
Opoz: 
     mov  dx,3dah 
Wai: 
     in  al,dx 
     test al,8 
     je  Wai 
     ret 
Set_pal: 
     mov  cx,254 
     mov  al,1 
Set_p: 
     mov  dx,3c8h 
     out  dx,al 
     inc  dx 
     xchg al,bl 
     out  dx,al 
     out  dx,al 
     out  dx,al 
     xchg al,bl 
     inc  bl 
     inc  al 
     loop Set_p 
     ret 
Random: 
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
;***************************************
;*** Procedura "rozmywajÜca" obrazek *** 
;*************************************** 
Soft_screen PROC
     mov  cx,64000  ;Iloûç "rozmywanych" punkt¢w
     mov  dx,0a000h ;"Rozmywanie" bezpoûrednio na ekranie
     mov  es,dx 
     mov  di,0 
     mov  dx,DATA ˇˇˇ  ;Segment ˇˇroboczy, ˇˇw ˇˇkt¢rym ˇˇbëdzie 
                        ;przechowywany obrazek
     mov  ds,dx 
     mov  si,0 
Soft: 
     mov  bx,0 
     mov  ax,0 
;--- Licz sumë intensywnoûci kolor¢w punkt¢w sÜsiednich --- 
;--- BX - suma ---
     mov  al,es:[di+1]      ;X+1
     cbw 
     add  bx,ax 
     mov  al,es:[di-1]      ;X-1
     cbw 
     add  bx,ax 
     mov  al,es:[di+320]    ;Y+1
     cbw 
     add  bx,ax 
     mov  al,es:[di-320]    ;Y-1
     cbw 
     add  bx,ax 
     mov  al,es:[di+321]    ;X+1 Y+1
     cbw 
     add  bx,ax 
     mov  al,es:[di+319]    ;X-1 Y+1
     cbw 
     add  bx,ax 
     mov  al,es:[di-321]    ;X-1 Y-1
     cbw 
     add  bx,ax 
     mov  al,es:[di-319]    ;X+1 Y-1
     cbw 
     add  bx,ax 
     inc  di 
     push cx 
     mov  cl,3 
     shr  bx,cl     ;Oblicz ûredniÜ arytmetyczÜ
     pop  cx 
     mov  ds:[si],bl     ;Zapamiëtaj punkt w segmencie roboczym
     inc  si 
     loop Soft 
     mov  dx,DATA 
     mov  ds,dx 
     mov  dx,0a000h 
     mov  es,dx 
     mov  si,0 
     mov  di,0 
     mov  cx,32000 
     rep  movsw          ;Przenieû zawartoûç segmentu roboczego 
                         ;na ekran
     ret 
     ENDP 

CODE ENDS 
DATA SEGMENT        ;Segment roboczy dla procedury SOFT_SCREEN 
Screen    dw 32000 dup(0) 
DATA ENDS 
END Start
