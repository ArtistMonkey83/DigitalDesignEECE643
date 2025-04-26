// ============================
// multiply.sv
// ============================

module multiply #(
    parameter int WIDTH = 16,         // Bit-width of input/output
    parameter int PIPE_STAGES = 2      // Number of pipeline stages
) (
    input  logic                  clk,
    input  logic [WIDTH-1:0]       a,
    input  logic [WIDTH-1:0]       b,
    output logic [2*WIDTH-1:0]     result
);

    logic [2*WIDTH-1:0] mult_result;
    logic [2*WIDTH-1:0] pipeline [0:PIPE_STAGES-1];

    // Perform multiplication immediately
    assign mult_result = a * b;

    // Register pipeline
    always_ff @(posedge clk) begin
        pipeline[0] <= mult_result;
        for (int i = 1; i < PIPE_STAGES; i++) begin
            pipeline[i] <= pipeline[i-1];
        end
    end

    assign result = pipeline[PIPE_STAGES-1];

endmodule


// ============================
// matrix_mult.sv
// ============================

module matrix_mult #(
    parameter int N = 4,               // Matrix size (NxN)
    parameter int WIDTH = 16,           // Bit-width of input elements
    parameter int PIPE_STAGES = 2       // Pipeline stages for multiply
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


// ============================
// matrix_mult_tb.sv (testbench)
// ============================

module matrix_mult_tb;

    parameter int N = 4;
    parameter int WIDTH = 16;
    parameter int PIPE_STAGES = 2;

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
    always #0.5 clk = ~clk; // 1ns clock period = 1GHz!

    initial begin
        clk = 0;

        // Initialize matrices
        for (int i = 0; i < N; i++) begin
            for (int j = 0; j < N; j++) begin
                A[i][j] = i + j;
                B[i][j] = (i==j) ? 1 : 0;  // Identity matrix
            end
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
