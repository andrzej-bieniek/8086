Init PROC
                mov     ax,13h
                int     10h

                mov     dx,3C4h
                mov     al,4
                out     dx,al

                inc     dx
                in      al,dx
                and     al,0F7h
                or      al,4
                out     dx,al

                mov     dx,3C4h
                mov     ax,0F02h
                out     dx,ax

                mov     ax,0A000h
                mov     es,ax
                mov     ax,0
                sub     di,di
                mov     cx,8000h
                cld
                rep     stosw
                mov     dx,3D4h
                mov     al,9
                out     dx,al

                mov     al,14h
                out     dx,al

                inc     dx
                in      al,dx
                and     al,0BFh
                out     dx,al
                dec     dx
                mov     al,17h
                out     dx,al

                inc     dx
                in      al,dx
                or      al,40h
                out     dx,al

		mov	dx,3c8h
		mov	al,0
		out	dx,al
		mov	al,0
		inc	dx
		out	dx,al
		out	dx,al
		out	dx,al
		mov	cx,254
		mov	al,255
		mov	ah,0
		mov	bl,4
		
Set:
		out	dx,al
		xchg 	al,ah
		out	dx,al
		out	dx,al
		xchg 	al,ah
		sub	al,1
		loop	Set				
	        ret
ENDP