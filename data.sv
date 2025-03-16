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
    input logic clk,     
    input logic reset,   
    output logic y
);

logic a, b, c;          // Internal signals

assign S = a | b;
assign y = S;

flipFlop ffA(clk,reset,~c,~b);
flipFlop ffB(clk,reset,a,c);
flipFlop ffC(clk,reset,a,~b);

endmodule

module flipFlop( 
    input logic clk,
    input logic reset,
    input logic d,
    output logic q
);

always_ff @(posedge clk or posedge reset)begin
    if(reset)begin
        q <= 1'b0;
    end else begin
        q <= d;
    end
end

