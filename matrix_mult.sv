`timescale 1ns / 1ps

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
