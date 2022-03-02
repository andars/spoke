VERILATOR ?= verilator
IVERILOG ?= iverilog
GTKWAVE ?= gtkwave

.PHONY: lint sim waves

lint:
	$(VERILATOR) --lint-only --top-module uart uart.v

sim: lint
	$(IVERILOG) tb_uart.sv uart.v && ./a.out

waves: sim
	$(GTKWAVE) waves.vcd -S signals.tcl

_out/uart.bin: _out/uart.asc
	icepack $< $@

_out/uart_timing.txt: _out/uart.asc
	icetime -d up5k -c 12 -mtr $@ $<

_out/uart.asc: _out/uart.json pins.pcf
	nextpnr-ice40 -ql _out/uart.nplog --up5k --package sg48 --freq 12 --asc $@ --pcf pins.pcf --pcf-allow-unconstrained --json $<

_out/uart.json: uart.v | lint
	yosys -ql _out/uart.yslog -p 'synth_ice40 -top uart -json $@' uart.v
