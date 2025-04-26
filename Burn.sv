`timescale 1ns / 1ps

module multiply #(
    parameter int WIDTH = 16,
    parameter int PIPE_STAGES = 10
) (
    input logic clk,
    input logic [WIDTH-1:0] a,
    input logic [WIDTH-1:0] b,
    output logic [2*WIDTH-1:0] result
);

    logic [2*WIDTH-1:0] pipeline [0:PIPE_STAGES];

    // Perform multiplication and pipeline the result
    assign pipeline[0] = a * b;

    always_ff @(posedge clk) begin
        for (int i = 1; i <= PIPE_STAGES; i++) begin
            pipeline[i] <= pipeline[i-1];
        end
    end

    assign result = pipeline[PIPE_STAGES];
endmodule

module matrix_mult #(
    parameter int N = 4,
    parameter int WIDTH = 16,
    parameter int PIPE_STAGES = 10
) (
    input logic clk,
    input logic [WIDTH-1:0] A[N][N],
    input logic [WIDTH-1:0] B[N][N],
    output logic [2*WIDTH-1:0] C[N][N]
);

    logic [2*WIDTH-1:0] product[N][N][N];

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
                        .result(product[i][j][k])
                    );
                end
            end
        end
    endgenerate

    // Sum the products and pipeline the sums
    logic [2*WIDTH-1:0] sum_pipeline[N][N][PIPE_STAGES+1];

    always_ff @(posedge clk) begin
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                sum_pipeline[i][j][0] = 0;
                for (int k = 0; k < N; k++) begin
                    sum_pipeline[i][j][0] += product[i][j][k];
                end
                for (int p = 1; p <= PIPE_STAGES; p++) begin
                    sum_pipeline[i][j][p] <= sum_pipeline[i][j][p-1];
                end
                C[i][j] <= sum_pipeline[i][j][PIPE_STAGES];
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

    // Clock generation for 900 MHz
    always #0.555 clk = ~clk;

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
