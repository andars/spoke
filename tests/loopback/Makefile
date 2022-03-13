SELF:=$(lastword $(MAKEFILE_LIST))
ROOT=$(realpath $(dir $(SELF))/../..)

TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(ROOT)/uart.v $(ROOT)/loopback.v

TOPLEVEL = loopback
MODULE = tests
export PYTHONPATH:=$(dir $(SELF)):$(PYTHONPATH)

include $(shell cocotb-config --makefiles)/Makefile.sim
