`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico
// Engineer: Yolanda Reyes #011234624
// 
// Create Date: 03/29/2025 02:54:57 PM
// Design Name: Initial state diagram testbench
// Module Name: activ4a_tb
// Project Name: Activity 4
// Target Devices: 
// Tool Versions: 
// Description: Testbench for the initial state diagram for activity 4
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module activ4a_tb;
    logic clk, reset, x, y;
    logic [2:0] currentState, nextState;
    
    activ4a dut(
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .currentState(currentState),
        .nextState(nextState)
    );
    
    initial begin clk = 1'b0;
    forever #10 clk = ~clk; end
    
    always_ff @(posedge clk, posedge reset)begin
        if(reset) x <= 1'b1;
        else x <= y;
    end           
    
    initial begin
        reset = 1;
        #10;
        reset = 0;
        #10;
    end
                                        
endmodule
