.286c 
ASSUME cs:CODE 
 
CODE SEGMENT 
        org     100h 
Start: 
        jmp     Install 
old9o   dw 0         ;Stary adres przerwania 9h
old9s   dw 0     
dw 'AA'              ;Do sprawadzania, czy juz zainstalowny
;******************************************* 
int9h: 
        pushf 
        call    dword ptr cs:old9o 
        pusha 
        push    es 
        push    ds 
        in      al,60h    ;Pobierz kod nacisnietego klawisza
        cmp     al,88     ;Jesli F12
        je      Okd       ;to wywolaj ZIUPKEY
        jmp     Wyskok    ;Jesli nie to koncz obsluge przerwania
Okd:     
        mov     bx,80*25                 
        mov     dx,3d4h   ;Ustaw offset drugiej strony
        mov     al,0ch 
        mov     ah,bh 
        out     dx,ax 
        inc     al 
        mov     ah,bl 
        out     dx,ax 
        ;*************************** 
        mov     dx,0b800h 
        mov     es,dx 
        push    cs 
        pop     ds 
        mov     di,160*25   ;Offset drugiej strony
        mov     cx,80*25 
        mov     al,' ' 
zero: 
        stosb 
        inc     di 
        loop    zero        ;Czysc druga strone
        mov     di,160*25        
        add     di,42 
        lea     si,ttx      ;Wyswietlany tekst
        mov     cx,24 
l: 
        push    cx 
        push    di       
        push    si 
        mov     cx,cs:llx   ;Dlugosc wyswietlanego tekstu
pisz: 
        lodsb 
        stosb 
        inc     di 
        loop    Pisz 
        pop     si 
        pop     di 
        add     di,160 
        pop     cx 
        loop    l        
        mov     dx,3d4h 
        mov     al,07h 
        out     dx,al 
        inc     dx 
        in      al,dx 
        and     al,11101111b ;Kasuj 8 bit rejestru
        out     dx,al        ;dzielenia obrazu (18h)
        dec     dx 
        mov     al,09h 
        out     dx,al 
        inc     dx 
        in      al,dx 
        and     al,10111111b  ;Kasuj 9 bit rejestru
        out     dx,al         ;dzielenia obrazu
         
        mov     cx,400        ;Ilosc linii do wysuniecia
        mov     bx,0          ;Licznik linii
;*****************************************************   
Move_offset1: 
        push    cx 
        mov     dx,3d4h 
        mov     al,18h 
        mov     ah,bl 
        out     dx,ax        ;Wysun kolejna linie
        call    Opoz         ;Dostosuj do ekranu
        add     bl,1         ;Nastepna linia
        jnc     ok_bity1  ;Jesli nie przeszlo zakresu to dalej
;*** Przeszlo zakres *** 
        mov     dx,3d4h 
        mov     al,07h 
        out     dx,al 
        inc     dx 
        or      al,00010000b   ;Ustaw bit 8 rejestru
        out     dx,al          ;dzielenia obrazu
ok_bity1:        
        pop     cx 
        loop    Move_offset1   ;Przesuwaj dalej
;**************************************************      
        mov     cx,401         ;Ilosc linii do wsuniecia
Move_offset2: 
        mov     dx,3d4h 
        mov     al,18h 
        mov     ah,bl 
        out     dx,ax          ;Wsun kolejna linie
        call    Opoz           ;Dostosuj do ekranu
        sub     bl,1           ;Nastepna linia
        jnb     ok_bity2       ;Jesli nie bylo pozyczki przy 
                               ;odejmowaniu to dalej
;*** Nastapila pozyczka ***
        mov     dx,3d4h 
        mov     al,07h 
        out     dx,al 
        inc     dx 
        and     al,11101111b ;Skasuj bit 8 rejestru podzielenia
        out     dx,al        ;obrazu
ok_bity2:        
        loop    Move_offset2 ;Nastepna linia
;**************************************************      
Wyskok: 
        pop     ds 
        pop     es       
        popa 
        iret                 ;Koniec przerwania
;****************************************************    
Opoz: 
        mov     dx,3dah 
w: 
        in      al,dx 
        test    al,8 
        je      w 
                 
        ret      
ttx     db      '    "A kuku - druga strona tekstu"'        
llx     dw      $-ttx 
Install: 
        mov     ax,3509h 
        int     21h       ;Pobierz adres przerwania 9h
        cmp     es:[bx-2],'AA'  ;Czy ZIUPKEY juz jest?
        je      Deinst          ;Jesli tak to deinstaluj
        mov     cs:old9o,bx     ;Zapamietaj stary
        mov     cs:old9s,es     ;adres obslugi przerwania
        push    cs 
        pop     ds 
        lea     dx,int9h        ;i ustaw nowy
        mov     ax,2509h        ;adres INT9h
        int     21h 
        push    cs 
        pop     ds 
        lea     dx,inst 
        mov     ah,09h 
        int     21h             ;Wypisz stosowny komunikat
        mov     dx,offset Install 
        int     27h             ;Wyjdz z programu
Deinst: 
        mov     dx,es:[bx-6]    ;Stary adres obslugi
        mov     ds,es:[bx-4]    ;przerwania 9h.
        mov     ax,2509h        ;Ustaw go na nowo
        int     21h 
        mov     ah,49h 
        int     21h             ;Zwolnij pamiec
        push    cs 
        pop     ds 
        lea     dx,dein 
        mov     ah,09h 
        int     21h             ;No i wyswietl komunikat
        mov     ax,4c01h 
        int     21h             ;Wyjdz z programu
inst    db      'ZIUPKEY zainstalowany.',13,10,'$' 
dein    db      'ZIUPKEY zdeinstalowany.',13,10,'$'      
CODE ENDS 
 
END Start        
 
