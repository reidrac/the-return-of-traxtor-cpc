.globl _cpc_PutSp4x14

_cpc_PutSp4x14::	; dibujar en pantalla el sprite
		; Entradas	bc-> Alto Ancho
		;			de-> origen
		;			hl-> destino
		; Se alteran hl, bc, de, af

	LD IX,#2
	ADD IX,SP
	LD e,0 (IX)
	LD d,1 (IX) ;sprite
   	LD l,2 (IX)
	LD h,3 (IX) ;address
	ld A,#14

pc_PutSp0X:
	.DB #0XFD
	LD H,A		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	LD B,#7
ancho0X:
loop_alto_2_pc_PutSp0X:
	LD C,#4
loop_ancho_2_pc_PutSp0X:
	EX DE,HL
	LDI
	LDI
	LDI
	LDI
	EX DE,HL
	;LD A,(DE)
	;LD (HL),A
	;INC DE
	;INC HL
	;DEC C
	;JP NZ,loop_ancho_2_pc_PutSp0X
	.DB #0XFD
	DEC H
	RET Z

suma_siguiente_linea0X:
salto_linea_pc_PutSp0X:
	LD C,#0XFC			;&07F6 			;SALTO LINEA MENOS ANCHO
	ADD HL,BC
	JP nc,loop_alto_2_pc_PutSp0X ;sig_linea_2zz		;si no desborda va a la siguiente linea
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7			;SÓLO SE DARÍA UNA DE CADA 8 VECES EN UN SPRITE
	JP loop_alto_2_pc_PutSp0X

