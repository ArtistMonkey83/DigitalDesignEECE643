`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 03/05/2025 12:23:06 PM
// Design Name: 
// Module Name: data_tb.sv
// Project Name: Activity 3
// Target Devices: 
// Tool Versions: 
// Description: Dataflow model for the circuit from Activity 3
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
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
    logic clk, reset;
    logic y;

behavioral_model DUT (      // Instantiate the behavioral module under test
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
