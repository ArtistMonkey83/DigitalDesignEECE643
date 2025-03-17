`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2025 05:14:32 PM
// Design Name: 
// Module Name: RTL_model_tb
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


module RTL_model_tb;           // Testbench signals
    logic clk, reset;
    logic y;

RTL_model DUT (      // Instantiate the behavioral module under test
    .clk(clk),
    .reset(reset),
    .y(y)
);
    
always begin                // Clock generation
    clk = 1;
    forever #10 clk = ~clk;// Generate a clock with 10 time units period
end

initial begin               // Start the testing
    reset = 1;              // Initializing at reset
    #10;                    // Waiting for some time to pass
    reset = 0;              // (┛◉Д◉)┛彡┻━┻
    #10;                    // Wait for some time to pass
    #83;                    // Let it run for a while
end
endmodule
