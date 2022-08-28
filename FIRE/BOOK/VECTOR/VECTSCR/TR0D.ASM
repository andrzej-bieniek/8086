lewe    dw  40 dup(11111111b,01111111b,00111111b,00011111b,00001111b,00000111b,00000011b,00000001b)
prawe   dw  40 dup(10000000b,11000000b,11100000b,11110000b,11111000b,11111100b,11111110b,11111111b)

TrData	dw  400 dup(0,0)

Trian PROC
        mov   	bx,y1
        cmp   	bx,y3
        jl    	@Oka1
        mov   	dx,x1
        xchg  	dx,x3
        xchg  	bx,y3
        mov   	x1,dx
        mov   	y1,bx
@oka1:
        mov   	bx,y2
        cmp   	bx,y3
        jl    	@Oka2
        mov   	dx,x2
        xchg  	dx,x3
        xchg  	bx,y3
        mov   	x2,dx
        mov   	y2,bx
@oka2:
        mov   	bx,y1
        cmp   	bx,y2
        jl    	@Oka3
        mov   	dx,x1
        xchg  	dx,x2
        xchg  	bx,y2
        mov   	x1,dx
        mov   	y1,bx
@oka3:
;----------------dx12-------------
	mov      cl,5
        mov      bx,y2
        sub      bx,y1
        jnz      @ok_zero1
	mov      bx,1
@ok_zero1:
        mov      dx,x1 
        shl      dx,cl
        mov      ax,x2
        shl      ax,cl
        sub      ax,dx
        jns      @Ok_znak1
        neg      ax
        neg      bx
@ok_znak1:
        mov      dx,0
        idiv     bx
        mov      dx12,ax
@tutaj1:
        mov      dx,y1
        mov      yk1,dx
        mov      dx,x1
        shl      dx,cl
        mov      xk1,dx
;----------------dx13--------------
        mov      bx,y1
        sub      bx,y3 
        jnz      @ok_zero2
	mov	 bx,1
@ok_zero2:
        mov      dx,x3
        shl      dx,cl
        mov      ax,x1
        shl      ax,cl
        sub      ax,dx
        jns      @Ok_znak2
        neg      ax
        neg      bx
@ok_znak2:
        mov      dx,0
        idiv     bx
        mov      dx13,ax
@tutaj2:
        mov      dx,y1
        mov      yk2,dx
        mov      dx,x1
        shl      dx,cl
        mov      xk2,dx
;-----------------dx23-------------------
        mov      bx,y2
        sub      bx,y3
        jnz      @ok_zero3
	mov	 bx,1
@ok_zero3:
        mov      dx,x3
        shl      dx,cl
        mov      ax,x2
        shl      ax,cl
        sub      ax,dx
        jns      @Ok_znak3
        neg      ax
        neg      bx
@ok_znak3:
        mov      dx,0
        idiv     bx
        mov      dx23,ax
@tutaj3:
        mov      dx,y2
        mov      yk3,dx
        mov      dx,x2
        shl      dx,cl
        mov      xk3,dx	
;**********************************************************
;xk1+dx12 xk2+dx13 yk1->y2
	mov	si,dx12
	mov	di,dx13
	lea	bp,TrData
	mov	ax,y1
	mov	cs:[bp],ax
	add	bp,2
	mov	cx,y2
	sub	cx,yk1
	jz	LiniaNr2
LL1:
	push	cx
	mov	cl,5
	mov	ax,xk1
	mov	dx,xk2
	sar	ax,cl
	sar	dx,cl
	mov	cs:[bp],ax
	mov	cs:[bp+2],dx
	add	bp,4
	add	xk1,si
	add	xk2,di
	pop	cx
	loop	LL1
;**********************************************************
;xk3+dx23 xk2+dx13 yk1 -> y3
LiniaNr2:
	mov	cx,y3
	sub	cx,y2
	jz	End_of_Trian
	mov	si,dx23
LL2:		
	push	cx
	mov	cl,5
	mov	ax,xk3
	mov	dx,xk2
	sar	ax,cl
	sar	dx,cl
	mov	cs:[bp],ax
	mov	cs:[bp][2],dx
	add	bp,4
	add	xk3,si
	add	xk2,di
	pop	cx
	loop	LL2
End_of_trian:
;*************************************************************
	lea	bp,TrData
	mov	bx,cs:[bp]
	cmp	bx,199
	jg	End_of_prTrian
	mov	cx,y3
	sub	cx,y1
	jz	End_of_prTrian
	add	bp,2
	
	cmp	bx,0
	jge	okbx1
	neg	bx
	sub	cx,bx
	jb	End_of_prTrian
	jz	End_of_prTrian
	shl	bx,1
	shl	bx,1
	add	bp,bx
	mov	bx,0
okbx1:	
	mov	ax,bx
	add	ax,cx
	cmp	ax,199
	jle	oksbxcx
	mov	cx,199
	sub	cx,bx
	jz	End_of_prTrian
oksbxcx:
;-----------------------------------	
	mov	dx,SegOfScreen
	mov	es,dx
DrTrian:
	push	cx
	mov	ax,cs:[bp]
	mov	cx,cs:[bp][2]
	push	bx
	push	bp
	jmp	Linia
Zlinia:	
	pop	bp
	pop	bx
	pop	cx
	inc	bx
	add	bp,4
	loop	DrTrian	
End_of_prTrian:		
	ret
	
;*************************************************************
Linia:
	cmp	ax,cx
	jl	OKaxcx
	xchg	ax,cx
Okaxcx:
	cmp	ax,0
	jnl	okaxl
	cmp	cx,0
	jl	End_of_linia
	xor	ax,ax
okaxl:	
	cmp	cx,319
	jle	okcxp
	cmp	ax,319
	jg	End_of_linia
	mov	cx,319
okcxp:	
	shl	bx,1
	mov	di,cs:Lines[bx]
	mov	bx,ax
	sar	bx,1
	sar	bx,1
	sar	bx,1
	add	di,bx
	mov	bx,ax
	shl	bx,1
	mov	si,lewe[bx]
	mov	bx,cx
	shl	bx,1
	mov	bp,prawe[bx]
	sar	cx,1
	sar	cx,1
	sar	cx,1
	sar	ax,1
	sar	ax,1
	sar	ax,1
	sub	cx,ax
	jz	wspolna
	dec	cx
	mov	ax,si
	
	or	es:[di],al
	inc	di
	;**********
	mov	ax,11111111b
	rep	stosb
	mov	ax,bp

	or	es:[di],al
	inc	di
	;**********
	
	jmp	Zlinia
wspolna:
	and	si,bp
	mov	ax,si

	or 	es:[di],al
	;*********
End_of_linia:	

	;*
	
	;*

	jmp	Zlinia
	
	ENDP				
