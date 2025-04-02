`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 03/26/2025 10:34:39 AM
// Design Name: Initial state diagram implementation
// Module Name: activ4a
// Project Name: Activity 4
// Target Devices: 
// Tool Versions: 
// Description: Initial state diagram implementation for activity#4 with 8 states. The goal
// this activity to to compare equivalent circuits and use state reduction algorithm.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5, S6, S7} statetype;
//statetype currentState, nextState;

module activ4a(
    input logic clk,
    input logic reset,
    input logic  x,
    output logic y,
    output logic[2:0] currentState,
    output logic [2:0] nextState
);

typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5, S6, S7} statetype;
statetype currentState_in, nextState_in;

always_ff @(posedge clk, posedge reset)
    if(reset) currentState_in <= S0;
    else currentState_in <= nextState_in;

always_comb
    case(currentState)
        S0: begin
            nextState_in = (x == 0) ? S5 : S1;
            y = (x == 0) ? 1'b0 : 1'b0;
            end 
        S1: begin
            nextState_in = (x == 0) ? S3 : S2;
            y = (x == 0) ? 1'b0 : 1'b0;
            end
        S2: begin
            nextState_in = (x == 0) ? S5 : S4;
            y = (x == 0) ? 1'b0 : 1'b0;
            end
        S3: begin
            nextState_in = (x == 0) ? S6 : S0; 
            y = (x == 0) ? 1'b1 : 1'b0;
            end
        S4: begin
            nextState_in = (x == 0) ? S3 : S2;
            y = (x == 0) ? 1'b0 : 1'b0;
            end
        S5: begin
            nextState_in = (x == 0) ? S5 : S1;
            y = (x == 0) ? 1'b1 : 1'b1;
            end
        S6: begin
            nextState_in = (x == 0) ? S6 : S7;
            y = (x == 0) ? 1'b0 : 1'b1;
            end
        S7: begin
            nextState_in = (x == 0) ? S6 : S0;
            y = (x == 0) ? 1'b1 : 1'b0;
            end
        default: begin
                 nextState_in = S0;
                 y = 1'b0;
                 end
    endcase
        
assign y = (currentState_in == S0);
assign currentState = currentState_in;
assign nextState = nextState_in;
        
endmodule
