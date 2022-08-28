;Anty Debuger (TRACK01.ASM) napisany przez M$(1998);
;
; Opis:
;Zablokowanie sledzenia.
;Program wymienia wektor przerwania 01h (tylko jego offset) na offset
;przerwania 03h. Nie powoduje to zawieszenia komputera, natomiast podczas
;sesji Turbo Debuggera nie bedzie mozna wywolywac przerwan (tzn. chcac sledzic
;dalej program klawiszem F7 lub F8(track), Turbo Debgger nie bedzie umial
;wywolac jakiego kolwiek przerwania - poprostu stanie w miejscu.
;Sa trzy sposoby na unieszkodliwienie tego zabezpieczenia:
;1) Wykasowac wymiane przerwania (jezeli nie ma tam czegos wiecej)
;2) Jezeli cos jest w procedurze to tak to przerobic zeby dzialo(...???)
;3) Zeby potem wywolac przerwanie postawic na nim i po nim pulapke.
;   Naciskajac klawisz F9(Run) Turbo Debugger wywola przerwanie.

.model tiny
.code
org 100h
Start:
 xor cx,cx
 mov es,cx
 mov ax,word ptr es:[0Ch]
 mov word ptr es:04h,ax

 mov ax,0e07h
 int 10h
 mov ah,4ch
 int 21h
End Start

