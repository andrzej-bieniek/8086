;***************
;*** FLY.ASM ***
;***************
.286c
DSTACK SEGMENT 'STACK' STACK
db 30 dup('STACK');
DSTACK ENDS

ASSUME cs:CODE

CODE SEGMENT

Fname   db 'fly.dat',0    ;Tablica z obrazkiem samolotu
Pname   db 'fly.pal',0    ;Tablica z paletÜ
X       dw      130       ;Pozycja X samolotu
Y       dw      110       ;Pozycja Y samolotu
speed   dw      256       ;Prëdkoûç lotu

Start:
        call    LoadDATA
        mov     ax,13h
        int     10h
        call    SetPAL   ;Ustaw paletë
        call    InitTLO  ;policz tío
MAIN:
        call    DrawFLY  ;rysuj samolot
        call    DrawTLO  ;rysuj tío
        call    TestJOY  ;Sprawd¶ ruch joysticka
        call    Opoz
        mov     ah,01h
        int     16h
        jz      MAIN
        mov     ax,3
        int     10h
        mov     ah,08h
        int     21h
        mov     ax,4c01h
        int     21h
;******************************
;AX - X, BX - Y
TestJOY PROC
        mov     ah,84h
        mov     dx,1
        int     15h
        cmp     ax,50    ;Moßna zmieniç w zaleßnoûci
                         ;od parametr¢w joysticka
        ja      No_right
        cmp     X,5
        jb      No_right        
        dec     X
        dec     X
No_right:
        cmp     ax,200   ;Moßna zmieniç
        jb      No_left
        cmp     X,235
        ja      No_left
        inc     X
        inc     X
No_left:
        cmp     bx,10    ;Moßna zmieniç
        ja      No_speed_up
        cmp     speed,1000
        ja      No_speed_up
        add     speed,20
No_speed_up:
        cmp     bx,200   ;Moßna zmieniç
        jb      No_speed_down
        cmp     speed,256
        jb      No_speed_down
        sub     speed,20
No_speed_down:
        ret
ENDP                    
;******************************
;Dostosowanie do ekranu
Opoz PROC
        mov     dx,3dah
wai:
        in      al,dx
        test    al,8
        je      wai
        ret
ENDP    
;******************************
;Rusuj samolot od punktu (X,Y)
DrawFLY PROC
        mov     dx,0a000h
        mov     es,dx
        ;licz offset(X,Y)
        mov     ax,y
        mov     bx,320
        mul     bx
        add     ax,X
        mov     di,ax
        push    cs
        pop     ds
        lea     si,FLY
        mov     dx,81   ;Iloûç linii
Vloop:
        mov     cx,30   ;iloûç wierszy
        rep     movsw
        movsb
        add     di,259
        dec     dx
        jns     Vloop
        ret
        ENDP
;******************************
;Ustaw paletë
SetPAL PROC
        mov     dx,3c8h
        mov     al,0
        out     dx,al
        inc     dx
        mov     cx,768
        lea     si,PAL
        push    cs
        pop     ds
        rep     outsb
        ret
ENDP
;******************************
;Rysuj tío
;Punkt tía jest ûcierany, gdy ma kolor = 255
;Punkt tía jest rysowany tylko na pustym miejscu
;Unika sië w ten spos¢b "MiGania samolotu"
DrawTLO PROC
        mov     cx,40*20  ;Iloûç punkt¢w tía
        push    cs
        pop     ds
        lea     si,TLO
        mov     dx,0a000h
        mov     es,dx
        ;Policz przyrost
        ;przyrost := speed / 256 * 320
        mov     ax,speed
        mov     al,ah
        xor     ah,ah
        mov     bx,320
        mul     bx
        mov     dx,ax
Move:
        mov     di,ds:[si]
        mov     al,es:[di]
        ;czy jest to punkt tía, czy samolotu?
        cmp     al,255
        jne     NO_zero
        mov     byte ptr es:[di],0      
NO_zero:
        add     ds:[si],dx  ;przesu§ punkt
        ;i zobacz, czy nie wyszedí za ekran
        cmp     word ptr ds:[si],64000
        jb      OK_offset
        ;jak wyszedí, to go cofnij
        sub     word ptr ds:[si],64000
OK_offset:
        mov     di,ds:[si]
        mov     al,es:[di]
        ;czy jest to kolor 0?
        test    al,al
        jnz     NO_point
        ;Stawiaj punkt tía
        mov     byte ptr es:[di],255
NO_point:
        add     si,2
        loop    Move    
        ret
ENDP    
;******************************
;licz offsety kolejnych punkt¢w tía
;punkt¢w w linii jest 40
;linii jest 20
InitTLO PROC
        mov     dx,0
        push    cs
        pop     es
        lea     di,TLO
        mov     cx,20
IVLoop:
        push    dx
        mov     si,39
IHLoop:
        mov     es:[di],dx
        add     di,2
        add     dx,8
        dec     si
        jns     IHLoop
        pop     dx
        add     dx,10*320
        loop    IVLoop
        ret
ENDP    
;******************************
;Czytaj dane
LoadDATA PROC
        ;czytaj FLY.DAT
        mov     ah,3dh
        push    cs
        pop     ds
        lea     dx,Fname
        mov     al,0
        int     21h

        mov     bx,ax
        mov     ah,3fh
        lea     dx,FLY
        mov     cx,60*85
        int     21h

        mov     ah,3eh
        int     21h
        ;czytaj PAL.DAT
        mov     ah,3dh
        push    cs
        pop     ds
        lea     dx,Pname
        mov     al,0
        int     21h

        mov     bx,ax
        mov     ah,3fh
        lea     dx,PAL
        mov     cx,768
        int     21h

        mov     ah,3eh
        int     21h
        ret
ENDP            

FLY  db  60*85 dup(0)
PAL  db  786   dup(0)
TLO  dw  40*20 dup(0)
                
CODE ENDS

END Start