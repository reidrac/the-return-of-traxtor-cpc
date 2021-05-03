.globl _cpc_PutMaskSp2x8
; imprime un sprite de 8x8 en modo 1
; El formato del sprite es el siguiente por cada línea:
; defb byte1,byte2,byte3,byte4
; siendo byte1 y byte3 son las máscaras de los bytes 2 y 4
; se recibe de entrada el sprite y la posición.
_cpc_PutMaskSp2x8::
	LD IX,#2
	ADD IX,SP
	LD L,2 (IX)
	LD H,3 (IX)
	LD E,0 (IX)
	LD D,1 (IX)
	.DB #0XFD
	LD H,#8		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	LD B,#7
loop_alto_mask_2x8:
	EX DE,HL
	LD A,(DE)	;leo el byte del fondo
	AND (HL)	;lo enmascaro
	INC HL
	OR (HL)		;lo enmascaro
	LD (DE),A	;actualizo el fondo
	INC DE
	INC HL
	;COMO SOLO SON 2 BYTES, es más rápido y económico desplegar la rutina
	LD A,(DE)
	AND (HL)
	INC HL
	OR (HL)
	LD (DE),A
	INC DE
	INC HL
	.DB #0XFD
	DEC H
	RET Z
	EX DE,HL
	LD C,#0XFE
	ADD HL,BC
	JP NC,loop_alto_mask_2x8
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7
	JP loop_alto_mask_2x8

