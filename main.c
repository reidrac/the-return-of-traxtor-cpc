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
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "ucl.h"
#include "cpcrslib/cpcrslib.h"
#include "cpcrslib/cpcwyzlib.h"
#include "splib.h"

#define WFRAMES 12 // ~ 25 FPS
#include "int.h"
#include "sound.h"

// generated
#include "font.h"
#include "menubg.h"
#include "playbg.h"
#include "tiles.h"
#include "tiles_alt.h"
#include "ship.h"
#include "return_mus.h"
#include "board_mus.h"
#include "gameover_mus.h"

#define KEY_RIGHT 0
#define KEY_LEFT 1
#define KEY_BEAM 2
#define KEY_FIRE 3
#define KEY_PAUSE 4
#define KEY_ALT_BEAM 5
#define KEY_QUIT 14

#define BW 7
#define BH 10

#define BLOCK_WILD              7

#define BLOCK(x)                (x & 0x0f)
#define EFFECT(x)               (x >> 4)
#define UPDATE_EFFECT(x, y)     ((x & 0x0f) | (y << 4))

#define LOCK_GRAVITY            8
#define TILE_ERASE              16
#define TILE_MARKER             17
#define TILE_EXPLO              18
#define TILE_GRAVITY            14

#define K_DELAY 3

#define DIRTY_NONE              0
#define DIRTY_SCORE             1
#define DIRTY_LEVEL             2
#define DIRTY_BAY               4
#define DIRTY_ALL               255

#define ENDGAME                 25

// encrypted endgame text; like anyobe is going to read it from the binary! :D
const uint8_t endgame[] = {
    0xf3, 0x45, 0xfe, 0x20, 0x89, 0x36, 0x9a, 0x44, 0xf3, 0x5e, 0x80, 0x31,
    0x99, 0x22, 0x8e, 0x50, 0xef, 0x5f, 0xe5, 0x11, 0xb8, 0x03, 0xdd, 0x73,
    0xdf, 0x64, 0xcc, 0x73, 0xc4, 0x76, 0xcd, 0x77, 0xa7, 0x53, 0xa7, 0x1f,
    0xae, 0x02, 0xdc, 0x6c, 0xdd, 0x74, 0xa4, 0x74, 0xa4, 0x50, 0xa4, 0x03,
    0xb2, 0x19, 0xc7, 0x78, 0xd4, 0x6f, 0xb1, 0x0e, 0xd0, 0x62, 0xd9, 0x60,
    0xdb, 0x6b, 0xd1, 0x0e, 0xfa, 0x0e, 0xa4, 0x12, 0xad, 0x1d, 0xa8, 0x05,
    0xdb, 0x63, 0xd2, 0x7e, 0xa0, 0x0e, 0xbc, 0x03, 0xa4, 0x13, 0xa3, 0x1a,
    0xee, 0x44, 0xf2, 0x49, 0x97, 0x2e, 0x91, 0x22, 0x99, 0x49, 0xb7
};

/*
"THE WAR IS OVER AND\n"
"WE PREVAILED.\n\n"
"FOR NOW...\n\n"
"YOU ARE A LEGEND!\n\n"
"THANKS FOR PLAYING\n"
"THE GAME."
*/

// conf
uint8_t conf_mode = 0; // normal, 1: easy
uint8_t conf_tiles = 0; // classic, 1: alternative
uint8_t conf_music = 1; // on, 0: off
uint8_t (*tiles_blocks)[54] = tiles;

uint8_t dirty_hud;
uint8_t last_wild;
uint8_t dirty_marker;

#define EFFECTS_DELAY   3
uint8_t has_effects;
uint8_t effects_delay;
uint8_t combo_delay;

#define GRAVITY_DELAY   2
uint8_t gravity[BW * BH * 2];
uint8_t has_gravity;
uint8_t gravity_delay;

uint8_t empty_board;
uint8_t gameover;
uint8_t paused;
uint16_t score;
uint16_t hiscore = 0;
uint8_t level;

int16_t next_level;
int16_t next_line;
int16_t next_line_level;

uint8_t px;
uint8_t py;
uint8_t old_px;

int8_t board[BW * BH];

uint8_t bay[3];
int8_t bay_top;

const uint8_t pal_hw[] = {
    0x54, 0x44, 0x55, 0x5c, 0x58, 0x4c, 0x4d, 0x46,
    0x57, 0x40, 0x5f, 0x4e, 0x5a, 0x5b, 0x4a, 0x4b
};

uint8_t joystick;
const uint16_t key_map[2][6] = {
    // right, left, beam, fire, pause, extra beam
    { 0x4002, 0x4101, 0x4004, 0x4580, 0x4510, 0x0000 }, // keyboard
    { 0x4908, 0x4904, 0x4580, 0x4910, 0x4510, 0x4920 }  // joystick
};
const char redefine[5][6] = {
    "RIGHT", "LEFT ", "BEAM ", "FIRE ", "PAUSE"
};

void
map_keys()
{
    uint8_t i;

    for (i = 0; i < 6; i++)
        cpc_AssignKey(i, key_map[joystick][i]);
}

void
draw_controls()
{
    if (joystick)
    {
        cpc_SetInkGphStr(2, 170);
        cpc_SetInkGphStr(3, 42);
    }
    else
    {
        cpc_SetInkGphStr(2, 160);
        cpc_SetInkGphStr(3, 138);
    }
    cpc_PrintGphStrXY("1:JOYSTICK", 30, 80);

    if (joystick)
    {
        cpc_SetInkGphStr(2, 160);
        cpc_SetInkGphStr(3, 138);
    }
    else
    {
        cpc_SetInkGphStr(2, 170);
        cpc_SetInkGphStr(3, 42);
    }
    cpc_PrintGphStrXY("2:KEYBOARD", 30, 90);

    cpc_SetInkGphStr(2, 160);
    cpc_SetInkGphStr(3, 138);
    cpc_PrintGphStrXY("3:REDEFINE", 30, 100);

    cpc_PrintGphStrXY("4:OPTIONS", 30, 110);

    cpc_SetInkGphStr(2, 128);
    cpc_SetInkGphStr(3, 128);
    cpc_PrintGphStrXY("BEAM OR FIRE TO PLAY", 20, 135);
}

void
draw_menu()
{
    uint8_t buffer[11] = "HI: ";

    // colors: 0 bg, 1 unused, 2 top/bottom, 3 center
    //
    //   8: blue
    //  42: yellow
    // 138: orange
    // 160: red
    //  32: dark purple
    //  40: light purple
    // 170: white
    // 162: light blue
    //

    ucl_uncompress(menubg, (uint8_t *)BUFF_ADDR);

    wait_vsync();
    cpc_PutSp((char *)BUFF_ADDR, 56, 80, (int)0xf050);
    draw_controls();

    if (hiscore > 0)
    {
        cpc_SetInkGphStr(2, 162);
        cpc_SetInkGphStr(3, 170);
        pad_numbers(buffer + 4, 6, hiscore);
        cpc_PrintGphStrXY(buffer, 30, 0);
    }

    cpc_SetInkGphStr(2, 160);
    cpc_SetInkGphStr(3, 40);
    cpc_PrintGphStrXY("CODE, GRAPHICS & SOUND", 18, 160);

    cpc_SetInkGphStr(2, 32);
    cpc_SetInkGphStr(3, 32);
    cpc_PrintGphStrXY("JUAN J. MARTINEZ", 24, 170);

    cpc_SetInkGphStr(2, 8);
    cpc_SetInkGphStr(3, 8);
    cpc_PrintGphStrXY("\x1f""2015 USEBOX.NET", 24, 190);
}

void
run_redefine()
{
    uint8_t i;

    memset((uint8_t *)BUFF_ADDR, 0, 65 * 80);
    cpc_PutSp((char *)BUFF_ADDR, 65, 80, (int)0xc320);

    // be sure the keyboard is free
    while (cpc_AnyKeyPressed())
        wait();

    cpc_SetInkGphStr(2, 160);
    cpc_SetInkGphStr(3, 138);
    cpc_PrintGphStrXY("PRESS KEY FOR:", 20, 110);

    cpc_SetInkGphStr(2, 42);
    cpc_SetInkGphStr(3, 42);

    // clean exiting keys
    for (i = 0; i < 6; i++)
        cpc_AssignKey(i, (int)0xffff);

    for (i = 0; i < 5; i++)
    {
        wait_vsync();
        cpc_PrintGphStrXY(redefine[i], 50, 110);
        cpc_RedefineKey(i);
    }

    // alt beam
    cpc_AssignKey(i, (int)0x0000);

    // be sure the keyboard is free
    while (cpc_AnyKeyPressed())
        wait();

    cpc_PutSp((char *)BUFF_ADDR, 65, 80, (int)0xc320);
}

uint8_t song_names[5][11] =
{
    { "THE RETURN" },
    { "THE LEGEND" },
    { "I REMEMBER" },
    { "FULL BOARD" },
    { "GAME OVER " }
};

const uint8_t *juke_songs[] = { return_mus, 0, 0, board_mus, gameover_mus };

void
draw_options(uint8_t song)
{
    cpc_SetInkGphStr(2, 160);
    cpc_SetInkGphStr(3, 138);

    wait_vsync();
    cpc_PrintGphStrXY("ESC:MAIN MENU", 22, 125);

    if (conf_mode)
        cpc_PrintGphStrXY("1:EASY MODE  ", 26, 80);
    else
        cpc_PrintGphStrXY("1:NORMAL MODE", 26, 80);

    if (conf_tiles)
        cpc_PrintGphStrXY("2:ALT TILES    ", 26, 90);
    else
        cpc_PrintGphStrXY("2:CLASSIC TILES", 26, 90);

    if (conf_music)
        cpc_PrintGphStrXY("3:MUSIC ON ", 26, 100);
    else
        cpc_PrintGphStrXY("3:MUSIC OFF", 26, 100);

    cpc_PrintGphStrXY("4:JUKEBOX [", 26, 110);
    cpc_PrintGphStrXY("]", 68, 110);

    cpc_SetInkGphStr(2, 162);
    cpc_SetInkGphStr(3, 170);
    cpc_PrintGphStrXY(song_names[song], 48, 110);
}

void
run_options()
{
    uint8_t song = 0, k_delay = 0;

    memset((uint8_t *)BUFF_ADDR, 0, 65 * 80);
    cpc_PutSp((char *)BUFF_ADDR, 65, 80, (int)0xc320);

    // be sure the keyboard is free
    while (cpc_AnyKeyPressed())
        wait();

    draw_options(song);

    while (1)
    {
        cpc_ScanKeyboard();

        if (k_delay)
        {
            k_delay--;
            continue;
        }

        if (cpc_TestKeyF(KEY_QUIT))
            break;

        if (cpc_TestKeyF(8)) // key: 1
        {
            conf_mode = !conf_mode;

            draw_options(song);
            k_delay = 8;
            continue;
        }

        if (cpc_TestKeyF(9)) // key: 2
        {
            conf_tiles = !conf_tiles;

            if (conf_tiles)
                tiles_blocks = (uint8_t *[])tiles_alt;
            else
                tiles_blocks = (uint8_t *[])tiles;

            draw_options(song);
            k_delay = 8;
            continue;
        }

        if (cpc_TestKeyF(10)) // key: 3
        {
            conf_music = !conf_music;

            draw_options(song);
            k_delay = 8;
            continue;
        }

        if (cpc_TestKeyF(11)) // key: 4
        {
            song++;
            if (song > 4)
                song = 0;

            WyzPlayerOff();
            switch (song)
            {
                default:
                    ucl_uncompress(juke_songs[song], (uint8_t *)7000);
                    cpc_WyzLoadSong(0);
                    break;
                case 1:
                case 2:
                    cpc_WyzLoadSong(song);
                    break;
            }
            WyzPlayerOn();

            draw_options(song);
            k_delay = 8;
            continue;
        }
    }

    // be sure the keyboard is free
    while (cpc_AnyKeyPressed())
        wait();

    if (song)
    {
        WyzPlayerOff();
        ucl_uncompress(return_mus, (uint8_t *)7000);
        cpc_WyzLoadSong(0);
        WyzPlayerOn();
    }

    cpc_PutSp((char *)BUFF_ADDR, 65, 80, (int)0xc320);
}

void
do_text_fadeout(char * text, uint8_t x, uint8_t y)
{
    cpc_SetInkGphStr(2, 170);
    cpc_SetInkGphStr(3, 170);
    wait();
    cpc_PrintGphStrXY2X(text, x, y);

    cpc_SetInkGphStr(2, 32);
    cpc_SetInkGphStr(3, 32);
    wait();
    wait();
    cpc_PrintGphStrXY2X(text, x, y);

    cpc_SetInkGphStr(2, 128);
    cpc_SetInkGphStr(3, 128);
    wait();
    wait();
    cpc_PrintGphStrXY2X(text, x, y);

    cpc_SetInkGphStr(2, 0);
    cpc_SetInkGphStr(3, 0);
    wait();
    wait();
    cpc_PrintGphStrXY2X(text, x, y);
}

void
screen_black()
{
    uint8_t i;

    wait_vsync();

    // all black
    for (i = 0; i < 16; i++)
        set_hw_ink(i, 0x54);
}

void
screen_fadein()
{
    uint8_t i;

    // all blue
    wait_vsync();
    for (i = 1; i < 16; i++)
        set_hw_ink(i, 0x44);

    for (i = 0; i < 4; i++)
        wait();

    // all white
    wait_vsync();
    for (i = 1; i < 16; i++)
        set_hw_ink(i, 0x4b);

    for (i = 0; i < 3; i++)
        wait();

    // final colours
    wait_vsync();
    for (i = 1; i < 16; i++)
        set_hw_ink(i, pal_hw[i]);
}

const uint8_t text_intro[] =
    "1000 YEARS HAVE PASSED SINCE THE\n"
    "LAST WAR, WHEN TRAXTOR SAVED US.\n\n"
    "WITH THE  LEGEND  NOW LONG GONE,\n"
    "THIS IS A STORY OF ITS LEGACY...";

const uint8_t intro_pos[3] = { 0, 3, 6 };

void
run_intro()
{
    const uint8_t *pt = text_intro;
    uint8_t buffer[2] = { 0, 0 };
    uint8_t i, j, k;

    init_tiles();

    cpc_WyzLoadSong(2);
    WyzPlayerOn();

    for (k = 0; k < 48; k++)
        wait();

    for (k = 0; k < 3; k++)
    {
        i = intro_pos[k];
        put_tile(tiles[k * 2], i, 1);
        put_tile(tiles[1 + k * 2], i, 2);

        put_tile(tiles[6 + k * 2], i, 14);
        put_tile(tiles[7 + k * 2], i, 15);
    }

    update_screen();
    screen_fadein();

    for (k = 0; k < 32; k++)
        wait();

    cpc_SetInkGphStr(2, 162);
    cpc_SetInkGphStr(3, 170);

    i = 8;
    j = 60;
    while (*pt)
    {
        switch (*pt)
        {
            default:
                buffer[0] = *pt;
                cpc_PrintGphStrXY(buffer, i, j);
                i += 2;
                break;
            case '\n':
                i = 8;
                j += 10;
                break;
        }
        for (k = 0; *pt != ' ' && k < 3; k++)
            wait();
        pt++;

        if (cpc_AnyKeyPressed())
            goto exit_intro;
    }

    for (k = 0; k < 42; k++)
        wait();

    WyzPlayerOff();
    cpc_WyzConfigurePlayer(0);
    WyzPlayerOn();
    cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_EXPLO);

    for (j = 0; j < 4; j++)
    {
        for (k = 0; k < 3; k++)
        {
            i = intro_pos[k];
            put_tile(tiles[TILE_EXPLO + 1 + j * 2], i,  1);
            put_tile(tiles[TILE_EXPLO + j * 2], i, 2);
        }

        for (k = 0; k < 3; k++)
        {
            i = intro_pos[k];
            put_tile(tiles[TILE_EXPLO + 1 + j * 2], i, 14);
            put_tile(tiles[TILE_EXPLO + j * 2], i, 15);
        }

        wait();
        update_screen();
        for (i = 0; i < 6; i++)
            wait();
    }

    for (k = 0; k < 3; k++)
    {
        i = intro_pos[k];
        put_tile(tiles[TILE_ERASE], i, 1);
        put_tile(tiles[TILE_ERASE], i, 2);

        put_tile(tiles[TILE_ERASE], i, 14);
        put_tile(tiles[TILE_ERASE], i, 15);
    }
    update_screen();

    for (k = 0; k < 42; k++)
        wait();

exit_intro:
    WyzPlayerOff();
}

const uint16_t bay_addr[] = { 0xc360, 0xcbb0, 0xd400, 0xdc50, 0xe4a0, 0xecf0 };

void
draw_hud()
{
    int8_t i;
    uint8_t buffer[6];

    cpc_SetInkGphStr(2, 170);
    cpc_SetInkGphStr(3, 170);

    if (dirty_hud & DIRTY_SCORE)
    {
        pad_numbers(buffer, 5, score);
        cpc_PrintGphStrXY(buffer, 7, 32);
    }

    if (dirty_hud & DIRTY_LEVEL)
    {
        pad_numbers(buffer, 2, level);
        cpc_PrintGphStrXY(buffer, 67, 32);
    }

    if (dirty_hud & DIRTY_BAY)
    {
        for (i = 2; i >= 0; i--)
            if (bay[i] == 0)
            {
                cpc_PutSp(tiles[TILE_ERASE], 9, 6, bay_addr[i * 2]);
                cpc_PutSp(tiles[TILE_ERASE], 9, 6, bay_addr[1 + i * 2]);
            }
            else
            {
                cpc_PutSp(tiles_blocks[(bay[i] - 1) * 2], 9, 6, bay_addr[i * 2]);
                cpc_PutSp(tiles_blocks[1 + (bay[i] - 1) * 2], 9, 6, bay_addr[1 + i * 2]);
            }

    }

    dirty_hud = DIRTY_NONE;
}

const uint16_t ship_addr[] = { 0xdef4, 0xdefa, 0xdf00, 0xdf06, 0xdf0c, 0xdf12, 0xdf18 };
const uint16_t engine_addr[] = { 0xef94, 0xef9a, 0xefa0, 0xefa6, 0xefac, 0xefb2, 0xefb8 };
const uint8_t engine_cycle[] = { 3, 2, 3, 2, 1, 2, 1, 0, 1 };

uint8_t engine;

void
draw_ship()
{
    cpc_PutSp(ship[0], 18, 6, ship_addr[px]);
    if (engine_cycle[engine])
        cpc_PutSp(&ship[0][126 - (engine_cycle[engine] * 6)], engine_cycle[engine], 6, engine_addr[px]);

    engine++;
    if (engine > 8)
        engine = 0;

    old_px = px;
}

void
erase_ship()
{
    if (old_px != px)
        cpc_PutSp(ship[1], 21, 6, ship_addr[old_px]);
    else
        cpc_PutSp(&ship[1][126 - 18], 3, 6, engine_addr[px]);
}

void
draw_board()
{
    uint8_t i, j;
    int8_t c;

    for (j = 0; j < BH; j++)
    {
        for (i = 0; i < BW; i++)
        {
            if (EFFECT(board[i + j & BW]))
                continue;

            c = BLOCK(board[i + j * BW]) - 1;

            if (c >= 0)
            {
                put_tile(tiles_blocks[c * 2], i, j * 2);
                put_tile(tiles_blocks[1 + c * 2], i, 1 + j * 2);
                continue;
            }
        }
    }
}

int8_t
update_py()
{
    int8_t i;

    for (i = BH - 1; i >= 0; i--)
        if (board[px + i * BW])
            break;

    return i;
}

void
add_board_line()
{
    uint8_t i;

    memmove(board + BW, board, (BW * BH) - BW);
    for (i = 0; i < BW; ++i)
    {
        board[i] = 1 + (rand() % 6);
        if (!conf_mode && i > 0 && board[i] == board[i - 1])
            board[i] = 1 + (rand() % 6);
    }

    if (!last_wild && (rand() % 4) < 2)
        board[rand() % (BW - 1)] = BLOCK_WILD;

    last_wild = last_wild ? 0 : 1;
}

// used to calculate the matches
uint8_t matches;
int8_t sc_buffer[BW * BH];

void
process_matches(uint8_t x, uint8_t y, uint8_t tile, uint8_t *matches)
{
    int8_t i;

    for (i = x - 1; i >= 0; i--)
    {
        if (!BLOCK(board[i + y * BW]))
            break;
        if (sc_buffer[i + y * BW] && BLOCK(board[i + y * BW]) == tile)
        {
            (*matches)++;
            sc_buffer[i + y * BW] = 0;
            process_matches(i, y, tile, matches);
        }
        else
            break;
    }

    for (i = x + 1; i < BW; i++)
    {
        if (!BLOCK(board[i + y * BW]))
            break;
        if (sc_buffer[i + y * BW] && BLOCK(board[i + y * BW]) == tile)
        {
            (*matches)++;
            sc_buffer[i + y * BW] = 0;
            process_matches(i, y, tile, matches);
        }
        else
            break;
    }

    for (i = y - 1; i >= 0; i--)
    {
        if (!BLOCK(board[x + i * BW]))
            break;
        if (sc_buffer[x + i * BW] && BLOCK(board[x + i * BW]) == tile)
        {
            (*matches)++;
            sc_buffer[x + i * BW] = 0;
            process_matches(x, i, tile, matches);
        }
        else
            break;
    }

    for (i = y + 1; i < BH; i++)
    {
        if (!BLOCK(board[x + i * BW]))
            break;
        if (sc_buffer[x + i * BW] && BLOCK(board[x + i * BW]) == tile)
        {
            (*matches)++;
            sc_buffer[x + i * BW] = 0;
            process_matches(x, i, tile, matches);
        }
        else
            break;
    }
}

uint16_t
has_matches()
{
    uint8_t i;

    memset(sc_buffer, 0, BLOCK_WILD + 1);

    for (i = 0; i < BW * BH; i++)
        sc_buffer[BLOCK(board[i])]++;

    for (i = 0; i < 3; i++)
        sc_buffer[bay[i]]++;

    for (i = 1; i < 7; i++)
        // 3 matches or 2 + wildcard
        if (sc_buffer[i] >= 3 || (sc_buffer[i] == 2 && sc_buffer[BLOCK_WILD]))
            return 1;

    return 0;
}

void
draw_effects()
{
    uint8_t i, j, e;

    for (j = 0; j < BH; j++)
        for (i = 0; i < BW; i++)
        {
            e = EFFECT(board[i + j * BW]);
            if (e)
            {
                e--;
                put_tile(tiles[TILE_EXPLO + e * 2], i, 1 + j * 2);
                put_tile(tiles[TILE_EXPLO + 1 + e * 2], i, j * 2);
            }
        }
}

void
add_gravity()
{
    uint8_t i, j;

    for (j = 1; j < BH; j++)
        for (i = 0; i < BW; i++)
            if (BLOCK(board[i + j * BW]) && !BLOCK(board[i + (j - 1) * BW]))
            {
                gravity[i + j * 2 * BW] = TILE_GRAVITY;
                gravity[i + (1 + (j * 2)) * BW] = TILE_GRAVITY + 1;
                board[i + j * BW] = 0;
                has_gravity = 1;
            }
}

void
update_effects()
{
    uint8_t i, j, e;

    effects_delay++;
    if (effects_delay < EFFECTS_DELAY)
        return;

    effects_delay = 0;

    for (j = 0; j < BH; j++)
        for (i = 0; i < BW; i++)
        {
            e = EFFECT(board[i + j * BW]);
            if (!e)
                continue;

            if (e < 4)
                board[i + j * BW] = UPDATE_EFFECT(board[i + j * BW], e + 1);
            else
            {
                board[i + j * BW] = 0;
                put_tile(tiles[TILE_ERASE], i, j * 2);
                put_tile(tiles[TILE_ERASE], i, 1 + j * 2);

                has_effects--;
                if (!has_effects && !gameover)
                {
                    add_gravity();

                    if (!dirty_marker)
                    {
                        put_tile(tiles[TILE_ERASE], px, py * 2);
                        dirty_marker = 1;
                    }

                    // check for empty board
                    if (!gameover && bay_top == 2)
                    {
                        empty_board = 1;
                        for (i = 0; i < BW * BH; i++)
                            if (BLOCK(board[i]))
                            {
                                empty_board = 0;
                                break;
                            }
                    }
                    return;
                }
            }
        }
}

void
erase_gravity()
{
    uint8_t i, j;

    for (j = 0; j < BH * 2; j++)
        for (i = 0; i < BW; i++)
            if (gravity[i + j * BW] && j < BH * 2 - 1)
                put_tile(tiles[TILE_ERASE], i, j);
}

void
draw_gravity()
{
    uint8_t i, j, c;

    for (j = 0; j < BH * 2; j++)
        for (i = 0; i < BW; i++)
        {
            c = gravity[i + j * BW];
            if (c)
            {
                if (j < BH * 2 - 1)
                    put_tile(tiles[c], i, j);
                if (j && !BLOCK(board[i + (j >> 1) * BW]) && !gravity[i + (j - 1) * BW])
                    put_tile(tiles[TILE_ERASE], i, j - 1);
            }
        }
}

void
update_gravity()
{
    uint8_t i;

    gravity_delay++;
    if (gravity_delay < GRAVITY_DELAY)
        return;

    gravity_delay = 0;
    has_gravity = 0;

    memmove(gravity + BW, gravity, (BW * BH * 2) - BW);
    memset(gravity, 0, BW);

    for (i = BW; i < BW * BH * 2; i++)
        if (gravity[i])
        {
            has_gravity = 1;
            return;
        }
}

void
level_up()
{
    level++;
    next_level = 24 + 3 * (int16_t)level;

    if (conf_mode) // easy
        next_line_level -= 16;
    else
        next_line_level -= 32;

    if (level % 5 == 0)
        next_line_level += 84;
    if (next_line_level < 64)
        next_line_level = 64;

    dirty_hud |= DIRTY_LEVEL;
}

void
dec_engame()
{
    uint8_t i = 21, j = 70, k;
    uint8_t p = 0x59, key = 0xfe, c;
    const uint8_t *pt = endgame;
    uint8_t buffer[2] = { 0, 0};

    while (1)
    {
        c = (*pt ^ key) ^ p;
        if (!c)
            break;

        switch (c)
        {
            default:
                buffer[0] = c;
                cpc_PrintGphStrXY(buffer, i, j);
                for (k = 0; c != ' ' && k < 3; k++)
                {
                    wait();
                    erase_ship();
                    draw_ship();
                }
                i += 2;
                break;
            case '\n':
                i = 21;
                j += 10;
                break;
        }
        p = *pt;
        pt++;
    }
}

void
run_play()
{
    uint8_t i, j, c, k_delay = 0;
    int8_t h;

    srand(tick);
    cpc_WyzConfigurePlayer(0);
    WyzPlayerOn();

    init_tiles();

    memset(board, 0, BW * BH);

    // frequency of the wildcards
    last_wild = 0;

    has_effects = 0;
    effects_delay = 0;
    combo_delay = 0;

    has_gravity = 0;
    gravity_delay = 0;

    empty_board = 0;
    gameover = 0;
    paused = 0;
    score = 0;
    level = 1;
    next_level = 15;
    next_line = 0;
    next_line_level = 336;

    px = 3;
    old_px = 3;
    py = 0;
    engine = 0;

    bay_top = 2;
    memset(bay, 0, 3);

    add_board_line();
    add_board_line();
    draw_board();

    py = 1 + update_py();
    put_tile(tiles[TILE_MARKER], px, py * 2);
    dirty_marker = 0;

    screen_black();

    wait_vsync();
    ucl_uncompress(playbg, (uint8_t *)0xc000);
    update_screen();

    if (conf_mode) // easy
    {
        cpc_SetInkGphStr(2, 8);
        cpc_SetInkGphStr(3, 8);
        cpc_PrintGphStrXY("EASY", 0, 190);
    }

    dirty_hud = DIRTY_ALL;
    draw_hud();

    draw_ship();

    cpc_SetInkGphStr(2, 138);
    cpc_SetInkGphStr(3, 42);
    cpc_PrintGphStrXY2X("READY?", 35, 90);

    screen_fadein();

    cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_READY);
    for (i = 0; i < 58; i++)
    {
        wait();
        erase_ship();
        draw_ship();
    }

    do_text_fadeout("READY?", 35, 90);

    if (conf_music)
    {
        WyzPlayerOff();
        cpc_WyzLoadSong(1);
        WyzPlayerOn();
    }

    while (1)
    {
        cpc_ScanKeyboard();

        if (cpc_TestKeyF(KEY_QUIT))
            break;

        if (!k_delay)
        {
            if (cpc_TestKeyF(KEY_PAUSE))
            {
                if (!paused)
                {
                    memset((uint8_t *)BUFF_ADDR, 0, TMW * TMH * TH * TW / 2);
                    for (j = 0; j < TMH - 1; j++)
                        for (i = 0; i < TMW; i++)
                            invalidate_tile_xy(i, j);

                    wait();
                    update_screen();

                    cpc_SetInkGphStr(2, 138);
                    cpc_SetInkGphStr(3, 42);
                    cpc_PrintGphStrXY2X("PAUSED", 35, 80);

                    if (conf_music)
                    {
                        WyzPlayerOff();
                        cpc_WyzConfigurePlayer(0);
                        WyzPlayerOn();
                    }

                    cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_ERROR);
                    paused = 1;

                }
                else
                {
                    do_text_fadeout("PAUSED", 35, 80);

                    draw_board();
                    if (has_effects)
                        draw_effects();
                    if (has_gravity)
                        draw_gravity();

                    put_tile(tiles[TILE_MARKER], px, py * 2);
                    dirty_marker = 0;

                    wait();
                    update_screen();

                    paused = 0;

                    if (conf_music)
                    {
                        WyzPlayerOff();
                        cpc_WyzLoadSong(1);
                        WyzPlayerOn();
                    }
                }

                k_delay = K_DELAY;
                continue;
            }

            if (paused)
                goto skip_controls;

            if (cpc_TestKeyF(KEY_RIGHT) && !cpc_TestKeyF(KEY_LEFT))
            {
                if (px < BW - 1)
                {
                    put_tile(tiles[TILE_ERASE], px, py * 2);
                    px++;
                    dirty_marker = 1;
                }

                k_delay = K_DELAY;
            }

            if (cpc_TestKeyF(KEY_LEFT) && !cpc_TestKeyF(KEY_RIGHT))
            {
                if (px > 0)
                {
                    put_tile(tiles[TILE_ERASE], px, py * 2);
                    px--;
                    dirty_marker = 1;
                }

                k_delay = K_DELAY;
            }

            if ((cpc_TestKeyF(KEY_BEAM) || cpc_TestKeyF(KEY_ALT_BEAM))
                    && !cpc_TestKeyF(KEY_FIRE))
            {
                if (bay_top >= 0)
                {
                    h = update_py();

                    if (h >= 0 && !EFFECT(board[px + h * BW]))
                    {
                        bay[bay_top--] = board[px + h * BW];
                        board[px + h * BW] = 0;

                        put_tile(tiles[TILE_ERASE], px, h * 2);
                        put_tile(tiles[TILE_ERASE], px, 1 + h * 2);

                        if (!dirty_marker)
                        {
                            put_tile(tiles[TILE_ERASE], px, py * 2);
                            dirty_marker = 1;
                        }

                        dirty_hud |= DIRTY_BAY;
                    }
                    else
                        cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_ERROR);
                }
                else
                    cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_ERROR);

                k_delay = K_DELAY;
            }

            if (cpc_TestKeyF(KEY_FIRE) && !cpc_TestKeyF(KEY_BEAM)
                    && !cpc_TestKeyF(KEY_ALT_BEAM))
            {
                if (bay_top < 2)
                {
                    h = update_py();

                    if (h == BH - 2)
                    {
                        k_delay = K_DELAY;
                        cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_ERROR);
                        continue;
                    }

                    // change wildcard to target block
                    if (BLOCK(bay[bay_top + 1]) == BLOCK_WILD
                            && h >= 0 && BLOCK(board[px + h * BW]))
                        bay[bay_top + 1] = BLOCK(board[px + h * BW]);

                    h++;
                    bay_top++;
                    board[px + h * BW] = bay[bay_top];
                    c = bay[bay_top];
                    bay[bay_top] = 0;
                    dirty_hud |= DIRTY_BAY;

                    matches = 0;
                    memset(sc_buffer, 1,  BW * BH);
                    process_matches(px, h, c, &matches);

                    // 3 matches and not targeting a wildcard!
                    if (matches >= 3 && BLOCK(board[px + h * BW]) != BLOCK_WILD)
                    {
                        next_level -= matches;

                        for (j = 0; j < BH; j++)
                            for (i = 0; i < BW; i++)
                            {
                                if (!sc_buffer[i + j * BW])
                                {
                                    if (EFFECT(board[i + j * BW]))
                                    {
                                        cpc_SetInkGphStr(2, 138);
                                        cpc_SetInkGphStr(3, 42);

                                        cpc_PrintGphStrXY("COMBO!", 6, 52);
                                        combo_delay = 32;
                                    }
                                    else
                                        has_effects++;
                                    board[i + j * BW] = UPDATE_EFFECT(board[i + j * BW], 1);
                                    cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_EXPLO);
                                }
                            }

                        score += matches * 5;
                        if (matches > 3)
                            score += (matches - 3) * 10;

                        dirty_hud |= DIRTY_SCORE;

                        if (score > hiscore)
                            hiscore = score;
                    }
                    else
                    {
                        c--;
                        // draw only the changed tile
                        put_tile(tiles_blocks[c * 2], px, h * 2);
                        put_tile(tiles_blocks[1 + c * 2], px, 1 + h * 2);
                    }

                    // will update marker
                    dirty_marker = 1;
                }
                else
                    cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_ERROR);

                k_delay = K_DELAY;
            }
        }
        else
            k_delay--;

skip_controls:
        if (!paused && has_effects)
        {
            update_effects();
            draw_effects();
        }

        if (!paused && has_gravity)
        {
            update_gravity();
            draw_gravity();
        }

        if (dirty_marker)
        {
            py = 1 + update_py();
            put_tile(tiles[TILE_MARKER], px, py * 2);
            dirty_marker = 0;
        }

        wait();
        update_screen();
        erase_ship();
        draw_ship();
        draw_hud();

        if (paused)
            continue;

        if (combo_delay)
        {
            combo_delay--;
            if (!combo_delay)
                cpc_PrintGphStrXY("      ", 6, 52);
        }

        if (empty_board)
        {
            if (conf_music)
            {
                WyzPlayerOff();
                cpc_WyzConfigurePlayer(0);
                WyzPlayerOn();
            }

            while (has_gravity)
            {
                update_gravity();
                draw_gravity();
                wait();
                update_screen();
                erase_ship();
                draw_ship();
            }

            if (combo_delay)
            {
                combo_delay = 0;
                cpc_PrintGphStrXY("      ", 6, 52);
            }

            dirty_hud = DIRTY_ALL;
            draw_hud();

            memset((uint8_t *)BUFF_ADDR, 0, TMW * TMH * TH * TW / 2);
            for (j = 0; j < TMH - 1; j++)
                for (i = 0; i < TMW; i++)
                    invalidate_tile_xy(i, j);

            wait();
            update_screen();

            px = 3;

            WyzPlayerOff();
            ucl_uncompress(board_mus, (uint8_t *)7000);
            cpc_WyzLoadSong(0);
            WyzPlayerOn();

            cpc_SetInkGphStr(2, 138);
            cpc_SetInkGphStr(3, 42);
            cpc_PrintGphStrXY2X("FULL BOARD", 31, 60);
            for (i = 0; i < 72; i++)
            {
                wait();
                erase_ship();
                draw_ship();
            }

            WyzPlayerOff();
            WyzPlayerOn();

            cpc_SetInkGphStr(2, 160);
            cpc_SetInkGphStr(3, 40);
            cpc_PrintGphStrXY("LINES", 31, 85);
            i = 0;
            if (next_level > 0)
                i += next_level * 10;
            score += i;
            pad_numbers((uint8_t *)BUFF_ADDR, 4, i);
            cpc_PrintGphStrXY((char *)BUFF_ADDR, 31 + 12, 85);

            dirty_hud = DIRTY_SCORE;
            draw_hud();

            if (i == 0)
                cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_ERROR);
            else
                cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_LEVEL);

            for (i = 0; i < 46; i++)
            {
                wait();
                erase_ship();
                draw_ship();
            }

            score += 2500;
            cpc_SetInkGphStr(2, 160);
            cpc_SetInkGphStr(3, 40);
            cpc_PrintGphStrXY("EXTRA 2500", 31, 95);

            dirty_hud = DIRTY_SCORE;
            draw_hud();

            cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_LEVEL);
            for (i = 0; i < 46; i++)
            {
                wait();
                erase_ship();
                draw_ship();
            }

            cpc_SetInkGphStr(2, 42);
            cpc_SetInkGphStr(3, 170);
            cpc_PrintGphStrXY("LEVEL  UP!", 31, 115);

            level_up();
            draw_hud();

            cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_LEVEL);
            for (i = 0; i < 46; i++)
            {
                wait();
                erase_ship();
                draw_ship();
            }

            memset((uint8_t *)BUFF_ADDR, 0, TMW * TMH * TH * TW / 2);
            for (j = 0; j < TMH - 1; j++)
                for (i = 0; i < TMW; i++)
                    invalidate_tile_xy(i, j);

            wait();
            update_screen();

            next_line = 0;
            add_board_line();
            add_board_line();
            draw_board();

            py = 1 + update_py();
            put_tile(tiles[TILE_MARKER], px, py * 2);
            dirty_marker = 0;

            wait();
            update_screen();

            cpc_SetInkGphStr(2, 138);
            cpc_SetInkGphStr(3, 42);
            cpc_PrintGphStrXY2X("READY?", 35, 90);

            cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_READY);
            for (i = 0; i < 58; i++)
            {
                wait();
                erase_ship();
                draw_ship();
            }

            do_text_fadeout("READY?", 35, 90);

            if (conf_music)
            {
                WyzPlayerOff();
                cpc_WyzLoadSong(1);
                WyzPlayerOn();
            }

            if (score > hiscore)
                hiscore = score;

            empty_board = 0;
            continue;
        }

        if (++next_line > next_line_level || !has_matches())
        {
            next_line = 0;
            add_board_line();
            cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_LINE);

            if (has_gravity)
            {
                update_gravity();
                update_gravity();
                draw_gravity();
            }

            draw_board();

            for (i = 0; i < BW; i++)
                if (board[i + (BH - 1) * BW] != 0)
                {
                    if (conf_music)
                    {
                        WyzPlayerOff();
                        cpc_WyzConfigurePlayer(0);
                        WyzPlayerOn();
                    }

                    update_screen();
                    gameover = 1;

                    bay_top = 2;
                    memset(bay, 0, 3);
                    dirty_hud |= DIRTY_BAY;
                    draw_hud();

                    // hacky!
                    memset((uint8_t *)BUFF_ADDR, 0, TMW * TMH * TH * TW / 2);
                    for (i = 0; i < BW; i++)
                        invalidate_tile_xy(i, TMH - 1);

                    wait();
                    cpc_PutSp(ship[1], 21, 6, ship_addr[px]);
                    update_screen();

                    erase_gravity();
                    put_tile(tiles[TILE_ERASE], px, py * 2);
                    draw_board();
                    wait();
                    update_screen();

                    for (j = 0; j < BH; j++)
                    {
                        for (i = 0; i < BW; i++)
                            if (BLOCK(board[i + (BH - 1 - j) * BW])
                                    && !EFFECT(board[i + (BH - 1 - j) * BW]))
                            {
                                board[i + (BH - 1 - j) * BW] = UPDATE_EFFECT(1, 1);
                                has_effects++;
                            }

                        cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_EXPLO);
                        while (has_effects)
                        {
                            update_effects();
                            draw_effects();
                            update_screen();
                        }
                    }

                    cpc_SetInkGphStr(2, 138);
                    cpc_SetInkGphStr(3, 42);
                    cpc_PrintGphStrXY2X("GAME  OVER", 31, 80);

                    WyzPlayerOff();
                    ucl_uncompress(gameover_mus, (uint8_t *)7000);
                    cpc_WyzLoadSong(0);
                    WyzPlayerOn();

                    for (i = 0; i < 118; i++)
                        wait();

                    WyzPlayerOff();

                    for (i = 0; i < 24; i++)
                        wait();

                    do_text_fadeout("GAME  OVER", 31, 80);
                    break;
                }

            if (gameover)
                break;

            py = 1 + update_py();
            put_tile(tiles[TILE_MARKER], px, py * 2);
            dirty_marker = 0;

            wait();
            update_screen();
        }

        if (!has_effects && next_level <= 0)
        {
            cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_LEVEL);
            level_up();

            if (level > ENDGAME)
            {
                gameover = 1;
                bay_top = 2;
                memset(bay, 0, 3);
                dirty_hud |= DIRTY_BAY;
                draw_hud();

                erase_gravity();
                put_tile(tiles[TILE_ERASE], px, py * 2);
                draw_board();
                wait();
                update_screen();

                px = 3;

                for (j = 0; j < BH; j++)
                {
                    for (i = 0; i < BW; i++)
                        if (BLOCK(board[i + (BH - 1 - j) * BW])
                                && !EFFECT(board[i + (BH - 1 - j) * BW]))
                        {
                            board[i + (BH - 1 - j) * BW] = UPDATE_EFFECT(1, 1);
                            has_effects++;
                        }

                    cpc_WyzStartEffect(WYZ_EFX_CHAN, SND_EXPLO);
                    while (has_effects)
                    {
                        update_effects();
                        draw_effects();
                        update_screen();
                        erase_ship();
                        draw_ship();
                    }
                }

                cpc_SetInkGphStr(2, 138);
                cpc_SetInkGphStr(3, 42);
                cpc_PrintGphStrXY2X("WELL DONE!", 31, 35);

                WyzPlayerOff();
                ucl_uncompress(return_mus, (uint8_t *)7000);
                cpc_WyzLoadSong(0);
                WyzPlayerOn();

                cpc_SetInkGphStr(2, 162);
                cpc_SetInkGphStr(3, 170);
                dec_engame();

                // be sure the keyboard is free
                while (cpc_AnyKeyPressed())
                    wait();

                while (!cpc_AnyKeyPressed())
                {
                    wait();
                    erase_ship();
                    draw_ship();
                }

                wait_vsync();
                cpc_ClrScr();

                break;
            }
        }
    }

    WyzPlayerOff();

    wait_vsync();
    cpc_ClrScr();
}

const uint8_t text_cycle[] = { 0x4b, 0x4a, 0x47, 0x4e, 0x4c, 0x4e, 0x47, 0x4a  };

int
main()
{
    uint8_t cycle = 0;

    setup_int();

    // black
    set_hw_border(0x54);
    set_hw_ink(0, 0x54);

    cpc_WyzInitPlayer(wyz_sound_table, wyz_ins_table, wyz_effect_table, wyz_song_table);
    cpc_WyzConfigurePlayer(0);

    cpc_SetFont(31, font);

    joystick = 1;
    map_keys();
    cpc_AssignKey(KEY_QUIT, 0x4804); // ESC
    cpc_AssignKey(8, 0x4801); // 1
    cpc_AssignKey(9, 0x4802); // 2
    cpc_AssignKey(10, 0x4702); // 3
    cpc_AssignKey(11, 0x4701); // 4

    cpc_SetInkGphStr(0, 0);

    screen_black();
    cpc_ClrScr();
    run_intro();

    screen_black();
    cpc_ClrScr();
    draw_menu();
    screen_fadein();

    ucl_uncompress(return_mus, (uint8_t *)7000);
    cpc_WyzLoadSong(0);
    WyzPlayerOn();

    while (1)
    {
        cpc_ScanKeyboard();

        if (cpc_TestKeyF(8) && !cpc_TestKeyF(9) && !joystick) // key: 1
        {
            joystick = 1;
            wait_vsync();
            draw_controls();

            map_keys();
            continue;
        }

        if (cpc_TestKeyF(9) && !cpc_TestKeyF(8) && joystick) // key: 2
        {
            joystick = 0;
            wait_vsync();
            draw_controls();

            map_keys();
            continue;
        }

        if (cpc_TestKeyF(10)) // key: 3
        {
            run_redefine();

            joystick = 0;
            draw_controls();
            continue;
        }

        if (cpc_TestKeyF(11)) // key: 4
        {
            run_options();

            draw_controls();
            continue;
        }

        if (cpc_TestKey(KEY_FIRE) || cpc_TestKey(KEY_BEAM)) // fire
        {
            // clean the cycle
            set_hw_ink(1, 0x44);
            WyzPlayerOff();

            run_play();

            screen_black();
            draw_menu();
            screen_fadein();

            ucl_uncompress(return_mus, (uint8_t *)7000);
            cpc_WyzLoadSong(0);
            WyzPlayerOn();
        }

        wait();
        if (++cycle > 7)
            cycle = 0;
        set_hw_ink(1, text_cycle[cycle]);
    }
}
