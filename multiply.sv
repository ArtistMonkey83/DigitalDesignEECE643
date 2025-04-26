// ============================
// multiply.sv
// ============================

`timescale 1ns / 1ps

module multiply #(
    parameter int DATA_WIDTH = 16,  // Width of the data inputs
    parameter int PIPE_STAGES = 3   // Number of pipeline stages
)(
    input  logic clk,
    input  logic rst,
    input  logic [DATA_WIDTH-1:0] a,
    input  logic [DATA_WIDTH-1:0] b,
    output logic [2*DATA_WIDTH-1:0] p // Output product
);

    // Intermediate pipeline registers for the multiplication stages
    logic [2*DATA_WIDTH-1:0] pipeline_regs[PIPE_STAGES];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pipeline_regs[0] <= 0;
        end else begin
            pipeline_regs[0] <= a * b;  // Initial multiplication stage
        end
    end

    // Generate the remaining pipeline stages
    genvar i;
    generate
        for (i = 1; i < PIPE_STAGES; i++) begin
            always_ff @(posedge clk or posedge rst) begin
                if (rst) begin
                    pipeline_regs[i] <= 0;
                end else begin
                    pipeline_regs[i] <= pipeline_regs[i-1];  // Pass the result to the next stage
                end
            end
        end
    endgenerate

    // Assign the final pipeline stage to the output
    assign p = pipeline_regs[PIPE_STAGES-1];

endmodule



// ============================
// matrix_mult.sv
// ============================

module matrix_mult #(
    parameter int SIZE = 8,        // Size of the matrix (e.g., 8x8)
    parameter int DATA_WIDTH = 16, // Bit width of matrix elements
    parameter int PIPE_STAGES = 3  // Number of pipelining stages in the multipliers
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic [DATA_WIDTH-1:0] A[SIZE][SIZE], // Input matrix A
    input  logic [DATA_WIDTH-1:0] B[SIZE][SIZE], // Input matrix B
    output logic [DATA_WIDTH-1:0] C[SIZE][SIZE], // Output matrix C
    output logic done
);

    // Internal Variables
    logic [DATA_WIDTH-1:0] products[SIZE][SIZE][SIZE]; // Intermediate products
    logic [DATA_WIDTH-1:0] sums[SIZE][SIZE]; // Sums of each row's products for final result
    logic [PIPE_STAGES-1:0][SIZE][SIZE][SIZE] pipeline_registers; // Pipeline registers for multipliers
    logic [PIPE_STAGES-1:0][SIZE][SIZE] sum_pipeline_registers; // Pipeline registers for adder tree

    // Pipelined Multipliers Instantiation
    genvar i, j, k;
    generate
        for (i = 0; i < SIZE; i++) begin
            for (j = 0; j < SIZE; j++) begin
                for (k = 0; k < SIZE; k++) begin
                    always_ff @(posedge clk) begin
                        if (rst) begin
                            pipeline_registers[0][i][j][k] <= 0;
                        end else if (start) begin
                            pipeline_registers[0][i][j][k] <= A[i][k] * B[k][j];
                            // Pipeline stages
                            for (int stage = 1; stage < PIPE_STAGES; stage++) begin
                                pipeline_registers[stage][i][j][k] <= pipeline_registers[stage-1][i][j][k];
                            end
                            products[i][j][k] <= pipeline_registers[PIPE_STAGES-1][i][j][k];
                        end
                    end;
                end
            end
        end
    endgenerate

    // Summation Logic
    generate
        for (i = 0; i < SIZE; i++) begin
            for (j = 0; j < SIZE; j++) begin
                always_comb begin
                    sums[i][j] = 0;
                    for (k = 0; k < SIZE; k++) begin
                        sums[i][j] += products[i][j][k];
                    end
                    // Register output sums
                    always_ff @(posedge clk) begin
                        if (rst) begin
                            sum_pipeline_registers[0][i][j] <= 0;
                        end else begin
                            sum_pipeline_registers[0][i][j] <= sums[i][j];
                            // Pipeline stages for sums
                            for (int stage = 1; stage < PIPE_STAGES; stage++) begin
                                sum_pipeline_registers[stage][i][j] <= sum_pipeline_registers[stage-1][i][j];
                            end
                            C[i][j] <= sum_pipeline_registers[PIPE_STAGES-1][i][j];
                        end
                    end;
                end
            end
        end
    endgenerate

    // Done signal logic
    always_ff @(posedge clk) begin
        if (rst) begin
            done <= 0;
        end else begin
            done <= 1; // Set done when the last stage of the pipeline completes
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
