module uart_rx #(
    parameter CLOCK_FREQ = 50000000, // 50 MHz clock
    parameter BAUD_RATE  = 9600
)(
    input  logic clk,
    input  logic rst_n,
    input  logic rx,                // UART RX pin
    output logic [7:0] data_out,    // Received byte
    output logic data_ready         // 1-cycle pulse when data_out is valid
);
    localparam integer CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

    typedef enum logic [2:0] {
        IDLE, START, DATA, STOP, CLEANUP
    } state_t;

    state_t state = IDLE;
    logic [12:0] clk_count = 0;   // Count cycles for bit timing
    logic [2:0] bit_index = 0;    // Index for bit position (0 to 7)
    logic [7:0] rx_shift = 0;     // Shift register to collect data

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            clk_count  <= 0;
            bit_index  <= 0;
            rx_shift   <= 0;
            data_ready <= 0;
        end else begin
            case (state)
                IDLE: begin
                    data_ready <= 0;
                    if (!rx) begin // Start bit detected
                        clk_count <= 0;
                        state <= START;
                    end
                end
                START: begin
                    if (clk_count == CLKS_PER_BIT/2) begin
                        clk_count <= 0;
                        state <= DATA;
                        bit_index <= 0;
                    end else
                        clk_count <= clk_count + 1;
                end
                DATA: begin
                    if (clk_count < CLKS_PER_BIT) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_shift[bit_index] <= rx;
                        if (bit_index == 7)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                    end
                end
                STOP: begin
                    if (clk_count < CLKS_PER_BIT)
                        clk_count <= clk_count + 1;
                    else begin
                        state <= CLEANUP;
                        clk_count <= 0;
                        data_out <= rx_shift;
                        data_ready <= 1; // pulse
                    end
                end
                CLEANUP: begin
                    state <= IDLE;
                    data_ready <= 0;
                end
            endcase
        end
    end
endmodule
