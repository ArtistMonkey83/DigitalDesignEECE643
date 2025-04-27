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
