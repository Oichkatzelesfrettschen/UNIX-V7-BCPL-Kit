# BCPL kit build rules
PREFIX?=/usr/local

# toolchain configuration (defaults may be overridden)
AS ?= as
LD ?= ld
CC ?= cc
AFLAGS ?= --32
CFLAGS ?= -m32
LDFLAGS ?= -m elf_i386
# Determine build architecture
ARCHBITS ?= $(shell [ "$(BUILD_BITS)" ] && echo $(BUILD_BITS) || \
([ "`uname -m`" = "x86_64" ] && echo 64 || echo 32))
OBJDIR ?= build/$(ARCHBITS)
BINDIR ?= $(OBJDIR)

CFLAGS += -m$(ARCHBITS) -std=c23
AFLAGS += --$(ARCHBITS)
LDFLAGS += -m $(if $(filter 64,$(ARCHBITS)),elf_x86_64,elf_i386)

O := $(OBJDIR)
B := $(BINDIR)
$(OBJDIR):
		mkdir -p $(OBJDIR)
all: $(B)/st $(B)/cg $(B)/xg
st: $(B)/st
cg: $(B)/cg
xg: $(B)/xg
xg1: $(B)/xg1
cg1: $(B)/cg1
st1: $(B)/st1
xg0: $(B)/xg0
cg0: $(B)/cg0
st0: $(B)/st0
icint: $(B)/icint

$(B)/xg: $(O)/su.o $(O)/xg.o $(O)/rt.o $(O)/sys.o | $(BINDIR)
	$(LD) $(LDFLAGS) -o $@ $(O)/su.o $(O)/xg.o $(O)/rt.o $(O)/sys.o

$(O)/xg.o: xg.s | $(OBJDIR)
	$(AS) $(AFLAGS) -o $@ xg.s

xg.s: $(B)/xg1 xg.int
	$(B)/xg1 <xg.int
		mv ASM xg.s

xg.int: $(B)/st1 $(B)/cg1 iclib.i blib.i xg.b
	$(B)/st1 < xg.b
	$(B)/cg1 < OCODE
		cat iclib.i blib.i INTCODE >xg.int

$(B)/cg: $(O)/su.o $(O)/cg.o $(O)/rt.o $(O)/sys.o | $(BINDIR)
	$(LD) $(LDFLAGS) -o $@ $(O)/su.o $(O)/cg.o $(O)/rt.o $(O)/sys.o

$(O)/cg.o: cg.s | $(OBJDIR)
	$(AS) $(AFLAGS) -o $@ cg.s

cg.s: $(B)/xg1 cg.int
	$(B)/xg1 <cg.int
		mv ASM cg.s

cg.int: $(B)/st1 $(B)/cg1 iclib.i blib.i cg.b
	$(B)/st1 < cg.b
	$(B)/cg1 < OCODE
		cat iclib.i blib.i INTCODE >cg.int

$(B)/st: $(O)/su.o $(O)/st.o $(O)/rt.o $(O)/sys.o | $(BINDIR)
	$(LD) $(LDFLAGS) -o $@ $(O)/su.o $(O)/st.o $(O)/rt.o $(O)/sys.o

$(O)/st.o: st.s | $(OBJDIR)
	$(AS) $(AFLAGS) -o $@ st.s

st.s: $(B)/xg1 st.int
	$(B)/xg1 <st.int
		mv ASM st.s

st.int: $(B)/st1 $(B)/cg1 iclib.i blib.i syn.b trn.b
	$(B)/st1 < syn.b
	$(B)/cg1 < OCODE
		cat iclib.i blib.i INTCODE >st.int
	$(B)/st1 < trn.b
	$(B)/cg1 < OCODE
		cat INTCODE >>st.int

$(B)/xg1: $(O)/su.o $(O)/xg1.o $(O)/rt.o $(O)/sys.o | $(BINDIR)
	$(LD) $(LDFLAGS) -o $@ $(O)/su.o $(O)/xg1.o $(O)/rt.o $(O)/sys.o

$(O)/xg1.o: xg1.s | $(OBJDIR)
	$(AS) $(AFLAGS) -o $@ xg1.s

xg1.s: $(B)/xg0 xg1.int xg1.int
	$(B)/xg0 <xg1.int
		mv ASM xg1.s

xg1.int: $(B)/st0 $(B)/cg0 iclib.i blib.i xg.b
	$(B)/st0 < xg.b
	$(B)/cg0 < OCODE
		cat iclib.i blib.i INTCODE >xg1.int

$(B)/cg1: $(O)/su.o $(O)/cg1.o $(O)/rt.o $(O)/sys.o | $(BINDIR)
	$(LD) $(LDFLAGS) -o $@ $(O)/su.o $(O)/cg1.o $(O)/rt.o $(O)/sys.o

$(O)/cg1.o: cg1.s | $(OBJDIR)
	$(AS) $(AFLAGS) -o $@ cg1.s

cg1.s: $(B)/xg0 xg1.int cg1.int
	$(B)/xg0 <cg1.int
		mv ASM cg1.s

cg1.int: $(B)/st0 $(B)/cg0 iclib.i blib.i cg.b
	$(B)/st0 < cg.b
	$(B)/cg0 < OCODE
		cat iclib.i blib.i INTCODE >cg1.int

$(B)/st1: $(O)/su.o $(O)/st1.o $(O)/rt.o $(O)/sys.o | $(BINDIR)
	$(LD) $(LDFLAGS) -o $@ $(O)/su.o $(O)/st1.o $(O)/rt.o $(O)/sys.o

$(O)/st1.o: st1.s | $(OBJDIR)
	$(AS) $(AFLAGS) -o $@ st1.s

st1.s: $(B)/xg0 xg1.int st1.int
	$(B)/xg0 <st1.int
		mv ASM st1.s

st1.int: $(B)/st0 $(B)/cg0 iclib.i blib.i syn.b trn.b
	$(B)/st0 < syn.b
	$(B)/cg0 < OCODE
		cat iclib.i blib.i INTCODE >st1.int
	$(B)/st0 < trn.b
	$(B)/cg0 < OCODE
		cat INTCODE >>st1.int

$(B)/xg0: $(O)/su.o $(O)/xg0.o $(O)/rt.o $(O)/sys.o | $(BINDIR)
	$(LD) $(LDFLAGS) -o $@ $(O)/su.o $(O)/xg0.o $(O)/rt.o $(O)/sys.o

$(O)/xg0.o: xg0.s | $(OBJDIR)
	$(AS) $(AFLAGS) -o $@ xg0.s

xg0.s: $(B)/icint xg0.int xg0.int
	$(B)/icint xg0.int <xg0.int
		mv ASM xg0.s

$(B)/cg0: $(O)/su.o $(O)/cg0.o $(O)/rt.o $(O)/sys.o | $(BINDIR)
	$(LD) $(LDFLAGS) -o $@ $(O)/su.o $(O)/cg0.o $(O)/rt.o $(O)/sys.o

$(O)/cg0.o: cg0.s | $(OBJDIR)
	$(AS) $(AFLAGS) -o $@ cg0.s

cg0.s: $(B)/icint xg0.int cg0.int
	$(B)/icint xg0.int <cg0.int
		mv ASM cg0.s

$(B)/st0: $(O)/su.o $(O)/st0.o $(O)/rt.o $(O)/sys.o | $(BINDIR)
	$(LD) $(LDFLAGS) -o $@ $(O)/su.o $(O)/st0.o $(O)/rt.o $(O)/sys.o

$(O)/st0.o: st0.s | $(OBJDIR)
	$(AS) $(AFLAGS) -o $@ st0.s

st0.s: $(B)/icint xg0.int st0.int
	$(B)/icint xg0.int <st0.int
		mv ASM st0.s

$(O)/sys.o: sys.s | $(OBJDIR)
	$(AS) $(AFLAGS) -o $@ sys.s

$(O)/rt.o: rt.s | $(OBJDIR)
	$(AS) $(AFLAGS) -o $@ rt.s

$(O)/su.o: su.s | $(OBJDIR)
	$(AS) $(AFLAGS) -o $@ su.s

xg0.int: iclib.i blib.i xg.i
		cat iclib.i blib.i xg.i >xg0.int

xg.i: $(B)/icint st0.int cg0.int LIBHDR xg.b
	$(B)/icint st0.int <xg.b
	$(B)/icint cg0.int <OCODE
		mv INTCODE xg.i

cg0.int: iclib.i blib.i cg.i
			cat iclib.i blib.i cg.i >cg0.int

st0.int: iclib.i blib.i syn.i trn.i
			cat iclib.i blib.i syn.i trn.i >st0.int

	$(B)/icint: $(O)/icint.o $(O)/blib.o | $(BINDIR)
	$(CC) $(CFLAGS) -o $@ $(O)/icint.o $(O)/blib.o

	$(O)/blib.o: blib.c blib.h | $(OBJDIR)
	$(CC) $(CFLAGS) -c blib.c -o $@

	$(O)/icint.o: icint.c blib.h | $(OBJDIR)
	$(CC) $(CFLAGS) -c icint.c -o $@

		install: bcpl icint st cg xg LIBHDR iclib.i blib.i rules $(O)/su.o $(O)/rt.o $(O)/sys.o
		mkdir -p $(PREFIX)/bin $(PREFIX)/lib/bcplkit
		install -c  -m 755 bcpl      $(PREFIX)/bin
		install -cs -m 555 $(B)/icint     $(PREFIX)/bin
			install -cs -m 555 $(B)/st        $(PREFIX)/lib/bcplkit
		install -cs -m 555 $(B)/cg        $(PREFIX)/lib/bcplkit
		install -cs -m 555 $(B)/xg        $(PREFIX)/lib/bcplkit
		install -c  -m 644 LIBHDR    $(PREFIX)/lib/bcplkit
		install -c  -m 444 iclib.i   $(PREFIX)/lib/bcplkit
		install -c  -m 444 blib.i    $(PREFIX)/lib/bcplkit
		install -c  -m 644 rules     $(PREFIX)/lib/bcplkit
			install -c  -m 444 $(O)/su.o      $(PREFIX)/lib/bcplkit
		install -c  -m 444 $(O)/rt.o      $(PREFIX)/lib/bcplkit
		install -c  -m 444 $(O)/sys.o     $(PREFIX)/lib/bcplkit

clean:
		rm -f OCODE INTCODE ASM
		rm -f st0.int cg0.int xg.i xg0.int
		rm -f st1.int cg1.int xg1.int
		rm -f st.int cg.int xg.int
		rm -f st0.s cg0.s xg0.s st1.s cg1.s xg1.s st.s cg.s xg.s
			rm -rf $(OBJDIR)
