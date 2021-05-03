;
; TAPE LOADER
;

.include "cpcfirm.inc"
.include "loader.opt"

loader:

.ifeq DISK
	; loading from disk

	ld hl, (#0xbe7d)	; save current drive
	ld a, (hl)
	ld (#drive+1), a
.endif ; end disk code

	ld c, #0xff
	ld hl, #start
	call mc_start_program

start:
	call kl_rom_walk

.ifeq DISK
drive:
	ld a, #0		; restore drive
	ld hl, (#0xbe7d)
	ld (hl), a
.endif ; end disk code

	ld bc, #0		; set border
	call scr_set_border

	ld bc, #0		; bg color
	xor a
	call scr_set_ink

	ld a, #1			; set mode 1
	call scr_set_mode

	ld a, #0xff
	call cas_noisy ; disable tape texts

.ifeq DISK
					; first file is the SCRX
	call load_file

.else ; tape code

	ld ix, #TMP_ADDR
	ld de, #SCRX_SIZE
	call turboload

.endif ; end tape code

					; setup the palette
	ld b, #0x10
	xor a
	ld ix, #TMP_ADDR + #4
set_palette_loop:
	push bc
	push af
	ld c, (ix)
	inc ix
	ld b, c
	call scr_set_ink
	pop af
	pop bc
	inc a
	djnz set_palette_loop

	; border is already 0

	ld hl, #0xc000	; uncompress into the screen
	push hl
	ld hl, #TMP_ADDR + #0x14 ; compressed data
	push hl
	call _ucl_uncompress
	pop af
	pop af

.ifeq DISK

	ld hl, #fname_end-#1
	inc (hl)
					; load the code
	call load_file

.else ; tape code

	ld ix, #APP_ADDR
	ld de, #APP_SIZE
	call turboload

.endif ; tape code ends

	xor	a		; set mode 0
	call scr_set_mode

	; jp to the app entry point
	.db #0xc3
	.dw #APP_EP

.ifeq DISK

load_file:
	ld hl, #fname
	ld b, #fname_end-#fname

	ld de, #0x400		; temp mem (only used in tape mode)
	call cas_in_open

	push de
	pop hl
	call cas_in_direct

	call cas_in_close
	ret

fname:
	.str "MAIN.BI0"
fname_end:

.else ; tape code

turboload:
	di
	ex af, af'
	push af
	ex af, af'
	exx
	push de
	push bc
	push hl
	exx
	xor a
	ld r, a
	dec a
	call _turboload
	jp nc, 0
	exx
	pop hl
	pop bc
	pop de
	exx
	ex af, af'
	pop af
	ex af, af'
	ei
	ret

.include "turboload.s"
.endif ; end tape code

.area _DATA

