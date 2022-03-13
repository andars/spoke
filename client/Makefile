SELF:=$(lastword $(MAKEFILE_LIST))
OUT=$(realpath $(dir $(SELF))/..)/_out/client

CFLAGS += -Wall -Werror

$(OUT)/serial: $(OUT)/serial.o

$(OUT)/%.o: %.c $(OUT)
	$(CC) -c $(CFLAGS) -o $@ $<

$(OUT):
	mkdir -p $@
