.Model Tiny
.Data
 Txt1 db ' Multi System Disk v1.0 - zaprojektowany i wykonany przez M$(1998).             '
 Txt1a db '                                                                                '
 Txt2 db 'Multi System'
 Txt3 db 'Disk ver 1.0'
 Txt4 db 'Wybierz system operacyjny: '
 Txt5 db ' MS-DOS ver 6.22          '
 Txt6 db ' Windows 95 ver 4.00.1111 '

 Disk01 db 'лллллллллллллллллллллллл'
 Disk02 db 'ппп'
 Disk03 db 'ммм'
 Disk04 db 'Г'
 System db 0

 wx dw 0
 wy dw 0
 wa db 0
 xd dw 0
 yd dw 0

.code
.286
 org 100h
  Begin:
   jmp Start

   Write PROC
    push ax
    push bx
    push dx
    push si
    push ds
    push di
    push cx
    mov ax,wy
    mov dx,80
    mul dx
    add ax,wx
    shl ax,1
    mov si,ax
    mov ax,0B800h
    mov es,ax
    mov bh,wa
  @w:
    mov bl,ds:[di]
    mov es:[si],bx
    inc di
    inc si
    inc si
    loop @w
    pop cx
    pop di
    pop ds
    pop si
    pop dx
    pop bx
    pop ax
    ret
  Write ENDP

  Delay Proc         ; cx - delay
   push ax
   push bx
   push di
   push cx
  Pause:
   mov ax,0040h
   push ax
   pop es
   mov di,006ch
   mov bl,es:[di]
  @Wait:
   mov al,es:[di]
   cmp al,bl
   jne exit
   jmp @wait
  exit:
   loop pause
   pop cx
   pop di
   pop bx
   pop ax
   ret
  Delay EndP

  HideDisk PROC
   push ax
   push cx
   push di
   mov ax,xd
   mov wx,ax
   mov ax,yd
   mov wy,ax
   mov cx,11
  Clear:
   push cx
   mov wa,0h
   inc wy
   mov cx,24
   mov di,offset Disk01
   call Write
   pop cx
   loop Clear
   pop di
   pop cx
   pop ax
   ret
  HideDisk ENDP




  ShowDisk PROC
   push ax
   push cx
   push di

   mov ax,xd
   mov wx,ax
   mov ax,yd
   mov wy,ax

   mov cx,11
  Show1:
   push cx
   mov wa,01h
   inc wy
   mov cx,24
   mov di,offset Disk01
   call Write
   pop cx
   loop Show1

   sub wy,6
   add wx,3
   mov cx,6
  Show2:
   push cx
   mov wa,0Fh
   inc wy
   mov cx,18
   mov di,offset Disk01
   call Write
   pop cx
   loop Show2

   sub wy,11
   add wx,3
   mov cx,4
  Show3:
   push cx
   mov wa,07h
   inc wy
   mov cx,8
   mov di,offset Disk01
   call Write
   pop cx
   loop Show3

   sub wy,3
   add wx,8
   mov wa,17h
   mov cx,3
   mov di,offset Disk02
   call Write
   add wy,3
   mov di,offset Disk03
   call Write

   sub wy,4
   add wx,3
   mov cx,4

  Show4:
   push cx
   mov wa,07h
   inc wy
   mov cx,1
   mov di,offset Disk01
  call Write
   pop cx
   loop Show4
     ; koniec blachy

   sub wx,16
   add wy,7
   mov wa,10h
   mov cx,1
   mov di,offset Disk02
   call Write
   add wx,21
   call Write

   sub wy,10
   sub wx,4
   call Write
   add wx,5
   call Write

   sub wx,22
   inc wy
   mov wa,10h
   mov di,offset Disk04
   call Write
   sub wy,2
   inc wx
   mov cx,4
  Show5:
   push cx
   mov wa,19h
   inc wy
   mov cx,1
   mov di,offset Disk04+1
  call Write
   pop cx
   loop Show5

   add wx,4
   add wy,3
   mov cx,12
   mov wa,0f0h
   mov di,offset Txt2
   Call Write
   add wy,2
   mov di,offset Txt3
   Call Write

   pop di
   pop cx
   pop ax
   ret
  ShowDisk ENDP



  Vrt PROC
   push ax
   push dx
   mov dx,3dah
   vrt1:
   in al,dx
   test al,8
   jnz vrt1
   vrt2:
   in al,dx
   test al,8
   jz vrt2
   pop dx
   pop ax
   ret
  Vrt ENDP


 Blacha PROC
   mov wx,29
   mov wy,4
   mov cx,4
  ShowB1:
   push cx
   mov wa,07h
   inc wy
   mov cx,8
   mov di,offset Disk01
   call Write
   pop cx
   loop ShowB1
   sub wy,3
   add wx,8
   mov wa,87h
   mov cx,3
   mov di,offset Disk02
   call Write
   add wy,3
   mov di,offset Disk03
   call Write
   sub wy,4
   add wx,3
   mov cx,4
  ShowB2:
   push cx
   mov wa,07h
   inc wy
   mov cx,1
   mov di,offset Disk01
  call Write
   pop cx
   loop ShowB2
   mov cx,4
   add wx,1
   sub wy,4
  ShowB3:
   push cx
   mov wa,01h
   inc wy
   mov cx,3
   mov di,offset Disk01
  call Write
   pop cx
   loop ShowB3
   mov cx,2
   sub wx,4
   sub wy,3
  ShowB4:
   push cx
   mov wa,78h
   inc wy
   mov cx,3
   mov di,offset Disk01
  call Write
   pop cx
   loop ShowB4
   ret
 Blacha ENDP


 Start:
  push cs
  pop ds
  mov ax,0003h
  int 10h
  mov ax,1003h
  mov bl,0
  int 10h
  mov dx,3D4h      ; wylaczenie kursora tekstowego
  mov ax,100Ah     ; (przez porty)
  out dx,ax

  mov wx,0
  mov wy,24
  mov wa,1fh
  mov cx,80
  mov di,offset Txt1
  call Write

  mov xd,8
  mov yd,4
  call ShowDisk

  mov wx,41
  mov wy,8
  mov wa,07h
  mov cx,27
  mov di,offset Txt4
  call Write


 First:
  mov system,1
  mov wa,7fh
  mov wx,42
  mov wy,10
  mov cx,26
  mov di,offset Txt5
  call Write

  mov wa,07h
  mov wy,11
  mov di,offset Txt6
  call Write

 Key:
  xor ax,ax
  int 16h
  cmp ah,50h
  jne Nextkey
  mov system,2
  mov wa,07h
  mov wx,42
  mov wy,10
  mov cx,26
  mov di,offset Txt5
  call Write
  mov wa,7fh
  mov wy,11
  mov di,offset Txt6
  call Write

 NextKey:
  cmp ah,48h
  jz First
  cmp ah,1Ch
  jne key



  mov wx,41
  mov wy,7
  mov cx,5
 clear1:
  push cx
  mov wa,00h
  inc wy
  mov cx,30
  mov di,offset Disk01
  call Write
  pop cx
  loop clear1


  mov wx,0
  mov wy,24
  mov wa,07h
  mov cx,80
  mov di,offset Txt1a
  call Write


  mov cx,18
  call vrt
  l:
  call ShowDisk
  call vrt
  call HideDisk
  inc xd
  loop l
  call ShowDisk
  
  

  xor ax,ax
  mov es,ax  
  mov ax,0201h
  mov cx,1512h
  cmp system,1
  jnz Win
  mov cx,0b0ch
  mov dx,0100h 
  jmp OutDos 
 Win:
  mov cx,200Ch
  mov dx,0000h 

 OutDos:
  mov bx,7c00h
  push es
  push bx
  int 13h      
  

  mov cx,5
  call Delay
 

  call Blacha

  mov ah,02h
  mov dh,23
  mov dl,0
  mov bh,0
  int 10h

  mov ah,1h
  mov cx,0607h    
  int 10h

  RETF
  
  
;  xor ax,ax
;  int 16h
  
  
 
  
  
;  mov ax,4c00h
;  int 21h
 end begin
