;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;쿐FNet IRC #Coders 1997 256 byte demo competition entry                     �
;쿞ierpinski Triangle Fractal generator (VGA 320x200x256)                    �
;쿛rogrammer - Sean M. Kelly (nick "codey")                                  �
;쿙otes:                                                                     �
;� This code is optimized for size as opposed to performance as best I could �
;쿶n two evenings. The actual strategy for coding this project has turned out�
;쿿uite different from what I originally projected, having undergone several �
;퀁evisions during the optimization process. The key to successfully cramming�
;퀃his code into under 256 bytes has turned out to be the data layout for the�
;퀆ertices. I have taken some notes in the code, most of which are just notes�
;쿯or various changes in functions, but nothing to really explain well how it�
;퀇orks.                                                                     �
;�                                                                           �
;쿞ierpinski's Triangle:                                                     �
;� Sierpinski's triangle is a fractal figure which in 3-Space occupies an    �
;쿶nfinite volume but 0 surface area. Generating Sierpinski's triangle on a  �
;쿯lat screen requires 3 vertices and a starting vertex (I use vertex 0). The�
;쿯ractal is created by plotting a pixel exactly midway between the starting �
;퀆ertex and one of the 3 randomly selected vertices and this point becomes  �
;퀃he new starting position. The greater the iterations, the finer the       �
;퀁esolution of the fractal. I have used 50,000 iterations per animated frame�
;퀇hich is hopefully not too slow on 486 systems. The random vertex to base  �
;퀃he next plotted point on is the key to this fractal generation. In fact,  �
;쿪fter much research, as yet a series has not been found to generate the    �
;쿞ierpinski Triangle. It's interesting that order might arise from chaos....�
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
.model small
.486

DATASIZE        equ     offset data_end
XRES            equ     320
YRES            equ     200

codesg          segment public  'CODE'
org             100h
start           proc    near
        assume  cs:codesg, ds:datasg, es:nothing
      ; *** Initialization Code ***
        mov     ax, cs                          ; get memory for and setup data segment
        add     ax, 40h
        mov     ds, ax
        mov     word ptr ds:[random], 8405h     ; init random # generator
        mov     word ptr ds:[rv], 3
        push    ds                              ; init VGA shadow
        pop     es
        mov     di, offset shadow
        mov     cx, 32000
        xor     ax, ax
        rep     stosw

        mov     si, offset points               ; init vertices
        mov     di, offset dirs
        mov     cx, 6                           ; 0000000011001101 (205)
        mov     bx, 328                         ; 0000000101001000 (328)
@@:     call    randomAX                        ; set coordinate
        xor     dx, dx
        div     bx
        mov     word ptr ds:[si], ax
        shr     al, 7                           ; set direction
        mov     byte ptr ds:[di], al
        inc     si                              ; next point
        inc     si
        inc     di
;        xor     bx, 0000000110000101b
        loop    @b
        mov     ax, 13h                         ; go to VGA mode
        int     10h
      ; *** Runtime Code ***
        push    0a000h
        pop     es
Runloop:mov     ah, 1                           ; get out if keypressed
        int     16h
        jnz     program_end
        mov     si, offset shadow               ; fade buffer down in intensity (16 bytes)
        mov     cx, 64000
fadebuf:cmp     byte ptr ds:[si], 16
        jbe     @f
        dec     byte ptr ds:[si]
@@:     inc     si
        loop    fadebuf
        xor     si, si                          ; move all points according to direction bits
        mov     di, offset dirs
        mov     cx, 6
        mov     dx, 319
movepointx:
        test    byte ptr ds:[di], 1
        jz      @f
        inc     word ptr ds:[si]
        cmp     word ptr ds:[si], dx
        setb    byte ptr ds:[di]
        jmp     short movepointl
@@:     dec     word ptr ds:[si]
        cmp     word ptr ds:[si], 1
        setb    byte ptr ds:[di]
movepointl:
        inc     si
        inc     si
        inc     di
        xor     dx, 0000000111111000b           ; swap between 319/199 checking
        loop    movepointx
        mov     eax, dword ptr ds:[points]      ; init drawing point
        mov     dword ptr ds:[xd], eax
        mov     cx, 50000                       ; draw new fractal
floop:  mov     ax, 320                         ; plot current drawing point
        mul     word ptr ds:[yd]
        add     ax, word ptr ds:[xd]
        mov     si, ax
        mov     byte ptr ds:[si+offset shadow], 31
        call    randomAX                        ; get a random vertex (0..2)
        shr     al, 7
        shr     ah, 7
        add     al, ah
        xor     ah, ah
        shl     ax, 2
        mov     si, ax                          ; assumes points[x] at org 0
        mov     di, offset xd                   ; adjust coords
        push    cx
        mov     cx, 2
fadjust:mov     ax, word ptr ds:[si]
        mov     bx, word ptr ds:[di]
        cmp     bx, ax
        jbe     @f
        xchg    ax, bx
@@:     mov     dx, bx
        sub     ax, bx
        shr     ax, 1
        add     dx, ax
        mov     word ptr ds:[di], dx
        inc     di
        inc     di
        inc     si
        inc     si
        loop    fadjust
        pop     cx
        loop    floop
        xor     di, di                          ; dump shadow to VGA
        mov     si, offset shadow
        mov     cx, 32000
        rep     movsw
        jmp     runloop                         ; do it again
program_end:
        mov     ax, 3                           ; return to textmode
        int     10h
        ret                                     ; return to MSDOS
randomAX:                                       ; get random # in ax
        mov     ax, word ptr ds:[rv]
        mul     word ptr ds:[random]
        inc     ax
        mov     word ptr ds:[rv], ax
        ret
codeend:
start           endp
codesg          ends

;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;쿾oint structure:                                                           �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
point   struc
        xpos    dw      ?
        ypos    dw      ?
point   ends

;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;쿭ir structure:                                                             �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
dir     struc
        xdir    db      ?       ; bit 0 set=incrementing, else decrementing
        ydir    db      ?       ; bit 0 set=incrementing, else decrementing
dir     ends

;旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
;쿭atasg:                                                                    �
;읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
datasg          segment at      0
org             0
      ; vertices
        points          db      3 * sizeof(point) dup (?)

      ; motion directions
        dirs            db      3 * sizeof(dir) dup (?)

      ; random # generator
        random          dd      ?       ; # used to mul random value
        rv              dd      ?       ; random value (system clock)

      ; current drawing point
        xd              dw      ?
        yd              dw      ?

      ; vga shadow double-buffer
        shadow          db      64000 dup (?)    ; vga shadow
data_end:
datasg          ends

end             start
