var 
     k : real; 
     f,g : text; 
     x,l : integer; 
begin 
     assign(f,'SIN.ASM'); 
     rewrite(f); 
     assign(g,'COS.ASM'); 
     rewrite(g); 
     k := 0; 
     x := 0; 
     l := 0; 
     write(f,'sinus     dw '); 
     write(g,'cosin     dw '); 
     repeat 
          write(f,round(512*sin(k)):3);
          write(g,round(512*cos(k)):3);
          if x < 10 then begin 
               write(f,','); 
               write(g,','); 
          end 
          else 
          begin 
               writeln(f); 
               writeln(g); 
               write(f,'   dw '); 
               write(g,'   dw '); 
               x := 0; 
          end; 
          inc(x); 
          k := k + 2*pi/360; 
     until k > 2*pi; 
     write(f,0); 
     write(g,0); 
     close(f); 
     close(g); 
end. 
