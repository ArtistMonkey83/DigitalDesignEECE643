`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/08/2025 06:51:35 PM
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


module divYR(  input logic clk,
    input logic reset,
    input logic [31:0] dividend_in,
    input logic [31:0] divisor_in,
    output logic [31:0] quotient_out,
    output logic [31:0] remainder_out,
    output logic ready
);

logic [31:0] dividend, divisor, quotient, remainder;
logic [5:0] count;
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
            dividend = 0;
            divisor = 0;
            quotient = 0;
            remainder = 0;
            count = 0;
            next_state = SUBTRACT;
        end
        SUBTRACT: begin
            remainder = remainder - divisor;
            next_state = QSHIFT;
        end
        QSHIFT: begin
            if (remainder < 0) begin
                remainder = divisor + remainder;
                quotient = quotient << 1;
            end 
            else 
                quotient = (quotient << 1) | 1;
            next_state = DSHIFT;
        end
        DSHIFT: begin
            divisor = divisor >> 1;
            if (++count == 32) next_state = DONE;
            else next_state = SUBTRACT;
        end
        DONE: begin
            ready = 1;
            next_state = RESET;
        end
    endcase
end

assign quotient_out = quotient;
assign remainder_out = remainder;
assign ready = (current_state == DONE);

