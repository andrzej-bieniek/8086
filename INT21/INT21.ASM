.model tiny
.data
  adres dd (0)
  txt db 'To jest bezposrednie wywolanie int 21h.$'
.code
 org 100h
 start:
  mov ah,52h
  int 21h
  mov word ptr adres[2],es
  mov ax,0fb2h
  mov word ptr adres,ax
  mov ah,09
  lea dx,txt

  call adres
  mov ah,4ch
  call adres
 end start
