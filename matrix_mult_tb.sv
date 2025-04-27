`timescale 1ns / 1ps
module matrix_mult_tb;
    parameter int N = 4;
    parameter int WIDTH = 16;
    parameter int PIPE_STAGES = 5;

    logic clk;
    logic [WIDTH-1:0] A[N][N];
    logic [WIDTH-1:0] B[N][N];
    logic [2*WIDTH-1:0] C[N][N];

    matrix_mult #(
        .N(N),
        .WIDTH(WIDTH),
        .PIPE_STAGES(PIPE_STAGES)
    ) uut (
        .clk(clk),
        .A(A),
        .B(B),
        .C(C)
    );

    // Clock generation for targeted 900 MHz
    always #0.555 clk = ~clk; // Setting up for 900 MHz frequency

    initial begin
        clk = 0;
        // Initialize matrices
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                A[i][j] = i + j;
                B[i][j] = (i == j) ? 1 : 0;  // Identity matrix
            end
        end

        #100;

        // Display results
        $display("Result matrix C:");
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                $write("%0d ", C[i][j]);
            end
            $display("");
        end

        $stop;
    end
endmodule
