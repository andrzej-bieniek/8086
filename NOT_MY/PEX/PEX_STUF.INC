;
; pe header structure
;
	signature			equ	0	; PE,0,0
	cputype				equ	4	; i386,i486 etc...
	numObj				equ	6	; count of sections
	timestamp			equ	8
	symboltable			equ	12
	symbolnum			equ	16
	NtHeaderSize			equ	20
	DllFlags			equ	22	; file is DLL or PE?
	reserved3			equ	24
	lmajor				equ	26	; linker major
	lminor				equ	27	; linker minor
	codesize			equ	28
	initdatasize			equ	32
	uninitdatasize			equ	36
	entrypointRVA			equ	40	; starting address
	baseofcode			equ	44
	baseofdata			equ	48
	imagebase			equ	52
	objalign			equ	56	; align between objects in file
	filealign			equ	60	; align between objects in memory
	imagesize			equ	80
	headersize			equ	84
	checksum			equ	88	; checksum
	dllflags			equ	94
	loaderflags			equ	112	; not used at all
	edatadir			equ	120
	import				equ	128	; import table RVA
	importsize			equ	132	; imports size
	resource			equ	136
	ressize				equ	140
	reloc				equ	160	; relocation table RVA
	relocsize			equ	164	; relocation table size
	debug				equ	168
	debugsize			equ	172
	tls				equ	192
	tlssize				equ	196
	entryiat			equ	216
	entryiatsize			equ	224
	dimport				equ	224
	dimportsize			equ	232

;
; object structure
;
	objname				equ	0	; section name		2DWORD
	objvsize			equ	8	; virtual size		DWORD
	objrva				equ	12	; rva of section	DWORD
	objpsize			equ	16	; raw size		DWORD
	objpoff				equ	20	; raw offset		DWORD
	objrle				equ	24	; relocations		DWORD
	objline				equ	28	; linenumbers		DWORD
	objrlenum			equ	32	; no of relocations	WORD
	objlinenum			equ	34	; no of linenumbers	WORD
	objflags			equ	36	; object flags		DWORD
	objlen				equ	40	; total object length

;
; SetFilePointer stuff
;
	FILE_BEGIN			equ	0
	FILE_CURRENT			equ	1
	FILE_END			equ	2
;
; mapping stuff
;
	PAGE_READONLY			equ	2
	PAGE_READWRITE			equ	4     
	PAGE_WRITECOPY			equ	8     
	SECTION_QUERY			equ	1
	SECTION_MAP_WRITE		equ	2
	SECTION_MAP_READ		equ	4
	SECTION_MAP_EXECUTE		equ	8
	SECTION_MAP_EXTEND_SIZE		equ	10
	FILE_MAP_COPY			equ	SECTION_QUERY
	FILE_MAP_WRITE			equ	SECTION_MAP_WRITE
	FILE_MAP_READ			equ	SECTION_MAP_READ

	MEM_COMMIT                      equ     00001000h
	MEM_RESERVE                     equ     00002000h
	MEM_DECOMMIT                    equ     00004000h
	MEM_RELEASE                     equ     00008000h
	MEM_FREE                        equ     00010000h
	MEM_PRIVATE                     equ     00020000h
	MEM_MAPPED                      equ     00040000h
	MEM_TOP_DOWN                    equ     00100000h

	OF_READ				equ	0h	;open file only for read
	OF_WRITE			equ	1h	;open file only for write
	OF_READWRITE			equ	2h	;open file only for read+write

	OFN_HIDEREADONLY		equ	4
	OFN_OVERWRITEPROMPT		equ	2
	FILE_ATTRIBUTE_NORMAL		equ	080h
	OPEN_EXISTING			equ	3
	GENERIC_READ			equ	80000000h
	GENERIC_WRITE			equ	40000000h
	FILE_SHARE_READ			equ	0001h
	FILE_ATTRIBUTE_ARCHIVE		equ	00000020h

	CREATE_NEW			equ	1
	CREATE_ALWAYS			equ	2
	OPEN_EXISTING			equ	3
	OPEN_ALWAYS			equ	4
	TRUNCATE_EXISTING		equ	5

	CR				equ	0Dh
	LF				equ	0Ah

	NORMAL_PRIORITY_CLASS           equ	00000020h
	IDLE_PRIORITY_CLASS             equ	00000040h
	HIGH_PRIORITY_CLASS             equ	00000080h
	REALTIME_PRIORITY_CLASS         equ	00000100h

	ERROR_ALREADY_EXISTS		equ	183

	PC_WRITEABLE			equ     00020000H
	PC_USER				equ     00040000H
	PC_STATIC			equ     20000000H
	PC_LOCKED			equ	00000080H
	VMM				equ	00001h

	_cf				equ	0000000000000001b	; carry flag
	_pf				equ	0000000000000100b	; parity flag
	_af				equ	0000000000010000b	; auxilary flag
	_zf				equ	0000000001000000b	; zero flag
	_sf				equ	0000000010000000b	; sign flag
	_tf				equ	0000000100000000b	; trap flag
	_if				equ	0000001000000000b	; interrupt flag
	_df				equ	0000010000000000b	; direction flag
	_of				equ	0000100000000000b	; overflow flag
;
; pushad
; usage:
; pushad
; ...
; ...
; mov	[esp+_eax],eax
; popad
;
	_edi				equ	0
	_esi				equ	4
	_ebp				equ	8
	_esp				equ	12
	_ebx				equ	16
	_edx				equ	20
	_ecx				equ	24
	_eax				equ	28


	VxDCall	macro   Service
		db	0CDh
		db	020h
		dd	Service
		endm

	VMMCall	macro   ServiceVMM
		db	0CDh,20h
		dw	ServiceVMM
		dw	VMM
		endm

	MEMF struct
		mem_ptr		dd ?
		mem_handle	dd ?
		file_handle	dd ?
		file_size	dd ?
	MEMF ends
	MEMF_		equ 4*4


	CONSOLESCREENBUFFERINFO	struct
		c_width		dw ?
		c_height	dw ?
		c_X		dw ?
		c_Y		dw ?
		c_attribs	dw ?
		c_smallrect	dd 2 dup(?)
		c_maxwidth	dw ?
		c_maxheight	dw ?
	CONSOLESCREENBUFFERINFO	ends
	CONSOLESCREENBUFFERINFO_ equ 2+2+2+2+2+8+2+2

	STD_OUTPUT_HANDLE	equ -11
	STD_INPUT_HANDLE	equ -10
	STD_ERROR_HANDLE	equ -12

	callW	macro	api_func
	IFDEF USE_TASM
	extrn	api_func:proc
	ENDIF
	call	api_func
	endm

	pushb	macro	bytevalue
	db	6Ah,bytevalue
	endm


	fcall	macro	popreg,junxx
	IFDEF DEBUG_T
	ELSE
	call	$+6
	db	junxx
	pop	popreg
	ENDIF
	endm

	ud2_1	macro
		db 0Fh,0Bh		; undocumented opcode to invoke exception,this one UD2
	endm

	ud2_2	macro
		db 0Fh,0B9h		; this is also UD2 but in disasembler it's showed as ???? unknown opcode
	endm

	salc	macro
		db D6h			; set AL on carry flag
	endm

	_sal	macro	byte		; !real! sal eax instruction,undocumented,sal eax,16 is translated
					; by asembler like tasm&masm as shl eax,16
	db	0C1h,0F0h,byte
	endm


	_junk	macro	prefix
	IFDEF DEBUG_T
;		db 4 dup(90h)
	ELSE
		jmp	$+5
;		db	prefix
;		db	NOT prefix+1
		db	0C7h
		db	084h
		db	prefix

	ENDIF
	endm

; 9 bytes macro
	_trash	macro some_byte
	IFDEF DEBUG_T
;		db 10 dup(90h)
	ELSE
		call	$+6		; you must step into(F8) if you want to continue
		db	some_byte	; tracing
		add	esp,4		; fix stack(dont change any! register)
					; add esp,4=3bytes instruction
	
	ENDIF
	endm

	_jmper	macro	shit
	IFDEF DEBUG_T
;		db 7 dup(90h)
	ELSE

		jl	$+5
		jmp	$+5
		db	shit
		jz	$-3
	ENDIF
	endm

	_vxd	macro
	IFDEF DEBUG_T
;		db 5 dup(90h)
	ELSE
		jmp	$+4
		db	0CDh,20h
	ENDIF
	endm

	_mmx	macro	shit
	IFDEF DEBUG_T
;		db 4 dup(90h)
	ELSE
		jmp	$+4
		db	0Fh
		db	shit
	ENDIF
	endm
