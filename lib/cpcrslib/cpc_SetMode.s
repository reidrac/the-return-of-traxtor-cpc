.globl _cpc_SetMode

_cpc_SetMode::
	;ld a,l
	LD HL,#2
	ADD HL,SP
	LD L,(HL)				; Comprobar que el valor vaya a L!!
	LD BC,#0x7F00          ;Gate array port
	LD D,#140 ;@10001100	   ;Mode  and  rom  selection  (and Gate Array function)
	ADD D
	OUT (C),A
	RET

