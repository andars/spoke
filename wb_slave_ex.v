`default_nettype none

module wb_slave_ex(
    input clock,
    input reset,
    input [31:0] data_in,
    output [31:0] data_out,
    output ack_out,
    input [31:0] addr_in,
    input cyc_in,
    input strobe_in,
    input we_in
);

reg [7:0] ack;

always @(posedge clock) begin
    if (reset) begin
        ack <= 0;
    end else begin
        ack <= {cyc_in && strobe_in, ack[7:1]};
    end
end
assign ack_out = cyc_in && strobe_in && ack[0];

reg [31:0] registers [1:0];

integer i;
always @(posedge clock) begin
    if (reset) begin
        for (i = 0; i < 2; i++) begin
            registers[i] <= 0;
        end
    end
    else begin
        if (cyc_in && strobe_in && we_in) begin
            registers[addr_in[0]] <= data_in;
        end
    end
end

assign data_out = registers[addr_in[0]];

endmodule

