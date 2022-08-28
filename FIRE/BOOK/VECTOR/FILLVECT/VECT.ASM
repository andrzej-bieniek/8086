DSTACK SEGMENT STACK 'STACK' use16
        db 64 dup('STACK    ');
DSTACK ENDS     
.386C
ASSUME cs:CODE,ss:DSTACK

CODE SEGMENT use16
lines   dw 200 dup(0)
INCLUDE DATAFILL.ASM         ;Plik ze zmiennymi dla 
                             ;procedury rysujÜcej tr¢jkÜt 

iler    equ     8
zm      dw 0    ;Pomoc
petla   dw 0    ;Do sortowania
X1      dw 0    ;x1,y1,x2,y2,x3,y3,wzor - tr¢jkat
Y1      dw 0
X2      dw 0
Y2      dw 0
X3      dw 0
Y3      dw 0
wzor    dw 0
adjust  dw 16384        
SegOfScreen dw 1024+0a000h

;*********** PARAMETRY BRYúY ***************
ile_scia dw 256 ;ile scian      
ile_pix  dw 128 ;ile punktow 

;*********** PARAMETRY OBROT£W *************
katx    dw 66   ;kat wokol X
katy    dw 0   ;Y
katz    dw 44  ;Z
strona  dw 0
xo      dw      0
yo      dw      0
zo      dw      0
;*********** Parametry perspektywy *********
Zv      dw -120*256
Zv1     dw -120
xv      dw      0
yv      dw      0

;*********** Przesuniëcie ******************  
d_Z     dw ?
d_x     dw 160
d_y     dw 100

sin     dw      0
cos     dw      0
sort1   dw      0
sort2   dw      0

adju    dw 16384,0      ;Tablica zmiennosci strona
stro    dw 0,16384      ;i adjust
sos     dw 1024+0a000h,0a000h

Start:
        ;*** Shrink ***
        mov     ah,4ah
        mov     bx,0ffffh
        int     21h
        ;Czy wystarczy pamiëci na SIN i COS?
        cmp     bx,15000
        jae     Ok_mem
        jmp     END_of_prog
Ok_mem:         
        mov     bx,15000
        mov     ah,4ah
        int     21h
        jnc     hend
        mov     ax,3
        int     10h
        ;***************
hend:   
        call    Allocate        ;Rezerwacja pamiëci
        call    LoadCosin       ;Czytaj SINUS i COSINUS
        call    Initialize      ;Tryb graficzny
        call    ChangeSciany    ;przelicz sciany
        call    InitLines       ;Policz offsety linii
MAIN:
        call    Move            ;przenies z PIX do TAB
        call    RotateX         ;Obr¢ç wok¢í osi X      
        call    Perspective     ;Przelicz perspektywë
        call    Draw        
        call    Zmien           ;Zmie§ strronë
        call    Show            ;i pokarz aktualnÜ
        call    Zkaty                   
        mov     ah,01h
        int     16h
        jz      MAIN
        call    Free
End_of_prog:
        mov     ax,3h
        int     10h        
        mov     ax,4c01h
        int     21h
;**************************************
Opoz PROC
        mov     dx,3dah
wai:
        in      al,dx
        test    al,8
        jne     wai
wai1:
        in      al,dx
        test    al,8
        je      wai1    
        ret
        ENDP            
;******** Zmie§ stronë ****************
Zmien PROC      
        mov     ax,cs:[stro]
        mov     strona,ax
        mov     bx,cs:[stro+2]
        mov     cs:[stro],bx
        mov     cs:[stro+2],ax
        
        mov     ax,cs:[Adju]
        mov     adjust,ax
        mov     bx,cs:[adju+2]
        mov     cs:[adju],bx
        mov     cs:[adju+2],ax

        mov     ax,cs:[sos]
        mov     SegOfScreen,ax
        mov     bx,cs:[sos+2]
        mov     cs:[sos],bx
        mov     cs:[sos+2],ax
        
        ret
        ENDP
;************** Pokaß stronë **********
Show PROC
        mov     bx,strona
        mov     dx,3d4h
        mov     al,12
        mov     ah,bh
        out     dx,ax
        inc     al
        mov     ah,bl
        out     dx,ax
        call    Opoz
        ;Kasuj stary rysunek
        mov     dx,0a000h
        mov     es,dx
        mov     di,adjust
        mov     dx,3c4h
        mov     ax,0f02h
        out     dx,ax
        mov     eax,0
        rept 4000
          stosd
        endm    
        ret
        ENDP
;************* Licz perspektywë ****************
Perspective PROC        
        push    cs
        push    cs
        pop     ds
        pop     es
        lea     si,tab
        lea     di,ekr
        mov     cx,ile_pix
Per:
        push    cx
        mov     cx,8
        mov     ax,Zv
        mov     bx,ds:[si][4]
        sub     bx,Zv1
        xor     dx,dx
        idiv    bx
        mov     bp,ax
        ;--X--
        mov     bx,xv
        lodsw
        sub     bx,ax
        mov     ax,bx
        imul    bp
        sar     ax,cl
        add     ax,d_x
        add     ax,xv
        stosw
        ;--Y--
        mov     bx,yv
        lodsw
        sub     bx,ax
        mov     ax,bx
        imul    bp
        sar     ax,cl
        add     ax,d_y
        add     ax,yv
        stosw
        
        add     si,2
        pop     cx
        loop    Per
        ret
        ENDP
;************ Rysuj bryíë *************
Draw    PROC
        push    cs
        pop     es
        lea     di,Kolej[2]
        mov     cx,ile_scia
        sub     ax,ax
        ;Czyûç tablicë kolejnoûci
Dwyp:
        stosw
        inc     ax
        loop    Dwyp    
        ;---Suma Z---
        mov     cx,ile_scia     
        lea     si,tab
        lea     di,S_tab   
        lea     bp,ArrZ
Licz_sumZ:
        mov     bx,cs:[di]
        mov     ax,cs:[si][bx][4]
        
        mov     bx,cs:[di+2]
        add     ax,cs:[si][bx][4]
        
        mov     bx,cs:[di+4]
        add     ax,cs:[si][bx][4]
        
        mov     cs:[bp],ax
        add     bp,2
        add     di,6
        loop    Licz_sumZ
        ;---Sort---
        call    QuickSort
        ;---Draw---
        mov     cx,ile_scia
        lea     si,kolej[2]
        lea     di,ekr
DrawTrian:
        mov     bx,cs:[si]
        shl     bx,1
        shl     bx,1
        shl     bx,1
        mov     bp,cs:S_ekr[bx] 
        mov     ax,cs:[di][bp]
        mov     x1,ax
        mov     ax,cs:[di][bp][2]
        mov     y1,ax
        
        mov     bp,cs:S_ekr[bx+2]
        mov     ax,cs:[di][bp]
        mov     x2,ax
        mov     ax,cs:[di][bp][2]
        mov     y2,ax

        mov     bp,cs:S_ekr[bx+4]
        mov     ax,cs:[di][bp]
        mov     x3,ax
        mov     ax,cs:[di][bp][2]
        mov     y3,ax
        
        mov     ax,cs:S_ekr[bx+6]  
        mov     wzor,ax            
        ;***************
        push    si
        push    di
        push    cx
        call    Trian
        pop     cx
        pop     di
        pop     si
        ;***************
        add     si,2
        loop    DrawTrian
        
                
        mov     dx,3c4h
        mov     ax,0f02h
        out     dx,ax
        ret
        ENDP
;************************************************************
RotateX PROC
        mov     dx,COS
        mov     ds,dx
        mov     dx,SIN
        mov     es,dx
        mov     bp,katx
        mov     cl,9
        shl     bp,cl
        mov     cx,ile_pix
        lea     si,tab
Rotx:
        ;Czytaj Y
        push    cx
        mov     cl,iler
        mov     bx,cs:[si+2]
        add     bx,127
        sub     bx,yo
        shl     bx,1
        add     bx,bp
        ;Czytaj Z
        mov     di,cs:[si+4]
        add     di,127
        sub     di,zo
        shl     di,1
        add     di,bp
        ;licz Y * cos + Z * sin
        mov     ax,ds:[bx]
        add     ax,es:[di]
        ;licz Z * cos - Y * sin
        mov     dx,ds:[di]
        sub     dx,es:[bx]
        ;przelicz na wsp¢írzëdne rzeczywiste
        sar     dx,cl
        sar     ax,cl
        
        add     ax,yo
        add     dx,zo
        mov     cs:[si+2],ax
        mov     cs:[si+4],dx
        
        add     si,6
        pop     cx      
        loop    RotX
        ret
        ENDP    
;************************************************************
;----------------Przenieû z PIX do TAB-----------------------
;Obroty wykonywane sÜ w oparciu o tablicë TAB
;************************************************************
Move    PROC
        push    cs
        pop     es
        lea     di,tab
        mov     dx,DATA
        mov     ds,dx
        lea     si,pix
        mov     cx,ile_pix
        mov     bx,cx
        add     cx,bx
        add     cx,bx
        cld
        rep     movsw
        ret
        ENDP
;**************************************
;Przelicz tablicë íÜcznik¢w
;**************************************
ChangeSciany PROC
        push    cs
        pop     es
        lea     di,S_ekr
        mov     dx,DATA
        mov     ds,dx
        lea     si,scia
        mov     cx,ile_scia
;Dla tablicy EKR wszystko * 4 (oprocz koloru), bo EKR = dw (x,y),(x,y),(x,y)
Change1:
        lodsw
        shl     ax,1
        shl     ax,1
        stosw

        lodsw
        shl     ax,1
        shl     ax,1
        stosw

        lodsw
        shl     ax,1
        shl     ax,1
        stosw

        lodsw
        stosw

        loop    Change1
        
        lea     si,scia
        mov     cx,ile_scia
        mov     dx,DATA
        mov     ds,dx
        lea     di,S_tab
Change2:
        lodsw
        mov     bx,ax
        add     ax,ax
        add     ax,ax
        add     ax,bx
        add     ax,bx
        mov     cs:[di],ax
        lodsw
        mov     bx,ax
        add     ax,ax
        add     ax,ax
        add     ax,bx
        add     ax,bx
        mov     cs:[di+2],ax
        lodsw
        mov     bx,ax
        add     ax,ax
        add     ax,ax
        add     ax,bx
        add     ax,bx
        mov     cs:[di+4],ax
        add     si,2
        add     di,6
        loop    Change2 
        ret
        ENDP
;-------------Zkaty---------
Zkaty PROC
        add     katx,1
        cmp     katx,91
        jb      okx
        mov     katx,1
okx:
        add     katy,1
        cmp     katy,91
        jb      oky
        mov     katy,1
oky:
        add     katz,1
        cmp     katz,91
        jb      okz
        mov     katz,1
okz:
        ret
        ENDP                                                                                                                        
;************************************************************
p       dw      0
ps      dw      0
ii      dw      0
jj      dw      0
i       dw      0
j       dw      0
r       dw      0
l       dw      0
x       dw      0
QuickSort PROC  
        mov     ps,1
        mov     dx,SORT1
        mov     ds,dx
        mov     dx,SORT2
        mov     es,dx
        mov     word ptr ds:[2],1
        mov     dx,ile_Scia
        mov     es:[2],dx
        lea     si,Kolej
        lea     di,ArrZ
_4030:
        cmp     ps,0
        jne     okps
        jmp     _4110
okps:
;*4035
        mov     bx,ps
        shl     bx,1
        mov     dx,ds:[bx]
        mov     ii,dx
        mov     dx,es:[bx]
        mov     jj,dx
        dec     ps
_4040:
        mov     p,0
        mov     dx,ii
        mov     i,dx
        mov     dx,jj
        mov     j,dx
_4045:
        mov     bx,i
        shl     bx,1
        mov     bx,cs:[si][bx]
        shl     bx,1
        mov     bx,cs:[di][bx]
        
        mov     bp,j
        shl     bp,1
        mov     bp,cs:[si][bp]
        shl     bp,1
        mov     bp,cs:[di][bp]
        
        cmp     bx,bp
        jge     _4060
;*4050  
        mov     dx,1
        sub     dx,p
        mov     p,dx
;*4055  
        mov     bx,i
        shl     bx,1
        mov     dx,cs:[si][bx]
        mov     bp,j
        shl     bp,1
        mov     ax,cs:[si][bp]
        mov     cs:[si][bx],ax
        mov     cs:[si][bp],dx
_4060:
        cmp     p,0
        jne     Noii1
        inc     i
Noii1:
;*4065
        cmp     p,1
        jne     Nojj1
        dec     j
Nojj1:
;*4070                  
        mov     dx,i
        cmp     dx,j
        jb      _4045
;*4075  
        mov     dx,i
        cmp     dx,jj
        jae     _4095
;*4080  
        inc     ps
;*4090  
        mov     bx,ps
        shl     bx,1
        mov     dx,i
        inc     dx
        mov     ds:[bx],dx
        mov     dx,jj
        mov     es:[bx],dx
_4095:          
        mov     dx,i
        dec     dx
        mov     jj,dx
;*4100
        mov     dx,jj
        cmp     dx,ii
        jbe     No4040
        jmp     _4040
No4040:
;*4105
        jmp     _4030
_4110:
        ret                     
        ENDP
        
;***************************************
;Policz offsety linii
;***************************************
InitLines PROC
        lea     si,Lines
        mov     ax,0
        mov     cx,200
IL:
        mov     cs:[si],ax
        add     si,2
        add     ax,80
        loop    Il
        ret
        ENDP                    
        
;*******************************************************
sind    db      'sinus.dat',0
cosd    db      'cosinus.dat',0
Erro    db      'Loading error.',13,10,'$'
LoadCosin PROC
        mov     ax,3d00h
        push    cs
        pop     ds
        lea     dx,sind
        int     21h
        jc      Error
        mov     bx,ax
        mov     ah,3fh
        mov     cx,49152
        mov     dx,SIN
        mov     ds,dx
        mov     dx,0
        int     21h
        jc      Error
        mov     ah,3eh
        int     21h
        mov     ax,3d00h
        push    cs
        pop     ds
        lea     dx,cosd
        int     21h
        jc      Error
        mov     bx,ax
        mov     ah,3fh
        mov     dx,COS
        mov     ds,dx
        mov     dx,0
        mov     cx,49152
        int     21h
        jc      Error
        mov     ah,3eh
        int     21h
        ret
Error:
        push    cs
        pop     ds
        lea     dx,Erro
        mov     ah,09h
        int     21h
        mov     ax,4c01h
        int     21h             
        ENDP            
;******************************************
Erro1   db      'Error allocating memory.',13,10,'$'
Allocate PROC
        mov     ah,58h
        mov     al,0
        mov     bl,1
        int     21h
        
        mov     ah,48h
        mov     bx,3125
        int     21h
        jc      Error1
        mov     sin,ax
        
        mov     ah,48h
        mov     bx,3125
        int     21h
        jc      Error1
        mov     cos,ax

        mov     ah,48h
        mov     bx,4000
        int     21h
        jc      Error1
        mov     SORT1,ax

        mov     ah,48h
        mov     bx,4000
        int     21h
        jc      Error1
        mov     SORT2,ax
        
        ret
Error1:
        push    cs
        pop     ds
        lea     dx,Erro1
        mov     ah,09h
        int     21h
        mov     ax,4c01h
        int     21h
        ENDP
        
Free PROC               
        mov     ah,49h
        mov     es,sin
        int     21h
        mov     ah,49h
        mov     es,cos
        int     21h
        mov     ah,49h
        mov     es,sort2
        int     21h
        mov     ah,49h
        mov     es,sort1
        int     21h
        ret
        ENDP
;************************************************************
Initialize PROC
        INCLUDE INITALIZE.ASM
           ENDP
           
include trian.asm

tab     dw 1500 dup(?,?,?)
ekr     dw 1500 dup(?,?)
S_ekr   dw 1500 dup(?,?,?,?)
S_tab   dw 1500 dup(?,?,?)
kolej   dw 1500 dup(?)
arrZ    dw 1500 dup(?)   
;------------------------------------------------------------

CODE ENDS

DATA SEGMENT use16

include bryla.asm     ;Plik z opisem bryíy (przykíad takiego pliku znajduje sië na dyskietce)
 
DATA ENDS

END Start
