;Procedura zmienia dlugosc linii
;W zaznaczonym miejscu nalezy wstawic wybrana wartosc
Szerokosc PROC 
     mov  dx,3d4h 
     mov  al,13h 
     mov  ah,szerokosc 
     out  dx,ax 
     ret 
     ENDP 
