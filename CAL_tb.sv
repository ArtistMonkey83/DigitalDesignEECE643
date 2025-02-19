`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2025 08:22:45 PM
// Design Name: 
// Module Name: CAL_tb
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

`timescale 1ns / 1ps

module CAL_tb;
    logic [3:0] a;
    logic [3:0] b;      // Input operand declarations using logic, internal signal
    logic cin;          // Carry input using logic, internal signal
    logic [3:0] s;      // 4-bit sum output using logic, internal signal
    logic cout;         // Carry out using logic, internal signal

    CAL dut(
        .a(a),
        .b(b),
        .cin(cin),
        .s(s),
        .cout(cout)
    );

    initial begin
        a = 4'b0000; b = 4'b0000; cin = 1'b0; #30    // Initialize all inputs to a starting state
        $monitor("Time=%t | a=%b b=%b cin=%b | s=%b cout=%b", $time, a, b, cin, s, cout);     // Display all signals for debugging?
        
        a = 4'b1010; b = 4'b0101; cin = 0; #10;
        a = 4'b1111; b = 4'b0001; cin = 1; #10;
        a = 4'b0000; b = 4'b1111; cin = 0; #10;
        a = 4'b1001; b = 4'b1001; cin = 1; #10;

    end
end
