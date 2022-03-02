`default_nettype none

module uart(
    input clock,
    input serial_rx,
    output reg [7:0] rx_byte,
    output serial_tx,
    input [7:0] tx_byte
);

localparam CLOCK_HZ = 1_000_000;
localparam BAUD_HZ = 9_600;
localparam CLOCK_DIV_MAX = 9;

wire reset;

reg [19:0] cycle_counter;
reg div_pulse;

reg [7:0] tx_shift;
reg [7:0] rx_shift;

assign serial_tx = tx_shift[0];

// Clock divider
always @(posedge clock) begin
    if (reset) begin
        cycle_counter <= 0;
        div_pulse <= 0;
    end else begin
        if (cycle_counter == CLOCK_DIV_MAX) begin
            cycle_counter <= 0;
            div_pulse <= 1;
        end else begin
            cycle_counter <= cycle_counter + 1;
            div_pulse <= 0;
        end
    end
end

// TX shift register
always @(posedge clock) begin
    if (reset) begin
        tx_shift <= 8'haa;
    end
    else begin
        if (div_pulse) begin
            tx_shift <= {1'b0, tx_shift[7:1]};
        end
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

endmodule
