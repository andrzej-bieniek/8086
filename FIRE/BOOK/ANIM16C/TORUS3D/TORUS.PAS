type 
  point3d = record 
              x,y,z : real; 
            end; 
const 
  i1 = 60; {Ilosc okregow tworzacych}
  i2 = 20; {Ilosc punktow na kazdym okrego tworzacym}
var 
  x,y,z    : real; 
  xv,yv,zv : real; 
  xe,ye    : integer; 
  t1       : array[0..i2] of point3d; 
  tab      : array[0..i1,0..i2] of point3d; 
 
 
Procedure RotateY(x,y,z,kat : real;var x1,y1,z1 : real); 
  begin 
    x1 := x * cos(kat) - z * sin(kat); 
    z1 := z * cos(kat) + x * sin(kat); 
    y1 := y; 
  end; 
 
Procedure Trans(x,y,z : real;var xp,yp : integer); 
  var 
    pz : real; 
  begin 
    pz := zv / (z - zv); 
    xp := trunc(xv + (x - xv) * pz)+xe; 
    yp := trunc(yv + (y - yv) * pz)+ye; 
  end; 
 
Procedure Init; 
{Procedura ÿprzygotowuje bazowa tablice ze wspolrzednymi punktow 
na okregu tworzacym}
  var 
    k : real; 
    l : byte; 
    x,y : real; 
  begin 
    k := 0; 
    for l := 0 to i2 do 
        begin 
          x := 35 + 15*sin(k); 
          y := 0 + 15 * cos(k); 
          t1[l].x := x; 
          t1[l].y := y; 
          t1[l].z := 0; 
          k := k + (2*pi)/i2; 
        end; 
  end; 
 
Procedure RobTorus; 
{Procedura ÿÿobraca ÿÿokrag ÿtworzacy ÿi ÿzapamietuje ÿwszystkie 
powstale w ten sposob punkty}
  var 
    l,i,j : integer; 
    x,y,z : real; 
    k     : real; 
    xr,yr,zr : real; 
  begin 
    k := 0; 
    for l := 0 to i1 do 
        begin 
          for i := 0 to i2 do 
              begin 
                x := t1[i].x; 
                y := t1[i].y; 
                z := 0; 
                Rotatey(x,y,z,k,xr,yr,zr); 
                tab[l,i].x := xr; 
                tab[l,i].y := yr; 
                tab[l,i].z := -zr; 
              end; 
          k := k + 2*pi/i1; 
       end; 
 end; 
 
Procedure SaveTorus; 
{Procedura zapisuje na dysku tablice wspolrzednych}
  var 
    f1    : text; 
    i,j   : integer; 
    x,y,z : integer; 
  begin 
    assign(f1,'pix'); 
    rewrite(f1); 
    for i := 0 to i1 do 
        begin 
          if i= 0 then write(f1,' pix '); 
          for j := 0 to i2 do 
              begin 
                x := round(tab[i,j].x); 
                y := round(tab[i,j].y); 
                z := round(tab[i,j].z); 
                writeln(f1,'dw ',x,',',y,',',z); 
              end; 
       end; 
      close(f1); 
  end; 
 
begin 
  xv := 0; 
  yv := 0; 
  zv := -100; 
  xe := 150; 
  ye := 100; 
  Init; 
  RobTorus; 
  SaveTorus; 
end.
