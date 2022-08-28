;*****************
;*** SKALA.ASM *** 
;*****************
Skala2 PROC 
        mov  dx,0a000h 
        mov  ds,dx 
        mov  si,0 
        mov  dx,DATA 
        mov  es,dx 
        lea  di,Obraz 
        mov  cx,100 
Sr: 
        push cx 
        mov  cx,160 
Go_sr: 
        ;Oblicz sumë punkt¢w sÜsiednich i ûredniÜ arytmetycznÜ 
        mov  al,ds:[si] 
        add  al,ds:[si+1] 
        add  al,ds:[si+320] 
        add  al,ds:[si+321] 
        shr  al,1 
        shr  al,1 
        ;Te cztery linie moßna usunÜç 
        ;ObrazujÜ one tylko to, co program robi z rysunkiem 
        mov  ds:[si],al     
        mov  ds:[si+1],al 
        mov  ds:[si+320],al 
        mov  ds:[si+321],al 
        stosb 
        add  si,2 
        loop Go_sr 
        pop  cx 
        add  si,320 
        loop Sr 
        ;Wyswietl zmniejszony obrazek  
        mov  dx,0a000h 
        mov  es,dx 
        mov  dx,DATA 
        mov  ds,dx 
        lea  si,Obraz 
        mov  di,0 
        mov  ax,0 
        mov  cx,32000 
        rep  stosw      ;Czyûç ekran 
        mov  cx,100 
        mov  di,16080 
Linia: 
        push cx 
        mov  cx,160 
        rep  movsb 
        pop  cx 
        add  di,160 
        loop Linia         
        ret 
        ENDP 
DATA SEGMENT            ;Tablica OBRAZ jest roboczÜ tablicÜ 
                        ;procedury SKALA2
Obraz  db 16000 dup(0) 
DATA ENDS 
