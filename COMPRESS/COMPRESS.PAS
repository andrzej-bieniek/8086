Const
 ZnakiEkr : array[1..9] of Byte = (176,177,178,219,220,223,96,126,32);

{
 ° - 176

 ± - 177

 ² - 178

 Û - 219

 Ü - 220

 ß - 223

 ` - 96

 ~ - 126
}

Var

   Plik00  : File;
   Plik01  : File of Byte;

   Bufor   : Array[1..4096] of Byte;
   Rozmiar : Word;
   Pos     : Word;
   Znak    : Byte;
   Licznik : Byte;
   Comp    : byte;

  Procedure GetCharSize(Start:word; var chr:Byte; var size:byte);
   Var L,C:Word;
    Begin
     C:=0;
     l:=0;
     Chr:=Bufor[Start];
     For L:=(Start) to (Start+14) do
      begin
       inc(C);
       if Bufor[Start]<>Bufor[L+1] then L:=Start+14;
      end;
     Size:=C;
    End;

 Begin
  Assign(Plik00,'x.asm');
  Reset(Plik00,1);
  Rozmiar:=FileSize(Plik00);
  BlockRead(Plik00,Bufor,Rozmiar);
  Close(Plik00);
  Assign(Plik01,'c.asm');
  Rewrite(Plik01);
  Pos:=1;

  Repeat
   GetCharSize(Pos,Znak,Licznik);

   if Znak=13 then
    begin
     Inc(Pos,2);
     Comp:=$FF;
     Write(Plik01,Comp);
    end else
     begin
      GetCharSize(Pos,Znak,Licznik);
      Case Znak of

      176 : znak:=1;
      177 : znak:=2;
      178 : znak:=3;
      219 : znak:=4;
      220 : znak:=5;
      223 : znak:=6;
      96  : znak:=7;
      126 : znak:=8;
      32  : znak:=9;
       end;

      Comp:=0;
      Znak:=Znak shl 4;
      Comp:=Comp or Znak;
      Comp:=Comp or Licznik;

      Write(Plik01,Comp);
      inc(Pos,Licznik);
     end;

  Until Pos>=Rozmiar;

  Close(Plik01);
 End.


