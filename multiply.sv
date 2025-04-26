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
