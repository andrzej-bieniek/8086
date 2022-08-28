;****************
;*** LUPA.ASM ***
;****************
DSTACK SEGMENT STACK 'STACK'
  db 64 dup('STACK');
DStACK ENDS  

ASSUME cs:CODE

CODE SEGMENT

Pname    db     'obraz.sfg',0   ;Obrazek, na kt¢rym
                                ;animujemy lupë
PPalName db     'obraz.pal',0   ;i paleta tego obrazka
PLName   db     'lupa.dat',0    ;ksztaít lupy
xx       dw     1               ;X lupy
yy       dw     1               ;Y lupy
dxx      dw     1
dyy      dw     1
;*******************************************
Start:
        call    LoadPic
        call    LoadLupa
        mov     ax,13h
        int     10h
        call    DrawPic
        call    SetPal
MAIN:
        call    DrawLupa
        call    Move
        mov     ah,01h
        int     16h
        jz      MAIN
        mov     ax,03h
        int     10h
        mov     ax,4c01h
        int     21h
;**************************************
;Zmienia XX i YY tak, aby uzyskaç "odbijanie"
;od brzeg¢w ekranu
;**************************************
Move PROC
        mov     ax,xx
        mov     bx,yy
        add     ax,dxx
        add     bx,dyy

        cmp     ax,215
        jb      okdxx1
        neg     dxx
okdxx1:
        cmp     ax,0
        ja      okdxx2
        neg     dxx
okdxx2:
        cmp     bx,96
        jb      okdyy1
        neg     dyy
okdyy1:
        cmp     bx,0
        ja      okdyy2
        neg     dyy
okdyy2: 
        mov     xx,ax
        mov     yy,bx
        ret
ENDP                                    
;*********************************************
;Procedura rysuje lupë na ekranie
;Dane obrazka brane sÜ z PIC
;*********************************************
DrawLupa PROC   
        mov     dx,0a000h
        mov     es,dx
        mov     ax,yy
        mov     bx,320
        mul     bx
        add     ax,xx
        mov     si,ax  ;SI = 320 * YY + XX
        mov     di,ax  ;DI = 320 * YY + XX
        mov     dx,PIC
        mov     ds,dx
        mov     bp,offset LUPA
        mov     cx,104  ;Wysokoûç matrycy
line:
        push    cx
        mov     cx,105  ;Szerokoûç matrycy
dline:
        mov     bx,cs:[bp]  ;Wczytaj offset ¶r¢día
        add     bx,si       ;Dodaj do offsetu punktu
        ;Nastëpny punkt matrycy
        inc     bp
        inc     bp
        ;Wczytaj kolor ¶r¢día
        mov     al,ds:[bx]
        inc     si          ;Nastëpny punkt
        ;Postaw punkt
        stosb
        ;Powt¢rz dla caíej linii
        loop    dline
        add     di,320-105
        add     si,320-105
        pop     cx
        loop    line
        ret
ENDP            
;**************************************
;Ustawia paletë z pliku OBRAZ.PAL
;**************************************
SetPal  PROC
        mov     dx,PIC
        mov     ds,dx
        mov     si,offset pal
        mov     cx,256
        mov     al,0
        mov     dx,3c8h
        out     dx,al
        inc     dx
SET:
        lodsb
        out     dx,al
        lodsb
        out     dx,al
        lodsb 
        out     dx,al
        loop    SET
        ret
ENDP            
;***************************************
;Rysuje na ekranie OBRAZ.SFG
;***************************************
DrawPic PROC
        mov     dx,PIC
        mov     ds,dx
        mov     si,0
        mov     dx,0a000h
        mov     es,dx
        mov     di,0
        mov     cx,32000
        rep     movsw
        ret
ENDP    
;****************************************
;Czyta OBRAZ.SFG i OBRAZ.PAL
;****************************************
LoadPic PROC
        mov     ah,3dh
        push    cs
        pop     ds
        lea     dx,Pname
        mov     al,0
        int     21h
        
        mov     bx,ax
        mov     ah,3fh
        mov     cx,64000
        mov     dx,PIC
        mov     ds,dx
        mov     dx,offset tab
        int     21h
        
        mov     ah,3eh
        int     21h
        ;*** PALETA
        mov     ah,3dh
        push    cs
        pop     ds
        lea     dx,PPalname
        mov     al,0
        int     21h
        
        mov     bx,ax
        mov     ah,3fh
        mov     cx,64000
        mov     dx,PIC
        mov     ds,dx
        mov     dx,offset pal
        int     21h
        
        mov     ah,3eh
        int     21h     
        ret
Error1:
        ret
ENDP    
;***************************************
;Czyta LUPA.DAT
;***************************************
LoadLupa PROC
        mov     ah,3dh
        mov     dx,offset PLname
        push    cs
        pop     ds
        mov     al,0
        int     21h
        
        mov     bx,ax
        mov     ah,3fh
        mov     cx,44032 ;rozmiar pliku
        push    cs
        pop     ds
        mov     dx,offset LUPA
        int     21h
        mov     ah,3eh
        int     21h
        ret
        ENDP
;***********************************************        
Opoz    PROC
        mov     dx,3dah
wai:
        in      al,dx
        test    al,8
        je      wai
        ret
        ENDP    

LUPA dw 23000 dup(?)
        
CODE ENDS

PIC SEGMENT
 tab db 64000 dup(?)
 pal db 768 dup(0)
PIC ENDS        

END Start               