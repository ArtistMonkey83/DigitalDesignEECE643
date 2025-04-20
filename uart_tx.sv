module uart_tx #(
    parameter CLOCK_FREQ = 50000000, // 50 MHz input clock
    parameter BAUD_RATE  = 9600
)(
    input  logic clk,             // System clock
    input  logic rst_n,           // Active-low reset
    input  logic start_tx,        // Trigger to begin transmitting data
    input  logic [7:0] data_in,   // 8-bit data to transmit
    output logic tx,              // UART transmit line
    output logic busy             // High when transmission is ongoing
);

    // === Calculated constant ===
    localparam integer CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

    // === Internal signals ===
    typedef enum logic [2:0] {
        IDLE,
        START_BIT,
        DATA_BITS,
        STOP_BIT,
        CLEANUP
    } state_t;

    state_t state = IDLE;         // Current FSM state
    logic [12:0] clk_count = 0;   // Counts system clocks per bit
    logic [2:0] bit_index = 0;    // Index of bit being transmitted
    logic [7:0] tx_buffer = 0;    // Buffer holding data being sent

    // === Main FSM for UART TX ===
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            clk_count <= 0;
            bit_index <= 0;
            tx <= 1;              // Idle state for UART TX is high
            busy <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1;
                    busy <= 0;
                    if (start_tx) begin
                        tx_buffer <= data_in;  // Capture input byte
                        busy <= 1;
                        state <= START_BIT;
                    end
                end
                START_BIT: begin
                    tx <= 0; // Send start bit (low)
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        state <= DATA_BITS;
                        bit_index <= 0;
                    end
                end
                DATA_BITS: begin
                    tx <= tx_buffer[bit_index]; // Send LSB first
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        if (bit_index == 7)
                            state <= STOP_BIT;
                        else
                            bit_index <= bit_index + 1;
                    end
                end
                STOP_BIT: begin
                    tx <= 1; // Stop bit (high)
                    if (clk_count < CLKS_PER_BIT - 1)
                        clk_count <= clk_count + 1;
                    else begin
                        clk_count <= 0;
                        state <= CLEANUP;
                    end
                end
                CLEANUP: begin
                    state <= IDLE; // Ready for next byte
                end
            endcase
        end
    end
endmodule
