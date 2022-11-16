; Crack for MASZYNISTKA written by M$(1998)
; Crack do programu MASZYNISTKA napisany przez M$(1998)

.model tiny
.data 
 ExeFile db 'MASZ.EXE',0
 ExecControlTable:
  Enviroment dw 0
  PSPO dw 0
  PSPS dw 0
  FCB1O dw 0
  FCB1S dw 0
  FCB2O dw 0
  FCB2S dw 0
  NEWSP dw 0
  NEWSS dw 0
  NEWIP dw 0
  NEWCS dw 0
 
 Licznik db 0

.code
 org 100h
  Start:
   jmp Begin
    
   Trace PROC
     push bp
     mov bp,sp
     push ds
     push bx
     push ax
     mov ds,[bp+4]
     push ds
     push cs
     pop ds
     mov al,licznik
     pop ds
     cmp al,3
     jz nopowanie
     cmp al,2
     jz nastepny
     mov bx,0198h
     jmp wpisanie
    nastepny:
     mov bx,004bh
    wpisanie:
     mov byte ptr [bx],0cch
     jmp wyjscie
    nopowanie:
     mov bx,34afh
     mov word ptr [bx],9090h
     mov bx,34b1h
     mov byte ptr [bx],90h    
    
    wyjscie:
     mov bx,[bp+6]
     and bx,0feffh
     mov [bp+6],bx
     pop ax
     pop bx
     pop ds
     pop bp
     iret
   Trace ENDP
   
   Trap PROC
    push bp
    mov bp,sp
    push ds
    push bx
    mov ds,[bp+4]
    mov bx,[bp+2]
    dec bx
    mov [bp+2],bx
    mov byte ptr [bx],0cbh
    push cs
    pop ds
    inc licznik
    mov bx,[bp+6]
    or bx,0100h
    mov [bp+6],bx
    pop bx
    pop ds
    pop bp
    iret
  Trap ENDP
 
  Begin:
   mov dx,offset Trap
   mov ax,2503h
   int 21h
   mov dx,offset Trace
   mov ax,2501h
   int 21h
   mov ah,4ah
   mov bx,2523h
   int 21h
   mov ax,4b01h
   lea dx,ExeFile
   lea bx,ExecControlTable
   int 21h
   jc exit
   mov ss,Newss
   mov sp,newsp
   mov ax,newcs
   mov skokcs,ax
   push ax
   pop es
   mov ax,newip
   mov skokip,ax
   mov byte ptr es:[0045h],0cch
   mov ah,62h
   int 21h
   push bx
   push bx
   pop es
   pop ds
   mov ax,exit-start
   add ax,100h
   mov word ptr es:[0ah],ax
   push cs
   pop ax
   mov word ptr es:[0ch],ax
   db 0eah
   skokip dw ?
   skokcs dw ?
  exit:
   mov ax,4c00h
   int 21h
 End Start


    






















-
