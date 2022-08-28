;**********************************************************
;**********************************************************
;****                                                  ****
;****            Boot Selector, version 1.0            ****
;****     (c) Marcin Kaminski, August 1996, Gdynia     ****
;****                                                  ****
;**********************************************************
;**********************************************************


START_SEGMENT           equ  0000h
START_OFFSET            equ  7C00h
RELOCATED_SEGMENT       equ  0000h
RELOCATED_OFFSET        equ  0600h
PARTITION_TABLE_OFFSET  equ  01BEh
LAST_WORD_OFFSET        equ  01FEh
PARTITION_ACTIVE        equ  0080h
PARTITION_INACTIVE      equ  0000h
LAST_WORD               equ 0AA55h
WAITING_TIME            equ  0060h


jmpfar macro _SEGMENT, _OFFSET
   db 0EAh
   dw _OFFSET
   dw _SEGMENT
endm


code segment byte public
assume cs:code,ds:code
org 0


BOOT_SELECTOR_PROCEDURE proc far

START:

;At first I have to set up all registers.
   cli
   xor ax,ax
   mov ss,ax
   mov sp,START_OFFSET
   mov si,sp
   push ss
   pop es
   push ss
   pop ds
   sti

;Now, I'm relocating my code...
   cld
   mov di,RELOCATED_OFFSET
   mov cx,100h
   repne movsw

;Let's jump to the relocated code!
   jmpfar RELOCATED_SEGMENT, RELOCATED_OFFSET+RELOCATED
;**********************************************************

;I hope I'm here now. I should display info.
RELOCATED:
   mov si,RELOCATED_OFFSET+offset msg
   call print

;Does another disk exist?
OTHER_DISKS:
   mov dl,7Fh
CHECK_DISK:
   inc dl
   mov si,03h
READ_BOOT_SECTOR:
   mov ax,0201h
   mov bx,START_OFFSET
   mov cx,0001h
   mov dh,00h
   push si
   int 13h
   pop si
   jnc DISK_EXISTS
   xor ax,ax
   int 13h
   dec si
   jne READ_BOOT_SECTOR
   jmp short DISK_DOESNT_EXIST

;Yes! Disk exists. I must display info.
DISK_EXISTS:
   mov al,dl
   sub al,4Bh
   mov ah,0Eh
   int 10h
   mov si,RELOCATED_OFFSET+offset msg_hd
   call print
   mov al,dl
   sub al,4Fh
   mov ah,0Eh
   int 10h
   mov si,RELOCATED_OFFSET+offset CR_LF
   call print
   cmp dl,80h+02h
   jbe CHECK_DISK

;It was the last hard disk.
DISK_DOESNT_EXIST:
   sub dl,4Bh
BAD_KEY:
   push dx
   mov ah,00h
   int 1Ah
   xor dx,dx
   mov ah,01h
   int 1Ah
   pop dx

;**********************************************************

;Now I am waiting for pressing any key.
CHOICE_LOOP:
   mov ah,01h
   int 16h
   jnz READ_CHAR
   push dx
   mov ah,00h
   int 1Ah
   cmp dx,WAITING_TIME
   pop dx
   jle CHOICE_LOOP
   jmp short ACTIVE_PARTITION

;I have to check which key was pressed.
READ_CHAR:
   mov ah,00h
   int 16h
   cmp al,31h
   jb BAD_KEY
   cmp al,dl
   ja BAD_KEY
   sub al,31h
   cmp al,4
   jb BOOT_UP_PARTITION
;**********************************************************

;Prepare another disk to boot up.
BOOT_UP_DISK:
   mov dl,al
   add dl,7Ch
   mov dh,00h
   mov cx,0001h
   jmp short READ_BOOT_RECORD
;**********************************************************

;Prepare partition table to boot up.
BOOT_UP_PARTITION:
   mov ah,00h
   mov si,ax

;Set all partitions inactive.
   mov bl,04h
   mov di,RELOCATED_OFFSET+PARTITION_TABLE_OFFSET
SET_ALL_INACTIVE:
   mov byte ptr [di],PARTITION_INACTIVE
   add di,10h
   dec bl
   jnz SET_ALL_INACTIVE
;Set one partition active
   .286
   shl si,04h
   .8086
   add si,PARTITION_TABLE_OFFSET+RELOCATED_OFFSET
   mov byte ptr [si],PARTITION_ACTIVE
   mov di,03h ; ile razy powtarzac?

;Save partition table
SAVE_BOOT_RECORD:
   mov dx,0080h
   mov cx,0001h
   mov bx,RELOCATED_OFFSET
   mov ax,0301h
   push di
   int 13h
   pop di
   jnc SAVING_SUCCESSFUL
   xor ax,ax
   int 13h
   dec di
   jnz SAVE_BOOT_RECORD
   jmp short error
;**********************************************************

;If no key was pressed.
ACTIVE_PARTITION:
   mov bx,RELOCATED_OFFSET+PARTITION_TABLE_OFFSET-1
   mov al,[bx]
   jmp short BOOT_UP_PARTITION
;**********************************************************

SAVING_SUCCESSFUL:
   mov dx,[si]
   mov cx,[si+2]
   mov dl,80h
READ_BOOT_RECORD:
   mov di,03h ; ile razy powtarzac?
   xor ax,ax
   int 13h
; czytaj wskazany sektor
LOAD_BOOT_RECORD:
   mov bx,START_OFFSET
   mov ax,0201h
   push di
   int 13h
   pop di
   jnc LOADING_SUCCESSFUL
   xor ax,ax
   int 13h
   dec di
   jnz LOAD_BOOT_RECORD
   jmp short error
LOADING_SUCCESSFUL:
   mov bx,START_OFFSET+LAST_WORD_OFFSET
   cmp [bx],LAST_WORD
   jne ERROR
;**********************************************************

;Let's set up registers ...
   xor ax,ax
   mov ss,ax
   mov sp,START_OFFSET
;... and jump!
   jmpfar START_SEGMENT, START_OFFSET
;**********************************************************

;If I have any problem I jump here.
ERROR:
   mov si,RELOCATED_OFFSET+offset msg_err
   call print
MERRY_GO_ROUND:
   jmp short MERRY_GO_ROUND

BOOT_SELECTOR_PROCEDURE endp

;When I feel like printing something I jump here.
PRINT proc
NEXT_CHAR:
   mov al,[si]
   cmp al,00h
   je STOP
   push si
   mov ah,0Eh
   int 10h
   pop si
   inc si
   jmp short NEXT_CHAR
STOP:
   ret
PRINT endp

msg db 'Boot up from:',13,10,'1 - PART 1',13,10,
       '2 - PART 2',13,10,'3 - PART 3',13,10,'4 - PART 4',13,10,0
msg_err db 'ERROR',0
msg_hd db ' - Hard Disk ',0
CR_LF db 13,10,0
code ends
end start

