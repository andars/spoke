VERILATOR ?= verilator
IVERILOG ?= iverilog
GTKWAVE ?= gtkwave

.PHONY: lint sim waves sim-loopback waves-loopback

all: _out/loopback.bin _out/wb_top.bin

SOURCES = uart.v loopback.v
TOP = loopback

lint:
	$(VERILATOR) --lint-only --top-module $(TOP) $(SOURCES)

sim: lint
	$(IVERILOG) -DFAKE_FREQ -s tb_uart tb_uart.sv $(SOURCES) && ./a.out

waves: sim
	$(GTKWAVE) waves.vcd -S signals.tcl

sim-loopback: lint
	$(IVERILOG) -DFAKE_FREQ tb_loopback.sv $(SOURCES) && ./a.out

waves-loopback: sim-loopback
	$(GTKWAVE) waves-loopback.vcd -S signals-loopback.tcl

WB_SOURCES = uart.v uart_wb_master.v wb_top.v wb_slave_ex.v

lint-wb:
	$(VERILATOR) --lint-only --top-module wb_top $(WB_SOURCES)

sim-wb: lint-wb
	$(IVERILOG) -g2005-sv -DFAKE_FREQ -s tb_wb_top tb_wb_top.sv $(WB_SOURCES) && ./a.out

waves-wb: sim-wb
	$(GTKWAVE) waves-wb-top.vcd -S signals-wb-top.tcl

define ICE40_RULES
_out/$(strip $1).bin: _out/$(strip $1).asc _out/$(strip $1)_timing.txt
	icepack $$< $$@

_out/$(strip $1)_timing.txt: _out/$(strip $1).asc
	icetime -d up5k -c 12 -mtr $$@ $$<

_out/$(strip $1).asc: _out/$(strip $1).json $(strip $1)-pins.pcf
	nextpnr-ice40 -ql _out/$(strip $1).nplog --up5k --package sg48 --freq 12 --asc $$@ --pcf $(strip $1)-pins.pcf --pcf-allow-unconstrained --json $$<

_out/$(strip $1).json: $2 | $3
	yosys -ql _out/$(strip $1).yslog -p 'synth_ice40 -top $(strip $1) -json $$@' $2
endef

$(eval $(call ICE40_RULES, loopback, $(SOURCES), lint))
$(eval $(call ICE40_RULES, wb_top, $(WB_SOURCES), lint-wb))
