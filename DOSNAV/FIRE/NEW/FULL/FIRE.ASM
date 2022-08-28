
                .model  tiny
                .code
                .386
                org     100h

WaveW           equ     320
WaveH           equ     100

Start:

                mov     ax,13h
                int     10h

                mov     dx,03C8h
                mov     al,0
                out     dx,al
                inc     dx
                mov     si,offset PalData
                mov     cl,3

@@makePal:      mov     ch,32
@@makeRamp:     mov     di,3
                xor     bx,bx
@@makeRGB:      mov     al,32
                sub     al,ch
                mov     ah,[si+bx+3]
                sub     ah,[si+bx]
                imul    ah
                sar     ax,5
                add     al,[si+bx]
                out     dx,al
                inc     bx
                dec     di
                jne     @@makeRGB
                dec     ch
                jne     @@makeRamp
                add     si,6
                dec     cl
                jne     @@makePal


                push    ds
                pop     es
                mov     cx,WaveW * WaveH / 4
                xor     eax,eax
                mov     di,offset WaveImage1
                rep     stosd

                mov     ax,0A000h
                mov     es,ax


 ;*****************************************************************

                 mov cx,95
                 mov di,0
                 mov si,0
                 mov al,95
DrawLine:
                push cx
                 mov cx,3
                 rep stosb
                 pop cx

                 dec al
                 inc si

                 push di
                 mov dx,si
                 xchg dh,dl
                 xor di,di
                 add di,dx
                 shr dx,2
                 add di,dx
         mov byte ptr es:[di],cl
                 pop di
;                call pause
                 call fire

                 loop DrawLine

@@FireLoop:
         call fire


                 in al,60h
                 cmp al,1
                 jnz     @@FireLoop


                mov     ax,0003h

                 int     10h
                int     20h



Fire Proc

                 push eax
                 push ebx
                 push ecx
                 push edx
                 push si
                 push di
                 push bp

@@waveLoop:     mov     si,Wave1
                add     si,WaveW - 1
                mov     di,Wave2
                inc     di
                mov     ebx,[si-WaveW]
                mov     ecx,[si]
                mov     edx,[si+WaveW]
                mov     bl,0
                add     si,4

                mov     bp,WaveW * (WaveH - 2)
@@waveLine:     mov     al,[si-WaveW]
                shrd    ebx,eax,8
                mov     al,[si]
                shrd    ecx,eax,8
                mov     al,[si+WaveW]
                shrd    edx,eax,8
                inc     si
                shld    eax,ecx,16
                add     al,cl
                setc    ah
                add     al,ch
                adc     ah,0
                add     al,dh
                adc     ah,0
                ror     ax,2
                test    al,al
                jz      @@put
                test    cl,1
                setnz   ah
                sub     al,ah
@@put:          mov     [di],al
                inc     di
                dec     bp
                jnz     @@waveLine

                mov     cx,WaveW
@@MakeSeed:     add     bx,05EDAh
                xor     bx,dx
                add     dx,0E34Ah
                mov     dl,bh
                add     dh,bl
                adc     dl,al
                add     bx,dx
                rol     bx,3
                mov     al,bl
                and     al,07Fh
                mov     [di],al
                inc     di
                loop    @@MakeSeed


                mov     si,Wave1
                xchg    si,Wave2
                mov     Wave1,si
                add     si,WaveW
                mov     di,32000
                mov     dx,WaveH-5
@@refresh0:     mov     cx,WaveW/4
                rep     movsd
                add     di,(320 - WaveW)
                dec     dx
                jne     @@refresh0
                 call pause

                 pop bp
                 pop di
                 pop si
                 pop edx
                 pop ecx
                 pop ebx
                 pop eax

                 ret
Fire Endp



Pause Proc
                 push dx
                 push ax
                 mov     dx,03DAh
@@W4R1:         in      al,dx
                test    al,8
                jnz     @@W4R1
@@W4R2:         in      al,dx
                test    al,8
                jz      @@W4R2
                 pop ax
                 pop dx
                 ret

Pause endp

PalData         db      00,00,00, 24,00,00    ;24
                db      25,01,00, 48,32,08
                db      50,33,08, 63,63,63

Wave1           dw      offset WaveImage1       ;offset WaveImage1
Wave2           dw      offset WaveImage2       ;offset WaveImage2
WaveImage1      db      WaveW * WaveH dup (?)
WaveImage2      db      WaveW * WaveH dup (?)
                end     Start
