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




.globl _cpc_PrintGphStrStd

_cpc_PrintGphStrStd::
	ld ix,#2
	add ix,sp
	ld l,3  (ix)
	ld h,4 (ix)	;destino
	ld e,1  (ix)
	ld d,2 (ix)	;texto origen
	ld a,0 (ix) ;color
	ld (#color_uso+1),a
	JP cpc_PrintGphStrStd0
	

.globl _cpc_PrintGphStrStdXY

_cpc_PrintGphStrStdXY::
;preparación datos impresión. El ancho y alto son fijos!
	ld ix,#2
	add ix,sp
	ld L,4 (ix)
	ld A,3 (ix)	;pantalla
	call cpc_GetScrAddress0   
	ld e,1 (ix)
	ld d,2 (ix)	;texto origen
	ld a,0 (ix) ;color
	ld (#color_uso+1),a
	JP cpc_PrintGphStrStd0

color0:
	XOR A
	CALL metecolor
	JP sigue
color1:
	LD A,#0B00001000
	CALL metecolor
	JP sigue
color2:
	LD A,#0B10000000
	CALL metecolor
	JP sigue
color3:
	LD A,#0b10001000
	CALL metecolor
	JP sigue
metecolor:
	LD (#cc0_gpstd-1),A
	LD (#cc4_gpstd-1),A
	SRL A
	LD (#cc1_gpstd-1),A
	LD (#cc5_gpstd-1),A
	SRL A
	LD (#cc2_gpstd-1),A
	LD (#cc6_gpstd-1),A
	SRL A
	LD (#cc3_gpstd-1),A
	LD (#cc7_gpstd-1),A
	RET

cpc_PrintGphStrStd0: 
;; marcará el color con que se imprime
color_uso:
	LD A,#1
	OR A 
	JP Z,color0
	CP #1
	JP Z,color1
	CP #2
	JP Z,color2
	CP #3
	JP Z,color3
sigue:

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
	Ld (#pos_cola),IX
	LD HL,#elementos_cola
	INC (HL)
	EI
	RET
leer_elemento:
	DI
	LD IX,(#pos_cola)
	LD L,0 (IX)
	LD H,1 (IX)
	LD E,2 (IX)
	LD D,3 (IX)
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
	.DW #0
pos_cola:
	.DW cola_impresion
cola_impresion:
	.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0 ; defs 12
bucle_texto0:
	LD A,#1
	LD (#imprimiendo),A
	LD A,(#first_char8)
	LD B,A		;resto 48 para saber el número del caracter (En ASCII 0=48)
	LD A,(HL)
	OR A ;CP 0
	RET Z
	SUB B
	LD BC,#cpc_Chars8	;apunto a la primera letra
	PUSH HL
	LD L,A		
	LD H,#0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL	
	ADD HL,BC	
	CALL escribe_letra_gpstd
	LD HL,(#direcc_destino)
	
	LD DE,#letra_decodificada
	CALL cpc_PutSp0_gpstd
	LD HL,(#direcc_destino)
	INC HL
	INC HL
	LD (#direcc_destino),HL
	POP HL
	INC HL
	JP bucle_texto0

imprimiendo: 
	.db #0
direcc_destino:
	.dw #0


cpc_PutSp0_gpstd:
	.DB #0XFD
	LD H,#8	
	LD B,#7
	LD C,B
loop_alto_2_gpstd:
loop_ancho_2_gpstd:		
	EX DE,HL
	LDI
	LDI
	.DB #0XFD
	DEC H
	RET Z	
	EX DE,HL   	   
salto_linea_gpstd:
	LD C,#0XFE			
	ADD HL,BC
	JP NC,loop_alto_2_gpstd 
	LD BC,#0XC050
	ADD HL,BC
	LD B,#7	
	JP loop_alto_2_gpstd	
		
		
		
escribe_letra_gpstd:		;; lee el byte y lo interpreta
	LD IY,#letra_decodificada
	LD B,#8
bucle_alto_gpstd:
	PUSH BC 	;leo el byte... ahora se miran sus bits y se rellena el caracter a imprimir
	XOR A
	LD B,(HL)
	BIT 7,B
	JP Z,cc0_gpstd
	OR #0b10001000
cc0_gpstd:
	BIT 6,B
	JP Z,cc1_gpstd
	OR #0b01000100
cc1_gpstd:
	BIT 5,B
	JP Z,cc2_gpstd
	OR #0b00100010
cc2_gpstd:
	BIT 4,B
	JP Z,cc3_gpstd
	OR #0b00010001
cc3_gpstd:
	;primer byte
	LD 0 (IY),A
	INC IY
	XOR A
	BIT 3,B
	JP Z,cc4_gpstd
	OR #0b10001000
cc4_gpstd:
	BIT 2,B
	JP Z,cc5_gpstd
	OR #0b01000100
cc5_gpstd:
	BIT 1,B
	JP Z,cc6_gpstd
	OR #0b00100010
cc6_gpstd:
	BIT 0,B
	JP Z,cc7_gpstd
	OR #0b00010001
cc7_gpstd:
	;segundo byte
	LD 0 (IY),A
	INC IY
	INC HL
	POP BC
	DJNZ bucle_alto_gpstd
	RET



byte_tmp: ;DEFS 2
	.DB #0,#0
letra_decodificada:
	.DB #0,#0,#0,#0,#0,#0,#0,#0 		;DEFS 16	
	.DB #0,#0,#0,#0,#0,#0,#0,#0			;USO ESTE ESPACIO PARA GUARDAR LA LETRA QUE SE DECODIFICA

;DEFC direcc_destino0s_m1 = direcc_destino  

first_char8: 
	.DB #32	;first defined char number (ASCII)
cpc_Chars8:   ;each bit of each byte is a pixel,#same way as SYMBOL function of Locomotive BASIC.
	;; KEY SET BY ANJUEL & NA_TH_AN FROM NANAKO CPC GAME.
   .DB #0,#0,#0,#0,#0,#0,#0,#0
   .DB #28,#8,#8,#8,#28,#0,#8,#0
   .DB #10,#10,#0,#0,#0,#0,#0,#0
   .DB #36,#126,#36,#36,#36,#126,#36,#0
   .DB #16,#62,#32,#60,#4,#124,#8,#0
   .DB #0,#50,#52,#8,#22,#38,#0,#0
   .DB #0,#16,#40,#58,#68,#58,#0,#0
   .DB #16,#16,#0,#0,#0,#0,#0,#0
   .DB #16,#112,#80,#64,#80,#112,#16,#0
   .DB #8,#14,#10,#2,#10,#14,#8,#0
   .DB #0,#42,#28,#28,#42,#0,#0,#0
   .DB #0,#8,#8,#62,#8,#8,#0,#0
   .DB #0,#0,#0,#0,#12,#12,#0,#0
   .DB #0,#0,#0,#62,#0,#0,#0,#0
   .DB #0,#0,#0,#0,#12,#12,#16,#0
   .DB #0,#4,#8,#16,#32,#64,#0,#0
   .DB #62,#34,#34,#34,#34,#34,#62,#0
   .DB #12,#4,#4,#4,#4,#4,#4,#0
   .DB #62,#34,#2,#62,#32,#34,#62,#0
   .DB #62,#36,#4,#28,#4,#36,#62,#0
   .DB #32,#32,#36,#62,#4,#4,#14,#0
   .DB #62,#32,#32,#62,#2,#34,#62,#0
   .DB #62,#32,#32,#62,#34,#34,#62,#0
   .DB #62,#36,#4,#4,#4,#4,#14,#0
   .DB #62,#34,#34,#62,#34,#34,#62,#0
   .DB #62,#34,#34,#62,#2,#34,#62,#0
   .DB #0,#24,#24,#0,#0,#24,#24,#0
   .DB #0,#24,#24,#0,#0,#24,#24,#32
   .DB #4,#8,#16,#32,#16,#8,#4,#0
   .DB #0,#0,#126,#0,#0,#126,#0,#0
   .DB #32,#16,#8,#4,#8,#16,#32,#0
   .DB #64,#124,#68,#4,#28,#16,#0,#16
   .DB #0,#56,#84,#92,#64,#60,#0,#0
   .DB #126,#36,#36,#36,#60,#36,#102,#0
   .DB #124,#36,#36,#62,#34,#34,#126,#0
   .DB #2,#126,#66,#64,#66,#126,#2,#0
   .DB #126,#34,#34,#34,#34,#34,#126,#0
   .DB #2,#126,#66,#120,#66,#126,#2,#0
   .DB #2,#126,#34,#48,#32,#32,#112,#0
   .DB #2,#126,#34,#32,#46,#36,#124,#0
   .DB #102,#36,#36,#60,#36,#36,#102,#0
   .DB #56,#16,#16,#16,#16,#16,#56,#0
   .DB #28,#8,#8,#8,#8,#40,#56,#0
   .DB #108,#40,#40,#124,#36,#36,#102,#0
   .DB #112,#32,#32,#32,#34,#126,#2,#0
   .DB #127,#42,#42,#42,#42,#107,#8,#0
   .DB #126,#36,#36,#36,#36,#36,#102,#0
   .DB #126,#66,#66,#66,#66,#66,#126,#0
   .DB #126,#34,#34,#126,#32,#32,#112,#0
   .DB #126,#66,#66,#74,#126,#8,#28,#0
   .DB #126,#34,#34,#126,#36,#36,#114,#0
   .DB #126,#66,#64,#126,#2,#66,#126,#0
   .DB #34,#62,#42,#8,#8,#8,#28,#0
   .DB #102,#36,#36,#36,#36,#36,#126,#0
   .DB #102,#36,#36,#36,#36,#24,#0,#0
   .DB #107,#42,#42,#42,#42,#42,#62,#0
   .DB #102,#36,#36,#24,#36,#36,#102,#0
   .DB #102,#36,#36,#60,#8,#8,#28,#0
   .DB #126,#66,#4,#8,#16,#34,#126,#0
   .DB #4,#60,#36,#32,#36,#60,#4,#0
   .DB #0,#64,#32,#16,#8,#4,#0,#0
   .DB #32,#60,#36,#4,#36,#60,#32,#0
   .DB #0,#16,#40,#68,#0,#0,#0,#0
   .DB #0,#0,#0,#0,#0,#0,#0,#0
   .DB #0,#100,#104,#16,#44,#76,#0,#0
   .DB #126,#36,#36,#36,#60,#36,#102,#0
   .DB #124,#36,#36,#62,#34,#34,#126,#0
   .DB #2,#126,#66,#64,#66,#126,#2,#0
   .DB #126,#34,#34,#34,#34,#34,#126,#0
   .DB #2,#126,#66,#120,#66,#126,#2,#0
   .DB #2,#126,#34,#48,#32,#32,#112,#0
   .DB #2,#126,#34,#32,#46,#36,#124,#0
   .DB #102,#36,#36,#60,#36,#36,#102,#0
   .DB #56,#16,#16,#16,#16,#16,#56,#0
   .DB #28,#8,#8,#8,#8,#40,#56,#0
   .DB #108,#40,#40,#124,#36,#36,#102,#0
   .DB #112,#32,#32,#32,#34,#126,#2,#0
   .DB #127,#42,#42,#42,#42,#107,#8,#0
   .DB #126,#36,#36,#36,#36,#36,#102,#0
   .DB #126,#66,#66,#66,#66,#66,#126,#0
   .DB #126,#34,#34,#126,#32,#32,#112,#0
   .DB #126,#66,#66,#74,#126,#8,#28,#0
   .DB #126,#34,#34,#126,#36,#36,#114,#0
   .DB #126,#66,#64,#126,#2,#66,#126,#0
   .DB #34,#62,#42,#8,#8,#8,#28,#0
   .DB #102,#36,#36,#36,#36,#36,#126,#0
   .DB #102,#36,#36,#36,#36,#24,#0,#0
   .DB #107,#42,#42,#42,#42,#42,#62,#0
   .DB #102,#36,#36,#24,#36,#36,#102,#0
   .DB #102,#36,#36,#60,#8,#8,#28,#0
   .DB #126,#66,#4,#8,#16,#34,#126,#0
   .DB #4,#60,#36,#96,#96,#36,#60,#4
   .DB #0,#16,#16,#16,#16,#16,#16,#0
   .DB #32,#60,#36,#6,#6,#36,#60,#32
   .DB #0,#0,#16,#40,#68,#0,#0,#0
   .DB #126,#66,#90,#82,#90,#66,#126,#0