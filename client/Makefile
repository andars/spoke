SELF:=$(lastword $(MAKEFILE_LIST))
OUT=$(realpath $(dir $(SELF))/..)/_out/client

CFLAGS += -Wall -Werror

all: $(OUT)/spoke $(OUT)/serial

$(OUT)/spoke: $(OUT)/spoke.o

$(OUT)/serial: $(OUT)/serial.o

$(OUT)/%.o: %.c $(OUT)
	$(CC) -c $(CFLAGS) -o $@ $<

$(OUT):
	mkdir -p $@
