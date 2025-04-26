`timescale 1ns / 1ps

module multiply #(
    parameter int WIDTH = 16,
    parameter int PIPE_STAGES = 5 // Adjusted for more realistic pipelining
) (
    input logic clk,
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    output logic [2*WIDTH-1:0] result
);

    logic [2*WIDTH-1:0] pipeline [0:PIPE_STAGES-1];

    // Initial multiplication pipelined over several stages
    always_ff @(posedge clk) begin
        pipeline[0] <= a * b;
        for (int i = 1; i < PIPE_STAGES; i++) begin
            pipeline[i] <= pipeline[i-1];
        end
    end

    assign result = pipeline[PIPE_STAGES-1];
endmodule

module matrix_mult #(
    parameter int N = 4,               // Matrix size (NxN)
    parameter int WIDTH = 16,          // Bit-width of input elements
    parameter int PIPE_STAGES = 5      // Reduced pipeline stages in multiplication
) (
    input logic clk,
    input logic [WIDTH-1:0] A[N][N],
    input logic [WIDTH-1:0] B[N][N],
    output logic [2*WIDTH-1:0] C[N][N]
);

    logic [2*WIDTH-1:0] products[N][N][N]; // Product of A[i][k] * B[k][j]

    // Generate multipliers
    generate
        for (genvar i = 0; i < N; i++) begin
            for (genvar j = 0; j < N; j++) begin
                for (genvar k = 0; k < N; k++) begin
                    multiply #(
                        .WIDTH(WIDTH),
                        .PIPE_STAGES(PIPE_STAGES)
                    ) mul_inst (
                        .clk(clk),
                        .a(A[i][k]),
                        .b(B[k][j]),
                        .result(products[i][j][k])
                    );
                end
            end
        end
    endgenerate

    // Summing up the results with reduced computational complexity per cycle
    logic [2*WIDTH-1:0] sum[N][N];

    always_ff @(posedge clk) begin
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                sum[i][j] = 0;
                for (int k = 0; k < N; k++) begin
                    sum[i][j] = sum[i][j] + products[i][j][k];
                }
                C[i][j] <= sum[i][j];
            end
        end
    end
endmodule

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
