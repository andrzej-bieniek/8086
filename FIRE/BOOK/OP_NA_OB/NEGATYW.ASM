;*******************
;*** NEGATYW.ASM *** 
;*******************
Negatyw PROC 
     mov  dx,0a000h      ;Negatyw obrazu graficznego 
     mov  ds,dx 
     mov  es,dx 
     mov  di,0 
     mov  si,0 
     mov  cx,32000 
Neguj: 
     lodsw 
     not  ax 
     stosw 
     loop Neguj 
     ret 
     ENDP 
