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

	        ret
ENDP