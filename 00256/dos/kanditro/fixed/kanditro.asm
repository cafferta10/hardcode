; nasm -f bin -o kanditro.com kanditro.asm
; basecode by las
; intro by cce
;
; paljon onnea atomille
; fixed updated version 7 Jun 2015
;   - put in finit to reset FPU stack to fix overflow
;   - the printed string uses attribute 7, not 15
;   - doesn't read garbage values, maybe?

org 100h
temp equ 0x7E00
section .text
_start:
	mov ax, 0x13 
	int 0x10

	; http://webpages.charter.net/danrollins/techhelp/0166.HTM
	;mov ax, 0x1130
	;mov bl, 0x00
	;mov bh, 0x03 ; get addr of ROM 8x8 font
	;int 0x10
	;; cx = height (scan-lines) / bytes per char (from 0040:0085)
	;; DL    screen rows (from 0040:0084)
    ;; ES:BP address of requested font-definition table
	;mov cx, 100

	mov dx, msg
	mov ah, 9 ; print string
	int 0x21

	xor di, di
	mov cx, 320*200
_copyloop:
	push word temp
	push 0xa000
	pop es
	mov ax, [es:di]
	pop es
	stosb ; store ax to es:di
	loop _copyloop	

	push word 0xa000 
	pop es

_mainloop:
	xor di, di
	mov	cx, 320*200
_drawloop:
	;mov [esp], cx
	xor dx, dx ; we divide DX:AX by BX, make sure DX has no garbage
	mov ax, di
	mov bx, 320
	div bx

	mov [xpos], dx ;actually y position!

	finit

	fild word [xpos]
	fidiv word [size]

	fist word [xpos]
	mov dx, [xpos]

	fild word [xpos]
	mov [xpos], ax
	fidiv word [divisor]
	fild word [frame]
	faddp st1, st0
	fsin
	fild word [xpos]

	fild word [frame]
	fidiv word [divisor]
	fcos
	fldpi
	faddp st1, st0
	fdiv

	faddp st1, st0
	fist word [xpos]
	mov ax, [xpos]

	push es
	push temp
	pop es
	push di
	push dx

	; if y < 0 then y = 0
	cmp ax, 0 ; 3
  jnge _silli ; 2
  	; not needed anymore??
	;cmp ax, 64 ; 3
	;jge _silli ; 2
	jmp _salaatti ; 2
_silli:
	xor ax, ax ; 2?
_salaatti:

	mov bx, 320
	mul bx 
	pop dx

	add ax, dx
	mov di, ax ; final pixel offset

	mov ax, [es:di]

	shr ax, 10
	mov bx, [xpos]
	add bx, 33
	mul bx

	pop di
	pop es

	stosb 

loop _drawloop
  inc dword [frame]

	;xor ax, ax ; at the bottom of the screen we always have 
              ; black pixels, so we can assume ax = 0
	; ESC check
	in al, 0x60
	dec ax 
	jnz _mainloop


	mov al, 0x3 ; ah is 0 already due to mainloop exit condition
	int 0x10
ret

    msg  db 13,10,13,10,'   MATERIAALIPISTE-',13,10,'      MENETELM',0x8E,13,10,'      2014-2015', '$'   
	xpos dw 0
	divisor dw 8
	size dw 2
	frame dw 0
