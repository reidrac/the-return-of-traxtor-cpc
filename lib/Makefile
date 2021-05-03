all: ucl.lib cpcrslib.lib

AS=sdasz80
AR=sdcclib

ucl.lib: ucl.s
	$(AS) -o $<
	$(AR) -a $@ ucl.rel

cpcrslib.lib: $(wildcard cpcrslib/*.s)
	make -C cpcrslib

cpcwyzlib.lib: $(wildcard cpcrslib/*.s)
	make -C cpcwyzlib

.PHONY: clean
clean:
	rm -f *.rel *.lib
	make -C cpcrslib clean

