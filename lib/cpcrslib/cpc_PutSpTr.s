.globl _cpc_PutSpTr

_cpc_PutSpTr::	; dibujar en pantalla el sprite
		; Entradas	bc-> Alto Ancho
		;			de-> origen
		;			hl-> destino
		; Se alteran hl, bc, de, af
	LD IX,#2
	ADD IX,SP
	LD E,0 (IX)
	LD D,1 (IX)
	LD A,4 (IX)
   	LD L,6 (IX)
	LD H,7 (IX)


    LD (#anchot+1),A	;actualizo rutina de dibujo
	SUB #1
	CPL
	LD (#suma_siguiente_lineat+1),A    ;comparten los 2 los mismos valores.

	LD A,2 (IX)
	;JP  cpc_PutSpTr0

cpc_PutSpTr0:
	.DB #0XFD
	LD H,A		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
anchot:
loop_alto_2t:
	LD B,#0
loop_ancho_2t:
	LD A,(DE)
	AND #0XAA
	JP Z,sig_pixn_der_2
	LD C,A ;B es el único registro libre
	LD A,(HL) ;pixel actual donde pinto
	AND #0X55
	OR C
	LD (HL),A ;y lo pone en pantalla
sig_pixn_der_2:
	LD A,(DE) ;pixel del sprite
	AND #0X55
	JP Z,pon_buffer_der_2
	LD C,A ;B es el único registro libre
	LD A,(HL) ;PIXEL ACTUAL DONDE PINTO
	AND #0XAA
	OR C
	LD (HL),A
pon_buffer_der_2:
	INC DE
	INC HL
	DEC B
	JP NZ,loop_ancho_2t
	.DB #0XFD
	DEC H
	RET Z
suma_siguiente_lineat:
salto_lineat:
	LD BC,#0X07FF			;&07f6 			;salto linea menos ancho
	ADD HL,BC
	JP NC,loop_alto_2t ;sig_linea_2zz		;si no desborda va a la siguiente linea
	LD BC,#0XC050
	ADD HL,BC
	;ld b,7			;sólo se daría una de cada 8 veces en un sprite
	JP loop_alto_2t

	LD A,H
	ADD #0X08
	LD H,A
	SUB #0XC0
	JP NC,loop_alto_2t ;sig_linea_2
	LD BC,#0XC050
	ADD HL,BC
	JP loop_alto_2t

