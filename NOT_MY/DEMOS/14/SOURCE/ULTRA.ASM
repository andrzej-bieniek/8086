
PAGE  59,132

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;лл					                                 лл
;лл				ULTRA	                                 лл
;лл					                                 лл
;лл      Created:   9-May-99		                                 лл
;лл      Passes:    5          Analysis	Options on: none                 лл
;лл					                                 лл
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

target		EQU   'T2'                      ; Target assembler: TASM-2.X

.486p

.387


; The following equates show data references outside the range of the program.

data_1e		equ	0F0h
data_9e		equ	200h			;*
data_10e	equ	33Fh			;*
data_11e	equ	340h			;*
data_12e	equ	341h			;*
data_13e	equ	480h			;*
data_14e	equ	1234h			;*
data_15e	equ	80E0h			;*
data_16e	equ	99B8h			;*
data_17e	equ	0F9FFh			;*

seg_a		segment	byte public use16
		assume	cs:seg_a, ds:seg_a


		org	100h

ultra		proc	far

start:
;*		fninit				; Initialize math uP
		db	0DBh,0E3h		;  Fixup - byte match

		mov	al,13h
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		mov	di,200h   
		mov	ch,0FDh
		mov	ax,3F00h
		rep	stosb			; Rep when cx >0 Store al to es:[di]
		mov	dx,3C8h
		out	dx,al			; port 3C8h, VGA pel address
		inc	dx
		mov	di,data_11e
		mov	si,di
		mov	cl,20h			; ' '

locloop_1:
		inc	di
		stosb				; Store al to es:[di]
		mov	[di+5Eh],ax
		mov	[di+60h],al
		inc	di
		add	al,2
		loop	locloop_1		; Loop if cx > 0

		mov	cl,0C0h
		rep	outsb			; Rep when cx >0 Out [si] to port dx
;*		fild	data_7			; Push integer to stk
		db	0DFh, 06h,0FCh, 01h	;  Fixup - byte match
;*		fldz				; Push +0.0 to stack
		db	0D9h,0EEh		;  Fixup - byte match
loc_2:
		inc	ch
;*		fldz				; Push +0.0 to stack
		db	0D9h,0EEh		;  Fixup - byte match

locloop_3:
;*		fld	st(1)			; Push onto stack
		db	0D9h,0C1h		;  Fixup - byte match
;*		fdiv	st,st(3)		; st = st / st(#)
		db	0D8h,0F3h		;  Fixup - byte match
;*		fsin
		db	0D9h,0FEh		;  Fixup - byte match
;*		fmul	st,st(3)		; st = st * st(#)
		db	0D8h,0CBh		;  Fixup - byte match
;*		fadd	st,st(1)
		db	0D8h,0C1h		;  Fixup - byte match
;*		fsincos				; Sin and cos
		db	0D9h,0FBh		;  Fixup - byte match
;*		fld	st(3)			; Push onto stack
		db	0D9h,0C3h		;  Fixup - byte match
;*		fsin
		db	0D9h,0FEh		;  Fixup - byte match
;*		fimul	data_8			; st = st * memory
		db	0DEh, 0Eh,0FEh, 01h	;  Fixup - byte match
;*		fist	word ptr ds:[1AAh]	; Store st to memory
		db	0DFh, 16h,0AAh, 01h	;  Fixup - byte match
;*		fld	st(3)			; Push onto stack
		db	0D9h,0C3h		;  Fixup - byte match
;*		fmul	st,st(6)		; st = st * st(#)
		db	0D8h,0CEh		;  Fixup - byte match
;*		fsin
		db	0D9h,0FEh		;  Fixup - byte match
;*		fmulp	st(1),st		; st(#)=st(#)*st, pop
		db	0DEh,0C9h		;  Fixup - byte match
;*		fiadd	data_8
		db	0DEh, 06h,0FEh, 01h	;  Fixup - byte match
;*		fmul	st(1),st		; st(#) = st(#) * st
		db	0DCh,0C9h		;  Fixup - byte match
;*		fmulp	st(2),st		; st(#)=st(#)*st, pop
		db	0DEh,0CAh		;  Fixup - byte match
;*		fistp	word ptr ds:[16Fh]	; Pop st to memory
		db	0DFh, 1Eh, 6Fh, 01h	;  Fixup - byte match
;*		fistp	word ptr ds:[16Ch]	; Pop st to memory
		db	0DFh, 1Eh, 6Ch, 01h	;  Fixup - byte match
;*		fadd	dword ptr data_6	; st = st + memory
		db	0D8h, 06h,0F8h, 01h	;  Fixup - byte match
		mov	si,data_14e
		mov	bx,data_14e
		imul	si,si,140h		; reg1 = reg2 * value
		mov	word ptr ds:data_15e[bx+si],3737h
		loop	locloop_3		; Loop if cx > 0

;*		fstp	st			; Pop st to st(#)
		db	0DDh,0D8h		;  Fixup - byte match
;*		fadd	dword ptr data_5	; st = st + memory
		db	0D8h, 06h,0F4h, 01h	;  Fixup - byte match
		mov	dl,0DAh
loc_4:
		in	al,dx			; port 3DAh, CGA/EGA vid status
		and	al,8
		jz	loc_4			; Jump if zero
		mov	di,data_17e
loc_5:
		mov	al,ds:data_12e[di]
;		add	al,ds:data_10e[di]
;		add	al,ds:data_13e[di]
		add	al,ds:data_9e[di]
		shr	al,2			; Shift w/zeros fill
		mov	ds:data_11e[di],al
		dec	di
		jnz	loc_5			; Jump if not zero
		push	ds
		pop	es
		mov	di,1234h
		add	di,di
		add	di,data_16e
		mov	si,data_11e
		mov	cl,32h			; '2'

locloop_6:
		mov	al,50h			; 'P'
loc_7:
		movsb				; Mov [si] to es:[di]
		add	si,3
		dec	al
		jnz	loc_7			; Jump if not zero
		add	si,3C0h
		add	di,data_1e
		loop	locloop_6		; Loop if cx > 0

		push	0A000h
		pop	es
		xor	di,di			; Zero register
		mov	ch,0FAh
loc_8:
		mov	al,ds:data_11e[di]
		and	bl,7
		add	al,bl
		add	bx,bp
		ror	bp,3			; Rotate
		add	bp,bx
		stosb				; Store al to es:[di]
		dec	cx
		jnz	loc_8			; Jump if not zero
		in	al,60h			; port 60h, keybd scan or sw1
		das				; Decimal adjust
		jc	loc_2			; Jump if carry Set
		mov	ax,3
		int	10h			; Video display   ah=functn 00h
						;  set display mode in al
		retn
data_5		dw	0CCCDh, 3D4Ch
data_6		dw	0FDBh, 3CC9h
data_7		dw	6
data_8		dw	2Dh

ultra		endp

seg_a		ends



		end	start
