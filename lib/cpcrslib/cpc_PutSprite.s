.globl _cpc_PutSprite

_cpc_PutSprite::
;*************************************
; SPRITE ROUTINE WITHOUT TRANSPARENCY
; Supplied by Tim Riemann
; from a German forum
; DE = source address of the sprite
;      (includes header with 1B width [64byte maximum!], 1B height)
; HL = destination address
;*************************************

	POP AF
	POP HL	;DESTINATION ADDRESS
	POP DE	;SPRITE DATA
	PUSH AF
    ;EX DE,HL
    LD A,#64
    SUB (HL)
    ADD A
    LD (width1+1),A
    XOR A
    SUB (HL)
    LD (width2+1),A
    INC HL
    LD A,(HL)
    INC HL
width0:
		;ex de,hl
width1:
	JR width1 				;cada LDI es un byte
    LDI						;se hace el salto al byte correspondiente (64-ancho)
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
	LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
    LDI
width2:
   LD BC,#0X700
   EX DE,HL
   ADD HL,BC
   JP NC,width3
   LD BC,#0XC050
   ADD HL,BC
width3:
   EX DE,HL
   DEC A
   JP NZ, width1
   RET

