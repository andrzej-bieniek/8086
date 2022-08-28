;Procedura dzieli obraz na dwie niezalezne czesci.
;W zaznaczone miejsce nalezy wstawic wybrana wartosc.
;W zaleznosci od potrzeb nalezy wybrac czy bity 8 i 9 maja
;byc kasowane czy ustawiane
Dziel_obraz PROC 
     mov  dx,3d4h 
     mov  al,18h 
     mov  ah,numer linii dzielacej (mniej znaczace bity)
     out  dx,ax 
     ;Jesli ÿnumer ÿlinii ÿjest wiekszy od 255 to nalezy zmienic 
     ;bity 8 i 9 rejestru dzielenia obrazu. 
     mov  dx,3d4h 
     mov  al,07h 
     out  dx,al 
     inc  dx 
     in   al,dx 
     ;*** ustawienie bitu 8 *** 
     or   al,00010000b 
     ;*** skasowanie bitu 8 *** 
     and  al,11101111b 

     out  dx,al 

     mov  dx,3d4h 
     mov  al,09h 
     out  dx,al 
     inc  dx 
     in   al,dx 
     ;*** ustawienie bitu 9 *** 
     or   al,01000000b 
     ;*** skasowanie bitu 9 *** 
     and  al,10111111b 

     out  dx,al 
     ret 
     ENDP 
