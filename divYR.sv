`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2025 07:57:58 PM
// Design Name: 
// Module Name: divYR
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module divYR(
    input logic clk,
    input logic reset,  
    input logic [31:0] dividend_in,
    input logic [31:0] divisor_in,
    output logic [31:0] quotient_out,
    output logic [31:0] remainder_out,
    output logic ready
);

logic [63:0] dividend, divisor, quotient, remainder;
logic [6:0] count;
typedef enum logic [2:0] {
    RESET,
    SUBTRACT,
    QSHIFT,
    DSHIFT,
    DONE
} stateMachina_t;

stateMachina_t current_state, next_state;

// Reset and sequential logic
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= RESET;
    end else begin            
        current_state <= next_state;
    end
end

// Combinational logic for next state and operations
always_comb begin
    case (current_state)
        RESET: begin
            dividend = {32'b0, dividend_in}; // Properly initialize 64-bit registers
            divisor = {32'b0, divisor_in};
            quotient = 0;
            remainder = 0;
            count = 0;
            next_state = SUBTRACT;
        end
        SUBTRACT: begin
            remainder = dividend - divisor;
            next_state = QSHIFT;
        end
        QSHIFT: begin
            if (remainder < 0) begin
                remainder = remainder + divisor;
                quotient = quotient << 1;
            end else begin
                quotient = (quotient << 1) | 1;
            end
            next_state = DSHIFT;
        end
        DSHIFT: begin
            divisor >>= 1;
            if (++count == 32) next_state = DONE; // Ensure count matches bit width being used
            else next_state = SUBTRACT;
        end
        DONE: begin
            ready = 1;
            next_state = RESET;
        end
    endcase
end

assign quotient_out = quotient[31:0];
assign remainder_out = remainder[31:0];

endmodule