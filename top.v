`default_nettype none

module top(
    input clock,
    input serial_rx,
    output [7:0] rx_byte,
    output serial_tx
);

wire reset;

wire [7:0] tx_byte;

wire rx_valid;
reg rx_ready;

reg tx_valid;
wire tx_ready;

uart uart0(
    .clock(clock),
    .reset(reset),
    .serial_rx(serial_rx),
    .rx_ready(rx_ready),
    .rx_valid(rx_valid),
    .rx_byte(rx_byte),
    .serial_tx(serial_tx),
    .tx_byte(tx_byte),
    .tx_valid(tx_valid),
    .tx_ready(tx_ready)
);

// Reset generator
reg [3:0] reset_counter = 0;
assign reset = (reset_counter < 4'hf);
always @(posedge clock) begin
    if (reset) begin
        reset_counter <= reset_counter + 1;
    end else begin
        reset_counter <= reset_counter;
    end
end

endmodule
