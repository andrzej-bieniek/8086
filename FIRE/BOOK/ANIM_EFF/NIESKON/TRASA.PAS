{*****************}
{*** TRASA.PAS ***}
{*****************}
uses
  crt;
const
  ile_krokow = 485; {ilož punkt¢w trasy}

var
  i       : word;
  r,k     : real;
  dr      : real;
  x,y     : word;
  xr,yr   : real;

  xs,ys   : real;
  f       : text;

begin
  asm
    mov ax,13h
    int 10h
  end;
  k := 0;
  xs := 150;
  ys := 92;
  r := 50;
  dr := 2.0;
  assign(f,'trasa.dat');
  rewrite(f);
  for i := 0 to ile_krokow do
     begin
       xr := xs + r * sin(k) * 2;
       yr := ys + r * cos(k) * 1.5;
       k := k + pi / 121;
       x := round(xr);
       y := round(yr);
       r := r + dr;
       if (r>60) or (r<20) then dr := - dr;
       mem[$a000:x+320*y] := 63;
       Write(f,chr(lo(x)),chr(hi(x)),
                 chr(lo(y)),chr(hi(y)));
       if keypressed then exit;
     end;
  close(f);
  readln;
end.
