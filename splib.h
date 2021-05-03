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
#ifndef _SPLIB_H
#define _SPLIB_H

#include <stdint.h>

// CONFIGURE **
// this is ; 84x180 pixels tiles
#define TMW 7
#define TMH 20

#define TW 12
#define TH 9

#define BUFF_ADDR 0x0100
// CONFIGURE **

struct st_tile
{
    uint8_t *t;
    uint16_t saddr;
    uint16_t baddr;
    uint8_t dirty;
    struct st_tile *n;
};

void init_tiles();
void update_screen();
void validate_screen();
void invalidate_screen();

void invalidate_tile(struct st_tile *st);
void invalidate_tile_xy(uint8_t x, uint8_t y);

void erase_tile(struct st_tile *st);
void erase_tile_xy(uint8_t x, uint8_t y);

void put_tile(uint8_t *t, uint8_t x, uint8_t y);

// misc
uint16_t screen_addr(uint16_t x, uint16_t y);
void wait_vsync();
void set_hw_mode(uint8_t m);
void set_hw_border(uint8_t c);
void set_hw_ink(uint8_t ink, uint8_t c);
void pad_numbers(uint8_t *s, uint8_t limit, uint16_t number);

#endif // _SPLIB_H
