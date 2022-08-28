
PAGE  59,132

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ				RIDDLE	                                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛ      Created:   6-Mar-97		                                 ÛÛ
;ÛÛ      Passes:    5          Analysis	Options on: none                 ÛÛ
;ÛÛ					                                 ÛÛ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ

target		EQU   'T2'                      ; Target assembler: TASM-2.X

include  srmacros.inc

.286c


; The following equates show data references outside the range of the program.

data_4e		equ	1FFh			;*
data_5e		equ	140h
data_6e		equ	0FEC0h

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

riddle		proc	far

start:
		mov	al,13h
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		push	0A000h
		pop	es
		call	sub_3
		mov	cl,5
		mov	data_2,2300h
		mov	word ptr ds:data_4e,19Ah

locloop_1:
		push	cx
		mov	dx,ds:data_4e
		call	sub_1
		mov	cl,23h			; '#'
		add	word ptr ds:data_4e,19h

locloop_2:
		push	cx
		mov	cx,0FFFFh

locloop_3:
		call	sub_2
		mov	bx,dx
		mov	ah,es:[bx]
		cmp	ah,0
		je	loc_4			; Jump if equal
		inc	ah
		mov	es:data_6e[bx],ah
		mov	es:data_5e[bx],ah
		mov	es:[bx-1],ah
		mov	es:[bx+1],ah
loc_4:
		loop	locloop_3		; Loop if cx > 0

		pop	cx
		loop	locloop_2		; Loop if cx > 0

		pop	cx
		add	data_2,2600h    ;2300h
		loop	locloop_1		; Loop if cx > 0

		mov	ax,3
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		retn

riddle		endp

;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_1		proc	near
		mov	ah,9
		int	21h			; DOS Services  ah=function 09h
						;  display char string at ds:dx
		retn
sub_1		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_2		proc	near
		mov	bx,data_1
		add	bx,9248h
		ror	bx,1			; Rotate
		ror	bx,1			; Rotate
		ror	bx,1			; Rotate
		mov	data_1,bx
		mov	ax,data_2
		mul	bx			; dx:ax = reg * ax
		retn
sub_2		endp


;ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                              SUBROUTINE
;ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ

sub_3		proc	near
		mov	cl,0FFh
		mov	ax,0FF01h

locloop_5:
		mov	dx,3C8h
		out	dx,al			; port 3C8h, VGA pel address
		inc	dx
		xchg	ah,al
		out	dx,al			; port 3C9h, VGA pel data reg
		out	dx,al			; port 3C9h, VGA pel data reg
		out	dx,al			; port 3C9h, VGA pel data reg
		xchg	ah,al
		inc	al
		dec	ah
		loop	locloop_5		; Loop if cx > 0

		retn
sub_3		endp

data_1		dw	1111h
data_2		dw	0
		db	0Ah, 0Ah, 0Ah, 0Dh, 0Ah, 9, '    '
		db	'   OverCool   $'
		db	0Ah, 0Ah, 0Ah, 0Dh, 0Ah, 9, '    '
		db	'     was      $'
		db	0Ah, 0Ah, 0Ah, 0Dh, 0Ah, 9, '    '
		db	'    here...   $'
		db	0Ah, 0Ah, 0Ah, 0Dh, 0Ah, 9, '    '
		db	' Fuck you :<  $$'

seg_a		ends



		end	start
