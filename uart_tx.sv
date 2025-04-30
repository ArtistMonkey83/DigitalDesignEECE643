module uartTX #(
    parameter CLOCK_FREQ = 100000000, // Basys 3 default clock 100 MHz
    parameter BAUD_RATE = 9600        // Common baud rate for UART
)(
    input logic clk,                // System clock
    input logic rst,                // System reset
    input logic [7:0] data_in,      // Input data to transmit
    input logic transmit,           // Control signal to start transmission
    output logic tx,                // UART transmit line
    output logic tx_busy            // Signal to indicate transmission in progress
);

    // Calculate number of clock cycles per bit period
    localparam integer BIT_PERIOD = CLOCK_FREQ / BAUD_RATE;

    // State definitions for FSM
    typedef enum {IDLE, START_BIT, DATA_BITS, STOP_BIT, CLEANUP} state_t;
    state_t state = IDLE;

    // Registers for data transmission and counters
    logic [7:0] shift_reg;
    integer bit_counter = 0;
    integer tick_counter = 0;

    // FSM implementation
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx <= 1; // UART line is idle high
            tx_busy <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (transmit) begin
                        shift_reg <= data_in; // Load data to shift register
                        tx_busy <= 1;
                        tick_counter <= 0;
                        state <= START_BIT;
                    end
                end
                START_BIT: begin
                    tx <= 0; // Start bit is low
                    if (tick_counter < BIT_PERIOD - 1) begin
                        tick_counter <= tick_counter + 1;
                    end else begin
                        tick_counter <= 0;
                        state <= DATA_BITS;
                    end
                end
                DATA_BITS: begin
                    tx <= shift_reg[0]; // Transmit LSB first
                    if (tick_counter < BIT_PERIOD - 1) begin
                        tick_counter <= tick_counter + 1;
                    end else begin
                        shift_reg <= shift_reg >> 1; // Shift to the next bit
                        tick_counter <= 0;
                        if (bit_counter < 7) begin
                            bit_counter <= bit_counter + 1;
                        end else begin
                            bit_counter <= 0;
                            state <= STOP_BIT;
                        end
                    end
                end
                STOP_BIT: begin
                    tx <= 1; // Stop bit is high
                    if (tick_counter < BIT_PERIOD - 1) begin
                        tick_counter <= tick_counter + 1;
                    end else begin
                        tick_counter <= 0;
                        state <= CLEANUP;
                    end
                end
                CLEANUP: begin
                    tx_busy <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule

