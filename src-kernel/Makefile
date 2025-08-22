CC ?= cc
# Enable aggressive optimisation and extensive warnings by default.  The
# flags can still be overridden by users supplying their own `CFLAGS`.
CFLAGS ?= -std=c2x -O3 -pipe -fstack-protector-strong -fdata-sections -ffunction-sections -Wall -Wextra -Wpedantic
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
