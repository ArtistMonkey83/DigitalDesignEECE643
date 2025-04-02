`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 03/29/2025 07:26:38 PM
// Design Name: Optimized state diagram implementation
// Module Name: activ4b
// Project Name: Activity 4
// Target Devices: 
// Tool Versions: 
// Description: Optimized version of the FSM presented in Activity #4, with the purpose of assessing if 
// there is a reduction in flip-flops with this design compared to activ4a design
//
//  Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module activ4b(
    input logic clk,
    input logic reset,
    input logic  x,
    output logic y,
    output logic[2:0] currentState,
    output logic [2:0] nextState
);

typedef enum logic [2:0] {S0, S1, S2, S3, S4} statetype;
statetype currentState_in, nextState_in;

always_ff @(posedge clk, posedge reset)
    if(reset) currentState_in <= S0;
    else currentState_in <= nextState_in;

always_comb
    case(currentState)
        S0: begin
            nextState_in = (x == 0) ? S3 : S1;
            y = (x==0) ? 1'b0 :1'b0;
            end
        S1: begin
            nextState_in = (x == 0) ? S2 : S0;
            y = (x==0) ? 1'b0 :1'b0;
            end
        S2: begin
            nextState_in = (x == 0) ? S4 : S0;
            y = (x==0) ? 1'b1 :1'b0;
            end
        S3: begin
            nextState_in = (x == 0) ? S3 : S1; 
            y = (x==0) ? 1'b1 :1'b1;
            end
        S4: begin
            nextState_in = (x == 0) ? S4 : S2;
            y = (x==0) ? 1'b0 :1'b1;
            end
        default: begin
                 nextState_in = S0;
                 y = 0;
                 end
    endcase
    
assign y = (currentState_in == S0);
assign currentState = currentState_in;
assign nextState = nextState_in;
        
endmodule
