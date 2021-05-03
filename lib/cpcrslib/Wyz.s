; ******************************************************
; **       Librería de rutinas para Amstrad CPC       **
; **	   Raúl Simarro, 	  Artaburu 2010           **
; **	   PLAYER programado por  WYZ		          **
; ******************************************************

;XLIB cpc_WyzPlayer



;XDEF CARGA_CANCION_WYZ
;XDEF INICIA_EFECTO_WYZ
;XDEF cpc_WyzSetPlayerOn0
;XDEF cpc_WyzSetPlayerOff0

;XDEF TABLA_SONG
;XDEF TABLA_EFECTOS
;XDEF TABLA_PAUTAS
;;XDEF TABLA_SONIDOS
;XDEF INTERRUPCION

;XDEF BUFFER_MUSICA
;XDEF direcc_tempo




;DEFINE BUFFER_DEC  = #0x100





; CPC PSG proPLAYER - WYZ 2010
;XREF INTERRUPCION


.globl _cpc_WyzConfigurePlayer

_cpc_WyzConfigurePlayer::

	LD HL,#2
    ADD HL,SP
    LD a,(HL)

	LD (#INTERR),A
	RET


.globl _cpc_WyzInitPlayer

_cpc_WyzInitPlayer::

; la entrada indica las tablas de canciones, pautas, efectos,... sólo hay que inicializar esos datos
; en la librería
	LD IX,#2
	ADD IX,SP

	LD L,6 (IX)
	LD H,7 (IX)
	LD (#TABLA_SONG0),HL
	LD L,4 (IX)
	LD H,5 (IX)
	LD (#TABLA_EFECTOS0),HL
	LD L,2 (IX)
	LD H,3 (IX)
	LD (#TABLA_PAUTAS0),HL
	LD L,0 (IX)
	LD H,1 (IX)
	LD (#TABLA_SONIDOS0),HL
	RET

.globl _cpc_WyzLoadSong

_cpc_WyzLoadSong::
	LD HL,#2
	ADD HL,SP
	LD A,(HL)
	JP CARGA_CANCION_WYZ0


.globl _cpc_WyzSetTempo

_cpc_WyzSetTempo::
	LD HL,#2
	ADD HL,SP
	LD A,(HL)
	ld (#dir_tempo+1),a
	ret


.globl _cpc_WyzStartEffect

_cpc_WyzStartEffect::
	LD HL,#2
	ADD HL,SP
	LD c,(HL)
	INC HL
	LD b,(HL)
	;AHORA TIENE 2 parámetros: C:canal, B:numero efecto
	JP INICIA_EFECTO_WYZ0

;.globl _cpc_WyzStartSound

;_cpc_WyzStartSound::
;	LD HL,#2
;	ADD HL,SP
;	LD A,(HL)
;	JP INICIA_SONIDO_WYZ

.globl _cpc_WyzTestPlayer

_cpc_WyzTestPlayer::
	LD HL,#INTERR
	LD A,(HL)
	LD L,A
	LD H,#0
	RET

_cpc_WyzPlayer::

;.globl	_cpc_WyzSetPlayerOn
;.globl _cpc_WyzSetPlayerOn1

;_cpc_WyzSetPlayerOn::
;_cpc_WyzSetPlayerOn1::
	;El player funcionará por interrupciones.
;	DI
;	ld a,(#0x0038)
;	ld (#datos_int),a
;	ld (#salto_int),a
;	ld a,(#0x0039)
;	ld (#datos_int+1),a
;	ld (#salto_int+1),a
;	ld a,(#0x003a)
;	ld (#datos_int+2),a
;	ld (#salto_int+2),a
;
;	ld a,#0xC3
;	ld (#0x0038),a
;	ld HL,#INICIO
;	ld (#0x0039),HL
;	EI
;	ret

.globl _cpc_WyzSetPlayerOff
;.globl _cpc_WyzSetPlayerOff1
_cpc_WyzSetPlayerOff::
;_cpc_WyzSetPlayerOff1::

	;apago todos los sonidos poniendo los registros a 0
	call PLAYER_OFF
	ret

	;DI
	;Restaura salto original
	;ld a,(#datos_int)	;guardo el salto original
	;ld (#0x0038),A
	;ld a,(#datos_int+1)	;guardo el salto original
	;ld (#0x0039),A
	;ld a,(#datos_int+2)	;guardo el salto original
	;ld (#0x003a),A

	;EI
	;ret





;___________________________________________________________

             ;   .db     "PSG PROPLAYER BY WYZ'10"

;___________________________________________________________


;___________________________________________________________

.globl _cpc_WyzPlayerISR

_cpc_WyzPlayerISR::

INICIO:


	;primero mira si toca tocar :P
	;push af
	LD A,(#contador)
	DEC A
	LD (#contador),A
	OR #0
	JP NZ,termina_int
dir_tempo:
	LD A,#6
 	LD (#contador),A

 	PUSH BC
	PUSH HL
	PUSH DE
	PUSH IX
	PUSH IY



		CALL    ROUT
		LD	HL,#PSG_REG
		LD	DE,#PSG_REG_SEC
		LD	BC,#14
		LDIR



        CALL    PLAY
		CALL    REPRODUCE_SONIDO

		LD	HL,#PSG_REG_SEC
		LD	DE,#PSG_REG_EF
		LD	BC,#14
		LDIR

		;De este modo, prevalece el efecto
		CALL	REPRODUCE_EFECTO_A
		CALL	REPRODUCE_EFECTO_B
		CALL	REPRODUCE_EFECTO_C
		CALL    ROUT_EF



	POP IY
	POP IX
	POP DE
	POP HL
	POP BC

termina_int:
		pop af
		ei
		ret
;salto_int:
;.db #0,#0,#0



contador: .db #0
;datos_int: .db #0,#0,#0		; Se guardan 3 BYTES!!!! (Dedicado a Na_th_an, por los desvelos)



;INICIA EL SONIDO Nº (A)

;INICIA EL SONIDO Nº (A)

INICIA_EFECTO_WYZ0:

;INICIA EL SONIDO Nº (B) EN EL CANAL (C)
		LD	A,C
		CP	#0
		JP	Z,INICIA_EFECTO_A
		CP	#1
		JP	Z,INICIA_EFECTO_B
		CP	#2
		JP	Z,INICIA_EFECTO_C
		;JP INICIA_EFECTO_A
		RET


;REPRODUCE EFECTOS




;REPRODUCE EFECTOS CANAL A


REPRODUCE_EFECTO_A:
                LD      HL,#INTERR
                BIT     3,(HL)          ;ESTA ACTIVADO EL EFECTO?
                RET     Z
                LD      HL,(#PUNTERO_EFECTO_A)
                LD      A,(HL)
                CP      #0xFF
                JR      Z,FIN_EFECTO_A
                CALL 	BLOQUE_COMUN
                LD      (#PUNTERO_EFECTO_A),HL
                LD      0 (IX),B
                LD      1 (IX),C
                LD      8 (IX),A
                RET
FIN_EFECTO_A:
   				LD      HL,#INTERR
                RES     3,(HL)
                XOR     A
                LD      (#PSG_REG_EF+0),A
                LD      (#PSG_REG_EF+1),A
                LD		(#PSG_REG_EF+8),A
                RET

REPRODUCE_EFECTO_B:
                LD      HL,#INTERR
                BIT     5,(HL)          ;ESTA ACTIVADO EL EFECTO?
                RET     Z
                LD      HL,(#PUNTERO_EFECTO_B)
                LD      A,(HL)
                CP      #0xFF
                JR      Z,FIN_EFECTO_B
                CALL 	BLOQUE_COMUN
                LD      (#PUNTERO_EFECTO_B),HL
                LD      2 (IX),B
                LD      3 (IX),C
                LD      9 (IX),A
                RET
FIN_EFECTO_B:
   				LD      HL,#INTERR
                RES     5,(HL)
                XOR     A
                LD      (#PSG_REG_EF+2),A
                LD      (#PSG_REG_EF+3),A
                LD		(#PSG_REG_EF+9),A
                RET

REPRODUCE_EFECTO_C:
                LD      HL,#INTERR
                BIT     6,(HL)          ;ESTA ACTIVADO EL EFECTO?
                RET     Z
                LD      HL,(#PUNTERO_EFECTO_C)
                LD      A,(HL)
                CP      #0xFF
                JR      Z,FIN_EFECTO_C
                CALL 	BLOQUE_COMUN
                LD      (#PUNTERO_EFECTO_C),HL
                LD      4 (IX),B
                LD      5 (IX),C
                LD      10 (IX),A
                RET
FIN_EFECTO_C:
   				LD      HL,#INTERR
                RES     6,(HL)
                XOR     A
                LD      (#PSG_REG_EF+4),A
                LD      (#PSG_REG_EF+5),A
                LD		(#PSG_REG_EF+10),A
                RET

BLOQUE_COMUN:
				LD IX,#PSG_REG_EF
                LD B,A
                INC     HL
                LD      A,(HL)
                RRCA
                RRCA
                RRCA
                RRCA
                AND     #0b00001111
                LD C,A
                LD      A,(HL)
                AND     #0b00001111
                INC     HL
				RET

INICIA_EFECTO_A:
				LD		A,B
				LD      HL,(#TABLA_EFECTOS0)
                CALL    EXT_WORD
                LD      (#PUNTERO_EFECTO_A),HL
                LD      HL,#INTERR
                SET     3,(HL)
                RET

INICIA_EFECTO_B:
				LD		A,B
				LD      HL,(#TABLA_EFECTOS0)
                CALL    EXT_WORD
                LD      (#PUNTERO_EFECTO_B),HL
                LD      HL,#INTERR
                SET     5,(HL)
                RET

INICIA_EFECTO_C:
				LD		A,B
				LD      HL,(#TABLA_EFECTOS0)
                CALL    EXT_WORD
                LD      (#PUNTERO_EFECTO_C),HL
                LD      HL,#INTERR
                SET     6,(HL)
                RET



INICIA_SONIDO:
				LD       HL,(#TABLA_SONIDOS0)
                CALL    EXT_WORD
                LD      (#PUNTERO_SONIDO),HL
                LD      HL,#INTERR
                SET     2,(HL)
                RET
;PLAYER OFF

PLAYER_OFF:
		LD	HL,#INTERR
		RES	1,(HL)

		XOR	A
		LD	HL,#PSG_REG
		LD	DE,#PSG_REG+1
		LD	BC,#14
		LD	(HL),A
		LDIR

		LD	HL,#PSG_REG_SEC
		LD	DE,#PSG_REG_SEC+1
		LD	BC,#14
		LD	(HL),A
		LDIR

		CALL	ROUT
		CALL	FIN_SONIDO
		RET




CARGA_CANCION_WYZ0:
        DI
        push af
		CALL	PLAYER_OFF
		pop af
; MUSICA DATOS INICIALES




				LD		DE,#0x0010					;  Nº BYTES RESERVADOS POR CANAL
                LD      HL,#BUFFER_DEC       	;* RESERVAR MEMORIA PARA BUFFER DE SONIDO!!!!!
                LD      (#CANAL_A),HL

                ADD     HL,DE
                LD      (#CANAL_B),HL

                ADD     HL,DE
                LD      (#CANAL_C),HL

                ADD     HL,DE
                LD      (#CANAL_P),HL

                ;LD      A,#0             	;* CANCION Nº 0
                CALL    CARGA_CANCION

               	LD A,#6
 				LD (#contador),A

;PANTALLA
		EI
		ret



;CARGA UNA CANCION
;IN:(A)=Nº DE CANCION

CARGA_CANCION:
				LD      HL,#INTERR       ;CARGA CANCION

                SET     1,(HL)          ;REPRODUCE CANCION
                LD      HL,#SONG
                LD      (HL),A          ;Nº A



;DECODIFICAR
;IN-> INTERR 0 ON
;     SONG

;CARGA CANCION SI/NO

DECODE_SONG:
			    LD      A,(#SONG)

;LEE CABECERA DE LA CANCION
;BYTE 0=TEMPO

                ;LD      HL,TABLA_SONG
                LD      HL,(#TABLA_SONG0)
                CALL    EXT_WORD
                LD      A,(HL)
                LD      (#TEMPO),A
		XOR	A
		LD	(#TTEMPO),A

;HEADER BYTE 1
;(-|-|-|-|-|-|-|LOOP)

                INC	HL		;LOOP 1=ON/0=OFF?
                LD	A,(HL)
                BIT	0,A
                JR	Z,NPTJP0
                PUSH	HL
                LD	HL,#INTERR
                SET	4,(HL)
                POP	HL


NPTJP0:
		        INC	HL		;2 BYTES RESERVADOS
                INC	HL
                INC	HL

;BUSCA Y GUARDA INICIO DE LOS CANALES EN EL MODULO MUS


		LD	(#PUNTERO_P_DECA),HL
		LD	E,#0x3F			;CODIGO INTRUMENTO 0
		LD	B,#0xFF			;EL MODULO DEBE TENER UNA LONGITUD MENOR DE #0xFF00 ... o_O!
BGICMODBC1:
		XOR	A			;BUSCA EL BYTE 0
		CPIR
		DEC	HL
		DEC	HL
		LD	A,E			;ES EL INSTRUMENTO 0??
		CP	(HL)
		INC	HL
		INC	HL
		JR	Z,BGICMODBC1

		LD	(#PUNTERO_P_DECB),HL

BGICMODBC2:
		XOR	A			;BUSCA EL BYTE 0
		CPIR
		DEC	HL
		DEC	HL
		LD	A,E
		CP	(HL)			;ES EL INSTRUMENTO 0??
		INC	HL
		INC	HL
		JR	Z,BGICMODBC2

		LD	(#PUNTERO_P_DECC),HL

BGICMODBC3:
		XOR	A			;BUSCA EL BYTE 0
		CPIR
		DEC	HL
		DEC	HL
		LD	A,E
		CP	(HL)			;ES EL INSTRUMENTO 0??
		INC	HL
		INC	HL
		JR	Z,BGICMODBC3
		LD	(#PUNTERO_P_DECP),HL


;LEE DATOS DE LAS NOTAS
;(|)(|||||) LONGITUD\NOTA

INIT_DECODER:
			    LD      DE,(#CANAL_A)
                LD      (#PUNTERO_A),DE
                LD	HL,(#PUNTERO_P_DECA)
                CALL    DECODE_CANAL    ;CANAL A
                LD	(#PUNTERO_DECA),HL

                LD      DE,(#CANAL_B)
                LD      (#PUNTERO_B),DE
                LD	HL,(#PUNTERO_P_DECB)
                CALL    DECODE_CANAL    ;CANAL B
                LD	(#PUNTERO_DECB),HL

                LD      DE,(#CANAL_C)
                LD      (#PUNTERO_C),DE
                LD	HL,(#PUNTERO_P_DECC)
                CALL    DECODE_CANAL    ;CANAL C
                LD	(#PUNTERO_DECC),HL

                LD      DE,(#CANAL_P)
                LD      (#PUNTERO_P),DE
                LD	HL,(#PUNTERO_P_DECP)
                CALL    DECODE_CANAL    ;CANAL P
                LD	(#PUNTERO_DECP),HL

                RET


;DECODIFICA NOTAS DE UN CANAL
;IN (DE)=DIRECCION DESTINO
;NOTA=0 FIN CANAL
;NOTA=1 SILENCIO
;NOTA=2 PUNTILLO
;NOTA=3 COMANDO I

DECODE_CANAL:
			    LD      A,(HL)
                AND     A               ;FIN DEL CANAL?
                JR      Z,FIN_DEC_CANAL
                CALL    GETLEN

                CP      #0b00000001       ;ES SILENCIO?
                JR      NZ,NO_SILENCIO
                SET     6,A
                JR      NO_MODIFICA

NO_SILENCIO:
			    CP      #0b00111110        ;ES PUNTILLO?
                JR      NZ,NO_PUNTILLO
                OR      A
                RRC     B
                XOR     A
                JR      NO_MODIFICA

NO_PUNTILLO:
			    CP      #0b00111111        ;ES COMANDO?
                JR      NZ,NO_MODIFICA
                BIT     0,B             ;COMADO=INSTRUMENTO?
                JR      Z,NO_INSTRUMENTO
                LD      A,#0b11000001      ;CODIGO DE INSTRUMENTO
                LD      (DE),A
                INC     HL
                INC     DE
                LD      A,(HL)          ;Nº DE INSTRUMENTO
                LD      (DE),A
                INC     DE
                INC	HL
                JR      DECODE_CANAL

NO_INSTRUMENTO:
				BIT     2,B
                JR      Z,NO_ENVOLVENTE
                LD      A,#0b11000100      ;CODIGO ENVOLVENTE
                LD      (DE),A
                INC     DE
                INC	HL
                JR      DECODE_CANAL

NO_ENVOLVENTE:
				BIT     1,B
                JR      Z,NO_MODIFICA
                LD      A,#0b11000010      ;CODIGO EFECTO
                LD      (DE),A
                INC     HL
                INC     DE
                LD      A,(HL)
                CALL    GETLEN

NO_MODIFICA:
			    LD      (DE),A
                INC     DE
                XOR     A
                DJNZ    NO_MODIFICA
		SET     7,A
		SET 	0,A
                LD      (DE),A
                INC     DE
                INC	HL
                RET			;** JR      DECODE_CANAL

FIN_DEC_CANAL:
				SET     7,A
                LD      (DE),A
                INC     DE
                RET

GETLEN:
		         LD      B,A
                AND     #0b00111111
                PUSH    AF
                LD      A,B
                AND     #0b11000000
                RLCA
                RLCA
                INC     A
                LD      B,A
                LD      A,#0b10000000
DCBC0:
	          RLCA
                DJNZ    DCBC0
                LD      B,A
                POP     AF
                RET






;PLAY __________________________________________________


PLAY:
	          	LD      HL,#INTERR       ;PLAY BIT 1 ON?
                BIT     1,(HL)
                RET     Z
;TEMPO
                LD      HL,#TTEMPO       ;CONTADOR TEMPO
                INC     (HL)
                LD      A,(#TEMPO)
                CP      (HL)
                JR      NZ,PAUTAS
                LD      (HL),#0

;INTERPRETA
                LD      IY,#PSG_REG
                LD      IX,#PUNTERO_A
                LD      BC,#PSG_REG+8
                CALL    LOCALIZA_NOTA
                LD      IY,#PSG_REG+2
                LD      IX,#PUNTERO_B
                LD      BC,#PSG_REG+9
                CALL    LOCALIZA_NOTA
                LD      IY,#PSG_REG+4
                LD      IX,#PUNTERO_C
                LD      BC,#PSG_REG+10
                CALL    LOCALIZA_NOTA
                LD      IX,#PUNTERO_P    ;EL CANAL DE EFECTOS ENMASCARA OTRO CANAL
                CALL    LOCALIZA_EFECTO

;PAUTAS

PAUTAS:
		        LD      IY,#PSG_REG+0
                LD      IX,#PUNTERO_P_A
                LD      HL,#PSG_REG+8
                CALL    PAUTA           ;PAUTA CANAL A
                LD      IY,#PSG_REG+2
                LD      IX,#PUNTERO_P_B
                LD      HL,#PSG_REG+9
                CALL    PAUTA           ;PAUTA CANAL B
                LD      IY,#PSG_REG+4
                LD      IX,#PUNTERO_P_C
                LD      HL,#PSG_REG+10
                CALL    PAUTA           ;PAUTA CANAL C

                RET



;REPRODUCE EFECTOS DE SONIDO

REPRODUCE_SONIDO:

				LD      HL,#INTERR
                BIT     2,(HL)          ;ESTA ACTIVADO EL EFECTO?
                RET     Z
                LD      HL,(#PUNTERO_SONIDO)
                LD      A,(HL)
                CP      #0xFF
                JR      Z,FIN_SONIDO
                LD      (#PSG_REG_SEC+4),A
                INC     HL
                LD      A,(HL)
                RRCA
                RRCA
                RRCA
                RRCA
                AND     #0b00001111
                LD      (#PSG_REG_SEC+5),A
                LD      A,(HL)
                AND     #0b00001111
                LD      (#PSG_REG_SEC+10),A
                INC     HL
                LD      A,(HL)
                AND     A
                JR      Z,NO_RUIDO
                LD      (#PSG_REG_SEC+6),A
                LD      A,#0b10011000
                JR      SI_RUIDO
NO_RUIDO:
		        LD      A,#0b10111000
SI_RUIDO:
		        LD      (#PSG_REG_SEC+7),A

                INC     HL
                LD      (#PUNTERO_SONIDO),HL
                RET
FIN_SONIDO:
			    LD      HL,#INTERR
                RES     2,(HL)

FIN_NOPLAYER:
				LD      A,#0b10111000 		;2 BITS ALTOS PARA MSX / AFECTA AL CPC???
       			LD      (#PSG_REG+7),A
                RET

;VUELCA BUFFER DE SONIDO AL PSG

;VUELCA BUFFER DE SONIDO AL PSG

ROUT:
       	XOR 	A
		LD 	HL,#PSG_REG_SEC
LOUT:
		CALL 	WRITEPSGHL
		INC 	A
		CP 	#13
		JR 	NZ,LOUT
		LD	A,(HL)
		AND 	A
		RET 	Z
		LD	A,#13
		CALL 	WRITEPSGHL
		XOR	A
		LD      (#PSG_REG+13),A
		LD      (#PSG_REG_SEC+13),A
		RET


ROUT_EF:
       	XOR 	A
		LD 	HL,#PSG_REG_EF
LOUT_EF:
		CALL 	WRITEPSGHL
		INC 	A
		CP 	#13
		JR 	NZ,LOUT_EF
		LD	A,(HL)
		AND 	A
		RET 	Z
		LD	A,#13
		CALL 	WRITEPSGHL
		XOR	A
		LD      (#PSG_REG_EF+13),A
		RET
;; A = REGISTER
;; (HL) = VALUE
WRITEPSGHL:
		LD 	B,#0xF4
		OUT 	(C),A
		LD 	BC,#0xF6C0
		OUT 	(C),C
		.db 	#0xED
		.db 	#0x71
		LD 	B,#0xF5
		OUTI
		LD 	BC,#0xF680
		OUT 	(C),C
		.db 	#0xED
		.db 	#0x71
		RET

;LOCALIZA NOTA CANAL A
;IN (PUNTERO_A)

LOCALIZA_NOTA:
			    LD      L,0 (IX)       		;HL=(PUNTERO_A_C_B)
                LD      H,1 (IX)
                LD      A,(HL)
                AND     #0b11000000       		;COMANDO?
                CP      #0b11000000
                JR      NZ,LNJP0

;BIT(0)=INSTRUMENTO

COMANDOS:
		        LD      A,(HL)
                BIT     0,A             	;INSTRUMENTO
                JR      Z,COM_EFECTO

                INC     HL
                LD      A,(HL)          	;Nº DE PAUTA
                INC     HL
                LD      0 (IX),L
                LD      1 (IX),H
                ;LD      HL,TABLA_PAUTAS
                LD      HL,(#TABLA_PAUTAS0)
                CALL    EXT_WORD
                LD      18 (IX),L
                LD      19 (IX),H
                LD      12 (IX),L
                LD      13 (IX),H
                LD      L,C
                LD      H,B
                RES     4,(HL)        		;APAGA EFECTO ENVOLVENTE
                XOR     A
                LD      (#PSG_REG_SEC+13),A
                LD	(#PSG_REG+13),A
                JR      LOCALIZA_NOTA

COM_EFECTO:
			    BIT     1,A             	;EFECTO DE SONIDO
                JR      Z,COM_ENVOLVENTE

                INC     HL
                LD      A,(HL)
                INC     HL
                LD      0 (IX),L
                LD      1 (IX),H
                CALL    INICIA_SONIDO
                RET

COM_ENVOLVENTE:
				BIT     2,A
                RET     Z               	;IGNORA - ERROR

                INC     HL
                LD      0 (IX),L
                LD      1 (IX),H
                LD      L,C
                LD      H,B
                LD	(HL),#0b00010000           ;ENCIENDE EFECTO ENVOLVENTE
                JR      LOCALIZA_NOTA


LNJP0:
			    LD      A,(HL)
                INC     HL
                BIT     7,A
                JR      Z,NO_FIN_CANAL_A	;
                BIT	0,A
                JR	Z,FIN_CANAL_A

FIN_NOTA_A:
		LD  E,6 (IX)
		LD	D,7 (IX)	;PUNTERO BUFFER AL INICIO
		LD	0 (IX),E
		LD	1 (IX),D
		LD	L,30 (IX)	;CARGA PUNTERO DECODER
		LD	H,31 (IX)
		PUSH	BC
                CALL    DECODE_CANAL    ;DECODIFICA CANAL
                POP	BC
                LD	30 (IX),L	;GUARDA PUNTERO DECODER
                LD	31 (IX),H
                JP      LOCALIZA_NOTA

FIN_CANAL_A:
			    LD	HL,#INTERR	;LOOP?
                BIT	4,(HL)
                JR      NZ,FCA_CONT
                CALL	PLAYER_OFF
                RET

FCA_CONT:
		LD	L,24 (IX)	;CARGA PUNTERO INICIAL DECODER
		LD	H,25 (IX)
		LD	30 (IX),L
		LD	31 (IX),H
		JR      FIN_NOTA_A

NO_FIN_CANAL_A:
				LD      0 (IX),L        ;(PUNTERO_A_B_C)=HL GUARDA PUNTERO
                LD      1 (IX),H
                AND     A               ;NO REPRODUCE NOTA SI NOTA=0
                JR      Z,FIN_RUTINA
                BIT     6,A             ;SILENCIO?
                JR      Z,NO_SILENCIO_A
                LD	A,(BC)
                AND	#0b00010000
                JR	NZ,SILENCIO_ENVOLVENTE
                XOR     A
                LD	(BC),A		;RESET VOLUMEN
                LD	0 (IY),A
                LD	1 (IY),A
				RET

SILENCIO_ENVOLVENTE:
				LD	A,#0xFF
                LD	(#PSG_REG+11),A
                LD	(#PSG_REG+12),A
                XOR	A
                LD	(#PSG_REG+13),A
                LD	0 (IY),A
                LD	1 (IY),A
                RET

NO_SILENCIO_A:
				CALL    NOTA            ;REPRODUCE NOTA
                LD      L,18 (IX)       ;HL=(PUNTERO_P_A0) RESETEA PAUTA
                LD      H,19 (IX)
                LD      12 (IX),L       ;(PUNTERO_P_A)=HL
                LD      13 (IX),H
FIN_RUTINA:
			    RET


;LOCALIZA EFECTO
;IN HL=(PUNTERO_P)

LOCALIZA_EFECTO:
				LD      L,0 (IX)       ;HL=(PUNTERO_P)
                LD      H,1 (IX)
                LD      A,(HL)
                CP      #0b11000010
                JR      NZ,LEJP0

                INC     HL
                LD      A,(HL)
                INC     HL
                LD      0 (IX),L
                LD      1 (IX),H
                CALL    INICIA_SONIDO
                RET


LEJP0:
	            INC     HL
                BIT     7,A
                JR      Z,NO_FIN_CANAL_P	;
                BIT	0,A
                JR	Z,FIN_CANAL_P
FIN_NOTA_P:
		LD      DE,(#CANAL_P)
		LD	0 (IX),E
		LD	1 (IX),D
		LD	HL,(#PUNTERO_DECP)	;CARGA PUNTERO DECODER
		PUSH	BC
		CALL    DECODE_CANAL    	;DECODIFICA CANAL
		POP	BC
                LD	(#PUNTERO_DECP),HL	;GUARDA PUNTERO DECODER
                JP      LOCALIZA_EFECTO

FIN_CANAL_P:
		LD	HL,(#PUNTERO_P_DECP)	;CARGA PUNTERO INICIAL DECODER
		LD	(#PUNTERO_DECP),HL
		JR      FIN_NOTA_P

NO_FIN_CANAL_P:
				LD      0 (IX),L        ;(PUNTERO_A_B_C)=HL GUARDA PUNTERO
                LD      1 (IX),H
                RET

; PAUTA DE LOS 3 CANALES
; IN:(IX):PUNTERO DE LA PAUTA
;    (HL):REGISTRO DE VOLUMEN
;    (IY):REGISTROS DE FRECUENCIA

; FORMATO PAUTA
;	    7    6     5     4   3-0                     3-0
; BYTE 1 (LOOP|OCT-1|OCT+1|SLIDE|VOL) - BYTE 2 ( | | | |PITCH)

PAUTA:
		        BIT     4,(HL)        ;SI LA ENVOLVENTE ESTA ACTIVADA NO ACTUA PAUTA
                RET     NZ

		LD	A,0 (IY)
		LD	B,1 (IY)
		OR	B
		RET	Z


                PUSH	HL
                ;LD      L,(IX+0)
                ;LD      H,(IX+1)

                ;LD	A,(HL)		;COMPRUEBA SLIDE BIT 4
		;BIT	4,A
		;JR	Z,PCAJP4
		;LD	L,(IY+0)	;FRECUENCIA FINAL
		;LD	H,(IY+1)
		;SBC	HL,DE
		;JR	Z,PCAJP4
		;JR	C,SLIDE_POS
		;EX	DE,HL
		;RRC	D		;/4
		;RR	E
		;RRC	D
		;RR	E


		;ADC	HL,DE
		;LD	(IY+0),L
		;LD	(IY+1),H
SLIDE_POS:
		;POP	HL
		;RET

PCAJP4:
		        LD      L,0 (IX)
                LD      H,1 (IX)
		LD	A,(HL)

		BIT     7,A		;LOOP / EL RESTO DE BITS NO AFECTAN
                JR      Z,PCAJP0
                AND     #0b00011111        ;LOOP PAUTA (0,32)X2!!!-> PARA ORNAMENTOS
                RLCA			;X2
                LD      D,#0
                LD      E,A
                SBC     HL,DE
                LD      A,(HL)

PCAJP0:
		BIT	6,A		;OCTAVA -1
		JR	Z,PCAJP1
		LD	E,0 (IY)
		LD	D,1 (IY)

		AND	A
		RRC	D
		RR	E
		LD	0 (IY),E
		LD	1 (IY),D
		JR	PCAJP2

PCAJP1:
		BIT	5,A		;OCTAVA +1
		JR	Z,PCAJP2
		LD	E,0 (IY)
		LD	D,1 (IY)

		AND	A
		RLC	E
		RL	D
		LD	0 (IY),E
		LD	1 (IY),D


PCAJP2:
		INC     HL
		PUSH	HL
		LD	E,A
		LD	A,(HL)		;PITCH DE FRECUENCIA
		LD	L,A
		AND	A
		LD	A,E
		JR	Z,ORNMJP1

                LD	A,0 (IY)	;SI LA FRECUENCIA ES 0 NO HAY PITCH
                ADD	A,1 (IY)
                AND	A
                LD	A,E
                JR	Z,ORNMJP1


		BIT	7,L
		JR	Z,ORNNEG
		LD	H,#0xFF
		JR	PCAJP3
ORNNEG:
		LD	H,#0

PCAJP3:
		LD	E,0 (IY)
		LD	D,1 (IY)
		ADC	HL,DE
		LD	0 (IY),L
		LD	1 (IY),H
ORNMJP1:
		POP	HL

		INC	HL
                LD      0 (IX),L
                LD      1 (IX),H
PCAJP5:
         POP	HL
                AND	#0b00001111 	;VOLUMEN FINAL
                LD      (HL),A
                RET



;NOTA : REPRODUCE UNA NOTA
;IN (A)=CODIGO DE LA NOTA
;   (IY)=REGISTROS DE FRECUENCIA


NOTA:
           ;ADD	6		;*************************
		LD      L,C
                LD      H,B
                BIT     4,(HL)
                LD      B,A
                JR	NZ,EVOLVENTES
                LD	A,B
                LD      HL,#DATOS_NOTAS
                RLCA                    ;X2
                LD      D,#0
                LD      E,A
                ADD     HL,DE
                LD      A,(HL)
                LD      0 (IY),A
                INC     HL
                LD      A,(HL)
                LD      1 (IY),A
                RET

;IN (A)=CODIGO DE LA ENVOLVENTE
;   (IY)=REGISTRO DE FRECUENCIA

EVOLVENTES:
		PUSH	AF
		CALL	ENV_RUT1
		LD	DE,#0x0000
		LD      0 (IY),E
                LD     1 (IY),D

		POP	AF
		ADD	A,#48
		CALL	ENV_RUT1


		LD	A,E
                LD      (#PSG_REG+11),A
                LD	A,D
                LD      (#PSG_REG+12),A
                LD      A,#0x0E
                LD      (#PSG_REG+13),A
                RET

;IN(A) NOTA
ENV_RUT1:
	LD      HL,#DATOS_NOTAS
		RLCA                    ;X2
                LD      D,#0
                LD      E,A
                ADD     HL,DE
                LD	E,(HL)
		INC	HL
		LD	D,(HL)
                RET



EXT_WORD:
		        LD      D,#0
                SLA     A               ;*2
                LD      E,A
                ADD     HL,DE
                LD      E,(HL)
                INC     HL
                LD      D,(HL)
                EX      DE,HL
                RET

;BANCO DE INSTRUMENTOS 2 BYTES POR INT.

;(0)(RET 2 OFFSET)
;(1)(+-PITCH)


;BANCO DE INSTRUMENTOS 2 BYTES POR INT.

;(0)(RET 2 OFFSET)
;(1)(+-PITCH)

;.TABLA_PAUTAS .dw 	PAUTA_1,PAUTA_2,PAUTA_3,PAUTA_4,PAUTA_5,PAUTA_6,PAUTA_7;,PAUTA_8,PAUTA_9,PAUTA_10,PAUTA_11,PAUTA_12,PAUTA_13,PAUTA_14,PAUTA_15,PAUTA_16,PAUTA_17,PAUTA_18











;DATOS DE LOS EFECTOS DE SONIDO

;EFECTOS DE SONIDO



;.TABLA_SONIDOS  .dw    SONIDO1,SONIDO2,SONIDO3,SONIDO4,SONIDO5;,SONIDO6,SONIDO7;,SONIDO8

TABLA_PAUTAS0: .dw 0

TABLA_SONIDOS0: .dw 0


;DATOS MUSICA



;TABLA_SONG:     .dw    SONG_0;,SONG_1,SONG_2;,SONG_3          ;******** TABLA DE DIRECCIONES DE ARCHIVOS MUS

;DATOS_NOTAS:    .INCBIN "C:/EM/BRMSX/PLAYER/NOTAS.DAT"        ;DATOS DE LAS NOTAS


DATOS_NOTAS:
    .dw #0x0000,#0x0000

;		.dw	#0x41D,#0x3E2,#0x3AA,#0x376,#0x344,#0x315,#0x2E9,#0x2BF,#0x297,#0x272,#0x24F,#0x22E,#0x20E,#0x1F1,#0x1D5,#0x1BB
;		.dw	#0x1A2,#0x18A,#0x174,#0x15F,#0x14B,#0x139,#0x127,#0x117,#0x107,#0xF8,#0xEA,#0xDD
;		.dw	#0xD1,#0xC5,#0xBA,#0xAF,#0xA5,#0x9C,#0x93,#0x8B,#0x83,#0x7C,#0x75,#0x6E
;		.dw	#0x68,#0x62,#0x5D,#0x57,#0x52,#0x4E,#0x49,#0x45,#0x41,#0x3E,#0x3A,#0x37
;		.dw	#0x34,#0x31,#0x2E,#0x2B,#0x29,#0x27,#0x24,#0x22,#0x20,#0x1F,#0x1D,#0x1B
;		.dw	#0x1A,#0x18,#0x17,#0x15,#0x14,#0x13,#0x12,#0x11,#0x10,#0xF,#0xE,#0xD


.DW #1711,#1614,#1524,#1438,#1358,#1281,#1210,#1142,#1078,#1017
.DW #960,#906,#855,#807,#762,#719,#679,#641,#605,#571
.DW #539,#509,#480,#453,#428,#404,#381,#360,#339,#320
.DW #302,#285,#269,#254,#240,#227,#214,#202,#190,#180
.DW #170,#160,#151,#143,#135,#127,#120,#113,#107,#101
.DW #95,#90,#85,#80,#76,#71,#67,#64,#60,#57


SONG_0:
		;INCBIN	"WYAZOW.MUS"



; VARIABLES__________________________


INTERR:
         .db    #0            			  ;INTERRUPTORES 1=ON 0=OFF
                                        ;BIT 0=CARGA CANCION ON/OFF
                                        ;BIT 1=PLAYER ON/OFF
                                        ;BIT 2=SONIDOS ON/OFF
                                        ;BIT 3=EFECTOS ON/OFF

;MUSICA **** EL ORDEN DE LAS VARIABLES ES FIJO ******

TABLA_SONG0: .dw #0
TABLA_EFECTOS0: .dw #0

;.db      'P','S','G',' ','P','R','O','P','L','A','Y','E','R',' ','B','Y',' ','W','Y','Z','-','1','0'


SONG:           .db    #00               ;DBNº DE CANCION
TEMPO:          .db    #00               ;.dbTEMPO
TTEMPO:         .db    #00               ;.dbCONTADOR TEMPO
PUNTERO_A:      .dw   #00               ;DW PUNTERO DEL CANAL A
PUNTERO_B:     .dw   #00               ;DW PUNTERO DEL CANAL B
PUNTERO_C:      .dw   #00               ;DW PUNTERO DEL CANAL C

BUFFER_MUSICA:
CANAL_A:        .dw   #BUFFER_DEC       ;DW DIRECION DE INICIO DE LA MUSICA A
CANAL_B:        .dw   #00               ;DW DIRECION DE INICIO DE LA MUSICA B
CANAL_C:        .dw   #00               ;DW DIRECION DE INICIO DE LA MUSICA C

PUNTERO_P_A:    .dw   #00               ;DW PUNTERO PAUTA CANAL A
PUNTERO_P_B:    .dw   #00               ;DW PUNTERO PAUTA CANAL B
PUNTERO_P_C:    .dw   #00               ;DW PUNTERO PAUTA CANAL C

PUNTERO_P_A0:   .dw   #00               ;DW INI PUNTERO PAUTA CANAL A
PUNTERO_P_B0:   .dw   #00               ;DW INI PUNTERO PAUTA CANAL B
PUNTERO_P_C0:   .dw   #00               ;DW INI PUNTERO PAUTA CANAL C


PUNTERO_P_DECA:	.dw   #00		;DW PUNTERO DE INICIO DEL DECODER CANAL A
PUNTERO_P_DECB:	.dw   #00		;DW PUNTERO DE INICIO DEL DECODER CANAL B
PUNTERO_P_DECC:	.dw   #00		;DW PUNTERO DE INICIO DEL DECODER CANAL C

PUNTERO_DECA:	.dw   #00		;DW PUNTERO DECODER CANAL A
PUNTERO_DECB:	.dw   #00		;DW PUNTERO DECODER CANAL B
PUNTERO_DECC:	.dw   #00		;DW PUNTERO DECODER CANAL C


;CANAL DE EFECTOS - ENMASCARA OTRO CANAL

PUNTERO_P:       .dw   #00           	;DW PUNTERO DEL CANAL EFECTOS
CANAL_P:         .dw   #00           	;DW DIRECION DE INICIO DE LOS EFECTOS
PUNTERO_P_DECP: 	.dw   #00		;DW PUNTERO DE INICIO DEL DECODER CANAL P
PUNTERO_DECP: 	.dw   #00		;DW PUNTERO DECODER CANAL P

PSG_REG:         .db     #00,#00,#00,#00,#00,#00,#00,#0b10111000 ,#00,#00,#00,#00,#00,#00,#00    ;.db(11) BUFFER DE REGISTROS DEL PSG
PSG_REG_SEC:     .db     #00,#00,#00,#00,#00,#00,#00,#0b10111000 ,#00,#00,#00,#00,#00,#00,#00    ;.db(11) BUFFER SECUNDARIO DE REGISTROS DEL PSG

PSG_REG_EF:         .db     #00,#00,#00,#00,#00,#00,#00,#0b10111000 ,#00,#00,#00,#00,#00,#00,#00    ;.db(11) BUFFER DE REGISTROS DEL PSG

;ENVOLVENTE_A    EQU     #0xD033           ;DB
;ENVOLVENTE_B    EQU     #0xD034           ;DB
;ENVOLVENTE_C    EQU     #0xD035           ;DB




;EFECTOS DE SONIDO

N_SONIDO:       .db      #0               ;.db  NUMERO DE SONIDO
PUNTERO_SONIDO: .dw      #0               ;.dw  PUNTERO DEL SONIDO QUE SE REPRODUCE

;EFECTOS

N_EFECTO:       .db      #0               ;.db  NUMERO DE SONIDO
;PUNTERO_EFECTO .dw      0               ;.dw  PUNTERO DEL SONIDO QUE SE REPRODUCE

PUNTERO_EFECTO_A: 	.dw      #0             ;DW : PUNTERO DEL SONIDO QUE SE REPRODUCE
PUNTERO_EFECTO_B: 	.dw      #0             ;DW : PUNTERO DEL SONIDO QUE SE REPRODUCE
PUNTERO_EFECTO_C: 	.dw      #0             ;DW : PUNTERO DEL SONIDO QUE SE REPRODUCE











BUFFER_DEC: ; defs #0x40
.dw #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0		; 16 bytes
.dw #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0		; 32 bytes
.dw #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0		; 48 bytes
.dw #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0		; 64 bytes


;   .db     #0x00		;************************* mucha atencion!!!!
;.BUFFER_DEC defs 2048		;space dinamically asigned in source code compilation!!
					; aqui se decodifica la cancion hay que dejar suficiente espacio libre.
					;*************************

;DEFC CARGA_CANCION_WYZ = CARGA_CANCION_WYZ0
;DEFC INICIA_EFECTO_WYZ = INICIA_EFECTO_WYZ0
;DEFC cpc_WyzSetPlayerOn0 = cpc_WyzSetPlayerOn1
;DEFC cpc_WyzSetPlayerOff0 = cpc_WyzSetPlayerOff1
;DEFC TABLA_SONG = TABLA_SONG0
;DEFC TABLA_EFECTOS = TABLA_EFECTOS0
;DEFC TABLA_PAUTAS = TABLA_PAUTAS0
;DEFC TABLA_SONIDOS = TABLA_SONIDOS0
;DEFC INTERRUPCION = INTERR
;DEFC direcc_tempo = dir_tempo
