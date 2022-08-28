{*******************}
{*** WAVETAB.PAS ***}
{*******************}
uses
  crt;
var
  f : text;
  k,offset : word;
begin
  asm
    mov ax,13h
    int 10h
  end;
  assign(f,'WAVE.DAT');
  rewrite(f);
  for k := 0 to 320 do
     begin
       offset := 320 * (100 + round(50*sin(k*pi/160))) + k;
       mem[$a000:offset] := 63;
       write(f,chr(lo(offset)),chr(hi(offset)));
     end;
  close(f);
end.
