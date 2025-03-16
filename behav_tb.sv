`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/05/2025 02:24:29 AM
// Design Name: 
// Module Name: behav_tb
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


module testbench;           // Testbench signals
    logic clk, reset;
    logic a, b, c, y;

    behavioral_model DUT (  // Instantiate the module under test
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .c(c),
        .y(y)
    );
    
    always begin               // Clock generation
        clk = 1;
         #5 clk = ~clk;  // Generate a clock with 10 time units period
    end

    initial begin
        reset = 1;    // Initialize all signals
        #10;        
        reset = 0;    // Checking initial conditions (after reset, expect all zeros)
        #10;       
//        check_outputs(0, 0, 0, 1);      
//        #10;  

//        force DUT.a = 1; // Force some values to check behavior
//        force DUT.b = 1; // 
//        release DUT.a;
//        release DUT.b;
//        #10;            // Allow changes to propagate
//        check_outputs(1, 1, 1, 0); // 

//        force DUT.b = 0;
//        #10;
//        check_outputs(0, 0, 1, 1);  //
//        #10;
//        $display("All tests completed.");
//        $finish;
    end

//    // Task to check outputs against expected values
//    task check_outputs(logic exp_a, logic exp_b, logic exp_c, logic exp_y);
//        if ((a === exp_a) && (b === exp_b) && (c === exp_c) && (y === exp_y)) begin
//            $display("Test passed at time %0t: a=%0b, b=%0b, c=%0b, y=%0b", $time, a, b, c, y);
//        end else begin
//            $display("Test failed at time %0t: Expected a=%0b, b=%0b, c=%0b, y=%0b but got a=%0b, b=%0b, c=%0b, y=%0b",
//                     $time, exp_a, exp_b, exp_c, exp_y, a, b, c, y);
//            $finish;
//        end
//    endtask
endmodule
