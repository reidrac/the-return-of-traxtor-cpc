.globl _cpc_GetScrAddress

_cpc_GetScrAddress::

;	LD IX,#2
;	ADD IX,SP
;	LD A,0 (IX)
;	LD L,1 (IX)	;pantalla


	LD HL,#2
    ADD HL,SP
	LD A,(HL)
	INC HL
	LD L,(HL)
	;LD L,E
	;JP cpc_GetScrAddress0


cpc_GetScrAddress0:			;en HL están las coordenadas

	;LD A,H
	LD (#inc_ancho+1),A
	LD A,L
	SRL A
	SRL A
	SRL A
	; A indica el bloque a multiplicar x &50
	LD D,A						;D
	SLA A
	SLA A
	SLA A
	SUB L
	NEG
	; A indica el desplazamiento a multiplicar x &800
	LD E,A						;E
	LD L,D
	LD H,#0
	ADD HL,HL
	LD BC,#bloques
	ADD HL,BC
	;HL APUNTA AL BLOQUE BUSCADO
	LD C,(HL)
	INC HL
	LD H,(HL)
	LD L,C
	;HL TIENE EL VALOR DEL BLOQUE DE 8 BUSCADO
	PUSH HL
	LD D,#0
	LD HL,#sub_bloques
	ADD HL,DE
	LD A,(HL)
	POP HL
	ADD H
	LD H,A
inc_ancho:
	LD E,#0
	ADD HL,DE
	RET

bloques:
.DW #0XC000,#0XC050,#0XC0A0,#0XC0F0,#0XC140,#0XC190,#0XC1E0,#0XC230,#0XC280,#0XC2D0,#0XC320,#0XC370,#0XC3C0,#0XC410,#0XC460,#0XC4B0,#0XC500,#0XC550,#0XC5A0,#0XC5F0,#0XC640,#0XC690,#0XC6E0,#0XC730,#0XC780
sub_bloques:
.DB #0X00,#0X08,#0X10,#0X18,#0X20,#0X28,#0X30,#0X38

