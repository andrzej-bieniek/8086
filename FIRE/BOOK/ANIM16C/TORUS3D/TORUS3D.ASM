.286C 
ASSUME cs:CODE 
 
CODE SEGMENT 
ile_pix  dw 1280  ;ile punktow program ma rysowac
katx    dw 0      ;kat obrotu wokol osi X 
;-------Zmienne dla procedury obracajacej--------- 
_sin    dw ? 
_cos    dw ? 
xr      dw 0 
yr      dw 0 
zr      dw 0 
;-------Zmienne dla procedury przeliczajacej ----- 
;-------na wspolrzedne ekranu                ----- 
Zv      dw -50*512 
Zv1     dw -110 
d_Z     dw ? 
d_x     dw 320 
d_y     dw 175 
 
stro    dw 0,80*350 
adju    dw 80*350,0 
strona dw 0 
adjust dw 0 
;*********************************** 
Start: 
        mov     ax,10h 
        int     10h 
MAIN: 
        call    Move 
        call    RotateX 
        call    Perspective 
        call    Draw 
        call    Zmien    
        call    Show 
        call    Opoz 
        call    Zkaty 
        mov     ah,01h 
        int     16h 
        jz      MAIN 
        mov     ax,3h 
        int     10h 
        mov     ax,4c01h 
        int     21h 
;***********************************     
;Procedura rysuje wszystkie punkty torusa
Draw PROC 
        mov     dx,0a000h 
        mov     es,dx 
        mov     bx,0 
        mov     cx,ile_pix 
Draw1: 
        mov     bp,cs:ekr[bx]      ;Odczytaj wspolrzedna X
        shl     bp,1               ;Przelicz na indeks tablicy
        shl     bp,1               ;PUNKTY
        mov     di,cs:punkty[bp]   ;Wczytaj numer bajtu w linii
        mov     ax,cs:ekr[bx+2]    ;Wczytaj wspolrzedna Y
        mov     dx,80              ;i przelicz na adres
        mul     dx                 ;na ekranie
        add     di,ax              ;Dodaj do X
        add     di,adjust          ;Ustaw na odpowiednia strone
        mov     ax,cs:punkty[bp+2]  ;Wczytaj numer bitu 
        mov     es:[di],al         ;I postaw punkt
        add     bx,4 
        loop    Draw1
        ret 
        ENDP 
;***********************************     
Opoz    PROC     
        mov     dx,3dah 
Wai: 
        in      al,dx 
        test    al,08 
        je      Wai 
Wai1: 
        in      al,dx 
        test    al,08 
        jne     Wai1             
        ret 
        ENDP     
;--------------Perspective----------------------------------- 
Perspective PROC         
        push    cs 
        push    cs 
        pop     ds 
        pop     es 
        lea     si,tab 
        lea     di,ekr 
        mov     cx,ile_pix 
Per: 
        push    cx 
        mov     cx,7 
        mov     ax,Zv 
        mov     bx,ds:[si][4] 
        sub     bx,Zv1 
        xor     dx,dx 
        idiv    bx 
        mov     d_z,ax 
        ;--X-- 
        lodsw 
        neg     ax 
        imul    d_z 
        sar     ax,cl 
        add     ax,d_x 
        stosw 
        ;--Y-- 
        lodsw 
        neg     ax 
        imul    d_z 
        sar     ax,cl 
        add     ax,d_y 
        stosw 
        add     si,2 
        pop     cx 
        loop    Per 
        ret 
        ENDP 
;------------------------------------------------------------ 
RotateX PROC 
        mov     bx,katx 
        shl     bx,1 
        mov     ax,cs:sinus[bx] 
        mov     _sin,ax 
        mov     ax,cs:cosin[bx] 
        mov     _cos,ax 
        mov     cx,ile_pix 
        push    cs 
        pop     ds 
        lea     si,tab 
R_X: 
        push    cx 
        mov     cx,9 
        ;----Y---- 
        mov     ax,ds:[si][2] 
        imul    _cos 
        push    ax 
        mov     ax,ds:[si][4] 
        imul    _sin 
        pop     dx 
        add     dx,ax 
        sar     dx,cl 
        mov     yr,dx 
        ;----Z---- 
        mov     ax,ds:[si][4] 
        imul    _cos 
        push    ax 
        mov     ax,ds:[si][2] 
        imul    _sin 
        pop     dx 
        sub     dx,ax 
 
        sar     dx,cl 
        mov     zr,dx 
         
        mov     ax,yr 
        mov     bx,zr 
        mov     ds:[si][2],ax 
        mov     ds:[si][4],bx 
        add     si,6 
        pop     cx 
        loop    R_X 
        ret 
        ENDP 
;----------------Przenies z PIX do TAB------------------
Move    PROC 
        push    cs 
        pop     es 
        lea     di,tab 
        mov     dx,DATA 
        mov     ds,dx 
        lea     si,pix 
        mov     cx,ile_pix 
        mov     bx,cx 
        add     cx,cx 
        add     cx,bx 
        cld 
        rep     movsw 
        ret 
        ENDP 
;-------------Zkaty--------- 
Zkaty PROC 
        add     katx,5 
        cmp     katx,360 
        jb      okx 
        mov     katx,0 
okx: 
        ret 
        ENDP 
        
;--------------Zmien------------------
;Adjust := abs(adjust-16384); 
;Strona := abs(strona-16384); 
Zmien PROC       
        mov     ax,cs:[stro] 
        mov     strona,ax 
        mov     bx,cs:[stro+2] 
        mov     cs:[stro],bx 
        mov     cs:[stro+2],ax 
        mov     ax,cs:[Adju] 
        mov     adjust,ax 
        mov     bx,cs:[adju+2] 
        mov     cs:[adju],bx 
        mov     cs:[adju+2],ax 
        ret 
        ENDP 
;--------------Show-------------------
;Procedura sciera stary rysunek i pokazuje nowy 
Show PROC 
        mov     bx,strona 
        mov     dx,3d4h 
        mov     al,12 
        mov     ah,bh 
        out     dx,ax 
        inc     al 
        mov     ah,bl 
        out     dx,ax 
        ;Kasuj stary rysunek 
        mov     dx,3c4h 
        mov     al,02h 
        mov     ah,0ffh 
        out     dx,ax 
        mov     dx,0a000h 
        mov     es,dx 
        mov     di,adjust 
        mov     ax,0 
        rept    40*350 
          stosw 
        endm   
        ret 
        ENDP 
;------------------------------------------------------------ 
INCLUDE SIN.ASM 
INCLUDE COS.ASM 
 
tab     dw 3000 dup(0,0,0) 
ekr     dw 3000 dup(0,0) 
include punkty.asm 
;------------------------------------------------------------ 
CODE ENDS 
 
DATA SEGMENT 
 
include pix 
 
DATA ENDS 
 
END Start        
 
