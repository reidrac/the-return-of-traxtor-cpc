.globl _cpc_PutSpXOR

_cpc_PutSpXOR::	; dibujar en pantalla el sprite
	; Entradas	bc-> Alto Ancho
	;			de-> origen
	;			hl-> destino
	; Se alteran hl, bc, de, af

	LD IX,#2
	ADD IX,SP
	LD E,0 (IX)
	LD D,1 (IX)
	LD A,3 (IX)
   	LD L,4 (IX)
	LD H,5 (IX)

    LD (#anchox0+#1),A		;actualizo rutina de captura
	SUB #1
	CPL
	LD (#suma_siguiente_lineax0+#1),A    ;comparten los 2 los mismos valores.

	LD A,2 (IX)
	JP cpc_PutSpXOR0


.globl _cpc_PutSpriteXOR

_cpc_PutSpriteXOR::	; dibujar en pantalla el sprite
		; Entradas	bc-> Alto Ancho
		;			de-> origen
		;			hl-> destino
		; Se alteran hl, bc, de, af
	POP AF
	POP HL
	POP DE
	PUSH AF
	LD A,(HL)		;ANCHO
	INC HL
    LD (#anchox0+#1),A		;ACTUALIZO RUTINA DE CAPTURA
    ;LD (ANCHOT+1),A	;ACTUALIZO RUTINA DE DIBUJO
	SUB #1
	CPL
	LD (#suma_siguiente_lineax0+1),A    ;COMPARTEN LOS 2 LOS MISMOS VALORES.
	LD A,(HL)	;ALTO
	INC HL
	EX DE,HL
	;LD A,(IX+4)
	JP cpc_PutSpXOR0


cpc_PutSpXOR0:
	.DB #0XFD
	LD H,A		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	LD B,#7
anchox0:
loop_alto_2x:
	LD C,#4
loop_ancho_2x:
	LD A,(DE)
	XOR (HL)
	LD (HL),A
	INC DE
	INC HL
	DEC C
	JP NZ,loop_ancho_2x
	.DB #0XFD
	DEC H
	RET Z

suma_siguiente_lineax0:
salto_lineax:
	LD C,#0XFF			;&07F6 			;SALTO LINEA MENOS ANCHO
	ADD HL,BC
	JP NC,loop_alto_2x ;SIG_LINEA_2ZZ		;SI NO DESBORDA VA A LA SIGUIENTE LINEA
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7			;SÓLO SE DARÍA UNA DE CADA 8 VECES EN UN SPRITE
	JP loop_alto_2x

