;******************
;*** SIMPLE.ASM ***
;******************

DSTACK SEGMENT STACK 'STACK'
db 10 dup('STACK');
DSTACK ENDS

ASSUME cs:CODE

CODE SEGMENT

Wname   db 'wave.dat',0
Fname   db 'big.fnt',0   ;nazwa pliku z fontem
;Text scrolla:
Text    db  'Falujacy scroll z fontem uzytkownika       ',0
Znak    dw  0    ;numer aktualnego znaku w TEXT
Pznak   db  0    ;numer kolumny w aktualnym znaku
color   db  15   ;kolor scrolla

Start:
        call    LoadFONT   ;wczytaj font
        call    LoadWAVE   ;wczytaj dane do wyûwietlania
                           ;scrolla
        mov     ax,13h
        int     10h
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
        mov     bl,color
No1:
        test    al,dh       ;Czy jest 2 punkt?
        jz      No2
        mov     bh,color
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
;Narysuj SCROLL na ekranie
ShowSCROLL PROC
        push    cs
        pop     ds
        lea     si,SCROLL
        mov     bx,0
        mov     cx,320
        mov     dx,0a000h
        mov     es,dx
Kolumna:        
        mov     di,cs:WAVE[bx]  ;Wczytaj offset dla kolumny
        inc     bx
        inc     bx
        mov     dx,15
        push    si
DK:
        movsb
        add     si,319
        add     di,319
        dec     dx
        jns     DK
        pop     si
        inc     si
        loop    Kolumna                 
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
;*******************************************
;Wczytaj dane do WAVE
LoadWAVE PROC
        push    cs
        pop     ds
        lea     dx,Wname
        mov     ah,3dh
        mov     al,0
        int     21h

        mov     bx,ax
        mov     ah,3fh
        mov     cx,642
        lea     dx,WAVE
        int     21h

        mov     ah,3eh
        int     21h
        ret
ENDP

WAVE    dw 320 dup(0)
FONT    db 4096 dup(?)
SCROLL  db 320*16 dup(0)

CODE ENDS

END Start               