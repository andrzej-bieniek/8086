{*******************}
{*** GWIAZDY.PAS ***}
{*******************}

uses
  crt;
const
  ile = 400;
var
  f     : text;
  ofset : word;
  l     : word;
begin
  randomize;
  assign(f,'gwiazdy.dat');
  rewrite(f);
  for l := 0 to ile * 3 do
    begin
      ofset := 320*random(200)+random(320);
      write(f,chr(lo(ofset)),chr(hi(ofset)));
    end;
  close(f);
end.