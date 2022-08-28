
 Var
  Source,Target : Text;
  LineString    : String;
  CheckSum      : Word;
  Point         : Byte;
  Counter       : Byte;

 Function Hex2Dec(Hex:String):Byte;
  var Result:Byte;
   begin
    if (not (Hex[1] in ['0'..'9','A'..'F'])) or (not (Hex[1] in ['0'..'9','A'..'F'])) then Hex2Dec:=0
    else
     begin
      Result:=0;
      if Hex[1] in ['0'..'9'] then Result:=16*(Ord(Hex[1])-48) else Result:=16 * (Ord(Hex[1])-55);
      if Hex[2] in ['0'..'9'] then Inc(Result,(Ord(Hex[2])-48)) else Inc(Result,(Ord(Hex[2])-55));
      Hex2Dec:=Result;
     end;
   end;

  Function Dec2Hex(w:word):string;
   const znak:array[0..15] of char =('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
    var s:string;
     begin
      s:='0000';
      s[1]:=znak[(w and $F000) shr 12];
      s[2]:=znak[(w and $0F00) shr 8];
      s[3]:=znak[(w and $00F0) shr 4];
      s[4]:=znak[w and $000F];
      dec2hex:=s[2]+s[3]+s[4];
     end;

 Begin
  Assign(Source,'XXXX');
  Reset(Source);
  Assign(Target,'$$$$$$$.$$$');
  Rewrite(Target);

  Repeat
   Readln(Source,LineString);
   Writeln(Target,LineString);
   LineString:= Copy(LineString,1,6);
   Writeln(LineString);
  Until LineString='Offset';

  While not Eof(Source) do
   begin
    Readln(Source,LineString);
    if LineString='' then
     begin
      Writeln(Target,LineString);
      Readln(Source,LineString);
      Writeln(Target,LineString);
     end else
     begin
      Writeln(LineString);
      CheckSum:=0;
      Point:=11;
       Repeat
        Inc(CheckSum,Hex2Dec(Copy(LineString,Point,2)));
        Inc(Point,3);
        if point=35 then Inc(Point,3);
       Until Point>=60;
      Writeln (Target,LineString+'  '+Dec2Hex(CheckSum));
     end;
    End;

  Close(Source);
  Close(Target);
 End.





