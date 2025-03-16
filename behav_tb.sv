`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chioo
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 03/05/2025 02:24:29 AM
// Design Name: 
// Module Name: behav_tb.sv
// Project Name: Activity 3
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


module testbench;           // Testbench signals
    logic clk;
    logic y;

behavioral_model DUT (  // Instantiate the module under test
    .clk(clk),
    .y(y)
);
    
always begin               // Clock generation
    clk = 1;
     forever #5 clk = ~clk;  // Generate a clock with 10 time units period
end
endmodule
