uses
  crt;
var
  pal : array[0..768] of byte;
  pic : array[1..64000] of byte absolute $a000:0;

Procedure LoadBMP;
  var
    f : text;
    x : word;
    r,g,b,z : char;
  begin
    assign(f,paramstr(1));
    reset(f);
    for x := 0 to 53 do
        read(f,z);
    for x := 0 to 255 do
        begin
          read(f,b,g,r,z);
          pal[x*3  ] := ord(r) div 4;
          pal[x*3+1] := ord(g) div 4;
          pal[x*3+2] := ord(b) div 4;
        end;
    for x := 1 to 64000 do
        begin
          read(f,z);
          pic[x] := ord(z);
        end;
    close(f);
   end;

Procedure SetPal;
  var
    x : byte;
  begin
    for x := 0 to 255 do
       begin
         port[$3c8] := x;
         port[$3c9] := pal[x*3];
         port[$3c9] := pal[x*3+1];
         port[$3c9] := pal[x*3+2];
       end;
  end;

Procedure Flip;
  var
    x,y : word;
    p : byte;
  begin
    for y := 0 to 100 do
        for x := 0 to 319 do
          begin
            p := pic[x+320*y];
            pic[x+320*y] := pic[x+320*(200-y)];
            pic[x+320*(200-y)] := p
          end;
  end;

Procedure _Write;
  var
    f : text;
    x : word;
  begin
    assign(f,paramstr(2)+'.sfg');
    rewrite(f);
    for x := 0 to 64000-1 do
        write(f,chr(pic[x]));
    close(f);
    assign(f,paramstr(3)+'.pal');
    rewrite(f);
    for x := 0 to 768 do
        write(f,chr(pal[x]));
    close(f);
  end;

begin
  asm
    mov ax,13h;
    int 10h
  end;
  LoadBMP;
  Flip;
  SetPal;
  _Write;
  readln;
end.