;	PeX v0.99
;
;	Known bugs and things to fix up:
;	- no resources compression support
;	- command line handling doeasn't work correctly in WindowsNT
;	- sometimes decompression routine hangs up(small data size to decompress)
;	- compression routine doesn't work in thread
;	- no real antidebugging code,only shit that's compatibile with Win95/98/NT
;
;	bart^CrackPl
;	cryogen@poland.com
;	cryogen@kki.net.pl
	
	.586					; access to all opcodes
	.MMX					; even MMX stuff :)
	.model flat,stdcall

	extern		aP_pack		:near
	_aP_pack	equ aP_pack

	extern		wsprintfA	:proc
	_wsprintfA	equ wsprintfA

	includelib	e:\dev\masm\lib\kernel32.lib
	includelib	e:\dev\masm\lib\user32.lib
	includelib	e:\dev\masm\lib\comdlg32.lib
	includelib	e:\dev\masm\lib\comctl32.lib
	includelib	e:\dev\masm\lib\advapi32.lib
	includelib	aplib.lib		; compression library

	include		e:\dev\masm\include\kernel32.inc
	include		e:\dev\masm\include\user32.inc
	include		e:\dev\masm\include\comdlg32.inc
	include		e:\dev\masm\include\comctl32.inc
	include		e:\dev\masm\include\advapi32.inc
	include		pex_stuff.inc		; PE Header equates,macros...
	include		pex_win.inc

	option		casemap	:none
	assume		fs	:flat

	STRIP_RELOC	equ	00000000000000000000000000000001b
	ALIGN_PE	equ	00000000000000000000000000000010b
	LDR_ALIGN	equ	00000000000000000000000000000100b
	BACKUP		equ	00000000000000000000000000001000b

	IMPORT_PROT	equ	00000000000000010000000000000000b
	BPX_PROT	equ	00000000000000100000000000000000b

	ALL_PARAMS	equ	STRIP_RELOC or ALIGN_PE or LDR_ALIGN or IMPORT_PROT or BPX_PROT or BACKUP

	CONSOLE		equ	10000000000000000000000000000000b


	RSRC		equ	0
	SECTION_FLAGS	equ	0C0000040h	; same flag for all sections

	IDD_DIALOG1	equ	103
	IDD_DIALOG2	equ	104

	IDC_ABOUTEXIT	equ	321
	IDC_TEXTABOUT	equ	301

	IDC_EDIT1	equ	104
	IDC_EXIT	equ	12
	IDC_ABOUT	equ	11
	IDC_COMPRESS	equ	10
	IDC_SELECT	equ	13

	IDC_STATUS1	equ	140
	IDC_PROGRESS	equ	170

	IDI_ICON1	equ	999

	IDC_WIPERELOC	equ	113
	IDC_EXTRAALIGN	equ	114
	IDC_LOADERALIGN	equ	115
.data
;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
	hConsoleOut	dd	?
	hProgress	dd	?
	hCompress	dd	?
	hWindow		dd	?
	hInst		dd	?
	DlgRect 	RECT	<?>
	DlgWidth 	dd	?
	DlgHeight 	dd	?
	DesktopRect 	RECT	<?>
	lpConsoleScreenBufferInfo CONSOLESCREENBUFFERINFO <0>
	lpWritten	dd	?
	hReg		dd	?
	lpdwDisposition	dd	?

	lpOfn			label byte
	ofn_lStructSize		dd	cbOfn	;number of bytes
	ofnhWndOwner		dd	0
	ofnhInstance		dd	0	;dialog box template id
	ofn_lpstrFilter		dd	offset szFilter		;filter strings
	ofn_lpstrCustomFilter	dd	0	;user-defined filter stings
	ofn_nMaxCustFilter	dd	0	;size of custom filter buffer
	ofn_nFilterIndex	dd	0	;index into the filter buffer
	ofn_lpstrFile		dd	offset lpFilename	;default file name buffer
	ofn_nMaxFile		dd	255	;size of the file name buffer
	ofn_lpstrFileTitle	dd	0	;file title buffer
	ofn_nMaxFileTitle	dd	0	;size of the file title buffer
	ofn_lpstrInitialDir	dd	0	;initial directory
	ofn_lpstrTitle		dd	offset szCaption	;dialog box title
	ofn_Flags		dd	4	;dialog box creation flags
	ofn_nFileOffset		dw	0	;file name offset in lpstrFile
	ofn_nFileExtension	dw	0	;file ext offset in lpstrFile
	ofn_lpstrDefExt		dd	0	;default extension
	ofn_lCustData		dd	0	;application-defined hook data
	ofn_lpfnHook		dd	0	;hook function
	ofn_lpTemplateName	dd	0	;dialog box template name
	cbOfn			equ $-lpOfn

	szFilter	db	'Executable files(*.exe)',0,'*.exe',0,'All files(*.*)',0,'*.*',0,0

	szAboutText	db	'PeX v0.99',CR,LF,CR,LF
			db	'Compression library used:',CR,LF
			db	'APLIB 0.26b by Joergen Ibsen',CR,LF,CR,LF
			db	'(c) by bart^CrackPl',CR,LF
			db	'cryogen@poland.com',CR,LF
			db	'cryogen@kki.net.pl',CR,LF
			db	0
;	szMailTo	db	'mailto:cryogen@free.net.pl',0
	szWrong		db	'Internal error occured!',0


	szPeXKey	db	'\Software\PeX',0
	szPeXOptions	db	'Options',0
	szDWORD		dd	4
	szCannotOpen	db	'Cannot open file!',0
	szWrongPE	db	'Wrong PE file!',0
	szErrorPack	db	'Error while compression!',0
	
	szCaption	db	'PeX v0.99 by bart^CrackPl',0
	lCaption	equ	$-szCaption-1

	szException	db	'Internal exception occured!',0
	szSuccess	db	'File compressed.Saved bytes %lu',0
	szAlreadyComp	db	'File already compressed with PeX!',0
	szAllDone	db	'All done...',0

	szCRLF		db	CR,LF


	lpFilename	db	255 dup(?)

	lpExePackData	label	dword
	lpFile		MEMF	<?>
	

	lpPeheader	dd	?
	lpSectionTable	dd	?
	

	lpTotalSize	dd	?
	lpTotalSizePtr	dd	?

	lpOutput	dd	?
	lpOutputPtr	dd	?

	lWorkMem	equ	840*1024
	lpWorkMem	dd	?

	lpOutFile	dd	?
	lpPackedSize	dd	?

	lpNumObj	dd	?
	lpRedirSize	dd	?

	lpLastSection	dd	?
	lpOriginalSize	dd	?
	lExePackData	equ	$-lpExePackData
	lpSafeLoader	dd	?

	lpParam		dd	?

	.code
_start:
	call	GetCommandLineA
	xchg	edi,eax				; eax -> pointer o command line
@search_dot:
	push	edi
	call	lstrlen				; find command line length

	pushad
nextletter:					; convert command line to upper case format
	mov	al,[edi]
	cmp	al,0
	je	alldone
	cmp	al,'a'
	jb	notlowcase
	cmp	al,'z'
	ja	notlowcase
	sub	al,20h				; lowcase 2 upcase
	mov	[edi],al
notlowcase:
	inc	edi
	jmp	nextletter
alldone:
	popad

@search_my_name:
	cmp	dword ptr[edi],'EXE.'
	je	@my_name
	inc	edi
	dec	eax
	jne	@search_my_name
@my_name:
	cmp	byte ptr[edi],' '
	je	@got_exe
	inc	edi
	dec	eax
	jne	@my_name
	jmp	@bad_command_line
@got_exe:
	inc	edi
	push	edi

@search_ext:
	cmp	dword ptr[edi],'EXE.'
	je	@got_exe_ext
	inc	edi
	dec	eax
	jne	@search_ext
	pop	edi
	jmp	@bad_command_line
@got_exe_ext:
	add	edi,4
	sub	eax,4

	pop	esi
	pushad

	mov	ecx,esi
	mov	eax,edi
	sub	eax,ecx
	xchg	eax,ecx
	mov	edi,offset lpFilename		; copy filename
	rep	movsb
	xchg	eax,ecx
	stosb					; make ASCIz
		
	popad
	or	dword ptr[lpParam],ALL_PARAMS AND (NOT BACKUP)

@search_params:
	cmp	word ptr[edi],'R-'		; strip relocation switch
	je	@set_param1
	cmp	word ptr[edi],'R/'
	je	@set_param1
	cmp	word ptr[edi],'A-'		; file align
	je	@set_param2
	cmp	word ptr[edi],'A/'
	je	@set_param2
	cmp	word ptr[edi],'L-'		; loader alignment
	je	@set_param3
	cmp	word ptr[edi],'L/'
	je	@set_param3
	cmp	word ptr[edi],'B-'		; backup
	je	@set_param4
	cmp	word ptr[edi],'B/'
	je	@set_param4
	cmp	word ptr[edi],'I-'		; import_protection
	je	@set_param5
	cmp	word ptr[edi],'I/'
	je	@set_param5
	cmp	word ptr[edi],'X-'		; bpx protection
	je	@set_param6
	cmp	word ptr[edi],'X/'
	je	@set_param6

@search_next_param:
	inc	edi
	dec	eax
	jne	@search_params

	or	dword ptr[lpParam],CONSOLE

	call	AllocConsole			; create new console window
@alredy_got_console:

	push	STD_OUTPUT_HANDLE
	callW	GetStdHandle
	mov	dword ptr[hConsoleOut],eax	; save console handle for write

	push	0
	push	offset lpWritten
	push	lCaption			; string length
	push	offset szCaption		; string
	push	eax				; output handle
	call	WriteConsoleA

	push	offset lpConsoleScreenBufferInfo
	push	dword ptr[hConsoleOut]
	call	GetConsoleScreenBufferInfo

	call	compress_peexe

	push	-1
	call	ExitProcess

@set_param1:
	and	dword ptr[lpParam],NOT STRIP_RELOC
	jmp	@search_next_param
@set_param2:
	and	dword ptr[lpParam],NOT ALIGN_PE
	jmp	@search_next_param
@set_param3:
	and	dword ptr[lpParam],NOT LDR_ALIGN
	jmp	@search_next_param
@set_param4:
	or	dword ptr[lpParam],BACKUP
	jmp	@search_next_param
@set_param5:
	and	dword ptr[lpParam],NOT IMPORT_PROT
	jmp	@search_next_param
@set_param6:
	and	dword ptr[lpParam],NOT BPX_PROT
	jmp	@search_next_param

@bad_command_line:
	sub	eax,eax
	push	offset lpdwDisposition
	push	offset hReg			; offset to handle
	push	eax
	push	1F0003h
	push	eax
	push	eax
	push	eax
	push	offset szPeXKey			; subkey
	push	HKEY_CURRENT_USER		; root key
	call	RegCreateKeyExA			; retrieve settings from registry

@skip_get_registry_settings:

	call	InitCommonControlsEx

	push	0
	call	GetModuleHandleA		; module base
	mov	[hInst],eax			; save it

	sub	edx,edx

	push	edx				; lParam WM_INITDIALOG
	push	offset DlgProc			; dialog proc
	push	edx				; parent handle
	push	IDD_DIALOG1			; ID
	push	eax				; module base
	call	DialogBoxParamA
_exit:
	push	-1
	call	ExitProcess			; exit

PUBLIC DlgProc
DlgProc proc STDCALL uses ebx edi esi, hWnd:DWORD, wmsg:DWORD, _wparam:DWORD, _lparam:DWORD

	movzx	eax,word ptr [wmsg]

	cmp	ax,WM_DESTROY
	je	_wmdestroy
	cmp	ax,WM_CLOSE
	je	_wmdestroy
	cmp	ax,WM_COMMAND
	je	_wmcommand
	cmp	ax,WM_INITDIALOG
	je	_initdlg

	sub	eax,eax
	ret					; message loop, return 0
_wmdestroy:

	jmp	@save_params
	jmp	_exit
@save_params:
	mov	word ptr[_wmdestroy],9090h

	push	113
	pop	ebx
	sub	ecx,ecx
	mov	dword ptr[lpParam],ecx

@get_params_save:
	push	ecx

	push	ebx
	push	hWnd
	call	IsDlgButtonChecked

	pop	ecx

	shl	eax,cl
	or	dword ptr[lpParam],eax
	inc	ecx
	inc	ebx
	cmp	ebx,130
	jbe	@get_params_save

	push	4				; dword value size
	push	offset lpParam			; place to store val from registry
	push	4				; REG_DWORD
	push	0
	push	offset szPeXOptions		; subkey
	push	hReg				; handle
	call	RegSetValueExA

	push	hReg
	call	RegCloseKey			; close handle

@end_dialog:
	push	0				; return 0
	push	hWnd				; dialog handle
	call	EndDialog			; close dialog box
	ret					; jmp _exit

_wmcommand:
	cmp	word ptr[_wparam],IDC_SELECT
	je	_select

	cmp	word ptr[_wparam],IDC_COMPRESS
	je	_compress

	cmp	word ptr[_wparam],IDC_ABOUT
	je	_show_about

	cmp	word ptr[_wparam],IDC_EXIT
	je	_wmdestroy
	
	ret
_select:
	push	hWnd
	pop	ofnhWndOwner

	push	offset lpOfn
	call	GetOpenFileNameA

	push	offset lpFilename
	push	IDC_EDIT1
	push	hWnd
	call	SetDlgItemTextA

	ret

_compress:
	push	0
	pop	dword ptr[lpParam]

	push	255
	push	offset lpFilename
	push	IDC_EDIT1
	push	hWnd
	call	GetDlgItemTextA

	push	113
	pop	ebx
	sub	ecx,ecx
@get_params:
	push	ecx

	push	ebx
	push	hWnd
	call	IsDlgButtonChecked

	pop	ecx

	shl	eax,cl
	or	dword ptr[lpParam],eax
	inc	ebx
	inc	ecx

	cmp	ebx,130
	jbe	@get_params

	push	0
	push	[hCompress]
	call	EnableWindow

	call	compress_peexe
	xchg	eax,ebx

	push	1
	push	[hCompress]
	call	EnableWindow
	
	test	ebx,ebx
	jne	_compression_ok

	push	10h
	push	offset szCaption
	push	offset szWrong
	push	hWnd
	call	MessageBoxA

_compression_ok:
	ret
_initdlg:
	push	hWnd
	pop	dword ptr[hWindow]

	push	IDI_ICON1
	push	hWnd
	call	set_icon

	push	hWnd
	call	center_window

	push	offset szCaption
	push	hWnd
	call	SetWindowTextA

	push	offset szDWORD
	push	offset lpParam
	push	0
	push	0
	push	offset szPeXOptions
	push	hReg
	call	RegQueryValueExA		; get settings from registry

@enable_reg_options:

	mov	edx,[lpParam]

	push	113
	pop	ebx

@enable_options:
	push	edx
	test	dl,1
	je	@skip_enable_option

	push	1
	push	ebx
	push	hWnd
	call	CheckDlgButton
@skip_enable_option:
	pop	edx
	shr	edx,1
	inc	ebx
	cmp	ebx,130
	jbe	@enable_options

	push	IDC_COMPRESS
	push	hWnd
	call	GetDlgItem
	mov	[hCompress],eax

	push	IDC_PROGRESS
	push	hWnd
	call	GetDlgItem
	mov	[hProgress],eax

	ret

_show_about:
	push	0		
	push	offset AboutProc
	push	hWnd
	push	IDD_DIALOG2
	push	hInst
	call	DialogBoxParamA
	ret

DlgProc	endp

status_msg proc near
	test	dword ptr[lpParam],CONSOLE
	je	win_msg

	push	edx
	sub	edx,edx
	call	writeln				; write CRLF
	pop	edx

	call	writeln				; write message

	sub	edx,edx
	call	writeln				; CRLF

	jmp	msg_end
win_msg:
	push	edx				; message text
	push	IDC_STATUS1			; ID
	push	dword ptr[hWindow]		; window handle
	call	SetDlgItemTextA			; set text
msg_end:
	ret					; return from proc


status_msg	endp

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; ABOUT
;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
AboutProc proc STDCALL uses ebx edi esi, hWnd:DWORD, wmsg:DWORD, _wparam:DWORD, _lparam:DWORD

	movzx	eax,word ptr [wmsg]		; wiadomosc do eax

	cmp	ax,WM_DESTROY			; wiadomosc WM_DESTROY
	je	_wmdestroy			; jezeli tak to zniszcz okno
	cmp	ax,WM_CLOSE			; podobnie jezeli WM_CLOSE
	je	_wmdestroy
	cmp	ax,WM_COMMAND			; WM_COMMAND nacisnieto cos
	je	_wmcommand			; obsluz
	cmp	ax,WM_INITDIALOG
	je	_initdlg

	sub	eax,eax
	ret					; message loop, return 0
_wmdestroy:
	push	0				; return 0
	push	hWnd				; uchwyt okan dlg
	call	EndDialog			; koniec dlg
	ret					; powrot

_wmcommand:
	cmp	word ptr[_wparam],IDC_ABOUTEXIT
	je	_wmdestroy

	cmp	word ptr[_wparam],100
	je	_wmdestroy
	ret

_initdlg:
	push	hWnd
	call	center_window

	push	IDI_ICON1
	push	hWnd
	call	set_icon

	push	offset szAboutText
	push	IDC_TEXTABOUT
	push	hWnd
	call	SetDlgItemTextA

	ret
AboutProc endp

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; push	IDC_ICON
; push	hWindow_handle
; call	set_icon
;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
set_icon proc near
	pop	eax
	pop	esi
	pop	edi

	push	eax

	push	edi
	push	hInst
	call	LoadIconA

	push	eax
	push	1
	push	WM_SETICON
	push	esi
	call	SendMessageA
	ret
set_icon endp

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; push	hWindow_handle
; call	center_window
;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
center_window	proc near
	pop	eax
	pop	esi
	push	eax

	push	offset DlgRect
	push	esi
	call	GetWindowRect

	call	GetDesktopWindow

	push	offset DesktopRect
	push	eax
	call	GetWindowRect

	push	0
	mov	eax,DlgRect.rc_bottom
	sub	eax,DlgRect.rc_top
	mov	DlgHeight,eax
	push	eax
	mov	eax,DlgRect.rc_right
	sub	eax,DlgRect.rc_left
	mov	DlgWidth,eax
	push	eax
	mov	eax,DesktopRect.rc_bottom
	sub	eax,DlgHeight
	shr	eax,1
	push	eax
	mov	eax,DesktopRect.rc_right
	sub	eax,DlgWidth
	shr	eax,1
	push	eax
	push	esi
	call	MoveWindow
	ret
center_window	endp

@handler proc near
	mov	esp,12345678
@safe_esp	equ dword ptr $-4

	push	10h
	push	offset szCaption
	push	offset szException
	push	0
	call	MessageBoxA

	push	-1
	call	ExitProcess

@handler endp

SectionAlign:
	mov	edi,[lpPeheader]
        mov     ecx, [edi+objalign]
        jmp	align_fix
FileAlign:
	mov	edi,[lpPeheader]
        mov     ecx, [edi+filealign]
; sets eax on alignment of ecx
align_fix:
	sub	edx,edx
	div	ecx				; /alignment
	test	edx,edx				; if no remainder then no next
	je	no_adjust
	inc	eax				; next alignment                  
no_adjust:
	mul     ecx				; *alignment

	ret


;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; get random byte
; on entry
; nothing
; on exit
; eax(al) pseudo random byte
@get_brandom proc near
	call	@get_random
	movzx	eax,al
	ret
@get_brandom endp

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; get random number
; on entry
; nothing
; on exit
; eax pseudo random number
@get_random	proc near
	push	edx
	push	ecx
@get_again_random:
	call	GetTickCount
	shl	eax,3
	xor	eax,edx
	not	eax
	add	eax,ecx
	add	eax,lpFile.file_size
	shl	eax,2
	add	dword ptr[rnd],eax
	add	eax,dword ptr[rnd]
	rol	eax,cl
	mov	[@rnd_temp],eax			; store valid random

	push	8
	pop	ecx

	test	al,al
	je	@get_again_random

	rol	eax,cl
	test	al,al
	je	@get_again_random

	ror	eax,cl 


	pop	ecx
	pop	edx

	ret
@rnd_temp	dd 0
rnd		dd 0

@get_random	endp

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; call this with szFilename set
; this proc partly coded by Virogen
align_pe proc near

	push	offset lpFilename
	call	open_file

	mov	lpFile.file_handle,eax
	mov	lpFile.file_size,ecx

	push	eax
	push	ecx
	call	map_file

	mov	lpFile.mem_ptr,eax
	mov	lpFile.mem_handle,ecx

	mov	esi,[eax+3Ch]
	add	esi,eax

	mov	eax,[esi+filealign]
	cmp	eax,200h			; already aligned to 200h
	jbe	skip_pealign

was_same:
	movzx	eax, word ptr [esi+NtHeaderSize]; get header size                             
	lea	eax,[eax+esi+18h]
		
	push	eax				; save ptr to obj table
	sub	edx,edx
	push	40
	pop	ecx
	movzx	eax,word ptr[esi+numObj]
	inc	eax
	mul	ecx
	xchg	eax,ebx	
	pop	eax	
	push	eax
	add	eax,ebx
	mov	ecx,[esi+filealign]
	call	align_fix
	xchg	ebx,eax				; ebx->phy. start of first obj
	pop	eax

	mov	ecx,ebx
	sub	ecx,lpFile.mem_ptr
	mov	[esi+headersize],ecx		; save new total size of hdr        

	mov	ecx,200h
	mov	[esi+filealign],ecx
		
	movzx	ecx,word ptr[esi+numObj]	; get number of objects           
	mov	edi,ebx				; edi->phy. start of first obj
						; edi contains pointer to current writing address of the executable	
otbl_loop:		
	push	eax
	push	ecx					
	mov	ecx,edi				; ecx->current obj poff
	sub	ecx,lpFile.mem_ptr		; get real obj poff
	mov	esi,[eax+objpoff]		; esi->original obj p. off
	mov	[eax+objpoff],ecx		; save new physical offset at cur
	mov	ebx,[eax+objvsize]		; get virtual size
	cmp	ebx,[eax+objpsize]		; bigger than physical size?
	jg	skip_align			; if so skip re-aligning this one
	mov	ecx,200h			; ecx=200h
	push	eax				; save obj rec ptr
	xchg	eax,ebx				; eax=object virtual size
	call	align_fix			; align that baby
	xchg	eax,ebx				; ebx=object virtual size
	pop	eax				; restore obj ptr
	jmp	did_align				
skip_align:		
	mov	ebx,[eax+objpsize]		; use psize if vsize>psize
did_align:
	mov	[eax+objpsize],ebx		; save new aligned physical size
	add	esi,lpFile.mem_ptr		; set esi into mapping
	mov	ecx,ebx				; ecx=physical size
	rep	movsb				; store object at new|old location
next_obj:
	pop	ecx
	pop	eax					
	add	eax,40				; onto next object ..whohoo
	loop	otbl_loop	
		
	sub	eax,40				; adjust to last object
	mov	ecx,[eax+objpsize]		; ecx=last object physical size
	add	ecx,[eax+objpoff]		; ecx=total physical size of file
	push	ecx				; save it for set_end proc

	push	lpFile.mem_ptr
	push	lpFile.mem_handle
	call	unmap

	call	set_end

	ret
skip_pealign:
	push	lpFile.mem_ptr
	push	lpFile.mem_handle
	call	unmap

	push	lpFile.file_handle
	call	CloseHandle

	ret

align_pe endp

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; on entry
; edi RVA
; on exit
; edi RVA converted to offset in file
@rva2offset	proc near
	pushad

	mov	edx,[lpSectionTable]
	mov	esi,[lpPeheader]
	movzx	ecx,word ptr[esi+numObj]
@check_section:
	cmp	edi,[edx+objrva]
	jb	@next_section

	mov	eax,[edx+objrva]
	add	eax,[edx+objvsize]

	cmp	edi,eax
	jae	@next_section

	sub	edi,[edx+objrva]
	add	edi,[edx+objpoff]
	add	edi,lpFile.mem_ptr

	jmp	@rva2offset_exit

@next_section:
	dec	ecx
	add	edx,28h
	test	ecx,ecx
	jne	@check_section

@rva2offset_exit:
	mov	dword ptr[esp+_edi],edi

	popad
	ret
@rva2offset	endp

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; on entry
; edi section table+section
; on exit
; ZF=0 means bad object
@IsBadObject	proc near
	
	pushad
	mov	eax,offset bad_otbl
@check_object:
	mov	edx,[eax]
	not	edx
	cmp	dword ptr[esi],edx
	je	@bad_object

	add	eax,4
	cmp	dword ptr[eax],0
	jne	@check_object

	popad
	sub	eax,eax
	inc	eax				; reset ZF
	ret

@bad_object:
	popad
	sub	eax,eax				; set ZF
	ret

bad_otbl:
	dd NOT 'ler.'				; relo
	dd NOT 'ade.'				; edata
	dd NOT 'ete.'				; etext
;	dd NOT 'adr.'				; rdata
	dd NOT 'slt.'				; tls
	dd NOT 'oci.'				; icon
;	dd NOT 'adi.'				; idata
	dd NOT 'rsr.'				; rsrc

	dd 0
@IsBadObject	endp

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; on entry
; edi section table+section
; on exit
; ZF is set if object cannot be encrypted
@IsEncryptable	proc near
	pushad
	mov	edi,dword ptr[lpPeheader]

	cmp	dword ptr[esi+objpoff],0	; offset=0, hmm strange
	je	@dont_encrypt			; skip encryption

	cmp	dword ptr[esi+objpsize],0	; section size 0
	je	@dont_encrypt			; skip encryption

	mov	eax,[esi+objrva]		; RVAs

;IFDEF RSRC
;@check_rsrc:
	cmp	eax,[edi+resource]		; resource?
	je	@dont_encrypt			; if equal skip it
;ENDIF

@check_reloc:
	cmp	eax,[edi+reloc]			; relocations?
	je	@dont_encrypt			; if equal skip encryption, no dll suppor(this time)

@check_tls:
	cmp	eax,[edi+tls]			; ThreadLocalStorage?
	je	@dont_encrypt			; if equal skip encryption

@object_encryptable:
	popad					; restore regs
	sub	eax,eax
	inc	eax				; clear zero flag
	ret					; return

@dont_encrypt:
	popad					; restore regs
	sub	eax,eax				; set zero flag
	ret					; return
@IsEncryptable	endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; push	lpFilename
; call	create_file
; returned values
; eax file handle
; eax -1 error
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
create_file proc near
	pop	eax
	pop	edx
	push	eax

	sub	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	CREATE_NEW
	push	eax
	push	eax
	push	GENERIC_READ + GENERIC_WRITE
	push	edx
	call	CreateFileA
	ret

create_file endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; push	lpFilename
; call	open_file
; returned values
; eax file handle
; ecx filesize
; eax -1 error
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
open_file proc near
	pop	eax
	pop	edx
	push	eax

	push	edx

	push	FILE_ATTRIBUTE_ARCHIVE		; attribs
	push	edx				; pointer to filename
	call	SetFileAttributesA		; clear attributes
	
	pop	edx				; pop filename

	sub	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_NORMAL
	push	OPEN_EXISTING			; action
	push	eax
	push	eax
	push	GENERIC_READ + GENERIC_WRITE	; access type
	push	edx				; pointer to filename
	call	CreateFileA
	
	cmp	eax,-1
	je	open_err

	push	eax

	push	0
	push	eax				; file handle
	call	GetFileSize

	pop	ecx
	xchg	eax,ecx

open_err:
	ret
open_file endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; push	hFile
; push	cbSize
; call	map_file
; returned values
; eax pointer to mapped file
; ecx mapped file handle
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
map_file proc near

	pop	eax				; return value
	pop	ecx				; size
	pop	edx				; file handle

	push	eax

	sub	eax,eax
	push	eax
	push	ecx				; low size+vs  
	push	eax				; high size   
	push	PAGE_READWRITE			; read&write  
	push	eax				       
	push	edx				; file handle
	call	CreateFileMappingA

	push	eax

	sub	edx,edx

	push	edx				; # of bytes, 0= map entire file
	push	edx				; file offset low
	push	edx				; file offset high             
	push	FILE_MAP_WRITE			; access flags - read&write       
	push	eax
	call	MapViewOfFile

	pop	ecx
	ret
map_file endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; push	lpPointer_to_mapped_file
; push	hMapped_file
; call	unmap
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

unmap	proc near
	pop	eax				; return address

	pop	ecx				; hMapped_file_handle
	pop	edx				; lpPointer_to_mapped_area

	push	eax

	push	ecx
	push	edx

	call	UnmapViewOfFile
	call	CloseHandle

	ret
unmap	endp

;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; on entry
; ecx - size of memory to allocate
; on exit
; eax - pointer to new allocated memory
valloc proc near
	push	ecx				; save used regs
	push	edx

	push	PAGE_READWRITE			; access type
	push	MEM_RESERVE or MEM_COMMIT	; flags
	push	ecx				; size
	push	0
	call	VirtualAlloc

	pop	edx
	pop	ecx
	ret
valloc endp
;лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; on entry
; ecx - size of memory to deallocate
; eax - pointer to memory
vfree proc near
	push	MEM_DECOMMIT
	push	ecx				; memory size
	push	eax				; memory pointer
	call	VirtualFree
	ret
vfree endp

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; push	lFileSize
; call	set_end
set_end proc near
	pop	eax				; pop return address
	pop	ecx				; pop param(file size)
	push	eax				; save ret address

	sub	eax,eax
	push	eax				; FILE_BEGIN from file begin                
	push	eax				; distance high                  
	push	ecx				; distance low                   
	push	lpFile.file_handle
	call	SetFilePointer			; move file pointer to       
						; real EOF                           
	push	lpFile.file_handle
	call	SetEndOfFile			; set end of file

	push	lpFile.file_handle		; file handle
	call	CloseHandle			; close lpFile handle

	ret
set_end	endp

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; edi pointer to buffer
; ecx buffer size
@rnd_fill proc near
	push	ecx
	call	@get_brandom
	cmp	al,9
	jbe	@fill_number

	and	al,0Fh
	add	al,41h
	jmp	@fill_byte
@fill_number:
	add	al,30h
@fill_byte:
	stosb

	pop	ecx
	loop	@rnd_fill
	ret
@rnd_fill endp


;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; on entry
; esi peheader
; edi section table
@wipe_reloc proc near
	pushad

	mov	esi,[lpPeheader]
	mov	edi,[lpSectionTable]

	movzx	ecx,word ptr[esi+numObj]	; section count
scan_objs:
	cmp	dword ptr[edi],'ler.'		; .reloc
	je	found_reloc
	cmp	dword ptr[edi],'oler'		; relocs (ALINK)
	je	found_reloc

	add	edi,objlen			; next section
	loop	scan_objs
	jmp	no_reloc
found_reloc:
	dec	ecx
	jne	reloc_not_last			; only set flag

	dec	word ptr [esi+numObj]		; decrement secion count on PEheader
	pushad
	sub	eax,eax
	push	objlen
	pop	ecx
	rep	stosb				; erase reloc section
	popad
reloc_not_last:
	sub	eax,eax
	mov	dword ptr [edi+objpsize],eax
	mov	dword ptr [esi+reloc],eax
	mov	dword ptr [esi+relocsize],eax			
	or	word ptr[esi+DllFlags],1	; set "relocations stripped"
	popad

	sub	eax,eax
	inc	eax				; reset ZF
	ret
no_reloc:
	popad
	sub	eax,eax				; set ZF
	ret
@wipe_reloc	endp

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; eax file start
; on exit
; esi pointer to pe header
get_peheader	proc near
	push	eax
	push	ecx

	mov	esi,[eax+3Ch]
	add	esi,eax
	mov	[lpPeheader],esi

	pop	ecx
	pop	eax
	ret
get_peheader	endp


sections_total_size	proc near
	pushad
	mov	esi,[lpPeheader]
	movzx	ecx,word ptr[esi+numObj]
	mov	esi,[lpSectionTable]
	sub	eax,eax
@calc_section_raw_size:
	add	eax,[esi+objpsize]
	add	esi,objlen
	loop	@calc_section_raw_size

	mov	[esp+_eax],eax
	popad
	ret
sections_total_size	endp


; push	iSection
; push	offset lpSectionStruc
; call	get_section_info
read_section	proc near
	pop	eax
	pop	edi
	pop	ebx
	push	eax

	mov	esi,dword ptr[lpSectionTable]
	dec	ebx
	imul	eax,ebx,objlen
	add	esi,eax

	push	objlen
	pop	ecx
	rep	movsb

	ret
read_section	endp




;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; push	lDataSize
; push	lpData
; call	add_section
; on exit:
; esi PE header
; edi current offset in mapped file
add_loader_section	proc near
	mov	esi,[lpSectionTable]
	mov	ecx,[lpNumObj]
	imul	eax,ecx,objlen
	add	esi,eax

	mov	edi,esi
	sub	eax,eax
	push	objlen
	pop	ecx
	rep	stosb

	mov	eax,@loader_len
	mov	edx,dword ptr[lpPackedSize]	; space for redirected api addresses
	mov	ecx,dword ptr[lpRedirSize]
	cmp	edx,ecx
	jae	@no_need_ext

	sub	ecx,edx
	add	edx,ecx
@no_need_ext:
	add	eax,edx
	call	SectionAlign
	mov	dword ptr[esi+objvsize],eax

	mov	eax,@loader_len
	add	eax,dword ptr[lpPackedSize]	; space for redirected api addresses
	call	FileAlign

	mov	dword ptr[esi+objpsize],eax

	mov	eax,[esi-objlen+objvsize]
	call	SectionAlign

	add	eax,[esi-objlen+objrva]
	mov	dword ptr[esi+objrva],eax

	mov	edx,[lpPeheader]
	mov	dword ptr[edx+entrypointRVA],eax

	push	edx

	mov	eax,dword ptr[esi+objrva]
	add	eax,dword ptr[esi+objvsize]	; last obj vsize+rva = imagesize
	call	SectionAlign

	pop	edx
	mov	[edx+imagesize],eax

	mov	eax,[esi-objlen+objpsize]
	test	eax,eax
	je	no_align

	call	FileAlign
no_align:
	mov	ebx,[lpLastSection]
	test	ebx,ebx
	je	scan_section_table

	mov	edx,[ebx+objpoff]
	test	edx,edx
	jne	got_last_offset
scan_section_table:
	mov	ebx,[lpNumObj]
	mov	edi,[lpSectionTable]
find_last_section_offset:
	cmp	byte ptr[edi+objlinenum],1
	je	fuck_this_section

	mov	edx,[edi+objpoff]
	test	edx,edx
	je	fuck_this_section

fuck_this_section:
	add	edi,objlen
	dec	ebx
	jne	find_last_section_offset

	test	edx,edx
	jne	got_last_offset

	mov	edx,[lpPeheader]
	mov	edx,[edx+headersize]
	sub	eax,eax
got_last_offset:
	add	eax,edx
	mov	dword ptr[esi+objpoff],eax
	
	mov	dword ptr[esi+objflags],SECTION_FLAGS

	mov	edi,[esi+objpoff]
	add	edi,lpFile.mem_ptr
	mov	esi,[esp+4]
	mov	ecx,[esp+8]
	rep	movsb

	mov	esi,[lpPeheader]
	inc	word ptr[esi+numObj]		; increment total section count

	ret	8

add_loader_section	endp

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; store old import RVA & import table size
; update new import infos,update loader import table RVAs
update_import_infos	proc near
	pushad

	mov	esi,[lpSectionTable]
	mov	ecx,[lpNumObj]
	dec	ecx
	imul	eax,ecx,objlen
	add	esi,eax

	mov	eax,[esi+objvsize]
	call	SectionAlign
	add	eax,[esi+objrva]
	xchg	eax,ebx
	
	mov	eax,[lpPeheader]

	push	dword ptr[eax+import]
	pop	dword ptr[@old_import]

						_vxd	; in the appended code
	add	ebx,ImportTable-@loader_start	; Calculate RVA of Importable
	mov	dword ptr[eax+import],ebx	; update header -> import my imports
	mov	dword ptr[eax+importsize], @it_end-ImportTable

	mov	esi,offset lpImportTablePatch
	push	(lImportTablePatch/4)
	pop	ecx
@update_import_table:
	lodsd
	add	dword ptr[eax],ebx
	loop	@update_import_table

	popad
	ret

lpImportTablePatch:
	dd	offset	IMAGE_IMPORT_DESCRIPTOR1
	dd	offset	IMAGE_IMPORT_DESCRIPTOR1+12
	dd	offset	IMAGE_IMPORT_DESCRIPTOR1+16

	dd	offset	IMAGE_IMPORT_DESCRIPTOR2
	dd	offset	IMAGE_IMPORT_DESCRIPTOR2+12
	dd	offset	IMAGE_IMPORT_DESCRIPTOR2+16

;	dd	offset	Dll1_RVA1
;	dd	offset	Dll1_RVA2
;	dd	offset	Dll1_RVA3
;	dd	offset	Dll1_RVA4
;	dd	offset	Dll1_RVA5

;	dd	offset	Dll2_RVA1

	dd	offset	Dll1_Pointer1
	dd	offset	Dll1_Pointer2
	dd	offset	Dll1_Pointer3
	dd	offset	Dll1_Pointer4
	dd	offset	Dll1_Pointer5

	dd	offset	Dll2_Pointer1
lImportTablePatch	equ $-lpImportTablePatch
update_import_infos	endp


;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; on entry
; esi pointer to import table
; on exit
; ecx no of all imported api functions
@scan_import_table proc near

	sub	ecx,ecx
@scan_image_import_descriptor:
	mov	edx,[esi]			; 1st table
	test	edx,edx
	jne	@1table
	mov	edx,[esi+16]			; original 1st thunk
	test	edx,edx
	je	@end_descriptor
@1table:
	mov	edi,edx
	call	@rva2offset
	mov	edx,edi
@hint_scan:
	mov	edi,[edx]

	not	dword ptr[edx]			; crypt rva

	test	edi,edi
	je	@end_hint

	test	edi,80000000h			; check if func is imported by ordinal
	jne	@import_by_ord

	call	@rva2offset

	pushad
	mov	[esp+_edi],edi			; save pointer to moved apiname
	lea	esi,[edi+2]			; esi pointer to api name
	push	esi
	call	lstrlen				; length of api name
	xchg	eax,ecx
	rep	movsb				; move 2 bytes up api name string
	sub	eax,eax
	stosw					; reminder

	popad

	mov	ebx,dword ptr[@apiname_key]
@crypt_apiname:
	movzx	eax,byte ptr[edi]
	test	eax,eax
	sete	ah
@enc_apiname label byte
	add	al,bl
	sub	al,bh
	xor	al,bl
@enc_apinamelen	equ $-@enc_apiname-2

	db	0C1h,0C3h			; rol	ebx,byte
	db	0
@apiname_crypt_rolkey	equ byte ptr $-1
	mov	byte ptr[edi],al
	cmp	ah,1
	je	@apiname_end

	inc	edi
	jmp	@crypt_apiname

@apiname_end:


@import_by_ord:
	inc	ecx
	add	edx,4
	jmp	@hint_scan
@end_hint:
	add	esi,20
	jmp	@scan_image_import_descriptor
@end_descriptor:

	ret
@scan_import_table endp

merge_compressable_sections	proc near
	call	@IsBadObject
	je	@skip_addition

	call	@IsEncryptable
	je	@skip_addition

	push	esi

	sub	eax,eax

	mov	ecx,[esi+objpsize]
	mov	dword ptr[esi],ecx		; save original raw size
	mov	byte ptr[esi+objlinenum],al	; compression marker
	mov	dword ptr[esi+objpsize],eax	; set 0 raw size
	mov	esi,[esi+objpoff]
	add	esi,lpFile.mem_ptr
	mov	edx,[esp]
	mov	dword ptr[edx+objpoff],eax	; set 0 raw offset
	rep	movsb

	pop	esi

	jmp	@section_added
@skip_addition:
	sub	eax,eax
	inc	eax

	mov	byte ptr[esi+objlinenum],al	; set section_not_compressed marker

	dec	eax

	mov	dword ptr[esi],eax		; 1st DWORD of name
@section_added:
	mov	dword ptr[esi+4],eax		; 2nd DWORD of name
	mov	dword ptr[esi+objflags],SECTION_FLAGS	; set new section attribs

	add	esi,objlen
	dec	ebx
	jne	merge_compressable_sections

	ret

merge_compressable_sections endp
;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
; M A I N  C O M P R E S S I O N  P R O C E D U R E
;
;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
compress_peexe	proc near
	pushad

	sub	eax,eax
	mov	edi,offset lpPeheader
	mov	ecx,lpSafeLoader-lpPeheader
	rep	stosb

	push	offset compress_pe_handler	; save handler offset
	push	dword ptr fs:[eax]		; save previous SEH frame
	mov	fs:[eax],esp			; establish SEH frame

	call	mutate				; mutate encryptors

	mov	ecx,@total_loader_size
	call	valloc
	mov	dword ptr[lpSafeLoader],eax	; copy unchanged(exept mutated decryptor body)
	xchg	eax,edi				; loader code
	mov	esi,offset @loader_start	; to new allocated memory
	mov	ecx,@total_loader_size		; after compression
	rep	movsb				; restore original loader code

	test	dword ptr[lpParam],BPX_PROT
	jne	@leave_bpx_prot_active
	mov	byte ptr[@check_bpx],0C3h	; put ret opcode on entry of @check_bpx proc
@leave_bpx_prot_active:

	test	dword ptr[lpParam],IMPORT_PROT
	jne	@leave_import_prot_active

	push	offset @store			; source
	push	offset @normal_api_store	; destiantion
	call	put_jmp

@leave_import_prot_active:

	call	@get_random			; create encryption keys
	mov	dword ptr[@apiname_key],eax
	call	@get_random
	mov	byte ptr[@apiname_crypt_rolkey],al
	mov	byte ptr[@apiname_decrypt_rolkey],al
	call	@get_random
	mov	dword ptr[@decryption_key_1],eax

	test	dword ptr[lpParam],BACKUP
	je	@no_backup

	push	offset lpFilename		; find file name length
	call	lstrlen
	xchg	eax,ecx
	push	ecx
	call	valloc				; allocate memory page

	xchg	eax,edi				; edi --> memory
	
	mov	esi,offset lpFilename		; original file name
	pop	ecx				; pop size
	push	ecx				; save size
	push	edi				; save pointer to memory

	push	0				; fail if exist
	push	edi				; new file name
	push	esi				; file name

	push	edi				; pointer to backup file name ptr
	rep	movsb				; copy original file name
	mov	eax,'KAB.'			; add .BAK suffix
	stosd					; store it
	call	DeleteFileA			; delete backup file if exists

	call	CopyFileA			; make backup

	pop	eax				; pop memory ptr
	pop	ecx				; pop memory size
	call	vfree				; free memory


@no_backup:
	push	offset lpFilename		; pointer to filename
	call	open_file			; open file
	inc	eax				; eax=0?
	je	@error_open			; error
@open_file_ok:
	dec	eax				; original value
	mov	lpFile.file_handle,eax		; save file handle
	mov	lpFile.file_size,ecx		; sae file size
	mov	dword ptr[lpOriginalSize],ecx

	push	eax				; file handle
	push	ecx				; file size(+extra size for decryptor body)
	call	map_file			; map file

	mov	lpFile.mem_ptr,eax		; save mem pointer
	mov	lpFile.mem_handle,ecx		; save handle

	call	get_peheader			; eax file ptr,esi pointer to pe header

	test	dword ptr[esi+0F4h],00000008h	; check PeX marker
	jne	@error_already_compressed

	cmp	dword ptr[esi],000004550h	; PE exe?
	jne	@wrong_pe_exe
						_vxd
	cmp	dword ptr[esi+entrypointRVA],0	; no entrypoint?
	je	@wrong_pe_exe
						_trash	0E9h
	cmp	word ptr[esi+cputype],014Ch	; i386
	jne	@wrong_pe_exe
						_vxd
	test	word ptr[esi+DllFlags],2000h	; DLL?
	je	@pe_exe_ok
@wrong_pe_exe:
	mov	edx,offset szWrongPE		; show error
	jmp	@error
@pe_exe_ok:

	movzx	eax,word ptr[esi+NtHeaderSize]
	lea	eax,[esi+eax+18h]		; calculate object table offset
	mov	dword ptr[lpSectionTable],eax

	sub	eax,lpFile.mem_ptr
	add	eax,[esi+imagebase]
	mov	dword ptr[@section_table],eax	; save VA of section table

	test	dword ptr[lpParam],STRIP_RELOC	; wipe reloc option enabled?
	je	@skip_wipe_reloc
	call	@wipe_reloc			; wipe relocation section
@skip_wipe_reloc:
	movzx	ecx,word ptr[esi+numObj]	; get n0 of sections
	mov	dword ptr[lpNumObj],ecx
	mov	dword ptr[@section_count],ecx	; save it 2 times

	mov	eax,[esi+imagebase]		; get image base
	mov	dword ptr[@image_base],eax	; save it

	add	eax,[esi+entrypointRVA]
	dec	eax
	mov	dword ptr[@entrypoint],eax	; save entrypoint VA

	or	dword ptr[esi+0F4h],00000008h	; set PeX marker

	sub	eax,eax
						_trash 0E9h
	mov	word ptr[esi+lmajor],ax		; clear linker field
	mov	dword ptr[esi+timestamp],eax	; reset timestamp
	mov	dword ptr[esi+loaderflags],eax	; clear loader flags
	mov	dword ptr[esi+debug],eax	; never used
	mov	dword ptr[esi+debugsize],eax	; as above
	mov	dword ptr[esi+checksum],eax

	mov	eax,esi
	sub	eax,lpFile.mem_ptr
	add	eax,dword ptr[esi+imagebase]
;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; import table eXtra encryption,rebuild little imports...
	mov	edi,[esi+import]		; import table RVA
	test	edi,edi				; import table exists?
	je	@skip_import_encyrption		; skip it

	call	@rva2offset			; edi RVA --> edi ptr in mapped file
	xchg	edi,esi

	call	@scan_import_table		; encrypt api names
	lea	eax,[eax*8+eax]			; eax api functions count
	mov	dword ptr[lpRedirSize],eax
	mov	dword ptr[@max_redir_size],eax
@skip_import_encyrption:
	call	update_import_infos		; correct loader's import table RVAs

	call	sections_total_size		; get total sections size(raw)

	add	eax,@symbiont_length

	mov	dword ptr[lpTotalSize],eax
	mov	dword ptr[@uncompressed],eax

	xchg	eax,ecx
	call	valloc				; allocate memory
	mov	dword ptr[lpTotalSizePtr],eax
	xchg	eax,edi

	mov	esi,offset @symbiont_start
	mov	ecx,@symbiont_length		; copy symbiont code
	rep	movsb				; to new allocated memory

	mov	ebx,dword ptr[lpNumObj]		; ebx no of sections,edi pointer to memory
	mov	esi,dword ptr[lpSectionTable]	; esi points to section table
	call	merge_compressable_sections	; copy all compressable sections into one stream

	mov	ecx,lWorkMem
	call	valloc
	mov	dword ptr[lpWorkMem],eax

	mov	ecx,dword ptr[lpTotalSize]
	push	9				; allocate ((length * 9) / 8) + 16) bytes
	pop	eax
	cdq
	mul	ecx				; to be sure that
	shr	eax, 3				; even an uncompressible data can be
	add	eax, 16				; compressed without problems(aplib.doc)
	xchg	eax,ecx				; ecx size of memory to allocate
	mov	dword ptr[lpOutput],ecx
	call	valloc
	mov	dword ptr[lpOutputPtr],eax


	test	dword ptr[lpParam],CONSOLE
	je	@win_callback
	push	offset DosCompressCallback
	jmp	@dos_callback

@win_callback:
	push	offset CompressCallback		; callback proc ptr
@dos_callback:
	push	dword ptr[lpWorkMem]		; 1mb of workmem
	push	dword ptr[lpTotalSize]		; length
	push	eax				; destination
	push	dword ptr[lpTotalSizePtr]	; source
	call	_aP_pack			; compress(cdecl)

	test	eax,eax				; error?
	je	@error_pack

	cmp	eax,[esp+8]			; check ratio
	ja	@error_pack

	mov	dword ptr[lpPackedSize],eax
	mov	dword ptr[@compressed_size],eax

	pop	edi				; pop source
	pop	edi				; compressed buffer
	add	esp,4*3				; fix stack

;	mov	edi,[lpOutputPtr]		; edi ptr to data
	xchg	eax,ecx				; ecx data size
	call	encrypt_data			; encrypt

	mov	ecx,lpFile.file_size		; size
	call	valloc
	mov	dword ptr[lpOutFile],eax

	mov	esi,dword ptr[lpPeheader]
	mov	ecx,dword ptr[esi+headersize]
	add	eax,ecx
	xchg	eax,edi

	mov	ebx,dword ptr[lpNumObj]
	mov	esi,dword ptr[lpSectionTable]
@copy_pe:
	push	esi

	cmp	byte ptr[esi+objlinenum],0	; check if section is compressed
	je	@skip_copy_section		;

	mov	dword ptr[lpLastSection],esi

	mov	ecx,dword ptr[esi+objpsize]	; object size
	mov	edx,dword ptr[esi+objpoff]
	add	edx,dword ptr[lpFile.mem_ptr]	; object offset(into mapped file)

	push	edi
	sub	edi,dword ptr[lpOutFile]
	mov	dword ptr[esi+objpoff],edi	; update raw offset
	pop	edi

	mov	esi,edx

	rep	movsb
	
@skip_copy_section:
	pop	esi

	add	esi,objlen
	dec	ebx
	jne	@copy_pe

	mov	esi,[lpPeheader]
	mov	ecx,[esi+headersize]
	mov	edi,[lpOutFile]
	mov	esi,lpFile.mem_ptr
	rep	movsb				; copy headers(MZ,PE,SectionTable)

	mov	edi,lpFile.mem_ptr
	mov	esi,[lpOutFile]
	mov	ecx,lpFile.file_size
	rep	movsb

	push	@loader_len			; new data section length
	push	offset @loader_start		; data to copy
	call	add_loader_section		; add decompressor section

	mov	esi,[lpOutputPtr]
	mov	ecx,[lpPackedSize]
	rep	movsb				; copy compressed buffer

	test	dword ptr[lpParam],LDR_ALIGN
	je	@skip_loader_alignment

	mov	esi,[lpSectionTable]
	mov	edi,[lpPeheader]
	movzx	ecx,word ptr[edi+numObj]
	dec	ecx
	imul	eax,ecx,objlen
	add	esi,eax

	mov	edi,[esi+objpoff]		; file size = last section offset
	add	edi,[esi+objpsize]		; +last section virtual size
	jmp	@offset_aligned
@skip_loader_alignment:
	sub	edi,lpFile.mem_ptr		; edi file size
@offset_aligned:
	push	lpFile.mem_ptr
	push	lpFile.mem_handle
	call	unmap

	push	edi
	call	set_end				; set new file size

	test	dword ptr[lpParam],ALIGN_PE	; eXtra file align option enabled?
	je	@skip_extra_align

	call	align_pe			; set new alignment(200h)
@skip_extra_align:
	
	push	offset lpFilename
	call	open_file
	push	eax

	mov	eax,[lpOriginalSize]
	cmp	eax,ecx
	jbe	@no_ratio

	sub	eax,ecx
	
	push	eax
	push	offset szSuccess
	push	[lpWorkMem]
	call	_wsprintfA
	pop	edx
	add	esp,4*2


	jmp	@show_success
@no_ratio:
	mov	edx,offset szAllDone

@show_success:
	call	status_msg

	call	CloseHandle

	mov	ecx,@total_loader_size
	mov	esi,[lpSafeLoader]
	mov	edi,offset @loader_start
	rep	movsb				; restore copy loader code

	push	ecx
	push	ecx
	push	1026				; PBM_SETPOS
	push	hProgress
	call	SendMessageA			; reset progress bar position

	jmp	@close
@error_already_compressed:
	mov	edx,offset szAlreadyComp
	jmp	@error

@error_open:
	mov	edx,offset szCannotOpen
	jmp	@error

@error_pack:
	add	esp,4*5				; fix stack
	mov	edx,offset szErrorPack
@error:
	call	status_msg

	mov	dword ptr[esp+_eax],0
@close:
;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; free all memory buffers,close mapped file(s),close file(s)

	mov	ecx,@total_loader_size
	mov	eax,[lpSafeLoader]
	call	vfree

	mov	ecx,lpFile.file_size
	mov	eax,lpOutFile
	call	vfree

	mov	ecx,[lpOutput]
	mov	eax,[lpOutputPtr]
	call	vfree

	mov	ecx,lWorkMem
	mov	eax,[lpWorkMem]
	call	vfree

	mov	ecx,[lpTotalSize]
	mov	eax,[lpTotalSizePtr]
	call	vfree

	push	lpFile.mem_ptr
	push	lpFile.mem_handle
	call	unmap

	push	lpFile.file_handle
	call	CloseHandle

	sub	eax,eax
	mov	[lpParam],eax
	pop	dword ptr fs:[eax]		; remove SEH handler
	pop	edx
	inc	eax
	mov	[esp+_eax],eax
	popad
	ret

compress_pe_handler:
	sub	edx,edx
	mov	eax,dword ptr fs:[edx]
	mov	esp,[eax]
	pop	dword ptr fs:[edx]
	pop	eax

	mov	[lpParam],edx
	mov	[esp+_eax],edx			; exit with error value
	popad
	ret

compress_peexe	endp

encrypt_data	proc near
	mov	edx,[@decryption_key_1]
@encrypt_extra_data:
	mov	al,byte ptr[edi]
@encrypt_extra_engine label byte
	ror	al,cl
	add	al,dh
	add	al,dl
	not	al
	add	al,ch
	add	al,cl
	rol	al,cl
	sub	al,dh
	sub	al,dl
	sub	al,ch
	sub	al,cl
	ror	al,cl
	xor	al,dh
	xor	al,dl
	not	al
	xor	al,ch
	xor	al,cl
	rol	al,cl
@encrypt_extra_engine_size	equ $-@encrypt_extra_engine-2
	rol	edx,cl

	mov	byte ptr[edi],al
	inc	edi
	dec	ecx
	jne	@encrypt_extra_data

	ret
encrypt_data	endp


mutate	proc near
	pushad
@get_valid_random:
						_junk 0E9h
	call	@get_brandom			; get random 32bit number
						_trash 0E8h
	test	eax,eax
	je	@get_valid_random		; 0?
@times:
						_junk 0E8h
	push	eax				; save random byte

	push	offset @encrypt_extra_engine
						_junk 8Dh
	push	offset @decrypt_extra_engine
						_junk 0E9h
	push	@encrypt_extra_engine_size
						_junk 8Bh
	call	swap_bytes
						_junk 0EBh
						_vxd
	pop	eax
						_junk 0E9h
						_junk 0E8h
	dec	eax
						_junk 0E9h
	jne	@times
						_junk 09Ah

	popad

	ret
mutate endp

swap_bytes proc cbSize:DWORD,lpDecrypt:DWORD,lpEncrypt:DWORD
						_junk 0E9h
	mov	eax,lpEncrypt
						_junk 0E8h
	mov	ecx,cbSize
						_junk 08Bh
	call	morph				; morph encryptor code
						_junk 0E9h

	mov	eax,cbSize
						_junk 09Ah
	push	2
	pop	ecx

	cdq
						_junk 09h
	div	ecx
						_junk 0E9h
	xchg	eax,edi
unmorph:
						_junk 0E8h
	mov	eax,lpDecrypt
						_vxd
	mov	ecx,cbSize
						_junk 069h
	call	morph
						_junk 69h
	dec	edi
						_junk 0E9h
	jne	unmorph
						_junk 0E8h
	ret
swap_bytes endp

morph proc near
						_junk 0E9h
	mov	dx,word ptr[eax+ecx]
						_junk 0E8h
	mov	bx,word ptr[eax+ecx-2]
						_vxd
	mov	word ptr[eax+ecx],bx
						_junk 9Ah
	mov	word ptr[eax+ecx-2],dx
						_junk 0E9h
	dec	ecx
						_junk 8Bh
	loopnz	morph
						_junk 0E9h
	ret
morph endp

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; push	offset lpSource
; push	offset lpDestination
; call	put_jmp
put_jmp	proc near
	pop	ecx				; ret addr
	pop	edx				; destiantion
	pop	eax				; source
	push	ecx
	
	mov	byte ptr[eax],0E9h		; jmp opcode
	sub	edx,eax
	sub	edx,5
	mov	dword ptr[eax+1],edx

	ret
put_jmp	endp



CompressCallback proc near
	mov	eax,[esp+4]
	imul	eax,eax,100
	
	sub	edx,edx
	mov	ecx,[lpTotalSize]
	jecxz	no_update_status
	div	ecx
	push	0
	push	eax				; position
	push	1026				; PBM_SETPOS
	push	hProgress			; handle of control
	call	SendMessageA			; set progress bar position
no_update_status:	
	sub	eax,eax				; ret with eax==1
	inc	eax
	ret
CompressCallback endp

DosCompressCallback proc near
; lpInputBytes	equ [esp+8]
; lpOutputBytes	equ [esp+4]
	pushad

	mov	eax,[esp+4+(8*4)]
	imul	eax,eax,50
	
	sub	edx,edx
	mov	ecx,[lpTotalSize]
	jecxz	@no_update_status
	div	ecx
	xchg	eax,ecx
	jecxz	@callback_ret

	push	offset lpWritten
	push	dword ptr[lpConsoleScreenBufferInfo.c_X]
	push	ecx
	push	'.'
	push	[hConsoleOut]
	call	FillConsoleOutputCharacter

@callback_ret:
	popad
@no_update_status:
	sub	eax,eax				; return 1
	inc	eax
	ret
lpDot	db	'.',0

	


DosCompressCallback endp

comment #
CompressCallback proc near
; lpInputBytes	equ [esp+8]
; lpOutputBytes	equ [esp+4]
	pushad

	mov	edx,offset lpChar
	movzx	ecx,byte ptr[lpCharCount]
	cmp	cl,4
	jb	@next_char

	mov	byte ptr[lpCharCount],0
	sub	ecx,ecx
@next_char:
	sub	eax,eax
	lea	ecx,[ecx*2+eax]
	add	edx,ecx
	call	status_msg

	inc	byte ptr[lpCharCount]

	popad

	sub	eax,eax				; return 1
	inc	eax
	ret
lpChar		db	'\',0,'-',0,'/',0,'|',0
lChar		equ	$-lpChar
lpCharCount	db	0

CompressCallback endp
#

;	edx	ptr to msg
writeln	proc	near
	pushad

	test	edx,edx
	jne	normal_string

	mov	edx,offset szCRLF
	push	2
	pop	eax
	jmp	show_console_msg

normal_string:
	or	eax,-1
search_zero_msg:
	inc	eax
	cmp	byte ptr[eax+edx],0
	jne	search_zero_msg
show_console_msg:
	push	0
	push	offset lpWritten
	push	eax				; string length
	push	edx				; string
	push	[hConsoleOut]			; output handle
	call	WriteConsoleA

	popad
	ret

writeln	endp


	include pex_loader.asm

end	_start



