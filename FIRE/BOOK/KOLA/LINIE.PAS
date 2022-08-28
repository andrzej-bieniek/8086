{****************}
{** LINIE.PAS ***} 
{****************}
var 
  f : text; 
  x,y : word; 
 
begin 
  assign(f,'linie.asm'); 
  rewrite(f); 
  x := 0; 
  write(f,'linie  dw  '); 
  for y := 0 to 199 do begin 
      write(f,y*320); 
      if (x < 20) and (y<199) then write(f,','); 
      if x = 20 then begin 
         writeln(f); 
         x := 0; 
         write(f,'      dw '); 
      end; 
      inc(x); 
  end; 
  close(f); 
end. 
