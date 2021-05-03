; ******************************************************
; **       Librería de rutinas SDCC para Amstrad CPC  **
; **       Raúl Simarro (Artaburu)    -   2009, 2012  **
; ******************************************************



cpc_GetScrAddress0:			;en HL están las coordenadas

	;LD A,H
	LD (#inc_ancho+1),A
	LD A,L
	SRL A
	SRL A
	SRL A
	; A indica el bloque a multiplicar x &50
	LD D,A						;D
	SLA A
	SLA A
	SLA A
	SUB L
	NEG
	; A indica el desplazamiento a multiplicar x &800
	LD E,A						;E
	LD L,D
	LD H,#0
	ADD HL,HL
	LD BC,#bloques
	ADD HL,BC
	;HL APUNTA AL BLOQUE BUSCADO
	LD C,(HL)
	INC HL
	LD H,(HL)
	LD L,C
	;HL TIENE EL VALOR DEL BLOQUE DE 8 BUSCADO
	PUSH HL
	LD D,#0
	LD HL,#sub_bloques
	ADD HL,DE
	LD A,(HL)
	POP HL
	ADD H
	LD H,A
inc_ancho:
	LD E,#0
	ADD HL,DE
	RET

bloques:
.DW #0XC000,#0XC050,#0XC0A0,#0XC0F0,#0XC140,#0XC190,#0XC1E0,#0XC230,#0XC280,#0XC2D0,#0XC320,#0XC370,#0XC3C0,#0XC410,#0XC460,#0XC4B0,#0XC500,#0XC550,#0XC5A0,#0XC5F0,#0XC640,#0XC690,#0XC6E0,#0XC730,#0XC780
sub_bloques:
.DB #0X00,#0X08,#0X10,#0X18,#0X20,#0X28,#0X30,#0X38




;*************************************
; GRAPHIC TEXT
;*************************************

.globl _cpc_PrintGphStr2X

_cpc_PrintGphStr2X::
;preparación datos impresión. El ancho y alto son fijos!
	LD IX,#2
	ADD IX,SP
	LD L,2 (IX)
	LD H,3 (IX)	;DESTINO
   	LD E,0 (IX)
	LD D,1 (IX)	;TEXTO ORIGEN
	LD A,#1
 	JP cpc_PrintGphStr0



.globl _cpc_PrintGphStrXY2X

_cpc_PrintGphStrXY2X::
;preparación datos impresión. El ancho y alto son fijos!
	LD IX,#2
	ADD IX,SP
 	LD L,3 (IX)
	LD A,2 (IX)	;pantalla
	CALL cpc_GetScrAddress0
   	LD E,0 (IX)
	LD D,1 (IX)	;texto origen
	LD A,#1
 	JP cpc_PrintGphStr0

.globl _cpc_PrintGphStrXY

_cpc_PrintGphStrXY::
;preparación datos impresión. El ancho y alto son fijos!
	LD IX,#2
	ADD IX,SP
 	LD L,3 (IX)
	LD A,2 (IX)	;pantalla
	CALL cpc_GetScrAddress0
   	LD E,0 (IX)
	LD D,1 (IX)	;texto origen
 	JP cpc_PrintGphStr0


.globl _cpc_PrintGphStr

_cpc_PrintGphStr::
;preparación datos impresión. El ancho y alto son fijos!
	LD IX,#2
	ADD IX,SP
	LD L,2 (IX)
	LD H,3 (IX)	;DESTINO
	;LD (CPC_PRINTGPHSTR0+DIRECC_DESTINO0),HL
   	LD E,0 (IX)
	LD D,1 (IX)	;TEXTO ORIGEN
	;JP cpc_PrintGphStr0

cpc_PrintGphStr0:

	;DE destino
	;HL origen
	;ex de,hl
	LD (#doble),A
	;trabajo previo: Para tener una lista de trabajos de impresión. No se interrumpe
	;la impresión en curso.
	LD A,(#imprimiendo)
	CP #1
	JP Z,add_elemento
	LD (#direcc_destino),HL
	EX DE,HL
	CALL bucle_texto0

;antes de terminar, se mira si hay algo en cola.
bucle_cola_impresion:
	LD A,(#elementos_cola)
	OR A
	JP Z,terminar_impresion
	CALL leer_elemento
	JP bucle_cola_impresion


terminar_impresion:
	XOR A
	LD (#imprimiendo),A
	RET
entrar_cola_impresion:
;si se está imprimiendo se mete el valor en la cola
	RET
add_elemento:
	DI
	LD IX,(#pos_cola)
	LD 0 (IX),L
	LD 1 (IX),H
	LD 2 (IX),E
	LD 3 (IX),D
	INC IX
	INC IX
	INC IX
	INC IX
	LD (#pos_cola),IX

	LD HL,#elementos_cola
	INC (HL)
	;Se añaden los valores hl y de
	EI
	RET
leer_elemento:
	DI
	LD IX,(#pos_cola)
	LD L,0 (IX)
	LD H,1 (IX)
	LD E,2 (IX)
	LD D,4 (IX)
	DEC IX
	DEC IX
	DEC IX
	DEC IX
	LD (#pos_cola),IX
	LD HL,#elementos_cola
	DEC (HL)
	EI
	RET

elementos_cola:
	.DW #0				; defw 0
pos_cola:
	.DW #cola_impresion ;defw cola_impresion
						;pos_escritura_cola defw cola_impresion
cola_impresion:  		; defs 12
	.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
bucle_texto0:
	LD A,#1
	LD (imprimiendo),A

	LD A,(first_char)
	LD B,A		;resto 48 para saber el número del caracter (En ASCII 0=48)

	LD A,(HL)
	OR A ;CP 0
	RET Z
	SUB B
	LD BC,(#cpc_Chars)	;apunto a la primera letra
	PUSH HL

	LD L,A		;en A tengo la letra que sería
	LD H,#0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL	;x8 porque cada letra son 8 bytes
	ADD HL,BC	;ahora HL apunta a los datos de la letra correspondiente
	CALL escribe_letra
	LD A,(doble)
	CP #1
; ANTES DE IMPRIMIR SE CHEQUEA SI ES DE ALTURA EL DOBLE Y SE ACTÚA EN CONSECUENCIA
	CALL Z, doblar_letra
	LD HL,(#direcc_destino)
	LD A,(doble)
	CP #1
	;alto
	JR Z,cont_doble
	LD DE,#letra_decodificada
	.DB #0xfD
	LD H,#8		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	JR cont_tot


cont_doble:
	LD DE,#letra_decodificada_tmp
	.DB #0xfD
	LD H,#16		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE

cont_tot:
	CALL cpc_PutSp0
	LD HL,(#direcc_destino)
	INC HL
	INC HL
	LD (#direcc_destino),HL
	POP HL
	INC HL
	JP bucle_texto0


doble:
	.DB #0
imprimiendo:
	.DB #0
direcc_destino:
	.DW #0


cpc_PutSp0:
;	.DB #0xfD
;  		LD H,16		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	LD B,#7
	LD C,B
loop_alto_2:

loop_ancho_2:
	EX DE,HL
	LDI
	LDI
	.DB #0XFD
	DEC H
	RET Z
	EX DE,HL
salto_linea:
	LD C,#0XFE			;&07F6 			;SALTO LINEA MENOS ANCHO
	ADD HL,BC
	JP NC,loop_alto_2 ;SIG_LINEA_2ZZ		;SI NO DESBORDA VA A LA SIGUIENTE LINEA
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7			;SÓLO SE DARÍA UNA DE CADA 8 VECES EN UN SPRITE
	JP loop_alto_2




doblar_letra:
	LD HL,#letra_decodificada
	LD DE,#letra_decodificada_tmp
	LD B,#8
buc_doblar_letra:
	LD A,(HL)
	INC HL
	LD (DE),A
	INC DE
	INC DE
	LD (DE),A
	DEC DE
	LD A,(HL)
	INC HL
	LD (DE),A
	INC DE
	INC DE
	LD (DE),A
	INC DE
	DJNZ buc_doblar_letra
	RET


escribe_letra:		; Code by Kevin Thacker
	PUSH DE
	LD IY,#letra_decodificada
	LD B,#8
bucle_alto_letra:
	PUSH BC
	PUSH HL
	LD E,(HL)
	CALL op_colores
	LD (IY),D
	INC IY
	CALL op_colores
	LD (IY),D
	INC IY
	POP HL
	INC HL
	POP BC
	DJNZ bucle_alto_letra
	POP DE
	RET

op_colores:
	ld d,#0					;; initial byte at end will be result of 2 pixels combined
	CALL op_colores_pixel	;; do pixel 0
	RLC D
	CALL op_colores_pixel
	RRC D
	RET

;; follow through to do pixel 1

op_colores_pixel:
	;; shift out pixel into bits 0 and 1 (source)
	RLC E
	RLC E
	;; isolate
	LD A,E
	AND #0X3
	LD HL,#colores_b0
	ADD A,L
	LD L,A
	LD A,H
	ADC A,#0
	LD H,A
	;; READ IT AND COMBINE WITH PIXEL SO FAR
	LD A,D
	OR (HL)
	LD D,A
	RET


.globl _cpc_SetInkGphStr

_cpc_SetInkGphStr::
;preparación datos impresión. El ancho y alto son fijos!
	LD IX,#2
	ADD IX,SP

	;LD A,H
	;LD C,L
	LD A,1 (IX) ;VALOR
	LD C,0 (IX)	;COLOR

	LD HL,#colores_b0
	LD B,#0
	ADD HL,BC
	LD (HL),A
	RET





.globl _cpc_PrintGphStrXYM1

_cpc_PrintGphStrXYM1::
;preparación datos impresión. El ancho y alto son fijos!
	LD IX,#2
	ADD IX,SP
 	LD L,3 (IX)
	LD A,2 (IX)	;pantalla
	CALL cpc_GetScrAddress0
   	LD E,0 (IX)
	LD D,1 (IX)	;texto origen
	XOR A
	JP cpc_PrintGphStr0M1


.globl _cpc_PrintGphStrXYM12X

_cpc_PrintGphStrXYM12X::
;preparación datos impresión. El ancho y alto son fijos!
	LD IX,#2
	ADD IX,SP
 	LD L,3 (IX)
	LD A,2 (IX)	;pantalla
	CALL cpc_GetScrAddress0
   	LD E,0 (IX)
	LD D,1 (IX)	;texto origen
	LD A,#1
	JP cpc_PrintGphStr0M1




.globl _cpc_PrintGphStrM12X

_cpc_PrintGphStrM12X::
	LD IX,#2
	ADD IX,SP
	LD L,2 (IX)
	LD H,3 (IX)	;DESTINO
   	LD E,0 (IX)
	LD D,1 (IX)	;TEXTO ORIGEN
	LD A,#1

	JP cpc_PrintGphStr0M1



.globl _cpc_PrintGphStrM1

_cpc_PrintGphStrM1::
;preparación datos impresión. El ancho y alto son fijos!

	LD IX,#2
	ADD IX,SP
	LD L,2 (IX)
	LD H,3 (IX)	;DESTINO
   	LD E,0 (IX)
	LD D,1 (IX)	;TEXTO ORIGEN
	XOR A

	;JP cpc_PrintGphStr0M1

cpc_PrintGphStr0M1:
	;DE destino
	;HL origen
	;ex de,hl
	LD (#dobleM1),A
	;trabajo previo: Para tener una lista de trabajos de impresión. No se interrumpe
	;la impresión en curso.
	LD A,(#imprimiendo)
	CP #1
	JP Z,add_elemento
	LD (#direcc_destino),HL
	EX DE,HL
	CALL bucle_texto0M1
;antes de terminar, se mira si hay algo en cola.
bucle_cola_impresionM1:
	LD A,(#elementos_cola)
	OR A
	JP Z,terminar_impresion
	CALL leer_elemento
	JP bucle_cola_impresionM1





bucle_texto0M1:
	LD A,#1
	LD (#imprimiendo),A

	LD A,(#first_char)
	LD B,A		;resto 48 para saber el número del caracter (En ASCII 0=48)
	LD A,(HL)
	OR A ;CP 0
	RET Z
	SUB B
	LD BC,(#cpc_Chars)	;apunto a la primera letra
	PUSH HL
	LD L,A		;en A tengo la letra que sería
	LD H,#0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL	;x8 porque cada letra son 8 bytes
	ADD HL,BC	;ahora HL apunta a los datos de la letra correspondiente
	CALL escribe_letraM1
	LD A,(dobleM1)
	CP #1
	; ANTES DE IMPRIMIR SE CHEQUEA SI ES DE ALTURA EL DOBLE Y SE ACTÚA EN CONSECUENCIA
	CALL Z, doblar_letraM1
	LD HL,(direcc_destino)
	LD A,(dobleM1)
	CP #1
	;alto
	JR Z,cont_dobleM1
	LD DE,#letra_decodificada
	.DB #0xfD
	LD H,#8		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	JR cont_totM1


cont_dobleM1:
	LD DE,#letra_decodificada_tmp
	.DB #0XFD
	LD H,#16		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
cont_totM1:
	CALL cpc_PutSp0M1
	LD HL,(#direcc_destino)
	INC HL
	LD (#direcc_destino),HL
	POP HL
	INC HL
	JP bucle_texto0M1

dobleM1:
	.DB #0
;.imprimiendo defb 0
;.direcc_destino defw 0

doblar_letraM1:
	LD HL,#letra_decodificada
	LD DE,#letra_decodificada_tmp
	LD B,#8
buc_doblar_letraM1:
	LD A,(HL)
	INC HL
	LD (DE),A
	INC DE
	LD (DE),A
	INC DE
	DJNZ buc_doblar_letraM1
	RET


cpc_PutSp0M1:
	;	defb #0xfD
   	;	LD H,8		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	LD B,#7
	LD C,B
loop_alto_2M1:
loop_ancho_2M1:
	EX DE,HL
	LDI
	.DB #0XFD
	DEC H
	RET Z
	EX DE,HL
salto_lineaM1:
	LD C,#0XFF			;#0x07f6 			;salto linea menos ancho
	ADD HL,BC
	JP NC,loop_alto_2M1 ;sig_linea_2zz		;si no desborda va a la siguiente linea
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7			;sólo se daría una de cada 8 veces en un sprite
	JP loop_alto_2M1



escribe_letraM1:
	LD IY,#letra_decodificada
	LD B,#8
	LD IX,#byte_tmp
bucle_altoM1:
	PUSH BC
	PUSH HL

	LD A,(HL)
	LD HL,#dato
	LD (HL),A
	;me deja en ix los valores convertidos
	;HL tiene la dirección origen de los datos de la letra
	;LD DE,letra	;el destino es la posición de decodificación de la letra
	;Se analiza el byte por parejas de bits para saber el color de cada pixel.
	LD (IX),#0	;reset el byte
	LD B,#4	;son 4 pixels por byte. Los recorro en un bucle y miro qué color tiene cada byte.
bucle_coloresM1:
	;roto el byte en (HL)
	PUSH HL
	CALL op_colores_m1	;voy a ver qué color es el byte. tengo un máximo de 4 colores posibles en modo 0.
	POP HL
	SRL (HL)
	SRL (HL)	;voy rotando el byte para mirar los bits por pares.
	DJNZ bucle_coloresM1
	LD A,(IX)
	LD (IY),A
	INC IY
	POP HL
	INC HL
	POP BC
	DJNZ bucle_altoM1
	RET


;.rutina
;HL tiene la dirección origen de los datos de la letra

;Se analiza el byte por parejas de bits para saber el color de cada pixel.
;ld ix,byte_tmp
;ld (ix+0),0

;LD B,4	;son 4 pixels por byte. Los recorro en un bucle y miro qué color tiene cada byte.
;.bucle_colores
;roto el byte en (HL)
;push hl
;call op_colores_m1	;voy a ver qué color es el byte. tengo un máximo de 4 colores posibles en modo 0.
;pop hl
;sla (HL)
;sla (HL)	;voy rotando el byte para mirar los bits por pares.

;djnz bucle_colores

;ret
op_colores_m1:   	;rutina en modo 1
					;mira el color del bit a pintar
	LD A,#3			;hay 4 colores posibles. Me quedo con los 2 primeros bits
	AND (HL)
	; EN A tengo el número de bytes a sumar!!
	LD HL,#colores_m1
	LD E,A
	LD D,#0
	ADD HL,DE
	LD C,(HL)
	;EN C ESTÁ EL BYTE DEL COLOR
	;LD A,4
	;SUB B
	LD A,B
	DEC A
	OR A ;CP 0
	JP Z,_sin_rotar
rotando:
	SRL C
	DEC A
	JP NZ, rotando
_sin_rotar:
	LD A,C
	OR (IX)
	LD (IX),A
	;INC IX
	RET


.globl _cpc_SetInkGphStrM1

_cpc_SetInkGphStrM1::
	LD IX,#2
	ADD IX,SP
	LD A,1 (IX) ;VALOR
	LD C,0 (IX)	;COLOR
	LD HL,#colores_cambM1
	LD B,#0
	ADD HL,BC
	LD (HL),A
	RET



colores_cambM1:
colores_m1:
	.DB #0b00000000,#0b10001000,#0b10000000,#0b00001000

;defb @00000000,  @01010100, @00010000, @00000101  ;@00000001, @00000101, @00010101, @00000000



;DEFC direcc_destino0_m1 = direcc_destino
;DEFC colores_cambM1 = colores_m1


.globl _cpc_SetFont

_cpc_SetFont::
	ld ix, #2
	add ix, sp
	ld a, 0(ix)
	ld (#first_char), a
	ld l, 1(ix)
	ld h, 2(ix)
	ld (#cpc_Chars), hl
	ret

dato:
	.DB #0b00011011  ;aquí dejo temporalmente el byte a tratar

byte_tmp:
	.DB #0
	.DB #0
	.DB #0  ;defs 3
colores_b0: ;defino los 4 colores posibles para el byte. Los colores pueden ser cualesquiera.
	  		;Pero se tienen que poner bien, en la posición que le corresponda.
	.DB #0b00001010,#0b00100000,#0b10100000,#0b00101000
	;.DB #0b00000000,  #0b01010100, #0b00010000, #0b00000101  ;#0b00000001, #0b00000101, #0b00010101, #0b00000000

letra_decodificada: ;. defs 16 ;16	;uso este espacio para guardar la letra que se decodifica
	.DB #0,#0,#0,#0,#0,#0,#0,#0
	.DB #0,#0,#0,#0,#0,#0,#0,#0
letra_decodificada_tmp: ;defs 32 ;16	;uso este espacio para guardar la letra que se decodifica para tamaño doble altura
	.DB #0,#0,#0,#0,#0,#0,#0,#0
	.DB #0,#0,#0,#0,#0,#0,#0,#0
	.DB #0,#0,#0,#0,#0,#0,#0,#0
	.DB #0,#0,#0,#0,#0,#0,#0,#0


first_char:
	.DB #0	;first defined char number (ASCII)

cpc_Chars:   ;cpc_Chars codificadas... cada pixel se define con 2 bits que definen el color.
	.DW #0

