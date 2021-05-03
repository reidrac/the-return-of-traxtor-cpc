all: cpcrslib.lib cpcwyzlib.lib

AS=sdasz80
AR=sdcclib
cpcrslib_SRCS=$(wildcard cpc_*.s)
cpcrslib_OBJS=$(patsubst %.s,%.rel,$(cpcrslib_SRCS))
cpcwyzlib_OBJS=Wyz.rel

cpcrslib.lib: $(cpcrslib_OBJS)
	$(AR) -a cpcrslib.lib $(cpcrslib_OBJS)
	cp cpcrslib.lib ..

cpcwyzlib.lib: $(cpcwyzlib_OBJS)
	$(AR) -a cpcwyzlib.lib $(cpcwyzlib_OBJS)
	cp cpcwyzlib.lib ..

%.rel: %.s
	$(AS) -o $<

.PHONY: clean
clean:
	rm -f *.rel *.lib

