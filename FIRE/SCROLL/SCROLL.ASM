;code by jasper/stc
JUMPS
.386
ASSUME	cs:CODE,ss:STACKS

CODE	SEGMENT USE16

Offset_scrolla	dw 320*160	;offset linii do rysowania scrolla
Licz_zn	dw 0			;ktory znak
Poz_zn	dw 0			;pozycja w znaku

Begin:
	mov	ax,0013h
	int	10h		;ustaw tryb 13h 320x200x256c
	mov	dx,seg Pal	;\
	mov	ds,dx		; >ustaw
	lea	si,Pal		; >palete
	call	Paleta		;/
Petla:
        call	Ramka		;kontrola ramki
        call	Przesun		;przesuniecie tablicy scrolla
        call	Znak		;dopisanie nowego wiersza znaku
        call	Naekran		;wyrzucenie wszystkiego na ekran
        mov	ah,01h
        int	16h
        jz 	petla		;czekaj na klawisz
Koniec:
	mov	ax,0003h
	int	10h		;ustaw tryb tekstowy
	mov	ax,4c00h
	int	21h		;wyjscie do DOSu
Przesun	PROC			;przesuniecie tablicy scrolla
        mov	dx,seg scroll	;\
        mov	es,dx		; \
        mov	ds,dx		;  >adres tablicy
        lea	si,scroll	; /
        mov	di,si		;/
        add	si,2
	mov	cx,318*34
        rep	movsb		;przesuwaj
        ret
Przesun	ENDP
Znak	PROC			;dopisanie nowego wiersza znaku
	cld
	cmp	poz_zn,32	;czy koniec znaku?
	jb	wznaku		;nie
	mov	poz_zn,0	;tak
	inc	licz_zn
Wznaku:
	mov	dx,seg text	;\
	mov	ds,dx		; >tablica z tekstem
	lea	si,text		;/
	add	si,licz_zn	;wybierz aktualnie rysowany znak
	lodsb
	cmp	al,'$'		;koniec tekstu?
	jne	niekoniectekstu	;nie
	mov	licz_zn,0	;tab
	jmp	wznaku
Niekoniectekstu:
	cbw
	sub	ax,'a'		;gdy 'a' ax=0, 'b' ax=1, 'c' ax=2, itd.
	shl	ax,1
	mov	dx,seg pocz	;\
	mov	ds,dx		; >tablica z offsetami fontow
	lea	si,pocz		;/
	add	si,ax
	lodsw			;wczytaj offset
	mov	dx,seg font	;\
	mov	ds,dx		; >tablica fontow
	lea	si,font		;/
	add	si,ax		;dodaj offset wybranego fontu
	add	si,poz_zn	;i pozycje w nim
	mov	dx,seg scroll	;\
	mov	es,dx		; >tablica scrolla
	lea	di,scroll	;/
	add	di,318
	mov	cx,34		;rysuj 34 poziome linie
Frik:
	lodsw
	stosw
	add	di,318
	add	si,318
	loop	frik
	add	poz_zn,2	;nastepna pozycja w znaku
	ret
Znak	ENDP
Naekran	PROC			;wyrzucenie wszystkiego na ekran
	cld
	mov	dx,seg scroll	;\
	mov	ds,dx		; >z tablicy scrolla
	lea	si,scroll	;/
	mov	dx,0a000h
	mov	es,dx		;na ekran
	mov	di,offset_scrolla;pod ten offset
	mov	cx,34*320	;dlugosc tablcy scrolla
	rep	movsb		;kopiuj
        ret
Naekran	ENDP
Paleta	PROC			;ustawianie palety DS:SI-rzadana paleta
	mov	cx,256*3	;ustaw 256 kolorow
	mov	dx,3c8h
	mov	al,0		;zacznij od zerowego
	out	dx,al
	inc	dx
	cld
	rep	outsb		;wysylaj dane do portu
	ret
Paleta	ENDP
Ramka	PROC			;kontrola ramki
	mov	dx,3dah
Ram1:
	in	al,dx
	test	al,8		;sprawdz 3 bit portu 3dah
	jnz	ram1		;jezeli nie zero to skok
Ram2:
	in	al,dx
	test	al,8		;sprawdz 3 bit portu 3dah
	jz	ram2		;jezeli zero to skok
	ret
Ramka	ENDP

CODE	ENDS

DATA	SEGMENT USE16

;tablica offsetow kolejnych fontow
Pocz	dw 0,32,64,96,128,160,192,224
	dw 10560+0,10560+32,10560+64,10560+96,10560+128,10560+160,10560+192,10560+224
	dw 21120+0,21120+32,21120+64,21120+96,21120+128,21120+160,21120+192,21120+224
	dw 31680+0,31680+32,31680+64
;tablica scrolla
Scroll	db  320*34 dup(0)
;tekst do scrolla
Text	db 'to{jest{scroll'
	db '{{{{{{{{{{$'
Pal:
include pal.inc			;dolacz palete
DATA	ENDS

ALFA	SEGMENT USE16
Font:
include font.inc		;dolacz tablice fontow
ALFA	ENDS

STACKS	SEGMENT USE16 STACK 'STACK'
	db 512 dup(0)		;zdefiniuj stos
STACKS	ENDS

END	Begin
