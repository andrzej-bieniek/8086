;*******************
;*** VECT_3D.ASM *** 
;*******************
DSTACK SEGMENT STACK 'STACK'
db 10 dup('STACK')
DSTACK ENDS

ASSUME cs:CODE

CODE SEGMENT 
Sname     db 'SINUS.DAT',0
Cname     db 'COSINUS.DAT',0

kat_y     dw 0           ;KÜt obrotu wok¢í osi Y
kat_x     dw 0           ;KÜt obrotu wok¢í osi X
kat_z     dw 0           ;KÜt obrotu wok¢í osi Z
;Wsp¢írzëdne punktu obrotu
XO        dw 0
YO        dw 0
ZO        dw 0

ile_punktow    equ 25    ;iloûç obracanych punkt¢w
ile_linii      equ 36    ;iloûç rysowanych linii
d_x       dw 150         ;korekcja X
d_y       dw 100         ;korekcja Y
iler      equ 8

Zv        dw -23040      ;Wsp¢írzëdna Z oka pomnoßona przez 256
Zv1       dw -90         ;Wsp¢írzëdna Z oka

Start: 
     mov  ax,13h 
     int  10h 
     call LoadDATA
     call Trans_lacz     ;Przelicz tablicë poíÜcze§ 
MAIN: 
     mov  color,0 
     call Draw           ;Zetrzyj stary rysunek 
     call Copy_bryla     ;Przenieû ˇˇˇwsp¢írzëdne ˇˇdo ˇˇtablicy 
                         ;roboczej 
     call Rotate_y       ;Obr¢ç wok¢í y
     call Transform      ;Przelicz na wsp¢írzëdne ekranu 
     mov  color,63h 
     call Draw           ;Rysuj nowy rysunek 
     ;*************************
     ;Czekaj na powr¢t pionowy
     mov  dx,3dah       
wai:     
     in   al,dx
     test al,8
     je   wai
wai1:
     in   al,dx
     test al,8
     jne  wai1     
     ;************************* 
     inc  kat_y          ;Nastëpny kÜt 
     cmp  kat_y,90 
     jb   Ok_Y 
     mov  kat_y,0 
Ok_Y: 
     mov  ah,01h 
     int  16h            ;Sprawd¶ czy klawisz
     jz   MAIN           ;jeûli nie to obracaj dalej
     mov  ax,3h
     int  10h
     mov  ax,4c01h
     int  21h

include linia.asm
     
;---- Kopiuj wsp¢írzëdne do tablicy ROT_BRYLA --- 
;Procedura przenosi wsp¢írzëdne do tablicy ROT_BRYLA z kt¢rej 
;bëdÜ brane do obrot¢w
Copy_bryla PROC
     push cs
     push cs
     pop  ds
     pop  es 
     lea  si,Bryla
     lea  di,Rot_bryla
     mov  cx,ile_punktow
Kopiuj: 
     movsw 
     movsw 
     movsw 
     loop Kopiuj 
     ret 
     ENDP 
;--- Obr¢ç wok¢í osi Y --- 
;Procedura obraca punkty zawarte w tablicy ROT_BRYLA o kÜt KAT_Y 
;i ˇumieszcza ˇje ˇzn¢w ˇw ˇtablicy ˇROT_BRYLA. ˇJest ˇto zabieg 
;konieczny ˇdo ˇp¢¶niejszej ˇrozbudowy ˇprogramu ˇo obroty wok¢í 
;pozostaíych ˇˇˇosi, ˇˇtak ˇˇaby ˇˇnowe ˇˇprocedury ˇˇobracajÜce 
;wykorzystywaíy ˇˇwsp¢írzëdne ˇˇprzeliczone ˇˇprzez ˇˇpoprzedniÜ 
;procedurë obracajÜcÜ (uwzglëdnienie wszystkich obrot¢w). 
Rotate_Y PROC
        mov     dx,SCOS
        mov     ds,dx
        mov     dx,SSIN
        mov     es,dx
        mov     bp,kat_y
        mov     cl,9
        shl     bp,cl
        mov     cx,ile_punktow
        lea     si,ROT_BRYLA
Roty:
        ;Czytaj X
        push    cx
        mov     cl,iler
        mov     bx,cs:[si]
        add     bx,127
        sub     bx,xo
        shl     bx,1
        add     bx,bp

        ;Czytaj Z
        mov     di,cs:[si+4]
        add     di,127
        sub     di,zo
        shl     di,1
        add     di,bp
        ;licz X * cos - Z * sin
        mov     ax,ds:[bx]
        sub     ax,es:[di]
        ;licz Z * cos + X * sin
        mov     dx,ds:[di]
        add     dx,es:[bx]
        ;przelicz na wsp¢írzëdne rzeczywiste
        sar     ax,cl
        sar     dx,cl
        
        add     ax,xo
        add     dx,zo

        mov     cs:[si],ax
        mov     cs:[si+4],dx
        add     si,6
        pop     cx
        loop    Roty
        ret
        ENDP    
;---- Przelicz wsp¢írzëdne 3D na wsp¢írzëdne ekranu ---- 
;Procedura ˇoblicza ˇwsp¢írzëdnÜ ˇna ˇekranie ˇkaßdego ˇpunktu z 
;wykorzystaniem ˇr¢wna§ ˇperspektywy ˇi ˇumieszcza ˇje w tablicy 
;EKRAN
D_z  dw ? 
Transform PROC 
     push cs
     push cs
     pop  es
     pop  ds
     lea  si,Rot_bryla   ;Wsp¢írzëdne 3D
     lea  di,Ekran       ;Tablica wpoírzëdnych ekranu 
     mov  cx,ile_punktow ;iloûç przelicznych punkt¢w
Trans: 
     ;Licz Zv/(Z-Zv1) i zachowaj na p¢¶niej
     mov  ax,Zv               ;Wczytaj ZV (patrz wz¢r) 
     mov  bx,ds:[si][4]       ;Wczytaj wsp¢írzëdnÜ Z
     sub  bx,Zv1              ;Odejmij ZV1 (patrz wz¢r)
     mov  dx,0 
     idiv bx                  ;Podziel przez (Z-Zv1)
     mov  d_z,ax      ;zapamiëtaj wynik w zmiennej D_Z
     ;--- Oblicz wsp¢írzëdnÜ X --- 
     lodsw          ;Wczytaj X z ROT_BRYLA
     neg  ax        ;Zmie§ znak
     imul d_z       ;Pomn¢ß przez D_z
     push cx 
     mov  cl,8      ;i podziel przez 256
     sar  ax,cl 
     pop  cx 
     add  ax,d_x    ;przesu§
     stosw          ;Zapamiëtaj w tablicy EKRAN
     ;--- Oblicz wsp¢írzëdnÜ Y --- 
     lodsw          ;Wczytaj Y z ROT_BRYLA
     neg  ax        ;Zmie§ znak
     imul d_z       ;Pomn¢ß przez D_z
     push cx 
     mov  cl,8      ;i podziel przez 256
     sar  ax,cl 
     pop  cx 
     add  ax,d_y    ;przesu§
     stosw          ;i zapamiëtaj w tablicy EKRAN
     add  si,2 
     loop Trans 
     ret 
     ENDP 
;---- Rysuj bryíë ---- 
;Procedura rysuje bryíë na ekranie na podstawie tablicy EKRAN
Draw PROC 
     push cs
     push cs
     pop  ds
     pop  es
     lea  di,Lacz        ;Tablica íÜcznik¢w
     lea  si,Ekran       ;Tablica wsp¢írzëdnych
     mov  cx,ile_linii   ;iloûç rysowanych linii
Rysuj: 
     mov  bx,es:[di]     ;pierwszy i 
     mov  bp,es:[di][2]  ;drugi punkt 
     mov  ax,ds:[si][bx]      ;Wczytaj X1
     mov  dx,ds:[si][bx][2]   ;Wczytaj Y1
     mov  cs:x1,ax 
     mov  cs:y1,dx 
     mov  ax,ds:[si][bp]      ;Wczytaj X2
     mov  dx,ds:[si][bp][2]   ;Wczytaj Y2
     mov  cs:x2,ax 
     mov  cs:y2,dx 
     push ds 
     push es 
     push si 
     push di 
     push cx 
     call Line           ;Rysuj linië od (X1,Y1) do (X2,Y2)
     pop  cx 
     pop  di 
     pop  si 
     pop  es 
     pop  ds 
     add  di,4 
     loop Rysuj 
     ret 
     ENDP 
;---- Przelicz tablicë íÜcznik¢w ---- 
;Procedura ˇmnoßy ˇprzez 4 kaßdÜ liczbë w tablicy íÜcznik¢w, tak 
;aby przerobiç je na offsety w tablicy EKRAN
Trans_lacz PROC 
     push cs
     pop  es
     lea  di,Lacz 
     mov  cx,ile_linii        ;iloûç linii pomnoßona przez 2
     shl  cx,1                ;-kaßda linia - dwa ko§ce
Tr: 
     mov  ax,es:[di]          ;Wczytaj liczbë
     shl  ax,1                ;Pomn¢ß przez 2
     shl  ax,1                ;Pomn¢ß przez 2
     stosw                    ;Zapisz w tym samym miejscu
     loop Tr 
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

;--- Wierzchoíki bryíy --- 
Bryla     dw -30,-10,-30, 30,-10,-30, 30,-10,30, -30,-10,30 
          dw -20,-10,-20, 20,-10,-20, 20,-10,20, -20,-10,20 
          dw -20,10,-20, 20,10,-20, 20,10,20, -20,10,20 
          dw -25,10,-25, 25,10,-25, 25,10,25, -25,10,25 
          dw 0,30,0 
          dw -17,7,20, -5,7,20, -5,-3,20, -17,-3,20 
          dw 17,7,20, 3,7,20, 3,-8,20, 17,-8,20 

;--- Tablica íÜcznik¢w --- 
Lacz      dw 0,1, 1,2, 2,3, 3,0 
          dw 4,5, 5,6, 6,7, 7,4 
          dw 8,9, 9,10, 10,11, 11,8 
          dw 4,8, 5,9, 6,10, 7,11 
          dw 12,13, 13,14, 14,15, 15,12 
          dw 8,12, 9,13, 10,14, 11,15 
          dw 12,16, 13,16, 14,16, 15,16 
          dw 17,18, 18,19, 19,20, 20,17 
          dw 21,22, 22,23, 23,24, 24,21 
Ekran     dw ile_punktow dup(0,0) 
Rot_bryla dw ile_punktow dup(0,0,0) 
Pom_bryla dw ile_punktow dup(0,0,0) 

CODE ENDS 

SSIN SEGMENT
SIN db 50000 dup(?)
SSIN ENDS

SCOS SEGMENT
COS db 50000 dup(?)
SCOS ENDS



END Start 
