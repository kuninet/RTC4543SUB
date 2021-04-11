#
# Makefile
#

.SUFFIXES: .asm .p .hex .sr .com

all:	RTC4543_RD-YM2203.hex RTC4543_WR-YM2203.hex

.p.com:
	p2bin $*.p $*.com

.p.hex:
	p2hex -F Intel $*.p $*.hex

.p.sr:
	p2hex -F Moto $*.p $*.sr

.asm.p:	
	asl -L $*.asm

clean:
	rm -f *.p *.hex *.sr *.lst