// ============================
// multiply.sv
// ============================

`timescale 1ns / 1ps

module matrix_mult #(
    parameter int SIZE = 8,        // Size of the matrix
    parameter int DATA_WIDTH = 16, // Bit width of matrix elements
    parameter int PIPE_STAGES = 3  // Number of pipeline stages in the multipliers
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic [DATA_WIDTH-1:0] A[SIZE][SIZE], // Input matrix A
    input  logic [DATA_WIDTH-1:0] B[SIZE][SIZE], // Input matrix B
    output logic [DATA_WIDTH-1:0] C[SIZE][SIZE], // Output matrix C
    output logic done
);

    // Internal variables for storing products and sums
    logic [2*DATA_WIDTH-1:0] products[SIZE][SIZE][SIZE];  // Intermediate products of multiplication
    logic [2*DATA_WIDTH-1:0] sums[SIZE][SIZE];            // Sums of products for each element in C
    logic [SIZE][SIZE] calc_done;                         // Done signals from each multiply instance

    // Instantiate the multipliers
    genvar i, j, k;
    generate
        for (i = 0; i < SIZE; i++) begin
            for (j = 0; j < SIZE; j++) begin
                for (k = 0; k < SIZE; k++) begin
                    multiply #(
                        .DATA_WIDTH(DATA_WIDTH),
                        .PIPE_STAGES(PIPE_STAGES)
                    ) mult_inst (
                        .clk(clk),
                        .rst(rst),
                        .a(A[i][k]),
                        .b(B[k][j]),
                        .p(products[i][j][k])
                    );
                end
                // Summation logic for each element in C
                always_comb begin
                    sums[i][j] = 0;
                    for (k = 0; k < SIZE; k++) begin
                        sums[i][j] += products[i][j][k];
                    end
                end
            end
        end
    endgenerate

    // Register outputs and provide done signal
    logic all_done;
    always_ff @(posedge clk) begin
        if (rst) begin
            done <= 0;
            all_done <= 0;
        end else begin
            all_done <= &calc_done;  // AND all done signals
            if (all_done) begin
                done <= 1;
                // Assign results to output matrix C
                for (i = 0; i < SIZE; i++) begin
                    for (j = 0; j < SIZE; j++) begin
                        C[i][j] <= sums[i][j][DATA_WIDTH-1:0];  // Truncate to original data width
                    end
                end
            end else begin
                done <= 0;
            end
        end
    end

endmodule

// ============================
// matrix_mult.sv
// ============================

`timescale 1ns / 1ps

module matrix_mult #(
    parameter int SIZE = 8,        // Size of the matrix
    parameter int DATA_WIDTH = 16, // Bit width of matrix elements
    parameter int PIPE_STAGES = 3  // Number of pipeline stages in the multipliers
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic [DATA_WIDTH-1:0] A[SIZE][SIZE], // Input matrix A
    input  logic [DATA_WIDTH-1:0] B[SIZE][SIZE], // Input matrix B
    output logic [DATA_WIDTH-1:0] C[SIZE][SIZE], // Output matrix C
    output logic done
);

    // Internal variables for storing products and sums
    logic [2*DATA_WIDTH-1:0] products[SIZE][SIZE][SIZE];  // Intermediate products of multiplication
    logic [2*DATA_WIDTH-1:0] sums[SIZE][SIZE];            // Sums of products for each element in C
    logic [SIZE][SIZE] calc_done;                         // Done signals from each multiply instance

    // Instantiate the multipliers
    genvar i, j, k;
    generate
        for (i = 0; i < SIZE; i++) begin
            for (j = 0; j < SIZE; j++) begin
                for (k = 0; k < SIZE; k++) begin
                    multiply #(
                        .DATA_WIDTH(DATA_WIDTH),
                        .PIPE_STAGES(PIPE_STAGES)
                    ) mult_inst (
                        .clk(clk),
                        .rst(rst),
                        .a(A[i][k]),
                        .b(B[k][j]),
                        .p(products[i][j][k])
                    );
                end
                // Summation logic for each element in C
                always_comb begin
                    sums[i][j] = 0;
                    for (k = 0; k < SIZE; k++) begin
                        sums[i][j] += products[i][j][k];
                    end
                end
            end
        end
    endgenerate

    // Register outputs and provide done signal
    logic all_done;
    always_ff @(posedge clk) begin
        if (rst) begin
            done <= 0;
            all_done <= 0;
        end else begin
            all_done <= &calc_done;  // AND all done signals
            if (all_done) begin
                done <= 1;
                // Assign results to output matrix C
                for (i = 0; i < SIZE; i++) begin
                    for (j = 0; j < SIZE; j++) begin
                        C[i][j] <= sums[i][j][DATA_WIDTH-1:0];  // Truncate to original data width
                    end
                end
            end else begin
                done <= 0;
            end
        end
    end

endmodule



// ============================
// matrix_mult_tb.sv (testbench)
// ============================

`timescale 1ns / 1ps

module matrix_mult_tb;

    // Parameters for the matrix size and data width
    localparam SIZE = 8;
    localparam DATA_WIDTH = 16;
    localparam PIPE_STAGES = 3;

    // Testbench-specific variables
    logic clk;
    logic rst;
    logic start;
    logic done;
    logic [DATA_WIDTH-1:0] A[SIZE][SIZE];
    logic [DATA_WIDTH-1:0] B[SIZE][SIZE];
    logic [DATA_WIDTH-1:0] C[SIZE][SIZE];
    
    // Instantiate the matrix multiplication module
    matrix_mult #(
        .SIZE(SIZE),
        .DATA_WIDTH(DATA_WIDTH),
        .PIPE_STAGES(PIPE_STAGES)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .A(A),
        .B(B),
        .C(C),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Initialize and apply inputs
    initial begin
        rst = 1;
        start = 0;
        initialize_matrices();
        #20 rst = 0;
        #20 start = 1;
        #10 start = 0;
    end

    // Monitor when the operation is complete
    always @(posedge clk) begin
        if (done) begin
            $display("Matrix multiplication complete.");
            check_results();
            $finish;
        end
    end

    // Initialize matrix A and B with some values
    task initialize_matrices();
        integer i, j;
        for (i = 0; i < SIZE; i++) begin
            for (j = 0; j < SIZE; j++) begin
                A[i][j] = $random % 256; // Random values between 0 and 255
                B[i][j] = $random % 256;
            end
        end
    endtask

    // Check the results against expected values
    task check_results();
        integer i, j, k;
        logic [DATA_WIDTH-1:0] expected[SIZE][SIZE];
        // Compute expected results
        for (i = 0; i < SIZE; i++) begin
            for (j = 0; j < SIZE; j++) begin
                expected[i][j] = 0;
                for (k = 0; k < SIZE; k++) begin
                    expected[i][j] += A[i][k] * B[k][j];
                }
                if (expected[i][j] !== C[i][j]) begin
                    $display("Mismatch at C[%0d][%0d]: Expected %0d, Got %0d", i, j, expected[i][j], C[i][j]);
                    $fatal;
                end
            end
        end
        $display("All results correct!");
    endtask

endmodule
