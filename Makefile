VERILATOR ?= verilator

.PHONY: lint

lint:
	$(VERILATOR) --lint-only --top-module uart uart.v
