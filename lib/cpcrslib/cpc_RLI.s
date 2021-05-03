.globl _cpc_RLI		;rota las líneas que se le digan hacia la izq y mete lo rotado por la derecha.

_cpc_RLI::
	LD IX,#2
	ADD IX,SP
	LD L,0 (IX)
	LD H,1 (IX)	;posición inicial
	LD A,2 (IX)	;lineas
	LD (alto_cpc_RLI+1),A
	LD A,3 (IX)	;ancho
	LD (ancho_cpc_RLI+1),A
	DEC HL
alto_cpc_RLI:
	LD A,#8					;; parametro
ciclo0_cpc_RLI:
	PUSH AF
	PUSH HL
	INC HL
	LD A,(HL)
	LD D,H
	LD E,L
	DEC HL
	LD B, #0
ancho_cpc_RLI:
	LD C,#50	; parametro
	LDDR
	INC HL
	LD (HL),A
	POP HL
	POP AF
	DEC A
	RET Z
	LD BC,#0X800	;salto de línea, ojo salto caracter.
	ADD HL,BC
	JP NC,ciclo0_cpc_RLI ;sig_linea_2zz		;si no desborda va a la siguiente linea
	LD BC,#0XC050
	ADD HL,BC
	JP ciclo0_cpc_RLI

