VERILATOR ?= verilator
IVERILOG ?= iverilog
GTKWAVE ?= gtkwave

.PHONY: lint sim waves sim-top waves-top

SOURCES = uart.v top.v
TOP = top

lint:
	$(VERILATOR) --lint-only --top-module $(TOP) $(SOURCES)

sim: lint
	$(IVERILOG) -DFAKE_FREQ tb_uart.sv $(SOURCES) && ./a.out

waves: sim
	$(GTKWAVE) waves.vcd -S signals.tcl

sim-top: lint
	$(IVERILOG) -DFAKE_FREQ tb_top.sv $(SOURCES) && ./a.out

waves-top: sim-top
	$(GTKWAVE) waves-top.vcd -S signals-top.tcl

WB_SOURCES = uart.v uart_wb_master.v wb_top.v wb_slave_ex.v

lint-wb:
	$(VERILATOR) --lint-only --top-module wb_top $(WB_SOURCES)

sim-wb: lint-wb
	$(IVERILOG) -g2005-sv -DFAKE_FREQ -s tb_wb_top tb_wb_top.sv $(WB_SOURCES) && ./a.out

waves-wb: sim-wb
	$(GTKWAVE) waves-wb-top.vcd -S signals-wb-top.tcl

_out/uart.bin: _out/uart.asc
	icepack $< $@

_out/uart_timing.txt: _out/uart.asc
	icetime -d up5k -c 12 -mtr $@ $<

_out/uart.asc: _out/uart.json pins.pcf
	nextpnr-ice40 -ql _out/uart.nplog --up5k --package sg48 --freq 12 --asc $@ --pcf pins.pcf --pcf-allow-unconstrained --json $<

_out/uart.json: $(SOURCES) | lint
	yosys -ql _out/uart.yslog -p 'synth_ice40 -top $(TOP) -json $@' $(SOURCES)
