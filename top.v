`default_nettype none

module top(
    input clock,
    input serial_rx,
    output [7:0] rx_byte,
    output serial_tx
);

wire [7:0] tx_byte;

uart uart0(
    .clock(clock),
    .serial_rx(serial_rx),
    .rx_byte(rx_byte),
    .serial_tx(serial_tx),
    .tx_byte(tx_byte)
);

endmodule
