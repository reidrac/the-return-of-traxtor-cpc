.globl _cpc_PutMaskSp4x16

_cpc_PutMaskSp4x16::

	LD IX,#2
	ADD IX,SP
	LD L,2 (IX)
	LD H,3 (IX)
	LD E,0 (IX)
	LD D,1 (IX)
	.DB #0XFD
	LD H,#16
	LD B,#7
loop_alto_mask_4x16:
	EX DE,HL
	LD A,(DE)	;leo el byte del fondo
	AND (HL)	;lo enmascaro
	INC HL
	OR (HL)		;lo enmascaro
	LD (DE),A	;actualizo el fondo
	INC DE
	INC HL
	;COMO SOLO SON 4 BYTES, es más rápido y económico desplegar la rutina
	LD A,(DE)	;leo el byte del fondo
	AND (HL)	;lo enmascaro
	INC HL
	OR (HL)		;lo enmascaro
	LD (DE),A	;actualizo el fondo
	INC DE
	INC HL
	LD A,(DE)	;leo el byte del fondo
	AND (HL)	;lo enmascaro
	INC HL
	OR (HL)		;lo enmascaro
	LD (DE),A	;actualizo el fondo
	INC DE
	INC HL
	LD A,(DE)	;leo el byte del fondo
	AND (HL)	;lo enmascaro
	INC HL
	OR (HL)		;lo enmascaro
	LD (DE),A	;actualizo el fondo
	INC DE
	INC HL
	.DB #0XFD
	DEC H
	RET Z
	EX DE,HL
	LD C,#0XFC
	ADD HL,BC
	JP NC,loop_alto_mask_4x16
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7
	JP loop_alto_mask_4x16

