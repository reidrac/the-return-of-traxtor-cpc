.globl _cpc_PrintStr

_cpc_PrintStr::
	LD IX,#2
	ADD IX,SP
   	LD l,0 (IX)
	LD h,1 (IX)	;TEXTO ORIGEN

;	LD HL,#2
 ;   ADD HL,SP
;	LD E,(HL)
;	INC HL
;	LD D,(HL)
;	EX DE,HL
bucle_imp_cadena:
	LD A,(HL)
	OR A
	JR Z,salir_bucle_imp_cadena
	CALL #0XBB5A
	INC HL
	JR bucle_imp_cadena
salir_bucle_imp_cadena:
	LD A,#0X0D				; PARA TERMINAR HACE UN SALTO DE LÍNEA
	CALL #0XBB5A
	LD A,#0X0A
	JP 0XBB5A

