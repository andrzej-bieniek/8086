ASSUME cs:CODE 
 
CODE SEGMENT 
        org     100h 
Start: 
        jmp     Tutaj 
wsk     db      0        ;Zmienna pomocnicza - intensywnosc 1
Tutaj: 
        cli 
MAIN:    
        call    Set      ;Ustawiaj tlo
        call    Zero     ;Czysc kolor 0
        inc     wsk      ;Nastepna intensywnosc
        in      al,60h   ;Sprawdz, czy zostal nacisniety klawisz
        cmp     al,1 
        jne     MAIN
Koncz:   
        sti 
        mov     ax,4c01h 
        int     21h 
;**********************************      
;Procedura zeruje rejestry RGB dla koloru 0
Zero PROC 
        mov     dx,3c8h 
        mov     al,0 
        out     dx,al 
        inc     dx 
        out     dx,al 
        out     dx,al 
        out     dx,al 
        ret 
        ENDP 
;********************************************************* 
;Procedura ustawia rejestry RGB podzczas tworzenia obrazu
Set PROC 
        mov     dx,3c9h 
        mov     bl,wsk 
        mov     bh,1 
        mov     ah,0 
        call    Opoz          ;Dostosuj sie do ekranu
SSet: 
        mov     dx,3c8h 
        mov     al,0
        out     dx,al         ;Kolor 0
        inc     dx 
        mov     al,bl 
	call	Opoz1
        out     dx,al 
        out     dx,al 
        out     dx,al 
        add     bl,bh 
        inc     ah 
        cmp     ah,40 
        jb      okah 
        mov     ah,0 
        neg     bh 
okah:    
	push	dx
	push	ax
	mov	dx,3dah
wai4:	
	in	al,dx
	test	al,8
	jnz	End_of_ss
	pop	ax
	pop	dx
	jmp	SSet
End_of_ss:
	pop	ax
	pop	dx	
        ret 
        ENDP 
;********************************************************** 
;Procedura dostosowuje program do tworzenia obrazu 
Opoz PROC 
        push    dx 
        push    ax 
        mov     dx,3dah 
wai1: 
        in      al,dx 
        test    al,8 
        jnz     wai1 
        pop     ax 
        pop     dx 
        ret 
        ENDP 
;********************************************************** 
;Procedura czeka na koniec tworzenia linii
Opoz1 PROC 
        push    ax 
        push    dx 
        mov     dx,3dah 
wai3:    
        in      al,dx 
        test    al,1 
        jz      wai3 
        pop     dx 
        pop     ax 
        ret 
        ENDP 
CODE ENDS  
 
END Start                        
