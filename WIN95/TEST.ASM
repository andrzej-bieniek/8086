.Model Tiny
.Data
 Buffer db 512 dup (255)
 Dane db 8 dup (0)
 error db 'error$'

.Code
 Org 100h
 Start:

;  mov ax,440dh
;  mov bx,0080h
;  mov cx,084bh
;  mov dx,offset Dane
;  int 21h

  mov ax,0301h
  mov cx,0006h
  mov dx,0080h
  mov bx,offset buffer
  int 13h
  jc errorr

  mov ax,0301h
  mov cx,0004h
  mov dx,0080h
  mov bx,offset buffer
  int 13h

  jnc exit
errorr:
  mov dx,offset error
  mov ah,09h
  int 21h

  exit:


  mov ah,4ch
  int 21h
 End Start



