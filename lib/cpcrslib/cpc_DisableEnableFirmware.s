.globl _cpc_DisableFirmware

_cpc_DisableFirmware::
	DI
	LD HL,(#0X0038)
	LD (backup_fw),HL
	LD HL,#0X0038
	LD (HL),#0XFB		;EI
	INC HL
	LD (HL),#0XC9		;RET
	EI
	RET

backup_fw:
	.DW  #0

.globl 	_cpc_EnableFirmware

_cpc_EnableFirmware::
	DI
	LD DE,(backup_fw)
	LD HL,#0X0038
	LD (HL),E			;EI
	INC HL
	LD (HL),D			;RET
	EI
	RET

