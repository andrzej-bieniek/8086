;******************
;*** COPPER.ASM ***
;******************

ASSUME cs:CODE

CODE SEGMENT
_Ddi    dw      0  ;przyrost offsetu paska w fazie animacji
_Dsi    dw      6  ;przyrost offsetu gí¢wnego paska

Lewa    equ     30  ;Granica z lewej
Prawa   equ     280 ;Granica z prawej
 
Start:  
        mov     ax,13h
        int     10h
        ;Ustaw VGA na wyûwietlanie tylko pierwszego wiersza
        mov     dx,3d4h      
        mov     al,13h
        mov     ah,0
        out     dx,ax
        ;Ustaw paletë
        mov     cx,255
        mov     dx,3c8h
        mov     al,0
        out     dx,al
        inc     dx
        mov     bl,0
Set:
        mov     al,bl
        out     dx,al
        mov     al,0
        out     dx,al
        mov     al,bl
        out     dx,al
        inc     bl
        loop    Set

        mov     dx,0a000h
        mov     es,dx
        mov     si,80   ;PoczÜtkowy offset gí¢wnego paska
;********************************************************
MAIN:   
        ;Czekaj na powr¢t pionowy
        mov     dx,3dah
wai:
        in      al,dx
        test    al,8
        je      wai
        ;Czyûç pierwszÜ linië - kolejna faza
        mov     di,0
        mov     ax,0
        mov     cx,160
        rep     stosw
        ;Przesu§ pasek gí¢wny
        add     si,_dsi
        cmp     si,Prawa
        jb      oksi1
        neg     _dsi
oksi1:
        cmp     si,Lewa
        ja      oksi2
        neg     _dsi
oksi2:
        mov     cx,80   ;Iloûç linii animacji
        mov     di,si   ;Offset pask¢w w animacji DI = SI 
        mov     ax,_dsi
        mov     _ddi,ax
;*****************************
HERE:
        ;Przeczekaj 4 linie ekranu
        call    Linia
        call    Linia
        call    Linia
        call    Linia
        ;Nastëpny pasek
        add     di,_ddi
        cmp     di,Prawa
        jb      okdi1
        neg     _ddi
okdi1:
        cmp     di,Lewa
        ja      okdi2
        neg     _ddi
okdi2:
        ;Narysuj pasek
        mov     byte ptr es:[di+00],20
        mov     byte ptr es:[di+01],25
        mov     byte ptr es:[di+02],30
        mov     byte ptr es:[di+03],35
        mov     byte ptr es:[di+04],40
        mov     byte ptr es:[di+05],45
        mov     byte ptr es:[di+06],50
        mov     byte ptr es:[di+07],45
        mov     byte ptr es:[di+08],40
        mov     byte ptr es:[di+09],35
        mov     byte ptr es:[di+10],30
        mov     byte ptr es:[di+11],25
        mov     byte ptr es:[di+12],20
        
        loop    HERE
        mov     ah,01h
        int     16h
        jnz     KONIEC
        jmp     MAIN
Koniec:
        mov     ah,08h
        int     21h
        mov     ax,3
        int     10h
        mov     ax,4c01h
        int     21h
;************************************
;procedura czeka na zako§czenie linii
Linia PROC
        mov     dx,3dah
Lwai1:
        in      al,dx
        test    al,1
        je      Lwai1
Lwai2:
        in      al,dx
        test    al,1
        jne     Lwai2
        ret
ENDP
        
CODE ENDS

DSTACK SEGMENT 'STACK' STACK
db      32 dup('STACK');
DSTACK ENDS

END Start
        