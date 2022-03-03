`default_nettype none

module uart(
    input clock,
    input serial_rx,
    output reg [7:0] rx_byte,
    output serial_tx,
    input [7:0] tx_byte
);

localparam CLOCK_HZ = 12_000_000;
localparam BAUD_HZ = 9_600;
`ifndef FAKE_FREQ
localparam CLOCK_DIV_MAX_ = CLOCK_HZ / BAUD_HZ;
`else
localparam CLOCK_DIV_MAX_ = 9;
`endif
localparam CLOCK_DIV_MAX = CLOCK_DIV_MAX_[19:0];

wire reset;

reg [19:0] cycle_counter;
reg div_pulse;

reg [7:0] tx_shift;
reg [7:0] rx_shift;

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

localparam TX_IDLE  = 3'h0;
localparam TX_START = 3'h1;
localparam TX_DATA  = 3'h2;
localparam TX_END   = 3'h3;

reg [2:0] tx_state;
reg [3:0] tx_bit_counter;

wire new_data;
wire [7:0] new_data_value;
assign new_data = 1;
assign new_data_value = 8'h41; // A

// TX state machine
always @(posedge clock) begin
    if (reset) begin
        tx_state <= 0;
        tx_bit_counter <= 0;
    end else if (div_pulse) begin
        if (tx_state == TX_IDLE) begin
            if (new_data) begin
                // there's new data to transmit, move to _START
                tx_state <= TX_START;
            end else begin
                // nothing doing, stay in _IDLE
                tx_state <= TX_IDLE;
            end
        end else if (tx_state == TX_START) begin
            // move to _DATA after transmitting the start bit
            tx_state <= TX_DATA;
            tx_bit_counter <= 7;
        end else if (tx_state == TX_DATA) begin
            tx_bit_counter <= tx_bit_counter - 1;
            if (tx_bit_counter == 0) begin
                // done with data, move to the stop bit
                tx_state <= TX_END;
            end else begin
                // continue shifting out the data byte
                tx_state <= TX_DATA;
            end
        end else if (tx_state == TX_END) begin
            // go to idle after one stop bit
            tx_state <= TX_IDLE;
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
            if (tx_state == TX_DATA) begin
                tx_shift <= {1'b0, tx_shift[7:1]};
            end if (tx_state == TX_START) begin
                tx_shift <= new_data_value;
            end
        end
    end
end

// TX output signal select
reg _serial_tx;
assign serial_tx = _serial_tx;

always @(*) begin
    _serial_tx = 1;
    if (tx_state == TX_IDLE) begin
        _serial_tx = 1;
    end else if (tx_state == TX_START) begin
        _serial_tx = 0;
    end else if (tx_state == TX_DATA) begin
        _serial_tx = tx_shift[0];
    end else if (tx_state == TX_END) begin
        _serial_tx = 1;
    end
end

localparam RX_IDLE = 3'h0;
localparam RX_START = 3'h1;
localparam RX_DATA = 3'h2;
localparam RX_END = 3'h3;
reg [2:0] rx_state;
reg [3:0] rx_bit_counter;

reg [19:0] rx_timer;
reg rx_sample_pulse;

// RX state machine
always @(posedge clock) begin
    if (reset) begin
        rx_state <= RX_IDLE;
        rx_timer <= 0;
        rx_bit_counter <= 0;
        rx_sample_pulse <= 0;
        rx_byte <= 0;
    end else begin
        rx_sample_pulse <= 0;

        if (rx_state == RX_IDLE) begin
            // TODO: add some synchronizers for serial_rx
            if (serial_rx == 0) begin
                // when serial_rx goes low, move to _START.
                // TODO: do some debouncing here
                rx_state <= RX_START;

                rx_timer <= CLOCK_DIV_MAX;
            end
        end else if (rx_state == RX_START) begin
            if (rx_timer == 0) begin
                // after one bit period, move to _DATA;
                rx_state <= RX_DATA;
                rx_bit_counter <= 7;

                // and wait half a bit period to sample in the center of each
                // data bit
                rx_timer <= CLOCK_DIV_MAX / 2;
            end else begin
                rx_timer <= rx_timer - 1;
            end
        end else if (rx_state == RX_DATA) begin
            if (rx_timer == 0) begin
                rx_sample_pulse <= 1;
                rx_bit_counter <= rx_bit_counter - 1;
                rx_timer <= CLOCK_DIV_MAX;
                if (rx_bit_counter == 0) begin
                    rx_state <= RX_END;
                end
            end else begin
                rx_sample_pulse <= 0;
                rx_timer <= rx_timer - 1;
            end
        end else if (rx_state == RX_END) begin
            if (rx_timer == 0) begin
                rx_state <= RX_IDLE;
                rx_byte <= rx_shift;
            end else begin
                rx_timer <= rx_timer - 1;
            end
        end
    end
end

// RX shift register
always @(posedge clock) begin
    if (reset) begin
        rx_shift <= 0;
    end
    else begin
        if (rx_sample_pulse) begin
            rx_shift <= {serial_rx, rx_shift[7:1]};
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
