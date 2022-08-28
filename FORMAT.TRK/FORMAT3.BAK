
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
   mov ch,81
   mov cl,1
   mov dh,0
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
   mov ch,81
   mov cl,1
   mov dh,0
   mov dl,0
   int 13h
   nop
  end;
 end;




procedure FormTrack(Drive, Cyl, Head: byte);
const
    Opis: array[1..4*18] of byte =
       ( 81, 0,  1, 2,   81, 0,  2, 2,   81, 0,  3, 2,
         81, 0,  4, 2,   81, 0,  5, 2,   81, 0,  6, 2,
         81, 0,  7, 2,   81, 0,  8, 2,   81, 0,  9, 2,
         81, 0, 10, 2,   81, 0, 11, 2,   81, 0, 12, 2,
         81, 0, 13, 2,   81, 0, 14, 2,   81, 0, 15, 2,
         81, 0, 16, 2,   81, 0, 17, 2,   81, 0, 18, 2 );
var
    Powtorzenia: word;
    k: byte;
begin
    Powtorzenia := 15;
    asm
            mov     ah,0
            int     13h
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




procedure FormTrack1(Drive, Cyl, Head: byte);
const
    Opis: array[1..4*18] of byte =
       ( 81, 1,  1, 2,   81, 1,  2, 2,   81, 1,  3, 2,
         81, 1,  4, 2,   81, 1,  5, 2,   81, 1,  6, 2,
         81, 1,  7, 2,   81, 1,  8, 2,   81, 1,  9, 2,
         81, 1, 10, 2,   81, 1, 11, 2,   81, 1, 12, 2,
         81, 1, 13, 2,   81, 1, 14, 2,   81, 1, 15, 2,
         81, 1, 16, 2,   81, 1, 17, 2,   81, 1, 18, 2 );
var
    Powtorzenia: word;
    k: byte;
begin
    Powtorzenia := 15;
    asm
            mov     ah,0
            int     13h
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


procedure FormTrack2(Drive, Cyl, Head: byte);
const
    Opis: array[1..4*18] of byte =
       ( 80, 0,  1, 2,   80, 0,  2, 2,   80, 0,  3, 2,
         80, 0,  4, 2,   80, 0,  5, 2,   80, 0,  6, 2,
         80, 0,  7, 2,   80, 0,  8, 2,   80, 0,  9, 2,
         80, 0, 10, 2,   80, 0, 11, 2,   80, 0, 12, 2,
         80, 0, 13, 2,   80, 0, 14, 2,   80, 0, 15, 2,
         80, 0, 16, 2,   80, 0, 17, 2,   80, 0, 18, 2 );
var
    Powtorzenia: word;
    k: byte;
begin
    Powtorzenia := 15;
    asm
            mov     ah,0
            int     13h
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

procedure FormTrack3(Drive, Cyl, Head: byte);
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

procedure FormTrack4(Drive, Cyl, Head: byte);
const
    Opis: array[1..4*18] of byte =
       ( 82, 0,  1, 2,   82, 0,  2, 2,   82, 0,  3, 2,
         82, 0,  4, 2,   82, 0,  5, 2,   82, 0,  6, 2,
         82, 0,  7, 2,   82, 0,  8, 2,   82, 0,  9, 2,
         82, 0, 10, 2,   82, 0, 11, 2,   82, 0, 12, 2,
         82, 0, 13, 2,   82, 0, 14, 2,   82, 0, 15, 2,
         82, 0, 16, 2,   82, 0, 17, 2,   82, 0, 18, 2 );
var
    Powtorzenia: word;
    k: byte;
begin
    Powtorzenia := 15;
    asm
            mov     ah,0
            int     13h
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

procedure FormTrack5(Drive, Cyl, Head: byte);
const
    Opis: array[1..4*18] of byte =
       ( 82, 1,  1, 2,   82, 1,  2, 2,   82, 1,  3, 2,
         82, 1,  4, 2,   82, 1,  5, 2,   82, 1,  6, 2,
         82, 1,  7, 2,   82, 1,  8, 2,   82, 1,  9, 2,
         82, 1, 10, 2,   82, 1, 11, 2,   82, 1, 12, 2,
         82, 1, 13, 2,   82, 1, 14, 2,   82, 1, 15, 2,
         82, 1, 16, 2,   82, 1, 17, 2,   82, 1, 18, 2 );
var
    Powtorzenia: word;
    k: byte;
begin
    Powtorzenia := 15;
    asm
            mov     ah,0
            int     13h
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
FormTrack4(0,82,0);
FormTrack5(0,82,1);

FormTrack(0,81,0);
FormTrack1(0,81,1);

FormTrack2(0,80,0);
FormTrack3(0,80,1);




WriteTrack;
ReadTrack;
WRITELN(BUFFERWRITE[1]);
WRITELN(BUFFERREAD[1]);




end.