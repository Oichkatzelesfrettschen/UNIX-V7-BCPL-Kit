CC ?= cc
CFLAGS ?= -std=c23 -O2
CFLAGS += -I../src-headers -m$(BITS)

OBJDIR ?= build/$(BITS)
LIB := $(OBJDIR)/libkernel.a

SRCS := ipc/mailbox.c ipc/exo.c
OBJS := $(SRCS:%=$(OBJDIR)/%)

all: $(LIB)

$(OBJDIR)/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(LIB): $(OBJS)
	ar rcs $@ $^

clean:
	rm -rf build

.PHONY: all clean
