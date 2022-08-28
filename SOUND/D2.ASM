

code 	SEGMENT para public 'CODE'
	ASSUME cs:code
	LOCALS
	.386

ORG	100h
start:	
;       cld	;filler to make the filesize exactly 1993 bytes
;	cld	;filler to make the filesize exactly 1993 bytes
  	jmp	main


;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ Simplex Adlib Player ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;this doesn't just read raw data to output to adlib like the one
;used in the last starport intro. This player really does have 
;note & instrument data it reads and processes!

;±±±±±±±±±±±±±±±± output data to adlib ±±±±±±±±±±±±±±
a_lodsboutaw03: ;size optimization related entry (instrument loading)
	call	a_lodsboutaw
	add	ah,3
a_lodsboutaw: ;size optimization related entry (instrument loading)
	lodsb
a_outaw	PROC NEAR ;ah=reg,al=data
	push	ax
	push	cx
	xchg	al,ah
	mov	dx,388h
	out	dx,al
	mov	cx,7
	call	a_wait
	mov	dx,389h
	mov	al,ah
	out	dx,al
	mov	cx,30
	call	a_wait
	pop	cx
	pop	ax
	ret
a_wait:	in	al,dx
	loop	a_wait
	ret
a_outaw	ENDP

;±±±±±±±±±±±±±±±± load instrument to adlib ±±±±±±±±±±±±±±
a_loadinstrument PROC NEAR
	;bx=channel, ds:si=offset to instrument data
	mov	ah,ds:a_inst_table[bx]
	mov	cx,4
@@1:	call	a_lodsboutaw03
	add	ah,20h-3
	loop	@@1
	add	ah,40h
	call	a_lodsboutaw03
	mov	ah,bl
	add	ah,0c0h
	jmp	a_lodsboutaw
a_loadinstrument ENDP

;±±±±±±±±±±±±±±±± set note on/off ±±±±±±±±±±±±±±
a_playnote PROC NEAR
	;bx=channel, ax=data
	push	bx
	xchg	ah,bl
	add	ah,0a0h
	call	a_outaw
	mov	al,bl
	add	ah,010h
	pop	bx
	jmp	a_outaw
a_playnote ENDP

;±±±±±±±±±±±±±±±± initialize/clear/shutup adlib ±±±±±±±±±±±±±±
a_init PROC NEAR
	mov	ax,00120h
	call	a_outaw
	mov	ax,00800h
	call	a_outaw
	mov	ah,0bdh
	call	a_outaw
	mov	bp,9
	xor	bx,bx
	mov	di,OFFSET music_instruments
@@1:	mov	si,ds:[di]
	add	di,2
	call	a_loadinstrument
	xor	ax,ax
	call	a_playnote
	inc	bx
	dec	bp
	jnz	@@1	
	ret
a_init ENDP

;±±±±±±±±±±±±±±±± advance music one row ±±±±±±±±±±±±±±
a_dorow PROC NEAR
	sub	ds:a_musiccnt,1
	jnc	@@0
	mov	ds:a_musiccnt,music_speed
	mov	cx,music_channels
	mov	di,OFFSET music_patterns
	xor	bx,bx
@@1:	sub	ds:a_chdelaycnt[bx],1
	jns	@@2
	mov	si,ds:[di]	
	xor	ax,ax
	call	a_playnote
@@4:	lodsb	
	or	al,al
	jz	@@7
	jns	@@6
	sub	al,81h
	mov	ds:a_chdelay[bx],al
	lodsb
@@6:	mov	dl,al
	and	ax,15
	mov	bp,ax
	add	bp,bp
	mov	ax,ds:a_note_table[bp]
	shr	dl,2
	and	dl,not 3
	add	ah,dl
	call	a_playnote
	mov	al,ds:a_chdelay[bx]
	mov	ds:a_chdelaycnt[bx],al
	mov	ds:[di],si
@@2:	add	di,4
	inc	bx
	loop	@@1
@@0:	ret
@@7:	mov	si,ds:[di+2]
	jmp	@@4
a_dorow ENDP

;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ Intro Routines ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ


;±±±±±±±±±±±±±±±± timer ±±±±±±±±±±±±±±±±
inittimer PROC NEAR
	mov	eax,fs:[8*4]
	mov	ds:oldint8,eax
	mov	ax,cs
	shl	eax,16
	mov	ax,OFFSET intti8
	mov	dx,17000 ;70hz
	jmp	@@1
deinittimer:
	mov	eax,ds:oldint8
	xor	dx,dx
@@1:	cli
	mov	fs:[8*4],eax
	mov	al,036h
	out	43h,al
	mov	al,dl
	out	40h,al
	mov	al,dh
	out	40h,al
	sti
	ret
inittimer ENDP

intti8	PROC FAR ;timer interrupt
	push	ax
	mov	al,20h
	out	20h,al
	inc	cs:framecounter
	pop	ax
	iret
intti8	ENDP




;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ Main routine ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;stack @ cs:0fffeh

main	PROC NEAR
	call	a_init
	call	inittimer
;ÍÍÍÍÍÍÍÍÍ Do the intro stuff ÍÍÍÍÍÍÍÍÍ
again: 
       xor 	cx,cx
      	xchg	cx,ds:framecounter
	jcxz	@@78
@@77:	push	cx
	call	a_dorow
       pop	cx

@@78:	
       in 	al,60h
	cmp 	al,1
	jnz again

	call	deinittimer
	call	a_init ;reinitializing adlib shuts it up


	mov	ax,4c00h
	int	21h
main	ENDP
	
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ Initialized (nonzero) data ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ



;adlib player data
a_inst_table LABEL BYTE
	db 20h+0,20h+1,20h+2,20h+8,20h+9,20h+10,20h+16,20h+17,20h+18
NTB equ 8192 ;+1024*1
a_note_table LABEL WORD
	dw NTB+363,NTB+385,NTB+408,NTB+432,NTB+458,NTB+485
	dw NTB+514,NTB+544,NTB+577,NTB+611,NTB+647,NTB+868
	;note: a zero word is expected after this table (found in col0)
	

;################## Music - (tune by skaven/fc) ###################
;generated with ST3->SIMPLEXADLIB, handoptimized by psi (283 bytes)

music_channels equ 8
music_speed equ 8
music_instruments LABEL BYTE
dw OFFSET ains6
dw OFFSET ains2
dw OFFSET ains4
dw OFFSET ains3
dw OFFSET ains3
dw OFFSET ains1
dw OFFSET ains1
dw OFFSET ains4
ains1 LABEL BYTE
db 65,194,6,0,35,242,240,240,1,0,4
ains2 LABEL BYTE
db 145,64,135,128,243,111,35,3,1,1,2
ains3 LABEL BYTE
db 225,33,17,128,17,19,34,34,0,0,12
ains4 LABEL BYTE
db 97,33,27,0,98,132,86,85,0,0,14
ains6 LABEL BYTE
db 145,64,135,136,243,111,35,3,1,1,2
music_patterns LABEL BYTE
ach0 dw OFFSET ach0d,OFFSET ach0dr
ach1 dw OFFSET ach1d,OFFSET ach1dr
ach2 dw OFFSET ach2d,OFFSET ach2dr
ach3 dw OFFSET ach3d,OFFSET ach3d
ach4 dw OFFSET ach4d,OFFSET ach4d
ach5 dw OFFSET ach5d,OFFSET ach5d
ach6 dw OFFSET ach6d,OFFSET ach6d
ach7 dw OFFSET ach7d,OFFSET ach7d
ach0d LABEL BYTE
db 081h
ach0dr LABEL BYTE
db 057h,050h,050h,055h,057h,050h,055h,057h
db 050h,055h,057h,050h,055h,057h,050h,055h
db 0
ach1d LABEL BYTE
db 081h
ach1dr LABEL BYTE
db 050h,055h,057h,050h,055h,057h,050h,055h
db 057h,050h,055h,057h,050h,055h,057h,050h
db 0
ach2d LABEL BYTE
db 0C0h,050h,084h
db 030h,020h,030h,020h,02Ah,01Ah,02Ah,01Ah
db 030h,020h,030h,020h,02Ah,01Ah,02Ah,01Ah
ach2dr LABEL BYTE
db 030h,020h,030h,020h,02Ah,01Ah,02Ah,01Ah
db 025h,015h,025h,015h,028h,018h,02Ah,01Ah
db 0
ach3d LABEL BYTE
db 0A0h,050h,040h,0C0h,040h,088h,040h,040h
db 03Ah,042h,090h,045h,088h,040h,042h,040h
db 047h,090h,04Ah,088h,045h,098h,040h
db 0
ach4d LABEL BYTE
db 0A0h,050h,030h,0C0h,047h,088h,047h,043h
db 042h,045h,047h,045h,048h,047h,047h,050h
db 052h,084h,050h,04Ah,088h,050h,098h,045h
db 0
ach5d LABEL BYTE
db 0C0h,020h,0A0h,010h,010h,090h,010h,02Ah
db 025h,088h,028h,02Ah,090h,010h,02Ah,025h
db 088h,028h,02Ah
db 0
ach6d LABEL BYTE
db 0C0h,020h,0A0h,020h,020h,090h,020h,01Ah
db 015h,088h,018h,01Ah,090h,020h,01Ah,015h
db 088h,018h,01Ah
db 0
ach7d LABEL BYTE
db 0C0h,00Ch,0FEh,050h,090h,00Ch,081h,04Ah
db 050h,084h,052h,055h,086h,04Ah,081h,050h
db 04Ah,086h,050h,082h,055h,098h,045h
db 0
;#########################################################










;adlib data
a_musiccnt dw	0
a_chdelaycnt db	9 dup(0)
a_chdelay db	9 dup(0)

;misc
;scrollsubber dw	0
framecounter dw	0
oldint8	dd	0


code 	ENDS
	END start
