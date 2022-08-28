.286C 
ASSUME cs:CODE 
 
CODE SEGMENT 
wsk_x      dw      14       
wsk_y      dw      14*28    
ile_ruchu  equ     145   ;Liczba opisuje rozmiar tabliy RUCH 
p_r        dw      0 
Start: 
        call    Graphics 
;******************************** 
MAIN:         
        call    Paleta_set 
        call    Opoz 
        call    Move 
         
        mov     ah,01h 
        int     16h 
        jz      MAIN 
;******************************** 
        mov     ah,08h 
        int     21h 
        mov     ax,3 
        int     10h 
        mov     ax,4c01h 
        int     21h 
;*************************************** 
;* Procedura zmieniajaca polozenie tla * 
;*************************************** 
Move PROC         
        mov     dx,DATA 
        mov     ds,dx 
        mov     bx,p_r 
        lea     si,Ruch[bx] 
        lodsb 
        cmp     al,1           ;1 - ruch w gore 
        jne     Dol 
        sub     wsk_y,28 
Dol: 
        cmp     al,5       ;5 - ruch w dol 
        jne     Prawo 
        add     wsk_y,28 
Prawo: 
        cmp     al,3           ;3 - ruch w prawo 
        jne     Lewo 
        add     wsk_x,1 
Lewo: 
        cmp     al,7           ;7 - ruch w lewo 
        jne     Gora_Prawo 
        sub     wsk_x,1 
Gora_prawo: 
        cmp     al,2           ;2 - ruch w gore i w prawo 
        jne     Dol_prawo 
        sub     wsk_y,28 
        add     wsk_x,1 
Dol_prawo: 
        cmp     al,4           ;4 - ruch w dol i w prawo 
        jne     Gora_lewo 
        add     wsk_y,28 
        add     wsk_x,1 
Gora_lewo:                 
        cmp     al,8           ;8 - ruch w gore i w lewo 
        jne     Dol_lewo 
        sub     wsk_y,28         
        sub     wsk_x,1 
Dol_lewo: 
        cmp     al,6           ;6 - ruch w dol i w lewo 
        jne     Koniec_tego 
        add     wsk_y,28 
        sub     wsk_x,1 
Koniec_tego: 
        inc     p_r            ;nasteepny kod ruchu 
        cmp     p_r,ile_ruchu 
        jne     ok_pr 
        mov     p_r,0 
ok_pr:         
        cmp     wsk_x,42       ;ograniczenie na przyrost X 
        jb      ok_wskx1 
        mov     wsk_x,28 
ok_wskx1: 
        cmp     wsk_Y,28*28    ;ograniczenie na przyrost Y 
        jb      ok_wsky1 
        mov     wsk_y,14*28 
ok_wsky1:                         
        cmp     wsk_x,27       ;ograniczenie na przyrost X 
        ja      ok_wskx2 
        mov     wsk_x,41 
ok_wskx2:         
        cmp     wsk_y,391      ;ograniczenie na przyrost Y 
        ja      ok_wsky2 
        mov     wsk_y,783 
ok_wsky2:                 
        ret 
        ENDP                 
;*************************************** 
Graphics PROC    
        mov     ax,13h 
        int     10h 
;Procedura rysuje tlo - uklad kwadratow o kolejnych  
;punktach w kolejnych kolorach 
        mov     cx,13 
        mov     bx,13+2880 
Wiersz: 
        push    cx 
        mov     cx,21 
        push    bx 
  D_w: 
        call    Rysuj     ;Rysuj kolejny kwadrat 
        add     bx,14 
        loop    D_w 
        pop     bx 
        add     bx,320*14 
        pop     cx 
        loop    Wiersz 
        ret 
 
Rysuj:   
        pusha                 
        mov     dx,0a000h 
        mov     es,dx 
        mov     di,bx 
        mov     cx,15 
        mov     al,1 
Linia: 
        push    cx 
        mov     cx,14 
  D_l: 
        stosb 
        inc     al 
        loop    D_l 
        add     di,306 
        pop     cx 
        loop    Linia 
        popa 
        ret         
ENDP                 
;******************************** 
ofs_tab dw      0 
Paleta_set PROC 
;Procedure ustawia palete tak, aby z rysunku na ekranie  
;powstala kolejna faza ruchu tla 
        mov     dx,DATA 
        mov     ds,dx 
        mov     cx,14 
        mov     bx,0 
        add     bx,wsk_x   ;Korekta wzgledem przesuniecia X 
        add     bx,wsk_y   ;i Y 
        mov     al,1 
        mov     dx,3c8h 
        out     dx,al   ;Ustaw na kolor 1 
        inc     dx 
Set_pal:         
        add     bx,28 
        lea     si,Pal[bx] ; Tablica kolorow 
        push    cx 
        mov     cx,14 
 Paletka:         
        lodsb 
        shl     al,1 
        out     dx,al 
        out     dx,al 
        out     dx,al 
        loop    Paletka 
        pop     cx 
        loop    Set_pal 
        ret 
        ENDP         
;*********************************** 
Opoz PROC 
        mov     dx,3dah 
Wai: 
        in      al,dx 
        test    al,8 
        je      Wai 
        ret 
        ENDP 
 
CODE ENDS 
                      
DATA SEGMENT 
;Tablica kolorow - nieco "wyciagnieta" w gore i w 
;dol, zeby uniknac sprawdzania czy przy przesuwaniu 
;program wyszedl poza tablice. 
db      0 ,1 ,2 ,3 ,4 ,5 ,6 ,7 ,6 ,5 ,4 ,3 ,2 ,1 
db      0 ,1 ,2 ,3 ,4 ,5 ,6 ,7 ,6 ,5 ,4 ,3 ,2 ,1         
db      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,7 ,6 ,5 ,4 ,3 ,2 
db      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,7 ,6 ,5 ,4 ,3 ,2         
db      2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,8 ,7 ,6 ,5 ,4 ,3 
db      2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,8 ,7 ,6 ,5 ,4 ,3         
db      3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,9 ,8 ,7 ,6 ,5 ,4 
db      3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,9 ,8 ,7 ,6 ,5 ,4         
db      4 ,5 ,6 ,7 ,8 ,9 ,10,11,10,9 ,8 ,7 ,6 ,5 
db      4 ,5 ,6 ,7 ,8 ,9 ,10,11,10,9 ,8 ,7 ,6 ,5         
db      5 ,6 ,7 ,8 ,9 ,10,11,12,11,10,9 ,8, 7, 6 
db      5 ,6 ,7 ,8 ,9 ,10,11,12,11,10,9 ,8, 7, 6         
db      6 ,7 ,8 ,9 ,10,11,12,13,12,11,10,9 ,8 ,7 
db      6 ,7 ,8 ,9 ,10,11,12,13,12,11,10,9 ,8 ,7         
db      7 ,8 ,9 ,10,11,12,13,14,13,12,11,10,9 ,8 
db      7 ,8 ,9 ,10,11,12,13,14,13,12,11,10,9 ,8         
db      6 ,7 ,8 ,9 ,10,11,12,13,12,11,10,9 ,8 ,7 
db      6 ,7 ,8 ,9 ,10,11,12,13,12,11,10,9 ,8 ,7         
db      5 ,6 ,7 ,8 ,9 ,10,11,12,11,10,9 ,8, 7, 6 
db      5 ,6 ,7 ,8 ,9 ,10,11,12,11,10,9 ,8, 7, 6         
db      4 ,5 ,6 ,7 ,8 ,9 ,10,11,10,9 ,8 ,7 ,6 ,5 
db      4 ,5 ,6 ,7 ,8 ,9 ,10,11,10,9 ,8 ,7 ,6 ,5         
db      3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,9 ,8 ,7 ,6 ,5 ,4 
db      3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,9 ,8 ,7 ,6 ,5 ,4         
db      2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,8 ,7 ,6 ,5 ,4 ,3 
db      2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,8 ,7 ,6 ,5 ,4 ,3         
db      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,7 ,6 ,5 ,4 ,3 ,2 
db      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,7 ,6 ,5 ,4 ,3 ,2         
Pal     db      0 ,1 ,2 ,3 ,4 ,5 ,6 ,7 ,6 ,5 ,4 ,3 ,2 ,1 
db      0 ,1 ,2 ,3 ,4 ,5 ,6 ,7 ,6 ,5 ,4 ,3 ,2 ,1         
db      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,7 ,6 ,5 ,4 ,3 ,2 
db      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,7 ,6 ,5 ,4 ,3 ,2         
db      2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,8 ,7 ,6 ,5 ,4 ,3 
db      2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,8 ,7 ,6 ,5 ,4 ,3         
db      3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,9 ,8 ,7 ,6 ,5 ,4 
db      3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,9 ,8 ,7 ,6 ,5 ,4         
db      4 ,5 ,6 ,7 ,8 ,9 ,10,11,10,9 ,8 ,7 ,6 ,5 
db      4 ,5 ,6 ,7 ,8 ,9 ,10,11,10,9 ,8 ,7 ,6 ,5         
db      5 ,6 ,7 ,8 ,9 ,10,11,12,11,10,9 ,8, 7, 6 
db      5 ,6 ,7 ,8 ,9 ,10,11,12,11,10,9 ,8, 7, 6         
db      6 ,7 ,8 ,9 ,10,11,12,13,12,11,10,9 ,8 ,7 
db      6 ,7 ,8 ,9 ,10,11,12,13,12,11,10,9 ,8 ,7         
db      7 ,8 ,9 ,10,11,12,13,14,13,12,11,10,9 ,8 
db      7 ,8 ,9 ,10,11,12,13,14,13,12,11,10,9 ,8         
db      6 ,7 ,8 ,9 ,10,11,12,13,12,11,10,9 ,8 ,7 
db      6 ,7 ,8 ,9 ,10,11,12,13,12,11,10,9 ,8 ,7         
db      5 ,6 ,7 ,8 ,9 ,10,11,12,11,10,9 ,8, 7, 6 
db      5 ,6 ,7 ,8 ,9 ,10,11,12,11,10,9 ,8, 7, 6         
db      4 ,5 ,6 ,7 ,8 ,9 ,10,11,10,9 ,8 ,7 ,6 ,5 
db      4 ,5 ,6 ,7 ,8 ,9 ,10,11,10,9 ,8 ,7 ,6 ,5         
db      3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,9 ,8 ,7 ,6 ,5 ,4 
db      3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,9 ,8 ,7 ,6 ,5 ,4         
db      2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,8 ,7 ,6 ,5 ,4 ,3 
db      2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,8 ,7 ,6 ,5 ,4 ,3         
db      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,7 ,6 ,5 ,4 ,3 ,2 
db      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,7 ,6 ,5 ,4 ,3 ,2         
 
rept 3 
db      0 ,1 ,2 ,3 ,4 ,5 ,6 ,7 ,6 ,5 ,4 ,3 ,2 ,1 
db      0 ,1 ,2 ,3 ,4 ,5 ,6 ,7 ,6 ,5 ,4 ,3 ,2 ,1         
db      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,7 ,6 ,5 ,4 ,3 ,2 
db      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,7 ,6 ,5 ,4 ,3 ,2         
db      2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,8 ,7 ,6 ,5 ,4 ,3 
db      2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,8 ,7 ,6 ,5 ,4 ,3         
db      3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,9 ,8 ,7 ,6 ,5 ,4 
db      3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,9 ,8 ,7 ,6 ,5 ,4         
db      4 ,5 ,6 ,7 ,8 ,9 ,10,11,10,9 ,8 ,7 ,6 ,5 
db      4 ,5 ,6 ,7 ,8 ,9 ,10,11,10,9 ,8 ,7 ,6 ,5         
db      5 ,6 ,7 ,8 ,9 ,10,11,12,11,10,9 ,8, 7, 6 
db      5 ,6 ,7 ,8 ,9 ,10,11,12,11,10,9 ,8, 7, 6         
db      6 ,7 ,8 ,9 ,10,11,12,13,12,11,10,9 ,8 ,7 
db      6 ,7 ,8 ,9 ,10,11,12,13,12,11,10,9 ,8 ,7         
db      7 ,8 ,9 ,10,11,12,13,14,13,12,11,10,9 ,8 
db      7 ,8 ,9 ,10,11,12,13,14,13,12,11,10,9 ,8         
db      6 ,7 ,8 ,9 ,10,11,12,13,12,11,10,9 ,8 ,7 
db      6 ,7 ,8 ,9 ,10,11,12,13,12,11,10,9 ,8 ,7         
db      5 ,6 ,7 ,8 ,9 ,10,11,12,11,10,9 ,8, 7, 6 
db      5 ,6 ,7 ,8 ,9 ,10,11,12,11,10,9 ,8, 7, 6         
db      4 ,5 ,6 ,7 ,8 ,9 ,10,11,10,9 ,8 ,7 ,6 ,5 
db      4 ,5 ,6 ,7 ,8 ,9 ,10,11,10,9 ,8 ,7 ,6 ,5         
db      3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,9 ,8 ,7 ,6 ,5 ,4 
db      3 ,4 ,5 ,6 ,7 ,8 ,9 ,10,9 ,8 ,7 ,6 ,5 ,4         
db      2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,8 ,7 ,6 ,5 ,4 ,3 
db      2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,8 ,7 ,6 ,5 ,4 ,3         
db      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,7 ,6 ,5 ,4 ,3 ,2 
db      1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,7 ,6 ,5 ,4 ,3 ,2         
endm 
;Tablica przyrostow. Liczby opisane sa w procedurze         
;MOVE, mozna je zmienic tak aby utworzyc inny tor ruchu. 
;Tor powinien byc zamkniety. 
Ruch db  1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 
     db  2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2 
     db  3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3 
     db  4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4 
     db  5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5 
     db  6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6 
     db  7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7 
     db  8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8 
DATA ENDS 
 
END Start   
