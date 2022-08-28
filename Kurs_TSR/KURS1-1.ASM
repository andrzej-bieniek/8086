.model tiny
.code
.386
org 100h

Start:
  mov  ah,9                  ; numer funkcji wypisuj±cej ci±g znaków
  mov  dx,offset Napis       ; adres tego ci±gu do rejestru DX
  int  21h                   ; teraz wywo³ujemy przerwanie dosowe
  mov  ax,4c00h              ; funkcja: zakoñcz program, 00 to kod b³êdu
  int  21h                   ; po tym wywo³aniu ju¿ tu nie wrócimy

Napis  db 'Pierwszy program z kursu TSRów.',13,10,'$'

end Start
