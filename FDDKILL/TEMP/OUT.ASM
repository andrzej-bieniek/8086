.model tiny
.code
.286
jumps
 org 100h

 Begin:

   jmp Start

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

 PutChar Proc       ; wypisanie znaku  al = x  bl = y  dl = char  dh = attr
  push ax
  push bx
  push dx
  push di
  push es
  push 0b800h
  pop es
  mov di,bx               ; obliczenie ofsetu pamieci ekranu
  shl bx,7                ; wg wzoru:
  shl di,5                ;           Ofs = Y * 160 + X * 2
  add bx,di               ; dodawanie...
  shl ax,1                ; ... i przesuniecia bitowe sa szybsze
  add ax,bx
  mov di,ax
  mov byte ptr es:[di],dl    ; wypisz znak
  mov byte ptr es:[di+1],dh  ; postaw atrybut
  pop es
  pop di
  pop dx
  pop bx
  pop ax
  ret
 PutChar EndP

 Delay Proc            ; cx - delay
  push ax
  push bx
  push di
 Pause:
  mov ax,0040h
  push ax
  pop es
  mov di,006ch
  mov bl,es:[di]
  @Wait:
  in al,60h
  cmp al,1
  jz ee
  mov al,es:[di]
  cmp al,bl
  jne exit
  jmp @wait
  exit:
  loop pause
  ee:
  pop di
  pop bx
  pop ax
  ret
 Delay EndP

 Start:
  mov ax,0003h
  int 10h
  mov ax,1003h
  mov bl,1
  int 10h

  mov dx,3D4h      ; wylaczenie kursora tekstowego
  mov ax,100Ah     ; (przez porty)
  out dx,ax
  push 0b800h
  pop es
  mov si,offset Pic  ; si = wskaznik do danych
  mov cx,(EndPic-Pic)

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

  cmp dl,126     ; czy zmienic atrybut
  jnz next
  mov attr,04h
  Back:
  inc si
  pop cx
  loop AllDraw

  next:
  cmp dl,96       ; czy zmienic atrybut
  jnz Forward
  mov attr,0eh
  jmp back

 Forward:

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


  jmp print
  Txt db 'Press ESC to continue...'
  print:
  lea di,txt
  mov cx,(print-txt)
  mov dh,088h
  mov al,40-12
  mov bl,24
  l:
  mov dl,ds:[di]
  call putchar
  inc di
  inc al
  loop l


 m:
  mov al,10
  mov bl,7
  mov cx,8

 Move:
  mov dx,0f07h
  call PutChar
  add al,20
  call PutChar
  sub al,20

  push cx
  mov cx,2
  Call Delay
  pop cx

  mov dx,0007h
  call PutChar
  add al,20
  call PutChar
  sub al,20

  inc al
  push ax
  in al,60h
  cmp al,1
  pop ax
  jz EndMove
  loop Move

  mov dx,0f07h
  call PutChar
  add al,20
  call PutChar
  sub al,20

  mov cx,30
  call delay

  mov cx,8
 Move2:
  mov dx,0f07h
  call PutChar
  add al,20
  call PutChar
  sub al,20

  push cx
  mov cx,2
  Call Delay
  pop cx

  mov dx,0007h
  call PutChar
  add al,20
  call PutChar
  sub al,20

  dec al
  push ax
  in al,60h
  cmp al,1
  pop ax
  jz EndMove
  loop Move2

  mov dx,0f07h
  call PutChar
  add al,20
  call PutChar
  sub al,20

  mov cx,20
  call delay

  in al,60h
  cmp al,1
  jnz m
  EndMove:
  mov ax,0003h
  int 10h


  mov ah,4ch
  int 21h
 End Begin

