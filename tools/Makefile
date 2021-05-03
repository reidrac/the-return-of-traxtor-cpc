BIN=idsk 2cdt ucl png2crtc hex2bin

all: $(BIN)
CC=gcc
CFLAGS=-s -O3 -Wall

idsk:
	mkdir iDSK/build
	cd iDSK/build && cmake ../
	make -C iDSK/build
	cp iDSK/build/iDSK idsk
	rm -rf iDSK/build

2cdt:
	make -C 2CDT
	cp 2CDT/2cdt .

png2crtc:
	make -C gfx2crtc
	cp gfx2crtc/png2crtc .

%.o: %.c
	$(CC) $(CFLAGS) $< -o $@ -c

ucl: ucl.o
	$(CC) -lucl $< -o $@

hex2bin:
	make -C hex2bin-2.0
	cp hex2bin-2.0/bin/hex2bin .

.PHONY: clean
clean:
	make -C 2CDT clean
	make -C gfx2crtc clean
	make -C hex2bin-2.0 clean
	rm -f $(BIN) *.o

