
;;; %define FULLSCREEN		

BITS 32
%define origin 0x8048000
ORG origin

ehdr:
				; e_ident
	db 0x7F, "ELF"		;   EI_MAG[0-3]
	db 1			;   EI_CLASS
	db 1			;   EI_DATA
	db 1			;   EI_VERSION

	db 0			;   EI_OSABI
	db 0			;   EI_ABIVERSION
	times 7 db 0		;   EI_PAD
	dw 2			; e_type
	dw 3			; e_machine
	dd 1			; e_version
	dd _start		; e_entry
	dd phdr-origin	 	; e_phoff
 	dd 0			; e_shoff
	dd 0 			; e_flags
	dw ehdrsize		; e_ehsize
	dw phdrsize		; e_phentsize
 	dw 3			; e_phnum
	dw 0			; e_shentsize
	dw 0			; e_shnum
	dw 0			; e_shstrndx

ehdrsize equ $ - ehdr

phdr:
	;; PT_INTERP header
	dd 3			; p_type
	dd interp-origin	; p_offset
	dd interp		; p_vaddr
	dd 0			; p_paddr
	dd interpsize		; p_filesize
 	dd interpsize		; p_memsz
	dd 4 			; p_flags
	dd 0 			; p_align
phdrsize equ $ - phdr

	;; PT_LOAD header
	dd 1			; p_type
	dd 0 			; p_offset
	dd origin		; p_vaddr
	dd 0			; p_paddr
 	dd filesize		; p_filesz
	dd memsize		; p_memsz
	dd 7			; p_flags - 0x1=x, 0x2=w, 0x4=r
	dd 0			; p_align - dangerous, should be 0x1000

	;; PT_DYNAMIC header
	dd 2			; p_type
	dd dynamic-origin	; p_offset
	dd dynamic		; p_vaddr
	dd 0			; p_paddr
	dd dynamicsize		; p_filesize
	dd dynamicsize		; p_memsz
	dd 6			; p_flags
	dd 0			; p_align

interp:
	db "/lib/ld-linux.so.2",0
interpsize equ $-interp

dynstr:
	db 0
libsdl:
;;; 	db "libSDL.so", 0
 	db "libSDL-1.2.so.0",0
libgl:
;;; 	db "libGL.so", 0
	db "libGL.so.1",0

fragment_shader_source:

db "float f(vec3 o){"
db 	"float a=(sin(o.x)+o.y*.25)*.35;"
db 	"o=vec3(cos(a)*o.x-sin(a)*o.y,sin(a)*o.x+cos(a)*o.y,o.z);"
db 	"return dot(cos(o)*cos(o),vec3(1))-1.2;"
db "}"

db "vec3 s(vec3 o,vec3 d){"
db 	"float t=0.,a,b;"
db 	"for(int i=0;i<75;i++){"
db 		"if(f(o+d*t)<0){"
db 			"a=t-.125;b=t;"
db 			"for(int i=0; i<10;i++){"
db 				"t=(a+b)*.5;"
db 				"if(f(o+d*t)<0)b=t;else a=t;"
db 			"}"
db 		"vec3 e=vec3(.1,0,0),"
db 		"p=o+d*t,"
db 		"n=-normalize(vec3(f(p+e),f(p+e.yxy),f(p+e.yyx))+vec3((sin(p*75.)))*.01);"
db 		"return vec3("
db 				"mix( ((max(-dot(n,vec3(.577)),0.) + 0.125*max(-dot(n,vec3(-.707,-.707,0)),0.)))*(mod(length(p.xy)*20.,2.)<1.0?vec3(.71,.85,.25):vec3(.79,.93,.4))"
db 				",vec3(.93,.94,.85),"
db 				"vec3(pow(t/9.,5.))"
db 				")"
db 			");"
db 		"}"
db 		"t+=.125;"
db 	"}"
db 	"return vec3(.93,.94,.85);"
db "}"

db "void main(){"
db 	"float t=dot(gl_Color.xyz,vec3(1,256,65536))*.5;"
db 	"gl_FragColor=vec4(s(vec3(sin(t*1.5)*.5,cos(t)*.5,t), normalize(vec3((gl_FragCoord.xy-vec2(512,384))/vec2(512),1))),1);"
db "}"
db 0 

dynamic:
	dd 1			; DT_NEEDED
	dd libsdl-dynstr
	dd 1
	dd libgl-dynstr
	dd 5			; DT_STRTAB
	dd dynstr
	dd 6			; DT_SYMTAB - needed otherwise segfault
	dd 0
	dd 21			; DT_DEBUG
debug:	dd 0
	dd 0			; DT_NULL
dynamicsize equ $-dynamic



%macro get_dynamic_sections 0
;;; ebx=dynamic address
	mov ecx, 4		;DT_HASH

.section_loop:
	mov esi, ebx		;esi=dynamic address
.entry_loop:
	lodsd			;eax=name
	cmp ecx, eax
	lodsd			;eax=address, flags unaffected
	jne .entry_loop
.found:
	push eax		;address
	
	inc ecx
	cmp ecx, 7
	jne short .section_loop

	pop esi			;symtab address
	pop ebx			;strtab address
	pop ecx			;hash address
%endmacro

	
;;; dodgy version, 3 bytes shorter
%macro calc_hash 0
;;; esi=string address, return=eax
	push ebx

	xor ebx, ebx		;ebx=hash
	xor eax, eax		;clear upper bits
.char_loop:
	;; these 2 lines don't do anything on the first run of the loop
 	imul ebx, ebx, byte 33	;same as ((hash<<5)+hash)?
	xor ebx, eax

	lodsb			;next char
	test al, al		
	jnz short .char_loop	;not 0? carry on
.hash_done:
	mov eax, ebx

	pop ebx
%endmacro

	
%macro find_symbol_in_map 0
;;; ebx=link_map address, edx=hash
	push ebx
	push ecx
	push esi

	mov ebx, [ebx+8]	;ebx=dynamic
	
 	get_dynamic_sections	;macro - now ecx=hash address, esi=symtab address, ebx=strtab address

	mov ecx, [ecx+4]	;num chains
.symbol_loop:
	lodsd			;eax=st_name, esi now points to st_value

	push esi
	lea esi, [ebx+eax]
	calc_hash		;macro
	pop esi

	cmp eax, edx
	lodsd			;eax=st_value, flags unaffected
	je short .got_symbol

	lodsd			;skip 8 bytes to next Elf32_Sym
	lodsd
 	loop .symbol_loop

	xor eax, eax		;not found, so null
.got_symbol:
	pop esi
	pop ecx
	pop ebx
%endmacro


%macro get_symbol 0
;;; edx==hash
 	mov ebx, [debug]
  	mov ebx, [ebx+4]	;ebx==link_map address

.link_map_loop:
	test ebx, ebx
	jz short .done		;link_map address is 0?

	push ebx		;link_map address
	mov ebx, [ebx+4]	;name address
 	mov ebx, [ebx]		;name
 	test bl, bl		;only check first byte of string
	pop ebx			;ebx=link_map address
	jz short .next		;is 0?
.continue:
 	find_symbol_in_map	;macro - ebx=link_map address, edx=hash, eax=returned address
	add eax, [ebx]		;returned address+=link map address
	cmp eax, [ebx]		;compare return address to link map address
.next:
 	mov ebx, [ebx+12]	;ebx=next link_map address - flags unaffected
 	je short .link_map_loop ;if returned address+link map address = link map address then returned address = 0, continue
.done:

%endmacro


	
GL_FRAGMENT_SHADER equ 0x8B30
GL_VERTEX_SHADER equ 0x8B31

%define shader_source_ptr ebp-12
%define shader_type ebp-8
%define shader_program ebp-4

%macro call_next 0
	lodsd
	call eax
%endmacro

%macro create_shader 0
;;; 	mov esi, glCreateShader
	
	push dword GL_FRAGMENT_SHADER
	call_next		;glCreateShader

	push dword fragment_shader_source
	lea ebx, [esp]
	
	push byte 0
	push dword ebx		;adress of adress of shader source
	push byte 1
	push dword eax		;result of glCreateShader
	call_next		;glShaderSource

	call_next		;glCompileShader - shader is on stack

	push dword edi
	call_next		;glAttachShader - stack= program, shader
%endmacro

%macro create_shader_program 0
	;; esi points to glCreateProgram when this macro is run
	call_next		;glCreateProgram
	lea edi, [eax]		;shader program in edi

	create_shader		;macro
	
	call_next		;glLinkProgram - program is on top of stack
	call_next		;glUseProgram - program is on top of stack
%endmacro

_start:
	lea esi, [__import]
  	mov edi, esi
    	mov ecx, __num_imports

.import_symbol_loop:
	lodsd
 	mov edx, eax		;edx=hash
	get_symbol		;macro
	stosd
  	loop .import_symbol_loop


;;; actual start
	lea esi, [SDL_Init]

	push byte 0x20		;SDL_INIT_VIDEO
	call_next		;SDL_Init

%ifdef FULLSCREEN
	push byte 0x0
	call_next
%endif

%ifdef FULLSCREEN
    	push dword (0x00000002 | 0x80000000) ;SDL_OPENGL|SDL_FULLSCREEN
%else
  	push dword 0x02	;SDL_OPENGL
%endif
	push dword 0

 	push dword 768
	push dword 1024

	call_next		;SDL_SetVideoMode

	create_shader_program	;macro

%ifdef FULLSCREEN
	add esp, byte 48
%else
	add esp, byte 44	;20 from SDL_Init and SDL_SetVideoMode, 24 from create_shader_program
%endif

mainloop:
	lea esi, [SDL_GetTicks]	
	call_next		;SDL_GetTicks

	push eax
	push esp
	call_next		;glColor4ubv

	push eax
	push eax
	neg eax
	push eax
	push eax
	call_next		;glRecti

	call_next		;SDL_GL_SwapBuffers

	add esp, byte 24

get_event:	
	push dword sdlevent
	call_next		;SDL_PollEvent
	sub esi, byte 4		;return function pointer to SDL_PollEvent
  	add esp, byte 4		;balance stack
	
	test al, al
	jz short mainloop		;if no event then loop

	mov al, [sdlevent]	;event.type
%ifdef FULLSCREEN
	cmp al, byte 0x2	;SDL_KEYDOWN
%else
	cmp al, byte 0xC
%endif
	jne get_event		;get next event if current is not SDL_KEYDOWN

quit:
%ifdef FULLSCREEN
	push byte 0x1
	call_next
	add esp, 4
%endif
	
	call_next		;SDL_Quit

	xor eax, eax
	inc eax
	int 0x80


%ifdef FULLSCREEN
	__num_imports equ 17
%else
	__num_imports equ 15
%endif

__import:
SDL_Init: dd 0x79ddc09e 	;SDL_Init

%ifdef FULLSCREEN
SDL_ShowCursor: dd 0x7820a72d 	;SDL_ShowCursor
%endif
	
SDL_SetVideoMode: dd 0x8fadcd14 	;SDL_SetVideoMode

glCreateProgram: dd 0x2b84f03b 	;glCreateProgram
	
glCreateShader: dd 0x24cbd546 	;glCreateShader
glShaderSource: dd 0x55e28b7f 	;glShaderSource
glCompileShader: dd 0xf222f3 	;glCompileShader
glAttachShader: dd 0x710d3289 	;glAttachShader
	
glLinkProgram: dd 0x9f9d10bf 	;glLinkProgram
glUseProgram: dd 0x1ab543bc 	;glUseProgram
	
SDL_GetTicks: dd 0x6541c894 	;SDL_GetTicks
glColor4ubv: dd 0x3ea426c3 	;glColor4ubv
	
glRecti: dd 0xbcb016e2 	;glRecti
SDL_GL_SwapBuffers: dd 0xe01bba96 	;SDL_GL_SwapBuffers
SDL_PollEvent: dd 0x723a3b37 	;SDL_PollEvent

%ifdef FULLSCREEN
SDL_ShowCursor2: dd 0x7820a72d 	;SDL_ShowCursor
%endif
	
SDL_Quit: dd 0x79e1ed5d 	;SDL_Quit



filesize equ $ - origin
ABSOLUTE $
	; fake bss

sdlevent:	resb 0x14

memsize equ $ - origin