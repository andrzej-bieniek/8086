; ============================================================================
; A 98 byte long PCX FILE READER (not much rite ? )
; works only on 320x200x256 pcx files
;
; ============================================================================
; Well I wrote it few months ago and never felt that It was someting
; worth to upload until I saw some people are really putting their efforts
; on tiny pcx file readers !!
; ============================================================================
; I AM NOT DECLARING THAT THIS IS THE SMALLEST PCX FILE READED, ALSO NOT
;                 THROUGHING ANY CHALLENGE TO ANYONE
;                 (because to me, its not a big deal)
; ============================================================================
;
; This viewer has been shrunk from 128 bytes to 98 bytes only !
; You can use this code anywhere you like. This peice of code is a very good
; example of writing smaller codes and intelligent use of registers although
; I still think it can shrunked at least 4 more bytes.
; If you can do that please let me know.
;
; ============================================================================
; USAGE:
; DRAWPCX [pcx_file_name]
; There can be only one space between the viewer and file name :)
; ===========================================================================
;
;                This code is written by Rezaul Kabir
;                      EMAIL: shuvro@kaifnet.com
;
; ============================================================================

PCXSeg SEGMENT PARA PUBLIC 'CODE'

ASSUME cs:PCXSeg, ds:PCXSeg

        org     100H
MAINPROC        proc    near

        ; get the file name from command line param
        mov     bl, byte ptr ds:[80h]

        mov     byte ptr [bx+81h], al


        ; Open pcx file to read
        mov     ah, 3Dh
        mov     dx, 82h
        int     21H
        jc      exit

        ; pass file handle
        xchg    bx, ax          ; one byte no big thing!
        mov     dx, offset Buffer

        ; Setup 320x200x256 video mode
        mov     al, 13h
        int     10h

        ; Skip first 128 bytes of the pcx file, The Header :)
        mov     cl, 80h
        call    ReadFile

        ; Start reading each byte and decode it
.386
        push    0A000h
.8086
        pop     es
        xor     di, di
ReadLup:
        call    getbyte

        test    al, 0C0h
        jns     single

        ; Runleght decoding
        and     al, 3Fh
        push    ax
        call    getbyte
        pop     cx
Single: rep stosb

        ; Check, when to stop
        cmp     di, 64001
        jb      ReadLup


        ; Read the palette for the end of the file
        mov     cx, 768
        call    ReadFile

        ; Close the pcx file
;       mov     ah, 3Eh         ; You can skip this 4 bytes as DOS
;       int     21h             ; closes all the open file handles for you
                                ; when you terminate a program normally !


        ; Setup the pal table and set the palette
        mov     si, dx
        xor     ax, ax

        mov     dx, 3c8h
        out     dx, al
        inc     dx

SetPal: lodsb
.386
        shr     al, 2
.8086
        out     dx, al
        loop    SetPal


        ; wait for key press
        int     16h

        ; back to text mode
        mov     ax, 3h
        int     10h
Exit:   ret

MAINPROC        endp

; Read a byte from the pcx file
getbyte PROC NEAR
        mov     cl, 1
ReadFile:
        mov     ah, 3Fh
        int     21h
        mov     al, Buffer
        ret
getbyte ENDP

Buffer  label   byte

PCXSeg ENDS
        END MAINPROC

