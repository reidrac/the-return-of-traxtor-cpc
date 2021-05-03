
.globl _tiles
.globl _pantalla_juego
.globl _tiles_tocados
.globl _posiciones_pantalla
.globl _posiciones_super_buffer
.globl _tabla_y_ancho_pantalla


;.globl _posicion_inicial_area_visible
;.globl _posicion_inicial_superbuffer
;.globl _ancho_pantalla_bytes
;.globl _alto_pantalla_bytes
;.globl _ancho_pantalla_bytes_visible


; ***************************************************
; Transparent colour for cpc_PutTrSpTileMap2b routine
;.globl _mascara1
;.globl _mascara2
; ***************************************************

;.globl _tiles_ocultos_ancho0
;.globl _tiles_ocultos_alto0
;.globl _tiles_ocultos_ancho1
;.globl _tiles_ocultos_alto1


;.globl _posicion_inicio_pantalla_visible
;.globl _posicion_inicio_pantalla_visible_sb



;.globl _tile
; ***************************************************
; Scroll Left Addresses column
; not requiered if scroll not used
.globl _ColumnScr
; ***************************************************


; ***************************************************
; Transparent colour for cpc_PutTrSpTileMap2b routine
; For printing sprites using transparent color (mode 0) transparent color selection is requiered.
; Selección color transparente. Escribir las 2 máscaras que correspondan al color elegido.
;Example colour number 7:
mascara1 	= 	#0
mascara2 	= 	#0


;0: #0x00, #0x00
;1: #0x80, #0x40
;2: #0x04, #0x08
;3: #0x44, #0x88
;4: #0x10, #0x20
;5: #0x50, #0xA0
;6: #0x14, #0x28
;7: #0x54, #0xA8
;8: #0x01, #0x02
;9: #0x41, #0x82
;10: #0x05, #0x0A
;11: #0x45, #0x8A
;12: #0x11, #0x22
;13: #0x51, #0xA2
;14: #0x15, #0x2A
;15: #0x55, #0xAA
; ***************************************************




;------------------------------------------------------------------------------------
; SCREEN AND BUFFER ADDRESSES
; VALORES QUE DEFINEN EL BUFFER Y LA PANTALLA
;------------------------------------------------------------------------------------

posicion_inicial_area_visible = #0xc0A4
posicion_inicial_superbuffer = #0x100


;------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------
; TILE MAP DIMENSIONS
;------------------------------------------------------------------------------------

T_WIDTH = 32 			;max=40		;dimensiones de la pantalla en tiles
T_HEIGHT = 16			;max=20


;Invisible tile margins:
T_WH = 2
T_HH = 0
;------------------------------------------------------------------------------------


tiles_ocultos_ancho0 = T_WH
tiles_ocultos_alto0 = T_HH
tiles_ocultos_ancho1 = T_WIDTH - T_WH - 1
tiles_ocultos_alto1 = T_HEIGHT - T_HH - 1

;------------------------------------------------------------------------------------
; Other parameters (internal use)
;------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------

ancho_pantalla_bytes = 2*T_WIDTH ; 2*T_WIDTH;		; El ancho de pantalla influye determinantemente en numerosas rutinas que hay que actualizar si se cambia
											; OJO con el modo
alto_pantalla_bytes = 8*T_HEIGHT;
ancho_pantalla_bytes_visible = 2*T_WIDTH ;32  ; 64;		;dentro del area definida, cuanto se debe mostrar. 2*T_WIDTH

;El tamaño del buffer es ancho_pantalla_bytes*alto_pantalla_bytes

_TileMapConf:
;------------------------------------------------------------------------------------
;Con la definición del mapeado hay que tener en cuenta que las coordenadas son:
;ANCHO=64 bytes (128 pixels en modo 0)
;ALTO=128 pixels
;el máximo que entra en el CPC es 20 líneas
;SI NO SE VAN A USAR TODAS LAS LINEAS, PARA AHORRA MEMORIA ES INTERESANTE COMENTARLAS
_posiciones_pantalla:		;Posiciones en las que se dibujan los tiles
.DW #posicion_inicial_area_visible+#0x50*0
.DW #posicion_inicial_area_visible+#0x50*1
.DW #posicion_inicial_area_visible+#0x50*2
.DW #posicion_inicial_area_visible+#0x50*3
.DW #posicion_inicial_area_visible+#0x50*4
.DW #posicion_inicial_area_visible+#0x50*5
.DW #posicion_inicial_area_visible+#0x50*6
.DW #posicion_inicial_area_visible+#0x50*7
.DW #posicion_inicial_area_visible+#0x50*8
.DW #posicion_inicial_area_visible+#0x50*9
.DW #posicion_inicial_area_visible+#0x50*10
.DW #posicion_inicial_area_visible+#0x50*11
.DW #posicion_inicial_area_visible+#0x50*12
.DW #posicion_inicial_area_visible+#0x50*13
.DW #posicion_inicial_area_visible+#0x50*14
.DW #posicion_inicial_area_visible+#0x50*15
.DW #posicion_inicial_area_visible+#0x50*16
.DW #posicion_inicial_area_visible+#0x50*17
.DW #posicion_inicial_area_visible+#0x50*18
.DW #posicion_inicial_area_visible+#0x50*19

_posiciones_super_buffer:			;muestra el inicio de cada línea (son 10 tiles de 8x16 de alto)
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*0
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*1
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*2
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*3
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*4
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*5
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*6
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*7
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*8
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*9
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*10
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*11
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*12
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*13
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*14
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*15
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*16
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*17
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*18
.DW #posicion_inicial_superbuffer+8*ancho_pantalla_bytes*19




; ***************************************************
; Scroll Left Addresses column. DECRAPTED
; not requiered if scroll not used comment it ;)
_ColumnScr:
; ***************************************************


_pantalla_actual: .DW #0
_pantalla_juego:  ;en tiles
;defs T_WIDTH*T_HEIGHT
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0
.DB #0xFF	;Este byte es importante, marca el fin de la pantalla.


_fondo_pantalla_juego:  ;en tiles
;defs T_WIDTH*T_HEIGHT
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#13,#14,#17,#13,#14,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#15,#16,#17,#15,#16,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17
.DB #17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17,#17


_tiles_tocados:
.DB #0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF
.DB #0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF
.DB #0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF
.DB #0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF
.DB #0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF
.DB #0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF
.DB #0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF
.DB #0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF
.DB #0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF
.DB #0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF,#0xFF
 ;defs 150 ;150	;cuando un tile es tocado, se marca en esta tabla para luego restaurarlo. Es una tabla sin duplicados.


_tabla_y_ancho_pantalla:
.dw #_pantalla_juego + #0
.dw #_pantalla_juego + #1*T_WIDTH
.dw #_pantalla_juego + #2*T_WIDTH
.dw #_pantalla_juego + #3*T_WIDTH
.dw #_pantalla_juego + #4*T_WIDTH
.dw #_pantalla_juego + #5*T_WIDTH
.dw #_pantalla_juego + #6*T_WIDTH
.dw #_pantalla_juego + #7*T_WIDTH
.dw #_pantalla_juego + #8*T_WIDTH
.dw #_pantalla_juego + #9*T_WIDTH
.dw #_pantalla_juego + #10*T_WIDTH
.dw #_pantalla_juego + #11*T_WIDTH
.dw #_pantalla_juego + #12*T_WIDTH
.dw #_pantalla_juego + #13*T_WIDTH
.dw #_pantalla_juego + #14*T_WIDTH
.dw #_pantalla_juego + #15*T_WIDTH
.dw #_pantalla_juego + #16*T_WIDTH
.dw #_pantalla_juego + #17*T_WIDTH
.dw #_pantalla_juego + #18*T_WIDTH
.dw #_pantalla_juego + #19*T_WIDTH

;_tabla_y_x_ancho2:
;.dw #ancho_pantalla_bytes * 0 /2
;.dw #ancho_pantalla_bytes * 1 /2
;.dw #ancho_pantalla_bytes * 2 /2
;.dw #ancho_pantalla_bytes * 3 /2
;.dw #ancho_pantalla_bytes * 4 /2
;.dw #ancho_pantalla_bytes * 5 /2
;.dw #ancho_pantalla_bytes * 6 /2
;.dw #ancho_pantalla_bytes * 7 /2
;.dw #ancho_pantalla_bytes * 8 /2
;.dw #ancho_pantalla_bytes * 9 /2
;.dw #ancho_pantalla_bytes * 10 /2
;.dw #ancho_pantalla_bytes * 11 /2
;.dw #ancho_pantalla_bytes * 12 /2
;.dw #ancho_pantalla_bytes * 13 /2
;.dw #ancho_pantalla_bytes * 14 /2
;.dw #ancho_pantalla_bytes * 15 /2
;.dw #ancho_pantalla_bytes * 16 /2
;.dw #ancho_pantalla_bytes * 17 /2
;.dw #ancho_pantalla_bytes * 18 /2
;.dw #ancho_pantalla_bytes * 19 /2


;------------------------------------------------------------------------------------
; TILE DATA. TILES MUST BE DEFINED HERE
;------------------------------------------------------------------------------------


_tiles: ;Son de 2x8 bytes
;tile 0
.db #0x00,#0x00
.db #0x40,#0x00
.db #0x40,#0x00
.db #0x40,#0x00
.db #0x40,#0x00
.db #0x40,#0x00
.db #0x40,#0xC0
.db #0x00,#0x00
;tile 1
.db #0x3C,#0x00
.db #0x3C,#0x00
.db #0x00,#0x3C
.db #0x00,#0x3C
.db #0x3C,#0x00
.db #0x3C,#0x00
.db #0x00,#0x3C
.db #0x00,#0x3C
;tile 2
.db #0x00,#0x00
.db #0x15,#0x00
.db #0x00,#0x2A
.db #0x15,#0x00
.db #0x00,#0x2A
.db #0x15,#0x00
.db #0x00,#0x00
.db #0x00,#0x00
