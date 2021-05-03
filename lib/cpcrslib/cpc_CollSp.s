.globl _cpc_CollSp
	
_cpc_CollSp::
;first parameter sprite 
;second parameter value
	ld hl,#2
	add hl,sp
	
	;ld ix,#2
	;add ix,sp
;	ld e,2 (ix)
;	ld d,3 (ix)
	;A=x value
;	ld l,0 (ix)
;	ld h,1 (ix)
	
	ld e,(hl)
	inc hl
	ld d,(hl)
	push de
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	push de
	
	pop iy	;ix sprite2 data
  
    pop ix	;iy sprite1 data
    
    ;Sprite coords & sprite dims
				
;COLISION_sprites



;entran sprite1 y sprite 2 y se actualizan los datos
;ix apunta a sprite1
;iy apunta a sprite2

;coordenadas
	ld l,8 (ix)
	ld h,9 (ix)
	LD (#SPR2X),HL
	
	ld l,8 (iy)
	ld h,9 (iy)
	LD (#SPR1X),HL	

;dimensiones sprite 1
	ld l,0 (ix)
	ld h,1 (ix)
	ld b,(hl)
	inc hl
	ld c,(hl)
;dimensiones sprite 12
	ld l,0 (iy)
	ld h,1 (iy)
	ld d,(hl)
	inc hl
	ld e,(hl)	
	
	
	;ld e,(ix+6)
	;ld d,(ix+7)	
	
	

;ld de,DIMENSIONES_SP_PPAL	;dimensiones sprite 2
;ld bc,DIMENSIONES_SP_PPAL	;dimensiones sprite 1
CALL TOCADO
;RET NC ;vuelve si no hay colision
ld h,#0
JP nc,no_colision
;Aquí hay colisión
ld l,#1
RET		

no_colision:
ld l,h
ret
	
TOCADO:
	LD HL,#SPR2X	
	LD A,(#SPR1X)
	CP (HL)
	jp C,C1
	LD A,(HL)
	ADD A,B	;alto del sprite1
	LD B,A
	LD A,(#SPR1X)
	SUB B
	RET NC
	jp COMPROBAR
C1:
	ADD A,D	;alto sprite2
	LD D,A
	LD A,(HL)
	SUB D
	RET NC
COMPROBAR:
	INC HL
	LD A,(#SPR1Y)
	CP (HL)
	jp C,C2
	LD A,(HL)
	ADD A,C
	LD C,A
	LD A,(#SPR1Y)
	SUB C
	RET
C2:
	ADD A,E
	LD E,A
	LD A,(HL)
	SUB E
	RET

SPR1X: 
.db 0
SPR1Y: 
.db 0
SPR2X: 
.db 0
SPR2Y: 
.db 0
