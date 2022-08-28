;*******************
;*** VECT_2D.ASM *** 
;*******************
DSTACK SEGMENT STACK 'STACK'
db 10 dup('STACK')
DSTACK ENDS

ASSUME cs:CODE 

CODE SEGMENT 

Sname db 'SINUS.DAT',0
Cname db 'COSINUS.DAT',0

ile_punktow equ 12   ;iloûç obracanych punkt¢w
ile_linii   equ 12   ;iloûç rysowanych linii
Dl_x    dw      150        ;Liczba korygujÜca wsp¢írzëdnÜ X
Dl_y    dw      100        ;i wsp¢írzëdnÜ Y
kat     dw      0          ;kÜt obrotu od pozycji poczÜtkowej 
iler    equ     8
XO      dw      0
YO      dw      0

Start: 
     mov  ax,13h 
     int  10h 
     call LoadDATA   
     call Trans_lacz ;Przelicz tablicë íÜcznik¢w
MAIN: 
     mov  color,0 
     call Draw      ;Zetrzyj stary rysunek 
     call Rotate    ;Obr¢ç 
     mov  color,63h 
     call Draw      ;Narysuj nowy rysunek 
     call Opoz
     inc  kat       ;Nastëpny kÜt 
     cmp  kat,90   ;Sprawd¶ czy przeszedí zakres 
     jb   Ok_kat 
     mov  kat,0     ;ustaw kÜt na zerowy 
Ok_kat: 
     mov  ah,01h    ;sprawd¶ czy naciûniëty klawisz 
     int  16h       ;jeûli nie, to obracaj dalej
     jz   MAIN 
     mov  ax,3h 
     int  10h 
     mov  ax,4c01h 
     int  21h 
;-------- Op¢¶nienie -------- 
;Procedura dostosowuje rysowanie bryíy do wyûwietlania obrazu 
;przez komputer na ekranie
Opoz PROC 
     mov  dx,3dah 
Wai: 
     in   al,dx 
     test al,8 
     je   Wai 
     ret 
     ENDP 
;-------- Przeliczenie tablicy íÜcznik¢w ---------- 
;Procedura ˇzamienia ˇliczby z tablicy LACZ na offsety punkt¢w w 
;tablicy R_KWADRAT
Trans_lacz PROC 
     mov  cx,ile_linii 
     shl  cx,1 
     push cs
     pop  es
     lea  di,Lacz 
Tr: 
     mov  ax,es:[di]     ;Pobierz liczbë
     shl  ax,1           ;Pomn¢ß przez 2
     shl  ax,1           ;Pomn¢ß przez 2
     stosw               ;Wstaw w to samo miejsce
     loop Tr 
     ret 
     ENDP
;**************** Procedura obracajÜca punkty ********************
;Procedura oblicza nowe wsp¢írzëdne punkt¢w na podstawie tablicy 
;KWADRAT (wierzchoíki bryíy) i umieszcza je w tablicy R_KWADRAT. 
;Punkty ˇobracane ˇsÜ wedíug punktu (XO,YO) o kÜt wyznaczony 
;przez zmiennÜ KAT
;*****************************************************************
Rotate PROC
        mov     dx,SCOS
        mov     ds,dx
        mov     dx,SSIN
        mov     es,dx
        mov     bp,KAT
        mov     cl,9
        shl     bp,cl
        mov     cx,ile_punktow
        mov     si,0
Rotz:
        ;Wczytaj X 
        push    cx
        mov     cl,iler
        mov     bx,cs:KWADRAT[si]
        add     bx,127  ;przelicz na offset
        sub     bx,xo
        shl     bx,1
        add     bx,bp

        ;Wczytaj Y
        mov     di,cs:KWADRAT[si+2]
        add     di,127  ;przelicz na offset
        sub     di,yo
        shl     di,1
        add     di,bp

        ;policz X * cos + Y * sin
        mov     ax,ds:[bx]
        add     ax,es:[di]
        ;policz Y * cos - X * sin
        mov     dx,ds:[di]
        sub     dx,es:[bx]
        ;przelicz na wsp¢írzëdne rzeczywiste
        sar     ax,cl
        sar     dx,cl
        
        add     ax,xo
        add     dx,yo
        ;zapamiëtaj     
        mov     cs:R_KWADRAT[si],ax
        mov     cs:R_KWADRAT[si+2],dx
        add     si,4
        pop     cx
        loop    RotZ
        ret
        ENDP    
;-------- Procedura rysujÜca figurë na ekranie --------- 
Draw PROC 
     push cs
     push cs
     pop  ds
     pop  es
     lea  si,R_kwadrat   ;Rysowanie na podstawie R_KWADRAT 
     lea  di,Lacz        ;Tablica íÜcznik¢w
     mov  cx,ile_linii 
Rysuj: 
     mov  bx,es:[di]          ;Wczytaj X poczÜtkowego punktu
     mov  bp,es:[di][2]       ;Wczytaj Y poczÜtkowego punktu
     mov  ax,ds:[si][bx]      ;X1 
     mov  dx,ds:[si][bx][2]   ;Y1 
     add  ˇax,dl_x ˇ            ;Dodaj ˇodpowiednie ˇwartoûci do 
                                ;wsp¢írzëdnych tak aby przesunÜç 
     add  dx,dl_y               ;figurë na ûrodek 
     mov  cs:x1,ax 
     mov  cs:y1,dx 
     mov  ax,ds:[si][bp]      ;X2 
     mov  dx,ds:[si][bp][2]   ;Y2 
     add  ax,dl_x               ;Dodaj odpowiednie liczby do
     add  dx,dl_y               ;do wsp¢írzëdnych
     mov  cs:x2,ax 
     mov  cs:y2,dx 
     push si 
     push di 
     push ds 
     push es 
     push cx 
     call Line           ;Rysuj linië od (X1,Y1) do (X2,Y2)
     pop  cx 
     pop  es 
     pop  ds 
     pop  di 
     pop  si 
     add  di,4 
     loop Rysuj 
     ret 
     ENDP 
;*********************************
;Wczytaj tablice sinusa i cosinusa
;*********************************
LoadDATA PROC
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
        ret
ENDP    
     
include linia.asm   ;DoíÜcz procedurë rysujÜcÜ linië

Kwadrat   dw -20,60, 20,60, 20,20, 60,20, 60,-20, 20,-20, 20,-60 
          dw -20,-60, -20,-20, -60,-20, -60,20, -20,20 
Lacz      dw 0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,0 
R_kwadrat dw ile_punktow dup(0,0) 

CODE ENDS 

SSIN SEGMENT
SIN db 50000 dup(?)
SSIN ENDS

SCOS SEGMENT
COS db 50000 dup(?)
SCOS ENDS

END Start 
