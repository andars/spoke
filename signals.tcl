set signals [list]

lappend signals "clock"
lappend signals "tb_uart.dut.reset"
lappend signals "tb_uart.dut.cycle_counter"
lappend signals "tb_uart.dut.div_pulse"
lappend signals "serial_tx"
lappend signals "tx_byte"
lappend signals "tx_valid"
lappend signals "tx_ready"
lappend signals "tb_uart.dut.tx_shift"
lappend signals "tb_uart.dut.tx_state"
lappend signals "tb_uart.dut.tx_bit_counter"
lappend signals "serial_rx"
lappend signals "rx_byte"
lappend signals "rx_valid"
lappend signals "rx_ready"
lappend signals "tb_uart.dut.rx_state"
lappend signals "tb_uart.dut.rx_timer"
lappend signals "tb_uart.dut.rx_bit_counter"
lappend signals "tb_uart.dut.rx_sample_pulse"
lappend signals "tb_uart.dut.rx_shift"

set signal_count [ gtkwave::addSignalsFromList $signals ]

gtkwave::setBaselineMarker 110
gtkwave::setMarker 310
gtkwave::/View/Define_Time_Ruler_Marks
gtkwave::/View/Show_Grid
gtkwave::setBaselineMarker -1
gtkwave::setMarker -1
