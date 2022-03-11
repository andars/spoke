`timescale 1ns/1ns
`default_nettype none

module tb_wb_top();

reg clock;
reg serial_rx = 1;
wire serial_tx;

wb_top dut(
    .clock(clock),
    .serial_rx(serial_rx),
    .serial_tx(serial_tx)
);

initial begin
    clock = 0;
end

always begin
    #10 clock = ~clock;
end

task gen_byte(input reg [7:0] data);
    // start bit
    #200 serial_rx = 0;

    $display("generating byte 0x%x\n", data);
    // data bits
    #200 serial_rx = data[0];
    #200 serial_rx = data[1];
    #200 serial_rx = data[2];
    #200 serial_rx = data[3];
    #200 serial_rx = data[4];
    #200 serial_rx = data[5];
    #200 serial_rx = data[6];
    #200 serial_rx = data[7];

    // stop bit & idle
    #200 serial_rx = 1;
endtask

initial begin
    @(negedge dut.reset);

    // control (write)
    gen_byte(8'h01);

    // address (even)
    gen_byte(8'h88);
    gen_byte(8'haa);
    gen_byte(8'hbb);
    gen_byte(8'h77);

    // data
    gen_byte(8'h11);
    gen_byte(8'h22);
    gen_byte(8'h33);
    gen_byte(8'haa);

    // control (read)
    gen_byte(8'h00);

    // address (even)
    gen_byte(8'h88);
    gen_byte(8'haa);
    gen_byte(8'hbb);
    gen_byte(8'h77);

    // wait until the transmit of the read response is complete
    #15000;

    // control (read)
    gen_byte(8'h00);

    // address (odd)
    gen_byte(8'h89);
    gen_byte(8'hdd);
    gen_byte(8'hee);
    gen_byte(8'h99);
end

integer i;
initial begin
    $dumpfile("waves-wb-top.vcd");
    $dumpvars;
    for (i = 0; i < 2; i++) begin
        $dumpvars(0, dut.wb_regs.registers[i]);
    end


    repeat(5000) @(posedge clock);

    $finish;
end

endmodule
