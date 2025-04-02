`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 03/29/2025 07:29:54 PM
// Design Name: Optimized state diagram implementation
// Module Name: activ4b_tb
// Project Name: Activity 4
// Target Devices: 
// Tool Versions: 
// Description: Optimized version of the FSM presented in Activity #4, with the purpose of assessing if 
// there is a reduction in flip-flops with this design compared to activ4a design
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module activ4b_tb;
    logic clk, reset, x, y;
    logic [2:0] currentState, nextState;
    
    activ4b dut(
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
                                       