uses Crt;

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
   Comp,l  : byte;

 Begin
  Assign(Plik00,'c.asm');
  Reset(Plik00,1);
  Rozmiar:=FileSize(Plik00);
  BlockRead(Plik00,Bufor,Rozmiar);
  Close(Plik00);

  Clrscr;
  textattr:=$01;

   For pos:=1 to Rozmiar do
    begin
     Comp:=Bufor[Pos];
     if Comp=$ff then begin textattr:=$01; writeln; end else
      begin
       Licznik:=(Comp and $0f);
       Znak:=ZnakiEkr[(Comp Shr 4)];
        case znak of
               126 : textattr:=$04;
                96 : textattr:=$0e;
             end;
       if not (znak in [126,96]) then
       For l:=1 to Licznik do Write(chr(Znak))
      end;
    end;
   readkey;


 End.


