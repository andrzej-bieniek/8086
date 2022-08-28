;*****************
;*** ZEGAR.ASM *** 
;*****************
.286C 
ASSUME cs:CODE 
 
CODE SEGMENT 
        org  100h 
Start: 
        jmp  Install 
 
wsk     db 0 
old8o   dw 0 
old8s   dw 0 
        dw 'AB'     ;'AB' - do sprawdzenia, czy program jest 
                    ;juß zainstalowany 
;--------------------------------------------     
;--- Nowa procedura obsíugi przerwania ------ 
;--------------------------------------------
Zegar: 
        pushf                ;umieûç na stosie znaczniki 
        call ˇˇdword ˇˇptr ˇcs:[old8o] ˇ;wywoíaj ˇstarÜ ˇobsíugë 
                                        ;przerwania 8h 
        inc  wsk             ;zwiëksz wska¶nik 
        cmp  wsk,18          ;jeûli minÜí 18, to 
        jne  Wyskok           
        mov  wsk,0           ;wypisz nowy czas 
        pusha                ;zapamiëtaj rejestry 
        push ds 
        push es 
        mov  dx,0b800h       ;pamiëç ekranu 
        mov  es,dx 
        mov  di,142          ;offset miejsca wyûwietlania 
        mov  ah,02h          ;odczyt czasu 
        int  1ah 
        push cs 
        pop  ds 
        ;---Pisz kolejne liczby--- 
        mov  al,ch 
        call Pisz            ;pisz godzinë 
        call Dwukropek 
        mov  al,cl     
        call Pisz            ;pisz minuty 
        call Dwukropek 
        mov  al,dh             
        call Pisz            ;pisz sekundy  
        ;***
        pop  es         
        pop  ds 
        popa 
Wyskok:         
        iret 
;Procedura wypisujÜca liczbë w kodzie BCD zawartÜ w AL         
Pisz PROC  
        mov  ah,al 
        push cx 
        mov  cl,4       ;przeksztaíç liczbë w kodzie BCD na 
        shl  al,cl      ;dwie binarne zawarte w AH i AL
        shr  al,cl 
        shr  ah,cl 
        pop  cx 
        add  ax,'00' 
        mov  byte ptr es:[di+1],01110000b  ;atrybut 
        mov  byte ptr es:[di+3],01110000b  ;atrybut 
        mov  es:[di],ah 
        mov  es:[di+2],al 
        add  di,4 
        ret 
     ENDP 
      
Dwukropek PROC 
        mov  byte ptr es:[di+1],01110000b  ;atrybut 
        mov  byte ptr es:[di],':' 
        add  di,2 
        ret 
        ENDP                      
;---------------------------------------------- 
Install: 
        call Czy_juz_jest            ;sprawd¶, czy program juß 
                                     ;jest zainstalowany    
        mov  ax,3508h                ;odczytaj adres procedury 
        int  21h                     ;obslugi przerwania 8h 
        mov  Old8s,es                ;i zapamiëtaj go 
        mov  Old8o,bx 
        push cs 
        pop  ds 
        mov  dx,offset zegar         ;ustaw nowy adres procedury 
        mov  ax,2508h                ;obsíugi przerwania  
        int  21h 
        push cs 
        pop  ds         
        mov  dx,offset Hej 
        mov  ah,09h                  
        int  21h                ;wypisz komunikat  
        mov  dx,offset install  ;wyjd¶ i zostaw wszystko przed 
        int  27h                     ;adresem INSTALL 
;--------------------------------         
Czy_juz_jest: 
        mov  ax,3508h 
        int  21h 
        cmp  es:[bx-2],'AB'   ;Sprawd¶, czy przed procedura 
                              ;obsíugi przerwania znajduje sië 
                              ;'AB' 
        jne  Nie_ma           ;jesli nie, to instaluj 
        jmp  Czy_parametry    ;jesli tak, to sprawd¶ paramerty 
Nie_ma: 
        ret 
;--------------------------------        
Czy_parametry: 
        mov  bx,80h                  ;pobierz licznik 
        mov  cl,[bx]                 ;parametr¢w  
        cmp  cl,0 
        je   Bez_prm                   
        jmp  Usun                   ;jesli jest, to usu§ program 
                                    ;z pamiëci 
Bez_prm: 
        push cs 
        pop  ds 
        mov  dx,offset JuzJest 
        mov  ah,09h 
        int  21h 
        mov  ax,4c01h 
        int  21h 
;--------------------------------         
Usun: 
        mov  ax,3508h 
        int  21h           ;pobierz adres procedury obsíugi 8h 
        mov  ds,es:[bx-4]  ;ustaw ˇadres ˇpoprzedniej ˇprocedury 
                           ;obslugi 
        mov  dx,es:[bx-6] 
        mov  ax,2508h 
        int  21h 
        mov  ˇah,49h         ˇ;zwolnij ˇpamiëç ˇzajmowanÜ ˇprzez 
                              ;program 
        int  21h 
        push cs 
        pop  ds 
        mov  dx,offset Deinst 
        mov  ah,09h 
        int  21h 
        mov  ax,4c01h 
        int  21h           
         
JuzJest db 'Zegar jest JUZ zainstalowany.',13,10,'$' 
Hej     db 'Zegar zainstalowany.',13,10,'$' 
Deinst  db 'Zegar zdeinstalowany.',13,10,'$' 
         
CODE ENDS 
 
END Start             
