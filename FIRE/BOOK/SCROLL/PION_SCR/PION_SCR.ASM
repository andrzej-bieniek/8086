;********************
;*** PION_SCR.ASM ***
;********************

DSTACK SEGMENT STACK 'STACK'
db 10 dup('STACK');
DSTACK ENDS

ASSUME cs:CODE

CODE SEGMENT

Fname   db 'big.fnt',0   ;nazwa pliku z fontem
;Text scrolla:
Text    db  'Scroll pionowy       ',0
Znak    dw  0    ;numer aktualnego znaku w TEXT
Pznak   dw  0    ;numer wiersza w aktualnym znaku
color   db  15   ;kolor scrolla

Start:
        call    LoadFONT   ;wczytaj font

        mov     ax,13h
        int     10h
MAIN:
        call    Opoz       ;dostosowanie do ekranu
        call    ShowSCROLL ;rysuj scrolla
        call    MoveSCROLL ;przesun tablicë SCROLL
        call    DrawZNAK   ;dorysuj kolejny wiersz
        
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
;Przesu§ tablicë SCROLL o linië w g¢rë
MoveSCROLL PROC
        push    cs
        push    cs
        pop     ds
        pop     es
        lea     si,SCROLL[8] ;linia 2
        lea     di,SCROLL    ;linia 1
        mov     cx,199*4
        ;przenoû z linii nastëpnej do aktualnej
        rep     movsw
        ;wyczyûç dolnÜ linië
        lea     di,SCROLL[199*8]
        xor     ax,ax
        stosw
        stosw
        stosw
        stosw
        ret
ENDP            
;*******************************************
;Dopisz kolumnë z prawej strony SCROLL
DrawZNAK PROC
        cmp     Pznak,15     ;Czy jesteûmy w znaku?
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
        ;dodaj numer linii
        add     si,Pznak
        push    cs
        pop     ds
        push    cs
        pop     es
        lea     di,SCROLL[199*8]  ;ustaw sië na dolnÜ linië
        
        mov     dl,10000000b      ;DL - kontrola punkt¢w
        xor     dh,dh
        mov     cx,8
        lodsb
        mov     ah,color
Draw_c:
        test    al,dl             ;Czy jest punkt?
        jz      No_point
        mov     es:[di],ah        ;Wstaw do scrolla
No_point:
        inc     di
        shr     dl,1    
        loop    Draw_c                                  
No_draw:
        inc     Pznak
        cmp     Pznak,17    ;17 - opisuje odstëp miëdzy 
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
        mov     dx,200
Linia:
        ;wyûwietl linië scrolla
        movsw
        movsw
        movsw
        movsw
        add     di,312 ;przejd¶ do nastëpnej linii
        dec     dx
        jns     Linia
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