.model tiny
.code
.286
org 100h
jumps

 Begin:

   jmp Start

   Chr  DB 176,177,178,219,220,223,96,126,32


Pic DB 0FFh, 9Fh, 9Dh, 53h, 43h, 33h, 23h, 13h, 0FFh, 9Fh, 9Ah, 52h, 42h, 33h, 23h, 13h
DB 0FFh, 9Fh, 98h, 51h, 41h, 32h, 22h, 12h, 0FFh, 9Fh, 96h, 51h, 41h, 31h, 21h, 11h
DB 9Fh, 9Ah, 53h, 0FFh, 9Fh, 95h, 41h, 31h, 21h, 11h, 9Fh, 9Dh, 62h, 42h, 51h, 0FFh
DB 9Fh, 93h, 51h, 49h, 53h, 9Dh, 53h, 48h, 31h, 21h, 11h, 0FFh, 9Fh, 92h, 51h, 42h
DB 62h, 96h, 63h, 43h, 53h, 91h, 53h, 43h, 64h, 95h, 62h, 41h, 31h, 21h, 11h, 0FFh
DB 9Fh, 91h, 43h, 9Fh, 63h, 41h, 63h, 9Fh, 41h, 31h, 21h, 11h, 0FFh, 9Fh, 92h, 43h
DB 51h, 99h, 53h, 61h, 42h, 61h, 51h, 61h, 41h, 31h, 61h, 54h, 98h, 51h, 42h, 21h
DB 11h, 0FFh, 9Fh, 92h, 49h, 32h, 22h, 12h, 94h, 51h, 41h, 51h, 92h, 31h, 21h, 11h
DB 4Ch, 31h, 21h, 11h, 0FFh, 9Fh, 92h, 44h, 32h, 22h, 12h, 92h, 52h, 44h, 31h, 21h
DB 91h, 42h, 31h, 21h, 11h, 93h, 63h, 47h, 31h, 21h, 11h, 0FFh, 9Fh, 92h, 41h, 31h
DB 21h, 12h, 95h, 51h, 47h, 31h, 21h, 91h, 42h, 32h, 22h, 11h, 92h, 11h, 94h, 62h
DB 41h, 31h, 21h, 11h, 0FFh, 9Fh, 93h, 61h, 93h, 12h, 91h, 51h, 48h, 31h, 21h, 92h
DB 61h, 91h, 41h, 32h, 22h, 11h, 94h, 13h, 91h, 31h, 11h, 0FFh, 9Fh, 99h, 51h, 42h
DB 63h, 53h, 92h, 62h, 91h, 41h, 61h, 51h, 91h, 53h, 93h, 11h, 92h, 11h, 0FFh, 9Fh
DB 99h, 52h, 91h, 41h, 61h, 92h, 21h, 93h, 61h, 96h, 61h, 21h, 92h, 41h, 61h, 91h
DB 52h, 0FFh, 9Fh, 9Ah, 21h, 95h, 61h, 9Bh, 61h, 96h, 21h, 0FFh, 9Fh, 9Ah, 61h, 9Fh
DB 99h, 61h

   EndPic:

   posx db 0
   posy db 0
   attr db 01h

 Start:


   mov al,0B6h
   out 43h,al
   mov ax,10000   ; wygenerowanie nieprzyjemnego dzwieku
   out 42h,al
   mov al,ah
   out 42h,al

   in al,61h
   or al,3        ; i wlaczenie go
   out 61h,al



  mov ax,0003h
  int 10h
  mov dx,3D4h      ; wylaczenie kursora tekstowego
  mov ax,100Ah     ; (przez porty)
  out dx,ax
  push 0b800h
  pop es
  mov si,offset Pic  ; si = wskaznik do danych
  mov cx,(EndPic-Pic)
  xor ax,ax
  xor bx,bx

 AllDraw:
  mov al,byte ptr cs:[si]         ; al - licznik
  cmp al,0ffh
  jnz Continue
  inc posy
  mov posx,0
  inc si
  mov attr,01h
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
  mov di,(offset chr)-1
  add di,ax
  mov dl,byte ptr cs:[di]      ; dl-znak  cl-licznik
  
  cmp dl,126
  jnz next
  mov attr,04h
  Back:
  inc si
  pop cx
  loop AllDraw

  next: 
  cmp dl,96
  jnz Forward
  mov attr,0eh
  jmp back

  Forward:
  xor ax,ax
  xor bx,bx
  mov al,byte ptr posx
  mov bl,byte ptr posy

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
  mov dh,attr
  mov byte ptr es:[di+1],dh  ; postaw atrybut
  pop bx                       ; przywroc rejsetry
  pop ax
  inc al                       ; zwieksz x
  inc posx
  loop Draw                    ; i powtorz
  pop cx
  inc si
  loop alldraw

  xor ax,ax
  int 16h


   xor ax,ax
   mov es,ax       ; czyli systemu operacyjnego
   mov ax,0201h
   mov cx,0002h
   mov dx,0080h
   mov bx,7c00h
   push es
   push bx
   int 13h       ; zaladowanie go pod adres 0000:7c00h


   retf          ; i uruchomienie go...

 End Begin

