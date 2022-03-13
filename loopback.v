`default_nettype none

module loopback(
    input clock,
    input serial_rx,
    output [7:0] rx_byte,
    output serial_tx
);

wire reset;

reg [7:0] tx_byte;

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

always @(posedge clock) begin
    if (reset) begin
        tx_valid <= 0;
        rx_ready <= 1;
    end
    else if (rx_ready && rx_valid) begin
        rx_ready <= 0;
        // loopback
        tx_byte <= rx_byte;
        tx_valid <= 1;
    end
    else if (tx_ready && tx_valid) begin
        tx_valid <= 0;
        rx_ready <= 1;
    end
end

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

`ifdef COCOTB_SIM
initial begin
    $dumpfile ("loopback.vcd");
    $dumpvars;
    #1;
end
`endif

endmodule
