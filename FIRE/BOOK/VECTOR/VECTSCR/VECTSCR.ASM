.386c
DSTACK SEGMENT STACK 'STACK' use16
db 50 dup('STACK');
DSTACK ENDS

ASSUME cs:CODE 

CODE SEGMENT use16

include datafill.asm
lines       dw 200 dup(0)  ;tablica pomocnicza
                           ;dla procedury TRIAN

segofscreen equ SSCR
Fname       db 'font.d',0      ;Plik z opisem fontu
sname       db 'sinus.dat',0
cname       db 'cosinus.dat',0
Tname       db 'tlo.d',0       ;Plik zawierajÜcy tío

litera      db 0               ;Zmienna pomocnicza dla procedury
                               ;rysujÜcej literë. Zawiera kod 
                               ;znaku do narysuwania
odstep      equ 100            ;odstëp miëdzy literami
iler        equ 8              
kat         dw 0               ;zmienna pomocnicza - kÜt obrotu
ILE_ZNAKOW  equ 5              ;iloûç znak¢w do narysowania
DXL         dw 0               ;przesuniëcie wzglëdem X 
DYL         dw 0               ;przesuniëcie wzglëdem Y
TEXT        db 'SCROLL WEKTOROWY..............       $'
pTXT        db 10 dup(' ')     ;tablica pomocnicza                      
fx          dw 0               ;licznik przesuniëcia
gdzie       dw 0               ;pozycja wzglëdem TEXT
color       db 63
;******************************************************
Start:
        mov     ax,0dh
        int     10h
        call    Initlines      ;Przelicz offsety linii ekranu  
        call    LoadDATA       ;Wczytaj dane
        call    DrawTLO        ;Narusyj tío
        call    InitPAL

        ;**** Ustaw plane dla scrolla ****
        mov     dx,3c4h
        mov     al,02h
        mov     ah,00000100b
        out     dx,ax
        mov     dx,3ceh
        mov     al,07h
        mov     ah,00001011b
        out     dx,ax
        mov     fx,odstep
;****************************************************** 
MAIN:
        call    ClearScroll   ;Czyûç SCR
        call    DrawSCROLL    ;Rysuj scrolla w SCR
        call    ShowScroll    ;i przenieû na ekran

        ;**** Zwiëksz kÜt ****
        inc     kat
        cmp     kat,90
        jb      ok_kat
        mov     kat,0
ok_kat: 
        ;i przesu§ scrolla
        sub     FX,4
        jns     okFX
        mov     bx,odstep
        sub     bx,4
        mov     FX,bx
        call    NewLetter
okFX:   
        mov     ah,01h
        int     16h
        jz      MAIN
        
        mov     ah,08h
        int     21h
        mov     ax,3
        int     10h
        mov     ax,4c01h
        int     21h
;***************************************************
;Ustawienie palety tak aby kolor punktu z bitplane-u
;scrolla nie zaleßaí od punktu z bitplane-u tía
;***************************************************
InitPAL PROC
        ;Ustaw kolor jeûli punkt tía i scrolla sÜ "wíÜczone" 
        mov     dx,3c8h
        mov     al,00000101b
        out     dx,al
        inc     dx
        mov     al,color
        out     dx,al
        xor     al,al
        out     dx,al
        out     dx,al

        ;Ustaw kolor jeûli punkt scrolla jest "wíÜczony",
        ;a punkt tía nie.
        mov     al,00000100b
        dec     dx
        out     dx,al
        inc     dx
        mov     al,color
        out     dx,al
        xor     al,al
        out     dx,al
        out     dx,al

        ;Ustaw kolor tía
        dec     dx
        mov     al,00000001b
        out     dx,al
        inc     dx
        mov     al,10
        out     dx,al
        xor     al,al
        out     dx,al
        mov     al,30
        out     dx,al
        ret
        ENDP
;***************************************************
DrawTLO PROC
        mov     dx,STLO
        mov     ds,dx
        mov     dx,0a000h
        mov     es,dx
        mov     di,0
        mov     si,offset TLO
        mov     cx,10*200
        mov     dx,3c4h
        mov     al,02h
        mov     ah,00000001b
        out     dx,ax
        mov     dx,3ceh
        mov     al,07h
        mov     ah,00001110b
        out     dx,ax
        rep     movsd
        ret
        ENDP
;***************************************************
ClearScroll PROC
        mov     dx,SSCR
        mov     es,dx
        mov     di,0
        mov     cx,10*160
        xor     eax,eax
        rep     stosd
        ret
        ENDP    
;***************************************************
ShowScroll PROC
        ;Czekaj na powr¢t pionowy
        mov     dx,3dah
wai:
        in      al,dx
        test    al,8
        je      wai     
wai1:
        in      al,dx
        test    al,8
        jne     wai1    
        mov     dx,0a000h
        mov     es,dx
        mov     di,40*15
        mov     dx,SSCR
        mov     ds,dx
        mov     si,0
        mov     cx,10*160
        rep     movsd
        ret
        ENDP
;***************************************************
;Procedura dostawia kolejnÜ literë do tablicy pTXT
;***************************************************
NewLetter PROC
        mov     cx,10
        push    cs
        push    cs
        pop     ds
        pop     es
        ;Przesu§ tablicë pTXT
        lea     si,pTXT[1]
        lea     di,pTXT
        rep     movsb
        ;We¶ znak z TEXT
        mov     bx,gdzie  
        mov     al,cs:Text[bx]
        ;Sprawd¶, czy koniec tekstu
        cmp     al,'$'
        jne     OKZNAK
        mov     gdzie,0
        xor     bx,bx
        mov     al,cs:text[bx]
OKZNAK:
        mov     bx,ILE_ZNAKOW
        mov     cs:pTXT[bx],al
        inc     gdzie       ;nastëpny znak
        ret
        ENDP
;***************************************************
DrawSCROLL PROC 
        mov     bx,0   ;offset wzgl. pTXT
        mov     cx,ILE_ZNAKOW
        mov     dx,FX
        sub     dx,50  ;Korekcja wzglëdem X
RYSLIT:
        mov     al,cs:pTXT[bx]  ;wczytaj kod znaku
        mov     litera,al       
        inc     bx              ;nastëpny znak
        mov     DYL,80          ;przesuniëcie wzgl. Y
        mov     DXL,dx          ;przesuniëcie wzgl. X
        add     dx,odstep
        
        push    cx
        push    bx
        push    dx
        ;Ustal kÜt obrotu dla litery
        ;KÜt zaleßy od kodu znaku
        mov     di,kat
        push    di

        xor     dx,dx
        mov     dl,al
        add     kat,dx
        
one_more:       
        cmp     kat,90
        jb      ok_kat2
        ;odejmuj tak díugo, aß KAT < 90
        sub     kat,90
        jmp     one_more
ok_kat2:        
        ;Rysuj literë
        call    Dlitera
        pop     di
        mov     kat,di
        pop     dx
        pop     bx
        pop     cx
        loop    RYSLIT
        ret
        ENDP
;***************************************************
xp      dw      0
yp      dw      0
Dlitera PROC
        mov     bl,litera   ;BL = kod znaku
        xor     bh,bh
        ;licz offset wzglëdem FONT
        shl     bx,1    
        mov     dx,SFONT
        mov     ds,dx
        mov     bx,ds:[bx]
        and     bx,bx
        jnz     okBX
        ret
okBX:   
        mov     ax,ds:[bx]      ;iloûç punkt¢w
        mov     dx,ds:[bx][2]   ;iloûç tr¢jkÜt¢w
        dec     dx
        add     bx,4            ;ustaw BX na listë punkt¢w
        shl     ax,1            ;licz offset listy tr¢jkÜt¢w
        mov     bp,bx
        add     bp,ax           ;BP = offset trojkatow
Dtr:
        mov     al,ds:[bp]      ;Czytaj numer pkt.1
        xor     ah,ah
        mov     di,ax
        shl     di,1
        mov     al,ds:[bx][di]  ;X1
        xor     ah,ah
        cbw
        mov     xp,ax

        inc     di
        mov     al,ds:[bx][di]  ;Y1
        xor     ah,ah
        cbw
        mov     yp,ax

        call    RotateP         ;Policz obr¢t (X1,Y1)

        mov     ax,xp
        add     ax,DXL
        mov     x1,ax
        mov     ax,yp
        add     ax,DYL
        mov     y1,ax
        ;Analogicznie dla pozostaíych dw¢ch punkt¢w tr¢jkÜta:
        inc     bp
        mov     al,ds:[bp]     
        xor     ah,ah
        mov     di,ax
        shl     di,1
        mov     al,ds:[bx][di]   ;X2
        xor     ah,ah
        cbw
        mov     xp,ax

        inc     di
        mov     al,ds:[bx][di]   ;Y2
        xor     ah,ah
        cbw
        mov     yp,ax

        call    RotateP

        mov     ax,xp
        add     ax,DXL
        mov     x2,ax
        mov     ax,yp
        add     ax,DYL
        mov     y2,ax
        ;*****
        inc     bp
        mov     al,ds:[bp]
        xor     ah,ah
        mov     di,ax
        shl     di,1
        mov     al,ds:[bx][di]   ;X3
        xor     ah,ah
        cbw
        mov     xp,ax

        inc     di
        mov     al,ds:[bx][di]   ;Y3
        xor     ah,ah
        cbw
        mov     yp,ax

        call    RotateP

        mov     ax,xp
        add     ax,DXL
        mov     x3,ax
        mov     ax,yp
        add     ax,DYL
        mov     y3,ax
        ;*****
        inc     bp
        ;Po policzeniu wszystkiego rysuj tr¢jkÜt        
        pusha
        push    ds
        call    Trian
        pop     ds
        popa
                
        dec     dx
        js      Wyjscie
        jmp     DTR
Wyjscie:        
        ret
ENDP    
;****************************************************
;Procedura obraca punkt (XP,YP) o kÜt KAT.
;****************************************************
RotateP PROC    
        pusha
        push    ds
        push    es

        mov     dx,SCOS
        mov     ds,dx
        mov     dx,SSIN
        mov     es,dx
        mov     bp,kat
        mov     cl,9
        shl     bp,cl
        
        mov     cl,iler
        mov     bx,XP
        add     bx,127
        shl     bx,1
        add     bx,bp
        
        mov     di,YP
        add     di,127
        shl     di,1
        add     di,bp

        mov     ax,ds:[bx]
        add     ax,es:[di]
        mov     dx,ds:[di]
        sub     dx,es:[bx]
        
        sar     ax,cl
        sar     dx,cl
        
        mov     XP,ax
        mov     YP,dx

        pop     es
        pop     ds
        popa
        ret
        ENDP
;***************************************************
;Procedura czyta FONT, TLO, SIN, COS
;***************************************************
LoadDATA PROC
        mov     ah,3dh
        push    cs
        pop     ds
        lea     dx,Fname
        mov     al,0
        int     21h
        mov     bx,ax
        mov     ah,3fh
        mov     dx,SFONT
        mov     ds,dx
        mov     dx,offset FONT
        mov     cx,32000
        int     21h
        mov     ah,3eh
        int     21h
        ;***************************
        mov     ah,3dh
        push    cs
        pop     ds
        lea     dx,Sname
        mov     al,0
        int     21h
        mov     bx,ax
        mov     ah,3fh
        mov     dx,SSIN
        mov     ds,dx
        mov     dx,offset SIN
        mov     cx,49152
        int     21h
        mov     ah,3eh
        int     21h
        ;***************************
        mov     ah,3dh
        push    cs
        pop     ds
        lea     dx,Cname
        mov     al,0
        int     21h
        mov     bx,ax
        mov     ah,3fh
        mov     dx,SCOS
        mov     ds,dx
        mov     dx,offset COS
        mov     cx,49152
        int     21h
        mov     ah,3eh
        int     21h
        ;***************************
        mov     ah,3dh
        push    cs
        pop     ds
        lea     dx,Tname
        mov     al,0
        int     21h
        mov     bx,ax
        mov     ah,3fh
        mov     dx,STLO
        mov     ds,dx
        mov     dx,offset TLO
        mov     cx,40*200
        int     21h
        mov     ah,3eh
        int     21h
        ret
ENDP    
;******************************************************
InitLines PROC
        lea     si,Lines
        mov     ax,0
        mov     cx,200
IL:
        mov     cs:[si],ax
        add     si,2
        add     ax,40
        loop    Il
        ret
        ENDP                    
;*******************************************************
                
include tr0d.asm

CODE ENDS

SCOS SEGMENT use16
COS dw 32000 dup(?)
SCOS ENDS

SSIN SEGMENT use16
SIN dw 32000 dup(?)
SSIN ENDS

SSCR SEGMENT use16
SCR db 64000 dup(?)
SSCR ENDS

STLO SEGMENT use16
TLO db 40 * 200 dup(?)
STLO ENDS

SFONT SEGMENT use16
font db 64000 dup(?)
SFONT ENDS      

END Start