;Program (CPUID.ASM) napisany przez M$(1998).
;Opis:
;
; Program odczytuje informacje zawarta w procesorze przy pomocy
; instrukcji CPUID.
;
;  Procesor    Informacja
;  INTEL        GENUINEINTEL
;  AMD          AuthenticAMD
;  CYRIX        (uruchamianie w biosie)

.model tiny
.data
 CpuInfo db 12 dup (0)
 db '$'
.code
.386
 org 100h
 Start:
  xor eax,eax
  db 0fh,0a2h                        ; instrukcja procesora pentium - CPUID
  mov dword ptr ds:[CpuInfo[0]],ebx  ; przeslanie danych otrzymanych
  mov dword ptr ds:[CpuInfo[4]],edx  ; z rejestrow 32-bitowych
  mov dword ptr ds:[CpuInfo[8]],ecx  ; EBX, EDX, ECX
  mov ah,09h                         ; wyswietlenie zawartosci rejestrow
  lea dx,CpuInfo
  int 21h
  ret
 End Start



