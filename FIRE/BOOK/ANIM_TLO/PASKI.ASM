ASSUME cs:CODE 
 
CODE SEGMENT 
paski ÿÿdb ÿ10,40,70,100,130,160 ÿÿ   ;Tablica ÿÿnumerow 
                 ;poczatkowych kolorow dla poszczegolnych paskow
dpas    db  1, 1, 1, 1,  1,  1           ;Tablica przyrostow
Start: 
        mov     ax,13h 
        int     10h 
        call    ÿÿDraw_pas         ;Narysuj ÿtlo ÿz 
                                   ;ktorego beda paski
MAIN: 
        call    Zero               ;Zeruj palete
        call    Ustaw_paski        ;Ustaw palete
        call    Opoz 
        mov     ah,01h 
        int     16h 
        jz      MAIN 
 
        mov     ah,08h 
        int     21h 
        mov     ax,3 
        int     10h 
        mov     ax,4c01h 
        int     21h      
;**************************************** 
Ustaw_paski PROC 
        push    cs 
        pop     ds 
        lea     si,paski 
        lea     di,dpas 
        mov     cx,6 
pasek: 
        push    cx 
        mov     ÿal,ds:[si] ÿ        ;Wczytaj ÿnumer ÿkoloru dla 
                                     ;paska
        push    ax               
        call    Ustaw                ;"Narysuj" pasek
        pop     ax 
        add     al,ds:[di] 
        cmp     al,230 
        jb      ok_al1 
        neg     byte ptr ds:[di] 
ok_al1: 
        cmp     al,1 
        ja      ok_al2 
        neg     byte ptr ds:[di] 
ok_al2:                  
        mov     ds:[si],al 
        inc     si 
        inc     di 
        pop     cx 
        loop    Pasek 
;***************************************         
Ustaw: 
        mov     cx,16 
        mov     bh,3 
        mov     dx,3c8h 
        out     dx,al 
        inc     dx 
        mov     al,10 
pal: 
        out     dx,al 
        out     dx,al 
        out     dx,al 
        add     al,bh 
        cmp     cl,9 
        jne     dal 
        neg     bh 
dal: 
        loop    pal 
 
        ret 
        ENDP     
;*********************************** 
Draw_pas PROC 
        mov     dx,0a000h 
        mov     es,dx 
        mov     di,12900 
        mov     al,1 
        mov     cx,120 
lll:     
        push    cx 
        mov     cx,120 
        push    ax 
        push    di 
lll1: 
        stosb 
        inc     al 
        loop    lll1 
        pop     di 
        pop     ax 
        inc     al 
        pop     cx 
        add     di,320 
        loop    lll 
        ret 
        ENDP                             
;*************************************   
Zero PROC 
        mov     dx,3c8h 
        mov     al,0 
        out     dx,al 
        inc     dx 
        mov     cx,255*3 
set: 
        out     dx,al    
        loop    Set 
        ret 
        ENDP     
;************************************** 
Opoz PROC 
        mov     dx,3dah 
wai: 
        in      al,dx 
        test    al,8 
        je      wai 
        ret 
        ENDP             
CODE ENDS 
 
END Start                
