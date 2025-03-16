`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California State University, Chico  
// Engineer: Yolanda Reyes #011234614
// 
// Create Date: 03/05/2025 12:02:37 AM
// Design Name: 
// Module Name: behav.sv
// Project Name: Activity 3
// Target Devices: 
// Tool Versions: 
// Description: Behavioral Model of the circuit for Activity 3
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module behavioral_model(
    input logic clk,        // Clock input
    input logic reset,      // Reset input
    output logic y          // Outputs
);

logic a, b, c;

always_ff @(posedge clk or posedge reset) begin
    if (reset)begin
        a <= 0;
        b <= 0;
        c <= 0;
    end else begin
        a <= ~( c | b );
        b <= ( a & b);
        c <= ( a ^ (~b));
    end
end

assign     y = ( a | b);

endmodule
