.globl  _cpc_SetColour

_cpc_SetColour::		;El número de tinta 17 es el borde
    LD HL,#2
    ADD HL,SP
  	LD A,(HL)
    INC HL
  	;INC HL
    LD E,(HL)
  	LD BC,#0x7F00                     ;Gate Array
	OUT (C),A                       ;Número de tinta
	LD A,#64 ;@01000000              	;Color (y Gate Array)
	ADD E
	OUT (C),A
	RET

