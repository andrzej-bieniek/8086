;*******************
;*** NIESKON.ASM ***
;*******************

.286C
DSTACK SEGMENT 'STACK' STACK
db 20 dup('STACK')
DSTACK ENDS

ASSUME cs:CODE

CODE SEGMENT

Kname   db 'kulka.dat',0    
Pname   db 'nieskon.pal',0   
Tname   db 'trasa.dat',0

ile_krokow      equ 485-5    ;iloûç punkt¢w trasy - 5
Tsize           dw  1944     ;rozmiar pliku z trasÜ
sizeX           equ 6        ;Rozmiar X kulki / 4
sizeY           equ 17       ;Rozmiar Y kulki
;Tablica z numerami segment¢w dla kolejnych stron
;Tablica jest podw¢jna. Daje to moßliwoûç pominiëcia
;w programie sprawdzania, czy wyszío sië poza tablicë
segs            dw  0a000h,0a000h+1024,0a000h+2048,0a000h+3072
                dw  0a000h,0a000h+1024,0a000h+2048,0a000h+3072

Cpage           dw  0    ;Aktualna strona
;Zmienne dla procedury DrawKULKA:               
strona          dw  0    ;numer strony
X               dw  0    ;wsp. X
Y               dw  0    ;wsp. Y

pos             dw  0    ;aktualna pozycja na trasie
;*****************************
Start:
        call    LoadDATA
        call    Init
        call    UstawPAL
MAIN:
        call    Opoz
        call    ChangePAGE   ;Zmie§ stronë
        call    DrawFAZA     ;Dorysuj fazë animacji
        ;*Op¢¶nienie
        ;Moßna zmieniç wedíug wíasnych upodoba§
        mov     cx,0
        op:     loop op
        ;*
        ;Zmie§ numer aktualnej strony
        inc     Cpage
        inc     Cpage
        cmp     Cpage,8
        jne     OK_Cpage
        mov     Cpage,0
OK_Cpage:       
        mov     ah,01h
        int     16h
        jz      MAIN

        mov     ah,08h
        int     21h
        mov     ax,3
        int     10h
        mov     ax,4c01h
        int     21h
;***********************************
;Dostosowanie do ekranu
Opoz PROC
        mov     dx,3dah
wai:
        in      al,dx
        test    al,8
        je     wai
        ret
ENDP                    
;***********************************
DrawFAZA PROC
;Dorysuj fazë animacji.
;Faza skíada sië z 4 kolejnych kulek na kolejnych
;stronach poczÜwszy od Cpage
        cmp     pos,ile_krokow  ;Czu koniec trasy?
        jb      OK
        ret
OK:     
        mov     ax,Cpage
        inc     ax
        inc     ax
        mov     strona,ax
        mov     dx,STRASA
        mov     ds,dx
        mov     si,offset TRASA
        mov     bx,pos
        shl     bx,1
        shl     bx,1
        add     si,bx  ;SI - offset w TRASA
        mov     cx,4
Faza:
        lodsw          ;X kulki
        mov     X,ax
        lodsw          ;Y kulki
        mov     Y,ax
        push    ds
        push    si
        push    cx
        call    DrawKULKA
        pop     cx
        pop     si
        pop     ds
        inc     strona
        inc     strona
        loop    Faza
        inc     pos
        ret
ENDP            
;***********************************
;Zmie§ stronë (zmiana offsetu poczÜtku 
;wyûwietlanego obszaru)
ChangePAGE PROC
        mov     bx,Cpage
        mov     cl,13
        shl     bx,cl
        mov     dx,3d4h
        mov     al,0ch
        mov     ah,bh
        out     dx,ax
        inc     al
        mov     ah,bl
        out     dx,ax
        ret
ENDP    
;***********************************
;Rysuje kulkë na stronie STRONA w pkt. (X,Y)
;Kaßdy plane jest rysowany osobno.
planes  dw      80 dup (0102h,0202h,0402h,0802h)
ofs     dw      0
XX      dw      0
DrawKULKA PROC
        ;Pobierz segment dla strony STRONA
        mov     bx,strona
        mov     bx,cs:SEGS[bx]
        mov     es,bx
        ;DS:SI - kulka
        push    cs
        pop     ds
        lea     si,KULKA
        ;licz offset wzglëdem poczÜtku segmentu
        mov     ax,Y
        mov     bx,80
        mul     bx
        mov     ofs,ax
        mov     ax,X
        mov     XX,ax
        mov     cx,4
        mov     bp,X
        shl     bp,1
Draw_plane:
        mov     di,ofs
        ;Dodaj X div 4 (1 bajt = 4 punkty)
        mov     bx,XX
        shr     bx,1
        shr     bx,1
        inc     XX
        add     di,bx
        ;Czytaj ustawienie plane-¢w
        mov     ax,cs:planes[bp]
        inc     bp
        inc     bp
        mov     dx,3c4h
        out     dx,ax   ;ustaw plane-y
        push    cx
        mov     cx,sizeY
        push    si
        push    di
Dlinia: 
        push    di
        mov     dx,sizeX-1
Linia:  
        lodsb
        and     al,al      ;Czy jest punkt?
        jz      No_pix
        mov     es:[di],al
No_pix:
        inc     di      
        add     si,3
        dec     dx
        jns     Linia
        
        pop     di
        add     di,80
        loop    Dlinia
        pop     di
        pop     si
        inc     si
        pop     cx
        loop    Draw_Plane
        ret
ENDP    
;***********************************
;Ustawia paletë z PAL
UstawPAL PROC
        push    cs
        pop     ds
        lea     si,PAL
        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx
        mov     cx,768
        rep     outsb
        ret
ENDP            
;***********************************
LoadDATA PROC   
        ;czytaj KULKA
        push    cs
        pop     ds
        lea     dx,Kname
        mov     ah,3dh
        mov     al,0
        int     21h

        mov     bx,ax
        lea     dx,KULKA
        mov     cx,900
        mov     ah,3fh
        int     21h

        mov     ah,3eh
        int     21h
        ;czytaj TRASA
        push    cs
        pop     ds
        lea     dx,Tname
        mov     al,0
        mov     ah,3dh
        int     21h

        mov     bx,ax
        mov     cx,Tsize
        mov     dx,STRASA
        mov     ds,dx
        lea     dx,TRASA
        mov     ah,3fh
        int     21h

        mov     ah,3eh
        int     21h
        ;czytaj PAL
        push    cs
        pop     ds
        lea     dx,Pname
        mov     al,0
        mov     ah,3dh
        int     21h

        mov     bx,ax
        mov     cx,768
        lea     dx,PAL
        mov     ah,3fh
        int     21h

        mov     ah,3eh
        int     21h
        ret
ENDP    
;**********************************
include INIT.ASM

KULKA   db 900 dup(0)
PAL     db 768 dup(0)
CODE ENDS

STRASA SEGMENT
TRASA dw 16000 dup(?,?)
STRASA ENDS

END Start