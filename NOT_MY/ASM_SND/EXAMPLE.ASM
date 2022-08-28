INCLUDE         MODPLAY.INC

                .286
                .SEQ
                .MODEL SMALL
                .STACK 200h

                .DATA
PSP             DW      0
Error_1         DB      'Cannot initialize sound driver...',13,10,'$'
Error_2         DB      'Unable to load module file...',13,10,'$'
Message         DB      'Playing module... Press [ESC] to quit.$'
Filename        DB      'INTROII.MOD',0

                .CODE
                LOCALS
Start:          mov     ax,SEG _DATA
                mov     ds,ax
                mov     [PSP],es
                xor     bx,bx
                xor     ax,ax		 

                call    FAR PTR Mod_Driver      ; Detection & Initialization
                or      ax,ax
                jnz     @@1
                mov     dx,OFFSET Error_1
                call    DOS_Text
                jmp     SHORT Terminate
@@1:            call    FAR PTR [Mod_End_Seg]   ; returns: ax=end segment
                mov     bx,ax
                mov     ax,[PSP]
                mov     es,ax
                sub     bx,ax                   ; bx=prog length in paragraphs
                mov     ah,4Ah
                int     21h                     ; set memory control block
                mov     bx,2
                mov     dx,OFFSET Filename
                call    FAR PTR Mod_Driver      ; load module in ds:dx
                or      ax,ax
                jnz     @@2
                mov     dx,OFFSET Error_2
                call    DOS_Text
                jmp     SHORT CloseDriver
@@2:            mov     bx,3
                mov     ax,1
                call    FAR PTR Mod_Driver      ; start playing, looping is on
                mov     dx,OFFSET Message
                call    DOS_Text

 

                mov dx,0220h+4
                mov al,04h
                out dx,al
                inc dx
                mov al,00110110b
                out dx,al
 
	
 


@@3:            mov     ah,1
                int     16h
                jz      @@3                     ; wait for keystroke
                xor     ah,ah
                int     16h                     ; test for escape key
                cmp     al,1Bh
                jnz     @@3
CloseDriver:    mov     bx,1
                call    FAR PTR Mod_Driver
Terminate:      mov     ax,4C00h
                int     21h

DOS_Text:       mov     ah,9
                int     21h
                ret

END             Start
