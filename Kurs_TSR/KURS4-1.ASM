.model tiny
.code
.386
org 100h

Start:
  jmp  StartTutaj

; wersja naszego TSRa:
wersja     db 'Beep v 1.0$'
; tutaj bêd± nasze zmienne:
staraklaw  dd 0
staramult  dd 0
flipflop   db 1              ; 0 - beep nieaktywny, 1 - beep aktywny
niemamnie  db 0              ; 1 - ca³y TSR nieaktywny

;***** procedura obs³uguj±ca przerwanie klawiatury *****

PrzerwKlaw:
  cmp  byte ptr cs:[niemamnie],0 ; sprawdzenie, czy ca³y TSR jest aktywny
  je   AktywOK
  jmp  dword ptr cs:[staraklaw] ; skok do oryginalnej procedury
AktywOK:
  push ax
  in   al,60h                ; scan-code klawisza do AL
  cmp  al,0d2h
  je   ToInsert              ; skok, gdy puszczono Insert
  cmp  byte ptr cs:[flipflop],0
  je   PowrotKlaw            ; skok, gdy beep nie jest aktywny
  test al,80h
  jnz  Puszczony             ; skok, gdy puszczono inny klawisz
Nacisniety:
  in   al,61h
  or   al,3                  ; w³±czamy d¼wiêk
  out  61h,al
  jmp  PowrotKlaw
Puszczony:
  in   al,61h
  and  al,0fch               ; wy³±czamy d¼wiêk
  out  61h,al
  jmp  PowrotKlaw
ToInsert:                    ; puszczono klawisz Insert
  push es
  xor  ax,ax
  mov  es,ax                 ; ES=0 - segment zmiennych BIOSu
  mov  al,byte ptr es:[417h] ; pierwszy bajt stanu klawiatury
  pop  es
  and  al,0ch                ; badamy bity 2. i 3.
  cmp  al,0ch                ; skok, gdy nie s± jednocze¶nie
  jne  PowrotKlaw            ; wci¶niête Alt i Ctrl
  xor  byte ptr cs:[flipflop],1 ; zmiana prze³±cznika aktywno¶ci
  cmp  [flipflop],1
  je   PowrotKlaw            ; skok gdy dopiero co w³±czyli¶my
  in   al,61h
  and  al,0fch               ; wy³±czamy d¼wiêk
  out  61h,al
PowrotKlaw:
  pop  ax
  jmp  dword ptr cs:[staraklaw] ; skok do oryginalnej procedury

;***** procedura obs³uguj±ca przerwanie Multiplex Interrupt *****

PrzerwMxI:
  cmp  byte ptr cs:[niemamnie],0
  jne  PowrotMxI             ; skok gdy ca³y TSR jest nieaktywny
  cmp  ah,90h                ; sprawdzenie, czy chodzi o nasz proces
  je   ToJa
PowrotMxI:
  jmp  dword ptr cs:[staramult] ; jak nie to skok pod oryginalny adres
ToJa:
  or   al,al                 ; zlecenie nr 0 ?
  jne  Nie0
  mov  al,0ffh               ; AL=0ffh - TSR obecny w pamiêci
  mov  bx,cs                 ; do BX wrzucamy segment kodu rezydenta
  iret                       ; powrót z przerwania
Nie0:
  cmp  al,1                  ; zlecenie nr 1 ?
  jne  Nie1
  mov  ax,cs
  mov  es,ax
  mov  di,offset wersja      ; do ES:DI wrzucamy adres napisu z nr wersji
  iret
Nie1:
  mov  al,0ffh               ; nie znamy innych zleceñ, zwracamy 0ffh
  iret

; koniec czê¶ci rezydentnej

StartTutaj:
  mov  ah,9                  ; 09h: wydruk nag³ówka na ekran
  mov  dx,offset Logo
  int  21h
  mov  ax,9000h              ; sprawdzenie, czy beep jest ju¿ w pamiêci
  int  2fh                   ; poprzez wywo³anie Multiplex Interrupt
  cmp  al,0ffh
  jne  Instaluj              ; instalujemy, gdy nie ma go jeszcze w pamiêci

Rozinstaluj:
  push bx                    ; zapamiêtujemy na stosie segment kodu TSRa
  mov  dx,offset NrWer
  mov  ah,9                  ; 09h: wydruk napisu na ekran
  int  21h
  mov  ax,9001h              ; pytanie o wska¼nik do napisu z nr wersji
  int  2fh                   ; wynik przyszed³ w ES:DI
  mov  ax,es
  mov  ds,ax
  mov  dx,di
  mov  ah,9                  ; 09h: wydruk napisu na ekran
  int  21h                   ; drukujemy numer wersji
  mov  ax,cs
  mov  ds,ax
  pop  di                    ; przywracamy do DI segment kodu TSRa
  mov  ax,3509h              ; 35h: pobranie wektora przerwania
  int  21h                   ; do rejestrów ES:BX
  mov  ax,es                 ;*** konstrukcja "na oko³o", poniewa¿ nie ma
  cmp  ax,di                 ;*** w 80x86 rozkazu: cmp es,di
  je   JestOstatni           ; skok gdy TSR by³ instalowany jako ostatni
TuDezaktywacja:
  mov  es,di                 ; do ES segment kodu TSRa
  mov  byte ptr es:[niemamnie],1 ; dezaktywacja rezydenta
  mov  ah,9                  ; 09h: wydruk napisu na ekran
  mov  dx,offset Dezakt
  int  21h
  in   al,61h
  and  al,0fch               ; wy³±czamy d¼wiêk
  out  61h,al
  mov  ax,4c02h              ; 4ch: powrót do DOSu, w AL kod b³êdu
  int  21h
JestOstatni:                 ; TSR by³ instalowany jako ostatni z ³añcucha
  mov  ax,352fh              ; int 9h, jeszcze sprawdzamy wektor MxI
  int  21h
  mov  ax,es                 ;*** konstrukcja "na oko³o" poniewa¿ nie ma
  cmp  ax,di                 ;*** w 80x86 rozkazu: cmp es,di
  jne  TuDezaktywacja        ; skok gdy nie by³ ostatni w int 2fh
  mov  dx,word ptr es:[staraklaw]
  mov  ax,word ptr es:[staraklaw +2]
  mov  ds,ax
  cli
  mov  ax,2509h              ; 25h: ustawienie wektora przerwania
  int  21h                   ; przywracamy dawny adres obs³ugi klawiatury
  mov  dx,word ptr es:[staramult]
  mov  ax,word ptr es:[staramult +2]
  mov  ds,ax
  mov  ax,252fh              ; 25h: ustawienie wektora przerwania
  int  21h                   ; przywracamy jeszcze adres obs³ugi Multiplex I.
  sti
  mov  ah,49h                ; 49h: zwolnienie bloku pamiêci z TSRem
  int  21h                   ; w ES mamy segment TSRa
  mov  ax,cs
  mov  ds,ax                 ; przywracamy do DS segment naszego programu
  mov  ah,9                  ; 09h: wydruk napisu na ekran
  mov  dx,offset Uninst
  int  21h                   ; drukujemy komunikat o pomy¶lym usuniêciu TSRa
  in   al,61h
  and  al,0fch               ; wy³±czamy d¼wiêk
  out  61h,al
  mov  ax,4c02h              ; 4ch: powrót do DOSu, w AL kod b³êdu
  int  21h

Instaluj:
  mov  ax,word ptr ds:[2ch]  ; numer segmentu ¶rodowiska odczytujemy z PSP
  mov  es,ax                 ; i ³adujemy do ES
  mov  ah,49h                ; 49h: zwolnienie bloku pamiêci
  int  21h
  mov  ax,3509h              ; 35h: pobranie wektora przerwania
  int  21h                   ; wynik wpad³ do ES:BX
  mov  word ptr cs:[staraklaw],bx ; trzeba jeszcze go gdzies zapamietac
  mov  word ptr cs:[staraklaw +2],es
  mov  ax,352fh              ; 35h: pobranie wektora przerwania
  int  21h
  mov  word ptr cs:[staramult],bx
  mov  word ptr cs:[staramult +2],es
  cli
  mov  ax,2509h              ; 25h: ustawienie wektora przerwania
  mov  dx,offset PrzerwKlaw  ; DS:DX - wektor naszej procedury
  int  21h
  mov  ax,252fh              ; 25h: ustawienie wektora przerwania
  mov  dx,offset PrzerwMxI   ; DS:DX - wektor obs³ugi Multiplex Interrupt
  int  21h
  sti
  mov  ah,9                  ; 09h: wydruk napisu na ekran
  mov  dx,offset Napis
  int  21h
  in   al,61h
  and  al,0fch               ; wy³±czamy d¼wiêk
  out  61h,al
  mov  dx,offset StartTutaj  ; do DX wpisujemy adres pierwszego bajtu,
  int  27h                   ; który ma byæ zwolniony, wcze¶niejsze
                             ; zostaj± w pamiêci na sta³e

Logo   db 'Beep 1996.',13,10,'$'
NrWer  db 'Program jest ju¿ zainstalowany, wersja: $'
Dezakt db 13,10,'Program nie by³ instalowany jako ostatni. Dezaktywowano.'
       db 13,10,'$'
Uninst db 13,10,'Program by³ instalowany jako ostatni. Rozinstalowano.'
       db 13,10,'$'
Napis  db 'Program zainstalowany w pamiêci.',13,10,'$'

end Start
