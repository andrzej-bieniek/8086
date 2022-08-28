Assume cs:Moj,ds:Moj

 Hz=10000

Moj Segment
 org 100h
 Start:
  mov al,0b6h
  out 43h,al
  mov ax,Hz
  out 42h,al
  mov al,ah
  out 42h,al
  in al,61h
  or al,3
  out 61h,al

  xor ax,ax
  int 16h

  in al,61h
  and al,0fch
  out 61h,al

  ret
 Moj EndS

End Start

