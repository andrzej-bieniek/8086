.model tiny

.data

;Text scrolla:
Text    db  '          Ten komputer jest teraz zainfekowany najnowszym wirusem HDDKILLER v9.99.  '
        db  ' W celu otrzymania AntyVirka trzeba sie skontaktowac ze szczecinska firma '
	 db  ' "VIRUSS FOOR JU" pod czestochowskim numerem telefonu: (032)202-22-03... Zycze milej pracy  :)                      ',0
	 
Znak    dw  0    ;numer aktualnego znaku w TEXT
Pznak   db  0    ;numer kolumny w aktualnym znaku
color   db  40   ;kolor scrolla

FONT:
include font.inc

SCROLL  db 320*16 dup(0)


.code

org 100h

Start:

        mov     ax,13h
        int     10h
MAIN:
        call    Pause       ;dostosowanie do ekranu
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

Pause Proc
                 push dx
                 push ax
                 mov     dx,03DAh
@@W4R1:          in      al,dx
                 test    al,8
                 jnz     @@W4R1
@@W4R2:          in      al,dx
                 test    al,8
                 jz      @@W4R2
                 pop ax
                 pop dx
                 ret

Pause endp


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
        mov     dx,0a000h
        mov     es,dx
        mov     di,320*80
        mov     cx,160*16
        rep     movsw
        ret
ENDP            




END Start               
