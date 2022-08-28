;Program (LOG.ASM) napisany przez M$(1998).
;
;Opis:
; Program uaktywnia lub chowa partycje (E: na moim dysku)...
; W fizycznym cylindrze 585 dysku twardego zmieniana jest pod ofsetem 1C2h
; wartosc oznaczajaca typ partycji.
; Wratosci:  00 - brak partycji ;  06 - Partycja typu BIGDOS
; Program uruchamiany jest z dwoma parametrami:
; in - uaktywnienie partycji
; out - schowanie partycji

Model Tiny

.Data
 Bufor db 32 dup ('M$(1998) - LOG -')
 Log1 db 'in'
 Log2 db 'out'

.Code
 org 100h

  Begin:
   cmp byte ptr cs:[80h],0       ; sprawdzenie czy jest cos w lini parametrow
   jz Exit

   mov ax,1600h
   int 2fh                       ; sprawdzenie czy program zostal
   cmp al,3                      ; uruchomiony w srodowisku windows
   ja Exit                       ; jesli tak to koniec dzalania programu

   mov ax,0201h                  ; odczyt sektora
   mov bx,offset bufor
   mov cx,4981h
   mov dx,0080h
   int 13h

   mov cx,2h                     ; sprawdzenie linii parametrow
   mov si,82h
   mov di,offset Log1
   cld
   rep cmpsb
   jz LogIn
   inc cx
   inc di
   inc di
   rep cmpsb
   jz LogOut
  Exit: ret

  LogIn:
   cmp byte ptr [bufor+1c2h],06h
   jz Exit
   mov byte ptr [bufor+1c2h],06h    ; BIGDOS
   jmp Write

  LogOut:
   cmp byte ptr [bufor+1c2h],00h
   jz Exit
   mov byte ptr [bufor+1c2h],00h    ; UNUSED

  Write:                            ; Zapis sektorka na dysk
   mov ax,0301h
   mov bx,offset bufor
   mov cx,4981h                     ; CX = obliczony cylinder i sektor
   mov dx,0080h
   int 13h

  EndCode:
   mov ah,0dh                       ; reset dyskowy
   int 21h
   xor ax,ax
   mov es,ax
   mov word ptr es:[0472h],1234h  ; reset bez testu pamieci
   db 0eah,0f0h,0ffh,000h,0f0h    ; jmp far f000:fff0

 End Begin





