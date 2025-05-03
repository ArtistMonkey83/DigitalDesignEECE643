module uartTX #(
    parameter CLOCK_FREQ = 100000000, // FPGA clock frequency for Basys 3: 100 MHz
    parameter BAUD_RATE  = 9600       // Desired UART baud rate (bits per second)
)(
    input logic clk,                  // System clock input
    input logic rst,                  // Active-high synchronous reset
    input logic [7:0] data_in,        // 8-bit parallel data to be transmitted serially
    input logic transmit,             // Signal to begin transmission of data_in
    output logic tx,                  // UART TX output line to the receiver
    output logic tx_busy              // High when transmitter is busy sending data
);

    localparam integer CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;     // Calculate the number of system clock cycles per bit duration

    typedef enum {IDLE, START_BIT, DATA_BITS, STOP_BIT, CLEANUP} state_t;    // Define FSM states for UART transmission process
    state_t state = IDLE;             // Initialize FSM to IDLE state

    logic [7:0] tx_buffer;            // Internal Register, holds the byte being transmitted (shifts right every bit)
    integer bit_index = 0;            // Internal Register, counts number of bits transmitted (0 to 7)
    integer clk_count = 0;            // Internal Register, counts clock cycles to time each UART bit (up to CLKS_PER_BIT)

    always_ff @(posedge clk or posedge rst) begin    
        if (rst) begin                               // Reset all control signals and return to IDLE state
            state <= IDLE;                           // We stay in IDLE till start_tx ==1
            tx <= 1;                                 // Default UART idle line state is logic HIGH
            tx_busy <= 0;                            // Transmission not in progress
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1;                         // Keep line high during idle, UART begins with falling edge 
                    if (transmit) begin              // Are we transmitting?...
                        tx_buffer <= data_in;        // Yes! then load byte into shift register
                        tx_busy <= 1;                // Set busy flag, we will transmit a total of 8-bits
                        clk_count <= 0;              // Reset clock counter for start bit timing
                        state <= START_BIT;          // Move to start bit state
                    end
                end

                START_BIT: begin
                    tx <= 0;                                 // Transmit start bit, falling edge detection triggers UART protocol
                    if (clk_count < CLKS_PER_BIT - 1) begin  // We need to remain in this state for a full bit period to transmit data
                        clk_count <= clk_count + 1;          // Count clock cycles for full bit duration
                    end else begin
                        clk_count <= 0;                      // Reset counter after one bit period, we have transmitted the whole bit
                        state <= DATA_BITS;                  // Proceed to transmit data bits, in this case 8-bits are transmitted
                    end
                end

                DATA_BITS: begin
                    tx <= tx_buffer[0];                      // Transmit LSB of shift register
                    if (clk_count < CLKS_PER_BIT - 1) begin  // We need to remain in this state for a full bit period to transmit data
                        clk_count <= clk_count + 1;          // Continue timing current bit period
                    end else begin                        // This line is executed when a full bit period has elasped
                        tx_buffer <= tx_buffer >> 1;         // Shift right to bring next bit to LSB for transmitting
                        clk_count <= 0;                      // Reset tick counter for next bit
                        if (bit_index < 7) begin          // Check to see what bit out of the 8 we are transmitting
                            bit_index <= bit_index + 1;      // Increment counter to track which bit is being transmitted
                        end else begin                    // We have sent all 8 bits
                            bit_index <= 0;                  // Reset the counter and prepare to receive stop bit
                            state <= STOP_BIT;               // Move to stop bit state
                        end
                    end
                end

                STOP_BIT: begin
                    tx <= 1;                                 // Transmit stop bit (logic high) signalling frame completed!
                    if (clk_count < CLKS_PER_BIT - 1) begin  // We need to remain in this state for a full bit period to transmit data
                        clk_count <= clk_count + 1;          // Increment tick counter till one bit period has elaspsed
                    end else begin                           // After we have transmitted the stop bit correctly...
                        clk_count <= 0;                      // Reset counter for next transmission to be timed correctly
                        state <= CLEANUP;                    // Enter cleanup before finishing
                    end
                end

                CLEANUP: begin
                    tx_busy <= 0;                            // Clear busy flag, ready for new transmission
                    state <= IDLE;                           // Return to IDLE state
                end
            endcase
        end
    end
endmodule
