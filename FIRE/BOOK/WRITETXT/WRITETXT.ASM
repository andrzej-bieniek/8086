DSTACK SEGMENT STACK 'STACK'
db 10 dup('STACK')
DSTACK ENDS

ASSUME cs:CODE

CODE SEGMENT
Fname db   'BIG.FNT',0       ;Nazwa pliku font¢w

txt   db   'Przykladowy tekst',0 ;Tekst do wypisania 
                                 ;zako§czony zerem
X     dw   0                     ;Wsp. X pierwszego znaku
Y     dw   0		         ;Wsp. Y pierwszego znaku 
kolor db   0                     ;Kolor tekstu  

Start:
	call	LoadFont         ;Wczytaj font     

	mov	ax,13h
	int	10h

	mov	X,10
	mov	Y,10
	mov	kolor,15

	call	PiszTekst

	mov	ah,08h
	int	21h
	mov	ax,3
	int	10h
	mov	ax,4c01h
	int	21h
;***************************************************
;***************************************************
PiszTekst PROC
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
	ret
ENDP			
;***************************************************
;Wczytanie pliku z fontem - patrz rozdziaí o plikach
;***************************************************
LoadFont PROC
	mov	ah,3dh
	push	cs
	pop	ds
	lea	dx,Fname
	mov	al,0
	int	21h

	mov	bx,ax
	mov	ah,3fh
	lea	dx,FONT
	mov	cx,4096
	int	21h

	mov	ah,3eh
	int	21h
	ret
ENDP		

FONT	db 4096 dup(?)	

CODE ENDS

END Start