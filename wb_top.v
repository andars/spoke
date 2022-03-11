`default_nettype none

module wb_top(
    input clock,
    input serial_rx,
    output serial_tx
);

wire reset;

wire [31:0] data_in;
wire [31:0] data_out;
wire ack;
wire [31:0] addr;
wire cyc;
wire strobe;
wire we;

uart_wb_master wb_master(
    .clock(clock),
    .reset(reset),
    .serial_rx(serial_rx),
    .serial_tx(serial_tx),
    .data_in(data_in),
    .data_out(data_out),
    .ack_in(ack),
    .addr_out(addr),
    .cyc_out(cyc),
    .strobe_out(strobe),
    .we_out(we)
);

wb_slave_ex wb_regs(
    .clock(clock),
    .reset(reset),
    .data_in(data_out),
    .data_out(data_in),
    .ack_out(ack),
    .addr_in(addr),
    .cyc_in(cyc),
    .strobe_in(strobe),
    .we_in(we)
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
