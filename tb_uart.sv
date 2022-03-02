`timescale 1ns/1ns
`default_nettype none

module tb_uart();

reg clock;
wire sync;
wire [3:0] data;

wire serial_rx;
wire [7:0] rx_byte;
wire serial_tx;
wire [7:0] tx_byte;

uart dut(
    .clock(clock),
    .serial_rx(serial_rx),
    .rx_byte(rx_byte),
    .serial_tx(serial_tx),
    .tx_byte(tx_byte)
);

initial begin
    clock = 0;
end

always begin
    #10 clock = ~clock;
end

integer i;
initial begin
    $dumpfile("waves.vcd");
    $dumpvars;

    repeat(9000) @(posedge clock);

    $finish;
end

endmodule
