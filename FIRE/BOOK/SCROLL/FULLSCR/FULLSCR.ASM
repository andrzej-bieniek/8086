;*******************
;*** FULLSCR.ASM ***
;*******************

DSTACK SEGMENT STACK 'STACK'
db 20 dup('STACK');
DSTACK ENDS

ASSUME cs:CODE

CODE SEGMENT

Fname   db 'big.fnt',0   ;nazwa pliku z fontem
;Text scrolla:
Text    db  'Scroll na caly ekran       ',0
Znak    dw  0    ;numer aktualnego znaku w TEXT
Pznak   db  0    ;numer kolumny w aktualnym znaku
LEN     equ 3    ;iloûç wyûwietle§ kaßdej linii
licz    db  LEN  ;licznik - iloûç wyûwietle§ kaßdej kolumny
color   db  15   ;kolor scrolla

Start:
        call    LoadFONT   ;wczytaj font

        mov     ax,13h
        int     10h
        ;* Zmie§ wysokoûç ekranu
        mov     dx,3d4h
        mov     al,9h
        out     dx,al
        inc     dx
        mov     al,23
        out     dx,al
        ;*z
MAIN:
        call    Opoz       ;dostosowanie do ekranu
        call    ShowSCROLL ;rysuj scrolla
        call    MoveSCROLL ;przesun tablicë SCROLL
        call    DrawZNAK   ;dorysuj kolejnÜ kolumnë
        
        mov     ah,01h
        int     16h
        jz      MAIN

        mov     ah,08h
        int     21h
        mov     ax,4c01h
        int     21h
;*******************************************
;Dostosowanie do ekranu
Opoz PROC
        mov     dx,3dah
wai:
        in      al,dx
        test    al,8
        je      wai
        ret
ENDP                    
;*******************************************
;Przesu§ tablicë SCROLL
MoveSCROLL PROC
        ;Najpierw wyczyûç pierwszÜ kolumnë,
        ;ßeby po przesuniëciu nie "wyszía" 
        ;z prawej strony
        push    cs
        pop     es
        lea     di,SCROLL
        mov     cx,16
        mov     ax,0
Clear:
        stosw
        add     di,318
        loop    Clear
        ;i dopiero teraz przesu§
        push    cs
        pop     ds
        lea     si,SCROLL[2]
        lea     di,SCROLL
        mov     cx,160*16-1
        rep     movsw
        ret
ENDP            
;*******************************************
;Dopisz kolumnë z prawej strony SCROLL
DrawZNAK PROC
        cmp     Pznak,8      ;Czy jesteûmy w znaku?
        ja      No_draw      ;Nie? - nic nie rysuj
                             ;wíaûnie tak otrzymujemy odstëp 
                             ;miëdzy znakami w scrollu
        mov     bx,Znak      ;Numer znaku
        mov     bl,Text[bx]  ;i sam kod znak
        and     bl,bl        ;Czy = 0
        jnz     Not_end      ;Jeûli nie to dalej,
        mov     Znak,0       ;a jeûli tak to od nowa
        jmp     DrawZNAK
Not_end:        
        ;policz offset znaku w FONT
        ;offset := kod znaku * 16
        xor     bh,bh        
        shl     bx,1
        shl     bx,1
        shl     bx,1
        shl     bx,1
        lea     si,FONT[bx]
        push    cs
        pop     ds
        push    cs
        pop     es
        lea     di,SCROLL[318]  ;ustaw sië na prawÜ kolumnë
        ;DL - ußywane do kontroli kolumny znaku
        mov     cl,Pznak        
        mov     dl,10000000b 
        shr     dl,cl
        mov     cx,16
Draw_c:
        xor     bx,bx
        lodsb
        test    al,dl       ;Czy jest punkt?
        jz      No1
        mov     bl,color
        mov     bh,color
No1:
        mov     ax,bx
        stosw
        add     di,318
        loop    Draw_c                                  
No_draw:
        dec     licz
        jns     No_next
        mov     licz,LEN    ;LEN - iloûç wyûwietle§ kaßdej
                            ;kolumny
        inc     Pznak
        cmp     Pznak,10    ;10 - opisuje odstëp miëdzy 
                            ;znakami
        jne     No_next
        mov     Pznak,0
        inc     Znak
No_next:
        ret
ENDP    
;*******************************************
;Narysuj SCROLL na ekranie
ShowSCROLL PROC
        push    cs
        pop     ds
        lea     si,SCROLL
        mov     dx,0a000h
        mov     es,dx
        mov     di,0
        mov     cx,160*16
        rep     movsw
        ret
ENDP            
;*******************************************
;Wczytaj font do FONT
LoadFONT PROC
        push    cs
        pop     ds
        lea     dx,Fname
        mov     ah,3dh
        mov     al,0
        int     21h

        mov     bx,ax
        mov     ah,3fh
        mov     cx,4096
        lea     dx,FONT
        int     21h

        mov     ah,3eh
        int     21h
        ret
ENDP

FONT    db 4096 dup(?)
SCROLL  db 320*16 dup(0)

CODE ENDS

END Start               