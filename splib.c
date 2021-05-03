/*
   The Return of Traxtor (Amstrad CPC)
   Copyright (C) 2015 Juan J. Martinez <jjm@usebox.net>

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
#include <stdlib.h>

#include "splib.h"

static struct st_tile tiles[TMW * TMH];
struct st_tile *dirty, *last_dirty;

#define T_CLEAN	0
#define T_DIRTY 1

// faster
struct st_tile *tile_p;

void
pad_numbers(uint8_t *s, uint8_t limit, uint16_t number)
{
    s += limit;
    *s = 0;

    while (limit--)
    {
        *--s = (number % 10) + '0';
        number /= 10;
    }
}

#pragma save
#pragma disable_warning 85
void
set_hw_border(uint8_t c)
{
    __asm;
    ld bc, #0x7f10
    out (c), c
    ld hl, #2
    add hl, sp
    ld c, (hl)
    out (c), c
    __endasm;
}
#pragma restore

#pragma save
#pragma disable_warning 85
void
set_hw_ink(uint8_t ink, uint8_t c)
{
    __asm;
    ld hl, #2
    add hl, sp
    ld a, (hl)
    inc hl
    ld e, (hl)
    ld bc, #0x7f00
    out (c), a
    ld a, #0x40
    or e
    out (c), a
    __endasm;
}
#pragma restore

#pragma save
#pragma disable_warning 85
void
set_hw_mode(uint8_t m)
{
    __asm;
    ld hl, #2
    add hl, sp
    ld e, (hl)
    out (c), a
    ld a, #0x8c
    or e
    ld bc, #0x7f00
    out (c), a
    __endasm;
}
#pragma restore


void
wait_vsync()
{
    __asm;
    ld b, #0xf5
    keep_waiting:
    in a, (c)
    rra
    jr nc, keep_waiting
    __endasm;
}

// this is quite slow, use it only where speed is not an issue
uint16_t
screen_addr(uint16_t x, uint16_t y)
{
    // up to 160 x 200
    return (0xc000 + x + ((y / 8) * 80) + ((y % 8) * 2048));
}

void
init_tiles()
{
    uint8_t i, j;

    for (j = 0; j < TMH; j++)
        for (i = 0; i < TMW; i++)
        {
            tiles[i + j * TMW].t = NULL;
            tiles[i + j * TMW].saddr = screen_addr((uint16_t)(20 + i * TW / 2), (uint16_t)(8 + j * TH));
            tiles[i + j * TMW].baddr = BUFF_ADDR + (i * TW / 2) + (j * TH * TMW * TW / 2);
            tiles[i + j * TMW].n = NULL;
            tiles[i + j * TMW].dirty = T_CLEAN;
        }

    dirty = NULL;
    last_dirty = NULL;
}

void
update_screen()
{
    // tiles are expected to be 12x9 pixels
    __asm;
    ld b, #0xf5
    update_keep_waiting:
    in a, (c)
    rra
    jr nc, update_keep_waiting

    ld bc, (_dirty)

    update_loop:
    ld a, b
    or c
    jr z, update_done

    ld hl, #2
    add hl, bc
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a

    push bc
    ld a, #9
    put_tile0:
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi

    dec a
    jp z, put_tile2

    ld bc, #0x24
    add hl, bc

    ex de, hl
    ld bc, #0x07fa
    add hl, bc
    jp nc, put_tile1
    ld bc, #0xc050
    add hl, bc
    put_tile1:
    ex de, hl
    jr put_tile0

    put_tile2:
    pop bc

    xor a
    ld hl, #6
    add hl, bc
    ld (hl), a

    inc hl
    ld c, (hl)
    inc hl
    ld b, (hl)

    jp update_loop

    update_done:
    __endasm;

    dirty = NULL;
    last_dirty = NULL;
}

void
validate_screen()
{
    for (; dirty; dirty = dirty->n)
        dirty->dirty = T_CLEAN;

    dirty = NULL;
    last_dirty = NULL;
}

void
invalidate_screen()
{
    uint8_t i;

    for (i = 0; i < (TMW * TMH) - 1; i++)
    {
        tiles[i].dirty = T_DIRTY;
        tiles[i].n = &tiles[i + 1];
    }

    tiles[i].dirty = T_DIRTY;
    tiles[i].n = NULL;

    dirty = tiles;
    last_dirty = &tiles[i];
}

void
invalidate_tile(struct st_tile *st)
{
    if (st->dirty)
        return;

    st->dirty = T_DIRTY;
    st->n = NULL;

    if (!dirty)
    {
        dirty = st;
        last_dirty = st;
    }
    else
    {
        last_dirty->n = st;
        last_dirty = st;
    }
}

inline void
invalidate_tile_xy(uint8_t x, uint8_t y)
{
    // x and y in tilemap coordinates

    invalidate_tile(&tiles[x + y * TMW]);
}

void
erase_tile(struct st_tile *st)
{
    if (!st || !st->t)
        return;

    invalidate_tile(st);

    tile_p = st;
    __asm;
    ld ix, (_tile_p)

    ld e, 4(ix)
    ld d, 5(ix)
    ld l, 0(ix)
    ld h, 1(ix)

    ld a, #9
    blit_tile0:
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi

    ex de, hl
    ld bc, #0x24
    add hl, bc
    ex de, hl

    dec a
    jp nz, blit_tile0
    __endasm;
}

inline void
erase_tile_xy(uint8_t x, uint8_t y)
{
    // x and y in tilemap coordinates
    erase_tile(&tiles[x + y * TMW]);
}

void
put_tile(uint8_t *t, uint8_t x, uint8_t y)
{
    // x and y in tilemap coordinates
    tile_p = &tiles[x + y * TMW];
    tile_p->t = t;

    erase_tile(tile_p);
}

// EOF
