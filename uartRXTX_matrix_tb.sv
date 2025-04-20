`timescale 1ns/1ps

module uart_matrix_tb;

    // UART & Matrix Parameters
    parameter CLOCK_FREQ = 50000000;
    parameter BAUD_RATE  = 9600;
    parameter CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

    parameter M = 2, N = 2, P = 2;

    // Clock and Reset
    logic clk = 0, rst_n = 0;
    always #10 clk = ~clk; // 50MHz Clock

    // UART Wires
    logic uart_rx_wire; // DUT receives from here
    logic uart_tx_wire; // DUT transmits to here

    logic done;
    logic [31:0] result_matrix [0:3][0:3];

    // Instantiate DUT
    matrix_loader #(
        .MAX_M(4), .MAX_N(4), .MAX_P(4),
        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx(uart_rx_wire),
        .uart_tx(uart_tx_wire),
        .done(done),
        .result(result_matrix)
    );

    assign uart_rx_wire = rx_line;

    logic rx_line = 1; // default idle state

    // === Byte transmission task ===
    task send_byte(input byte data);
        integer b;
        begin
            rx_line <= 0; // Start bit
            #(CLKS_PER_BIT);
            for (b = 0; b < 8; b++) begin
                rx_line <= data[b]; // LSB first
                #(CLKS_PER_BIT);
            end
            rx_line <= 1; // Stop bit
            #(CLKS_PER_BIT);
        end
    endtask

    // === Word transmission task ===
    task send_word(input logic [31:0] word);
        begin
            send_byte(word[31:24]);
            send_byte(word[23:16]);
            send_byte(word[15:8]);
            send_byte(word[7:0]);
        end
    endtask

    // === Test Procedure ===
    initial begin
        rx_line = 1;
        rst_n = 0;
        #200 rst_n = 1;

        // Send M, N, P
        send_word(M); send_word(N); send_word(P);

        // Send matrix A (row-major)
        send_word(32'd1); send_word(32'd2);
        send_word(32'd3); send_word(32'd4);

        // Send matrix B
        send_word(32'd5); send_word(32'd6);
        send_word(32'd7); send_word(32'd8);

        // Wait for multiplication to complete
        wait(done);
        $display("\nReceiving Result Matrix via UART TX:\n");

        // Start UART sniffer to capture output bytes
        receive_result_matrix();

        $finish;
    end

    // === UART Sniffer to Receive and Print Matrix C ===
    task receive_result_matrix;
        integer i, j, b;
        reg [7:0] byte;
        reg [31:0] word;
        begin
            for (i = 0; i < M; i++) begin
                for (j = 0; j < P; j++) begin
                    word = 0;
                    for (b = 0; b < 4; b++) begin
                        byte = get_uart_byte(); // Grab byte from UART TX
                        word = {word[23:0], byte}; // Assemble 32-bit word (MSB first)
                    end
                    $display("C[%0d][%0d] = %0d", i, j, word);
                end
            end
        end
    endtask

    // === UART Byte Capture (start bit + 8 data bits + stop) ===
    function [7:0] get_uart_byte;
        integer b;
        begin
            // Wait for start bit (low)
            while (uart_tx_wire === 1) @(posedge clk);
            #(CLKS_PER_BIT / 2); // Wait to middle of start bit

            // Sample 8 data bits (LSB first)
            for (b = 0; b < 8; b++) begin
                #(CLKS_PER_BIT);
                get_uart_byte[b] = uart_tx_wire;
            end

            #(CLKS_PER_BIT); // Stop bit wait
        end
    endfunction
endmodule
