{*******************}
{*** KSZTAœT.PAS ***}
{*******************}
uses
  graph,crt;
const
  sx = 300;
  sy = 200;
  sx1 = 60;
  sy1 = 60;

var
  a   : array[1..sx,1..sy] of byte;
  x,y : integer;


Procedure Putpixel(x,y : word;c : byte);
  begin
    mem[$a000:x+320*y] := c;
  end;

Function Getpixel(x,y : word) : byte;
  begin
    Getpixel := mem[$a000:x+320*y];
  end;

Procedure Init;
  begin
    asm
      mov ax,13h
      int 10h
    end;
  end;

Procedure Lupa;
  var
    x,y        : longint;
    f          : text;
    dx,dy      : integer;
    srx,sry    : integer;
    r          : integer;
    dr         : integer;
begin
  assign(f,'lupa.dat');
  rewrite(f);
  srx := sx div 2;
  sry := sy div 2;
  r := 50;
  for y := 1 to sy do
    for x := 1 to sx do
       begin
        if (x>=srx-r-2) and (x<=srx+r+2) and
           (y>=sry-r-2) and (y<=sry+r+2) then
           begin
             dr := sqr(x-srx)+sqr(y-sry);
             if dr <= sqr(r) then
                begin
                  dx := round((srx-x) / (sqrt(dr)/40+1) + x);
                  dy := round((sry-y) / (sqrt(dr)/40+1) + y);
                  dx := -x + dx;
                  dy := -y + dy;
                  putpixel(x,y,a[x+dx,y+dy]);
                end
              else
                begin
                  dx := 0;
                  dy := 0;
                end;
             dx := dx + 320*dy;
             write(f,chr(lo(dx)),chr(hi(dx)));
           end;
      end;
      close(f);
end;

Procedure Pale;
  var
    x : byte;
    f : text;
  begin
    for x := 0 to 255 do
       begin
         port[$3c8] := x;
         port[$3c9] := x;
         port[$3c9] := x * 2;
         port[$3c9] := x * 4;
       end;
  end;

begin
  Init;
  Pale;
  for y := 1 to sy do
      for x := 1 to sx do
        begin
          putpixel(x,y,x+y);
          a[x,y] := getpixel(x,y);
        end;
  Lupa;
end.

