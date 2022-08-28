
PAGE  59,132

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;€€					                                 €€
;€€				INIT	                                 €€
;€€					                                 €€
;€€      Created:   6-Mar-97		                                 €€
;€€      Passes:    5          Analysis	Options on: none                 €€
;€€					                                 €€
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

.286c


; The following equates show data references outside the range of the program.

data_2e		equ	200h			;*
data_3e		equ	0FEC0h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

init		proc	far

start:
		mov	al,13h
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		xor	ax,ax			; Zero register
		mov	ah,0A0h
		db	 8Eh,0E0h
loc_1:
		mov	dx,3C8h
		out	dx,al			; port 3C8h, VGA pel address
		inc	dx
		push	ax
		xor	al,0FFh
		shr	al,1			; Shift w/zeros fill
		out	dx,al			; port 3C9h, VGA pel data reg
		out	dx,al			; port 3C9h, VGA pel data reg
		out	dx,al			; port 3C9h, VGA pel data reg
		pop	ax
		inc	ax
		jnz	loc_1			; Jump if not zero
		push	cs
		pop	es
		mov	ah,4Ah			; 'J'
		call	sub_4
		call	sub_3
		push	ax
		call	sub_3
		mov	ds,ax
		mov	es,ax
		mov	cl,80h
		mov	si,cx
		xor	bx,bx			; Zero register
		call	sub_1
		pop	es
		mov	si,0A0h
		mov	cx,64h
		dec	bx
		call	sub_1
		mov	dx,3DAh
loc_2:
		in	al,dx			; port 3DAh, CGA/EGA vid status
		test	al,8
		jnz	loc_2			; Jump if not zero
		call	sub_2
		xchg	ah,al
		call	sub_2
		add	cx,102h
		xor	di,di			; Zero register
		xchg	si,ax
		mov	ax,140h
		mov	bh,es:data_3e[di]
		mov	bl,es:[di-1]
		inc	di
		sub	bh,byte ptr es:[13Fh][di]
		sub	bl,es:[di]
		mov	bl,[bx+si]
		db	 64h, 88h, 1Dh, 46h, 48h, 75h
		db	0E5h, 83h,0EEh, 40h, 81h,0FFh
		db	 00h,0FAh, 75h,0D9h,0EBh,0C0h

init		endp

;ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
;                              SUBROUTINE
;‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹

sub_1		proc	near
		mov	dx,cx
		neg	dx
		mov	bp,si
		neg	si
		db	 8Eh,0EEh,0E8h, 54h, 00h, 8Eh
		db	0E9h,0E8h, 4Fh, 00h,0DEh,0C1h
		db	0D9h,0FAh,0D0h,0CBh, 73h, 0Eh
		db	 90h, 90h, 2Eh,0DEh, 36h,0FEh
		db	 01h,0D9h,0FEh, 2Eh,0DEh, 0Eh
		db	0FAh, 01h, 2Eh,0DFh, 1Eh, 00h
		db	 02h, 2Eh,0A0h, 00h, 02h,0AAh
		db	 46h, 3Bh,0F5h, 75h,0D1h, 49h
		db	 3Bh,0CAh, 75h,0CAh,0C3h

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_2:
		mov	cs:data_2e,cx
		db	 2Eh,0DFh, 06h,0FCh, 01h,0D9h
		db	0EBh, 2Eh,0DEh, 0Eh, 00h, 02h
		db	0D8h,0F1h,0D9h,0FEh,0DEh,0C9h
		db	 2Eh,0DFh, 1Eh, 02h, 02h, 2Eh
		db	 86h, 26h, 02h, 02h, 86h,0E9h
		db	0C3h, 2Eh, 8Ch, 2Eh, 00h, 02h
		db	 2Eh,0DFh, 06h, 00h, 02h,0D9h
		db	0C0h,0DEh,0C9h,0C3h

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_3:
		mov	ah,48h			; 'H'

;ﬂﬂﬂﬂ External Entry into Subroutine ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ

sub_4:
		mov	bx,1000h
		int	21h			; DOS Services  ah=function 4Ah
						;  change memory allocation
						;   bx=bytes/16, es=mem segment
		retn
sub_1		endp

		db	 40h, 00h, 80h, 00h, 04h, 00h

seg_a		ends



		end	start
