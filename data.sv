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

module structural_model(
    input logic clk,     
    input logic reset,   
    output logic y
);

logic a, b, c, S0, S1, S2;          // Internal signals

flipFlop ffA(.clk(clk), .reset(reset), .d(~( S1 | S2)), .q((~S0)));
flipFlop ffB(.clk(clk), .reset(reset), .d( S0 & S2), .q(S1));
flipFlop ffC(.clk(clk), .reset(reset), .d(S0 ~^ (~S1)), .q(S2));

assign {a, b, c} = {S0, S1, S2};
assign y = (S0 | S1);

endmodule

module flipFlop( 
    input logic clk,
    input logic reset,
    input logic d,
    output logic q,
    output logic qNot
);

logic temp;

always_ff @(posedge clk or posedge reset)begin
    if(reset)begin
        temp <= 1'b0;
    end else begin
        temp <= d;
    end
end

assign q = temp;
assign qNot = ~temp;


endmodule
