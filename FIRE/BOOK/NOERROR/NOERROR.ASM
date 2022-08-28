;*******************
;*** NOERROR.ASM ***
;*******************

.286c
ASSUME cs:CODE

CODE SEGMENT
        org     100h
Start:
        jmp     Install 
;********************************************** 
;Zmienne pomocnicze do zapami‘tania stanu stosu
_ax2    dw      0
_ax1    dw      0
_ax     dw      0
;Zmienne do zapami‘tania starego adresu obs’ugi 13h
old13o  dw      0
old13s  dw      0
        dw      'JJ'
        
NewInt13h:
        cmp     ah,2  ;Sprawd¦ nr funkcji, 2 - odczyt sektora
        jne     GOOD
        cmp     dl,1  ;Nap‘d dyskietek?
        ja      GOOD
        ;Wywo’aj star† procedur‘ obs’ugi 13h
        pushf
        call    dword ptr cs:old13o
        ;***
        ;Odczytaj stos
        pop     _ax1
        pop     _ax2
        pop     _ax
        ;Kasuj CF i wstaw znaczniki na stos
        clc
        pushf
        ;Odtw¢rz stos
        push    _ax2
        push    _ax1
        mov     ah,0 
        
        jmp     koniec
GOOD:   
        jmp     dword ptr cs:old13o
koniec:         
        iret    
;*****************************************
Install:
        ;Czytaj adres 13h
        mov     ax,3513h
        int     21h
        ;Zobacz, czy program ju§ jest zainstalowany                
        cmp     word ptr es:[bx-2],'JJ'
        je      Deinstall
        ;----------------------------
        ;Zapami‘taj adres
        mov     old13o,bx
        mov     old13s,es
        push    cs
        pop     ds
        ;Ustaw 13h na NewInt13h
        mov     dx,offset NewInt13h
        mov     ax,2513h
        int     21h
        lea     dx,inst
        mov     ah,09h
        int     21h        
        mov     dx,offset Install
        int     27h     
        ;-----------------------------
Deinstall:      
        ;Deinstaluj program
        mov     ds,es:[bx-4]
        mov     dx,es:[bx-6]
        mov     ax,2513h
        int     21h
        mov     ah,49h
        int     21h
        push    cs
        pop     ds
        lea     dx,dein
        mov     ah,09h
        int     21h                                                
        mov     ax,4c01h
        int     21h
        
Inst    db 'NOERROR zainstalowany',13,10,'$'
Dein    db 'NOERROR zdeinstalowany',13,10,'$'        
CODE ENDS

END Start       