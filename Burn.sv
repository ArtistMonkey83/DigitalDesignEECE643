`timescale 1ns / 1ps

module multiply #(
    parameter int WIDTH = 16,          // Bit-width of input/output
    parameter int PIPE_STAGES = 10     // Number of pipeline stages
) (
    input  logic clk,
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [2*WIDTH-1:0] result
);

    logic [2*WIDTH-1:0] mult_result;
    logic [2*WIDTH-1:0] pipeline [0:PIPE_STAGES-1];

    // Perform multiplication
    assign mult_result = a * b;

    // Pipeline the multiplication result
    always_ff @(posedge clk) begin
        pipeline[0] <= mult_result;
        for (int i = 1; i < PIPE_STAGES; i++) begin
            pipeline[i] <= pipeline[i-1];
        end
    end

    assign result = pipeline[PIPE_STAGES-1];
endmodule

module matrix_mult #(
    parameter int N = 4,                // Matrix size (NxN)
    parameter int WIDTH = 16,           // Bit-width of input elements
    parameter int PIPE_STAGES = 10      // Pipeline stages for multiply
) (
    input  logic clk,
    input  logic [WIDTH-1:0] A[N][N],
    input  logic [WIDTH-1:0] B[N][N],
    output logic [2*WIDTH-1:0] C[N][N]
);

    logic [2*WIDTH-1:0] products[N][N][N];    // Product of A[i][k] * B[k][j]

    // Generate multipliers and add pipelining
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

    // Summation logic with pipelining
    always_ff @(posedge clk) begin
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                logic [2*WIDTH-1:0] sum = 0;
                for (int k = 0; k < N; k++) begin
                    sum += products[i][j][k];
                end
                C[i][j] <= sum;
            end
        end
    end
endmodule

module matrix_mult_tb;
    parameter int N = 4;
    parameter int WIDTH = 16;
    parameter int PIPE_STAGES = 10;

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

    // Clock generation
    always #0.555 clk = ~clk;  // Adjusted to target closer to 900 MHz

    initial begin
        clk = 0;
        // Initialize matrices
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                A[i][j] = i + j;
                B[i][j] = (i == j) ? 1 : 0;  // Identity matrix
            }
        end

        #100;

        // Display result
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
