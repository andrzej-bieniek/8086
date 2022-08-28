;Program (PICTURE.ASM) napisany przez M$(1998).
;
;Opis:
; Program na podstawie tablicy Picture wyswietla na ekranie znak radioaktywnosci.

.model tiny
.data

 Picture db 0Ch,04h,1Fh,04h,00h,0Ah,07h,1Eh,07h,00h,08h,09h,1Eh,09h,00h
         db 07h,0Bh,1Dh,0Bh,00h,06h,0Ch,1Dh,0Ch,00h,05h,0Eh,1Ch,0Eh,00h
         db 04h,0Fh,1Ch,0Fh,00h,03h,11h,1Bh,11h,00h,03h,11h,1Bh,11h,00h
         db 02h,13h,1Ah,13h,00h,02h,13h,1Ah,13h,00h,01h,12h,16h,03h,1Ch,12h
         db 00h,01h,11h,14h,07h,1Dh,11h,00h,01h,10h,13h,09h,1Eh,10h,00h
         db 01h,10h,12h,0Bh,1Eh,10h,00h,01h,0Fh,12h,0Bh,1Fh,0Fh,00h,06h,0Ah
         db 11h,0Dh,1Fh,0Ah,00h,0Ch,04h,11h,0Dh,1Fh,04h,00h,12h,0Bh,00h
         db 12h,0Bh,00h,13h,09h,00h,14h,07h,00h,12h,01h,16h,03h,1Ch,01h
         db 00h,11h,04h,1Ah,04h,00h,11h,0Dh,00h,10h,0Fh,00h,10h,0Fh
         db 00h,0Fh,11h,00h,0Fh,11h,00h,0Eh,13h,00h,0Eh,13h,00h
         db 0Dh,15h,00h,0Dh,15h,00h,0Ch,17h,00h,0Eh,13h,00h,10h,0Fh
         db 00h,13h,09h,0FFh
.code
.286
  org 100h

  Begin:
   mov ax,0003h
   int 10h          ; tryb tekstowy 80x25
   mov ax,1112h
   mov bl,00h
   int 10h          ; rozmiar znakow 8x8
   mov dx,3D4h      ; wylaczenie kursora tekstowego
   mov ax,100Ah     ; (przez porty)
   out dx,ax
   mov al,0Bh
   out dx,ax
   push 0B800h
   pop es           ; es = $B800 = Segment pamieci ekranu
   mov cx,4000
   xor di,di
   mov ax,0EDBh
   cld
   rep stosw        ; wyczyszczenie pamieci
   mov si,offset Picture   ; si = wskaznik do danych
   xor ax,ax
   mov bx,6
  AllDraw:
   mov cl,byte ptr ds:[si] ; pobierz dana
   cmp cl,0
   jz NextLine             ; jezeli cl=0 to nastepna lina
   cmp cl,0ffh
   jz EndDraw              ; jezeli cl=255 to koniec rysowania
   mov al,cl
   add ax,15               ; ofset + 15 (tak zeby wyszedl na srodku)
   inc si                  ; przesun wskaznik
   mov cl,byte ptr ds:[si] ; pobierz licznik
  Draw:
   push ax                 ; wypisanie znaku  ax = x  bx = y
   push bx
   mov di,bx               ; obliczenie ofsetu pamieci ekranu
   shl bx,7                ; wg wzoru:
   shl di,5                ;           Ofs = Y * 160 + X * 2
   add bx,di               ; dodawanie...
   shl ax,1                ; ... i przesuniecia bitowe sa szybsze
   add ax,bx
   mov di,ax
   mov byte ptr es:[di],0DBh    ; wypisz znak
   mov byte ptr es:[di+1],0CEh  ; postaw atrybut
   pop bx                       ; przywroc rejsetry
   pop ax
   inc ax                       ; zwieksz x
   loop Draw                    ; i powtorz
   inc si                       ; zwieksz wskaznik si
   jmp AllDraw;                 ; i powtorz cala procedure
  NextLine:
   inc bx                       ; zwieksz y
   inc si
   jmp AllDraw;
  EndDraw:
   xor ax,ax
   int 16h                      ; Poczekaj na klwaisz...
   mov ax,0003h
   int 10h                      ; przywroc tryb 80x25
   ret                          ; powrot do int 20h
  End Begin
