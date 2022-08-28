;*******************
;*** TXT_SCR.ASM ***
;*******************

DSTACK SEGMENT STACK 'STACK'
db 10 dup('STACK');
DSTACK ENDS

ASSUME cs:CODE

CODE SEGMENT

Fname   db 'big.fnt',0   ;nazwa pliku z fontem
;Text scrolla:
Text    db  'Scroll w trybie tekstowym zrobiony na matrycy znakow       ',0
Znak    dw  0    ;numer aktualnego znaku w TEXT
Pznak   db  0    ;numer kolumny w aktualnym znaku

Start:
        call    LoadFONT   ;wczytaj font

        mov     ax,03h
        int     10h
        call    DrawMATRIX
MAIN:
        call    Opoz       ;dostosowanie do ekranu
        call    ShowSCROLL ;rysuj scrolla
        call    MoveSCROLL ;przesun tablicë SCROLL
        call    DrawZNAK   ;dorysuj kolejnÜ kolumnë
        
        mov     ah,01h
        int     16h
        jz      MAIN

        mov     ax,03h
        int     10h
        
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
        cmp     Pznak,3      ;Czy jesteûmy w znaku?
        ja      No_draw      ;Nie? - nic nie rysuj
                             ;Tak otrzymujemy odstëp miëdzy
                             ;znakami w scrollu
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
        ;DL i DH - ußywane do kontroli odpowiednich kolumn 
        ;znaku.
        mov     cl,Pznak        
        shl     cl,1
        mov     dl,10000000b 
        mov     dh,01000000b
        shr     dx,cl
        mov     cx,16
Draw_c:
        xor     bx,bx
        lodsb
        test    al,dl       ;Czy jest 1 punkt?
        jz      No1
        mov	bl,1
No1:
        test    al,dh       ;Czy jest 2 punkt?
        jz      No2
        mov	bh,1
No2:            
        mov     ax,bx
        stosw
        add     di,318
        loop    Draw_c                                  
No_draw:
        inc     Pznak
        cmp     Pznak,6     ;6 - opisuje odstëp miëdzy 
                            ;znakami
        jne     No_next
        mov     Pznak,0
        inc     Znak
No_next:
        ret
ENDP    
;*******************************************
;1.Przenieû FONT do NEWTXTFONT tak aby 
;  NEWTXTFONT byío matrycÜ fontu
;2.Zmie§ font

ShowSCROLL PROC
        push    cs
        push    cs
        pop     ds
        pop     es
        lea     si,SCROLL
        lea     di,NEWTXTFONT
        mov     cx,32*40
        xor     ax,ax
        rep     stosw
        lea     di,NEWTXTFONT
        mov     bx,0
        mov     dl,3
        mov     dh,11000000b
        mov     bp,15
        ;Przenieû SCROLL do NEWTXTFONT
Convert:
        mov     cx,320
Line:
        lodsb
        and     al,al        ;czy jest punkt?
        jz      No_pix
        or      es:[di][bx],dh    ;wstaw punkt do NEWTXTFONT
        or      es:[di][bx][1],dh ;wstaw punkt
No_pix:
        shr     dh,1
        shr     dh,1
        dec     dl
        jns     Ok_byte
        ;*
        mov     dh,11000000b
        mov     dl,3
        add     bx,16
        ;*
Ok_byte:
        loop    Line
        sub     bx,16*80
        inc     bx
        inc     bx
        cmp     bp,8
        jne     No_change
        mov     bx,80*16
No_change:      
        dec     bp
        jns     Convert
        ;Zmie§ font:
        mov     ah,11h
        mov     al,0h
        mov     bh,10h
        mov     bl,0
        mov     cx,160
        mov     dx,33
        push    cs
        pop     es
        lea     bp,NEWTXTFONT
        int     10h                     
        ret
ENDP            
;*******************************************
;Rysuj matrycë dla scrolla
;160 znak¢w od 33
DrawMATRIX PROC
        mov     dx,0b800h
        mov     es,dx
        mov     di,160*20
        mov     al,33
        mov     cx,160
Pisz:
        stosb
        inc     al
        inc     di
        loop    Pisz
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
NEWTXTFONT db 4096 dup(0)

CODE ENDS

END Start               