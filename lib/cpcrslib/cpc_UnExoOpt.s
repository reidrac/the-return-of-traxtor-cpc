; ******************************************************
; **       Librería de rutinas SDCC para Amstrad CPC  **
; **       Raúl Simarro (Artaburu)    -   2009, 2012  **
; ******************************************************


;*************************************
; UNEXO
;*************************************


; Exomizer 2 Z80 decoder
; by Metalbrain
;
; optimized by Antonio Villena
;
; compression algorithm by Magnus Lind

;input: 	hl=compressed data start
;		de=uncompressed destination start
;
;		you may change exo_mapbasebits to point to any free buffer


.globl _cpc_UnExo

_cpc_UnExo::

;	POP AF
;	POP HL	;DESTINATION ADDRESS
;	POP DE	;SPRITE DATA	
;	PUSH AF
	
	LD IX,#2
	ADD IX,SP
	LD e,2 (IX)
	LD d,3 (IX)	;DESTINO
   	LD l,0 (IX)
	LD h,1 (IX)	;TEXTO ORIGEN
		
	di
	call deexo
	ei
	ret

deexo:		
		ld	iy, #exo_mapbasebits
		ld	a,#128
		ld	b,#52
		push	de
exo_initbits:	
		ex	af,af'
		ld	a,b
		sub	#4
		and	#15
		jr	nz,exo_node1
		ld	de,#1		;DE=b2
exo_node1:	
			ld	c,#16
      		ex	af, af'
exo_get4bits:	
		call	exo_getbit
		rl	c
		jr	nc,exo_get4bits
		ld	(iy),c	;bits[i]=b1
		push	hl
		ld	hl,#1
		.db	#210		;3 bytes nop (JP NC)
exo_setbit:	
		add	hl,hl
		dec	c
		jr	nz,exo_setbit
		ld	52 (iy),e
		ld	104 (iy),d	;base[i]=b2
		add	hl,de
		ex	de,hl
		inc	iy
		pop	hl
		djnz	exo_initbits
		inc	c
exo_literalseq:	
		pop	de
exo_literalcopy:
		ldir			;copy literal(s)
exo_mainloop:	
		ld	c,#1
		call	exo_getbit	;literal?
		jr	c,exo_literalcopy
		ld	c,#255
exo_getindex:	
		inc	c
		call	exo_getbit
		jr	nc,exo_getindex
		bit	4,c
		jr	z,exo_continue
      	bit	0, c
		ret	z
		push	de
		ld	d,#16
		call	exo_getbits
		jr	exo_literalseq
exo_continue:	
		push	de
		call	exo_getpair
		push	bc
		pop	ix
		ld	de,#560  ;512+48	;1?
      		inc	b
      		djnz	exo_dontgo
      		dec	c
      		jr	z, exo_goforit
      		dec	c               ;2?
exo_dontgo:	
		ld	de,#1056 ;1024+32
		jr	z,exo_goforit
		ld	e,#16
exo_goforit:	
		call	exo_getbits
      		ex	af, af'
		ld	a,e
		add	a,c
		ld	c,a
      		ex	af, af'
		call	exo_getpair	;bc=offset
		pop	de		;de=destination
		push	hl		
		ld	h,d
		ld	l,e
		sbc	hl,bc		;hl=origin
		push	ix
		pop	bc		;bc=lenght
		ldir
		pop	hl		;Keep HL, DE is updated
		jr	exo_mainloop	;Next!

exo_getpair:	
		ld	iy,#exo_mapbasebits
		ld	b,#0
		add	iy,bc
		ld	d,(iy)
		call	exo_getbits
      		push	hl
      		ld	l, 52 (iy)
      		ld	h, 104 (iy)
      		add	hl, bc          ;Always clear C flag
      		ld	b, h
      		ld	c, l
      		pop	hl
		ret

exo_getbits:	
		ld	bc,#0		;get D bits in BC
exo_gettingbits:
		dec	d
		ret	m
		call	exo_getbit
		rl	c
		rl	b
		jr	exo_gettingbits

exo_getbit:	
			add	a, a		;get one bit
      		ret	nz
      		ld	a, (hl)
      		inc	hl
      		adc	a, a
      		ret

exo_mapbasebits:
			;defs	156	;tables for bits, baseL, baseH
			.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
			.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
			.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
			.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
			.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
			.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
			.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
			.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
			.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
			.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
			.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
			.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
			.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0