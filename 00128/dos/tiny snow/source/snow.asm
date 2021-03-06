;#########################################################################
.386
.model tiny
locals @@
jumps
;#########################################################################
CODESEG
.Startup
	; switch to graphics mode
	mov	al, 013h
	int	10h

	; initialize es to the video buffer
	push	0A000h
	pop	es

	; main loop
@@main:	; wait for vertical sync
	mov	dx, 3DAh
@@vs:	in	al, dx
	test	al, 8
	jz	short @@vs

	; clear the display
	xor	di, di
	xor	ax, ax
	mov	cx, 64000 shr 1
	rep	stosw

	; update position and draw
	mov	si, OFFSET snow
	not	cx
@@upd:	inc	byte ptr [si]
 	cmp	byte ptr [si], 200
	jb	short @@nost
	mov	byte ptr [si], 0
@@nost:	fild	word ptr [si]
	fdiv	[amp]
	fsin
	fmul	[amp]
	fild	word ptr [si+4]
	fadd
	lodsw
	fistp	word ptr [si]
	mov	di, ax
	shl	ax, 8
	shl	di, 6
	add	di, ax
	add	di, [si]
	mov	al, 31
	stosb
	add	si, 4
	loop	short @@upd

	; check for key press
	mov	ah, 001h
	int	16h
	jz	short @@main

	; restore text mode
	mov	al, 003h
	int	10h
	ret
;#########################################################################
	amp	real4	05.0
	snow	db	255*6 dup (?)
;#########################################################################
;#########################################################################
end