.model tiny
.code
.386
org 100h

Start:
  jmp  Instaluj

; to co wpiszemy pomiêdzy etykietami: Start oraz Instaluj pozostanie w
; pamiêci po powrocie do DOSu

  db   'To zosta³o w pamiêci i le¿y od³ogiem.'

; koniec czê¶ci rezydentnej

Instaluj:
  mov  ah,9
  mov  dx,offset Napis
  int  21h
  mov  dx,offset Instaluj    ; do DX wpisujemy adres pierwszego bajtu,
  int  27h                   ; który ma byæ zwolniony, wcze¶niejsze
                             ; zostaj± w pamiêci na sta³e

Napis  db 'Program zainstalowany w pamiêci.',13,10,'$'

end Start
