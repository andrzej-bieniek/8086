uses
  crt;
var
  f : text;
  x : longint;
  k : longint;
  rk  : real;
  ile : real;
  licz  : longint;
  k1    : real;
  w     : longint;
begin
  assign(f,'sinus.dat');
  rewrite(f);
  for k := 0 to 95 do
    begin
      k1 := k;
      rk := (k1*(360/90)*pi/180);
      rk := sin(rk);
      for x := -127 to 128 do
          begin
            ile := x * rk;
            w := round(ile*255);
            write(f,chr(lo(w)),chr(hi(w)));
          end;
    end;
  close(f);
  assign(f,'cosinus.dat');
  rewrite(f);
  for k := 0 to 95 do
    begin
      k1 := k;
      rk := (k1*(360/90)*pi/180);
      rk := cos(rk);
      for x := -127 to 128 do
          begin
            ile := x * rk;
            w := round(ile*255);
            write(f,chr(lo(w)),chr(hi(w)));
          end;
    end;
  close(f);
end.