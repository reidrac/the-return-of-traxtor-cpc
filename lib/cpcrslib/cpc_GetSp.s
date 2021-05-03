.globl _cpc_GetSp

_cpc_GetSp::

	LD IX,#2
	ADD IX,SP
	LD E,0 (IX)
	LD D,1 (IX)
	LD A,3 (IX)
   	LD L,4 (IX)
	LD H,5 (IX)



	LD (#loop_alto_2x_GetSp0+1),A


	SUB #1
	CPL
	LD (#salto_lineax_GetSp0+1),A    ;comparten los 2 los mismos valores.

	LD A,2 (IX)
	;JP cpc_GetSp0

cpc_GetSp0::
	.DB #0XFD
	LD H,A		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	LD B,#7
loop_alto_2x_GetSp0:
	LD C,#0
loop_ancho_2x_GetSp0:
	LD A,(HL)
	LD (DE),A
	INC DE
	INC HL
	DEC C
	JP NZ,loop_ancho_2x_GetSp0
	.DB #0XFD
	DEC H
	RET Z
salto_lineax_GetSp0:
	LD C,#0XFF					;salto linea menos ancho
	ADD HL,BC
	JP NC,loop_alto_2x_GetSp0 	;sig_linea_2zz		;si no desborda va a la siguiente linea
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7						;sólo se daría una de cada 8 veces en un sprite
	JP loop_alto_2x_GetSp0

