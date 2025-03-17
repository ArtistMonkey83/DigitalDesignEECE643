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

logic  a, b, c, S0, S1, S2, S0Not, S1Not, S2Not;          // Internal signals

flipFlop ffA(.clk(clk), .reset(reset), .d(~( S1 | S2)), .q((S0)), .qNot(S0Not));
flipFlop ffB(.clk(clk), .reset(reset), .d( ~(S0Not & S2Not)), .q(S1), .qNot(S1Not));
flipFlop ffC(.clk(clk), .reset(reset), .d(~(S0 ^ S1Not)), .q(S2), .qNot(S2Not));

assign {a, b, c} = {S0, S1, S2};
assign y = ~(S0Not | S1Not);

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
