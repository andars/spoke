`default_nettype none

module top(
    input clock,
    input serial_rx,
    output [7:0] rx_byte,
    output serial_tx
);

wire [7:0] tx_byte;

wire rx_valid;
reg rx_ready;

reg tx_valid;
wire tx_ready;

uart uart0(
    .clock(clock),
    .serial_rx(serial_rx),
    .rx_ready(rx_ready),
    .rx_valid(rx_valid),
    .rx_byte(rx_byte),
    .serial_tx(serial_tx),
    .tx_byte(tx_byte),
    .tx_valid(tx_valid),
    .tx_ready(tx_ready)
);

endmodule
