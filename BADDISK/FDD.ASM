.model tiny
.code
org 100h
begin:
;  cli
;  xor ax,9000h
 ; mov ss,ax
 ; mov sp,0
 ; sti

  xor ax,ax
  mov ss,ax
  mov sp,7000h
  nop
  nop
  nop

  mov cx,10
 testing:
  push cx
  mov ax,cs
  mov es,ax
  mov bx,offset bufor
  mov ah,4
  mov dl,0
  mov al,1
  mov dh,1
  mov ch,40
  mov cl,18
  int 13h
  pop cx
 loop testing
  jnc error

  mov ax,cs
  mov es,ax
  mov bx,offset bufor
  mov ah,3
  mov al,2
  mov dl,0
  mov dh,0
  mov ch,0
  mov cl,1
  int 13h
  jc error

  mov ax,cs
  mov es,ax
  mov bx,offset bufor
  mov ah,2
  mov al,1
  mov dl,80h
  mov dh,0
  mov ch,0
  mov cl,2
  int 13h
  jc error

  mov ax,cs
  mov es,ax
  mov bx,offset bufor
  mov ah,3
  mov al,1
  mov dl,80h
  mov dh,0
  mov ch,0
  mov cl,1
  int 13h

  error:
  mov ax,0e2ah
  int 10h
  jmp error

bufor:
end begin

