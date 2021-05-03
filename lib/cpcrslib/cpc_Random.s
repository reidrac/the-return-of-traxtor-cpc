.globl _cpc_Random

_cpc_Random::


 ;          LD A,(#valor_previo)
 ;           LD C,A
;			LD L,A
;			LD A,R;
;			ADD L
;            AND #0xB8
;            SCF
;            JP PO,NO_CLR
;            CCF
;NO_CLR:      LD A,C
 ;           RLA
 ;           LD C,A
 ;           LD A,R
 ;           ADD C
 ;           LD (#valor_previo),A
 ;           LD L,A
;            RET

	LD A,(#valor_previo)
	LD L,A
	LD A,R
	ADD L ;LOS 2 ÚLTIMOS BITS DE A DIRÁN SI ES 0,1,2,3
	LD (#valor_previo),A
	LD L,A ;SE DEVUELVE L (CHAR)
	LD H,#0
	RET
valor_previo:
	.db #0xFF

