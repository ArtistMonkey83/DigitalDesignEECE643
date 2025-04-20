`timescale 1ns/1ps

module tb_uart_matrix;

    // === UART config ===
    parameter CLOCK_FREQ = 50000000; // 50 MHz
    parameter BAUD_RATE  = 9600;
    parameter CLKS_PER_BIT = CLOCK_FREQ / BAUD_RATE;

    // === Matrix dimensions for testing ===
    parameter M = 2, N = 2, P = 2;

    // === Clock and reset ===
    logic clk = 0, rst_n = 0;

    always #10 clk = ~clk; // 50MHz clock

    // === DUT wiring ===
    logic uart_rx_wire;
    logic uart_tx_wire; // We’ll capture this
    logic done;
    logic [31:0] result_matrix [0:3][0:3];

    // === Instantiate DUT ===
    matrix_loader #(
        .MAX_M(4), .MAX_N(4), .MAX_P(4)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx(uart_rx_wire),
        .done(done),
        .result(result_matrix)
    );

    assign uart_tx_wire = 1'bz; // Placeholder until we add TX logic

    // === Byte transmission task ===
    task send_byte(input byte data);
        integer bit_idx;
        begin
            uart_rx_wire <= 0; // Start bit
            #(CLKS_PER_BIT * 1ns);
            for (bit_idx = 0; bit_idx < 8; bit_idx++) begin
                uart_rx_wire <= data[bit_idx]; // Send LSB first
                #(CLKS_PER_BIT * 1ns);
            end
            uart_rx_wire <= 1; // Stop bit
            #(CLKS_PER_BIT * 1ns);
        end
    endtask

    // === Word transmission task ===
    task send_word(input logic [31:0] word);
        begin
            send_byte(word[31:24]); // MSB first
            send_byte(word[23:16]);
            send_byte(word[15:8]);
            send_byte(word[7:0]);   // LSB last
        end
    endtask

    // === UART RX capture ===
    byte rx_byte;
    integer i, j;
    initial begin
        uart_rx_wire = 1'b1; // Idle state for UART line
        rst_n = 0;
        #200 rst_n = 1;

        // === Step 1: Send Dimensions M, N, P ===
        send_word(M); // 0x00000002
        send_word(N); // 0x00000002
        send_word(P); // 0x00000002

        // === Step 2: Send matrix A (M x N = 2 x 2) ===
        send_word(32'd1); // A[0][0]
        send_word(32'd2); // A[0][1]
        send_word(32'd3); // A[1][0]
        send_word(32'd4); // A[1][1]

        // === Step 3: Send matrix B (N x P = 2 x 2) ===
        send_word(32'd5);  // B[0][0]
        send_word(32'd6);  // B[0][1]
        send_word(32'd7);  // B[1][0]
        send_word(32'd8);  // B[1][1]

        // === Wait for computation to complete ===
        wait(done);
        $display("Matrix multiplication DONE.\n");

        // === Step 4: Print result matrix ===
        for (i = 0; i < M; i++) begin
            for (j = 0; j < P; j++) begin
                $display("C[%0d][%0d] = %0d", i, j, result_matrix[i][j]);
            end
        end

        $finish;
    end
endmodule
