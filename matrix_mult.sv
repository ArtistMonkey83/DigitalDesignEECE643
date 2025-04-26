`timescale 1ns / 1ps


module matrix_mult #(
    parameter int N = 4,               // Matrix size (NxN)
    parameter int WIDTH = 16,           // Bit-width of input elements
    parameter int PIPE_STAGES = 10       // Pipeline stages for multiply
) (
    input  logic                   clk,
    input  logic [WIDTH-1:0]        A[N][N],
    input  logic [WIDTH-1:0]        B[N][N],
    output logic [2*WIDTH-1:0]      C[N][N]
);

    logic [2*WIDTH-1:0] products[N][N][N];   // products[i][j][k] = A[i][k] * B[k][j]
    logic [2*WIDTH-1:0] sums[N][N][N];       // pipelined sums

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

    // Pipeline sums using adder trees
    always_ff @(posedge clk) begin
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                sums[i][j][0] <= products[i][j][0];
                for (int k = 1; k < N; k++) begin
                    sums[i][j][k] <= sums[i][j][k-1] + products[i][j][k];
                end
                // Final result after all additions
                C[i][j] <= sums[i][j][N-1];
            end
        end
    end

endmodule
