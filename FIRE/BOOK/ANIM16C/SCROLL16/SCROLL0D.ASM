
.286C 
ASSUME cs:CODE 
 
CODE SEGMENT 
 
Poz     dw      0 
Znak    dw      0 
ofs     dw      0 
Start: 
        mov     ax,0dh 
        int     10h 
MAIN: 
        call    Next_znak 
        call    Opoz 
        call    Rysuj 
         
        mov     ah,01h   
        int     16h 
        jz      MAIN 
         
        mov     ax,3h 
        int     10h 
        mov     ax,4c01h 
        int     21h 
;------------------------------------------------ 
Opoz PROC 
        mov     dx,3dah 
Wai: 
        in      al,dx 
        test    al,8 
        je      Wai 
        ret 
        ENDP                 
;--------------------------------------------- 
Przesun PROC 
        mov     dx,DATA 
        mov     es,dx 
        mov     ds,dx 
        lea     si,scroll 
        mov     di,si 
        mov     cx,14 
;Wyczysc dwie pierwsze kolumny.
Zeruj: 
        lodsb 
        and     al,00111111b 
        stosb 
        add     si,39 
        add     di,39 
        loop    Zeruj 
        lea     si,scroll 
        mov     di,si         
        mov     cx,40*14 
;******************************** 
;Przesuwaj bity w scrollu o dwa miejsca w lewo
Bytep: 
        lodsw                 ;Wczytaj slowo scrolla
        xchg    al,ah 
        shl     ax,1          ;Przesun w lewo
        shl     ax,1          ;Przesun w lewo
        mov     bl,ds:[si]    ;Wczytaj nastepny bajt scrolla
        rol     bl,1          ;Przesun w lewo
        rol     bl,1          ;Przesun w lewo
        and     bl,00000011b  ;Zostaw dwa skrajne bity 
        or      al,bl         ;I wstaw do pobranego slowa
        xchg    al,ah 
        stosw                 ;Zapamietaj
        loop    Bytep 
        ret 
        ENDP                    
;--------------------------------------------------------- 
Rysuj PROC 
        mov     dx,DATA 
        mov     ds,dx 
        mov     dx,0a000h 
        mov     es,dx 
        mov     di,0 
        mov     cx,13 
Ryss: 
        push    cx 
        push    di       
        lea     si,scroll 
        mov     cx,14*20 
        rep     movsw 
        pop     di 
        pop     cx 
        add     di,40*16 
        loop    Ryss 
        ret 
        ENDP         
;---------------------------------------------------------- 
Next_znak PROC 
        call    Przesun 
        call    Pisz_text 
        inc     poz 
        inc     poz 
        cmp     Poz,10 
        jb      Niet1 
        inc     Znak 
        mov     poz,0 
Niet1: 
        mov     bx,znak 
        lea     si,text[bx] 
        mov     dx,DATA 
        mov     ds,dx 
        lodsb 
        cmp     al,'$' 
        jne     Nie_kon 
        mov     znak,0 
nie_kon: 
        ret 
        ENDP         
;------------------------------------------------ 
Pisz_text PROC 
        cmp     poz,8 
        jb      Nie_znak 
        mov     dx,0 
        mov     bx,0 
        jmp     Tutaj 
Nie_znak:         
        mov     dx,DATA 
        mov     ds,dx 
        mov     bx,Znak 
        lea     si,text[bx] 
        lodsb 
        cbw 
        mov     bx,ax 
        mov     cl,4 
        shl     bx,cl 
        mov     ax,poz 
        shl     ax,1 
        add     bx,ax 
        lea     si,Fonty[bx] 
        lodsw 
        mov     dx,ax 
        lodsw 
        mov     bx,ax 
Tutaj:         
        call    Pisz_kolumne 
        ret 
        ENDP 
;-------------------------------------------------- 
Pisz_kolumne    PROC 
        mov     ax,DATA 
        mov     ds,ax 
        mov     es,ax 
        lea     di,scroll[39] 
        mov     si,di 
        mov     cx,14 
        mov     bp,0000000000000001b 
Rysuje: 
        xor     ah,ah 
        test    bx,bp 
        jz      No_pixel1 
        or      ah,00000001b 
No_Pixel1: 
        test    dx,bp 
        jz      No_pixel2 
        or      ah,00000010b         
No_pixel2:         
        lodsb 
        or      al,ah 
        stosb 
        shl     bp,1 
        add     di,39 
        add     si,39 
        loop    Rysuje 
        ret 
        ENDP                      
                                         
CODE ENDS 
 
DATA SEGMENT         
Scroll  db   2000 dup(0) 
 
INCLUDE FONT.ASM 
Text    db      'Scroll w trybie 16 kolorowym.......$' 

DATA ENDS 
 
END Start 
 
