set signals [list]

lappend signals "clock"
lappend signals "serial_tx"
lappend signals "tx_valid"
lappend signals "tx_ready"
lappend signals "serial_rx"
lappend signals "rx_valid"
lappend signals "rx_ready"
lappend signals "tx_byte"
lappend signals "tb_top.dut.uart0.tx_shift"

set signal_count [ gtkwave::addSignalsFromList $signals ]

gtkwave::setBaselineMarker 110
gtkwave::setMarker 310
gtkwave::/View/Define_Time_Ruler_Marks
gtkwave::/View/Show_Grid
gtkwave::setBaselineMarker -1
gtkwave::setMarker -1
