;*******************
;*** PIC_ROT.ASM ***
;*******************

.286C
DSTACK SEGMENT 'STACK' STACK
db 30 dup('STACK');
DSTACK ENDS

ASSUME cs:CODE, ss:DSTACK

CODE SEGMENT

s1      db  'sin1.dat',0
s2      db  'sin2.dat',0
c1      db  'cos1.dat',0
c2      db  'cos2.dat',0
PICname db  'rotate.sfg',0
PALname db  'rotate.pal',0

kat     dw  0       ;K†t obrotu
dkat    dw  1       ;przyrost k†ta
X       dw  32768   ;Przesuni‘cie na X
Y       dw  0       ;Przesuni‘cie na Y
skala   dw  100    ;Skala
dskala  dw  20      ;przyrost skali

Start:
        call    LoadSINCOS  ;wczytaj tablice tryg.
        call    LoadPICPAL  ;wczytaj obrazek i palet‘
        mov     ax,13h
        int     10h
        call    SetPAL      ;ustaw palet‘
;**************************     
MAIN:
        call    DrawIMAGE   ;rysuj obrazek
        ;zwi‘ksz k†t
        mov     dx,dkat
        add     kat,dx
        ;zwi‘ksz Y
        add     Y,128
        ;zmie¤ skal‘
        mov     dx,dskala
        add     skala,dx
        cmp     skala,2000
        jbe     Ok_skala1
        neg     dskala
Ok_skala1:
        cmp     skala,4
        jae     Ok_skala2
        neg     dskala
OK_skala2:
        mov     ah,01h
        int     16h
        jz      MAIN
;**************************
        mov     ax,3
        int     10h
        mov     ah,08h
        int     21h
        mov     ax,4c01h
        int     21h     
;*********************************
;DDX,DDY - przyrost w prawo
ddx     dw      0
ddy     dw      0
;D2X,D2Y - przyrost w d¢’
d2x     dw      0
d2y     dw      0
;I,J punkt startowy
i       dw      0
j       dw      0
DrawIMAGE PROC
        ;licz DDX
        ;DDX := cos(kat)*skala
        mov     bx,kat
        xor     bh,bh
        shl     bx,1
        mov     cx,skala
        mov     si,256
        mov     ax,cs:COS1[bx]          
        imul    cx
        idiv    si
        mov     ddx,ax
        ;licz DDY
        ;DDY := sin(kat)*skala
        mov     ax,cs:SIN1[bx]
        imul    cx
        idiv    si
        mov     ddy,ax
        ;licz D2X
        ;D2X := cos(kat+pi/2)*skala
        mov     ax,cs:COS2[bx]
        imul    cx
        idiv    si
        mov     d2x,ax
        ;licz D2Y
        ;D2Y := sin(kat+pi/2)*skala
        mov     ax,cs:SIN2[bx]
        imul    cx
        idiv    si
        mov     d2y,ax
        
        ;licz I
        ;I := X - DDX * 160 - D2X * 100
        mov     ax,ddx
        mov     cx,160
        imul    cx
        mov     bx,ax
        mov     ax,d2x
        mov     cx,100
        imul    cx
        add     bx,ax
        mov     ax,X
        sub     ax,bx
        mov     I,ax

        ;licz J
        ;J := Y - DDY * 160 - D2Y * 100
        mov     ax,ddy
        mov     cx,160
        imul    cx
        mov     bx,ax
        mov     ax,d2y
        mov     cx,100
        imul    cx
        add     bx,ax
        mov     ax,Y
        sub     ax,bx
        mov     J,ax

        ;Drawing
        mov     ax,SPIC    ;adres obrazka
        mov     ds,ax
        mov     ax,0a000h
        mov     es,ax
        xor     di,di
        ;zapami‘taj przyrosty w rejestrach
        ;dla przyspieszenia oblicze¤
        mov     si,ddx     
        mov     bp,ddy
        mov     cx,200     ;ilož linii ekranu
Vloop:
        push    cx
        mov     ax,i       ;zacznij od (I,J)
        mov     dx,j
        mov     cx,319     ;ilož kolumn - 1
Hloop:
        add     ax,si
        add     dx,bp
        ;BX := 256 * Y + X
        mov     bl,ah
        mov     bh,dh
        mov     bl,ds:[bx]
        mov     es:[di],bl
        inc     di
        dec     cx
        jns     Hloop

        mov     ax,d2x
        mov     dx,d2y
        ;przejd¦ do nast‘pnego punktu
        add     i,ax
        add     j,dx
        pop     cx
        loop    Vloop
        ret
ENDP    
;*********************************
;Ustaw palet‘ z PAL
SetPAL PROC
        mov     dx,3c8h
        mov     al,0
        out     dx,al
        inc     dx
        mov     cx,768
        push    cs
        pop     ds
        lea     si,PAL
        rep     outsb
        ret
ENDP            
;*********************************
;Wczytaj PIC i PAL
LoadPICPAL PROC
        push    cs
        pop     ds
        lea     dx,PICname
        mov     cx,0ffffh
        mov     bx,SPIC
        mov     es,bx
        mov     di,0
        call    Load
        ;*
        push    cs
        pop     ds
        lea     dx,PALname
        mov     cx,768
        push    cs
        pop     es
        lea     di,PAL
        call    Load
        ret
ENDP    
;*********************************
;Wczytaj wartožci funkcji tryg.
LoadSINCOS PROC
        push    cs
        pop     ds
        lea     dx,S1
        mov     cx,512
        push    cs
        pop     es
        lea     di,SIN1
        call    Load
        ;*
        push    cs
        pop     ds
        lea     dx,S2
        lea     di,SIN2
        call    Load
        ;*
        push    cs
        pop     ds
        lea     dx,C1
        lea     di,COS1
        call    Load
        ;*
        push    cs
        pop     ds
        lea     dx,C2
        lea     di,COS2
        call    Load
        ret
ENDP
;*******************************
;Procedura wczytuj†ca
;plik(DS:DX) -> ES:DI
Load PROC
        mov     ah,3dh
        mov     al,0
        int     21h

        mov     bx,ax
        mov     dx,es
        mov     ds,dx
        mov     dx,di
        mov     ah,3fh
        int     21h

        mov     ah,3eh
        int     21h
        ret
ENDP    

SIN1 dw 256 dup(0)
SIN2 dw 256 dup(0)
COS1 dw 256 dup(0)
COS2 dw 256 dup(0)
PAL  db 768 dup(0)

CODE ENDS

SPIC SEGMENT
PIC db 65535 dup(?)
SPIC ENDS

END Start