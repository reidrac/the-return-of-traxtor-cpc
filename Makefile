TARGET=traxtor
GENERATED=font.h menubg.h tiles.h tiles_alt.h playbg.h ship.h return_mus.h board_mus.h gameover_mus.h

LOADER_ADDR=512
TMP_ADDR=3072
APP_ADDR=8072

LOADER_ADDR_HEX=$(shell printf "%x" $(LOADER_ADDR))
TMP_ADDR_HEX=$(shell printf "%x" $(TMP_ADDR))
APP_ADDR_HEX=$(shell printf "%x" $(APP_ADDR))

CC=sdcc
AS=sdasz80
AR=sdcclib
CFLAGS=-mz80 -Ilib
LDFLAGS=-Llib -L. --data-loc 0 --no-std-crt0 --fomit-frame-pointer

export PATH:=tools:$(PATH)

all:
	make -C tools
	make -C lib
	make $(TARGET).dsk
	make $(TARGET).cdt
	@chksize 8072 main.map

$(TARGET).dsk: main.bin loader.bin loading.bin
	cp loader_disk.bin $(TARGET)
	idsk $@ -n -t 1 -i $(TARGET) -e $(LOADER_ADDR_HEX) -c $(LOADER_ADDR_HEX) > /dev/null
	rm -f $(TARGET)
	cp loading.bin main.bi0
	idsk $@ -t 1 -i main.bi0 -c $(TMP_ADDR_HEX) -s > /dev/null
	rm -f main.bi0
	cp main.bin main.bi1
	idsk $@ -t 1 -i main.bi1 -e $(shell awk ' /_main_init/ { print $$1 } ' main.map) -c $(APP_ADDR_HEX) -s > /dev/null
	rm -f main.bi1

$(TARGET).cdt: main.bin loader.bin loading.bin
	2cdt -n -X $(LOADER_ADDR) -L $(LOADER_ADDR) -r $(TARGET) loader.bin $@ > /dev/null
	2cdt -m 2 loading.bin $@ > /dev/null
	2cdt -m 2 $< $@ > /dev/null

loader.bin: loader.s turboload.s main.map loading.bin
	echo "DISK = 1" > loader.opt
	echo "APP_EP = 0x$(shell awk ' /_main_init/ { print $$1 } ' main.map)" >> loader.opt
	echo "TMP_ADDR = 0x$(TMP_ADDR_HEX)" >> loader.opt
	echo "SCRX_SIZE = $(shell stat -c '%s' loading.bin)" >> loader.opt
	echo "APP_ADDR = 0x$(APP_ADDR_HEX)" >> loader.opt
	echo "APP_SIZE = $(shell stat -c '%s' main.bin)" >> loader.opt
	$(AS) -g -o $<
	$(CC) $(CFLAGS) $(LDFLAGS) --code-loc $(LOADER_ADDR) -lucl loader.rel
	hex2bin -p 00 loader.ihx
	echo "DISK = 0" > loader.opt
	echo "APP_EP = 0x$(shell awk ' /_main_init/ { print $$1 } ' main.map)" >> loader.opt
	echo "TMP_ADDR = 0x$(TMP_ADDR_HEX)" >> loader.opt
	echo "SCRX_SIZE = $(shell stat -c '%s' loading.bin)" >> loader.opt
	echo "APP_ADDR = 0x$(APP_ADDR_HEX)" >> loader.opt
	echo "APP_SIZE = $(shell stat -c '%s' main.bin)" >> loader.opt
	$(AS) -g -o $<
	$(CC) $(CFLAGS) $(LDFLAGS) --code-loc $(LOADER_ADDR) -lucl -o loader_disk.ihx loader.rel
	hex2bin -p 00 loader_disk.ihx

loading.bin: loading.png
	png2crtc loading.png loading.scr 7 1
	dump-pal.py loading.png pal.bin
	echo -n "SCRX" > loading.bin
	cat pal.bin >> loading.bin
	ucl < loading.scr >> loading.bin

main.bin: main.c crt0.s splib.lib sound.h sound.rel $(GENERATED)
	rm -f main.map
	$(AS) -g -o crt0.s
	$(CC) $(CFLAGS) $(LDFLAGS) -lsplib -lucl -lcpcrslib -lcpcwyzlib --code-loc $(APP_ADDR) crt0.rel sound.rel $<
	hex2bin -p 00 main.ihx

splib.lib: splib.c splib.h
	$(CC) $(CFLAGS) $(LDFLAGS) -c $<
	$(AR) -a $@ splib.rel

font.h: font.gif
	img2f.py --effect font.gif font > font.h

menubg.h: menu.png
	img2sprite.py --height 56 --width 160 -b menu.png > menubg.bin
	ucl < menubg.bin > menu.bin
	bin2h.py menu.bin menubg > menubg.h

tiles.h: tiles.png
	img2sprite.py --height 9 --width 12 -i tiles tiles.png > tiles.h

tiles_alt.h: tiles_alt.png
	img2sprite.py --height 9 --width 12 -i tiles_alt tiles_alt.png > tiles_alt.h

ship.h: ship.png
	img2sprite.py --height 21 --width 12 -i ship ship.png > ship.h

playbg.h: play.png
	png2crtc play.png play.scr 7 0
	ucl < play.scr > play.bin
	bin2h.py play.bin playbg > playbg.h

sound.rel: sound.c sound.h theplayer_mus.h intro_mus.h
	$(CC) $(CFLAGS) $(LDFLAGS) -c $<

return_mus.h: music/return.mus
	ucl < music/return.mus > return.bin
	bin2h.py return.bin return_mus > return_mus.h

board_mus.h: music/board.mus
	ucl < music/board.mus > board.bin
	bin2h.py board.bin board_mus > board_mus.h

gameover_mus.h: music/gameover.mus
	ucl < music/gameover.mus > gameover.bin
	bin2h.py gameover.bin gameover_mus > gameover_mus.h

theplayer_mus.h: music/theplayer.mus
	bin2h.py music/theplayer.mus theplayer_mus > theplayer_mus.h

intro_mus.h: music/intro.mus
	bin2h.py music/intro.mus intro_mus > intro_mus.h

.PHONY: clean all cleanall
clean:
	rm -f *.dsk *.bin *.cdt *.scr *.rel *.opt *.lk *.noi *.map *.lst *.sym *.asm *.ihx *.lib $(GENERATED) theplayer_mus.h intro_mus.h

cleanall:
	make clean
	make -C tools clean
	make -C lib clean

