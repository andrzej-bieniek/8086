@echo off
set file=pex_main
set dir=e:\dev\toolz\pex

e:\dev\masm\bin\ml.exe /c /coff /Zi /Cp /Fl /Sc /Sg %file%.asm
 e:\dev\masm\bin\link.exe /SECTION:.text,RWE /SUBSYSTEM:WINDOWS,4.0 /DEBUG /DEBUGTYPE:CV %file%.obj %file%.res
  if errorlevel 1 goto End
   del %file%.OBJ
    del %file%.LST
      copy %dir%\goat_files\*.* %dir%\*.exe
:End
 pause
 cls