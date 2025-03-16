`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico  
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 03/05/2025 12:02:37 AM
// Design Name: 
// Module Name: behav.sv
// Project Name: Activity 3
// Target Devices: 
// Tool Versions: 
// Description: Behavioral Model of the circuit for Activity 3
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module behavioral_model(
    input logic clk,        // Clock input
    input logic reset,      // Reset input
    output logic y          // Outputs
);

logic a, b, c;
typedef enum logic [3:0] {S0, S1, S2, S3, S4, S5, S6, S7} statetype;

statetype currentState, nextState;

always_ff @(posedge clk or posedge reset) begin
    if (reset)begin
        a <= 0;
        b <= 0;
        c <= 0;
    end else begin
        currentState <= nextState;
    end
end

always_comb 
    case(currentState)
        S0:  nextState = S4;
        S1:  nextState = S2;
        S2:  nextState = S1;
        S3:  nextState = S3;
        S4:  nextState = S7;
        S5:  nextState = S2;
        S6:  nextState = S2;
        S7:  nextState = S2;
        default: nextState = S0;
    
    endcase

assign a = ~( c | b );
assign b = ( a & b);
assign c = ( a ^ (~b));
assign y = ( a | b);

endmodule
