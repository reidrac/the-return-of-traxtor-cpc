.globl _cpc_RRI
;cpc_RRI(unsigned int pos, unsigned char w, unsigned char h);
_cpc_RRI::
	LD IX,#2
	ADD IX,SP
	LD L,0 (IX)
	LD H,1 (IX)	;posición inicial
	LD A,2 (IX)	;lineas
	LD (alto_cpc_RRI+1),A
	LD A,3 (IX)	;ancho
	LD (ancho_cpc_RRI+1),A
	INC HL
alto_cpc_RRI:
	LD A,#8					;; parametro
ciclo0_cpc_RRI:
	PUSH AF
	PUSH HL
	DEC HL
	LD A,(HL)
	LD D,H
	LD E,L
	INC HL		; SOLO MUEVE 1 BYTE
	LD B, #0
ancho_cpc_RRI:
	LD C,#50	; PARAMETRO
	LDIR
	DEC HL
	LD (HL),A
	POP HL
	POP AF
	DEC A
	RET Z
	LD BC,#0X800	;salto de línea, ojo salto caracter
	ADD HL,BC
	JP NC,ciclo0_cpc_RRI ;sig_linea_2zz		;si no desborda va a la siguiente linea
	LD BC,#0XC050
	ADD HL,BC
	JP ciclo0_cpc_RRI

