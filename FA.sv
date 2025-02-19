`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 09:27:34 AM
// Design Name: 
// Module Name: fulladder
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


module fulladder(
    input logic [3:0] a,b,
    output logic [3:0] s,
    input logic cin,
    output  cout
   );
    
    logic [2:0] c;
    add_one_bit A0 (.a(a[0]),.b(b[0]), .cin(cin), .cout(c[0]), .result(s[0]));
    add_one_bit A1 (.a(a[1]),.b(b[1]), .cin(c[0]), .cout(c[1]), .result(s[1]));
    add_one_bit A2 (.a(a[2]),.b(b[2]), .cin(c[1]), .cout(c[2]), .result(s[2]));
    add_one_bit A3 (.a(a[3]),.b(b[3]), .cin(c[2]), .cout(cout), .result(s[3]));
endmodule
