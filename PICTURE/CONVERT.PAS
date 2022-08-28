{ Program (CONVERT.PAS) napisany przez M$(1998).
   Opis:

    Program przeprowadza konwersje rysunku w pliku PICTURE.TXT na dane
    hexadecymalne:  Ofset,Licznik,...,00h(Nastepna linia),Ofset,Licznik,...
}

Uses Crt;

 Const
  SizeX=45;       { Rozmiary rysunku }
  SizeY=37;

 Var
  Plik   : Text;
  Offs   : Byte;
  Count  : Byte;
  Ln     : Byte;
  Line   : string;
  Zn     : string[1];
  Size   : Byte;
  Target : Text;
  Next   : Byte;

  Function Hex(b:byte):string;                 { funkcja zmienia Dec na Hex }
   const HexArray:String='0123456789ABCDEF';
   var OutHex:String;
   begin
    OutHex:='';
    OutHex:=HexArray[(b shr 4)+1]+HexArray[(b mod 16)+1]+'h';
    if OutHex[1] in ['A'..'F'] then OutHex:='0'+OutHex;
    Hex:=OutHex;
   end;

  Procedure NextLine;
   begin
    Writeln(Target);
    Write(Target,'         db ');
    Next:=0;
   end;

 Begin
  ClrScr;
  Assign(Plik,'Picture.txt');
  Reset(Plik);
  Assign(Target,'Picture.as$');
  Rewrite(Target);
  Write(Target,' Picture db ');
  For Ln:=1 to SizeY do
   Begin
    Readln(Plik,Line);
    Offs:=1;
    Repeat
     Zn:=Copy(Line,Offs,1);
     If Zn<>#219 then Inc(Offs);
     If Zn=#219 then
      begin
       Count:=0;
       repeat
        Inc(Count);
        Zn:=Copy(Line,Offs+Count,1);
       until Zn<>#219;
      Write(Target,Hex(Offs),',',Hex(Count),',');
      Inc(Next,2);
      If Next>=17 then NextLine;
      Write('.');
      Inc(Size,2);
      inc(Offs,Count);
      end;
    Until Offs>=SizeX;
    Write(Target,'00h,');
    Inc(Size);
    Inc(Next,2);
    If Next>=17 then NextLine;
   end;
  Writeln(Target);
  Writeln(Target,'Size db ',Hex(Size));
  Close(Plik);
  Close(Target);
 End.


