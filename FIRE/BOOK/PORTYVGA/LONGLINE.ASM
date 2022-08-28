ASSUME cs:CODE 
 
CODE SEGMENT 
        org     100h 
Start: 
        call    Ustaw_tryb         ;Ustaw tryb czterech stron
 
        mov     dx,3d4h 
        mov     al,13h 
        mov     ah,80 
        out     ÿdx,ax ÿ             ;Zmien ÿszerokosc ekranu na 
                                     ;160. ÿStrony ÿustawione ÿw 
                                     ;kwadrat
        call    Paleta 
        call    Draw_tlo 
;**************************** 
MAIN: 
        mov     ax,0003h 
        int     33h 
        mov     ax,dx 
        mov     bx,160 
        mul     bx 
        shr     cx,1 
        shr     cx,1 
        shr     cx,1 
        add     ax,cx 
        mov     bx,ax 
 
        mov     dx,3d4h 
        mov     al,0ch 
        mov     ah,bh 
        out     dx,ax 
        inc     al 
        mov     ah,bl 
        out     dx,ax
         
        mov     ah,01h 
        int     16h 
        jz      MAIN 
;************************************** 
        mov     ah,08h 
        int     21h 
        mov     ax,3h 
        int     10h 
        mov     ax,4c01h 
        int     21h 
 
Draw_tlo PROC 
        mov     dx,3c4h 
        mov     ax,0f02h 
        out     dx,ax 
         
        mov     dx,0a000h 
        mov     es,dx 
        mov     di,0 
        mov     cx,100 
        mov     ah,0 
        mov     bh,1 
Linia: 
        push    cx 
        push    di 
        mov     cx,160 
        mov     al,ah 
        mov     bl,1 
LL: 
        stosb 
        add     di,159 
        stosb 
        add     di,159 
        stosb 
        add     di,159 
        stosb 
        sub     di,160*3 
        add     al,bl 
        cmp     cx,80 
        jne     noneg 
        mov     bl,-1 
noneg: 
        loop    LL 
        pop     di 
        add     di,160*4 
        pop     cx 
        cmp     cx,50 
        jne     noneg1 
        neg     bh 
noneg1: 
        add     ah,bh 
        loop    Linia 
        ret 
        ENDP     
 
Paleta PROC 
        mov     dx,3c8h 
        mov     al,0 
        out     dx,al 
        inc     dx 
        mov     cx,255 
set: 
        out     dx,al 
        out     dx,al 
        out     dx,al 
        inc     al 
        loop    set 
        ret 
        ENDP     
 
;******************************** 
;Tu nalezy dolaczyc procedure USTAW_TRYB
INCLUDE INIT.ASM 
;******************************** 
 
CODE ENDS  
 
END Start
