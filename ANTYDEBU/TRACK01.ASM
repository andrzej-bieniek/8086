; Anti Debugger (TRACK01.ASM) written by M$(1998);
;
; Description:
; Disable debugging.
; Program replace vector of interrupt 01h (offset only) to offset
; interrupt 03h. It does not cause computer to freeze, but during 
; Turbo Debugger session you will not be able to call interrupts (i.e. trying to continue debugging
; the program using key F7 or F8 (track), Turbo Debgger will not be able 
; to call any interrupts - it will just stand still.
; There are three ways to avoid this protection:
; 1) Remove the vector replacement (if there is nothing more)
; 2) If there is something more in the procedure, change it the way so interrupts works (...???)
; 3) To call interrupt you you have to put breakpoint on the interrupt call and just after it.
;   Using key F9(Run) Turbo Debugger will call the interrupt.


; Anty Debuger (TRACK01.ASM) napisany przez M$(1998);
;
; Opis:
; Zablokowanie sledzenia.
; Program wymienia wektor przerwania 01h (tylko jego offset) na offset
; przerwania 03h. Nie powoduje to zawieszenia komputera, natomiast podczas
; sesji Turbo Debuggera nie bedzie mozna wywolywac przerwan (tzn. chcac sledzic
; dalej program klawiszem F7 lub F8(track), Turbo Debgger nie bedzie umial
; wywolac jakiego kolwiek przerwania - poprostu stanie w miejscu.
; Sa trzy sposoby na unieszkodliwienie tego zabezpieczenia:
; 1) Wykasowac wymiane przerwania (jezeli nie ma tam czegos wiecej)
; 2) Jezeli cos jest w procedurze to tak to przerobic zeby dzialo(...???)
; 3) Zeby potem wywolac przerwanie postawic na nim i po nim pulapke.
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

