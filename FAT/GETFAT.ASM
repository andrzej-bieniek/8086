;Program (GETFAT.ASM) napisany przez M$(1998).
;Opis:
; Program zawiera trzy procedury do operacji na tablicy FAT dyskietki 1,44Mb:
;
;  1. GetCluster - Odczyt wartosci klastra z FAT.
;                   wejscie:  ax = numer jednostki do odczytu
;                   powrot:   ax = wartosc odczytanej jednostki
;
;  2. PutCluster - Zapis nowej wartosci klastra do FAT.
;                   wejscie:  ax = numer jednostki alokacji , bx = nowa wartosc
;                   powrot:   -
;
;  3. RwFat - Odczyt/Zapis calego bufora z/do FAT dyskietki.
;              wejscie:  ah = 02 odczyt do bufora
;                        ah = 03 zapis bufora
;              powrot:   -

.Model Tiny
.Data
 FAT db 9*512 dup(0)
 Cluster = 27

.286
.Code
 Org 100h

 Start:
  jmp Begin

 GetCluster PROC  ; ax = numer jednostki do odczytu
  push bx
  push cx
  push di

  mov cx,ax
  shl ax,1      ;  mov bx,3
  add ax,cx     ;  mul bx
  shr ax,1      ;  mov bx,2
                ;  div bx
  mov di,ax
  mov bx,word ptr ds:[fat+di]
  test cx,1
  jp parity
  shr bx,4
  jmp continue
  parity:
  and bx,0fffh
  continue:
  xchg ax,bx
  pop di
  pop cx
  pop bx
  ret
 GetCluster ENDP     ; ax = wartosc odczytanej jednostki

 PutCluster PROC     ; ax = numer jednostki alokacji , bx = nowa wartosc
  push ax
  push bx
  push cx
  push di
  push bx

  mov cx,ax
  shl ax,1      ;  mov bx,3  - przesuniecia bitowe sa szybsze
  add ax,cx     ;  mul bx
  shr ax,1      ;  mov bx,2
                ;  div bx
  mov di,ax
  mov bx,word ptr ds:[fat+di]
  xchg ax,bx
  pop bx
  test cx,1
  jp par
  and ax,000Fh
  shl bx,4
  or ax,bx
  jmp cont
 par:
  and ax,0F000h
  or ax,bx
 cont:
  mov word ptr ds:[fat+di],ax
  pop di
  pop cx
  pop bx
  pop ax
  ret
 PutCluster ENDP

 RwFat PROC
  mov al,09h
  mov cx,0002h
  xor dx,dx
  mov bx,Offset FAT
  int 13h
  ret
 RwFat ENDP

 Begin:
  mov ah,02h
  call RwFat
  mov ax,Cluster
  mov bx,00h
  ;call PutCluster
  call GetCluster
  ;mov ah,03h ; call RwFat
  ret
 End Start





