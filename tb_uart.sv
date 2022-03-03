`timescale 1ns/1ns
`default_nettype none

module tb_uart();

reg clock;
wire sync;
wire [3:0] data;

reg serial_rx;
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

initial begin
    serial_rx = 1;
    // start bit
    #1000 serial_rx = 0;

    // data bits
    #200 serial_rx = 1;
    #200 serial_rx = 0;
    #200 serial_rx = 1;
    #200 serial_rx = 0;
    #200 serial_rx = 1;
    #200 serial_rx = 1;
    #200 serial_rx = 0;
    #200 serial_rx = 0;

    // stop bit & idle
    #200 serial_rx = 1;
end

integer i;
initial begin
    $dumpfile("waves.vcd");
    $dumpvars;

    repeat(9000) @(posedge clock);

    $finish;
end

endmodule
