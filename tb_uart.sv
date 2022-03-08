`timescale 1ns/1ns
`default_nettype none

module tb_uart();

reg clock;
reg reset;

wire sync;

reg serial_rx;
wire [7:0] rx_byte;
wire serial_tx;
reg [7:0] tx_byte;

wire rx_valid;
reg rx_ready;

reg tx_valid;
wire tx_ready;

uart dut(
    .clock(clock),
    .reset(reset),
    .serial_rx(serial_rx),
    .rx_byte(rx_byte),
    .rx_valid(rx_valid),
    .rx_ready(rx_ready),
    .serial_tx(serial_tx),
    .tx_byte(tx_byte),
    .tx_valid(tx_valid),
    .tx_ready(tx_ready)
);

initial begin
    clock = 0;
    rx_ready = 0;
    reset = 1;
end

always begin
    #10 clock = ~clock;
end

reg [7:0] rx_data;

integer i;

initial begin
    tx_valid = 0;

    // wait a while before deasserting reset
    #200;
    reset = 0;
    #500;

    for (i = 0; i < 5; i++) begin
        tx_byte = 8'h55 + i;

        tx_valid = 1;
        @(negedge tx_ready);
        tx_valid = 0;

        @(posedge tx_ready);
        #490;
    end
    serial_rx = 1;
    for (i = 0; i < 5; i++) begin
        rx_data = 8'hac + i;

        // start bit
        #1000 serial_rx = 0;

        // data bits
        #200 serial_rx = rx_data[0];
        #200 serial_rx = rx_data[1];
        #200 serial_rx = rx_data[2];
        #200 serial_rx = rx_data[3];
        #200 serial_rx = rx_data[4];
        #200 serial_rx = rx_data[5];
        #200 serial_rx = rx_data[6];
        #200 serial_rx = rx_data[7];

        // stop bit & idle
        #200 serial_rx = 1;
    end
end

always @(posedge rx_valid) begin
    #50 rx_ready = 1;
    @(posedge clock);
    #5 rx_ready = 0;
end

initial begin
    $dumpfile("waves.vcd");
    $dumpvars;

    repeat(9000) @(posedge clock);

    $finish;
end

endmodule
