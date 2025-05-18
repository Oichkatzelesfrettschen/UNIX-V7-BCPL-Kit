# $Id: Makefile,v 1.4 2004/12/21 11:53:53 rn Exp $

BCPL=bcpl

all: cmpltest xref gpm

cmpltest: cmpltest.b
	$(BCPL) cmpltest.b

xref: xref.b
	$(BCPL) xref.b

gpm: gpm.b
	$(BCPL) gpm.b

install:

clean:
	rm -f ASM INTCODE OCODE
	rm -f cmpltest cmpltest.o cmpltest.s cmpltest.int
	rm -f xref xref.o xref.s xref.int
	rm -f gpm gpm.o gpm.s gpm.int
