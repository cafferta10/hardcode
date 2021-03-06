; Kod napisany przez Piotra Tars�

; Linie zaczynaj�ce si� od �rednika s� komentarzem i nie s� brane pod uwag�
; przy kopilacji

; Program: Bum (wersja dwuwymiarowa - 2W).
; Opis: Program przedstawiaj�cy dziecinnie prosty do wykonania efekt graficz
; ny typu wybuch. Zrobiona przeze mnie wersja tego efektu jest do�� znacznie
; uproszczona (dla wi�kszej czytelno�ci kodu). Program dzia�a w rozdzielczo�
; ci 320x200x256 kolor�w. Korzysta z kernela prze��czaj�cego w tryb 32-bitow
; y autorstwa Miko�aja Feliksa (nie zawar�em tutaj jego kodu, gdy� obja�nien
; ie jego dzia�ania od strony technicznej i zasad pracy procesora (przede ws
; zystkim obliczania adres�w bezwzgl�dnych) w r�nych trybach; u�yty tutaj p
; rzeze mnie 32-bitowy tryb chroniony jest do�� trudny do opanowania, wi�c d
; o��czy�em tylko skompilowany kernel (plik kernel.obj). Pobie�ny opis dw�ch
; najwa�niejszych tryb�w procesora zaj�by kilkana�cie kilobajt�w i nie jest
; potrzebny do zrozumienia dzia�ania poni�szego programu.
; Algorytm: Program dzia�a w p�tli. Na pocz�tku inicjujemy wszystkie punkty:
; ich wsp�rz�dne ustawiamy na (0,0) - aby wybuch zacz�� si� od �rodka ekran
; u, a pr�dko�ci pionowe (vy) i poziome (vx) ustawiamy na losow� warto�� z m
; a�ego przedzia�u. Potem zmniejszamy warto�� koloru. Warto�� ta jest zmniej
; szana z ka�d� klatk� animacji, a wi�c punkty z czasem staj� si� coraz bard
; ziej ciemne. Po doj�ciu do zera kolor si� przekr�ca i ma warto�� 255 (jest
; zmienn� typu bajt, a wi�c b�dzie przekr�ca� si� co 256 klatek animacji). W
; ka�dym powt�rzeniu p�tli sprawdzane jest czy przypadkiem kolor nie przyj��
; warto�ci zero. W takim przypadku punkty s� reinicjowane (dlatego pocz�tkow
; � warto� zmiennej kolor ustawi�em na 1 - aby na pocz�tku zainicjowa� wszys
; tkie punkty). Teraz rysujemy punkty: do wsp�rz�dnych x i y dodajemy korek
; ty odpowiednio x i y, aby wybuch by�o wida� na �rodku ekranu i obliczamy p
; ozycj� piksela w buforze ze wzoru: p = 320*y + x, poniewa� szeroko�� ekran
; u wynosi 320. W tym programie rysowane s� kwadraty 2x2 zamiast pikseli, by
; by�y bardziej widoczne. Wa�ne jest te�, by punkty nie wychodzi�y poza ekra
; n i nie by�y na jego brzegu - w takim przypadku nie rysujemy ich. Po narys
; owaniu punkt�w rozmazujemy obraz (rozmazywanie tutaj polega na zsumowaniu
; pikseli nad, pod, z lewej i z prawej aktualnego piksela i podzielenia wyni
; ku przez 4) i �ciemniamy obraz o 1. Rysowanie odbywa si� ca�y czas na tym
; samym ekranie, dzi�ki czemu wida� tak jakby �lad po ruchu pikseli. Po nary
; sowaniu wszystkich punkt�w przetwarzamy je: do wsp�rz�dnych x i y dodajem
; y odpowiednio pr�dko�ci vx i vy (punkty poruszaj� si� we wszystkie strony)
; , pr�dko�ci spowalniamy mno��c je przez np: 0.95 (aby punkty porusza�y si�
; coraz wolniej) i dodajemy grawitacj� do pr�dko�ci pionowej (vy) - aby punk
; ty te� powoli spada�y w d�. Ca�y proces jest powtarzany dop�ty, dop�ki u�
; ytkownik nie naci�nie klawisza 'Esc' co ko�czy ca�y program.

MAX_P			equ 600 ; ilo�� punkt�w

; Program wykorzystuje interfejs DPMI, a wi�c musi by� zainstalowany w pami�
; ci jaki� DOS extender typu CWSDPMI, EMM386 lub inny. Mo�e te� by� wINDOW$
; 32-bitowy.
.486p
locals

code32 segment para public use32	; u�ywamy segment�w 32-bitowych, a wi�c
	 assume cs:code32, ds:code32	; mamy wszystko w jednym segmencie, tak
						; jak pod wINDOZE

global _main:proc				; potrzebne kernelowi
global code32_base:dword		; zwr�cone przez kernel


dpmi_regs struc				; struktura potrzebna do wywo�a� przerwa
	_edi		dd ?			; � 16-bitowych w trybie 32-bitowym, par
	_esi		dd ?			; ametry przekazywane s� do tej struktur
	_ebp		dd ?			; y, reszt� zajmuje si� DOS extender
	_none1	dd ?
	_ebx		dd ?
	_edx		dd ?
	_ecx		dd ?
	_eax		dd ?
	_flags	dw ?
	_es		dw ?
	_ds		dw ?
	_fs		dw ?
	_gs		dw ?
	_none2	dw ?
	_none3	dw ?
	_sp		dw ?
	_ss		dw ?
ends
losuj proc

	mov	bx,los_pom
	add	bx,9248h
	ror	bx,3
	mov	los_pom,bx
	mov	ax,los_max
	sub	ax,los_min
	mul	bx
	mov	ax,dx
	add	ax,los_min				; ax - liczba losowa
	ret
endp
_main proc
	finit					; inicjujemy koprocesor matematyczny

poczatek:
	; alokujemy 64000 bajt�w pami�ci (na nasz bufor ekranu)
	mov	cx,64000			; rozmiar pami�ci do zaalokowania podaje
	xor	bx,bx				; my w BX:CX
	mov	ax,0501h			; wybieramy funkcj� alokowania pami�ci
	int	31h				; wywo�ujemy host DPMI
	jc	koniec			; jak b��d to kaplica
	shl	ebx,16
	mov	bx,cx
	sub	ebx,code32_base
	mov	ax,si
	shl	eax,16
	mov	ax,di
	mov	uchwyt_bufora,eax		; uchwyt zwracany w SI:DI
	mov	ekran,ebx			; adres bezwzgl�dny BX:CX (ale przerobil
						; i�my go na wzgl�dny, aby mo�na go by�o
						; u�ywa�)

	; czy�cimy nasz bufor ekranu
	mov	edi,ebx
	xor	eax,eax
	mov	ecx,64000/4
	cld
	rep	stosd

	; obliczamy wzgl�dny adres VRAM - pami�� ekranu
	mov	eax,0a0000h
	sub	eax,code32_base
	mov	_a0000h,eax

	; ustaw tryb 13h (graficzny)
	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	mov	[edi._eax],13h
	int	31h

	; podajemy numer koloru od kt�rego zaczynamy (w tym przypadku 0)
	mov	dx,03c8h
	xor	ax,ax
	out	dx,al
	; zwi�kszamy numer portu (podawanie kolor�w), i wysy�amy kolory (skala
	; odcieni szaro�ci). Podajemy sk�adowe R, G, B. Maksymalna warto�� kt�
	; rejkolwiek sk�adowej wynosi 63 (bo wczesne karty graficzne VGA mia�y
	; 6-bitowy przetwornik analogowo-cyfrowy (DAC) i tak pozosta�o, aby pr
	; ogramy by�y kompatybilne z ka�d� kart� graficzn�. Mo�na w��czy� 8-bi
	; towy DAC, ale to jest rzadko u�ywane (w tym programie te� jest u�ywa
	; ny 6-bitowy DAC).
	inc	dx
	; za ka�dym razem ustawiamy 4 jednakowe kolory, zwi�kszamy jasno�� o j
	; eden i tak w k�ko 64 razy
	mov	bx,64
paleta:
	mov	cx,12
paleta_pentla:
	out	dx,al
	loop	paleta_pentla		; loopni�cie, czyli inaczej dec cx \ jnz
	inc	al
	dec	bx
	jnz	paleta

main_loop:					; siedzimy ostro w p�tli dop�ki u�yszkod
						; nik nie naci�nie eskejta
	dec	kolor	
	jnz	jedziemy_dalej

	; inicjujemy punkty
	mov	ecx,MAX_P
	mov	esi,offset punkt_tab
inicjujemy_punkty:
	fldz					; �adujemy zero i ustawiamy nim wsp�rz�
	fst	dword ptr [esi]		; dne punkt�w (wybuch zaczyna si� na �ro
	fstp	dword ptr [esi+4]		; dku ekranu)

	mov	los_max, 12000		; losujemy liczb� z przedzia�u 0...12000
	call	losuj				; , odejmujemy 6000 otrzymuj�c warto�� z
	sub	ax,6000			; przedzia�u -6000...6000, dzielimy prze
	mov	fpom16,ax			; z skal� (700) i ustawiamy ni� pr�dko��
	fild	fpom16			; vx
	fdiv	skala
	fstp	dword ptr [esi+8]

	call	losuj				; to samo co wy�ej dla pr�dko�ci vy
	call	losuj				; dwa razy losuj, bo funkcja losuj jest
	sub	ax,6000			; niedoskona�a
	mov	fpom16,ax
	fild	fpom16
	fdiv	skala
	fstp	dword ptr [esi+12]

	add	esi,16			; przechodzimy do nast�pnego punktu
	dec	ecx				; je�eli jeszcze co� zosta�o to powtarza
	jnz	inicjujemy_punkty		; my p�tl�

jedziemy_dalej:
; zaczynamy wykonywanie punkt�w

	mov	ecx,MAX_P
	mov	esi,offset punkt_tab
	mov	edi,ekran
wykonuj_punkty:
	fld	dword ptr [esi]		; �adujemy wsp�rz�dne punktu, dodajemy
	fadd	korekta_x			; korekty x i y (aby wybuch by� na �rodk
	fistp	word ptr [xe]		; ku ekranu) i zapisujemy je w zmiennych
	fld	dword ptr [esi+4]		; przechowuj�cych wsp�rz�dne ekranowe
	fadd	korekta_y
	fistp	word ptr [ye]

	fld	dword ptr [esi+8]		; �adujemy pr�dko�� vx
	fadd	dword ptr [esi]		; dodajemy do wsp�rz�dnej x
	fstp	dword ptr [esi]		; zapisujemy wynik we wsp�rz�dnej x
	fld	dword ptr [esi+12]	; �adujemy pr�dko�� vy
	fadd	dword ptr [esi+4]		; dodajemy do wsp�rz�dnej y
	fstp	dword ptr [esi+4]		; zapisujemy wynik we wsp�rz�dnej y
	fld	dword ptr [esi+8]		; �adujemy pr�dko�� vx
	fmul	delta_v			; spowalniamy deczko
	fstp	dword ptr [esi+8]		; zapisujemy wynik w pr�dko�ci vx
	fld	dword ptr [esi+12]	; �adujemy pr�dko�� vy
	fmul	delta_v			; spowalniamy deczko
	fadd	grav				; dodajemy grawitacj� (aby sobie spada�y
	fstp	dword ptr [esi+12]	; zapisujemy wynik w pr�dko�ci vy

	cmp	word ptr [xe],0		; sprawdzamy wsp�rz�dne ekranowe
	je	punkt_nastempny		; nie powinny one by� na brzegu ekranu
	cmp	word ptr [ye],0		; (oboj�tne, czy g�rnym, czy lewym, czy
	je	punkt_nastempny		; jakim), ani nie powinny wychodzi� poza
	cmp	word ptr [xe],318		; ekran (logiczne)
	ja	punkt_nastempny
	cmp	word ptr [ye],198
	ja	punkt_nastempny

	xor	eax,eax			; obliczamy pozycj� naszego pikselka w b
	mov	ax,ye				; uforze ekranu ze wzoru: p = 320*y + x,
	shl	ax,6				; stosuj� metod� przesuni�� logicznych,
	mov	bx,ax				; bo jest o wiele szybsza od mno�enia (o
	shl	ax,2				; ptymalizacja)
	add	ax,bx
	add	ax,xe				; mamy nasz� pozycj� p pikselka
	add	eax,edi			; dodajemy adres bufora ekranu
	mov	bl,kolor			; rysujemy kwadracik 2x2 o kolorze podan
	mov	bh,bl				; ym w zmiennej kolor
	mov	[eax],bx
	mov	[eax+320],bx
punkt_nastempny:
	add	esi,16			; przechodzimy do nast�pnego punktu
	dec	ecx				; sprawdzamy czy zosta�y jeszcze punkty
	jnz	wykonuj_punkty		; je�eli tak to powtarzamy p�tl�


; ko�czymy wykonywa� punkty

	; blur start
	mov edi,ekran			; zerujemy (czy�cimy) pierwsz� lini� ekr
	xor eax,eax				; anu
	mov ecx,320/4
	cld
	rep stosd

	mov edx,64000-640			; rozmazujemy ca�y ekran opr�cz pierwsze
	xor ebx,ebx				; j i ostatniej linii
blur_skok:
	mov al,[edi-1]			; bierzemy piksele po lewej, prawej, u g
	mov bl,[edi-320]			; �ry i u do�u, sumujemy je, dzielimy to
	add ax,bx				; przez 4, odejmujemy 1 (�ciemniamy) i z
	mov bl,[edi+1]			; apisujemy
	add ax,bx
	mov bl,[edi+320]
	add ax,bx
	shr ax,2
	jz blur_dalej
	dec al
	mov [edi],al
blur_dalej:
	inc edi
	dec edx
	jnz blur_skok

	xor eax,eax				; zerujemy (czy�cimy) ostatni� lini� ekr
	mov ecx,320/4			; anu
	rep stosd
	; blur end

	; czekamy na od�wie�enie ekranu
	mov	dx,03dah
c1:
	in	al,dx
	test	al,8
	jz	c1
c2:
	in	al,dx
	test	al,8
	jnz	c2

	; wywalamy nasz bufor na ekran
	mov	esi,ekran
	mov	edi,_a0000h
	mov	ecx,64000/4
	cld
	rep	movsd

	; je�eli nie naci�ni�to eskejta to powtarzamy p�telk�
	in	al,60h
	dec	al
	jnz	main_loop

	; zwalniamy pami��
	mov	eax,uchwyt_bufora
	mov	di,ax
	shr	eax,16
	mov	si,ax
	mov	ax,0502h
	int	31h

	; z powrotem tryb tekstowy (03h)
	mov	ax,0300h
	mov	bx,10h
	mov	edi,offset _regs
	mov	[edi._eax],03h
	int	31h
koniec:
	; koniec programu i powr�t do DOS'a
	mov	ah,4Ch
	int	21h

kolor			db 1				; kolor do rysowania pikseli
even
los_min		dw 0				; do losowania: liczba minimalna,
los_max		dw 0				; maksymalna i liczba pomocnicza (
los_pom		dw 1234h			; tak jak zmienna randomseed w pas
fpom16		dw 0				; zczalu)
xe			dw 0				; wsp�rz�dne ekranowe x i y (po k
ye			dw 0				; orekcie)
align 4
_a0000h		dd 0				; adres pami�ci ekranu (dost�p bez
							; po�redni)
ekran			dd 0				; przechowuje adres bufora ekranu
uchwyt_bufora	dd 0				; a ten jego uchwyt (potrzebny do
fpom32		dd 0.0			; p�niejszego zwolnienia pami�ci)
korekta_x		dd 160.0			; korekty wsp�rz�dnych (rysujemy
korekta_y		dd 100.0			; od �rodka ekranu)
delta_v		dd 0.95			; spowolnienie
grav			dd 0.056636246626546456 ; si�a grawitacji
skala			dd 700.0			; do obliczania pr�dko�ci punkt�w
hor_resolution	dd 320.0			; rozdzielczo�� pozioma
_regs			dpmi_regs ?
punkt_tab		dd MAX_P dup(?,?,?,?)	; x,y,vx,vy	(16 bajt�w)
endp
code32 ends
end