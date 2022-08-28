.model tiny
.code
.386
org 100h

Start:
  jmp  StartTutaj

; wersja naszego TSRa:
wersja     db 'Grabber v 1.0$'
; tutaj bêd± nasze zmienne:
staraklaw  dd 0
staramult  dd 0
adresINDOS dd 0
flagaakt   db 0              ; wewnêtrzna flaga aktywno¶ci (1=aktywny)
nazwapliku db 'C:\TEMP\OBRAZ'
numerek    db '000.BMP',0
BMPheader  db 42h,4Dh,36h,0FEh,0,0,0,0,0,0,36h,4,0,0,28h,0,0,0,40h,1,0,0
           db 0C8h,0,0,0,1,0,8,0,0,0,0,0,0,0FAh,0,0,0,0,0,0,0,0,0,0,0,1,0,0
           db 0,1,0,0        ; nag³ówek ma 54 bajty, za nim nastêpuj±
paleta     db 1024 dup (0)   ; sk³adowe BGR-  ->  paleta kolorów

;***** procedura obs³uguj±ca przerwanie klawiatury *****

PrzerwKlaw:
  push ax
  push bx
  push ds
  cmp  byte ptr cs:[flagaakt],1 ; sprawdzenie, czy TSR w³a¶nie zapisuje
  jne  AktywOK               ; skok gdy nie zapisujemy (TSR nie pracuje)
WywolajOryg:
  pop  ds
  pop  bx
  pop  ax
  jmp  dword ptr cs:[staraklaw] ; skok do oryginalnej procedury obs³ugi
AktywOK:
  in   al,60h                ; scan-code klawisza do AL
  cmp  al,053h
  jne  WywolajOryg           ; skok gdy nie naci¶niêto Delete
  xor  ax,ax
  mov  ds,ax                 ; ES=0 - segment zmiennych BIOSu
  mov  ax,word ptr ds:[417h] ; dwa bajty stanu klawiatury
  and  ax,0106h              ; 01 - Lewy Ctrl, 06 - Lewy Shift + Ctrl
  cmp  ax,0106h
  jne  WywolajOryg           ; skok gdy nie sa wszystkie wcisniete
  mov  byte ptr cs:[flagaakt],1 ; zaznaczamy aktywno¶æ naszego rezydenta
  in   al,61h                ;+ znak dla kontrolera klawiatury, ¿e
  mov  ah,al                 ;+ pobrali¶my ju¿ znak z portu 60h i mo¿e on
  or   al,80h                ;+ dalej pracowaæ
  out  61h,al                ;+
  mov  al,ah                 ;+
  out  61h,al                ;+
  mov  al,20h                ;- znak dla kontrolera przerwañ
  out  20h,al                ;- (tzw. EOI - End Of Interrupt)
  sti                        ; teraz ju¿ mo¿emy spokojnie w³±czyæ przerwania
  cmp  byte ptr ds:[449h],13h ; numer aktywnego trybu graficznego
  jne  NieMoznaTeraz         ; skok gdy jest inny ni¿ 13h
;-----> wykomentuj odt±d                              vvvvv
  mov  ax,word ptr cs:[adresINDOS]
  mov  ds,ax
  mov  bx,word ptr cs:[adresINDOS +2]
  mov  al,ds:[bx]            ; adres flagi INDOS do DS:BX
  or   al,al                 ; sprawd¼ flagê aktywno¶ci DOSu - INDOS
  jnz  NieMoznaTeraz         ; skok gdy DOS nic teraz nie wykonuje
;-----> dot±d, aby rezydent nie sprawdza³ flagi INDOS ^^^^^
  jmp  Uaktywnij
NieMoznaTeraz:
  in   al,61h
  or   al,3                  ; w³±czamy d¼wiêk
  out  61h,al
  xor  ax,ax
  mov  ds,ax                 ; DS=0 - segment zmiennych BIOSu
  mov  al,byte ptr ds:[46ch]
  add  al,2                  ; czekamy przez 2 przerwania
CzekajNaZegar:
  cmp  al,byte ptr ds:[46ch] ; sprawd¼, czy zmieni³ siê licznik zegara
  jne  CzekajNaZegar         ; jeszcze nie doczekalismy - sprawd¼ jeszcze raz
  in   al,61h
  and  al,0fch               ; wy³±czamy d¼wiêk
  out  61h,al
  pop  ds
  pop  bx
  pop  ax
  cli                        ; wy³±czamy przerwania
  mov  byte ptr cs:[flagaakt],0 ; zaznaczamy nieaktywno¶æ naszego rezydenta
  iret                       ; i powracamy z przerwania bez wywo³ywania
                             ; oryginalnej procedury obs³ugi
Uaktywnij:
  push cx
  push dx                    ; k³adziemy na stos pozosta³e rejestry
  push si
  push di
  push es
  push bp

;*** w tym miejscu zaczyna siê w³a¶ciwa tre¶æ tego, co bêdzie robiæ ***
;******************* nasz rezydent po uaktywnieniu ********************

  mov  ax,cs
  mov  es,ax
  mov  di,offset paleta      ; odczytamy paletê kolorów karty VGA pod ES:DI
  xor  al,al                 ; AL=0 - numer pierwszego koloru
  mov  dx,3c7h
  out  dx,al
  mov  dl,0c9h
  mov  cx,256                ; odczytujemy sk³adowe 256 kolorów
KolejnyKolor:
  in   al,dx
  shl  al,2                  ; mno¿ymy przez 4 (przesuwaj±c o 2 bity w lewo)
  mov  bl,al                 ; sk³adowa R do BL
  in   al,dx
  shl  al,2
  mov  ah,al                 ; sk³adowa G do AH
  in   al,dx
  shl  al,2
  stosw                      ; zapisujemy AX (sk³adowe: B i G) pod ES:DI
  mov  al,bl
  xor  ah,ah
  stosw                      ; zapisujemy sk³adowe R i bajt równy 0
  loop KolejnyKolor          ; zapêtlamy aby odczytaæ wszystkie kolory
  mov  ax,cs
  mov  ds,ax
  mov  dx,offset nazwapliku
  mov  ah,3ch                ; 3Ch: utworzenie nowego pliku
  mov  cx,20h                ; ustawiamy tylko atrybut Archive
  int  21h
  jc   NieWyszlo             ; skok gdy b³±d
  mov  bx,ax
  mov  cx,1078               ; 54 bajty nag³ówka + 1024 bajty palety kolorów
  mov  dx,offset BMPheader
  mov  ah,40h                ; 40h: pisanie przez doj¶cie
  int  21h
  jc   ZamknijPlik           ; skok gdy b³±d
  mov  ax,0a000h
  mov  ds,ax                 ; segment pamiêci ekranu w trybie 13h
  mov  dx,0F8C0h             ; offset ostatniej (199.) linii ekranu
KolejnaLinia:
  mov  cx,320                ; d³ugo¶æ jednej linii (w bajtach)
  mov  ah,40h                ; 40h: pisanie przez doj¶cie
  int  21h
  jc   ZamknijPlik           ; skok gdy b³±d
  cmp  ax,320
  jne  ZamknijPlik           ; skok gdy zapisano nie tyle, ile chcieli¶my
  sub  dx,320                ; oblicz offset poprzedniej linii
  jnc  KolejnaLinia          ; skok gdy jeszcze zosta³y wy¿ej jakie¶ linie
  inc  byte ptr cs:[numerek+2]      ; zwiêkszamy praw± cyfrê numeru
  cmp  byte ptr cs:[numerek+2],':'  ; nastêpnym znakiem po '9' jest ':'
  jne  ZamknijPlik
  mov  byte ptr cs:[numerek+2],'0'
  inc  byte ptr cs:[numerek+1]      ; zwiêkszamy ¶rodkow± cyfrê numeru
  cmp  byte ptr cs:[numerek+1],':'  ; nastêpnym znakiem po '9' jest ':'
  jne  ZamknijPlik
  mov  byte ptr cs:[numerek+1],'0'
  inc  byte ptr cs:[numerek]        ; zwiêkszamy lew± cyfrê numeru
  cmp  byte ptr cs:[numerek],':'    ; nastêpnym znakiem po '9' jest ':'
  jne  ZamknijPlik
  mov  byte ptr cs:[numerek],'0'    ; przekroczyli¶my zakres - kto¶ zapisa³
                                    ; ponad 999 plików ?!?
ZamknijPlik:
  mov  ah,3eh                ; 3Eh: zamykanie doj¶cia
  int  21h
NieWyszlo:
  pop  bp
  pop  es
  pop  di
  pop  si
  pop  dx
  pop  cx
  pop  ds
  pop  bx
  pop  ax
  cli                        ; wy³±czamy przerwania
  mov  byte ptr cs:[flagaakt],0 ; zaznaczamy nieaktywno¶æ naszego rezydenta
  iret

;***** procedura obs³uguj±ca przerwanie Multiplex Interrupt *****

PrzerwMxI:
  cmp  ah,91h                ; sprawdzenie, czy chodzi o nasz proces
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

;*********************************
;*** KONIEC CZÊ¦CI REZYDENTNEJ ***
;*********************************

StartTutaj:
  mov  ah,9                  ; 09h: wydruk nag³ówka na ekran
  mov  dx,offset Logo
  int  21h
  mov  ax,9100h              ; sprawdzenie, czy grabber jest ju¿ w pamiêci
  int  2fh                   ; poprzez wywo³anie Multiplex Interrupt
  cmp  al,0ffh
  jne  Instaluj              ; instalujemy, gdy nie ma go jeszcze w pamiêci

Rozinstaluj:
  push bx                    ; zapamiêtujemy na stosie segment kodu TSRa
  mov  ax,cs
  mov  ds,ax
  mov  dx,offset NrWer
  mov  ah,9                  ; 09h: wydruk napisu na ekran
  int  21h
  mov  ax,9101h              ; pytanie o wska¼nik do napisu z nr wersji
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
  mov  ah,34h                ; 34h: pobranie adresu flagi INDOS
  int  21h                   ; wynik wpad³ do ES:BX
  mov  word ptr cs:[adresINDOS],bx
  mov  word ptr cs:[adresINDOS +2],es
  mov  ax,3509h              ; 35h: pobranie wektora przerwania
  int  21h                   ; wynik wpad³ do ES:BX
  mov  word ptr cs:[staraklaw],bx
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
  in   al,61h                ; na wszelki wypadek wy³±czamy d¼wiêk
  and  al,0fch
  out  61h,al
  mov  dx,offset StartTutaj  ; do DX wpisujemy adres pierwszego bajtu,
  int  27h                   ; który ma byæ zwolniony, wcze¶niejsze
                             ; zostaj± w pamiêci na sta³e

Logo   db 'Grabber 1997.',13,10,'$'
NrWer  db 'Program jest ju¿ zainstalowany, wersja: $'
Dezakt db 13,10,'Program nie by³ instalowany jako ostatni. Nie mo¿na '
       db 'rozinstalowaæ.',13,10,'$'
Uninst db 13,10,'Program by³ instalowany jako ostatni. Rozinstalowano.'
       db 13,10,'$'
Napis  db 'Program zainstalowany w pamiêci.',13,10,'$'

end Start
