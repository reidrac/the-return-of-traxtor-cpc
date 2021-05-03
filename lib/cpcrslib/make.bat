del *.rel
del *.lib
sdasz80 -o cpcrslib.s
sdasz80 -o GphStr.s
sdasz80 -o Sprites.s
sdasz80 -o Keyboard.s
sdasz80 -o UnExoOpt.s
sdasz80 -o Uncrunch.s
sdasz80 -o GphStrStd.s
sdasz80 -o TileMap.s
sdasz80 -o Wyz.s



sdar rc cpcrslib.lib cpcrslib.rel GphStr.rel Sprites.rel Keyboard.rel UnExoOpt.rel Uncrunch.rel GphStrStd.rel TileMap.rel 

sdar rc cpcwyzlib.lib Wyz.rel
copy cpcrslib.lib C:\sdcc\lib\z80
copy cpcwyzlib.lib C:\sdcc\lib\z80
