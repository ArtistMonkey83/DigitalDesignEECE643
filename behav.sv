`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico  
// Engineer: Yolanda Reyes
// 
// Create Date: 03/05/2025 12:02:37 AM
// Design Name: 
// Module Name: behav
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
    output logic a, b, c, y // Outputsfix abc
);

typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5, S6, S7, S8} statetype;
statetype currentState, nextState;

// Sequential logic to handle feedback among a, b, and c
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        currentState <= S1;
    end else begin
        currentState <= nextState;
    end
end

always_comb begin       
    case(currentState)
        S1: nextState = S5;
        S2: nextState = S3;
        S3: nextState = S2;
        S4: nextState = S4;
        S5: nextState = S8;
        S6: nextState = S4;
        S7: nextState = S3;
        S8: nextState = S3;
        default: nextState = S1;
    endcase
    
    assign y = (currentState == S8 | currentState == S7);
    assign {a, b, c} = {currentState[2], currentState[1], currentState[0]};
end

endmodule
