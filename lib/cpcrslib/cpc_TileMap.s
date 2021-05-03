PEEPHOLE = 0

.include "TileMap.h"



.globl _cpc_ResetTouchedTiles

_cpc_ResetTouchedTiles::
	LD HL,#_tiles_tocados
	LD (HL),#0xFF
	RET


.globl _cpc_InitTileMap

_cpc_InitTileMap::
	LD HL,#0
	LD (_tiles),HL
	RET


.globl _cpc_SetTile

_cpc_SetTile::

;	ld ix,#2
;	add ix,sp

;	ld e,1 (ix)
;	ld a,0 (ix)

	ld hl,#2
	add hl,sp
	ld a,(hl)
	inc hl
	ld e,(hl)
	inc hl
	ld c,(hl)

	;.include "multiplication2.asm"
		;LD    H, #ancho_pantalla_bytes/2
        ;LD    L, #0
		LD	  HL,#ancho_pantalla_bytes * 256 / 2
        LD    D, L
        LD    B, #8

MULT:   ADD   HL, HL
        JR    NC, NOADD
        ADD   HL, DE
NOADD:  DJNZ  MULT

	ld e,a
	;ld d,#0		; D ya es 0
	add hl,de

	ld de,#_pantalla_juego
	add hl,de
	ld (hl),c

	ret




; ******************************************************
; **       Librería de rutinas para Amstrad CPC       **
; **	   Raúl Simarro, 	  Artaburu 2007       **
; ******************************************************

.globl _cpc_ShowTileMap	;	para una pantalla de 64x160 bytes. Superbuffer 8192bytes



_cpc_ShowTileMap::

cont_normal:
	xor a
	ld (#contador_tiles),a
;Se busca el número de tiles en pantalla
	ld hl,(#ntiles)
	ld (#contador_tiles2),hl
	ld hl,#_pantalla_juego
	call transferir_pantalla_a_superbuffer

;parte donde se transfiere el superbuffer completo a la pantalla

	ld de,#posicion_inicial_superbuffer
	ld hl,#tiles_ocultos_ancho0*2
	add hl,de	;primero posiciona en ancho

	; Posición inicial lectura datos superbuffer
	ld de,#ancho_pantalla_bytes
	ld b,#tiles_ocultos_alto0*8
	XOR A
	CP B
	JR Z, NO_SUMA
bucle_alto_visible:
	add hl,de
	djnz bucle_alto_visible
NO_SUMA:
	push hl
	ld (#posicion_inicio_pantalla_visible_sb+1),HL


;;.otro_ancho
	ld b,#ancho_pantalla_bytes-4*(tiles_ocultos_ancho0)	;;nuevo ancho
	ld c,#alto_pantalla_bytes-16*(tiles_ocultos_alto0)			;;nuevo alto


;; a HL tb se le suma una cantidad
	ld de, #tiles_ocultos_alto0*2
	ld hl,#_posiciones_pantalla
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld hl, #2*tiles_ocultos_ancho0
	add hl,de
	ld (#posicion_inicio_pantalla_visible+1),HL
	ld (#posicion_inicio_pantalla_visible2+1),HL
	pop de	;origen
	;HL destino
	;DE origen
	;call cpc_PutSpTM		;cambiar la rutina por una que dibuje desde superbuffer
	;ret
	jp creascanes
; A partir de la dirección del vector de bloques se dibuja el mapeado en pantalla


transferir_pantalla_a_superbuffer:


	PUSH HL
	POP IX	;IX lleva los datos de la pantalla
	LD DE,(#_posiciones_super_buffer)
bucle_dibujado_fondo:
	;Leo en HL el tile a meter en el superbuffer
	LD L,0 (IX)
	LD H,#0
	ADD HL,HL	;x2
	ADD HL,HL	;x4
	ADD HL,HL	;x8
	ADD HL,HL	;x16
	LD BC,#_tiles
	ADD HL,BC	;hl apunta al tile a transferir
	;me falta conocer el destino. IY apunta al destino
	EX DE,HL
	PUSH HL
	call transferir_map_sbuffer		;DE origen HL destino

		; Inicio Mod. 29.06.2009
; Se cambia la forma de controlar el final de datos de tiles. El #0xFF ahora sí que se podrá utilizar.
	ld HL,(#contador_tiles2)
	dec HL
	LD (#contador_tiles2),HL
	LD A,H
	OR L
	;ret z
	jp z, ret2
; Fin    Mod. 29.06.2009
	POP HL
	INC IX	;Siguiente byte



;	LD A,(IX+0)
;	CP #0xFF	;El fin de los datos se marca con #0xFF, no hay un tile que sea #0xFF
	;RET Z
	EX DE,HL
	LD A,(#contador_tiles)
	CP #ancho_pantalla_bytes/2-1 ;31	;son 32 tiles de ancho
	JP Z,incremento2
	INC A
	LD (#contador_tiles),A
	INC DE
	INC DE	;para pasar a la siguiente posición
	;si ya se va por el 18 el salto es mayor, es
	JP bucle_dibujado_fondo

incremento2:
	XOR A
	LD (#contador_tiles),A
	LD BC, #7*ancho_pantalla_bytes+2 ;450 ; 64x7+2 48x7+2  1084 ;72x15+4
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	JP bucle_dibujado_fondo

contador_tiles: .DB 0
contador_tiles2: .DW 0
; Ahora se puede usar el tile 255
ntiles: .DW  ( alto_pantalla_bytes / 8 ) * ( ancho_pantalla_bytes / 2	)

ret2:
;Se busca el número de tiles en pantalla
	;ld hl,(ntiles)
	;ld (contador_tiles2),hl
	pop hl
ret


transferir_map_sbuffer:

		ld bc,#ancho_pantalla_bytes-1 

		.DB #0xfD
   		LD H,#8		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE

loop_alto_map_sbuffer:
loop_ancho_map_sbuffer:
	ld A,(DE)
	ld (HL),A
	inc de
	inc hl
	ld A,(DE)
	ld (HL),A
	inc de

	.DB #0xfD
	dec h
	ret z
;hay que sumar el ancho de la pantalla en bytes para pasar a la siguiente línea

	add HL,BC
	jp loop_alto_map_sbuffer


.globl _cpc_PutSpTM

_cpc_PutSpTM::	; dibujar en pantalla el sprite

;di
ld a,b
ld b,c
ld c,a
loop_alto_2_cpc_PutSpTM:
	push bc
	ld b,c
	push hl
loop_ancho_2_cpc_PutSpTM:
	ld A,(DE)
	ld (hl),a
	inc de
	inc hl
	djnz loop_ancho_2_cpc_PutSpTM

	;incremento DE con el ancho de la pantalla-el del sprite
	ex de,hl
ancho_mostrable:
	ld bc,#4*(tiles_ocultos_ancho0)
	add hl,bc
	ex de,hl
	pop hl
	ld A,H
	add #0x08
	ld H,A
	sub #0xC0
	jp nc,sig_linea_2_cpc_PutSpTM
	ld bc,#0xc050
	add HL,BC
sig_linea_2_cpc_PutSpTM:
	pop BC
	djnz loop_alto_2_cpc_PutSpTM
;ei
ret





.globl _cpc_ShowTileMap2

_cpc_ShowTileMap2::
	ld bc, #256*(ancho_pantalla_bytes-4*(tiles_ocultos_ancho0))+#alto_pantalla_bytes-16*(tiles_ocultos_alto0)

posicion_inicio_pantalla_visible:
	ld hl,#0000


posicion_inicio_pantalla_visible_sb:
	ld hl,#0000
papa:		; código de Xilen Wars
	di
	ld	(#auxsp),sp
	ld	sp,#tablascan
	ld	a,#alto_pantalla_bytes-16*(tiles_ocultos_alto0)	;16 alto
ppv0:
	pop	de		; va recogiendo de la pila!!
inicio_salto_ldi:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi

	ldi
	ldi

	ldi
	ldi
	ldi
	ldi


	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
CONT_salto_ldi:
	ld	de,#4*tiles_ocultos_ancho0
	add	hl,de

CONT_salto_ldi1:
	dec a
	jp nz, ppv0
	ld	sp,(#auxsp)
	ei
	ret

auxsp:	.DW	0





creascanes:
	ld	ix,#tablascan
posicion_inicio_pantalla_visible2:
	ld	hl,#0000
	ld	b, #alto_pantalla_bytes/8-2*tiles_ocultos_alto0 ; 20	; num de filas.
cts0:
	push	bc
	push	hl
	ld	b,#8
	ld	de,#2048
cts1:
	ld	0 (ix),l
	inc	ix
	ld	0 (ix),h
	inc	ix
	add	hl,de
	djnz	cts1
	pop	hl
	ld	bc,#80
	add	hl,bc
	pop	bc
	djnz	cts0
;	jp prepara_salto_ldi
prepara_salto_ldi:		; para el ancho visible de la pantalla:
	ld hl,#ancho_pantalla_bytes-4*tiles_ocultos_ancho0
	ld de,#inicio_salto_ldi
	add hl,hl
	add hl,de
	ld (hl),#0xc3
	inc hl
	ld de,#CONT_salto_ldi
	ld (hl),e
	inc hl
	ld (hl),d
	ret





; MIRAR SUMA DE COORDENADAS PARA HACER SOLO UNA BUSQUEDA DE TILES
.globl _cpc_PutSpTileMap

_cpc_PutSpTileMap::

.if PEEPHOLE-0
    ex de,hl
.else
    ld hl,#2                                    ;3
    add hl,sp                                    ;3

    ld e,(hl)                                    ;2
    inc hl                                        ;1
    ld d,(hl)                                    ;2
.endif



;según las coordenadas x,y que tenga el sprite, se dibuja en el buffer

;    ld hl,#2                                    ;3
;    add hl,sp                                    ;3
;    ld e,(hl)                                    ;2
;    inc hl                                        ;1
;    ld d,(hl)                                    ;2

    .db #0xdd
    ld l,e                                        ;2
    .db #0xdd
    ld h,d                                        ;2
                                                ; --> 15 NOPS

                                                ;Obtencion de
;dimensiones, solo usadas para calcular iteraciones -> BC
ld l,0 (ix)
ld h,1 (ix)        ;dimensiones del sprite
ld C,(hl)    ;; ANCHO
inc hl
ld B,(hl) ;; ANCHO
Dec b
Dec c
;->BC coord -1

    ld l,10 (ix)
    ld h,11 (ix)    ;recoje coordenadas anteriores

    ld e,8 (ix)
    ld d,9 (ix)
    ld 10 (ix),e
    ld 11 (ix),d


;Obtencion x0y0 -> HL
PUSH HL
Srl l  ; x0/2
Srl h
Srl h
Srl h ; y0/8
Ex de,hl  ;-> Guarda de con origen de loops

POP hl ;(recuperar coord xoyo)
Add hl,bc  ;(Suma de dimensiones)
Srl l ; (x0+ancho)/2
Srl h
Srl h
Srl h; (y0+alto)/2

xor a
SBC hl,de        ;diferencia entre bloque inicial y bloque con dimensiones

;Hl tiene iteraciones en i,j partiendo de origen loops
Ld a,h
Inc a
Ld (pasos_alto_xW+1),a
Ld a,l
Inc a
;Ld (pasos_ancho_x+1),a

;Loop from d, i veces
;Loop from e, j veces
jp macario
.db 'r','a','u','l'
macario:
pasos_ancho_xW:    ; *parametro
    ld b,a
bucle_pasos_anchoW:
    push de
pasos_alto_xW: ; *parametro
    ld c,#0
bucle_pasos_altoW:
        ; Mete E y D
            call _cpc_UpdTileTable
        inc d
        dec c
        jp nz,bucle_pasos_altoW

    pop de
    inc e
    dec b
    jp nz,bucle_pasos_anchoW

    ret




.globl _cpc_UpdTileTable

_cpc_UpdTileTable::
; En DE word a comprobar (fila/columna o al revés)
	LD HL,#_tiles_tocados
	;incorporo el tile en su sitio, guardo x e y
bucle_recorrido_tiles_tocados:
	LD A,(HL)
	CP #0xFF
	JP Z,incorporar_tile	;Solo se incorpora al llegar a un hueco
;	INC HL
;	PUSH HL
;	LD H,(HL)
;	LD L,A	
;	SBC HL,DE
;	POP HL
;	RET Z
;	INC HL
;	JP bucle_recorrido_tiles_tocados
	CP E
	JP Z, comprobar_segundo_byte
	INC HL
	INC HL
	JP bucle_recorrido_tiles_tocados
comprobar_segundo_byte:
	INC HL
	LD A,(HL)
	CP D
	RET Z	;los dos bytes son iguales, es el mismo tile. No se añade
	INC HL
	JP bucle_recorrido_tiles_tocados
	
		

incorporar_tile:
	LD (HL),E
	INC HL
	LD (HL),D
	INC HL
	LD (HL),#0xFF	;End of data
contkaka:
	RET


;_solo_tile0:
;LD HL,#_tiles
;jp _saltate

.globl _cpc_UpdScr

_cpc_UpdScr::
;lee la tabla de tiles tocados y va restaurando cada uno en su sitio.
	LD IX,#_tiles_tocados							;4
bucle_cpc_UpdScr:
	LD E, 0 (IX)									;5
	LD A,#0xFF										;2
	CP E											;1
	RET Z		;RETORNA SI NO HAY MÁS DATOS EN LA LISTA	;2/4
	LD D,1 (IX)										;5
	INC IX											;3
	INC IX											;3

posicionar_superbuffer:
;con la coordenada y nos situamos en la posición vertical y con x nos movemos a su sitio definitivo
	LD C,D
	SLA C  ;x2
	LD B,#0
	
	; puedo usar BC para el siguiente cálculo
	push bc
	
	LD HL,#_posiciones_super_buffer
	ADD HL,BC
	LD C,(HL)
	INC HL
	LD B,(HL)

	LD L,E
	SLA L
	LD H,#0

	ADD HL,BC
	
	pop bc
		;HL apunta a la posición correspondiente en superbuffer
	push hl

posicionar_tile:

	LD HL,#_tabla_y_ancho_pantalla
	ADD HL,BC
	LD C,(HL)
	INC HL
	LD B,(HL)
	LD L,E
	LD H,#0
	ADD HL,BC
;	LD DE,#_pantalla_juego
;	ADD HL,DE
	LD L,(HL) 
;	xor a
;	cp l
;	jp z, _solo_tile0
	
	LD H,#0
	
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL	;X16
	LD DE,#_tiles
	ADD HL,DE
	;HL apunta a los datos del tile
;_saltate:
	;ex de,hl
	pop de ;hl
	;RET



;	de: Posición buffer
;	hl: datos tile


transferir_map_sbuffer1:	;; ENVIA EL TILE AL SUPERBUFFER
	;ld bc,ancho_pantalla_bytes-2 ;63
	ldi									;5
	ldi		;de<-hl						;5
	ex de,hl							;1
	ld bc,#ancho_pantalla_bytes-2		;3
	ld a,c
	add HL,BC							;3
	ex de,hl							;1
	ldi									;5
	ldi									;5
	ex de,hl							;1
	ld c,a		;ld c,#ancho_pantalla_bytes-2		;2
	add HL,BC							;3
	ex de,hl							;1
	ldi
	ldi
	ex de,hl
	ld c,a		;ld c,#ancho_pantalla_bytes-2
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a		;ld c,#ancho_pantalla_bytes-2
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a		;ld c,#ancho_pantalla_bytes-2
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a		;ld c,#ancho_pantalla_bytes-2
	add HL,BC
	ex de,hl
	ldi
	ldi
	ex de,hl
	ld c,a		;ld c,#ancho_pantalla_bytes-2
	add HL,BC
	ex de,hl
	ldi
	ldi
jp bucle_cpc_UpdScr	
	


.globl _cpc_PutSpTileMap2b

_cpc_PutSpTileMap2b::

;según las coordenadas x,y que tenga el sprite, se dibuja en el buffer

  ; ld ix,#2
  ; add ix,sp


  ; ld l,0 (ix)
  ; ld h,1 (ix)	;HL apunta al sprite

  ; push hl
  ; pop ix


   	ld hl,#2									;3
	add hl,sp									;3
	ld e,(hl)									;2
	inc hl										;1
	ld d,(hl)									;2

	.db #0xdd
	ld l,e										;2
	.db #0xdd
	ld h,d										;2
												; --> 15 NOPS



  ;lo cambio para la rutina de multiplicar
    ld a,8 (ix)
    ld e,9 (ix)


;include "multiplication1.asm"


   	    ;ld    h, #ancho_pantalla_bytes
        ;LD    L, #0
		LD	  HL,#ancho_pantalla_bytes * 256        
        LD    D, L
        LD    B, #8

MULT2:   ADD   HL, HL
        JR    NC, NOADD2
        ADD   HL, DE
NOADD2:  DJNZ  MULT2





	;ld b,#0
	ld e,a
	add hl,de
	ld de,#posicion_inicial_superbuffer
	add hl,de
	;hl apunta a la posición en buffer (destino)


	ld 4 (ix),l		;update superbuffer address
    ld 5 (ix),h


	ld e,0 (ix)
    ld d,1 (ix)	;HL apunta al sprite

    ;con el alto del sprite hago las actualizaciones necesarias a la rutina
    ld a,(de)
    ld (#loop_alto_map_sbuffer2+2),a
    ld b,a
    ld a,#ancho_pantalla_bytes
    sub b
    ;ld (#ancho_22+1),a
    ld c,a
	inc de
	ld a,(de)
	inc de

	;ld a,16		;necesito el alto del sprite



sp_buffer_mask2:
	ld b,#0
ancho_22:
	;ld c,#ancho_pantalla_bytes-4 ;60	;;DEPENDE DEL ANCHO

	.db #0xDD
	LD H,A		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	;ld ixh,a
loop_alto_map_sbuffer2:
		.db #0xDD
		LD L,#4		;ANCHO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
		;ld ixl,#4
		ex de,hl
loop_ancho_map_sbuffer2:


		LD A,(hl)	;leo el byte del fondo
		;AND (HL)	;lo enmascaro
		;INC HL
		;OR (HL)		;lo enmascaro
		LD (de),A	;actualizo el fondo
		INC DE
		INC HL


		.db #0xDD
		DEC L		;resta ancho
		;dec ixl
		JP NZ,loop_ancho_map_sbuffer2

	   .db #0xDD
	   dec H
	   ;dec ixh
	   ret z
	   EX DE,HL
;hay que sumar 72 bytes para pasar a la siguiente línea
		add HL,BC
		jp loop_alto_map_sbuffer2


.globl _cpc_PutMaskSpTileMap2b

_cpc_PutMaskSpTileMap2b::
;según las coordenadas x,y que tenga el sprite, se dibuja en el buffer
 .if PEEPHOLE-0
	ex de,hl
.else

   	ld hl,#2									;3
	add hl,sp									;3
	ld e,(hl)									;2
	inc hl										;1
	ld d,(hl)									;2
.endif


;    ld hl,#2									;3
;	add hl,sp									;3
;	ld e,(hl)									;2
;	inc hl										;1
;	ld d,(hl)									;2

	.db #0xdd
	ld l,e										;2
	.db #0xdd
	ld h,d										;2
												; --> 15 NOPS


    ld a,8 (ix)
    ld e,9 (ix)

;include "multiplication1.asm"
   	    ;ld    h, #ancho_pantalla_bytes
        ;LD    L, #0
        LD	  HL,#ancho_pantalla_bytes * 256
        LD    D, L
        LD    B, #8

MULT3:   ADD   HL, HL
        JR    NC, NOADD3
        ADD   HL, DE
NOADD3:  DJNZ  MULT3



	;ld b,#0
	ld e,a
	add hl,de
	;HL=E*H+D





	ld de,#posicion_inicial_superbuffer
	add hl,de
	;hl apunta a la posición en buffer (destino)

	ld 4 (ix),l		;update superbuffer address
    ld 5 (ix),h

	ld e,0 (ix)
    ld d,1 (ix)	;HL apunta al sprite

    ;con el alto del sprite hago las actualizaciones necesarias a la rutina
    ld a,(de)
    ld (#loop_alto_map_sbuffer3+2),a
    ld b,a
    ld a,#ancho_pantalla_bytes
    sub b
    ;ld (#ancho_23+1),a
    ld c,a
	inc de
	ld a,(de)
	inc de

	;ld a,16		;necesito el alto del sprite



sp_buffer_mask3:
	ld b,#0
ancho_23:
	;ld c,#ancho_pantalla_bytes-4 ;60	;;DEPENDE DEL ANCHO

	.db  #0xdd
	LD H,A		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	;ld ixh,a
loop_alto_map_sbuffer3:
		.db  #0xdd
		LD L,#4		;ANCHO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
		;ld ixl,4
		ex de,hl
loop_ancho_map_sbuffer3:


		LD A,(DE)	;leo el byte del fondo
		AND (HL)	;lo enmascaro
		INC HL
		OR (HL)		;lo enmascaro
		LD (DE),A	;actualizo el fondo
		INC DE
		INC HL

		.db  #0xdD
		DEC L		;resta ancho
		;dec ixl
		JP NZ,loop_ancho_map_sbuffer3

	   .db  #0xdd
	   dec H
	   ;dec ixh
	   ret z
	   EX DE,HL
;hay que sumar 72 bytes para pasar a la siguiente línea
		add HL,BC
		jp loop_alto_map_sbuffer3



		
		
		
		
		
.globl _cpc_PutMaskInkSpTileMap2b

_cpc_PutMaskInkSpTileMap2b::
;según las coordenadas x,y que tenga el sprite, se dibuja en el buffer

    ld hl,#2									;3
	add hl,sp									;3
	ld e,(hl)									;2
	inc hl										;1
	ld d,(hl)									;2

	.db #0xdd
	ld l,e										;2
	.db #0xdd
	ld h,d										;2
												; --> 15 NOPS


    ld a,8 (ix)
    ld e,9 (ix)

;include "multiplication1.asm"
   	    ;ld    h, #ancho_pantalla_bytes
  	    ;LD    L, #0
        LD	  HL,#ancho_pantalla_bytes * 256
        LD    D, L
        LD    B, #8

MULT7:   ADD   HL, HL
        JR    NC, NOADD7
        ADD   HL, DE
NOADD7:  DJNZ  MULT7

	ld e,a
	add hl,de
	;HL=E*H+D

	ld de,#posicion_inicial_superbuffer
	add hl,de
	;hl apunta a la posición en buffer (destino)

	ld 4 (ix),l		;update superbuffer address
    ld 5 (ix),h

	ld e,0 (ix)
    ld d,1 (ix)	;HL apunta al sprite

    ;con el ancho del sprite hago las actualizaciones necesarias a la rutina
    ld a,(de)
    ld (#loop_alto_map_sbuffer7+2),a
    ld b,a
    ld a,#ancho_pantalla_bytes
    sub b
    ;ld (#ancho_27+1),a
    ld c,a
	inc de
	ld a,(de)
	inc de


sp_buffer_mask7:
	ld b,#0
ancho_27:
	;ld c,#ancho_pantalla_bytes-4 ;60	;;DEPENDE DEL ANCHO

	.db  #0xdd
	LD H,A		;ALTO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
	;ld ixh,a
loop_alto_map_sbuffer7:
		.db  #0xdd
		LD L,#4		;ANCHO, SE PUEDE TRABAJAR CON HX DIRECTAMENTE
		;ld ixl,4
		ex de,hl
		
loop_ancho_map_sbuffer7:


		LD A,(hl)	;leo el byte del fondo
		or a
		jp z, cont7
		
		LD (DE),A	;actualizo el fondo
cont7:
		INC DE
		INC HL

		.db  #0xdD
		DEC L		;resta ancho
		;dec ixl
		JP NZ,loop_ancho_map_sbuffer7

	   .db  #0xdd
	   dec H
	   ;dec ixh
	   ret z
	   EX DE,HL
;hay que sumar 72 bytes para pasar a la siguiente línea
		add HL,BC
		jp loop_alto_map_sbuffer7
		
				

.globl _cpc_ScrollLeft00

_cpc_ScrollLeft00::

	;se decrementa cada posiciones_pantalla
	LD HL,#_posiciones_pantalla
	ld b,#20
	buc_suma1:
	DEC (HL)
	INC HL
	INC HL
	djnz buc_suma1

	ld hl,(#posicion_inicio_pantalla_visible_sb+1)
	inc HL
	ld (#posicion_inicio_pantalla_visible_sb+1),HL

	RET

.globl _cpc_ScrollLeft01

_cpc_ScrollLeft01::

	;se incrementa cada posiciones_pantalla
	LD HL,#_posiciones_pantalla
	ld b,#20
	buc_suma14:
	INC (HL)
	INC HL
	INC HL
	djnz buc_suma14


	ld hl,(#posicion_inicio_pantalla_visible_sb+1)
	dec HL
	ld (#posicion_inicio_pantalla_visible_sb+1),HL


	ld hl,#_pantalla_juego+1
	ld de,#_pantalla_juego
	ld bc,#alto_pantalla_bytes*ancho_pantalla_bytes/16 -1
	LDIR

	ld hl,#posicion_inicial_superbuffer+2
	ld de,#posicion_inicial_superbuffer
	ld bc,#alto_pantalla_bytes*ancho_pantalla_bytes -1
	LDIR

	RET




.globl _cpc_ScrollRight00

_cpc_ScrollRight00::		;;scrollea el area de pantalla de tiles

	;se decrementa cada posiciones_pantalla
	LD HL,#_posiciones_pantalla
	ld b,#20
	buc_suma12:
	INC (HL)
	INC HL
	INC HL
	djnz buc_suma12


	ld hl,(#posicion_inicio_pantalla_visible_sb+1)
	dec HL
	ld (#posicion_inicio_pantalla_visible_sb+1),HL

	RET


.globl _cpc_ScrollRight01

_cpc_ScrollRight01::	;;scrollea el area de pantalla de tiles

	;se incrementa cada posiciones_pantalla
	LD HL,#_posiciones_pantalla
	ld b,#20
	buc_suma15:
	DEC (HL)
	INC HL
	INC HL
	djnz buc_suma15


	ld hl,(#posicion_inicio_pantalla_visible_sb+1)
	inc HL
	ld (#posicion_inicio_pantalla_visible_sb+1),HL

	ld hl,#_pantalla_juego+alto_pantalla_bytes*ancho_pantalla_bytes/16-1
	ld de,#_pantalla_juego+alto_pantalla_bytes*ancho_pantalla_bytes/16
	ld bc,#alto_pantalla_bytes*ancho_pantalla_bytes/16 -1 ;-1
	LDDR

	;;scrollea el superbuffer
	ld hl,#posicion_inicial_superbuffer+alto_pantalla_bytes*ancho_pantalla_bytes-2 ; pantalla_juego+alto_pantalla_bytes*ancho_pantalla_bytes/16-1
	ld de,#posicion_inicial_superbuffer+alto_pantalla_bytes*ancho_pantalla_bytes ;pantalla_juego+alto_pantalla_bytes*ancho_pantalla_bytes/16
	ld bc,#alto_pantalla_bytes*ancho_pantalla_bytes-1 ;-1
	LDDR
	RET

.globl _cpc_SetTouchTileXY

_cpc_SetTouchTileXY::

	;ld ix,#2
	;add ix,sp

	;ld d,1 (ix)
	;ld e,0 (ix)


	ld hl,#2
	add hl,sp
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld c,(hl)


	;ld d,e
	;ld e,c
	call _cpc_UpdTileTable

	;ld e,1 (ix)
	;ld a,0 (ix)
	ld a,e
	ld e,d
;include "multiplication2.asm"
		;ld   h, #ancho_pantalla_bytes/2
        ;LD    L, #0
        LD	  HL,#ancho_pantalla_bytes * 256 / 2
        LD    D, L
        LD    B, #8

MULT4:   ADD   HL, HL
        JR    NC, NOADD4
        ADD   HL, DE
NOADD4:  DJNZ  MULT4


			ld e,a
			;ld d,#0
		add hl,de
		ld de,#_pantalla_juego
		add hl,de
	;ld a,2 (ix)
		ld (hl),c
	ret


.globl _cpc_ReadTile

_cpc_ReadTile::


;	ld ix,#2
;	add ix,sp
;	ld e,1 (ix)
;	ld a,0 (ix)

	ld hl,#2
	add hl,sp
	ld a,(hl)
	inc hl
	ld e,(hl)



;	ld hl,2
;    add hl,sp			; ¿Es la forma de pasar parámetros? ¿Se pasan en SP+2? ¿en la pila?
;	ld E,(hl)		;Y
;	inc hl
;	inc hl
;	ld a,(hl)	;X

;	include "multiplication2.asm"
		;ld   h, #ancho_pantalla_bytes/2
        ;LD    L, #0
        LD	  HL,#ancho_pantalla_bytes * 256 / 2
        LD    D, L
        LD    B, #8

MULT5:   ADD   HL, HL
        JR    NC, NOADD5
        ADD   HL, DE
NOADD5:  DJNZ  MULT5



			ld e,a
			;ld d,#0
		add hl,de		;SUMA X A LA DISTANCIA Y*ANCHO
	ld de,#_pantalla_juego
		add hl,de
		ld l,(hl)
		ld h,#0
	ret


.globl _cpc_SuperbufferAddress

_cpc_SuperbufferAddress::
;    ld ix,#2
;    add ix,sp

;    ld l,0 (ix)
;    ld h,1 (ix)	;HL apunta al sprite

;    push hl
;    pop ix

    ld hl,#2									;3
	add hl,sp									;3
	ld e,(hl)									;2
	inc hl										;1
	ld d,(hl)									;2

	.db #0xdd
	ld l,e										;2
	.db #0xdd
	ld h,d										;2
												; --> 15 NOPS


  ;lo cambio para la rutina de multiplicar
    ld a,8 (ix)
    ld e,9 (ix)
; 	include "multiplication1.asm"
   	    ;ld    h, #ancho_pantalla_bytes
        ;LD    L, #0
        LD	  HL,#ancho_pantalla_bytes * 256
        LD    D, L
        LD    B, #8

MULT6:   ADD   HL, HL
        JR    NC, NOADD6
        ADD   HL, DE
NOADD6:  DJNZ  MULT6


	;ld b,#0
	ld e,a
	add hl,de
	ld de,#posicion_inicial_superbuffer
	add hl,de
	;hl apunta a la posición en buffer (destino)
    ld 4 (ix),l
    ld 5 (ix),h
    ret



tablascan:	;defs 20*16
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.db #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0

