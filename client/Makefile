SELF:=$(lastword $(MAKEFILE_LIST))
OUT=$(realpath $(dir $(SELF))/..)/_out/client

CFLAGS += -Wall -Werror

SRC:=$(wildcard *.c)
OBJ:=$(SRC:%.c=$(OUT)/%.o)
DEP:=$(SRC:%.c=$(OUT)/%.d)

all: $(OUT)/spoke $(OUT)/loopback

$(OUT)/spoke: $(OUT)/spoke.o $(OUT)/serial.o

$(OUT)/loopback: $(OUT)/loopback.o $(OUT)/serial.o

$(OBJ): $(OUT)/%.o: %.c $(OUT)/%.d | $(OUT)
	$(CC) -MT $@ -MMD -MP -MF $(OUT)/$*.d -o $@ -c $(CFLAGS) $<

$(OUT):
	mkdir -p $@

$(DEP):
include $(wildcard $(DEPS))
