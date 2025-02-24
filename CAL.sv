`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University,Chico
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 02/15/2025 08:19:53 PM
// Design Name: Carry Look Ahead Adder
// Module Name: CAL
// Project Name: Activity 1
// Target Devices: That one Basys thing
// Tool Versions: Good question...
// Description: Activity 1 purpose is to perform timing analysis and compare the
//              the results of the ripple adder from Activity 0.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: CLA is the correct way to designate I have dyslexia
// 
////////////////////////////////////////////////////////////////////////////////

module CLA4(
    input  logic [3:0] a,  // 4-bit first operand, read-only signal
    input  logic [3:0] b,  // 4-bit second operand, read-only signal
    input  logic cin,      // Carry input is a single bit, read-only signal
    output logic [3:0] s,  // 4-bit sum result, written within the module
    output logic cout      // Final carry out, written within the module
);
    logic [3:0] G;         // Carry Generate, internal signal 
    logic [3:0] P;         // Carry Propagate, internal signal
    logic [4:0] C;         // Carry bits (including C0 = C4), internal signal
 
    assign C[0] = cin;     // Initialize carry input

                           // Generate carry look ahead combinational logic
    assign G = a & b;      // G_i = A_i * B_i, with i∈{0,1,2,3} " both bits are 1, ∴  a 10 Generates a carry"
    assign P = a ^ b;      // P_i = A_i ⊕ B_i, with i∈{0,1,2,3} " if at least 1 input == 1,∴ a carry input will pass to higher bit"

                           // Compute carry values
    assign C[1] = (P[0] & C[0]) | G[0];
    //assign C[2] = (P[1] & C[1]) | G[1];
    //assign C[3] = (P[2] & C[2]) | G[2];
    assign C[2] = (P[1] & G[0]) | (P[1] & P[0] & C[0]) | G[1];
    assign C[3] = (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]) | G[2];
    assign C[4] =  G[3] | (P[3] & C[3]); // G[3] can generate a carry if a=b=1
                                         // P[3] can propagate a carry if there is a carry in C[3] and if a or b == 1
    assign s[0] = P[0] ^ C[0];           // S_i = P_i ⊕ C_i, with i∈{0,1,2,3}
    assign s[1] = P[1] ^ C[1];
    assign s[2] = P[2] ^ C[2];
    assign s[3] = P[3] ^ C[3];
    //assign s = P[3:0] ^ C[3:0];      // S_i = P_i ⊕ C_i, with i∈{0,1,2,3}
    assign cout = C[4];         // Assign final carry-out

endmodule
