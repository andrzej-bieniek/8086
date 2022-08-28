;*****************
;*** PRZEN.ASM *** 
;*****************
Przenikaj PROC 
        mov  dx,0a000h 
        mov  ds,dx 
        mov  dx,DATA 
        mov  es,dx 
        mov  si,0 
        mov  di,0 
        mov  cx,64000 
Draw: 
        mov  al,ds:[si]   ;Obrazek na ekranie
        add  al,es:[di]   ;Obrazek w segmencie DATA
        shr  al,1         ;Licz ûredniÜ
        mov  ds:[si],al   ;Postaw nowy punkt
        inc  si 
        inc  di 
        loop Draw         
        ret 
        ENDP 
DATA SEGMENT      ;Tu powinien znajdowaç sië jeden z obrazk¢w
obraz dw 32000 dup(0) 
DATA ENDS 
                                                 
