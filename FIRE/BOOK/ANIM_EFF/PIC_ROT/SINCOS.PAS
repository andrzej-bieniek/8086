{******************}
{*** SINCOS.PAS ***}
{******************}

uses
  crt;
var
  f       : text;
  d       : word;
  kat     : real;
  sin1,cos1,sin2,cos2 : array[0..255] of integer;
begin
  for d := 0 to 255 do
     begin
       kat := d * pi / 128;
       sin1[d] := round(sin(kat)*256);
       cos1[d] := round(cos(kat)*256);
       sin2[d] := round(sin(kat+pi/2)*256*1.2);
       cos2[d] := round(cos(kat+pi/2)*256*1.2);
     end;
  assign(f,'sin1.dat');
  rewrite(f);
  for d := 0 to 255 do
     write(f,chr(lo(sin1[d])),chr(hi(sin1[d])));
  close(f);
  assign(f,'cos1.dat');
  rewrite(f);
  for d := 0 to 255 do
     write(f,chr(lo(cos1[d])),chr(hi(cos1[d])));
  close(f);
  assign(f,'sin2.dat');
  rewrite(f);
  for d := 0 to 255 do
     write(f,chr(lo(sin2[d])),chr(hi(sin2[d])));
  close(f);
  assign(f,'cos2.dat');
  rewrite(f);
  for d := 0 to 255 do
     write(f,chr(lo(cos2[d])),chr(hi(cos2[d])));
  close(f);
end.