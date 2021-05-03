.globl _cpc_SetBorder

_cpc_SetBorder::
	LD HL,#2
	ADD HL,SP
	LD B,(HL)
	;LD B,A
	LD C,B
	JP 0XBC38

