;*****************
;*** SHARP.ASM *** 
;*****************
Sharp PROC 
     mov  dx,SHARPS      ;Segment roboczy 
     mov  es,dx 
     mov  dx,0a000h      ;Wyostrzanie obrazu na ekranie 
     mov  ds,dx 
     mov  si,0 
     mov  di,0 
     mov  cx,64000       ;Caíy ekran 
Go: 
     mov  bx,0           ;BX bëdzie sumÜ intensywnoûci 
     sub  si,321 
     push cx 
     mov  cx,3 
     ;Oblicz ˇsumë ˇintensywnoûci ˇkolor¢w 9 punkt¢w (aktualny w 
     ;ûrodku) i odejmij intensywnoûç koloru punktu aktualnego 
Dodaj: 
     lodsb 
     cbw 
     add  bx,ax 
     lodsb 
     cbw
     add  bx,ax 
     lodsb 
     cbw 
     add  bx,ax 
     add  si,317         ;Zejd¶ linië nißej 
     loop Dodaj 
     sub  si,639 
     lodsb 
     cbw 
     sub  bx,ax          ;Odejmij kolor punktu aktualnego 
     mov  cl,3 
     shr  bx,cl          ;Oblicz ûredniÜ arytmetycznÜ 
     pop  cx 
     ;Licz nowÜ intensywnoûç koloru
     mov  al,ds:[si-1] 
     mov  dl,al 
     sub  al,bl 
     add  al,dl 
     ;Sprawd¶ czy kolor "nie przeszedí" zakresu
     cmp  al,64 
     jb   Ok3 
     cmp  al,128 
     jb   Ok1 
     mov  al,0 
     jmp  Ok3 
Ok1: 
     mov  al,63 
Ok3: 
     stosb 
     loop Go 
     ;Rysuj nowy obraz 
     mov  si,0 
     mov  di,0 
     mov  cx,32000 
     mov  dx,ds 
     mov  bx,es 
     mov  ds,bx 
     mov  es,dx 
     rep  movsw 
     ret 
     ENDP 
SHARPS SEGMENT      ;Segment roboczy dla procedury SHARP
Tab  dw 32000 dup(0) 
SHARPS ENDS 
