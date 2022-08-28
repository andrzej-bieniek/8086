;
; CAMARS.ASM
;
; Notes:
;
;   I rolled the horizontal and vertical draw routines into loops for clarity
;
;  I moved the whole main program over to the C code.
;
;  I added rotate code.  It uses an incremental algorithm similar to
;  bresenhams line formula to calculate points on the first 45 degree
;  arc of a circle, then reflects the points calculated into whatever
;  quadrants are being viewed.  It uses the points generated to sample
;  the mountain map and draw the heights.  This is faster than simply
;  applying the rotation formula directly.
;
;  programmer:
;    Original code, unknown
;    De-optimized (clarified code) and rotation modifications:
;		David Lindauer, e-mail gclind01@ulkyvx.louisville.edu
;		July 19, 1995
;
        .386

        Jumps

	extrn sintable : word, costable: word, _B : word

	PUBLIC _FadeOut, _FadeIn, _ClearPAL, _ReadPalette, _PaletteOut
	PUBLIC _MakeMakeTable, _MakeMarsPalette, _InitRandom
	PUBLIC _DrawView,_CalcFractal
	PUBLIC	_CalcSky, _CalcMountains, _UpdateViewCoord
	PUBLIC	_UpdateSky, _UpdateMountains
	PUBlIC _SwitchToText, _SwitchToGraphics, _RetFARData, _DeltaMove
	PUBLIC _ReleaseFarData

	PUBLIC _Map_Seg, _Color_Seg,_Sky_Seg,_InternalScreen_Seg
	PUBlIC	_MapMakeTable,_AddCXTable,_AddDXTable, _MapCoord
	PUBLIC _MountHeight, _Map_X, _Map_Y, _RandomSeed
	PUBLIC	_BiosPal, _MarsPal, _W_Divider, _Count_Loop
	
	PUBLIC  _FlyHeight, _Angle

SkyPalette = 64
MountainPalette = 0
MidbandPalette = 128
NullPalette = 192

;
; Paragraph offsets into the 256Kb extra memory we are going to alloc
;
MapAOFFS = 0
MapBOFFS = 1000h
SkyOFFS = 2000h
InternalScreenOFFS = 3000h


_DATA	SEGMENT DWORD PUBLIC USE16 'DATA'

_Map_Seg        dw      MapAOFFS
_Color_Seg        dw      MapBOFFS
_Sky_Seg         dw      SkyOFFS
_InternalScreen_Seg	dw	InternalScreenOFFS
_MapMakeTable    dw      41 dup (0000h), 10 dup (0001h), 09 dup (0003h)
LastMake        dw      0003h, 0000h
_AddCXTable      dw       16, -16, -8, 32
_AddDXTable      dw      -32, -32, 16, 32
_MapCoord        dw      0000h, 0004h, 0202h, 0FEFFh   ;0,4,514,65279 decimal
VRAM_Seg        dw      0A000h		; VGA memory
baseangles	dw	255,128,127,0,-1,-128,-129,-256,-257,-384,-385,-512
AngleConv	dw	4096/360  	; 512/360*8
;
; reflection bits, used to reflect bits from first octant into other
; ll octants as needed
;
reflectswap	dw	0000011001100110b
reflectnegx	dw	0000110000111100b
reflectnegy	dw	0000000011110000b
_W_Divider       dw      0DB97h		; 56215 decimal, controls the mountain
					; density .. the bigger the more 
_MountHeight	dw	0
_Map_X		dw	0
_Map_Y		dw	0
_RandomSeed	dw	0
PerspectiveIndex	dw	0
RelativeHeight	dw	0
ReciprocalPerspective	dw	0
CurrentCol	dw	0
_Count_Loop	dw	0
_Angle		dw	0
_NormAngle	dw	0
angletab	dw	12 DUP (0)
intermedangletab dw	5 DUP (0)
octant		dw	0
Table_A		dw	256 Dup (0)
Table_B		dw	256 Dup (0)
_BiosPal	db	256 *3 Dup (0)
_MarsPal	db	256 *3 Dup (0)
TempPal		db	256 *3 Dup (0)

_FlyHeight	db	0

	align 4
SkyMountHeight	dd	0
SkyX	dd	0
SkyY	dd	0
D		dd	0
Xrel		dd	0
Yrel		dd	0
Xpos		dd	0
Ypos		dd	0
RfourthCsquared	dd	0
TwoRfourthCsquared	dd	0
RC		dd	0
DeltaX		dd	0
DeltaY		dd	0

_DATA	ENDS



_TEXT 	SEGMENT WORD PUBLIC USE16 'CODE'
	assume cs:_TEXT, ds:_DATA, es:nothing,fs:nothing,gs:nothing
;--------------------------Miscellaneous subroutines-------------------

;
; Return the map data segments
;
; prototype: unsigned RetFARData(void)
;
_RetFARData	proc	far
		mov ah,48h	; Allocate memory func
		mov bx,4000h	; Allcoate 4096 paragraphs, or 64K
		int 21h		; Allocate the memory
		jc not_allocated ; Error if couldn't complete
		ret
 not_allocated:
		mov ax, 0
		ret
_RetFARData	endp
;
; Release data area
;
; prototype: void ReleaseFarData(unsigned seg)
;
		thefarseg = bp+6
_ReleaseFarData	proc	far
		push	bp
		mov	bp,sp
		mov	bx,[thefarseg]
		mov	ah,49h
		int	21h
		pop	bp
		ret
_ReleaseFarData	endp

;
; Wait for Vertical retrace to go high, then low
; i.e. sync with start of display
;
; Modifies: dx,al
;
WaitVRT       proc	near
                mov     dx, 03DAh       ; Input status reg #1
  @wv1:
                in      al, dx          ; While Vertical Retrace is low
                test    al, 8           ;
                jz      @wv1           ;
  @wv2:
                in      al, dx          ; Loop while retrace is high
                test    al, 8           ;
                jnz     @wv2           ;
		ret
WaitVRT	endp
;
; Draw a palette to palette mem
;
; Input regs:
;	si = palette to draw
;
; Modifies: dx,al
;
PaletteOut	proc 	near
		push	si
                call	WaitVRT            ;
		cli
                mov     cx, 3*256       ;
                mov     dx, 03C8h       ; Set beginning of palette regs
                mov     al, 00h         ;
                out     dx, al          ;
                inc     dx              ; Point to palette data reg
                rep     outsb           ; Output the palette
		sti
                call	WaitVRT
		pop	si
		ret
PaletteOut	endp
;
; Shell for calling palette out routine from C
;
_PaletteOut	proc	far
		palette = dword ptr [bp+6]
		push	bp
		mov	bp,sp
		push	si
		push	ds
		lds	si,[palette]
		call	PaletteOut
		pop	ds
		pop	si
		pop	bp
		ret
_PaletteOut	endp
;
; Fade out.
;
; Input regs:
;	si = palette to fade
; modifies: dx,ax,bx,cx,di  
;
; prototype:  void fadeout(BYTE *table);
;
_FadeOut	proc far
		table = dword ptr [bp + 6]
		push	bp
		mov	bp,sp
		push	ds
		push	si
		push	di
		
		
		push	ds
		pop	es
          	mov     bx, 0200h	; BH = increment, bl = current color compare
  @fo1:
		lds	si,[table]
		
;
; Blank out any entry that is less than color compare
;
                mov     cx, 3*256       ; 256 palette entries, 3 colors/palette
		mov	di,offset TempPal
  @fo2:        
                lodsb                   ; if source < color compare
                sub     al, bl
                cmc
                sbb     ah, ah          ; use 0
                and     al, ah          ; Else use color
                stosb                   ; To dest

                loop    @fo2
;
; Draw the palette
;
		push	es
		pop	ds
		mov	si,offset TempPal
		call	PaletteOut
;
; Loop if not done
;
                add     bl, bh          ; Next color compare
                test    bl, 3Fh         ; Only 63 intensities
                jnz     @fo1
		pop	di
		pop	si
		pop	ds
		pop	bp
		ret
_FadeOut		ENDP

; Fade in
;
; input regs:
;	si = palette to fade
;
; modifies: ax,bx,cx,dx,di
;
; prototype: void FadeIn(BYTE *table)
_FadeIn 		proc	far
		table = dword ptr [bp + 6]
		push	bp
		mov	bp,sp
		push	ds
		push	si
		push	di

		push	ds
		pop	es
                mov     bx, 0FE40h	; bh = increment, bl = color compare
  @fi1:
		lds	si,[table]
		mov	di,offset TempPal
;
; Blank out any color less than color compare
;
   	        mov     cx, 3*256	;
  @fi2:
                lodsb			; if source < color compare
                sub     al, bl		;
                cmc			;
                sbb     ah, ah		; use 0
                and     al, ah		; Else use color
                stosb			;
                loop    @fi2
;
; Output the palette
;
		push	ds
		pop	es
		mov	si,offset TempPal
		call	PaletteOut
                add     bl, bh		; Next color compare
                test    bl, 3Fh
                jnz     @fi1
		pop	di
		pop	si
		pop	ds
		pop	bp
		ret
_FadeIn		ENDP

;
; Clear palette
;
; Modifies: si,eax,cx,dx
;
;prototype: void ClearPAL(void);
;
_ClearPAL  	proc far
		push	si
		push	di
		push	ds
		pop	es
		mov	di,offset TempPal
		sub	eax,eax
		mov	cx,768/4
		rep	stosd
		mov	si,offset TempPal
 		call	PaletteOut
		pop	di
		pop	si
		ret
_ClearPAL	endp

;
; Read a palette in using bios
;
; input: 
;	dx = palette offset
;
; modifies: es,bx,cx,ax
;
; prototype: ReadPalette(BYTE *table)
;
;
_ReadPalette		proc far	
		table = dword ptr [bp + 6]
		push	bp
		mov	bp,sp
		push	ds
		push	ds
		pop	es
		lds	dx,[table]
                xor     bx, bx
                mov     cx, 256			; read block of color registers
                mov     al, 17h			; into TempPAL1
                mov     ah, 10h
                int     10h
		pop	ds
		pop	bp
		ret
_ReadPalette		endp
	
;
; Switch to graphics mode
; modifes: ax
;
; prototype: void SwitchToGraphics(void)
_SwitchToGraphics proc far
                mov     al, 13h			; Set 320x200 graphics mode
                mov     ah, 00h
		int	10h
		ret
_SwitchToGraphics endp
;
; Switch to text mode
;
; modifies: ax
;
; prototype: void SwitchToText(void)
_SwitchToText	proc	far
                mov     al, 03h		; Put us in text mode
                mov     ah, 00h
                int     10h             ; Switch Back to Char Mode
		ret
_SwitchToText	endp
;
; Make the map make table
;
; modifies ax,cx,di,es
;
; prototype: void MakeMakeTable(void)
;
_MakeMakeTable	proc	far
		push	di
		push	ds
		pop	es
		mov	di,offset _MapMakeTable
		mov	ax,0ffffh
                mov     cx, (offset LastMake-offset _MapMakeTable)/2+1	; Size of map make table
  @Decompress2:
                add     ax, [di]	; ax = ax + value  in table +1
                inc     ax		;
                stosw			; Value in table = ax
                loop    @Decompress2	; until CX = 0
		pop	di
		ret
_MakeMakeTable	endp
;
; Make the palette for the prog
;
; modifies: everything
;
; Prototype: void MakeMarsPalette(void)
;
_MakeMarsPalette	PROC	far
		push	si
		push	di
 		mov	di,offset _MarsPal
		mov	si,di
		sub	ax,ax
		mov	cx,64
@map:
;
; Mountain palette entry
; ( gray scale)
;
		mov	[di],al
		mov	[di+1],al
		mov	[di+2],al
;
; Sky palette entry
; (blue scale)
;
		mov	byte ptr [di + SkyPalette*3],0
		mov	byte ptr [di + SkyPalette*3+1],0
		mov	[di + SkyPalette*3+2],al
;
; Midband palette entry
; (green scale)
;
		mov	byte ptr [di + MidbandPalette*3],0
		mov	[di + MidbandPalette*3+1],al
		mov	byte ptr [di + MidbandPalette*3+2],0
;
;Null palette, unused
;
		mov	byte ptr [di + NullPalette*3],0
		mov	byte ptr [di + NullPalette*3+1],0
		mov	byte ptr [di + NullPalette*3+2],0
		inc	al
		inc	di
		inc	di
		inc	di
		loop	@map
		call	PaletteOut
		pop	di
		pop	si
		ret
_MakeMarsPalette	ENDP
;
; Init random # generator
;
; modifies ax,dx
;
;prototype: void InitRandom(void)
;
_InitRandom	proc	far
                xor     ax, ax
                int     1Ah			; get CLOCK value in DH
                and     dh, 7Fh
                mov     dx, 7FCFh               ; preset RND seed in DX
                mov     [_RandomSeed], dx
		ret
_InitRandom	endp
;
; Get a random number
;
; input:
;	si = seed
; output:
;	si = dx = random #
; Modifies: ax,si,dx
;
RandomNumber	proc	near
                mov     ax, 0AFh	; 175 decimal
                mul     si
                add     ax, 2BC0h	; 11200 decimal
                adc     dx, 0
                div     [_W_Divider]
                mov     si, dx
		ret
RandomNumber	endp
;
; Draw a view
;
; modifies: es,si,ax,di,bl,cx
;
; prototype: void DrawView(void)
_DrawView	proc	far
		push	ds
		push	si
		push	di
                mov     es, [VRAM_Seg]		
		sub	si,si
		mov	ax, [_InternalScreen_Seg]
		mov	ds,ax
                mov     di, (320-256)/2		; Center image horizontally
                mov     bl, 200			; 200 lines
						; Actual image is 256 * 200
  @Copy2VRAM:
                mov     cx, 256/4		; Draw a line
                rep     movsd			;
                add     di, (320-256)		; Move to start of next line 
		dec	bl			;
                jnz     @Copy2VRAM		; Draw whole screen
		pop	di
		pop	si
		pop	ds
		ret
_DrawView	endp
;---------------------------Calculation and view routines---------------
;
; Using Fractals to generate the terrain.  Nifty neeto I always wanted
; to know how this was done!
;
; The map this generates is 256x256.  Each byte generated is a height
;
; This routine takes a square of arbitrary size, and calculates the height
; of the midpoints of each line joining the corners using a combination
; of the average height of the corners and a psuedo-random algorithm.
; Then it calculates the height of the center point by averaging the four
; midpoints and applying the psuedo-random generator.  Then it uses
; Recursion to do the same thing to each of the four squares so generated.
; Each of these squares is then recursed into 4 more squares, until all
; bytes in the array are filled in.
;
; Randomize the average height
; For large cl this gives us a random number which can vary
; significantly from the midpoint.  For smaller cl the variance will be
; smaller.  Thus local maxima and minima will be maintained
;
; Randomize Average Height
;
; Modifies ax,si,dx,ch
;
; input:
;	cl = granularity
;	si = random number seed
;	al = number to randomize
; output:
;	al = randomized value
;
RandomizeAvgHeight   proc	near
		mov	ch,al
		call	RandomNumber
                sub     dx, 67E8h ; Magic number, what's it do to random #
                xor     ax, ax	; dx = ((cl *8 *rn)/10000h ) + avg heigh
                mov     al, cl
                shl     ax, 3
                imul    dx
                xor     ax, ax
                add     dl, ch  ;
                mov     ch, al  ; ch = 0
                adc     dh, ch  ;
                js      @CS2   ; If dh <0 use 0
                jz      @CS1	; if dh =0 use dl
				; Else dh >0use 0feh
                mov     dl, 0FEh
  @CS1:        
                mov     al, dl
  @CS2:				; Else if dh = 0 use 0
		ret
RandomizeAvgHeight	endp
;
; Get the average height between two points & randomize it
;
; modifies: ax,bx,ch,dx,di
;
; input:
;	di = buffer pos to write to
;	al = first height
;	bx = position of second height
;
RandomizeMidpoint    proc	near
                cmp     byte ptr es:[di], 0FFh ; Don't draw over what is there
                jne     @CS3
                add     al, es:[bx] ; Average current height and old height
                adc     ah, ch
                shr     ax, 1
                call	RandomizeAvgHeight   ; Calc
                stosb           ; Save the height we got by randomizing the average
  @CS3:
		ret
RandomizeMidpoint	endp

;
; Fractalize a 256x256 map
;
; Modifies: everything
;
CalcFrac	proc	near
                shr     cx, 1
                jz      OutCalcFrac	; Quit when the granularity is too thin
;
; First we calculate the height at the halfway pt at each side of the square
;
                xor     ax, ax
                add     al, es:[bx]	;al = map byte
                adc     ah, ch          ; NOP
                add     bl, cl		; Load DI up with halfway point
                mov     di, bx          ; 
                add     bl, cl		; Move to another corner of square
                call	RandomizeMidpoint		; Fill in the midpoint
                xor     ax, ax
                add     al, es:[bx]	; al = height here at new bx
                adc     ah, ch		; nop
                add     bh, cl		; Load DI up with halfway point
                mov     di, bx
                add     bh, cl          ; Move to another corner of square
                call	RandomizeMidpoint		; Fill in the midpoint
                xor     ax, ax		; Contine to next corner of square
                add     al, es:[bx]
                adc     ah, ch
                sub     bl, cl
                mov     di, bx
                sub     bl, cl
                call	RandomizeMidpoint
                xor     ax, ax		; And now work back to origin of square
                add     al, es:[bx]
                adc     ah, ch
                sub     bh, cl
                mov     di, bx
                sub     bh, cl
                call	RandomizeMidpoint
;
; Now we average all the halfway values
;
                xor     ax, ax
                add     al, es:[bx]
                adc     ah, ch
                add     bl, cl
                add     bl, cl
                add     al, es:[bx]
                adc     ah, ch
                add     bh, cl
                add     bh, cl
                add     al, es:[bx]
                adc     ah, ch
                sub     bl, cl
                sub     bl, cl
                add     al, es:[bx]
                adc     ah, ch
                shr     ax, 2
                call	RandomizeAvgHeight		; Randomize it
                add     bl, cl		; Move to midpoint of square
                sub     bh, cl
                mov     es:[bx], al	; Fill it in
;
; Now we use recursion to handle the four squares we have subdivided into
;
; i.e. we are going to calculate the height at the midpoint of each
; side of each square.  Since we are using recursion that will recurse
; into the height at the midpoint of each of the 16 squares we generate
; And so on.  The check at the beginning of this function checks for
; byte granularity; when we hit that there are no more points to be filled
; in and we've hit the bottom level of recursion
;
                push    bx
		push	cx
		call	CalcFrac
                pop     cx
                pop     bx
                sub     bl, cl
                push    bx
		push	cx
		call	CalcFrac
                pop     cx
                pop     bx
                sub     bh, cl
                push    bx
		push	cx
		call	CalcFrac
                pop     cx
                pop     bx
                add     bl, cl
		call	CalcFrac
OutCalcFrac:
		ret
CalcFrac	endp
;
; Shell for calling the calc fractal routine from C
;
; prototype: CalcFractal(unsigned seg)
;
_CalcFractal	proc	far
		seg = word ptr [bp + 6]
		push	bp
		mov	bp,sp
		push	si
		push	di
		mov	es,[seg]
		call	CalcFrac
		pop	di
		pop	si
		pop	bp
		ret
_CalcFractal	endp
;;--------------------------Section End---------------------------
;
; Calculate the sky map
;
; modifies: everything
;
; prototype: void CalcSky(void)
;
_CalcSky		proc	far
		push	bp
		push	si
		push	di
                xor     di, di
                mov     es, [_Sky_Seg]
                stc
		mov	eax, 0FFFFFFFFh  ; TAG
                mov     cx, 4000h	; Set sky seg to all ffs ( color 255 = nothing drawn)
                rep     stosd			; repeats 16384 times
                mov     si, [_RandomSeed]
		call	RandomNumber
		mov	[_RandomSeed],si
                xor     bx, bx          	; Start at offset 0
                mov     cx, 0100h		; 8 levels of recursion
                mov     byte ptr es:[0080h], -2	; Put in a couple of maximums
                mov     byte ptr es:[8000h], -2
                mov     byte ptr es:[0000h],  cl ; Put in a couple of minimums
                mov     byte ptr es:[8080h],  cl
		call	CalcFrac		; Calculate the sky colors
;
; Adjust the sky map colors
; into the sky palette
;
                xor     di, di
  CalcSky1:
                mov     al, es:[di]
                shr     al, 2		; Sky Color pointer
		add	al,SkyPalette
                stosb
                or      di, di
		jnz	CalcSky1
		pop	di
		pop	si
		pop	bp
		ret
_CalcSky		endp
;
; Calculate the mountains
;
; modifies: everything
;
; Prototype: void CalcMountains(void)
;
_CalcMountains	proc	far
		push	bp
		push	si
		push	di
                mov     es, [_Map_Seg]  ;  CalcMap ??
                mov     fs, [_Color_Seg]
		mov	eax,0ffffffffh
		sub	di,di
                mov     cx, 4000h	; Set the map to all ffffs
		rep	stosd		; 
                mov     si, [_RandomSeed]; Next random seed
		call	RandomNumber
                mov     [_RandomSeed], si;
                xor     bx, bx          ; 
                mov     cx, 0100h	; 256 decimal
		mov	byte ptr es:[0000],40	; Make an average sized mountain
		call	CalcFrac	; Calculate mountain heights
;
; Now average each point with three other nearby points to smooth out the
; mountains a little.
;
                xor     di, di
  CalcMap1:
                xor     ax, ax
                mov     si, offset _MapCoord
                mov     bx, [si]
                add     al, es:[bx+di]
                adc     ah, ch
                inc     si
                inc     si
                mov     bx, [si]
                add     al, es:[bx+di]
                adc     ah, ch
                inc     si
                inc     si
                mov     bx, [si]
                add     al, es:[bx+di]
                adc     ah, ch
                inc     si
                inc     si
                mov     bx, [si]
                add     al, es:[bx+di]
                adc     ah, ch
                shr     ax, 2		; Taking an average
                stosb
                or      di, di
                jnz     CalcMap1
;
; Set up map B.  This does the lighting effect from the right
;
                xor     si,si
  CalcMap2:
                mov     al, es:[si]
                sub     al, es:[si+3]
                sbb     ah, ah
                add     ax, 20h	
                jns     CalcMap3
                xor     ax, ax
  CalcMap3:
                cmp     al, 3Fh		; Palette range 0-63
                jbe     CalcMap4
                mov     al, 3Fh
  CalcMap4:
		mov	fs:[si],al
                inc     si
                jnz     CalcMap2
;
; Another averager.  Average four points next to each other to
; smooth out some of the rough spots.
;
  CalcMap5:
                xor     ax, ax
                add     al, es:[di]
                adc     ah, ch
                add     al, es:[di+0100h]	; 256 decimal
                adc     ah, ch
                inc     di
                add     al, es:[di]
                adc     ah, ch
                add     al, es:[di+0100h]	; 256 decimal
                adc     ah, ch
                dec     di
                shr     ax, 2		; flattens plane (big = flat)
                stosb
                or      di, di
                jnz     CalcMap5
		pop	di
		pop	si
		pop	bp
                ret
_CalcMountains	endp

;
; Calculate the X, Y , Z coordinates of our viewpoint
;
;
; Update the view coordinates
;
; Modifies: ax,bx,cx,dx, si
;
; prototype: void UpdateViewCoord(void)
;
_UpdateViewCoord	proc	far
		push	si
                mov     cx, [_Map_X]
                mov     dx, [_Map_Y]
; Calculate Z coordinate
;
                mov     es, [_Map_Seg]		; Calculate New Points
                ror     cx, 4			;; X_Pos / 16
                ror     dx, 4			;; Y_Pos / 16
                mov     bl, cl                  ; bh,bl = y,x ( high 8 bits)
                mov     bh, dl
                shr     cx, 0Ch			; cx = x low 4 bits
                shr     dx, 0Ch			; dx = y low 4 bits
                push    dx
                inc     bl
                xor     ax, ax
                add     al, es:[bx]
		dec	bl
                sub     al, es:[bx]
                sbb     ah, ah
                imul    cx
                mov     dx, ax			; DX = dif in height * xlow4
                xor     ax, ax
                add     al, es:[bx]
                shl     ax, 4			
                add     ax, dx
                xchg    si, ax                  ; si = dx + height*16
                inc     bh                      ; move diagonally
                inc     bl                      ;
                xor     ax, ax
                add     al, es:[bx]
		dec	bl
                sub     al, es:[bx]
                sbb     ah, ah
                imul    cx
                mov     dx, ax                  ; DX = dif in height * xlow4
                xor     ax, ax
                add     al, es:[bx]
                shl     ax, 4
                add     ax, dx			; ax = dx + height * 16 - si
                pop     dx                      ;
                sub     ax, si                  ;
                imul    dx                      ; ax = ax * ylow4 + si*16
                shl     si, 4
                add     ax, si
		pushf
		cmp	[_FlyHeight], 0		; are we flying ?
		je	CalcNew0

		cmp	ah, [_FlyHeight]	; are we flying below the
		jae	CalcNew0	; highest mountain ?
		popf
		mov	ah, [_FlyHeight]
		jmp	CalcNew9
  CalcNew0:
		popf
;                add     ah, 1Ah	; Offset us above the mountains a little ways
                add     ah, 14h	; Offset us above the mountains a little ways
                jnc     CalcNew9
                mov     ax, 0FFFFh	; 65535 decimal
  CalcNew9:
                mov     [_MountHeight], ax		; Checked
		pop	si
		ret

_UpdateViewCoord	endp
;;--------------------------Section End---------------------------

;
; Draw the sky, scaling and making it diagonal (99 lines)
; Draw a line of color 50h
; Also draw the midband below the sky, give it a gradient ( 40 lines)
;
;;--------------------------Section Start-------------------------
;
; shift EDX:EAX right 15 with sign
;
shiftright15	proc
	mov	cx,15
@srl:
	sar	edx,1
	rcr	eax,1
	loop	@srl
	ret
shiftright15	endp
;
; Rotate one of the sky lines
;
; input:
;   eax = dist
; output;
;   bl:ax = x
;   bh:dx = y
;   DeltaX = delta for x
;   DeltaY = delta for y

rotate_skyline	proc
	push	edi

;
; Offset to sine table
;
	mov	si,[_Angle]
	shl	si,1
	push	eax
;
; Calculate xcos(angle)
;
	movsx	ebx,[si+costable]
	imul	ebx
	call	shiftright15
	mov	edi,eax		; edi = xcos(angle)
;
; Calculate xsin(angle)
; 
	pop	eax
	movsx	ebx,[si+sintable]
	imul	ebx
	call	shiftright15
	mov	esi,eax		; esi = xsin(angle)

;
; Calculate x' = xcos(angle)-ysin(angle)
;
	mov	ecx,edi
	sub	ecx,esi
;
; Calculate y' = xsin(angle)+ycos(angle)
;
	mov	edx,esi
	add	edx,edi
;
; DeltaX = Delta*cos(angle)
;
	
	sar	edi,7		; Scale down xcos(angle)
	mov	[DeltaX],edi
;
; DeltaY = Delta*sin(angle)
;
 	sar	esi,7		; Scale down xsin(angle)
	mov	[DeltaY],esi	
;
; Up to now we've been doing relative rotation based around
; (Map_X, Map_Y)
;
;
; Offset X from where we are and load up bl:cx
;	
	mov	eax,[SkyX]
	add	ecx,eax
	mov	ebx,ecx
	mov	cx,bx
	shr	ebx,16
;
; Offset Y from where we are and load up bh:dx
;
	mov	eax,[SkyY]
	add	eax,edx
	mov	dx,ax
	shr	eax,16
	mov	bh,al
	
;
; load up bl:ax
;
 	mov	ax,cx
	pop	edi
	ret
rotate_skyline	endp
;
; Update the sky view
;
; modifies: everything
;
; prototype: void UpdateSky(void)
;
_UpdateSky	proc	far
		push	si
		push	di
                xor     eax, eax
		mov	ax,[_MountHeight]
		neg	ax              ; (- _MountHeight/8 + 16384)
                shr     ax, 3
                add     ah, 40h		; 64 decimal   
                shl     eax, 4          ; * 16
                shl     eax, 9          ; *512
		mov	[SkyMountHeight],eax
                xor     eax, eax
		mov	ax,[_Map_X]
                shl     eax, 9          ; * 512
		mov	[SkyX],eax
                xor     eax, eax
		mov	ax,[_Map_Y]
                shl     eax, 9          ; *512
		mov	[SkyY],eax
;
; Now we scale the sky for distance and draw it
;
                mov     gs, [_Sky_Seg]	; Point at sky data
		mov	ecx,63h
		sub	di,di
		mov	es,[_InternalScreen_Seg] ; Point at our screen
  @UpdateSky1:
		push	ecx
                mov     eax, [SkyMountHeight]	; Adjusted mountain height
                xor     edx, edx        ;
                div     ecx             ; Divided by number of lines left
		call	rotate_skyline
;
; Draw one line of the sky
;
		mov	cx,256
 @usl:
		mov	si,bx
                db      65h                 ; GS segment override prefix
                movsb
		add	ax,word ptr [DeltaX]
		adc	bl,byte ptr [DeltaX+2]
		add	dx,word ptr [DeltaY]
		adc	bh,byte ptr [DeltaY +2]
		loop	@usl
		pop	ecx
                loop     @UpdateSky1
;
;
;
                mov     eax, 50505050h		; Draw a line of color 50h
                mov     cx, 40h
                rep     stosd			; repeats 64 times

;
; Now draw the midband.  We don't need to rotate this, it is constant
;

                mov     si, [_MountHeight]
                mov     bx, 04			; Starting divisor
  @UpdateSky2:
                mov     ax, si			; Divide height by divisor
                xor     dx, dx
                div     bx
                shr     ax, 7			; And shift right to get color
                cmp     al, 3Fh			; 63 decimal
                jbe     @UpdateSky3
                mov     al, 3Fh			; 63 decimal
  @UpdateSky3:
		add	al,MidbandPalette
                mov     ah, al			; Replicate color throughout EAX
                mov     dx, ax
                shl     eax, 10h
                xchg    ax, dx
                mov     cx, 40h			; Draw a line of this color
                rep     stosd			; repeats 64 times
                inc     bx			; Next devisor
                cmp     bx, 2Ch			; Drawing 40 lines of this
                jne     @UpdateSky2
		pop	di
		pop	si
		ret
_UpdateSky	endp

;
; Calculate the X, Y deltas for the angle we are moving at
;
; prototype void DeltaMove(int distance, int angle)
;
; angle MUST be in the range 0 - 359
;
		angle = bp+8
		distance = bp+6
_DeltaMove	proc	far
		push	bp
		mov	bp,sp
		push	si
;
; Get the angle
;
		mov	si,[angle]		; Angle
		shl	si,1			; Index into cos/sin tables

;
; x delta = x cos(angle)
;
		movzx	eax,word ptr [distance]
		movsx	ebx,[si+costable]
		imul	ebx
		sar	eax,15
		add	[_Map_X],ax
;
; y delta = y cos(angle)
;
		movzx	eax,word ptr [distance]
		movsx	ebx,[si+sintable]
		imul	ebx
		sar	eax,15
		add	[_Map_Y],ax

		pop	si
		pop	bp
		ret
_DeltaMove	endp
;
; Shift Right 16 times
;
shiftright16	proc
		mov	cx,16
srl16:
		sar	edx,1
		rcr	eax,1
		loop	srl16
		ret
shiftright16	endp
;
; Shift Right 8 times
;
shiftright10	proc
		mov	cx,10
srl10:
		sar	edx,1
		rcr	eax,1
		loop	srl10
		ret
shiftright10	endp
;
; Init Circle Coords
;
; input:
;	si = radius
; output:
;   DeltaX, DeltaY, D , Xrel, Yrel, RfourthCsquared, TwoRcubedC  initted
init_coords	proc
;
; Calculate RC
;
		movzx	eax,[_B]
		mul	esi
		call	shiftright16		; We are keeping a 16-bit fraction
		mov	[RC],eax
;
; Calculate D = 5rfourthCsqaured/4-RfourthC
;
; This is rsqaured*csqaured
		mul	eax
		call	shiftright16

;
; This is RfourthCsquared
;
		mul	esi
		call	shiftright16
		mul	esi
		call	shiftright16
		call	shiftright10		; We shift the decision variables
						; to keep their values within
						; a 32-bit dword
		mov	[RfourthCsquared],eax
		mov	[TwoRfourthCsquared],eax
		shl	[TwoRfourthCsquared],1
;
; Times 5/4
;
		mov	ebx,eax
		shl	ebx,2
		add	eax,ebx
		shr	eax,2
		mov	[D],eax
;
; This is RfourthC
;
		mov	eax,[RC]
		mul	esi
		call	shiftright16
		mul	esi
		call	shiftright16
		call	shiftright10
		mul	esi
		call	shiftright16
		sub	[D],eax
;
; This is DeltaX = 2RfourthC
;
		shl	eax,1
		mov	[DeltaX],eax
;
; This is Yrel & DeltaY
;
		sub	eax,eax
		mov	[Yrel],eax
		mov	[DeltaY],eax
;
; This is Xrel
;
		mov	[Xrel],esi

		ret
init_coords	endp		
;
; Calculate new circle coords and deltas and C
;
calc_coords	proc
		bt	[D],31			; Check sign of decision variable
		jc	nodeltax		; If neg use old X
		mov	eax,[RC]	
		sub	[Xrel],eax      	; Else update X and decision vars
		mov	eax,[TwoRfourthCsquared]
		sub	[DeltaX],eax
		mov	eax,[DeltaX]
		sub	[D],eax
nodeltax:
		mov	eax,[RC]		; Now update Y and decision vars
		add	[Yrel],eax
		mov	eax,[TwoRfourthCsquared]
		add	[DeltaY],eax
		mov	eax,[RfourthCsquared]
		add	[D],eax
		mov	eax,[DeltaY]
		add	[D],eax
		ret
calc_coords	endp
;
; Get absolute X,Y coords
;
; output:
;	bl:cx = x coord
;	bh:dx = y coord
;
get_coords	proc
;
; Calculate X coord in bl:cx
;
		mov	ecx,[Xpos]
		movzx	eax,[_Map_X]
		shl	eax,12
		add	ecx,eax
		mov	ebx,ecx		; CX has X fraction
		sar	ebx,16		; BL has X integer
;
; Calculate Y coord in bh:dx
;
		mov	edx,[Ypos]
		movzx	eax,[_Map_Y]
		shl	eax,12
		add	edx,eax		; DX has Y fraction
		mov	eax,edx		;
		sar	eax,16		; BH has Y integer
 		mov	bh,al

		ret
get_coords	endp
;
		
; Draw a height at a point
;
draw_height	proc
		push	dx
                shr     cx, 1			; Divide new fraction by 2
                mov     al, fs:[bx+1]
                sub     al, fs:[bx]
                sbb     ah, ah
		imul	cx			; height dif * fraction/128
                shrd    ax, dx ,7		;
                add     ah, fs:[bx]		; + current height
                mul     [ReciprocalPerspective]		; * 10000h / perspective scale
                mov     di, [RelativeHeight]	; Subtracted from r16b
                sub     di, dx			;
                jns     @UpdateMountains5		; If < 0 make -1
                mov     di, 0FFFFh
  @UpdateMountains5:
                cmp     di, 0C8h	; See if fits on screen
                jl      @UpdateMountains6
                mov     di, 0C7h	; If not force it to
  @UpdateMountains6:
                mov     al, gs:[bx+1]		; Height dif * upper part of fraction *2
                sub     al, gs:[bx]		;
		imul	ch			;
                shl     ax, 1			;
                add     ah, gs:[bx]             ; + height at current point
                mov     dx, ax
						; Table A & B are used to correlate two 
						; different perspectives with each other
                xchg    ax, [si+Table_B]	; Distance to go before changing shades
                mov     bp, di			; Lines high in table A
                xchg    bp, [si+Table_A]
                sub     bp, di   		; Quit if distance to go < lines high
                jns     @UpdateMountains7
                shl     di, 8			; Get y coord
                add     di, [CurrentCol] ; + row,col of point
                push    ax			; 
                sub     ax, dx                  ; (New dit to go - old dist to go)/lines high
		cwd
		idiv	bp
                pop     dx			; DX = dist to go
                push    bx
                lea     bx, [bp+1]		; bh = (lines high + 1), bl = 0
                shl     bx, 8
;
; Draw a vertical line
;
  @uml:
                mov     es:[bx+di], dh	; 
                add     dx, ax		; 
                inc     bh		; 
		inc	bp   
		jnz	@uml
                pop     bx
  @UpdateMountains7:
		pop	dx
                shl     cx, 1
		ret
draw_height	endp
;
; Load reflect coords
;
reflect_coords	proc
		mov	ecx,[Xrel]		; Load up x,y coords
		mov	edx,[Yrel]		;
		bt	[reflectswap],bx	; See if have to swap this octant
		jnc	noswap			;
		xchg	ecx,edx			; Yes, do it
noswap:
		bt	[reflectnegx],bx	; See if x is neg this octant
		jnc	nonegx
		neg	ecx			; Yes, do it
nonegx:
		bt	[reflectnegy],bx	; See if y is neg this octant
		jnc	nonegy
		neg	edx			; Yes, do it
nonegy:
		mov	[Xpos],ecx		; Save values of X&Y to use
		mov	[Ypos],edx
		mov	si,[intermedangletab+si]; Get the column to draw in
		mov	[CurrentCol],si	
		shr	[CurrentCol],1		; column in table was table ofs	
		ret
reflect_coords	endp
	
;
; Reflect our lower 45 degree angle into appropriate quadrants
;
reflect_angle	proc
		push	si
		mov	dx,si
;
; Copy the relevant octant angles to the intermediate table
;
		push	es
		push	ds
		pop	es
		mov	cx,5			; We can draw in up to five 
		mov	bx,[octant]		; octants
		lea	si,[angletab + bx]	; Select the first octant
		mov	di,offset intermedangletab ; Get local table
itc:
		lodsw				; Get the base angle
		bt	bx,1			; If octant number odd
						; we current si, 
		jc	itca
		sub	ax,dx           	; Else we subtract it
		jmp	short itcb	
itca:
		add	ax,dx
itcb:
		stosw				; Save the local value
		xor	bl,2			; Switch odd/even flag
		loop	itc			;
		pop	es			;
		xor	bl,2			; Restore odd/even flag to orig
		shr	bl,1			; state & make the table index
						; a straight octant number
;
; Check if drawing in first or fifth octants
;
		sub	si,si			; First relative octant
		push	bx			; Save absolute octant
		mov	ax,[intermedangletab]	; See whether reflecting
						; angle into fifth octant
		cmp	ax,512
		jc	firstoct		;
		add	si,8			; Yes, adjust octant ptrs
		add	bx,4			;
firstoct:
		call	reflect_coords		; Reflect coords for this octant
		call	get_coords		; Get coords
		call	draw_height		; Draw the height
		pop	bx                      ; Absolute octant
		sub	si,si			; Relative octant = 0
		mov	cx,3			; Drawing three octants
refloop:
		
		inc	si			; Next octant
		inc	si			;
		inc	bx			;
		push	cx			;
		push	bx			;
		push	si			;
		call	reflect_coords		; Reflect coords into this octant
		call	get_coords		; Translate coords to draw_height
						; Format
		call	draw_height		; Draw the height
		pop	si
		pop	bx
		pop	cx
		loop	refloop			; Loop till done
		pop	si
		ret
reflect_angle	endp
;
; Draw mountains
;
; prototype: void UpdateMountains(void)
;

_UpdateMountains	proc	far
		push	bp
		push	si
		push	di
                mov     fs, [_Map_Seg]		; Get the map height seg
                mov     gs, [_Color_Seg]		; The map shading seg
		push	ds
		pop	es
;
; Fill tables with default
;
                mov     eax, 7D007D00h		; Initialiae table a
                mov     di, offset Table_A
                mov     cx, 80h			; 64 decimal
                rep     stosd			; repeats 64 times
                xor     eax, eax
                mov     di, offset Table_B   	; Initilaize table b
                mov     cx, 80h	
                rep     stosd			; repeats 64 times
;
; Calculate norm angle in 512ths of a circle
;
		mov	ax,[_Angle]		; multiply by 4096/360
		mul	[AngleConv]		;
		shr	ax,3			; We want 512/360
		mov	[_NormAngle],ax		; Save the angle
;
; Calculate angletab & octant
;	
		mov	cx,12			; 12 possible octants
		mov	bx,ax			; The viewing angle in 512ths
		mov	si,offset baseangles	; We are going to calculate drawing
		mov	di,offset angletab	; angles based on the viewing angle
						; And the default drawing angle for
						; a 0 degree view
atc:
		lodsw				; Get default
		add	ax,bx			; Add in viewing angle
		shl	ax,1			; Make it a TABLE_A /TABLE_B index
		stosw				; Save custom value
		loop atc			; Loop til done
		mov	[octant],0		; Assume octant is 0
olp:
		sub	bx,64			; Sub one octant ; 64/512 = 1/8
		jle	doneoctant		; Quit if went under 0
		inc	[octant]		; Else we are up an octant
		jmp	olp			; Loop around
doneoctant:
		shl	[octant],1		; Make the octant a table index

                mov     [PerspectiveIndex], 78h		; Initialze R16a to item 60
			; This is scale factor pointer for perspective
;
; First calculate mountain height relative to horizon
;
		mov	es, [_InternalScreen_Seg] ; The draw seg
  @UpdateMountains1:
                movzx   esi, [PerspectiveIndex]		; 
                mov     si, [si+_MapMakeTable]	; Get an item in map make tbl
                shl     si, 4			; *4
                mov     ax, [_Map_Y]		; Get low 4 bits of y coord
                and     ax, 0Fh			;
                xor     al, 0Fh                 ; Invert them
                add     si, ax                  ; Add them with map make table
                mov     ax, [_MountHeight]	; Divide mountain height by this
                xor     dx, dx
		div	si
                add     ax, 64h			; Add 100 lines in
                mov     [RelativeHeight], ax		; This is r16B
                cmp     [PerspectiveIndex], 2		; if index was 2
                jne     @UpdateMountains2
                mov     [RelativeHeight], 7D00h	; Set default values
                mov     [ReciprocalPerspective], 0000h	;
                jmp     @UpdateMountains3
  @UpdateMountains2:
                xor     ax, ax			; Else divide new inde into 10000h
                mov     dx, 1
		div	si
                mov     [ReciprocalPerspective], ax;
  @UpdateMountains3:
		shl	esi,12
		call	init_coords		; Initialize circle coords at (r,0)
                mov     si, 0			; First item
						; (Rotating counter-clockwise)
;
; Main draw loop, draws a line of mountains at given depth of view
;
  @UpdateMountains4:
		call	reflect_angle		; Reflect the x,y coord into
						; the viewed octants
		call	calc_coords		; Calculate next point on circle
                inc     si
                inc     si
		cmp	si,63*2
                jbe     @UpdateMountains4
                sub     [PerspectiveIndex], 2		; get next closes ROW depth POV
                jnz     @UpdateMountains1
		pop	di
		pop	si
		pop	bp
		ret
_UpdateMountains	endp
_TEXT	ends
	end