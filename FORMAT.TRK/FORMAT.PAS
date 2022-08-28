
var BufferWrite : Array[1..512] of byte;
    BufferRead  : Array[1..512] of byte;


procedure WriteTrack;
 begin
  Fillchar(BufferWrite,512,244);
  asm
   mov ax,seg BufferWrite
   mov es,ax
   mov bx,offset BufferWrite
   mov ah,03
   mov al,1
   mov ch,80
   mov cl,1
   mov dh,1
   mov dl,0
   int 13h
   nop
  end;
 end;

procedure ReadTrack;
 begin
  Fillchar(BufferRead,512,0);
  asm
   mov ax,seg BufferRead
   mov es,ax
   mov bx,offset BufferRead
   mov ah,02
   mov al,1
   mov ch,80
   mov cl,1
   mov dh,1
   mov dl,0
   int 13h
   nop
  end;
 end;




procedure FormTrack(Drive, Cyl, Head: byte);
const
    Opis: array[1..4*18] of byte =
       ( 80, 1,  1, 2,   80, 1,  2, 2,   80, 1,  3, 2,
         80, 1,  4, 2,   80, 1,  5, 2,   80, 1,  6, 2,
         80, 1,  7, 2,   80, 1,  8, 2,   80, 1,  9, 2,
         80, 1, 10, 2,   80, 1, 11, 2,   80, 1, 12, 2,
         80, 1, 13, 2,   80, 1, 14, 2,   80, 1, 15, 2,
         80, 1, 16, 2,   80, 1, 17, 2,   80, 1, 18, 2 );
var
    Powtorzenia: word;
    k: byte;
begin
    Powtorzenia := 15;
    asm
            mov     ah,0
            int     13h
            mov     ax,Powtorzenia   { liczba powtorzen }
    @FORM:  mov     Powtorzenia,ax
            mov     ax, seg Opis
            mov     es,ax
            mov     bx,offset Opis
            mov     ah,5
            mov     al,18       { liczba sect }
            mov     ch,Cyl      { cyl }
            mov     dh,Head     { head }
            mov     dl,Drive    { drive }
            int     13h
            and     ah,80h
            jz      @OKBOY
            mov     ax,Powtorzenia
            dec     ax
            jnz     @FORM
    @OKBOY: mov     ah,0
            int     13h
    end
end;

begin
FormTrack(0,80,1);
{WriteTrack;
ReadTrack;}
WRITELN(BUFFERWRITE[1]);
WRITELN(BUFFERREAD[1]);




end.