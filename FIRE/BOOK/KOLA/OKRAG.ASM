;*****************
;*** OKRèG.ASM ***
;***************** 
_dx     dw 0 
_dy     dw 0 
_dxy    dw 0 
_pdx    dw 0 
_pdy    dw 0 
 
color   db 63h      ;Kolor okrëgu
r       dw 99       ;Promie§ okrëgu
sx      dw 160      ;Wsp¢írzëdna X ûrodka okrëgu     
sy      dw 100      ;Wsp¢írzëdna Y ûrodka okrëgu
 
Circle PROC 
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
        ;Ten fragment stawia 8 punkt¢w
        mov  cx,sx 
        sub  cx,_pdx 
        mov  dx,sx 
        add  dx,_pdx 
        mov  bx,sy 
        add  bx,_pdy 
        shl  bx,1 
        mov  di,ds:[si][bx]
        add  di,dx 
        mov  es:[di],al ;1 punkt
        sub  di,dx 
        add  di,cx 
        mov  es:[di],al ;2 
        mov  bx,sy 
        sub  bx,_pdy 
        shl  bx,1 
        mov  di,ds:[si][bx] 
        add  di,dx 
        mov  es:[di],al ;3 
        sub  di,dx 
        add  di,cx 
        mov  es:[di],al ;4 
        mov  cx,sx 
        sub  cx,_pdy 
        mov  dx,sx 
        add  dx,_pdy 
        mov  bx,sy 
        add  bx,_pdx 
        shl  bx,1 
        mov  di,ds:[si][bx] 
        add  di,dx 
        mov  es:[di],al ;5 
        sub  di,dx 
        add  di,cx 
        mov  es:[di],al ;6 
        mov  bx,sy 
        sub  bx,_pdx 
        shl  bx,1 
        mov  di,ds:[si][bx] 
        add  di,dx 
        mov  es:[di],al ;7 
        sub  di,dx 
        add  di,cx 
        mov  es:[di],al ;8 
        ;------------------- 
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
