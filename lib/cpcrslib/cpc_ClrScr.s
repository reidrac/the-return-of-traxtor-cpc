.globl _cpc_ClrScr

_cpc_ClrScr::
	XOR A
	LD HL,#0xC000
	LD DE,#0xC001
	LD BC,#16383
	LD (HL),A
	LDIR
	RET

