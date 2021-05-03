.globl	_cpc_SetModo

_cpc_SetModo::
 	;LD A,L
  	LD HL,#2
 	ADD HL,SP
 	LD a,(HL)			; COMPROBAR QUE EL VALOR VAYA A L!!
   	JP 0XBC0E

