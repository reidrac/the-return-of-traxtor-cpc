; ******************************************************
; **       Librería de rutinas SDCC para Amstrad CPC  **
; **       Raúl Simarro (Artaburu)    -   2009, 2012  **
; ******************************************************


;*************************************
; UNCRUNCH
;*************************************


.globl _cpc_Uncrunch

_cpc_Uncrunch::
; datos necesarios que vienen en la pila:
; ORIGEN	HL
; DESTINO	DE

	;Ojo, para que el pucrunch funcione hay que coger y quitar el salto de las interrupciones.
	DI
	LD HL,(#0X0038)
	LD (#datos_int),HL

	LD HL,#0X00C9
	LD (#0x0038),HL
	EI

;POP AF
;POP HL
;POP DE
;PUSH AF
	LD IX,#2
	ADD IX,SP
	LD e,2 (IX)
	LD d,3 (IX)	;DESTINO
   	LD l,0 (IX)
	LD h,1 (IX)	;TEXTO ORIGEN
		

pucrunch:
   PUSH   DE         ; destination pointer to 2nd register 
   EXX            ; set 
   POP   DE 

   
   PUSH   HL 
   PUSH   DE 
   PUSH   BC 
   PUSH   AF 

   EXX 

        ; read the header self-modifying the 
        ; parameters straight into the code 
        ; skip useless data 
 
   
   LD BC,#6
   ADD HL,BC

   LD   A, (HL)         ; starting escape 
   INC   HL 
   LD   (#esc+1), A 

   INC   HL         ; skip useless data 
   INC   HL 

   LD   A, (HL)         ; number of escape bits 
   INC   HL 
   LD   (#escb0+1), A 
   LD   (#escb1+1), A 

   LD   B, A         ; 8 - escape bits 
   LD   A, #8 
   SUB   B 
   LD   (#noesc+1), A 

   LD   A, (HL)         ; maxGamma + 1 
   INC   HL 
   LD   (#mg+1), A 

   LD   B, A         ; 8 - maxGamma 
   LD   A, #9 
   SUB   B 
   LD   (#longrle+1), A 

   LD   A, (HL)         ; (1 << maxGamma) 
   INC   HL 
   LD   (#mg1+1), A 

   ADD   A, A         ; (2 << maxGamma) - 1 
   DEC   A 
   LD   (#mg21+1), A 

   LD   A, (HL)         ; extra lz77_0 position bits 
   INC   HL 
   LD   (#elzpb+1), A 

   INC   HL         ; skip useless data 
   INC   HL 

   LD   E, (HL)         ; RLE table length 
   LD   (#rlet+1), HL      ; RLE table pointer 
   INC   HL 
   LD   D, #0 
   ADD   HL, DE 

   LD   C, #0X80         ; start decompression 
   JP   loop_u 

newesc:
   ld   a, (#esc+1)      ; save old escape code 
   ld   d, a 

escb0:
   LD   B, #2         ; ** parameter 
   XOR   A         ; get new escape code 
   CALL   get_bits 
   LD   (#esc+1), A 

   LD   A, D 

noesc:
	LD   B, #6         ; ** parameter 
	CALL   get_bits      ; get more bits to complete a byte 
	
	EXX            ; output the byte 
	LD   (DE), A 
	INC   DE 
	EXX 

loop_u: 
	XOR   A 
escb1:
	LD   B, #2         ; ** parameter 
    CALL   get_bits      ; get escape code 
esc:   
	CP   #0         ; ** PARAMETER 
	JP   NZ, noesc 
	
	CALL   get_gamma      ; get length 
	EXX 
	LD   B, #0 
	LD   C, A 
	EXX 
	
	CP   #1 
	JP   NZ, lz77_0      ; lz77_0 
	
	XOR   A 
	CALL   get_bit 
	JP   NC, lz77_0_2      ; 2-byte lz77_0 
	
	CALL   get_bit 
	JP   NC, newesc      ; escaped literal byte 
	
	CALL   get_gamma      ; get length 
	EXX 
	LD   B, #1 
	LD   C, A 
	EXX 

mg1:   
	CP   #64         ; ** parameter 
	JP   C, chrcode      ; short RLE, get bytecode 

longrle:   
	LD   B, #2         ; ** parameter 
	CALL   get_bits      ; complete length LSB 
	EX   AF, AF' 
	
	CALL   get_gamma      ; length MSB 
	EXX 
	LD   B, A 
	EX   AF, AF' 
	LD   C, A 
	EXX 

chrcode:   
	CALL   get_gamma      ; get byte to repeat 

	PUSH   HL 
rlet:   
	LD   HL, #0X0000      ; ** parameter 
	LD   D, #0 
	LD   E, A 
	ADD   HL, DE 
	
	CP   #32 
	LD   A, (HL) 
	POP   HL 
	JP   C, dorle 
	
	LD   A, E         ; get 3 more bits to complete the 
	LD   B, #3         ; byte 
	CALL   get_bits 

dorle:  
	EXX            ; output the byte n times 
	INC   C 
dorlei:
	LD   (DE), A 
	INC   DE 
	DEC   C 
	JP   NZ, dorlei 
	DEC   B 
	JP   NZ, dorlei 
	EXX 
	JP   loop_u 

lz77_0:
   CALL   get_gamma      ; offset MSB 
mg21:
   CP   #127         ; ** parameter 

   ; ret   z 

   JP   Z, fin         ; EOF, return 

   DEC   A         ; (1...126 -> 0...125) 
elzpb:
   LD   B, #0         ; ** parameter 
   CALL   get_bits      ; complete offset MSB 

lz77_0_2:
   EX   AF, AF' 
   LD   B, #8         ; offset LSB 
   CALL   get_bits 
   CPL            ; xor'ed by the compressor 

   EXX            ; combine them into offset 
   LD   L, A 
   EX   AF, AF' 
   LD   H, A 
   INC   HL 

   XOR   A         ; CF = 0 

   PUSH   DE         ; (current output position) - (offset) 
   EX   DE, HL 
   SBC   HL, DE 
   POP   DE 

   INC   BC 

   LDIR            ; copy 
   EXX 
   JP   loop_u 

;## Get a bit from the source stream. 
;## Return    CF = result 
get_bit:
   SLA   C         ; shift next bit into CF 
   RET   NZ 
   LD   C, (HL)         ; get next byte 
   INC   HL         ; increase source stream pointer 
   RL   C         ; shift next bit into CF, bit0 = 1 
   RET 

;## Get multiple bits from the source stream. 
;## In        B = number of bits to get 
;## Return    A = result 
get_bits:  
   DEC   B 
   RET   M 
   SLA   C         ; shift next bit into CF 
   JP   NZ, gb1 
   LD   C, (HL)         ; get next byte 
   INC   HL         ; increase source stream pointer 
   RL   C         ; shift next bit into CF, bit0 = 1 
gb1:
   RLA            ; rotate next bit into A 
   JP   get_bits 

;## Get an Elias Gamma coded value from the source stream. 
;## Return    A = result 
get_gamma:  
	LD   B, #1 
mg:  
	LD   A, #7         ; ** parameter 
gg1:
	CALL   get_bit         ; get bits until 0-bit or max 
	JR   NC, gg2 
	INC   B 
	CP   B 
	JP   NZ, gg1 
gg2:
   LD   A, #1         ; GET THE ACTUAL VALUE 
   DEC   B 
   JP   get_bits 

fin:
   ; Restauramos los registros dobles y vuelta limpia 
   EXX 
   POP   AF 
   POP   BC 
   POP   DE 
   POP   HL 
   EXX 
   
   ;RET   
	DI
	LD HL,(#datos_int)
	LD (#0X0038),HL	;RESTAURO LA INTERRUPCIÓN ORIGINAL
	EI
	RET   
datos_int:
	.DW #0	   