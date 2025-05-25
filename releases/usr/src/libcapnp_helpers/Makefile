CXXFLAGS?=-O2 -std=c++20
AR?=ar

OBJS=helpers.o

all: libcapnp_helpers.a

libcapnp_helpers.a: $(OBJS)
$(AR) rc $@ $(OBJS)
ranlib $@

clean:
rm -f $(OBJS) libcapnp_helpers.a
