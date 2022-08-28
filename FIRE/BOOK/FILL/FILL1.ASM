;*****************
;*** FILL1.ASM *** 
;*****************
R_ofs     dw ?      ;Zmienna pomocnicza 
Xf        dw ?      ;Kolumna, od kt¢rej bëdzie wypeíniany obszar 
Yf        dw ?      ;Wiersz, od kt¢rego bëdzie wypeíniany obszar 
Xp        dw ?      ;Zmienna pomocnicza 
Long      dw ?      ;Iloûç wypeínianych linii 
f_color   db ?      ;Kolor wypeíniania 
stop_color db ?     ;Kolor ramki figury 
Fill PROC 
     mov  dx,0a000h ;Wypeínianie bezpoûrednio na ekranie 
     mov  es,dx
     ;Oblicz offset punktu poczÜtkowego 
     mov  ax,Yf     ;Oblicz offset linii
     mov  bx,320 
     mul  bx        ;mnoßÜc jej numer przez 320
     add  ax,Xf     ;Oblicz offset punktu
     mov  R_ofs,ax  ;Zapamiëtaj w zmiennej
     mov  di,ax 
     mov  cx,long   ;Iloûç linii do wypeínienia
     ;Znajd¶ pierwszy punkt 
First_point: 
     push cx 
     mov  cx,319    ;Szukaj od kolumny Xf
     sub  cx,Xf     ;do ewentualnego ko§ca linii
     mov  al,Stop_color ;Kolor punktu zatrzymujÜcego 
     repne scasb    ;Przeszukuj
     jcxz Next_line ;Jeûli koniec tej linii, to bierz nastëpnÜ
     mov  xp,cx     ;Zapamiëtaj CX
End_of_first: 
     repe scasb     ;Szukaj punktu r¢ßnego od zatrzymujÜcego 
                    ;gdyß ˇmoße ˇzaistnieç ˇtaka ˇsytuacja, ße w 
                    ;linii ˇbëdzie ˇkilka ˇkolejnych ˇpunkt¢w ˇw 
                    ;kolorze zatrzymujÜcym
     jcxz Next_line ;Jeûli caía linia wypeíniona, to bierz 
                    ;linië nastëpnÜ
Second_point: 
     repne scasb    ;Szukaj punktu ko§cowego
     jcxz Next_line ;Jeûli go nie ma, to bierz nastëpnÜ linië
     sub  Xp,cx     ;Oblicz r¢ßnicë miëdzy ostatnim a pierwszym 
                    ;Wyznacza ona iloûç punkt¢w do zamalowania
     mov  cx,Xp 
     sub  di,cx     ;Wr¢ç do punktu pierwszego
     dec  di 
     inc  cx 
     mov  al,f_color ;Kolor wypeíniania
     rep  stosb     ;Wypeíniaj 
Next_line: 
     pop  cx 
     add  R_ofs,320 
     mov  di,R_ofs 
     loop First_point 
     ret 
     ENDP 
