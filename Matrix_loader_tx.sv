module matrix_loader #(
    parameter MAX_M = 4,
    parameter MAX_N = 4,
    parameter MAX_P = 4,
    parameter CLOCK_FREQ = 50000000,
    parameter BAUD_RATE  = 9600
)(
    input  logic clk,              // Main system clock
    input  logic rst_n,            // Active-low reset
    input  logic uart_rx,          // UART input pin
    output logic uart_tx,          // UART output pin (for sending result)
    output logic done,             // Goes high when computation is complete
    output logic [31:0] result [MAX_M][MAX_P] // Output matrix for verification
);

    // === UART RX signals ===
    logic [7:0] uart_byte;         // Received byte from UART
    logic uart_byte_valid;         // Valid pulse for uart_byte

    // === Instantiate UART RX ===
    uart_rx #(
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uart_rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx(uart_rx),
        .data_out(uart_byte),
        .data_ready(uart_byte_valid)
    );

    // === Buffer for assembling 32-bit word from UART bytes ===
    logic [31:0] word_buffer;
    logic [1:0] byte_index; // Tracks byte position (0 to 3)

    // === Matrix dimension registers ===
