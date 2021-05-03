.globl _cpc_SetInk

_cpc_SetInk::
	LD HL,#2
	ADD HL,SP
	LD A,(HL)
	INC HL

	LD B,(HL)
	LD C,B
	JP 0XBC32

