;****************
;*** KOúO.ASM *** 
;****************
_dx     dw 0 
_dy     dw 0 
_dxy    dw 0 
_pdx    dw 0 
_pdy    dw 0 
 
color   db 63h 
r       dw 99 
sx      dw 160 
sy      dw 100 
 
Disc PROC 
        pusha 
        push ds 
        push es 
        mov  dx,DATA 
        mov  ds,dx 
        mov  dx,0a000h 
        mov  es,dx 
        mov  _dx,0 
        mov  ax,r 
        mov  _pdx,ax 
        mov  _pdy,0 
        mov  al,color 
        lea  si,linie 
Rysuj: 
        mov  bx,_dx 
        add  bx,_pdy 
        add  bx,_pdy 
        inc  bx 
        mov  _dy,bx 
        mov  bx,_dy 
        sub  bx,_pdx 
        sub  bx,_pdx 
        inc  bx 
        mov  _dxy,bx 
        ;Punkty 
        mov  bp,sx 
        sub  bp,_pdx 
        mov  dx,sx 
        add  dx,_pdx 
        mov  bx,sy 
        add  bx,_pdy 
        shl  bx,1 
        mov  di,ds:[si][bx] 
        add  di,bp 
        mov  cx,_pdx 
        shl  cx,1 
        push cx 
        rep  stosb 
        pop  cx 
        mov  bx,sy 
        sub  bx,_pdy 
        shl  bx,1 
        mov  di,ds:[si][bx] 
        add  di,bp 
        rep  stosb 
        mov  dx,sx 
        add  dx,_pdy 
        mov  bp,sx 
        sub  bp,_pdy 
        mov  bx,sy 
        add  bx,_pdx 
        shl  bx,1 
        mov  di,ds:[si][bx] 
        add  di,bp 
        mov  cx,_pdy 
        shl  cx,1 
        push cx 
        rep  stosb 
        pop  cx 
        mov  bx,sy 
        sub  bx,_pdx 
        shl  bx,1 
        mov  di,ds:[si][bx] 
        add  di,bp 
        rep  stosb 
        mov  bx,_dx 
        xchg _dy,bx 
        mov  _dx,bx 
        inc  _pdy 
        mov  bx,_dxy 
        mov  bp,_dy 
        cmp  bx,0 
        jge  ok1 
        neg  bx 
ok1: 
        cmp  bp,0 
        jge  ok2 
        neg  bp 
ok2: 
        cmp  bx,bp 
        jae  ok3 
        mov  bx,_dxy 
        xchg bx,_dx 
        mov  _dxy,bx 
        dec  _pdx        
ok3:         
        mov  bx,_pdy 
        cmp  bx,_pdx 
        jg   Wyskok 
        jmp  Rysuj 
Wyskok:         
        pop  es 
        pop  ds 
        popa 
        ret 
        ENDP                         
DATA SEGMENT 
;**************************************************
;***** Tutaj umieûç zawartoûç pliku LINIE.ASM *****
;***** utworzonego za pomocÜ programu w Pascalu ***
;***** zamieszczonego na poczÜtku rozdziaíu *******
;**************************************************  
include LINIE.ASM
DATA ENDS 
