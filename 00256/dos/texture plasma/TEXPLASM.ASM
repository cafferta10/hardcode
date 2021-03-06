.MODEL tiny
.486
.CODE
ORG 100h
PLASM1 equ 09000h
PLASM2 equ 08000h
TEX    equ 07000h
START:               jmp      begin
                     db 'aardbei', 1ah
begin:               mov      al, 13h
                     int      10h
                     nop
                     push     ds
                     mov      di, offset sintab
calcsin:             fldpi
                     fimul [angle]
                     fidiv [_128]
                     fcos
                     fimul [muller]
                     fistp word ptr [di]
                     inc   di
                     dec [angle]
                     jnz calcsin
                     mov      ax, TEX
                     mov      es, ax
                     mov      cx, 65535
texgenloop:          mov      al, ch
                     xor      al, cl
                     stosb
                     loop     texgenloop
MAINLOOP:            pop      ds
                     push     ds
                     add      dword ptr [t1], 01020301h
                     mov      dx, 3dah
                l1:  in       al, dx
                     and      al, 8
                     jnz      l1
                l2:  in       al, dx
                     and      al, 8
                     jz       l2
                     lea      bx, sintab
                     mov      al, [t3]
                     xlat
                     mov      [t5], al
                     mov      al, [t2]
                     xlat
                     mov      [t4], al
                     mov      ax, PLASM1
                     mov      es, ax
                     xor      di, di
                     mov      dx, 200
plasm1vert:          mov      cx, 320
plasm1hor:           mov      al, cl
                     add      al, [t1]
                     xlat
                     mov      ah, al
                     mov      al, dl
                     add      al, [t2]
                     xlat
                     add      al, ah
                     stosb
                     loop     plasm1hor
                     dec      dx
                     jnz      plasm1vert
                     mov      ax, PLASM2
                     mov      es, ax
                     xor      di, di
                     mov      dl, 200
plasm2vert:          mov      cx, 320
plasm2hor:           mov      al, cl
                     add      al, [t3]
                     xlat
                     mov      ah, al
                     mov      al, dl
                     add      al, [t4]
                     add      al, [t5]
                     xlat
                     add      al, ah
                     stosb
                     loop     plasm2hor
                     dec      dx
                     jnz      plasm2vert
                     mov      ax, 0a000h
                     mov      es, ax
                     sub      ah, 10h
                     mov      fs, ax
                     sub      ah, 10h
                     mov      gs, ax
                     sub      ah, 10h
                     mov      ds, ax
                     xor      di, di
                     mov      dx, 200
wobvert:             mov      cx, 320
wobbler:             mov      bl, fs:[di]
                     add      bl, cl
                     mov      bh, gs:[di]
                     add      bh, dl
                     mov      al, ds:[bx]
                     stosb
                     loop     wobbler
                     dec      dx
                     jnz      wobvert
                     in       al, 60h
                     cmp      al, 1
                     jne      MAINLOOP
                     mov      ax, 3h
                     int      10h
                     int      20h
muller dw 32
_128   dw 128
angle  dw 256
sintab db 256 dup (?)
t1  db ?
t2  db ?
t3  db ?
t4  db ?
t5  db ?
org 1ffh
db 1
END START
