.module crt0
.globl	_main
.globl _main_init

	.area	_HOME
	.area	_CODE
	.area	_INITIALIZER
    .area   _GSINIT
    .area   _GSFINAL

	.area	_DATA
	.area	_INITIALIZED
	.area	_BSEG
    .area   _BSS
    .area   _HEAP

   	.area   _CODE

_main_init::

	di
	; disable the firmware
	ld hl, #0x38
	ld (hl), #0xfb
	inc hl
	ld (hl), #0xc9

	; disable upper/lower roms
	ld bc, #0x7f8c
	out (c), c

	; put the stack as high as we can
	ld sp, #0xc000
	ei

	call gsinit
	call _main

halt0:
    halt
    jr halt0

	.area   _GSINIT
gsinit::
	ld bc, #l__INITIALIZER
	ld a, b
	or a, c
	jr Z, gsinit_next
	ld de, #s__INITIALIZED
	ld hl, #s__INITIALIZER
	ldir
gsinit_next:

.area   _GSFINAL
   	ret
