`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 09:53:46 AM
// Design Name: 
// Module Name: add_one_bit_tb
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


module add_one_bit_tb();
    logic result;
    logic cout; 
    logic a;
    logic b;
    logic cin;
    
    add_one_bit dut(
        .a (a),
        .b (b),
        .cin (cin),
        .cout (cout),
        .result (result)
    );
    
    initial begin
    a = 1'b0; b = 1'b0; cin = 1'b0;
    #10; // A = b= cin=0
    a = 1'b0; b = 1'b1; cin = 1'b0;
    #10; // a =1 & b = cin=0
    a = 1'b1; b = 1'b; cin = 1'b0;
    #10; //A=B=1 and cin =0
    a = 1'b0; b = 1'b0; cin = 1'b1;
    #10; // a=b=0 and cin =1
    a = 1'b0; b = 1'b1; cin = 1'b1;
    #10; // a =0 and b=cin=1
    a = 1'b1; b = 1'b0; cin = 1'b1;
    #10;  //a=cin=1 and b=0
    a = 1'b1; b = 1'b1; cin = 1'b1;
    #10;   // a=b=cin=1
    end
    
endmodule
