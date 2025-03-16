`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 03/05/2025 11:17:01 AM
// Design Name: 
// Module Name: data.sv
// Project Name: Activity 3
// Target Devices: 
// Tool Versions: 
// Description: Dataflow model of the circuit from Activity 3
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module dataflow_model(
    input logic clk,     // Although unused, kept for interface consistency
    input logic reset,   // Same as above
    output logic y
);

    // Define internal signals, if needed
    logic a, b, c;
    logic notA, notB, notC

    // Logic expressions using dataflow modeling
    assign a = ~(c | b);        // Equivalent to NOR gate
    assign notA = ~a;          // Equivalent to NOT gate
    assign notC = ~c;          // Equivalent to NOT gate
    assign b = ~(notA & notC);  // Equivalent to NAND gate
    assign notB = ~b;          // Equivalent to NOT gate
    assign c = ~(a ^ notB);    // Equivalent to XNOR gate
    assign y = ~(notB & notA);  // Equivalent to NOR gate

endmodule
