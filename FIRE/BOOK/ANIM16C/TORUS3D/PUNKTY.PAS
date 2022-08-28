var 
  f : text; 
  x : integer; 
  wx,b : byte; 
begin 
  assign(f,'punkty.asm'); 
  rewrite(f); 
  write(f,' punkty '); 
  for x := 0 to 640 do 
      begin 
        wx := x div 8; 
        b := x mod 8; 
        write(f,' dw ',wx,','); 
        asm 
          mov al,10000000b 
          mov cl,b 
          shr al,cl 
          mov b,al 
        end; 
        writeln(f,b); 
      end; 
  close(f); 
end.
