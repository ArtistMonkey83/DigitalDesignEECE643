`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 03/04/2025 07:57:58 PM
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

logic [63:0] dividend, divisor, quotient, remainder;    // Internal registers
logic [6:0] count;
typedef enum logic [2:0] {      // This enumeration translates to s0,s1,s2,s3,s4 for table purposes
    RESET,                      // S0 = 000
    SUBTRACT,                   // S1 = 001
    QSHIFT,                     // S2 = 010
    DSHIFT,                     // S3 = 011
    DONE                        // S4 = 100
} stateMachina_t;

stateMachina_t current_state, next_state;           // Used for transitioning from state to state

always_ff @(posedge clk or posedge reset) begin     // Reset and sequential logic "what state are we in?"
    if (reset) begin
        current_state <= RESET;
    end else begin            
        current_state <= next_state;
    end
end


always_comb begin               // Combinational logic for setting next_state variable and performing operations
    case (current_state)
        RESET: begin                         // Initializing registers to a known value
            dividend = {32'b0, dividend_in}; // Padding with zero 64-bit registers
            divisor = {32'b0, divisor_in};
            quotient = 0;
            remainder = 0;
            count = 0;                      // Initializing count to 0 for proper accumulation and bit tracking
            next_state = SUBTRACT;
        end
        SUBTRACT: begin                         // Do the subtraction
            remainder = remainder - divisor;
            next_state = QSHIFT;
        end
        QSHIFT: begin                           // Left shift the Quotient depending on what the remainder is
            if (remainder < 0) begin
                remainder = divisor + remainder;
                quotient = quotient << 1;
            end else begin
                quotient = (quotient << 1) | 1;
            end
            next_state = DSHIFT;
        end
        DSHIFT: begin                             // Right shift the Divisor always!
            divisor >>= 1;
            if (++count == 32) next_state = DONE; // Ensure count matches bit width being used
            else next_state = SUBTRACT;
        end
        DONE: begin                               // Executes after completing calculations for 32-bit #s
            ready = 1;
            //next_state = RESET;                 // We get stuck in done I can't use this
        end
    endcase
end                                               // Right Shift: take the 32 LSBs for remainder
                                                  // Left Shift: take the 32 MSBs for quotient
assign quotient_out = quotient[63:32];            // Connect the internal quotient reg with output 
assign remainder_out = remainder[63:32];          // Connect the internal remainder reg with output

endmodule