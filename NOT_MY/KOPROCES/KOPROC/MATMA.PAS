{********************************************************
   Moduˆ zawiera funkcje matematyczne wykorzystuj¥ce
              koprocesor arytmetyczny 80387
 ********************************************************}
{$G+} {generowanie kodu dla procesora 80286}
{$N+E-} {generowanie kodu dla NPU, wyˆ¥czenie emulacji
         koprocesora}
Unit Matma;
Interface
  Function Sin(X:Extended):Extended;
  Function Cos(X:Extended):Extended;
  Procedure SinCos(X:Extended;Var XSin,XCos:Extended);
  Function Tan(X:Extended):Extended;
  Function Ctg(X:Extended):Extended;
  Function ArcTan(X:Extended):Extended;
  Function ArcCtg(X:Extended):Extended;
  Function Log(A,X:Extended):Extended;
  Function Log10(X:Extended):Extended;
  Function Ln(X:Extended):Extended;
  Function Power(X,Y:Extended):Extended;
  Function Exp(Y:Extended):Extended;
Implementation
{Symbol ST(n) oznacza rejestr stosu koprocesora o 
  numerze n np. ST(0)=ST - wierzchoˆek stosu
Operacja "ze stosu" oznacza zwolnienie wierzchoˆka stosu
  koprocesora i zwi©kszenie o 1 wska«nika stosu
Operacja "na stos" oznacza zmniejszenie wska«nika stosu
  koprocesora o 1 i poˆo¾enie na jego wierzchoˆku 
  okre˜lonej liczby}
{Funkcja wyznacza sinus k¥ta X wyra¾onego w radianach}
Function Sin(X:Extended):Extended;Assembler;
Asm
  FLD X           {na stos X}
  DB 217,254      {FSIN - ST(0):=sin(ST(0))}
End;
{Funkcja wyznacza cosinus k¥ta X wyra¾onego w radianach}
Function Cos(X:Extended):Extended;Assembler;
Asm
  FLD X           {na stos X}
  DB 217,255      {FCOS  - ST(0):=cos(ST(0))}
End;
{Procedura wyznacza sinus (XSin) i cosinus (XCos) k¥ta X
wyra¾onego w radianach}
Procedure SinCos(X:Extended;Var XSin,XCos:Extended);
Assembler;
Asm
  FLD X      {na stos X}
  DB 217,251 {FSINCOS -
              Z:=ST(0); ST(0):=sin(Z); na stos cos(Z)}
  LES DI,XCos
  FSTP ES:tbyte ptr [DI] {XCos:=ST(0); ze stosu}
  LES DI,XSin
  FSTP ES:tbyte ptr [DI] {XSin:=ST(0); ze stosu}
End;
{Funkcja wyznacza tangens k¥ta X wyra¾onego w radianach.
X  PI/2 + k*PI, gdzie k jest liczb¥ caˆkowit¥}
Function Tan(X:Extended):Extended;Assembler;
Asm
  FLD X     {na stos X}
  FPTAN     {ST(0):=tg(ST(0)); na stos 1}
  FFREE ST  {zwolnienie ST(0)}
  FINCSTP   {zwi©kszenie o 1 licznika stosu}
End;
{Funkcja wyznacza cotangens k¥ta X wyra¾onego w radianach
wedˆug wzoru:
  ctg(X) = 1/tg(X)
X  k*PI, gdzie k jest liczb¥ caˆkowit¥}
Function Ctg(X:Extended):Extended;Assembler;
Asm
  FLD X         {na stos X}
  FPTAN         {ST(0):=tg(ST(0)); na stos 1}
  FDIV ST,ST(1) {ST(0):=ST(0)/ST(1)}
  FFREE ST(1)   {zwolnienie ST(1)}
End;
{Funkcja wyznacza arcus tangens k¥ta X wyra¾onego w
radianach wedˆug wzoru:
  arctg(X) = arctg(X/1)}
Function ArcTan(X:Extended):Extended;Assembler;
Asm
  FLD X    {na stos X}
  FLD1     {na stos 1}
  FPATAN   {Z:=arctg(ST(1)/ST(0)); ze stosu; ST(0):=Z}
End;
{Funkcja wyznacza arcus cotangens k¥ta X wyra¾onego w
radianach wedˆug wzoru:
  arcctg(X) = arctg(1/X)}
Function ArcCtg(X:Extended):Extended;Assembler;
Asm
  FLD1     {na stos 1}
  FLD X    {na stos X}
  FPATAN   {Z:=arctg(ST(1)/ST(0)); ze stosu; ST(0):=Z}
End;
{Funkcja wyznacza logarytm o podstawie A z X wedˆug wzoru:
  logA(X) = 1/log2(A)*log2(X)
A > 0 i A  1
X > 0}
Function Log(A,X:Extended):Extended;Assembler;
Asm
  FLD1     {na stos 1}
  FLD A    {na stos A}
  FYL2X    {Z:=ST(1)*log2(ST(0)); ze stosu; ST(0):=Z}
  FLD1     {na stos 1}
  FDIVRP ST(1),ST   {ST(1):=ST(0)/ST(1); ze stosu}
  FLD X    {na stos X}
  FYL2X    {Z:=ST(1)*log2(ST(0)); ze stosu; ST(0):=Z}
End;
{Funkcja wyznacza logarytm dziesi©tny z X wedˆug wzoru:
  log(X) = log(2)*log2(X)
X > 0}
Function Log10(X:Extended):Extended;Assembler;
Asm
  FLDLG2   {na stos log(2)}
  FLD X    {na stos X}
  FYL2X    {Z:=ST(1)*log2(ST(0)); ze stosu; ST(0):=Z}
End;
{Funkcja wyznacza logarytm naturalny z X wedˆug wzoru:
  ln(X) = ln(2)*log2(X)
X > 0}
Function Ln(X:Extended):Extended;Assembler;
Asm
  FLDLN2   {na stos ln(2)}
  FLD X    {na stos X}
  FYL2X    {Z:=ST(1)*log2(ST(0)); ze stosu; ST(0):=Z}
End;
{Funkcja podnosi X do pot©gi Y wedˆug wzoru:
  X^^Y = 2^^(Y*log2(X))
X > 0
Pot©ga dw¢jki jest obliczana oddzielnie dla caˆkowitej
(FSCALE) i dla uˆamkowej (F2XM1) cz©˜ci wyra¾enia Y*log2(X).
Nast©pnie obie pot©gi s¥ przez siebie mno¾one}
Function Power(X,Y:Extended):Extended;Assembler;
Asm
  FLD1           {na stos 1}
  FLD Y          {na stos Y}
  FLD X          {na stos X}
  FYL2X          {Z:=ST(1)*log2(ST(0)); ze stosu; ST(0):=Z}
  FST ST(2)      {ST(2):=ST(0)}
  FPREM          {ST(0):=ST(0) mod ST(1)}
  F2XM1          {ST(0):=2^^ST(0)-1}
  FADD ST,ST(1)  {ST(0):=ST(0)+ST(1)}
  FXCH ST(2)     {ST(0)<=>ST(2)}
  FXCH ST(1)     {ST(0)<=>ST(1)}
  FSCALE         {ST(0):=ST(0)*2^^ST(1)}
  FMULP ST(2),ST {ST(2):=ST(2)*ST(0); ze stosu}
  FFREE ST       {zwolnienie ST(0)}
  FINCSTP        {zwi©kszenie licznika stosu}
End;
{Funkcja podnosi e do pot©gi Y wedˆug wzoru:
  e^^Y = 2^^(Y*log2(e))
Pot©ga dw¢jki jest obliczana oddzielnie dla caˆkowitej
(FSCALE) i dla uˆamkowej (F2XM1) cz©˜ci wyra¾enia Y*log2(e).
Nast©pnie obie pot©gi s¥ przez siebie mno¾one}
Function Exp(Y:Extended):Extended;Assembler;
Asm
  FLD1            {na stos 1}
  FLD Y           {na stos Y}
  FLDL2E          {na stos log2(e)}
  FMULP ST(1),ST  {ST(1):=ST(1)*ST(0); ze stosu}
  FST ST(2)       {ST(2):=ST(0)}
  FPREM           {ST(0):=ST(0) mod ST(1)}
  F2XM1           {ST(0):=2^^ST(0)-1}
  FADD ST,ST(1)   {ST(0):=ST(0)+ST(1)}
  FXCH ST(2)      {ST(0)<=>ST(2)}
  FXCH ST(1)      {ST(0)<=>ST(1)}
  FSCALE          {ST(0):=ST(0)*2^^ST(1)}
  FMULP ST(2),ST  {ST(2):=ST(2)*ST(0); ze stosu}
  FFREE ST        {zwolnienie ST(0)}
  FINCSTP         {zwi©kszenie licznika stosu}
End;
End.

