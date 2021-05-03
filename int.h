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
#ifndef _INT_H
#define _INT_H

#ifndef WFRAMES
#define WFRAMES		4
#endif

// timer
unsigned char tick;
unsigned char timer;
unsigned char playerISR;

void
wait()
{
    while ((unsigned char)(tick - timer) < WFRAMES)
        __asm__("halt");
    timer = tick;
}

void
WyzPlayerOn()
{
    __asm;
    di
    ld a, #1
    ld (_playerISR), a
    ei
    __endasm;
}

void
WyzPlayerOff()
{
    __asm;
    di
    xor a
    ld (_playerISR), a
    call _cpc_WyzSetPlayerOff
    ei
    __endasm;

}

void
setup_int()
{
    tick = 0;
    timer = 0;
    playerISR = 0;
    __asm;
    di

    ld ix, #0x0038
    ld hl, #isr
    ld (ix), #0xc3
    ld 1(ix), l
    ld 2(ix), h
    im 1

    ei
    jp setup_done

    isr:
    push af
    ld a, (#_tick)
    inc a
    ld (#_tick), a
    ld a, (#_playerISR)
    or a
    jp z, player_is_off

    jp _cpc_WyzPlayerISR
    player_is_off:
    pop af
    ei
    ret

    setup_done:
    __endasm;
}

#endif // _INT_H
