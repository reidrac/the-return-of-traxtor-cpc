; ******************************************************
; **       Librería de rutinas SDCC para Amstrad CPC  **
; **       Raúl Simarro (Artaburu)    -   2009, 2012  **
; ******************************************************

;*************************************
; KEYBOARD
;*************************************


.globl _cpc_AnyKeyPressed


_cpc_AnyKeyPressed::
    call hacer_tiempo
    call hacer_tiempo
    call hacer_tiempo



	LD A,#40
bucle_deteccion_tecla:
	PUSH AF
	CALL cpc_TestKeyboard				;en A vuelve los valores de la linea
	OR A
	JP NZ, tecla_pulsada				; retorna si no se ha pulsado ninguna tecla
	POP AF
	INC A
	CP #0x4a
	JP NZ, bucle_deteccion_tecla
	LD HL,#0

	RET

tecla_pulsada:
	POP AF
	LD HL,#1
	RET
t_pulsada:
    POP AF
    JP _cpc_AnyKeyPressed

hacer_tiempo:
    LD A,#254
bucle_previo_deteccion_tecla:
	PUSH AF
	POP AF
	dec A
	Jr nZ, bucle_previo_deteccion_tecla
	ret



.globl _cpc_AssignKey

_cpc_AssignKey::

	LD HL,#2
    ADD HL,SP
	LD E,(HL)		;E-> numero tecla
	INC HL
	;INC HL
    LD A,(HL)					;linea, byte
    INC HL
    LD B,(HL)					;DE tiene el valor de la tecla a escribir en la tabla
								; En A se tiene el valor de la tecla seleccionada a comprobar [0..11]
								;___________________________________________________________________
								;	;En A viene la tecla a redefinir (0..11)
	SLA E
	LD D,#0
	LD HL, #tabla_teclas
	ADD HL,DE 					;Nos colocamos en la tecla a redefinir y la borramos
	LD (HL),#0XFF
	INC HL
	LD (HL),#0XFF
	DEC HL
	PUSH HL
								;call ejecutar_deteccion_teclado ;A tiene el valor del teclado
								; A tiene el byte (<>0)
								; B tiene la linea
								;guardo linea y byte
	POP HL
	LD (HL),A ;byte
	INC HL
	LD (HL),B
	RET


.globl _cpc_TestKey

_cpc_TestKey::

	LD HL,#2
    ADD HL,SP
    LD L,(HL)					; En A se tiene el valor de la tecla seleccionada a comprobar [0..11]
	SLA L
	INC L
	LD H,#0
	LD DE,#tabla_teclas
	ADD HL,DE
	LD A,(HL)
	CALL cpc_TestKeyboard		; esta rutina lee la línea del teclado correspondiente
	DEC HL						; pero sólo nos interesa una de las teclas.
	and (HL) 					;para filtrar por el bit de la tecla (puede haber varias pulsadas)
	CP (HL)						;comprueba si el byte coincide
	LD H,#0
	JP Z,pulsado
	LD L,H
	RET
pulsado:
	LD L,#1
	RET





.globl _cpc_RedefineKey

_cpc_RedefineKey::

	LD HL,#2
    ADD HL,SP
    LD L,(HL)
	SLA L
	LD H,#0
	LD DE,#tabla_teclas
	ADD HL,DE 					;Nos colocamos en la tecla a redefinir
	LD (HL),#0XFF				; y la borramos
	INC HL
	LD (HL),#0XFF
	DEC HL
	PUSH HL
	CALL ejecutar_deteccion_teclado ;A tiene el valor del teclado
	LD A,D
								; A tiene el byte (<>0)
								; B tiene la linea
								;guardo linea y byte
	POP HL						;recupera posición leída
	LD A,(linea)
	LD (HL),A 					;byte
	INC HL
	LD A,(bte)
	LD (HL),A
	RET


ejecutar_deteccion_teclado:
	LD A,#0x40
bucle_deteccion_tecla1:
	PUSH AF
	LD (bte),A
	CALL cpc_TestKeyboard					;en A vuelve los valores de la linea
	OR A
	JR NZ, tecla_pulsada1					; retorna si no se ha pulsado ninguna tecla
	POP AF
	INC A
	CP #0x4A
	JR NZ, bucle_deteccion_tecla1
	JR ejecutar_deteccion_teclado

tecla_pulsada1:
	LD (linea),A
	POP AF
	CALL comprobar_si_tecla_usada
	RET NC
	JR bucle_deteccion_tecla1

comprobar_si_tecla_usada: 				; A tiene byte, B linea
	LD B,#12							;numero máximo de tecla redefinibles
	LD IX,#tabla_teclas
	LD C,(IX)
bucle_bd_teclas:						;comprobar byte
	LD A,(linea)
	LD C,(IX)
	CP (IX)
	JR Z, comprobar_linea
	INC IX
	INC IX
	DJNZ bucle_bd_teclas
	SCF
	CCF
	RET									; si vuelve después de comprobar, que sea NZ
comprobar_linea:						;si el byte es el mismo, mira la linea
	LD A,(bte)
	CP 1 (IX)							; esto es (ix+1)
	JR Z, tecla_detectada				; Vuelve con Z si coincide el byte y la linea
	INC IX
	INC IX
	DJNZ bucle_bd_teclas
	SCF
	CCF
	RET 								; si vuelve después de comprobar, que sea NZ
tecla_detectada:
	SCF
	RET


.globl _cpc_DeleteKeys

_cpc_DeleteKeys::		;borra la tabla de las teclas para poder redefinirlas todas
	LD HL,#tabla_teclas
	LD DE,#tabla_teclas+#1
	LD BC, #24
	LD (HL),#0xFF
	LDIR
	RET


.globl _cpc_TestKeyF

_cpc_TestKeyF::
	LD HL,#2
    ADD HL,SP
    LD L,(HL)
	SLA L
	INC L
	LD H,#0
	LD DE,#tabla_teclas
	ADD HL,DE
	LD A,(HL)
	SUB #0X40
	EX DE,HL
	LD HL,#keymap	;; LEE LA LÍNEA BUSCADA DEL KEYMAP
	LD C,A
	LD B,#0
	ADD HL,BC
	LD A,(HL)
	EX DE,HL
	DEC HL						; PERO SÓLO NOS INTERESA UNA DE LAS TECLAS.
	AND (HL) ;PARA FILTRAR POR EL BIT DE LA TECLA (PUEDE HABER VARIAS PULSADAS)
	CP (HL)	;COMPRUEBA SI EL BYTE COINCIDE
	LD H,#0
	JP NZ,#pulsado_cpc_TestKeyF
	LD L,H
	RET
pulsado_cpc_TestKeyF:
	LD L,#1
	RET


.globl _cpc_ScanKeyboard

_cpc_ScanKeyboard::

    DI              ;1 #0X#0X%%#0X#0X C P C   VERSION #0X#0X%%#0X#0X   FROM CPCWIKI
    LD HL,#keymap    ;3
    LD BC,#0XF782     ;3
    OUT (C),C       ;4
    LD BC,#0XF40E     ;3
    LD E,B          ;1
    OUT (C),C       ;4
    LD BC,#0XF6C0     ;3
    LD D,B          ;1
    OUT (C),C       ;4
    LD C,#0          ;2
    OUT (C),C       ;4
    LD BC,#0XF792     ;3
    OUT (C),C       ;4
    LD A,#0X40        ;2
    LD C,#0X4A        ;2 44
loop_cpc_scankeyboard:
	LD B,D          ;1
    OUT (C),A       ;4 SELECT LINE
    LD B,E          ;1
    INI             ;5 READ BITS AND WRITE INTO KEYMAP
    INC A           ;1
    CP C            ;1
    JR C,loop_cpc_scankeyboard       ;2/3 9*16+1*15=159
    LD BC,#0XF782     ;3
    OUT (C),C       ;4
    EI              ;1 8 =211 MICROSECONDS
    RET



cpc_TestKeyboard::	;Tomado de las rutinas básicas que aparecen
					;en los documentos de  Kevin Thacker

	DI
	LD BC, #0XF40E
	OUT (C), C
	LD BC, #0XF6C0
	OUT (C), C
	.DB #0XED,#0X71        ;    OUT (C),0
	LD BC, #0XF792
	OUT (C), C
	DEC B
	OUT (C), A
	LD B, #0XF4
	IN A, (C)
	LD BC, #0XF782
	OUT (C), C
	DEC B
	.DB #0XED,#0X71        ;    OUT (C),0
	CPL
	EI
	RET

linea:
	.DB #0
bte:
	.DB #0

keymap:
	.DB #0
	.DB #0
	.DB #0
	.DB #0
	.DB #0
	.DB #0
	.DB #0
	.DB #0
	.DB #0
	.DB #0

tecla_0: .DW #0x0204
;teclado_usable					; teclas del cursor, cada tecla está definida por su bit y su línea.
tabla_teclas:
tecla_0_x: 	.DW #0xffff		; bit 0, línea 2
tecla_1_x: 	.DW #0xffff		; bit 1, línea 1
tecla_2_x: 	.DW #0xffff		; bit 0, línea 1
tecla_3_x: 	.DW #0xffff		; bit 0, línea 4
tecla_4_x:	.DW #0xffff		; bit 0, línea 2
tecla_5_x:  .DW #0xffff		; bit 1, línea 1
tecla_6_x:  .DW #0xffff		; bit 0, línea 1
tecla_7_x:  .DW #0xffff		; bit 0, línea 4
tecla_8_x:  .DW #0xffff		; bit 0, línea 4
tecla_9_x:  .DW #0xffff		; bit 0, línea 4
tecla_10_x:  .DW #0xffff		; bit 0, línea 4
tecla_11_x:  .DW #0xffff		; bit 0, línea 4
tecla_12_x:  .DW #0xffff		; bit 0, línea 4
tecla_13_x:  .DW #0xffff		; bit 0, línea 4
tecla_14_x:  .DW #0xffff		; bit 0, línea 4
tecla_15_x:  .DW #0xffff		; bit 0, línea 4
; For increasing keys available just increase this word table
.DB #0











