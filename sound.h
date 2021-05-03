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
#ifndef _SOUND_H
#define _SOUND_H

// effect definitions

#define SND_READY 	0
#define SND_EXPLO	1
#define SND_ERROR	2
#define SND_LEVEL	3
#define SND_LINE	4

#define WYZ_EFX_CHAN 2

extern const uint8_t *wyz_effect_table[];
extern const uint8_t *wyz_ins_table[];
extern const uint8_t *wyz_sound_table[];
extern const uint8_t *wyz_song_table[];

#endif // _SOUND_H
