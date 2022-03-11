`default_nettype none

module uart_wb_master(
    input clock,
    input reset,
    input serial_rx,
    output serial_tx,
    input [31:0] data_in,
    output [31:0] data_out,
    input ack_in,
    output [31:0] addr_out,
    output reg cyc_out,
    output reg strobe_out,
    output reg we_out
);

reg [2:0] state;
reg [2:0] count;

reg rx_ready;
wire rx_valid;
wire [7:0] rx_byte;

wire tx_ready;
reg tx_valid;
reg [7:0] tx_byte;

uart uart0(
    .clock(clock),
    .reset(reset),
    .serial_rx(serial_rx),
    .rx_ready(rx_ready),
    .rx_valid(rx_valid),
    .rx_byte(rx_byte),
    .serial_tx(serial_tx),
    .tx_ready(tx_ready),
    .tx_valid(tx_valid),
    .tx_byte(tx_byte)
);

always @(posedge clock) begin
    if (reset) begin
        rx_ready <= 1;
    end
    else if (rx_ready && rx_valid) begin
        rx_ready <= 0;
    end
    else if (rx_byte_consumed) begin
        rx_ready <= 1;
    end
end

reg [2:0] p_state;
localparam P_IDLE = 3'h0;
localparam P_WRITE_ADDR = 3'h1;
localparam P_WRITE_DATA = 3'h2;
localparam P_SEND_WB_WRITE = 3'h3;
localparam P_ACK_WRITE = 3'h4;
localparam P_READ_ADDR = 3'h5;
localparam P_SEND_WB_READ = 3'h6;
localparam P_READ_RESPONSE = 3'h7;

reg [31:0] rq_addr;
reg [31:0] rq_addr_next;

reg [31:0] rq_data;
reg [31:0] rq_data_next;

reg [2:0] p_next;
reg rx_byte_consumed;
always @(*) begin
    p_next = p_state;
    word_count_next = word_count;
    rx_byte_consumed = 0;
    rq_addr_next = rq_addr;
    rq_data_next = rq_data;
    cyc_out = 0;
    strobe_out = 0;
    we_out = 0;
    tx_byte = 8'h0;
    tx_valid = 0;
    if (p_state == P_IDLE) begin
        if (!rx_ready) begin
            word_count_next = 0;
            rx_byte_consumed = 1;
            if (rx_byte[0]) begin
                p_next = P_WRITE_ADDR;
            end else begin
                p_next = P_READ_ADDR;
            end
        end
    end
    else if (p_state == P_WRITE_ADDR) begin
        if (!rx_ready) begin
            word_count_next = word_count + 1;
            rx_byte_consumed = 1;
            rq_addr_next = {rx_byte, rq_addr[31:8]};

            if (word_count == 3) begin
                p_next = P_WRITE_DATA;
                word_count_next = 0;
            end
        end
    end
    else if (p_state == P_WRITE_DATA) begin
        if (!rx_ready) begin
            word_count_next = word_count + 1;
            rx_byte_consumed = 1;
            rq_data_next = {rx_byte, rq_data[31:8]};

            if (word_count == 3) begin
                p_next = P_SEND_WB_WRITE;
                word_count_next = 0;
            end
        end
    end
    else if (p_state == P_SEND_WB_WRITE) begin
        cyc_out = 1;
        strobe_out = 1;
        we_out = 1;

        if (ack_in) begin
            p_next = P_ACK_WRITE;
        end
    end
    else if (p_state == P_ACK_WRITE) begin
        tx_valid = 1;
        tx_byte = 8'haa;
        if (tx_valid && tx_ready) begin
            p_next = P_IDLE;
        end
    end
    else if (p_state == P_READ_ADDR) begin
        if (!rx_ready) begin
            word_count_next = word_count + 1;
            rx_byte_consumed = 1;
            rq_addr_next = {rx_byte, rq_addr[31:8]};

            if (word_count == 3) begin
                p_next = P_SEND_WB_READ;
                word_count_next = 0;
            end
        end
    end
    else if (p_state == P_SEND_WB_READ) begin
        cyc_out = 1;
        strobe_out = 1;
        we_out = 0;

        if (ack_in) begin
            rq_data_next = data_in;
            p_next = P_READ_RESPONSE;
            word_count_next = 0;
        end
    end
    else if (p_state == P_READ_RESPONSE) begin
        tx_byte = rq_data[7:0];
        tx_valid = 1;
        if (tx_valid && tx_ready) begin
            word_count_next = word_count + 1;
            rq_data_next = {8'h0, rq_data[31:8]};

            if (word_count == 3) begin
                p_next = P_IDLE;
            end
        end
    end
end

reg [1:0] word_count;
reg [1:0] word_count_next;

always @(posedge clock) begin
    if (reset) begin
        p_state <= P_IDLE;
        word_count <= 0;
        rq_addr <= 0;
        rq_data <= 0;
    end
    else begin
        p_state <= p_next;
        word_count <= word_count_next;
        rq_addr <= rq_addr_next;
        rq_data <= rq_data_next;
    end
end

assign addr_out = rq_addr;
assign data_out = rq_data;

endmodule
