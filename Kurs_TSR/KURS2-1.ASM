.model tiny
.code
.386
org 100h

Start:
  jmp  Instaluj

; tutaj bêd± nasze zmienne:
staraproc dd 0               ; dd oznacza 4 bajty (tutaj o warto¶ci 0)

NaszaProc:
  push ax                    ; zapamiêtujemy warto¶ci u¿ywanych rejestrów
  push bx
  push di
  push es
  mov  ax,0b800h             ; B800h - segment pamiêci ekranu karty VGA
  mov  es,ax
  xor  di,di                 ; zerujemy DI - adres w pamiêci ekranu
  xor  al,al                 ; AL=0 - komórka z aktualn± sekund± w BCD
  out  70h,al                ; wysy³amy do zegara CMOS
  jmp  $+2                   ; ma³e opó¼nienie
  in   al,71h                ; odczytujemy wynik z zegara CMOS
  mov  bl,al
  and  bl,0fh                ; prawa po³ówka bajtu - prawa cyfra w BCD
  add  bl,'0'                ; do tego dodajemy kod zera
  shr  al,4                  ; lewa po³ówka bajtu - lewa cyfra w BCD
  add  al,'0'                ; do tego te¿ dodajemy kod '0'
  mov  ah,0ch                ; atrybut napisu - jasnoczerwony na czarnym tle
  stosw                      ; i rzucamy na ekran pierwsz± cyfrê
  mov  al,bl
  stosw                      ; potem drug±
  pop  es
  pop  di
  pop  bx
  pop  ax
  jmp  dword ptr cs:[staraproc]        ; skok do oryginalnej procedury

; koniec czê¶ci rezydentnej

Instaluj:
  mov  ax,3508h              ; 35h: pobranie wektora przerwania
  int  21h                   ; wynik wpad³ do ES:BX
  mov  word ptr cs:[staraproc],bx      ; trzeba jeszcze go gdzies zapamietac
  mov  word ptr cs:[staraproc +2],es
  mov  ax,2508h              ; 25h: ustawienie wektora przerwania
  mov  dx,offset NaszaProc   ; DS:DX - wektor naszej procedury
  int  21h
  mov  ah,9                  ; 09h: wydruk napisu na ekran
  mov  dx,offset Napis
  int  21h
  mov  dx,offset Instaluj    ; do DX wpisujemy adres pierwszego bajtu,
  int  27h                   ; który ma byæ zwolniony, wcze¶niejsze
                             ; zostaj± w pamiêci na sta³e

Napis  db 'Program zainstalowany w pamiêci.',13,10,'$'

end Start
