;void  						cpc_PutMaskSprite(int *sprite, int *posicion);
;void    					cpc_PutMaskSp(int *sprite, char alto, char ancho, int *posicion);
.globl _cpc_PutMaskSp

_cpc_PutMaskSp::	; dibujar en pantalla el sprite
		; Entradas	bc-> Alto Ancho
		;			de-> origen
		;			hl-> destino
		; Se alteran hl, bc, de, af

	LD IX,#2
	ADD IX,SP
	LD L,4 (IX)
	LD H,5 (IX)
	LD A,3 (IX)
   	LD E,0 (IX)
	LD D,1 (IX)
    ld (#loop_alto_2m_PutMaskSp0+#1),a		;actualizo rutina de captura
	SUB #1
	CPL
	LD (#salto_lineam_PutMaskSp0+#1),A    ;comparten los 2 los mismos valores.
	ld A,2(IX)
	;JP cpc_PutMaskSp0

cpc_PutMaskSp0:
	.DB #0XFD
	LD H,A		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	LD B,#7
loop_alto_2m_PutMaskSp0:
	LD C,#4
	EX DE,HL
loop_ancho_2m_PutMaskSp0:
	LD A,(DE)	;LEO EL BYTE DEL FONDO
	AND (HL)	;LO ENMASCARO
	INC HL
	OR (HL)		;LO ENMASCARO
	LD (DE),A	;ACTUALIZO EL FONDO
	INC DE
	INC HL
	DEC C
	JP NZ,loop_ancho_2m_PutMaskSp0
	.DB #0XFD
	DEC H
	RET Z
	EX DE,HL
salto_lineam_PutMaskSp0:
	LD C,#0XFF
	ADD HL,BC
	JP nc,loop_alto_2m_PutMaskSp0
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7
	JP loop_alto_2m_PutMaskSp0

.globl _cpc_PutMaskSprite

_cpc_PutMaskSprite::	; dibujar en pantalla el sprite
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
    ld (#loop_alto_2m_PutMaskSp0+#1),a		;ACTUALIZO RUTINA DE CAPTURA
    ;LD (ANCHOT+1),A	;ACTUALIZO RUTINA DE DIBUJO
	SUB #1
	CPL
	LD (#salto_lineam_PutMaskSp0+#1),A    ;COMPARTEN LOS 2 LOS MISMOS VALORES.
	LD A,(HL)	;ALTO
	INC HL
	EX DE,HL
	jp cpc_PutMaskSp0


