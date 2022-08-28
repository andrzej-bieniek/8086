;Anty Debuger (TRAP01.ASM) napisany przez M$(1998).
;
;Opis:
; Zainstalowanie procedury pod przerwanie 03h.
; Pod przerwanie 03h jest instalowana nowa procedura. Jest to procedura ktorej
; nie bedzie mozna sledzic. Procedure wywoluje sie przez INT 03h.
; Dodana jest opcja sprawdzajaca czy ma byc wywolana nasza procedura czy jakis
; dupek zastawil pulapke... (jesli tak to resetuje komputer, lub mozna np
; sformatowac jakies sciezki na hdd). Jezeli postawisz pulapke w naszej
; procedurze to program sie zawiesi.


.model tiny
.code
org 100h
Start:
 xor cx,cx
 mov es,cx
 cli
 mov es:[0Ch],Offset New3
 mov es:[0Ch+2],cs
 sti
 mov cx,0FFh
 int 03h

 mov ah,4ch
 int 21h

New3 Proc
 cmp cx,0FFh ; sprawdzenie czy wywolac procedure czy zresetowac komputer
 jz Ok
 int 19h
 Ok:

 mov ax,0e07h   ; Tu mozna wstawic procedure ktorej nie mozna sledzic.
 int 10h
 xor cx,cx
 iret
New3 EndP
End Start

