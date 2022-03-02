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
