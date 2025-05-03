module uartRX #(
    parameter CLOCK_FREQ = 100000000,  // FPGA clock frequency for Basys 3: 100 MHz
    parameter BAUD_RATE  = 9600        // Desired UART baud rate (bits per second)
)(
    input  logic       clk,           // System clock input
    input  logic       rst,           // Active-high synchronous reset
    output logic [7:0] data_out,      // 8-bit parallel data to be received serially
    input  logic       rx,            // UART RX input line from transmitter
    output logic       data_ready     // Pulses high one cycle when a full byte is received
);

    localparam integer CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;    // Calculate the number of system clock cycles per bit duration

  typedef enum logic [2:0] {IDLE, START, DATA, STOP, CLEANUP} state_t; // Define FSM states for UART receiving process
    state_t state = IDLE;              // Initialize FSM in IDLE

    logic [7:0] rx_buffer = 0;         // Internal Register, temporarily holds received bits
    integer bit_index = 0;             // Internal Register, tracks which data bit (0–7) we’re sampling
    integer clk_count = 0;             // Internal Register, counts clock cycles to time each UART bit (up to CLKS_PER_BIT)

    logic [7:0] data_reg = 0;          // Internal OUTPUT Register, holds the completed byte
    logic       ready_reg = 0;         // Internal OUTPUT Register, pulse for data_ready

    assign data_out  = data_reg;       // Continuously drive the 8-bit output port with the value in data_reg
    assign data_ready = ready_reg;     // Continuously drive the 1-bit output port with the value in ready_reg

    always_ff @(posedge clk or posedge rst) begin
         if (rst) begin              // Reset everything to 0s and state to IDLE
            state       <= IDLE;
            clk_count   <= 0;        // Counts the ticks for a bit period, start counting at 0
            bit_index   <= 0;        // Indicates what bit of the data we are recieving we start with LSB
            rx_buffer   <= 0;        // Temporairly stores the data received, clear it
            data_reg    <= 0;        // Holds a fully assembled byte once all 8-bits have be recieved
            ready_reg   <= 0;        // Flag to indicate that a new byte is available in data_reg
        end else begin
            case (state)
                IDLE: begin                      // Waiting for start bit
                    ready_reg <= 0;              // Clear data_ready flag
                    clk_count <= 0;              // Reset clock counter
                    bit_index <= 0;              // Reset bit index
                    if (rx == 0) begin           // Detect start bit (logic 0), the falling edge
                        state <= START;          // Move to START to confirm UART frame
                    end
                end

                START: begin                                     // Verifying start bit
                  if (clk_count < (CLKS_PER_BIT/2) - 1) begin    // Wait half a bit period, then sample to confirm it's still low
                        clk_count <= clk_count + 1;              // Count clock cycles for full bit duration
                    end else begin                // If the rx is low we have detected falling edge for UART protocol
                        clk_count <= 0;           // To prepare for data sampling reset tick counter, counts up to a full bit period!
                        if (rx == 0)              // Confirm valid start bit so we can move to the DATA state for receiving
                            state <= DATA;        // Next up recieving data!
                        else
                            state <= IDLE;        // False start, go back to IDLE
                    end
                end

                DATA: begin                                     // Receiving 8 data bits
                    if (clk_count < CLKS_PER_BIT - 1) begin     // Wait full bit period, then sample one data bit
                        clk_count <= clk_count + 1;             // Continue timing current bit period
                    end else begin                           // This line is executed when a full bit period has elasped
                        clk_count <= 0;                         // Reset tick counter for next bit, there are 8 bits to manage
                        rx_buffer[bit_index] <= rx;             // Sample rx at the end of each bit-period, LSB first!
                        if (bit_index < 7) begin                // Check to see if we have sampled all 8-bits or not
                            bit_index <= bit_index + 1;         // Move to next bit if we haven't finished yet
                        end else begin                       // This line executes if we have recieved all 8-bits
                            bit_index <= 0;                     // All 8 bits done, reset the index for future processing
                            state <= STOP;                      // Proceed to stop bit state
                        end
                    end
                end

                STOP: begin                                  // Receiving stop bit, flag is set in clean when stop bit is validated!
                    if (clk_count < CLKS_PER_BIT - 1) begin  // Wait full bit period for stop bit
                        clk_count <= clk_count + 1;          // Increment tick counter since we are still waiting
                    end else begin
                        clk_count <= 0;                      // We have waited one bit period and need to reset tick counter
                        state <= CLEANUP;                    // Frame complete, transition to cleanup state for setting flag
                    end
                end

                CLEANUP: begin                      // Final housekeeping before next frame
                    data_reg  <= rx_buffer;         // Transfer assembled byte to output
                    ready_reg <= 1;                 // Pulse data_ready, we have a full data_reg (8-bits)
                    state <= IDLE;                  // Go back to IDLE for next frame
                end
            endcase
        end
    end
endmodule
