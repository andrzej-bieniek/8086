;*******************
;*** GWIAZDY.ASM ***
;*******************

DSTACK SEGMENT 'STACK' STACK
db 10 dup('STACK')
DSTACK ENDS

ASSUME cs:CODE

CODE SEGMENT
Gname   db  'gwiazdy.dat',0
ile     equ  400  ;iloûç "gwiazd"

Start:
        call    LoadGWIAZDY
        mov     ax,13h
        int     10h
        call    Paleta
MAIN:   
        call    MoveGWIAZDY
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
;****************************
;Dostosowanie do ekranu
Opoz PROC
        mov     dx,3dah
wai:
        in      al,dx
        test    al,8
        je      wai
        ret
ENDP                    
;****************************
;Ustaw kolory: 1, 2, 3
Paleta PROC
        mov     dx,3c8h
        mov     al,1
        out     dx,al
        inc     dx
        mov     cx,3
        mov     bl,30
Set:
        mov     al,0
        out     dx,al
        out     dx,al
        mov     al,bl
        add     bl,10
        out     dx,al
        loop    Set
        ret
ENDP    
;****************************
;Przesu§ gwiazdy
MoveGWIAZDY PROC
        mov     cx,ile
        push    cs
        pop     ds
        mov     dx,0a000h
        mov     es,dx
        lea     di,GWIAZDY
        mov     si,di
        mov     dl,0
Move:
        ;Najwolniejsze
        mov     bx,ds:[si]
        mov     es:[bx],dl             ;Skasuj starÜ
        mov     byte ptr es:[bx][-1],1 ;postaw nowÜ
        dec     word ptr ds:[si]
        add     si,2

        ;òrednie
        mov     bx,ds:[si]
        mov     es:[bx],dl   
        mov     byte ptr es:[bx][-2],2 ;skasuj starÜ
        sub     word ptr ds:[si],2     ;postaw nowÜ
        add     si,2

        ;Najszybsze
        mov     bx,ds:[si]
        mov     es:[bx],dl
        mov     byte ptr es:[bx][-3],3 ;skasuj starÜ 
        sub     word ptr ds:[si],3     ;postaw nowÜ
        add     si,2
        loop    Move
        ret
ENDP    
;****************************
LoadGWIAZDY PROC
        push    cs
        pop     ds
        lea     dx,Gname
        mov     al,0
        mov     ah,3dh
        int     21h

        mov     bx,ax
        mov     ah,3fh
        lea     dx,GWIAZDY
        mov     cx,ile*6
        int     21h

        mov     ah,3eh
        int     21h
        ret
ENDP            

GWIAZDY dw ile*3 dup(?)
CODE ENDS

END Start       