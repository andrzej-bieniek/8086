uses crt;
var oldtime,c : byte;
    hz:word;
begin
 hz:=100;
  asm
   nop
   nop
   end;
  repeat
  for Hz:=110 to 130 do
   begin
    sound(Hz);
    OldTime:=Mem[$0:$046c];
    while Mem[$0:$046c]=oldtime do;
  end;
  nosound;
    OldTime:=Mem[$0:$046c];
    while Mem[$0:$046c]=oldtime do;
   until keypressed;
  asm
   nop
   nop
   end

end.