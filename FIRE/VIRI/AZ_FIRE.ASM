
.model  tiny
               jumps
               .code
              .386

                org     100h

WaveW           equ     320
WaveH           equ     70

Start:
                push cs
		 pop ds
		 push ds
		 pop es
		 mov 	 di,offset zera
		 mov     cx,49919
		 mov 	 ax,0
		 rep     stosb

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
                 call fire

                 loop DrawLine


FireLoop:
         call fire
      	  Call PiszTekst
         call    ShowSCROLL ;rysuj scrolla
         call    MoveSCROLL ;przesun tablicë SCROLL
         call    DrawZNAK   ;dorysuj kolejnÜ kolumnë

         cmp byte ptr del2,0
	  jnz odejmij
	  
	  inc byte ptr kolor
	  cmp byte ptr kolor,90
	  jnz ccc
	  mov byte ptr del2,1
	  jmp ccc
     odejmij:
         dec byte ptr kolor
	  cmp byte ptr kolor,0
	  jnz ccc
         mov byte ptr del2,0

     ccc:


         in al,60h
         cmp al,1
         jnz     FireLoop
         mov     ax,0003h
         int     10h

koniecprogramu:    
         retf


;   xor ax,ax
;   mov es,ax
;   mov bx,7C00h
;  
;   push es
;   push bx  
;  
;   mov ax,0201h
;   mov ch,79
;   mov cl,18
;   mov dh,1
;   mov dl,0
;   int 13h
;
;   retf
;
;  xx: jmp xx





 ;********************************************************************
 ;********************************************************************
 ;********************************************************************
 ;********************************************************************
 ;********************************************************************
 ;********************************************************************
 ;********************************************************************




MoveSCROLL PROC
        ;Najpierw wyczyûç pierwszÜ kolumnë,
        ;ßeby po przesuniëciu nie "wyszía" 
        ;z prawej strony
	 push es
	 push ax
	 push cx
	 push si
	 push di

        push    cs
        pop     es
        lea     di,SCROLL
        mov     cx,16
        mov     ax,0
Clear:
        stosw
        add     di,318
        loop    Clear
        ;i dopiero teraz przesu§
        push    cs
        pop     ds
        lea     si,SCROLL[2]
        lea     di,SCROLL
        mov     cx,160*16-1
        rep     movsw

	 pop di
	 pop si
	 pop cx
	 pop ax
	 pop es

        ret
ENDP            





PiszTekst PROC
        push ax
	 push bx
	 push cx
	 push dx
	 push si
	 push di
	 push es


	mov	dx,0a000h
	mov	es,dx
	push	cs
	pop	ds
	;Policz offset punktu, od kt¢rego ma byç
	;wypisany tekst
	mov	ax,Y
	mov	bx,320
	mul	bx
	add	ax,X
	mov	di,ax
	lea	bx,txt   ;BX - offset wzglëdem TXT
PiszZnak:
	mov	al,cs:[bx]
	XOR     AL,66      ;((((((((((((((((((((((((((((((((((((

	inc	bx
	cmp	al,0
	jne	NieKoniec
	jmp	Koniec
NieKoniec:
	xor	ah,ah
	;Policz offset znaku w tablicy FONT
	shl	ax,1
	shl	ax,1
	shl	ax,1
	shl	ax,1
	lea	si,FONT
	add	si,ax
	mov	cx,16
	mov	ah,kolor
	push	di
Linia:	
	push	di
	lodsb
	mov	dl,10000000b
	mov	dh,8
Kropka:
	test	al,dl      ;Jest punkt?
	jz	NieKropka
	mov	es:[di],ah
NieKropka:		
	inc	di
	shr	dl,1
	dec	dh
	jns	Kropka
	pop	di
	add	di,320
	loop	Linia
	pop	di
	add	di,9
	jmp	PiszZnak	
Koniec:

        pop es
        pop di
	 pop si
	 pop dx
	 pop cx
	 pop bx
	 pop ax
	
	ret
ENDP			







;*******************************************
;Dopisz kolumnë z prawej strony SCROLL
DrawZNAK PROC
        push ax
	 push bx
	 push cx
	 push dx
	 push si
	 push di
	 push es

ddznak:
        cmp     Pznak,3      ;Czy jesteûmy w znaku?
        ja      No_draw      ;Nie? - nic nie rysuj
                             ;Tak otrzymujemy odstëp miëdzy
                             ;znakami w scrollu
        mov     bx,Znak      ;Numer znaku
        mov     bl,Text[bx]  ;i sam kod znak
	 xor     bl,66
        and     bl,bl        ;Czy = 0
        jnz     Not_end      ;Jeûli nie to dalej,
        mov     Znak,0       ;a jeûli tak to od nowa


        jmp     ddZnak
Not_end:        
        ;policz offset znaku w FONT
        ;offset := kod znaku * 16
        xor     bh,bh        
        shl     bx,1
        shl     bx,1
        shl     bx,1
        shl     bx,1
        lea     si,FONT[bx]
        push    cs
        pop     ds
        push    cs
        pop     es
        lea     di,SCROLL[310]  ;ustaw sië na prawÜ kolumnë
        ;DL i DH - ußywane do kontroli odpowiednich kolumn 
        ;znaku.
        mov     cl,Pznak        
        shl     cl,1
        mov     dl,10000000b 
        mov     dh,01000000b
        shr     dx,cl
        mov     cx,16
Draw_c:
        xor     bx,bx
        lodsb
        test    al,dl       ;Czy jest 1 punkt?
        jz      No1
        
	 

	 cmp byte ptr ddeell,0
	 jz dodawaj

      	 dec byte ptr color
	 cmp byte ptr color,30
	 jnz dalej1
        mov byte ptr ddeell,0
	 jmp dalej1

dodawaj:
      	 inc     byte ptr color
	 cmp byte ptr color,90
	 jnz dalej1
	 mov byte ptr ddeell,1
dalej1:        
	 mov     bl,color
No1:
        test    al,dh       ;Czy jest 2 punkt?
        jz      No2
        mov     bh,color
No2:            
        mov     ax,bx
        stosw
        add     di,318
        loop    Draw_c                                  
No_draw:
        inc     Pznak
        cmp     Pznak,6     ;6 - opisuje odstëp miëdzy 
                            ;znakami
        jne     No_next
        mov     Pznak,0
        inc     Znak
No_next:

        pop es
        pop di
	 pop si
	 pop dx
	 pop cx
	 pop bx
	 pop ax
        ret
ENDP    
;*******************************************
;Narysuj SCROLL na ekranie

ShowSCROLL PROC


        push si
	 push di
	 push cx
	 push dx

        push    cs
        pop     ds
        lea     si,SCROLL
        mov     dx,0a000h
        mov     es,dx
        mov     di,320*80
        mov     cx,160*16
        rep     movsw

	 pop dx
	 pop cx
	 pop di
	 pop si

        ret
ENDP            




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

                mov     bp,WaveW * (WaveH - 2) - 2
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
                mov     di,44000
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

.data


txt:
;   db   'MKS_VIR SYSTEM DISK by OverCooL',0 ;Tekst do wypisania 
include info1.inc
                                 
				  ;zako§czony zerem
X     dw   10                     ;Wsp. X pierwszego znaku
Y     dw   10		         ;Wsp. Y pierwszego znaku 
kolor db   0                     ;Kolor tekstu  


Text db 22
      ;    db  ' Ten komputer zostal zainfekowany najnowszym wirusem HDD KILLER v9.99. '
     ;   db  ' W celu otrzymania programu AntyVirusowego trzeba skontaktowac sie ze Szczecinska firma '
     ;   db  ' "VIRUSS FOOR JU" pod Czestochowskim numerem telefonu: (032)202-22-03... Zycze milej pracy...:)     M$(1999)                   '
     ;	 db  ' OverCooL & Boo was where...                                ',0

    include info2.inc

Znak    dw  0    ;numer aktualnego znaku w TEXT
Pznak   db  0    ;numer kolumny w aktualnym znaku
color   db  50   ;kolor scrolla
ddeell  db  0
del2    db  0

Wave1           dw      offset WaveImage1       ;offset WaveImage1

Wave2           dw      offset WaveImage2       ;offset WaveImage2

PalData         db      00,00,00, 24,00,00    ;24
                db      25,01,00, 48,32,08
                db      50,33,08, 63,63,63


FONT:
include font.inc






; db '4','4','4','4','4','4','4','4','4','4','4','4','4','4','4','4','4','4'

ZERA:

SCROLL  db 320*16 dup('s')


WaveImage1      db      WaveW * WaveH dup (0F6H)
WaveImage2      db      WaveW * WaveH dup (0F6H)

KONIECZER:

                end     Start
