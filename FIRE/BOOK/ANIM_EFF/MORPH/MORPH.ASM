ASSUME cs:CODE

DSTACK SEGMENT 'STACK' STACK
db 32 dup('STACK');
DSTACK ENDS

CODE SEGMENT

f1name db 'fract1.dat',0
f2name db 'fract2.dat',0
planes db 640 dup(0)
ile    equ 2000     ;Maxymalnie 4000
ile_krokow equ 50   ;Ilož krok¢w animacji
pow2    equ 5       ;Pomocnicze - dla dok’adnožci oblicze¤

Start:
        call    LoadDATA
        call    InitPLANES
        mov     ax,12h
        int     10h
        ;Ustaw plane dla animacji
        mov     ax,0f02h
        mov     dx,3c4h
        out     dx,ax
MAIN:
        lea     si,fract1  ; r¢d’o
        lea     di,fract2  ;Cel
        call    Morph
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
;Procedura przetwarza figur‘ z SI
;w figur‘ z DI i potem DI -> SI
Morph PROC      
        ;Licz przyrosty X i Y na faz‘ animacji
        mov     cx,ile
        mov     dx,SFRACT
        mov     ds,dx
        mov     es,dx
        lea     bp,Delta
        push    si
liczD:
        ;DX = (X2 - X1)
        push    cx
        mov     ax,ds:[di] ;X2
rept pow2
        shl     ax,1
endm
        mov     bx,ds:[si] ;X1
rept pow2
        shl     bx,1
endm
        ;Podziel przez ilož krok¢w
        mov     cx,ile_krokow
        xor     dx,dx
        sub     ax,bx
        jns     Ok_d1
        neg     ax
        neg     cx
Ok_d1:
        idiv    cx
        mov     ds:[bp],ax

        ;DY
        mov     ax,ds:[di][2] ;Y2
rept pow2
        shl     ax,1
endm
        mov     bx,ds:[si][2] ;Y1
rept pow2
        shl     bx,1
endm
        ;Podziel przez ilož krok¢w
        mov     cx,ile_krokow
        xor     dx,dx
        sub     ax,bx
        jns     Ok_d2
        neg     ax
        neg     cx
Ok_d2:
        idiv    cx
        mov     ds:[bp][2],ax
        add     bp,4
        add     si,4
        add     di,4
        pop     cx
        loop    LiczD
        ;Przeniež figur‘-¦r¢d’o do CFRACT
        ;i pomn¢§ wsp¢’rz‘dne przez sta’† (patrz pow2)
        pop     si
        mov     cx,ile*2
        lea     di,CFRACT
MoveC:
        lodsw
rept pow2
        shl     ax,1
endm
        stosw
        loop    MoveC
        ;MORPHING
        call    MakeMorph  ;1 -> 2
        ;Zaneguj DELTA (animacja powrotna)
        mov     cx,ile*2
        mov     dx,SFRACT
        mov     es,dx
        mov     ds,dx
        lea     si,Delta
        lea     di,Delta
Minus:
        lodsw
        neg     ax
        stosw
        loop    Minus
        call    MakeMorph  ;2 -> 1
        ret
ENDP
;****************************************
MakeMorph PROC
        mov     dx,SFRACT
        mov     ds,dx
        mov     cx,ile_krokow
        mov     dx,0a000h
        mov     es,dx
Draw:   
        mov     si,ile-1
        mov     bp,0
Pixel:
        ;Kasuj punkt
        call    LiczPunkt   ;policz offset i mask‘ dla punktu
        not     dl
        and     es:[di],dl  ;skasuj punkt

        ;X = X + DX, Y = Y + DY
        mov     bx,ds:Delta[bp]
        add     ds:Cfract[bp],bx
        mov     bx,ds:Delta[bp+2]
        add     ds:Cfract[bp+2],bx

        ;Stawiaj punkt
        call    LiczPunkt  ;licz offset i mask‘
        or      es:[di],dl ;postaw punklt

        add     bp,4       ;nast‘pny punkt
        dec     si
        jns     Pixel
        dec     cx
        jns     Draw
        ret
ENDP    
;******************************************
;Procedura liczy offset i mask‘ dla punktu 
;o offsecie w tablicy CFRACT = BP
LiczPunkt PROC
        mov     bx,ds:Cfract[bp]        
rept pow2
        shr     bx,1
endm
        mov     dl,cs:planes[bx]  ;wczytaj mask‘
        push    dx
        shr     bx,1
        shr     bx,1
        shr     bx,1
        mov     ax,ds:Cfract[bp+2]  ;Y
rept pow2
        shr     ax,1
endm
        ;licz offset linii
        mov     di,80
        mul     di
        add     ax,bx
        mov     di,ax
        pop     dx
        ret
ENDP
;***********************************
;Liczy maski dla ka§dej kolumny ekranu
;0 - 10000000b, 1 - 01000000b, 2 - 001000000b itd.
InitPLANES PROC
        mov     cx,640
        mov     al,10000000b    
        mov     bx,0
InitP:
        mov     cs:planes[bx],al
        ror     al,1
        inc     bx
        loop    InitP
        ret
ENDP            
;***********************************
;Czyta FRACT1.DAT, FRACT2.DAT
LoadDATA PROC
        ;FRACT1
        push    cs
        pop     ds
        lea     dx,f1name
        mov     al,0
        mov     ah,3dh
        int     21h     

        mov     bx,ax
        mov     ah,3fh
        mov     dx,SFRACT
        mov     ds,dx
        lea     dx,fract1
        mov     cx,16000
        int     21h

        mov     ah,3eh
        int     21h
        ;FRACT2
        push    cs
        pop     ds
        lea     dx,f2name
        mov     al,0
        mov     ah,3dh
        int     21h

        mov     bx,ax
        mov     ah,3fh
        mov     dx,SFRACT
        mov     ds,dx
        lea     dx,fract2
        mov     cx,16000
        int     21h

        mov     ah,3eh
        int     21h
        ret
ENDP

CODE ENDS

SFRACT SEGMENT
fract1 dw 4000 dup(0,0)
fract2 dw 4000 dup(0,0)
Cfract dw 4000 dup(0,0)
delta  dw 4000 dup(0,0)
SFRACT ENDS

END Start
        