;*******************
;*** SCR&TLO.ASM ***
;*******************
.286c
DSTACK SEGMENT STACK 'STACK'
db 20 dup('STACK');
DSTACK ENDS

ASSUME cs:CODE

CODE SEGMENT
Tname   db 'tlo.sfg',0
Pname   db 'tlo.pal',0
Fname   db 'big.fnt',0   ;nazwa pliku z fontem
;Text scrolla:
Text    db  'Scroll nie scierajacy tla       ',0
Znak    dw  0    ;numer aktualnego znaku w TEXT
Pznak   db  0    ;numer kolumny w aktualnym znaku
color   db  123  ;kolor scrolla

ofs     dw  320*70   ;Aktualny offset scrolla
Dofs    dw  320      ;przyrost offsetu 

Start:
        call    LoadFONT   ;wczytaj font
        call    LoadTLO    ;wczytaj tío

        mov     ax,13h
        int     10h

        call    DrawTLO    ;narysuj tío
MAIN:
        call    Opoz       ;dostosowanie do ekranu
        call    ShowSCROLL ;rysuj scrolla
        call    MoveSCROLL ;przesun tablicë SCROLL
        call    DrawZNAK   ;dorysuj kolejnÜ kolumnë
        call    CH_ofs     ;zmie§ offset scrolla
        
        mov     ah,01h
        int     16h
        jz      MAIN

        mov     ah,08h
        int     21h
        mov     ax,4c01h
        int     21h
;*******************************************
;zmie§ offset scrolla: odbijaj go od g¢rnej
;i dolnej krawëdzi ekranu
CH_ofs PROC
        mov     dx,ofs
        add     dx,Dofs
        cmp     dx,0    
        ja      OK_dx1
        neg     Dofs
OK_dx1:
        cmp     dx,320*180
        jb      OK_dx2
        neg     Dofs
OK_dx2:
        mov     ofs,dx
        ret     
ENDP                    
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
;1. Przenieû tío to tablicy TOSCREEN
;2. Przenieû scrolla do TOSCREEN - tylko punkty <> 0
;3. Przenieû TOSCREEN na ekran
ShowSCROLL PROC
        ;przenieû tío do tablicy TOSCREEN
        push    cs
        pop     es
        lea     di,TOSCREEN
        mov     dx,STLO
        mov     ds,dx
        mov     si,offset TLO
        add     si,ofs
        mov     cx,160*18
        rep     movsw
        ;przenieû scrolla do TOSCREEN
        lea     di,TOSCREEN[320]
        push    cs
        pop     ds
        lea     si,scroll
        mov     cx,320*16
move:
        lodsb
        and     al,al
        jz      NO_POINT
        mov     es:[di],al
NO_POINT:
        inc     di
        dec     cx
        jns     move
        ;Przenieû TOSCREEN na ekran
        mov     dx,0a000h
        mov     es,dx
        mov     di,ofs
        push    cs
        pop     ds
        lea     si,TOSCREEN
        mov     cx,160*18
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
;*******************************************
;Wczytaj TLO i PAL
LoadTLO PROC
        ;tlo
        push    cs
        pop     ds
        lea     dx,Tname
        mov     ah,3dh
        mov     al,0
        int     21h

        mov     bx,ax
        mov     ah,3fh
        mov     cx,64000
        mov     dx,STLO
        mov     ds,dx
        lea     dx,TLO
        int     21h

        mov     ah,3eh
        int     21h
        
        ;paleta
        push    cs
        pop     ds
        lea     dx,Pname
        mov     ah,3dh
        mov     al,0
        int     21h

        mov     bx,ax
        mov     ah,3fh
        mov     cx,768
        mov     dx,STLO
        mov     ds,dx
        lea     dx,PAL
        int     21h

        mov     ah,3eh
        int     21h
        ret
ENDP
;*************************************
;Ustaw palete i rysuj tlo
DrawTLO PROC
        mov     dx,3c8h
        mov     al,0
        out     dx,al
        inc     dx
        mov     cx,768
        mov     bx,STLO
        mov     ds,bx
        mov     si,offset PAL
        rep     outsb
        lea     si,TLO
        mov     cx,32000
        mov     dx,0a000h
        mov     es,dx
        mov     di,0
        rep     movsw
        ret
ENDP    
FONT    db 4096 dup(?)
SCROLL  db 320*16 dup(0) 
TOSCREEN db 320*18 dup(0) ;Tablica pomocnicza do kopiowania
                          ;na ekran                       

CODE ENDS

STLO SEGMENT
TLO db 64000 dup(?)
PAL db 768 dup(?)
STLO ENDS

END Start               