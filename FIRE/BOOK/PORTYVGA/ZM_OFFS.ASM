;Procedura zmienia adres poczatku wyswietlanego obrazu
;W zaznaczone miejsca nalezy wstawic wybrane wartosci
Zmien_offset PROC 
     mov  3d4h 
     mov  al,0ch 
     mov  ah,high 
     out  dx,ax 
     inc  al        ;(0Dh) 
     mov  ah,low 
     out  dx,ax 
     ret 
     ENDP 
