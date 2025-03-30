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
        S0: nextState_in = (x == 0) ? S5 : S1;
        S1: nextState_in = (x == 0) ? S3 : S2;
        S2: nextState_in = (x == 0) ? S5 : S4;
        S3: nextState_in = (x == 0) ? S3 : S2; 
        S4: nextState_in = (x == 0) ? S3 : S2;
        S5: nextState_in = (x == 0) ? S5 : S1;
        S6: nextState_in = (x == 0) ? S6 : S7;
        S7: nextState_in = (x == 0) ? S6 : S0;
        default: nextState_in = S0;
    endcase
    
assign y = (currentState_in == S0);
assign currentState = currentState_in;
assign nextState = nextState_in;
        
endmodule
