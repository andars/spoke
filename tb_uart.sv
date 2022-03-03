`timescale 1ns/1ns
`default_nettype none

module tb_uart();

reg clock;
wire sync;

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

reg [7:0] rx_data;

integer i;
initial begin
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

initial begin
    $dumpfile("waves.vcd");
    $dumpvars;

    repeat(9000) @(posedge clock);

    $finish;
end

endmodule
