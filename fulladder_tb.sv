`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 09:31:13 AM
// Design Name: 
// Module Name: fulladder_tb
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
// po go p1 g1 not submodudle
/// define logic those c0-c3
//////////////////////////////////////////////////////////////////////////////////


module fulladder_tb();
    logic [3:0] a;
    logic [3:0] b;
    logic [3:0] s;
    logic cin;
    logic cout;
    
    fulladder dut (
        .a (a),
        .b (b),
        .s (s),
        .cin(cin),
        .cout(cout)
    );
    
    initial begin
    a = 4'b0011; b = 4'b0011; cin = 1'b0;
    #10;
    a = 4'b0111; b = 4'b0111; cin = 1'b1;
    #10;
    a = 4'b1011; b = 4'b1011; cin = 1'b0;
    #10;
    a = 4'b0101; b = 4'b0001; cin = 1'b1;
    #10;
    end
endmodule
