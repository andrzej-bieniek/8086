uses crt,dos;







 const tekst:string=
{          'Ten komputer zostal zainfekowany najnowszym wirusem HDD KILLER v9.99. '+
          ' W celu otrzymania programu AntyVirusowego trzeba skontaktowac sie ze Szczecinska firma '+
          ' "VIRUSS FOOR JU" pod Czestochowskim numerem telefonu: (032)202-22-03...     '+chr(0);}


          '  Zycze milej pracy...  :>   M$(1999)           '+
	  ' OverCooL & Boo was where...                       '+chr(0);



  var f1 : text;
     x : word;
     b : byte;
     e : integer;

 begin
  assign(f1,'tekst1.inc');
  rewrite(f1);
  b:=1;
  x:=1;
  while b<>0 do
   begin
    asm
     push di
     push ax
     mov di,offset tekst
     add di,x
     mov al,byte ptr [di]
     mov b,al
     pop ax
     pop di
    end;
   writeln(f1,'db ',b xor 66);
   inc(x);
  end;
  close(f1);
  end.

