`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 09:51:05 AM
// Design Name: 
// Module Name: add_one_bit
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


module add_one_bit(
    input logic a, b, cin,
    output logic cout, result
    );
    
    assign result = a ^ b ^ cin;
    assign cout = (a&b) | (a&cin) | (b&cin);
endmodule
