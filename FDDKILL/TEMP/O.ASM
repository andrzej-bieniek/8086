.model tiny
.data
 moj db 'xxxx'
 n dd 0
.code
 org 100h

 pic:
 nop
 nop
 endpic:

 mov ax,offset (EndPic-pic)
 mov cx,(endpic-pic)
 mov dx,offset moj
 les di,n
 lea bx,moj[si+bx]

 ret
 end pic 

