;	TRAP		equ 1
;	DEBUG_T		equ 1
	MAGIC		equ 1
;	SAVE_FLAGS	equ 1

	BANNER		equ 1


@loader_start:
ifdef	BANNER
	jmp	@after_banner
	db	CR,LF
	db	'ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ',CR,LF
	db	' PeX (c) by bart^CrackPl beta release                                          ',CR,LF
	db	'ФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФФ',CR,LF
@after_banner:
endif
	pushad
ifdef SAVE_FLAGS
	pushfd
endif
						_trash	0E8h
	call	@delta				; delta offset
	db	0E9h				; junxx
@delta:	pop	ebp				; pop caller offset
	sub	ebp,(offset @delta)-1		; substract hardcoded delta offset

	call	@fake_ret
	db	0E8h
	jmp	@trap_trick
@return:
	jmp	@return_from_call
	db	0CDh,20h
@return_from_call:
	jmp	dword ptr[esp]
	db	09Ah
@trap_trick:
ifdef MAGIC
	mov	si,'FG'				; magic values
						fcall	ecx,09Ah
	lea	edx,[ebp+@after_int]		; handler offset
						fcall	eax,069h
	mov	di,'JM'				; magic
	call	@set_seh
	lea	edx,[edx-(@after_int-@exit_process)]
						fcall	ebx,0E8h
	db	68h				; push dword
	db	0CCh				; int 3 <-------+
	db	0FFh,0E2h			; jmp edx	|
	db	9Ah				; junk		|
						;		|
	jmp	esp				; --------------+
	db	069h
@exit_process:
	jmp	dword ptr[ebp+_ExitProcess]	; exit process
	db	0E9h
@after_int:
endif

	call	@return
@call_trick_start:
						_vxd
	mov	eax,esp
						_vxd
	add	dword ptr[eax],@call_trick_end-@call_trick_start
	jne	@fake_ret
@call_trick_end:
	db	069h

	call	$+5
	pop	eax
	cdq
	or	dl,21
	lea	eax,[eax+edx]
	push	eax
	
	call	@fake_ret_02
	cmp	ax,0F386h
	je	@next_weird+2
	db	0E9h
@next_weird:

ifdef TRAP
	pushfd
						fcall	eax,08Bh
	pop	eax
	test	ah,1				; trap flag
	jne	@exit_process
	
	or	eax,_of				; set overflow flag
	jmp	@invoke_int4
@trap_flag_not_set:
	and	eax,NOT _of			; clear overflow flag
@invoke_int4:
	push	eax
	popfd					; restore flags
	into					; int 4 on overflow
endif

	lea	edx,[ebp+@real_seh]
	call	@set_seh
						_trash	69h
	lea	edi,[ebp+@it_end]
	mov	ecx,12345678
@compressed_size	equ dword ptr $-4
	mov	edx,12345678
@decryption_key_1	equ dword ptr $-4

@decrypt_extra_data:
	mov	al,byte ptr[edi]
@decrypt_extra_engine:
	ror	al,cl
	xor	al,cl
	not	al
	xor	al,ch
	xor	al,dl
	xor	al,dh
	rol	al,cl
	add	al,cl
	add	al,ch
	add	al,dl
	add	al,dh
	ror	al,cl
	sub	al,cl
	sub	al,ch
	not	al
	sub	al,dl
	sub	al,dh
	rol	al,cl
@decrypt_extra_engine_size	equ $-@decrypt_extra_engine
	rol	edx,cl
	mov	byte ptr[edi],al
	inc	edi
	dec	ecx
	jne	@decrypt_extra_data
						_trash 0E8h
	ud2_1					; exception :)
	db	0E8h
@handler_1:
	sub	edx,edx
	mov	eax,dword ptr fs:[edx]
	mov	esp,[eax]
	pop	dword ptr fs:[edx]
	pop	eax				; pop handler
	pop	ebp				; delta offset
	ret					; return
	db	09Ah
@real_seh:
	mov	edx,dword ptr[ebp+_ExitProcess]	; handler pointer
	call	@set_seh
						_trash	0C7h
	mov	ebx,12345678
@uncompressed	equ dword ptr $-4

	push	PAGE_READWRITE			; access type
	push	MEM_RESERVE or MEM_COMMIT	; flags
	push	ebx				; memory size to allocate
	push	0
	call	[ebp+_VirtualAlloc]		; allocate memory
						_trash	0E8h
	push	MEM_DECOMMIT			; save params for VirtualFree
	push	ebx				; memory size to deallocate
	push	eax				; memory pointer
						_trash	0E9h
	push	eax				; destination
	lea	edx,[ebp+@it_end]
	push	edx				; source

	call	_aP_depack_asm			; depack it
						_trash	069h
	pop	edx				; pop source
	pop	esi				; pop destination
	push	cs				; code segment
	push	esi				; jmp to depacked code
	retf					; pop offset->pop segment->jmp segment:offset

	include	depack.inc			; decompression code
@fake_ret_02:
	jmp	@fake_ret_02_exit
	db	069h
@fake_ret_02_exit:
	pop	eax
	pop	eax
	jmp	eax

@set_seh:
	pop	ecx				; pop return address

	push	edx				; edx destination handler
	push	ebp				; save delta offset
	lea	eax,[ebp+@handler_1]		; pointer to handler
	push	eax
	sub	eax,eax
	push	dword ptr fs:[eax]
	mov	dword ptr fs:[eax],esp
@ret:
						_junk	0E8h

	push	ecx				; return from call

	ret

@fake_ret:
						_junk	09Ah
	pop	ecx
	inc	ecx
	jmp	@ret


@loader_end:
	dd	0,0
ImportTable:
IMAGE_IMPORT_DESCRIPTOR1:			; IMAGE_IMPORT_DESCRIPTOR for KERNEL32
		dd	Dll1_Pointer1-ImportTable	; pointer to original 1st thunk(NULL termiated)
		dd	0				; time date stamp
		dd	0				; forwarder chain
		dd	Dll1-ImportTable		; pointer to DLL asciz name
		dd	Dll1_Pointer1-ImportTable	; pointer to original 1st thunk(NULL termiated)

IMAGE_IMPORT_DESCRIPTOR2:			; IMAGE_IMPORT_DESCRIPTOR for USER32
		dd	Dll2_Pointer1-ImportTable
		dd	0,0
		dd	Dll2-ImportTable
		dd	Dll2_Pointer1-ImportTable

		dd	0,0,0,0,0		; NULL IMAGE_IMPORT_DESCRIPTOR entry

;Dll2_RVA1	dd	Dll2_1-ImportTable	; this thingie seems to be never used
;		dd	0
Dll2_Pointer1	dd	Dll2_1-ImportTable	; pointer to IMAGE_IMPORT_BY_NAME struct
		dd	0			; end marker

;Dll1_RVA1	dd	Dll1_1-ImportTable	; we're only using one table
;Dll1_RVA2	dd	Dll1_2-ImportTable	;
;Dll1_RVA3	dd	Dll1_3-ImportTable	;
;Dll1_RVA4	dd	Dll1_4-ImportTable	;
;Dll1_RVA5	dd	Dll1_5-ImportTable	;
;		dd	0

Dll1_Pointer1	dd	Dll1_1-ImportTable	; call dword ptr[ebp+Dll1_RVA1]
Dll1_Pointer2	dd	Dll1_2-ImportTable
Dll1_Pointer3	dd	Dll1_3-ImportTable
Dll1_Pointer4	dd	Dll1_4-ImportTable
Dll1_Pointer5	dd	Dll1_5-ImportTable

@import_redirector:

		dd	0			; end marker
Dll1		db	'KERNEL32.DLL',0	; module name
Dll2		db	'USER32.DLL',0

Dll1_1		dw      0			; ord or string (0=string)
                db	'GetProcAddress',0
Dll1_2		dw	0
		db	'LoadLibraryA',0
Dll1_3		dw	0
		db	'ExitProcess',0
Dll1_4		dw	0
		db	'VirtualAlloc',0
Dll1_5		dw	0
		db	'VirtualFree',0

Dll2_1		dw	0
		db	'MessageBoxA',0
		dd	0
_GetProcAddress	equ Dll1_Pointer1
_LoadLibraryA	equ Dll1_Pointer2
_ExitProcess	equ Dll1_Pointer3
_VirtualAlloc	equ Dll1_Pointer4
_VirtualFree	equ Dll1_Pointer5

_MessageBoxA	equ Dll2_Pointer1
@it_end:
@loader_len	equ $-@loader_start

; this code is located in memory allocated by VirtualAlloc
; we must calculate 2nd delta offset,and update all pointers
; that needs 1st delta offset displacement...what a mess ;)

@symbiont_start:
	xchg	eax,ebp				; mov to eax 1st delta offset
@passed:
	call	@delta2				; delta offset
	db	0C7h				; junxx
@delta2:pop	ebp				; pop caller offset
	sub	ebp,(offset @delta2)-1		; substract hardcoded delta offset

	lea	edx,[ebp+@patch_delta_table]	; offsets that need update
	push	7				; total offsets count
	pop	ecx
@make_delta_relocation:
	mov	ebx,[edx]			; ebx offset
	add	ebx,ebp				; in allocated memory
	add	[ebx],eax			; update pointer
	add	edx,4				; next offset
	loop	@make_delta_relocation

	add	esi,@symbiont_length		; esi = $
						; +@symbiont_length==pointer to extra data
	inc	ecx
	db	0C1h,0F1h,1			; sal ecx,1
	loop	@fake_loop
	db	0E8h
@fake_loop:

@copy_sections:
	cld					; clear direction flag
	mov	edi,1234567			; pointer to section table
@section_table	equ dword ptr $-4
	mov	ebx,1234567			; section count(without loader section)
@section_count	equ dword ptr $-4
						_trash	0C7h
@decompress_sections:
	push	edi				; save pointer to section table
	cmp	byte ptr[edi+objlinenum],0	; check if section is compressed
	jne	@skip_this_section		;
						_trash	0E9h
	mov	ecx,[edi]			; original section raw size(section name
						; overwrited with original section size)
	movzx	eax,byte ptr[edi+objflags]
	xor	al,byte ptr[edi+objflags+3]	; al should be 80h
	
	add	eax,[edi+objrva]
	add	eax,12345678			; section VA
@image_base	equ dword ptr $-4

	push	7Fh				; push byte 80-1(short form of push)
	pop	edx				; edx=7Fh
	inc	edx				; edx=80h
	sub	eax,edx				; correct eax
	xchg	eax,edi

	rep	movsb				; copy this section

@skip_this_section:
	pop	edi				; pop pointer to section table
	add	edi,objlen			; pointer to next section in table
						_trash	0E8h
	dec	ebx				; decrement sections count
	jne	@decompress_sections
						_trash	069h
	mov	[ebp+@passed],ebx		; initial value(0)
;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; IMPORT TABLE HANDLING
;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
	mov	esi,12345678			; original import table rva
@old_import	equ dword ptr $-4
	test	esi,esi				; import table exists?
	je	@it_done
						fcall eax,0E8h
	finit
						fcall eax,0E9h
	fild	qword ptr[ebp+@clear]		; load 8bytes of @clear procedure to st0
	
						fcall	edx,069h
	mov	edx,[ebp+@image_base]		; edx - imagebase
	add	esi,edx				; VA of import table
						_junk	09Ah
@next_module:
	mov	eax,[esi+12]			; dll name RVA
	test	eax,eax				; last image import descriptor?
	je	@it_done
						_trash	0E9h
	
	add	eax,edx				; dll name VA
	mov	ebx,eax				; ebx pointer to dll asciz name
	push	eax				; push offset to dll name
						_trash	09Ah
	mov	eax,dword ptr[_LoadLibraryA]
@patch_1_delta	equ dword ptr $-4

	call	@check_bpx
@load:						; restore eax
	call	eax				; call LoadLibraryA

	test	eax,eax				; cannot load library?
	je	@import_dll_error

						fcall	ecx,069h
	fistp	qword ptr[ebp+@clear]		; restore&pop
	fild	qword ptr[ebp+@clear]		; load
						_junk	08Bh
@is_loaded:
	call	@clear				; erase DLL name(ebx pointer to dll name)
						_junk	09Ah
	mov	[ebp+@hmodule], eax		; save dll handle
	push	0
	pop	dword ptr [@it_index+ebp]	; start 0
						_junk	08Bh
@next_function:
        mov	eax,[esi]			; original first thunk (rva)
        test	eax,eax				; is it there?
        mov	edx,[ebp+@image_base]		; imagebase
        jne	@do_hint
        mov	eax,[esi+16]			; try to use 2nd table
						_junk	069h
@do_hint:
	add	eax,edx				; offset to function name
	add	eax,[@it_index+ebp]
						_junk	069h
	mov	ebx,[eax]
	not	ebx
@pointer_enc_opcode	equ byte ptr $-1
	mov	dword ptr[eax],edx		; clear RVA pointer
	mov	edi,[esi+16]			; pointer array
						_junk	069h
	add	edi,edx                           
	add	edi,[@it_index+ebp]             ; address of IAT entry to patch 
	test	ebx,ebx                         ; function present?
	je	@thunk_end
						_trash 0E8h
	test	ebx,80000000h			; is imported by ordinal?
	je	@str
@ord:	mov	byte ptr[ebp+@ord_flag],1
	jmp	@ordinal

@str:	mov	byte ptr[ebp+@ord_flag],0
;	lea	ebx,[ebx+edx+2]			; pointer to api name
	add	ebx,edx				; pointer to api name(moved up 2bytes ;)
						_trash	069h
	mov	eax,12345678
@apiname_key	equ dword ptr $-4
	push	ebx
	sub	ecx,ecx
@decrypt_apiname:
	mov	cl,byte ptr[ebx]
@dec_apiname:
	xor	cl,al
						_trash	0E9h
	add	cl,ah
						_trash	0E8h
	sub	cl,al
						_trash	0E9h

	db	0C1h,0C0h			; rol	eax,byte
	db	00h
@apiname_decrypt_rolkey	equ byte ptr $-1
						_trash	0E9h
	mov	byte ptr[ebx],cl
	inc	ebx
	test	ecx,ecx
	jne	@decrypt_apiname
@decrypt_apiname_end:
	pop	ebx
						_trash	0E8h
@ordinal:
	and	ebx, 7FFFFFFFh			; clear 31st bit

	push	ebx				; API name or ORD
	push	dword ptr[ebp+@hmodule]		; module handle
						_trash 0E8h
	mov	eax,dword ptr[_GetProcAddress]
@patch_2_delta	equ dword ptr $-4
	call	@check_bpx			; check bpx
@getp:	call	eax				; GetProcAddress
	test	eax,eax
	je	@import_func_error

@skip_2nd:
						_trash 0E9h
	call	@check_bpx			; check function againts BPX

	pushad					; save all regs
@store:
;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; API redirector
; before:
; IAT:
; ...
; dd	offset SomeFunc
; after:
; IAT:
; ...
; dd	offset lpRedirector1			; jmp to redirector
;
; lpRedirector1:
; push	0					;\
; sub	edx,edx					; > execute 1st instructions of proc
; push	1000					;/
; jmp	SomeFunc+9--------------+
;				|
; SomeFunc:			|
; push	0			|
; sub	edx,edx			|
; push	1000			|
; call	Some <------------------+
;
;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
						_trash 09Ah
	mov	ebx,offset @import_redirector	; pointer to import redirector
@patch_7_delta	equ dword ptr $-4

	lea	ecx,[ebp+@passed]		; work done
	add	ebx,[ecx]
	cmp	dword ptr[ecx],1234567		; check against overflow
@max_redir_size	equ dword ptr $-4
	jae	@normal_api_store		; in this case save api addresses to IAT

	push	ebx				; pointer to redirector
						_trash 08Dh
	push	edi
						_trash 08Bh
	push	ecx
;	mov	byte ptr[ebx],0CCh
;	inc	ebx
;	inc	dword ptr[ecx]
@next_opcode:
; check push reg32,pop reg32 opcodes

	mov	dl,byte ptr[eax]		; get byte from api func
	
	cmp	dl,50h				; is it push reg32?
	jb	@check_next_opcode1		; nope something else

	cmp	dl,5Fh				; pop reg32
	jbe	@update_code_one
@check_next_opcode1:
	
;	mov	dl,50h
;
;	push	0Fh
;	pop	ecx
;@check_one_byte_opcode:
;	cmp	byte ptr[eax],dl
;	je	@update_code_one
;	inc	dl
;	loop	@check_one_byte_opcode
;
;	cmp	byte ptr[eax],6Ah		; push byte
	cmp	dl,6Ah				; push byte
	je	@update_code_two
;
;	cmp	byte ptr[eax],68h		; push dword
	cmp	dl,68h				; push dword
	je	@update_code_five
;
;	mov	dl,0B0h				; mov al,byte
;	push	7
;	pop	ecx
;@check_two_byte_mov_al:
;	cmp	byte ptr[eax],dl
;	je	@update_code_two
;	inc	dl
;	loop	@check_two_byte_mov_al
	cmp	dl,0B0h
	jb	@check_next_opcode2

	cmp	dl,0B7h
	jbe	@update_code_two
@check_next_opcode2:


	lea	esi,[ebp+@two_byte_op]		; 2 bytes opcodes table
	push	4				; opcodes count
	pop	ecx
@check_two_bytes_opcode:
	mov	dl,byte ptr[esi]		; get byte from table
	cmp	byte ptr[eax],dl		; match with api code?
	jne	@check_next_two			; nope

	mov	edi,ecx				; edi counter
	push	(0FFh-0C0h)
	pop	ecx
	mov	dl,0C0h				; modr byte
@check_two_bytes_modr:
	cmp	byte ptr[eax+1],dl
	je	@update_code_two
	inc	dl
	loop	@check_two_bytes_modr

	mov	ecx,edi
@check_next_two:
	inc	esi
	loop	@check_two_bytes_opcode

	jmp	@dissasm_end
@update_code_one:

	mov	dl,1
	jmp	@fix_pointers
@update_code_two:

	mov	dl,2
	jmp	@fix_pointers
	
@update_code_five:
	mov	dl,5
; eax - source
; ebx - destination
; edx - bytes count
@fix_pointers:
	push	3
	pop	ecx

	mov	word ptr[ebx],01EBh		; junk jmp $+3
	mov	byte ptr[ebx+2],al		; bogus byte
	add	dword ptr[ebp+@passed],ecx	; inc counter
	add	ebx,ecx				; inc pointer
						_trash 0C7h

	movzx	edx,dl				; mask edx
	add	dword ptr[ebp+@passed],edx	; inc global counter
@copy_func_bytes:
	mov	cl,byte ptr[eax]		; copy bytes from
	mov	byte ptr[ebx],cl		; *eax to *ebx
	inc	eax				; increment pointers
	inc	ebx				;
	dec	edx				; decrement counter
	jne	@copy_func_bytes
	jmp	@next_opcode			; go to next opcode

@dissasm_end:
	pop	ecx
						_trash 069h
	push	5				; mov	edx,5
	pop	edx				; but only 3bytes insteed of 5bytes in mov edx,5
						_trash 0C7h
	sub	eax,ebx				; destination-jmp instruction VA
	sub	eax,edx				; -jmp ???????? instr size(5bytes)=relative offset
	mov	byte ptr[ebx],0E9h		; opcode of jmp relative
	mov	dword ptr[ebx+1],eax		; relative offset
	add	dword ptr[ecx],edx		; inc global counter
						_trash 0E9h
	pop	edi
	pop	eax				; eax pointer to redirected jmp
@normal_api_store:
	mov     [edi],eax			; patch IAT
	add     dword ptr[ebp+@it_index],4	; next IMAGE_THUNK_DATA entry
	popad
@clear_name:
	cmp	byte ptr[ebp+@ord_flag],0	; if function were imported by ordinal
	jne	@skip_erasing			; skip erasing(what do you want to erase today?)

	fistp	qword ptr[ebp+@clear]		; restore code from erase function
	fild	qword ptr[ebp+@clear]		; restore&pop
	
	jmp	$+3
	db	09Ah

	lea	eax,[ebp+@next_function]
	push	eax
	jmp	@clear				; clear function name
@skip_erasing:
	jmp	@next_function			; go to the next function
@thunk_end:
	push	5				; 5*4=20
	pop	ecx
	xchg	edi,esi
	rep	stosd				; erase IMAGE_IMPORT_DESCRIPTOR struct
	xchg	edi,esi				; esi - pointer to next IMAGE_IMPORT_DESCRIPTOR entry

	mov	edx,[ebp+@image_base]
	jmp	@next_module
@it_done:
	push	eax
	push	eax
	fistp	qword ptr[esp]
	pop	eax
	pop	eax
						_trash	09Ah
	mov	edi,offset @loader_start+1	; edi destination
@patch_5_delta	equ dword ptr $-4
	push	edi				; return trick
	lea	esi,[ebp+@return_code_start]
	db	6Ah				; push byte
	db	(@return_code_end-@return_code_start)

	pop	ecx
	rep	movsb				; copy code needed to return to the host eip to
						; new location
	ret					; jmp @loader_start+1

@return_code_start:
	call	[_VirtualFree]			; free memory
@patch_6_delta	equ dword ptr $-4
						_trash	0E9h
	sub	eax,eax
	pop	dword ptr fs:[eax]		; restore handler
	add	esp,3*4				; fix stack
						fcall	eax,0C7h
ifdef SAVE_FLAGS
	popfd
endif
	popad
	call	@call
	db	0E8h

	call	@call
	db	09Ah

	call	@call
	db	0E9h

	push	12345678			; (entrypointVA-1)
@entrypoint	equ dword ptr $-4
	jmp	@call
	db	0C7h
@call:
	pop	eax
	inc	eax
	push	eax
	ret
@return_code_end:

;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; mov	ebx,offset lpASCIzString
; call	@clear
@clear	proc near
	mov	byte ptr[ebx],0
	inc	ebx
	cmp	byte ptr[ebx],0
	jne	@clear
	ret
@clear	endp
;ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; mov	eax,offset lpCode
; call	@check_bpx
@check_bpx	proc near
						_trash	0E8h
ifdef	DEBUG_T
else
	cmp	byte ptr[eax],0CCh		; check if any breakpoint is set
	je	$+3				; crash on breakpoint
endif
	ret
	db	0F0h,0Fh,0C7h,0C8h		; lock cmpxchg8b (e)ax this will crash SoftIce and all system
	
@check_bpx	endp
	
@import_dll_error:
	lea	edx,[ebp+@import_dll]
	call	@str_cat
	jmp	@import_error
@import_func_error:
	lea	edx,[ebp+@import_func]

	cmp	byte ptr[ebp+@ord_flag],0
	jne	@import_bute_exit

	call	@str_cat
	
@import_error:
	push	10h
	lea	eax,[ebp+@caption]
	push	eax
	push	edx
	push	0
	call	[_MessageBoxA]
@patch_3_delta	equ dword ptr $-4

@import_bute_exit:
	jmp	[_ExitProcess]
@patch_4_delta	equ dword ptr $-4

; edx lpDestinationString
; ebx lpSourceString
@str_cat:
	push	edx
	xchg	edx,edi
	sub	eax,eax
@find_zero:
	scasb
	jne	@find_zero
	dec	edi
@copy_string:
	mov	al,byte ptr[ebx]
	mov	byte ptr[edi],al
	inc	ebx
	inc	edi
	test	eax,eax
	jne	@copy_string
@end_copy:
	pop	edx
	ret

@loader_data:

@caption	db	'PeX by bart',0
@import_dll	db	"Couldn't load library ",0
@import_func	db	"Couldn't locate function ",0

@it_index	dd	0
@hmodule	dd	0
@ord_flag	db	0

@two_byte_op:			; byte,0C0h
		db	8Bh	; mov reg32,reg32
		db	2Bh	; sub reg32,reg32
		db	03h	; add reg32,reg32
		db	33h	; xor reg32,reg32

@patch_delta_table:
		dd	offset @patch_1_delta
		dd	offset @patch_2_delta
		dd	offset @patch_3_delta
		dd	offset @patch_4_delta
		dd	offset @patch_5_delta
		dd	offset @patch_6_delta
		dd	offset @patch_7_delta
@patch_delta_table_len	equ $-@patch_delta_table

@symbiont_end:

@symbiont_length	equ $-@symbiont_start
@total_loader_size	equ $-@loader_start
