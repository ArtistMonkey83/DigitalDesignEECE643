`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2025 09:29:12 AM
// Design Name: 
// Module Name: CLA4_tb
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

module CLA4_tb();

    logic [3:0] a;
    logic [3:0] b;      // Input operand declarations using logic, internal signal
    logic cin;          // Carry input using logic, internal signal
    logic [3:0] s;      // 4-bit sum output using logic, internal signal
    logic cout;         // Carry out using logic, internal signal

    CLA4 DUT(
        .a(a),
        .b(b),
        .cin(cin),
        .s(s),
        .cout(cout)
    );
    initial 
    begin
        a = 4'b0000; b = 4'b0000; cin = 1'b0; #100    // Initialize all inputs to a starting state
        //$monitor("Time=%t | a=%b b=%b cin=%b | s=%b cout=%b", $time, a, b, cin, s, cout);     // Display all signals for debugging?
        
        a = 4'b0001; b = 4'b0001; cin = 1'b0; #100;     // 1111(b) cout=0
        a = 4'b0010; b = 4'b0010; cin = 1'b0; #100;     // 0000(b) cout=1
        a = 4'b0011; b = 4'b1111; cin = 1'b0; #100;     // 1111(b) cout=0
        a = 4'b0100; b = 4'b0100; cin = 1'b0; #100;     // 0011(b) cout=1

    end



endmodule
